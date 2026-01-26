Use agent @uat/generate
First read and include the logic inside any function calls and their inner code in below. Make sure all function calls, classes, etc. 
are read recursively until there are no more nested calls that need to be included.
$ARGUMENTS

Search inside the inner code to find test data requirements that are needed.

Use **mcp code-mode database in .utcp_config.json** to retrieve the real data required (**THINK CAREFULLY ABOUT THIS — you may only use SELECT queries on mcp code-mode database in .utcp_config.json**).

Create a UAT that's easy for non-programmers to understand according to the template. UAT exclude edge-cases and peformance-cases.

Provide the explanation in Indonesian, but for technical terms, do not translate them.

Save using myspec-debug skill