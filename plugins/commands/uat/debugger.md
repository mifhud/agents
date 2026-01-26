@.github/commands/uat-runner.prompt.md

Important:
- only use select queries on mcp for mysql-dev-apps_config, mysql-dev-token
- only use selet and insert queries on mysql-dev-broadcast (FIRST CHECK IF DATA TO BE INSERTED ALREADY EXISTS)
- don't delete/modify any existing(besides test data requirements) data on the database
- create uat test file

Run only these UAT
@spec/debug/uat/personalschedulertrigger.md

- don't remove files test
- don't clean up test data in databases after uat run

## Clean Up
remove file test and remove only successfully inserted/updated data