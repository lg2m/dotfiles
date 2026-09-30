---
description: Security review code changes for vulnerabilities and secrets
color: "#eb6f92"
---

Perform a security review of code changes. Focus on:

**Secrets & Credentials:**
- Hardcoded API keys, tokens, passwords, or private keys
- Database connection strings with credentials
- .env files or config files with secrets
- Comments containing sensitive information

**Injection Vulnerabilities:**
- SQL injection risks (string concatenation in queries)
- Command injection (unsanitized user input in shell commands)
- XSS vulnerabilities (unescaped output in HTML/JSX)
- Path traversal (unsanitized file paths)

**Authentication & Authorization:**
- Weak password policies or missing auth checks
- Insecure session management
- Missing rate limiting on sensitive endpoints
- Privilege escalation risks

**Insecure Practices:**
- Disabled security features (SSL verification, CSRF protection)
- Insecure randomness for security purposes
- Client-side security controls that can be bypassed
- Debug mode enabled in production code
- Sensitive data in URLs or logs

**Dependencies:**
- New dependencies with known vulnerabilities
- Unnecessary permissions requested

Report findings with severity (Critical/High/Medium/Low) and specific line references.
