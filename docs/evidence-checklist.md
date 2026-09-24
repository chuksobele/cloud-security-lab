# Evidence checklist

Before committing any screenshot or output file:

- [ ] Subscription ID, tenant ID and object IDs blurred or redacted
- [ ] Your home public IP address not visible
- [ ] No employer name, internal hostname or internal IP range present
- [ ] No access keys, SAS tokens, connection strings or bearer tokens
- [ ] No real personal data of any kind
- [ ] Terminal output scrubbed of anything in the two lists above

## Why this matters in an interview

Being able to say "I redact subscription IDs and check for secrets before I publish
anything, and I scan the repo history with Gitleaks" is itself a security answer. It
shows you think about operational security, not just controls.
