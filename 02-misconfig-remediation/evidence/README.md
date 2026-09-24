# Evidence

Screenshots and exported findings from my own runs.

Expected files:

- `secure-score-before.png` — Defender for Cloud secure score with the insecure
  resources deployed
- `secure-score-after.png` — the same view after remediation
- `recommendation-storage-public.png` — the specific recommendation raised
- `recommendation-management-ports.png`
- `checkov-insecure-output.txt` — Checkov run against `terraform/insecure`
- `checkov-secure-output.txt` — Checkov run against `terraform/secure`

## Redaction checklist before committing

- [ ] Subscription ID and tenant ID blurred
- [ ] Your own public IP not visible
- [ ] Account names that identify your employer removed
- [ ] No access keys, connection strings or tokens anywhere in the image
