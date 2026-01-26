Provide information about **databases used by the application**, including relational and non-relational databases (e.g., MySQL, PostgreSQL, MongoDB, Redis, Elasticsearch, etc.).  
Focus only on databases that are **connected to, accessed by, or configured in the application**.

Include the following types of inputs only:

- Database connections configured in the application (connection strings, clients, drivers, ORMs)
- Databases used for persistence, caching, search, or messaging state
- Read/write operations explicitly implemented in the code (queries, repositories, models)
- Environment-based database configurations (e.g., env vars, config files)

Deliver the output in the following format:

```
# DB-001: Database Name (Type)

## Description
Explain how the database is used in the application (purpose, role, data stored).

## Configuration Details
Connection method, driver/ORM, host, port, database name (omit secrets).

## Sample Query / Operation (if applicable)
Example of read/write/query operation used in the code.

## Code Reference
\`\`\`{relative-path-file}:{start-line}-{end-line}
\`\`\`

... Repeat for each database used by the application.
```