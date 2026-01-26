# UAT Test Case Template
```
# Title

## Overview

## Configuration Parameters

### {Config Parameter 1}
- Plain Config Name: {plain config if applicable}
- Source: {Source of the configuration, e.g., environment variable, config file, etc if applicable}
- Description: {Description of the configuration parameter}
- Value: {Value if applicable}

### {Config Parameter 2}
- Plain Config Name: {plain config if applicable}
- Source: {Source of the configuration, e.g., environment variable, config file, etc if applicable}
- Description: {Description of the configuration parameter}
- Value: {Value if applicable}

## Test Cases

### Success Test Case

#### TC-001: {Test Case Description}

##### Test Data Requirements (if applicable)
e.g., mock data DML databases, external system mocks

##### Example Payloads (if applicable)
- HTTP API endpoints only recevied by the application
- Message-broker queues/topics (e.g., Kafka, RabbitMQ) only consumed by the application

##### Pre Condition

- List any setup or requirements before executing the test.
  - Example: "User account exists in the system."
  - Example: "Application is running in staging environment."

##### Steps

- Step 1: {First action}
- Step 2: {Next action}
- Step 3: {Continue until complete}
  *(Keep each step atomic and written from the tester’s perspective.)*

##### Expected Result

- Describe the correct system behavior when the steps are executed successfully.
  - Example: "User is redirected to the dashboard page."
  - Example: "Confirmation message 'Order placed successfully' is displayed."

---

### Exception Test Case

#### TC-001: {Test Case Description}

##### Test Data Requirements (if applicable)
e.g., mock data DML databases, external system mocks

##### Example Payloads (if applicable)
e.g., HTTP request/response samples, message broker payloads

##### Pre Condition

- State conditions that must exist before testing.
  - Example: "User account exists but uses an incorrect password."
  - Example: "System has internet connection disabled."

##### Steps

- Step 1: {First action under failure scenario}
- Step 2: {Next action}
- Step 3: {Continue until the error occurs}

##### Expected Result

- Describe the correct system behavior under exception handling.
  - Example: "Error message 'Invalid username or password' is displayed."
  - Example: "System prevents transaction and logs the error."
```
