---
name: log-rules
description: Comprehensive logging guidelines for implementing or reviewing logging in a codebase. Use when writing logs, reviewing log statements, debugging logging issues, or setting up logging infrastructure.
---

You are tasked with implementing or reviewing logging in a codebase. Follow these comprehensive logging guidelines:

## Core Philosophy
Log with purpose. Logging isn't about "log everything" or "only log errors" — it's about **logging what provides value** for debugging, monitoring, and auditing. Include trace/correlation IDs for easy parsing elasticsearch, log aggregators and trace/correlation IDs must same in one request flow.

## What to Log

### REQUIRED - Errors & Exceptions
- Log ALL errors with sufficient context for investigation
- Include: user_id, transaction_id, error reason, relevant data
- Example: `ERROR: Payment failed for user_id=12345, order_id=789, reason="insufficient_balance"`

### HIGHLY RECOMMENDED - Request/Response Flow
- Log incoming requests: method, endpoint, source IP, user identifier
- Log responses: status code, duration
- Example: `INFO: Incoming request POST /api/orders from ip=192.168.1.1, user_id=12345`
- Example: `INFO: Response 201 Created in 245ms`

### RECOMMENDED - Business Events
- Log significant business transactions
- Example: `INFO: Order completed, order_id=789, amount=500000, payment_method=credit_card`
- Example: `INFO: User registered, user_id=12345, source=google_oauth`

### RECOMMENDED - Critical State Changes
- Log system state changes that affect behavior
- Example: `WARN: Circuit breaker OPEN for service=payment-gateway, failures=5`
- Example: `INFO: Database connection pool resized from 10 to 20`

### OPTIONAL - Debug Information (disable in production)
- Example: `DEBUG: Cache miss for key=user:12345:profile, fetching from database`

## Log Levels Guide

- **FATAL**: Application cannot run (database connection completely failed)
- **ERROR**: Operation failed, requires investigation (payment gateway timeout, API error)
- **WARN**: Anomaly but system still operational (retry attempt 3 of 5, deprecated API used)
- **INFO**: Normal significant events (user login, order created, service started)
- **DEBUG**: Detailed troubleshooting info (cache hit/miss, query executed)
- **TRACE**: Extremely detailed, rarely used (every step in algorithm)

## What NOT to Log

Avoid excessive internal details:
```
DEBUG: Entering function validateEmail()
DEBUG: Email format valid
DEBUG: Exiting function validateEmail()
```

Never log sensitive data:
- Passwords, tokens, API keys
- Credit card numbers
- PII without masking
- Session tokens

## Decision Framework: "3 Questions"

Before adding a log statement, ask:

1. **"Will this help me debug an issue at 3 AM?"**
   - If yes → log it
   - If no → skip it

2. **"Is there enough context to understand the situation?"**
   - Log without context = useless noise
   - Always include: who, what, when, result

3. **"Could this cause problems (PII, performance, cost)?"**
   - Don't log sensitive data
   - Too many logs = expensive storage + noise

## Structured Logging (Modern Approach)

Use structured/JSON format for easy parsing elasticsearch, log aggregators

## Quick Reference Table

| Situation | Log? | Level |
|-----------|------|-------|
| API request received | Yes | INFO |
| Validation successful | No | - |
| Validation failed | Yes | WARN/ERROR |
| Database query | No (unless slow) | DEBUG |
| External API call | Yes | INFO |
| Business transaction completed | Yes | INFO |
| Error/Exception | Yes REQUIRED | ERROR |
| Retry attempt | Yes | WARN |
| Configuration changes | Yes | INFO |

## Golden Rules

1. **Log for others** — imagine another engineer reading your logs at 3 AM during an incident
2. **Context is king** — logs without context are useless
3. **Never log sensitive data** — mask PII, tokens, credentials
4. **Use correlation/trace IDs** — for tracking requests across services
5. **Log levels must be consistent** — team agreement is essential
6. **Include error details** — use exc_info=True or equivalent to capture stack traces

When implementing logging in code:
- Add logging at function entry/exit for critical paths
- Always log errors with full context
- Use appropriate log levels consistently
- Structure logs with key-value pairs for easy searching
- Include trace/correlation IDs for distributed systems
- Sanitize sensitive data before logging
