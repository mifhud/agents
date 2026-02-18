Provide the API integrations and external communications used by the frontend application. Focus on outgoing calls, consumed services, and data fetching patterns:

- HTTP API endpoints **CALLED** by the application (GET, POST, PUT, DELETE, etc.)
- WebSocket connections established by the application
- Server-Sent Events (SSE) subscribed by the application
- Third-party integrations (analytics, payment gateways, maps, etc.)
- GraphQL queries/mutations (if applicable)
- Real-time data subscriptions

Deliver the output in the following format:
```

# {Integration Type}: {Name/Identifier}

## Description

Brief description of what this integration does

## Sample Request
\`\`\`
\`\`\`

## Sample Response
\`\`\`
\`\`\`

## Code Reference
\`\`\`{relative-path-file}:{start-line}-{end-line}
\`\`\`
```