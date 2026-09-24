# Tuning rationale

Every suppression and exclusion in this repository, with a reason. This file exists
because "suppress with a documented reason, an owner and an expiry" is the correct
practice, and a repo is a good place to demonstrate it.

| What | Where | Reason | Review |
|---|---|---|---|
| Checkov skips `02-misconfig-remediation/terraform/insecure` | `.checkov.yaml` | That directory is deliberately non-compliant; it is the control group for the experiment. Scanning it would fail every build for no signal. | Permanent, documented |
| Trivy does not fail the build on the insecure image | `.github/workflows/iac-security.yml` | Same reason — the image exists to prove the gate works on the secure one. | Permanent, documented |
| `soft-fail-on: LOW, MEDIUM` | `.checkov.yaml` | Blocking on every severity makes the pipeline unusable and teaches developers to bypass it. Low and medium findings are reported and reviewed, not gated. | Review if low/medium backlog grows |
| `--ignore-unfixed` on Trivy | workflow | A vulnerability with no available fix cannot be actioned by a rebuild. Tracked separately rather than blocking releases indefinitely. | Review monthly |

## The principle

Suppression is not the same as making something disappear. Every exclusion has a
stated reason, is visible in version control, and can be challenged. Silent
suppression is how real breaches get missed.
