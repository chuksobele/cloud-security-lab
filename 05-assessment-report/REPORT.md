# Security Assessment — Azure Lab Subscription

**Assessor:** Chukwuemeka David Obele
**Dates:** _fill in_
**Scope:** Azure subscription `seclab` — storage, networking, identity and RBAC,
Kubernetes workloads, CI/CD pipeline
**Standards assessed against:** Microsoft Cloud Security Benchmark, CIS Microsoft
Azure Foundations Benchmark, CIS Kubernetes Benchmark
**Method:** Defender for Cloud regulatory compliance view, Azure Policy compliance,
manual configuration review via Az PowerShell, Checkov against IaC, Trivy against
container images, kube-bench against the cluster

---

## 1. Executive summary

_Three to five sentences, no jargon. What was assessed, what the overall posture is,
the two or three things that actually matter, and what you need from the reader._

Example shape: "This assessment covered the lab subscription and its Kubernetes
workloads. The environment had X open findings, of which Y were high severity. The
most significant issue is Z, because it would allow an unauthenticated attacker on
the internet to read stored data. All high findings were remediated during the
assessment and verified by rescan; the secure score moved from A to B."

## 2. Scope and limitations

- In scope: _list_
- Out of scope: _list_
- Limitations: single-subscription lab, no production data, no penetration testing
  performed, findings based on configuration review rather than exploitation

## 3. Risk summary

| Severity | Open at start | Remediated | Remaining |
|---|---|---|---|
| Critical | | | |
| High | | | |
| Medium | | | |
| Low | | | |

Secure score: _before_ → _after_

## 4. Attack paths

Narrate two or three chains. Each is a story, not a list.

### AP-01 — Internet to stored data
`Public storage container (anonymous blob read)` → `HTTP permitted, TLS 1.0 accepted`
→ `no diagnostic logging on the storage account`
**Consequence:** anyone on the internet can read stored objects, can do so over an
unencrypted channel, and we would have no record that it happened.
**Severity:** High. **Status:** remediated.

### AP-02 — Management port to host to subscription
`NSG allows 0.0.0.0/0 on 22 and 3389` → `VM with a system-assigned managed identity`
→ `identity holds Contributor at resource group scope`
**Consequence:** a successful brute force or credential reuse against an exposed
management port yields not just the host but the managed identity's permissions
across the resource group.
**Severity:** High. **Status:** _fill in._

### AP-03 — Container escape to cross-tenant access
`No NetworkPolicy (all pods can reach all pods)` → `privileged pod admitted`
→ `hostPath mount of host root`
**Consequence:** one compromised workload reaches every other tenant's workload.
**Severity:** Critical in a multi-tenant context. **Status:** remediated via
default-deny NetworkPolicy and Pod Security Admission at `restricted`.

## 5. Detailed findings

### F-01 — Storage account permits anonymous public blob access

| | |
|---|---|
| **Severity** | High |
| **Justification** | Reachable from the internet with no authentication; exposes stored data; no exploit required |
| **Affected resource** | `seclabinsecuresa` / container `public-data` |
| **Evidence** | `evidence/recommendation-storage-public.png`; `curl` from an unauthenticated session returning object content |
| **Standard** | CIS Azure 3.x; MCSB DP-x; Defender for Cloud "Storage account public access should be disallowed" |
| **Business impact** | Any data placed in this container is world-readable. In a regulated environment this is a reportable personal data breach under UK GDPR if it contains personal data. |
| **Remediation** | Set `allowBlobPublicAccess = false` on the account and container access to `private`; enforce with an Azure Policy `deny` assignment so it cannot recur |
| **Owner / date** | _fill in_ |
| **Verified** | Rescanned, recommendation closed on _date_ |

### F-02 — Management ports open to the internet
_Same structure._

### F-03 — Over-permissive RBAC assignment at subscription scope
_Same structure._

### F-04 — No network segmentation between Kubernetes namespaces
_Same structure._

### F-05 — Container image runs as root on an end-of-life base image
_Same structure._

## 6. What is working

Genuinely include this — it builds credibility and it is honest.
_Examples: MFA enforced for administrators; PIM in use for privileged roles; Activity
Log centralised with 90-day retention; IaC scanning blocking insecure Terraform at
pull request._

## 7. Recommendations (thematic)

1. **Move controls from detective to preventive.** Where Defender for Cloud raised a
   recommendation, ask whether an Azure Policy `deny` could have prevented it. Public
   storage and disallowed regions are both good candidates.
2. **Standardise base images.** One hardened, current, non-root base image removes
   hundreds of findings at once instead of generating hundreds of tickets.
3. **Make tenant isolation explicit.** Default-deny NetworkPolicy per namespace, plus
   a decision recorded about whether namespace isolation is sufficient for the threat
   model or whether a stronger boundary is required.
4. **Track mean time to remediate, not open counts.** Open counts rise when coverage
   improves, which makes them a misleading measure of success.

## 8. Appendices

- A: Checkov output (insecure vs secure)
- B: Trivy output (insecure vs secure image)
- C: kube-bench results
- D: Az PowerShell baseline check output
- E: Commands run
