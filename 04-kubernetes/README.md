# 04 — Kubernetes: network policy and Pod Security Admission

Two facts that surprise people, demonstrated rather than recited:

1. **By default, every pod in a Kubernetes cluster can reach every other pod** —
   across namespaces. There is no network segmentation until you create it.
2. **By default, a pod can ask to be privileged, run as root, or mount the host
   filesystem** — and the cluster will schedule it. Pod Security Admission stops that.

For a multi-tenant platform, both defaults are unacceptable.

## Setup

```bash
# kind with a CNI that enforces NetworkPolicy (the default kindnet does not)
kind create cluster --name seclab --config kind-config.yaml
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml
kubectl -n kube-system rollout status daemonset/calico-node --timeout=180s
```

## Demonstration 1 — network policy

```bash
kubectl apply -f manifests/00-namespaces.yaml
kubectl apply -f manifests/01-test-workloads.yaml
kubectl wait --for=condition=ready pod --all -n tenant-a --timeout=120s
kubectl wait --for=condition=ready pod --all -n tenant-b --timeout=120s

# BEFORE: tenant-b can reach tenant-a's service. This should not be possible.
kubectl -n tenant-b exec deploy/client -- curl -s -m 3 http://api.tenant-a.svc.cluster.local
# -> returns "ok"   <-- cross-tenant traffic, allowed by default

kubectl apply -f manifests/02-default-deny.yaml

# AFTER: the same request now times out.
kubectl -n tenant-b exec deploy/client -- curl -s -m 3 http://api.tenant-a.svc.cluster.local
# -> exit code 28 (timeout)

# Allow only the one path that is actually needed
kubectl apply -f manifests/03-allow-specific.yaml
```

Capture the before and after terminal output into `evidence/`.

## Demonstration 2 — Pod Security Admission

```bash
# tenant-a is labelled enforce=restricted in 00-namespaces.yaml
kubectl apply -f manifests/04-privileged-pod.yaml
# -> rejected by the admission controller, with the reason printed
```

## Demonstration 3 — CIS benchmark

```bash
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/kube-bench/main/job.yaml
kubectl logs -l app=kube-bench --tail=-1 > evidence/kube-bench.txt
```

## Teardown

```bash
kind delete cluster --name seclab
```

## What I learned

> Fill in. Good prompts: which default surprised you most? What would breaking this
> look like in a payments platform where tenants are different banks? Where would you
> put the boundary if you were designing it — namespace, cluster, or subscription?
