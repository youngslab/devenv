# CCU2 Project Instructions

## Overview

CCU2 (Central Computing Unit 2.0) development for Sonatus RTA/NSS modules.

**Components:** RTA (Routine App), NSS (Network Shared Storage)
**Repository:** CCU_GEN2.0_SONATUS.manifest

---

## Development Workflow

### 1. Jira Ticket Management

**Project:** CCU2 (RTA/NSS), CS (Customer Support)

**Required Fields:**
| Field | Value |
|-------|-------|
| Sprint | `CCU2_DEV_SNT_YYMMDD` (latest) |
| Assignee | kevin.park |
| H/W Type | Common |
| Fix Version | future |
| Component | `Shared Storage` or `RTA` |

**Description Template:**
```
## Background
[Explain the context and why this work is needed]

## Action Items
[Describe expected deliverables in natural sentences, not bullet points]
```

**Closure Checklist:**
- Notify Customer, Affected Vehicle Types
- Issue Description, Root Cause, How to Fix
- Manual Test, Automated Test
- Vehicle Category, Customer Ticket Links, RN Component

---

### 2. Git Branch & Development

**Branch Naming:** Branch name must match Jira ticket number
- Example: `CCU2-17999` or `feature/CCU2-17999`

**Code Formatting (Required before commit):**
```bash
./run-dev-container.sh -x "./build.py -m {project} --format-apply"
```

---

### 3. Build Commands

#### Host Build (Development & Unit Test)
```bash
./run-dev-container.sh -x "./build.py -m {rta|nss}"
./run-dev-container.sh -x "./build.py -m {project} --tests-build-only"
```

#### Yocto SDK Build (Cross Compile for Target)
```bash
source ~/workspace/sdk/fsl-auto/0.26.0/environment-setup-cortexa53-crypto-fsl-linux
cd build
cmake .. -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=Debug -GNinja
ninja
```

#### Yocto Image Build
```bash
./run-dev-container.sh -x "cd lge && build.py"           # Sonatus image
./run-dev-container.sh -x "cd lge && build.py --snt"     # Prebuilt binary
./run-dev-container.sh -x "cd lge && build.py -c populate_sdk"  # SDK
```

---

### 4. Target Management & Deploy

**Claim Priority:** `ccu2-kr-17` > `ccu2-kr-*` > `ccu2-*`

```bash
# List available targets
list all ccu2
list all ccu2-kr

# Claim/Release
claim ccu2-kr-17 for 8 hours {reason}
release ccu2-kr-17

# Check current target
target    # Output: ccu2-27
tester    # Output: ccu2-tester-27

# SSH Access
ssh $(target)    # CCU2 device
ssh $(tester)    # Tester machine
```

**Deploy Binaries:**
```bash
cd build
DESTDIR=./out cmake --install . --strip
scp -r ./out $(target):/var/progmgr

ssh $(target) << 'EOF'
kill -9 $(pidof snt_rta)
find /var/progmgr/out -type f -exec sh -c 'dest="${1#/var/progmgr/out}"; /replace_binary.sh "$1" "$dest"' _ {} \;
rm -rf /var/progmgr/out
EOF
```

---

### 5. Testing

#### Unit Test (Host)
```bash
./run-dev-container.sh -x "./build/{project}/{project}_test"
./run-dev-container.sh -x "./build/{project}/{project}_test --gtest_filter=Foo.*"
```

#### Integration Test (Target/Tester)
```bash
# SSH to tester
ssh $(tester)
cd ~/integration-test-framework

# Run test suite
./build.py --ignore-health --suite ./suites/ccu2_nss_suite_basic.yml

# Run specific test case for NSS
./build.py --ignore-health --test ./tests/ccu2/nss/C111.py

# Run specific test case for RTA
./build.py --ignore-health --test ./tests/ccu2/routines/SW2_VERTC_3455.py

```

**Framework Setup (if not exists):**
```bash
git clone --reference-if-able /RepoCache/snt-integration-tests/ \
    git@github.com:sonatus/snt-integration-tests.git

# If SSH key error:
scp ~/.ssh/id_rsa* $(tester):~/.ssh/
```

---

### 6. Pull Request

**Title Format:** `[CCU2-XXXXX] Concise description`
**Example:** `[CCU2-17999] Fix memory leak in RTA signal handler`

**Requirements:**
- Maximum 100 lines summary
- Clear explanation for reviewers
- Reference related Jira tickets

절대 AI agent가 코드를 작성했다는 표시를 남기지 마세요.

---

### 7. Ticket Finalization

After PR merge:
1. Update Jira ticket with final status
2. Complete all closure required fields
3. Link PR to ticket
4. Transition ticket to Done

---

## Quick Reference

| Action | Command |
|--------|---------|
| Claim target | `claim ccu2-27 for 8 hours {reason}` |
| SSH to target | `ssh $(target)` |
| SSH to tester | `ssh $(tester)` |
| Host build | `./run-dev-container.sh -x "./build.py -m {project}"` |
| Unit test | `./run-dev-container.sh -x "./build/{project}/{project}_test"` |
| Format apply | `./run-dev-container.sh -x "./build.py -m {project} --format-apply"` |

---

## Troubleshooting Checklist

When issues occur, verify in order:
1. Target claimed: `target` returns valid device name
2. SSH accessible: `ssh $(target)` succeeds
3. Build prerequisites met
4. Formatters applied: `--format-apply` run
