# Issues Faced & Solutions

## 1. `scott-the-programmer/minikube` provider deadlocked

**Problem:** `terraform apply` hung indefinitely at "Still creating..." with no output.
The provider process was in `futex_do_wait` state — stuck on a stale
`~/.minikube/machine_client.lock` left behind by a previously cancelled apply.
Every subsequent apply inherited the poisoned lock and blocked forever.

**Solution:** Dropped the third-party minikube provider entirely. Used
`null_resource` + `provisioner "local-exec"` to drive the system `minikube`
CLI directly. The CLI handles locking correctly and does not leave stale state.

---

## 2. Provider forced a ~389 MB VM ISO download for the Docker driver

**Problem:** Provider v0.6.0 embeds minikube v1.37.0, which unconditionally
downloads a VM boot ISO even when `driver = "docker"` is set. The Docker driver
does not use ISOs at all. The download stalled on a slow connection and caused
every apply to time out before the cluster was created.

**Solution:** Same as above — replacing the provider with a `local-exec`
`minikube start` call uses the system CLI (v1.38.1), which correctly skips the
ISO for the Docker driver. All required images (`kicbase`, preloaded tarball)
were already cached from an earlier manual `minikube start`.

---

## 3. `kubernetes` provider configured from a resource in the same apply

**Problem:** The original single-file design configured the `kubernetes`
provider from the output of a `minikube_cluster` resource in the same
`terraform apply`. On the first run the cluster does not exist yet, so the
provider receives unknown/empty connection values, making the plan unreliable.

**Solution:** Used the `external` data source with a helper script
(`scripts/kubeconfig.sh`) that runs **after** the cluster is up (via
`depends_on`). The script reads file paths for the certificates straight from
kubeconfig and passes them to the `kubernetes` provider via
`file(...)` — no base64 decoding needed, and the provider connects to a
cluster that is guaranteed to already be running.

---

## 4. Second node failed to join the cluster (race condition)

**Problem:** `minikube start --nodes=2` succeeded for the control-plane node
but failed while labelling the worker node (`terraform-k8s-m02 not found`).
The node container started but had not finished registering with the API server
before minikube tried to apply labels.

**Solution:** Added an explicit `kubectl wait --for=condition=Ready nodes --all
--timeout=120s` inside the `local-exec` provisioner, immediately after
`minikube start`. This blocks until both nodes are fully Ready before
Terraform moves on to creating the Nginx pod, eliminating the race.

---

## 5. `kube-proxy` CrashLoopBackOff — `too many open files`

**Problem:** Nodes stayed `NotReady` because `kube-proxy` crashed on startup
with `too many open files`. The default Linux inotify limits
(`max_user_instances=128`) were exhausted by running two overlapping minikube
profiles simultaneously (a leftover `minikube` profile from manual testing plus
the `terraform-k8s` profile).

**Solution:** Raised inotify limits (`max_user_instances=512`,
`max_user_watches=524288`) and deleted the stray leftover profile. The final
working project uses a single profile (`tf-minikube`) and sets
`kubernetes_version = ""` to let minikube pick its default, avoiding any
version/image mismatch.
