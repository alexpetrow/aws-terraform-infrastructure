# Troubleshooting

Real issues found while building this project.

## `terraform init`: no space left on device

**Symptom:** Provider installation fails with `no space left on device`.

**Root cause:** Every Terraform working directory downloads its own copy of each provider
(~700 MB for AWS). With `bootstrap/` and `environments/dev/` the copies add up quickly
on a small VM. The VM also used only half of its disk (see the LVM issue in
[infrastructure-automation-lab](https://github.com/alexpetrow/infrastructure-automation-lab/blob/main/docs/troubleshooting.md)).

**Fix:** A shared provider cache in `~/.terraformrc`:

    plugin_cache_dir = "$HOME/.terraform.d/plugin-cache"

## Ansible `aws_ec2` inventory: missing `botocore[crt]`

**Symptom:** `ansible-inventory --graph` fails with
`Using the login credential provider requires an additional dependency`.

**Root cause:** Credentials come from `aws login` (short-term, no access keys).
boto3 supports this provider, but it needs the AWS Common Runtime (CRT) library.

**Fix:** `pipx inject --force ansible "botocore[crt]"`. The `--force` is needed when
`botocore` is already injected, otherwise pipx skips the extra dependencies.

## Ansible connections refused right after UFW is enabled

**Symptom:** The playbook fails with `Connection refused` on port 22 in the task after
`Enable UFW`, although SSH is allowed.

**Root cause:** `ssh_args` in `ansible.cfg` **replaces** Ansible's default SSH options,
which include connection multiplexing (`ControlMaster`, `ControlPersist`). Without it every
task opens a new SSH connection. The UFW `limit` rule rejects more than 6 connections
in 30 seconds from the same IP, so Ansible was blocked by its own brute-force protection.

**Fix:** Keep the defaults and add custom options after them:

    ssh_args = -C -o ControlMaster=auto -o ControlPersist=60s -o StrictHostKeyChecking=accept-new

## Handlers not executed after a host became unreachable

**Symptom:** After the failure above, `ubuntu` could still log in over SSH although
`AllowUsers` no longer included it.

**Root cause:** The SSH config file was written and the `Restart SSH` handler was notified,
but Ansible does not run pending handlers for a host that fails. On the next run the
task was `ok` (file already correct), so the handler was never notified again.

**Fix:** `force_handlers = True` in `ansible.cfg`. One-time recovery:

    ansible role_web -m ansible.builtin.systemd -a "name=ssh state=restarted" --become

## `group_vars` silently ignored

**Symptom:** UFW had no rule for port 80 and allowed SSH from anywhere,
although `group_vars/role_web.yml` defined both.

**Root cause:** Ansible loads `group_vars/` only next to the inventory source or next to
the playbook. The file was in `ansible/group_vars/`, next to neither, so the roles used
their defaults. Ansible does not warn about this.

**Fix:** Moved to `ansible/inventory/group_vars/`. Verify variables before running a playbook:

    ansible-inventory --host dev-web

## Old firewall rules remain after changing variables

**Root cause:** The `firewall` role adds the rules it describes but does not remove rules
that are no longer described. After the `group_vars` fix, the old `22/tcp LIMIT Anywhere`
rule stayed next to the new admin-IP rule.

**Fix:** Removed once with the `community.general.ufw` module (`delete=true`), after the
new rule existed. Purging unmanaged rules automatically is a possible future improvement,
with the risk of cutting off SSH access during the run.

## Checkov fails with "NumPy was built with baseline optimizations (X86_V2)"

**Root cause:** The control node VM used a generic emulated CPU model without
x86-64-v2 instructions. Fixed by switching the VM CPU mode to Host Passthrough.
Details in the
[infrastructure-automation-lab troubleshooting guide](https://github.com/alexpetrow/infrastructure-automation-lab/blob/main/docs/troubleshooting.md).

## GitHub Actions OIDC: Not authorized to perform sts:AssumeRoleWithWebIdentity

**Symptom:** `configure-aws-credentials` fails after several retries, although the role ARN
and the trust policy look correct.

**Diagnosis:** A temporary workflow step decoded the OIDC token payload (claims only, never
the token itself). The `sub` claim included immutable numeric IDs:
`repo:OWNER@OWNER_ID/REPO@REPO_ID:pull_request`, while the trust policy expected the
name-only format `repo:OWNER/REPO:pull_request`. `StringEquals` requires an exact match.

**Fix:** The trust policy builds the subject from owner and repository IDs
(see `global/ci-access`). IDs come from `https://api.github.com/repos/OWNER/REPO`.

**Why it matters:** Names can be reused after a repository is deleted or renamed;
numeric IDs cannot. Matching on IDs prevents a new repository with the same name
from assuming the role.

**Alternative diagnosis:** CloudTrail event history, event name `AssumeRoleWithWebIdentity`,
shows the denied request.
