<p align="center">
  <img src="https://github.com/DouglasFreshHabian/F0rkB0mb/blob/main/Graphics/Tux.png?raw=true" alt="My Image" width="400">
</p>

<h1 align="center">
💣 detectForkBombs.sh
	</h1>

A Bash script that scans user-specified scripts (or all `.sh` files in a directory) for **common fork bomb patterns**, including:

* Recursive functions that call themselves
* Use of `|` and `&` in self-calling functions
* Suspicious use of `while true`
* Known fork bomb payloads like `:(){ :|:& };:`
* Repeated calls to `$0`, which can suggest self-execution

> ⚠️ **Note**: This script is not foolproof — it catches known and common patterns, but sophisticated fork bombs could still slip through. It's meant as a __first line of defense__, not a formal static analysis tool.

## 📚 Documentation

- [🔍 Understanding Fork Bombs and Detection Patterns](https://github.com/DouglasFreshHabian/F0rkB0mb/blob/main/docs/FORKBOMBS.md)
- [🛡️ System-Wide Fork Bomb Protections](https://github.com/DouglasFreshHabian/F0rkB0mb/blob/main/docs/PROTECTIONS.md)
- [🐧 Ubuntu-Specific Hardening Guide](https://github.com/DouglasFreshHabian/F0rkB0mb/blob/main/docs/UBUNTU_HARDENING.md))

## 🧪 Example Usage
```bash
chmod +x detectForkBombs.sh

# Scan a specific script for fork bombs and dangerous patterns
./detectForkBombs.sh myscript.sh

# Scan all .sh files in current directory
./detectForkBombs.sh

# Optional Flags:
./detectForkBombs.sh --forkbombs   # Only check for fork bombs
./detectForkBombs.sh --dangerous   # Only check for other dangerous patterns
./detectForkBombs.sh               # Scan for both
./detectForkBombs.sh --quiet       # Minimal output, no banner
```

---

## 🔍 What It Detects
**Forkbomb patterns**:
- Classic `:(){ :|:& };:` and variants
- Self-invoking aliases or functions
- Infinite loops
- Recursive `$0` calls

**Other dangerous patterns**:
- `rm -rf /` or variants
- Use of `dd` to overwrite devices
- `mkfs` commands
- Calls to `shutdown`, `reboot`, or `init`
- Heavy resource usage or misuse of `yes`, `cat /dev/zero`, etc.

---

## 🛡️ Hardening Against Fork Bombs

### 1. Set Permanent User Process Limits (`ulimit -u`)
**Edit `/etc/security/limits.conf`**:
```bash
sudo nano /etc/security/limits.conf
```
Add lines like:
```bash
yourusername  hard  nproc  100
yourusername  soft  nproc   80
```

### 2. Ensure PAM Enforces Limits
**Edit `/etc/pam.d/common-session`**:
Ensure this line exists:
```bash
session required pam_limits.so
```

### 3. Apply System-Wide Limits via `/etc/security/limits.d/`
```bash
sudo nano /etc/security/limits.d/forkbomb.conf
```
Add:
```bash
*  hard  nproc  100
*  soft  nproc   80
*  hard  fsize  10000
*  hard  core   0
```

### 4. Confirm Limits
```bash
ulimit -u
su - yourusername -c "ulimit -u"
```

### 5. Temporary Script Isolation with systemd
```bash
systemd-run --scope -p TasksMax=50 ./test-script.sh
```

---

## 🛠️ `forkbombProtection.sh`

### ✅ What it does:
- Writes user-level `nproc` and `fsize` limits to `/etc/security/limits.d/forkbomb.conf`
- Ensures PAM loads `pam_limits.so` if not already configured
- Prints a before/after `ulimit` report for verification
- Notifies user to logout/login to apply changes

### 💡 Usage:
```bash
chmod +x forkbombProtection.sh
sudo ./forkbombProtection.sh
```

---

## 🔐 Summary
| Step | File / Command | Purpose |
|------|----------------|---------|
| 1    | `/etc/security/limits.conf` or `.d/` | Set per-user limits |
| 2    | `/etc/pam.d/common-session` | Enforce via PAM |
| 3    | `ulimit -u` | Confirm limits |
| 4    | `systemd-run` | Temporary sandboxing |

---

## 🚀 Future Add-ons
| Feature | Purpose |
|---------|---------|
| `--summary` | Count matches per file or type |
| `--output report.txt` | Save detections to a file |
| Whitelist support | Exclude known-safe patterns |
| JSON export | Use in CI pipelines |
| Interactive mode | Prompt user before continuing |

---

You're now equipped with:
- A modular scanning tool for dangerous Bash logic
- A companion hardening script for Linux systems
- Practical, portable defenses against fork bombs and resource abuse

Stay secure — and keep hacking smart. 🧠


## 💬 Feedback & Contributions

Got ideas, bug reports, or improvements?
Feel free to open an issue or submit a pull request!

## 💖 Support This Project

If F0rkB0mb™ has helped you or your system, consider supporting the project!  
Your contributions help fuel future updates, testing, and new features.

Every bit of support is appreciated — thank you!


  <h2 align="center"> 
  <a href="https://www.buymeacoffee.com/dfreshZ" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>




<!-- Reach out to me if you are interested in collaboration or want to contract with me for any of the following:
	Building Github Pages
	Creating Youtube Videos
	Editing Youtube Videos
	Youtube Thumbnail Creation
	Anything Pertaining to Linux! -->

<!-- 
 _____              _       _____                        _          
|  ___| __ ___  ___| |__   |  ___|__  _ __ ___ _ __  ___(_) ___ ___ 
| |_ | '__/ _ \/ __| '_ \  | |_ / _ \| '__/ _ \ '_ \/ __| |/ __/ __|
|  _|| | |  __/\__ \ | | | |  _| (_) | | |  __/ | | \__ \ | (__\__ \
|_|  |_|  \___||___/_| |_| |_|  \___/|_|  \___|_| |_|___/_|\___|___/
        dfresh@tutanota.com Fresh Forensics, LLC 2025 -->

