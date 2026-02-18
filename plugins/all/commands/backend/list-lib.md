# Find Library API Specification

Provide the API specifications or integration descriptions for the library/SDK exposed by this application. The inputs may include:

- Public classes, interfaces, or modules exported for external use
- Public functions/methods that can be called by other applications
- Exported types, enums, or constants meant for external consumption
- Configuration options or builder patterns for library initialization
- Event hooks or callback interfaces for extensibility

Focus only on APIs that are:
1. Publicly accessible (exported/public visibility)
2. Designed to be consumed by external applications or services
3. Part of the library's public contract

Deliver the output in the following format:
```
# {API/Class/Function Name}

## Description
{Brief description of what this API does and its purpose}

## Usage
{How to import/initialize and use this API}

## Parameters/Arguments
{List of parameters with types and descriptions}

## Return Value
{Return type and description, if applicable}

## Example
{Code example showing typical usage}

## Code Location
`{relative-path-file}:{start-line}-{end-line}`
```

Group the APIs by:
1. Core/Main APIs
2. Configuration/Setup APIs
3. Utility/Helper APIs
4. Types/Interfaces/Models