#!/bin/bash
# ============================================
# Outline Knowledge Base Fetcher
# ============================================
# Usage:
#   ./outline-fetch.sh --list-collections
#   ./outline-fetch.sh --search "keyword"
#   ./outline-fetch.sh --doc <urlId|docId|URL>
#   ./outline-fetch.sh --children <urlId|URL>     # child docs (nested)
#   ./outline-fetch.sh --collection <collectionId> [--limit 50]
#   ./outline-fetch.sh --collection-docs <collectionId|urlId>
# ============================================
# Supported URL formats:
#   https://outline-rbi.jatismobile.com/doc/post-login-GDTFBgZmll
#   GDTFBgZmll                   (urlId only)
#   9bb1fd97-76c7-45dc-...       (UUID)
# ============================================
# Credentials loaded from: ~/.config/jatis/.env
# Required: OUTLINE_API_URL, OUTLINE_API_TOKEN
# ============================================

set -e

# Load environment
SECRETS_FILE="${HOME}/.config/jatis/.env"
if [ -f "$SECRETS_FILE" ]; then
  set -a
  source "$SECRETS_FILE"
  set +a
else
  echo "ERROR: Secrets file not found at $SECRETS_FILE"
  exit 1
fi

# Validate required vars
if [ -z "$OUTLINE_API_URL" ] || [ -z "$OUTLINE_API_TOKEN" ]; then
  echo "ERROR: OUTLINE_API_URL and OUTLINE_API_TOKEN must be set in .env"
  exit 1
fi

# Strip trailing slash
OUTLINE_API_URL="${OUTLINE_API_URL%/}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ============================================
# Helper: API call
# ============================================
outline_api() {
  local endpoint="$1"
  local payload="$2"
  curl -s -X POST "${OUTLINE_API_URL}/${endpoint}" \
    -H "Authorization: Bearer ${OUTLINE_API_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "${payload}"
}

# ============================================
# Helper: Extract urlId from URL
# Input:  https://outline-rbi.jatismobile.com/doc/post-login-GDTFBgZmll
#         or GDTFBgZmll directly
# Output: GDTFBgZmll
# ============================================
extract_id() {
  local input="$1"
  # If URL with /doc/ — take last part after - (urlId)
  if echo "$input" | grep -q "/doc/"; then
    local slug
    slug=$(echo "$input" | sed 's|.*/doc/||' | sed 's|[?#].*||')
    # urlId is last part after final -
    echo "${slug##*-}"
  else
    # Already an ID or urlId
    echo "$input"
  fi
}

# ============================================
# Command: list-collections
# ============================================
cmd_list_collections() {
  echo -e "${CYAN}=== Outline Collections ===${NC}"
  echo ""

  local response
  response=$(outline_api "collections.list" '{"limit":100}')

  local ok
  ok=$(echo "$response" | python3 -c "import sys,json; print(json.load(sys.stdin).get('ok','false'))" 2>/dev/null)

  if [ "$ok" != "True" ]; then
    echo -e "${RED}ERROR: $(echo "$response" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('error','unknown'))" 2>/dev/null)${NC}"
    exit 1
  fi

  echo "$response" | python3 -c "
import sys, json
d = json.load(sys.stdin)
collections = d.get('data', [])
print(f'Total: {len(collections)} collections\n')
print(f'{'ID (urlId)':<14} {'Collection Name':<40} {'Documents':<10}')
print('-' * 68)
for c in sorted(collections, key=lambda x: x.get('name','')):
  name = c.get('name','')[:38]
  url_id = c.get('urlId','')
  cid = c.get('id','')
  print(f'{url_id:<14} {name:<40} {cid}')
" 2>/dev/null
}

# ============================================
# Command: search
# ============================================
cmd_search() {
  local query="$1"
  local limit="${2:-20}"

  echo -e "${CYAN}=== Search: \"${query}\" ===${NC}"
  echo ""

  local payload
  payload=$(printf '{"query":"%s","limit":%s}' "$query" "$limit")
  local response
  response=$(outline_api "documents.search" "$payload")

  local ok
  ok=$(echo "$response" | python3 -c "import sys,json; print(json.load(sys.stdin).get('ok','false'))" 2>/dev/null)

  if [ "$ok" != "True" ]; then
    echo -e "${RED}ERROR: $(echo "$response" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('message','unknown'))" 2>/dev/null)${NC}"
    exit 1
  fi

  echo "$response" | python3 -c "
import sys, json
d = json.load(sys.stdin)
results = d.get('data', [])
print(f'Found: {len(results)} documents\n')
for i, r in enumerate(results, 1):
  doc = r['document']
  title = doc.get('title', '(no title)')
  url_id = doc.get('urlId', '')
  doc_id = doc.get('id', '')
  context = r.get('context', '').strip().replace('\n', ' ')[:120]
  collection_id = doc.get('collectionId', '')
  print(f'{i:2}. {title}')
  print(f'    urlId: {url_id}')
  print(f'    URL  : https://outline-rbi.jatismobile.com/doc/{url_id}')
  if context:
    print(f'    ...{context}...')
  print()
" 2>/dev/null
}

# ============================================
# Command: doc (read document content)
# ============================================
cmd_doc() {
  local input="$1"
  local doc_id
  doc_id=$(extract_id "$input")

  echo -e "${CYAN}=== Document: ${doc_id} ===${NC}"
  echo ""

  local response
  response=$(outline_api "documents.info" "{\"id\":\"${doc_id}\"}")

  local ok
  ok=$(echo "$response" | python3 -c "import sys,json; print(json.load(sys.stdin).get('ok','false'))" 2>/dev/null)

  if [ "$ok" != "True" ]; then
    echo -e "${RED}ERROR: $(echo "$response" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('message','unknown'))" 2>/dev/null)${NC}"
    exit 1
  fi

  # Extract doc UUID for child lookup
  local doc_uuid
  doc_uuid=$(echo "$response" | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['id'])" 2>/dev/null)

  echo "$response" | python3 -c "
import sys, json
d = json.load(sys.stdin)
doc = d['data']
title     = doc.get('title', '(no title)')
url_id    = doc.get('urlId', '')
doc_id    = doc.get('id', '')
created   = doc.get('createdAt','')[:10]
updated   = doc.get('updatedAt','')[:10]
text      = doc.get('text', '')

print(f'Title    : {title}')
print(f'URL      : https://outline-rbi.jatismobile.com/doc/{url_id}')
print(f'ID       : {doc_id}')
print(f'Created  : {created}')
print(f'Updated  : {updated}')
print()
print('=' * 60)
print(text)
" 2>/dev/null

  # Fetch & display child docs if any
  local children_response children_ok
  children_response=$(outline_api "documents.list" "{\"parentDocumentId\":\"${doc_uuid}\",\"limit\":100}")
  children_ok=$(echo "$children_response" | python3 -c "import sys,json; print(json.load(sys.stdin).get('ok','false'))" 2>/dev/null)

  if [ "$children_ok" = "True" ]; then
    echo "$children_response" | python3 -c "
import sys, json
d = json.load(sys.stdin)
docs = d.get('data', [])
if not docs:
  exit()
print()
print('=' * 60)
print(f'  📂 Child Documents ({len(docs)})')
print('  ' + '-' * 58)
for i, doc in enumerate(docs, 1):
  title  = doc.get('title', '(no title)')
  url_id = doc.get('urlId', '')
  updated = doc.get('updatedAt', '')[:10]
  print(f'  {i}. {title}')
  print(f'     urlId  : {url_id}')
  print(f'     URL    : https://outline-rbi.jatismobile.com/doc/{url_id}')
  print(f'     Updated: {updated}')
  print()
" 2>/dev/null
  fi
}

# ============================================
# Command: children (list child/nested docs from a document)
# ============================================
cmd_children() {
  local input="$1"
  local limit="${2:-100}"
  local url_id
  url_id=$(extract_id "$input")

  echo -e "${CYAN}=== Child Documents of: ${url_id} ===${NC}"
  echo ""

  # Resolve urlId → UUID first via documents.info
  local info_response
  info_response=$(outline_api "documents.info" "{\"id\":\"${url_id}\"}")
  local ok
  ok=$(echo "$info_response" | python3 -c "import sys,json; print(json.load(sys.stdin).get('ok','false'))" 2>/dev/null)

  if [ "$ok" != "True" ]; then
    echo -e "${RED}ERROR: Document '${url_id}' not found${NC}"
    exit 1
  fi

  local doc_uuid doc_title
  doc_uuid=$(echo "$info_response" | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['id'])" 2>/dev/null)
  doc_title=$(echo "$info_response" | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['title'])" 2>/dev/null)

  echo -e "Parent: ${BOLD}${doc_title}${NC}"
  echo ""

  # List child docs
  local payload response
  payload=$(printf '{"parentDocumentId":"%s","limit":%s}' "$doc_uuid" "$limit")
  response=$(outline_api "documents.list" "$payload")
  ok=$(echo "$response" | python3 -c "import sys,json; print(json.load(sys.stdin).get('ok','false'))" 2>/dev/null)

  if [ "$ok" != "True" ]; then
    echo -e "${RED}ERROR: $(echo "$response" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('message','unknown'))" 2>/dev/null)${NC}"
    exit 1
  fi

  echo "$response" | python3 -c "
import sys, json
d = json.load(sys.stdin)
docs = d.get('data', [])
print(f'Total: {len(docs)} child doc(s)\n')
if not docs:
  print('  (no child docs)')
  exit()
print(f\"  {'#':<4} {'Title':<50} {'urlId':<14} {'Updated':<12}\")
print('  ' + '-' * 82)
for i, doc in enumerate(docs, 1):
  title   = doc.get('title', '(no title)')[:48]
  url_id  = doc.get('urlId', '')
  updated = doc.get('updatedAt', '')[:10]
  print(f'  {i:<4} {title:<50} {url_id:<14} {updated}')
  print(f'       URL: https://outline-rbi.jatismobile.com/doc/{url_id}')
  print()
" 2>/dev/null
}

# ============================================
# Command: collection-docs (list documents in collection)
# ============================================
cmd_collection_docs() {
  local input="$1"
  local limit="${2:-100}"
  local doc_id
  doc_id=$(extract_id "$input")

  echo -e "${CYAN}=== Documents in Collection: ${doc_id} ===${NC}"
  echo ""

  local payload
  payload=$(printf '{"id":"%s","limit":%s}' "$doc_id" "$limit")
  local response
  response=$(outline_api "documents.list" "$payload")

  local ok
  ok=$(echo "$response" | python3 -c "import sys,json; print(json.load(sys.stdin).get('ok','false'))" 2>/dev/null)

  if [ "$ok" != "True" ]; then
    # Try with collectionId
    payload=$(printf '{"collectionId":"%s","limit":%s}' "$doc_id" "$limit")
    response=$(outline_api "documents.list" "$payload")
    ok=$(echo "$response" | python3 -c "import sys,json; print(json.load(sys.stdin).get('ok','false'))" 2>/dev/null)
  fi

  if [ "$ok" != "True" ]; then
    echo -e "${RED}ERROR: $(echo "$response" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('message','unknown'))" 2>/dev/null)${NC}"
    exit 1
  fi

  echo "$response" | python3 -c "
import sys, json
d = json.load(sys.stdin)
docs = d.get('data', [])
print(f'Total: {len(docs)} documents\n')
print(f'  {'Title':<50} {'urlId':<14} {'Updated':<12}')
print('  ' + '-' * 78)
for doc in docs:
  title   = doc.get('title', '(no title)')[:48]
  url_id  = doc.get('urlId', '')
  updated = doc.get('updatedAt', '')[:10]
  print(f'  {title:<50} {url_id:<14} {updated}')
  print(f'  URL: https://outline-rbi.jatismobile.com/doc/{url_id}')
  print()
" 2>/dev/null
}

# ============================================
# Usage
# ============================================
usage() {
  echo -e "${BOLD}Usage:${NC}"
  echo "  $0 --list-collections"
  echo "  $0 --search <keyword> [limit]"
  echo "  $0 --doc <urlId|URL>                      # Read document content"
  echo "  $0 --children <urlId|URL>                 # List child docs (nested)"
  echo "  $0 --collection-docs <collectionId|urlId> [limit]"
  echo ""
  echo -e "${BOLD}Examples:${NC}"
  echo "  $0 --list-collections"
  echo "  $0 --search 'post login'"
  echo "  $0 --doc GDTFBgZmll"
  echo "  $0 --doc 'https://outline-rbi.jatismobile.com/doc/post-login-GDTFBgZmll'"
  echo "  $0 --children GDTFBgZmll"
  echo "  $0 --collection-docs yY1zI9VRK3"
}

# ============================================
# Main
# ============================================
if [ $# -eq 0 ]; then
  usage
  exit 0
fi

case "$1" in
  --list-collections)
    cmd_list_collections
    ;;
  --search)
    [ -z "$2" ] && { echo "ERROR: keyword required"; exit 1; }
    cmd_search "$2" "${3:-20}"
    ;;
  --doc)
    [ -z "$2" ] && { echo "ERROR: urlId/URL required"; exit 1; }
    cmd_doc "$2"
    ;;
  --children)
    [ -z "$2" ] && { echo "ERROR: urlId/URL required"; exit 1; }
    cmd_children "$2" "${3:-100}"
    ;;
  --collection-docs)
    [ -z "$2" ] && { echo "ERROR: collectionId/urlId required"; exit 1; }
    cmd_collection_docs "$2" "${3:-100}"
    ;;
  --help|-h)
    usage
    ;;
  *)
    echo -e "${RED}ERROR: Unknown command '$1'${NC}"
    echo ""
    usage
    exit 1
    ;;
esac