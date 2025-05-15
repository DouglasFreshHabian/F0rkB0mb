# Protect Yourself From Fork Bombs
To **protect yourself from fork bombs** and other resource-exhausting attacks in Bash, 
you'll want to **limit the system resources** that a user or script can consume. Here 
are the key protections you should set up — especially `ulimit` settings — and other 
important system-level defenses:
---

## 🛡️  1. Set Process Limits with `ulimit`

### ✅ Limit the number of processes a user can spawn:

```bash
ulimit -u 100
```
* This limits the **number of processes** to 100 for the current shell session.

* Prevents runaway process creation from overwhelming the system.

### 🔧 To make it persistent for a specific user:
Edit `/etc/security/limits.conf` and add:

```bash
yourusername hard nproc 100
```
Also ensure PAM is configured to enforce this in `/etc/pam.d/common-session` (on Debian/Ubuntu) or `/etc/pam.d/login`:

```bash
session required pam_limits.so
```
---

## 🛡️  2. Limit Core Dump Sizes (optional, but good practice)
```bash
ulimit -c 0
```
* Prevents processes from writing large core dumps that can fill up disk space.

## 🛡️  3. Use `ulimit -f` to limit file sizes (prevents scripts from writing huge files)
```bash
ulimit -f 10000  # 10MB max file size
```

## 🛡️  4. Use Control Groups (cgroups) for More Robust Limits (Advanced)
If you're on a system with **systemd**, you can apply limits using slices:

```bash
# Create a custom slice with limits
sudo systemctl set-property user-1000.slice TasksMax=150
```
Or run a script in a temporary slice:
```bash
systemd-run --scope -p TasksMax=100 ./suspicious_script.sh
```
This limits the number of tasks (processes/threads) that can be created.
---

## 🛡️  5. Use `nice` and `ionice` for CPU and I/O priority limiting
Fork bombs often eat up CPU and I/O. Run unknown scripts with lower priority:

```bash
nice -n 19 ./script.sh          # Lower CPU priority
ionice -c 3 ./script.sh         # Idle I/O priority
```

## 🛡️  6. Monitor System Resources
Use tools like:

* `htop` – for live process monitoring

* `ps -u username` – to see all processes by a user

* `watch -n 1 "ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head"` – live process resource use

## 🧪 TL;DR — Safe Defaults You Can Apply Now:
Add these to your ~/.bashrc or shell init file (for personal sessions):
```bash
ulimit -u 100      # Max 100 processes
ulimit -c 0        # No core dumps
ulimit -f 10000    # Max file size: 10MB
```
And for system-wide safety, configure `/etc/security/limits.conf` and PAM correctly.

