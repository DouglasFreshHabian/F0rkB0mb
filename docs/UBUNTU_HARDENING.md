# Ubuntu Hardening Guide
on **Ubuntu**, you're in a good position to harden your system against fork bombs 
using both `ulimit` and PAM-based user limits. Here's a step-by-step setup tailored for Ubuntu:

## 🛡️  1. Set Permanent User Process Limits (`ulimit -u`)

### 🔧 Edit `/etc/security/limits.conf`

Run:
```bash
sudo nano /etc/security/limits.conf
```
At the bottom, add lines like this (replace `yourusername` with your actual username):

```bash
yourusername  hard  nproc  100
yourusername  soft  nproc   80
```

* `soft` limit is the default.

* `hard` limit is the maximum allowed if a process tries to raise its own limit.

## 🛡️  2. Ensure PAM Enforces Limits

### 🔧 Check or edit `/etc/pam.d/common-session`

Make sure this line is present:
```bash
session required pam_limits.so
```
If it's missing, add it.
> This ensures the limits are enforced for `non-root users` during login sessions (including SSH, terminals, etc.).
---

## 🛡️  3. Optional: Apply Limits for All Users via `/etc/security/limits.d/`
Create a dedicated config file:
```bash
sudo nano /etc/security/limits.d/forkbomb.conf
```
Add:
```bash
*  hard  nproc  100
*  soft  nproc   80
```
> `*` applies to all users **except root**. You can also use groups if you prefer more control.
---

## 🛡️  4. Apply File and Memory Limits (Optional)
In the same file or in `limits.conf`, add:
```bash
*  hard  fsize  10000    # Max file size: 10MB
*  hard  core   0        # Disable core dumps
```

## 🛡️  5. Confirm Limits
After rebooting or logging out and in again, run:
```bash
ulimit -u  # should return 80 (or your soft limit)
```
To test limits for a user without logging out:
```bash
su - yourusername -c "ulimit -u"
```
---

## 🧪 Bonus: Temporary Run Limits with `systemd-run`
If you're testing potentially dangerous scripts:
```bash
systemd-run --scope -p TasksMax=50 ./test-script.sh
```
Limits the total number of processes the script can spawn.
---

