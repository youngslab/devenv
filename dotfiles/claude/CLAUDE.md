# Global Claude Code Instructions

# CCU2 Development Project Context

## Project Overview

This is the CCU2 (Central Computing Unit 2.0) development environment for Sonatus RTA/NSS modules. Claude assists with C++ development, build system management, Jira ticket workflows, and code reviews.

**Primary Components:** RTA (Routine App), NSS (Network Shared Storage)

---

## Development Workflow

### Phase 1: Issue/Task Management (Jira)

#### Jira Projects
| Project | Purpose |
|---------|---------|
| CCU2 | RTA/NSS issue and task management |
| CS | Customer support activities (visits, meetings) |

#### Ticket Creation Requirements

**Required Fields:**
- **Sprint:** Always use the latest sprint (format: `CCU2_DEV_SNT_YYMMDD`)
- **Assignee:** kevin.park
- **H/W Type:** Common
- **Fix Version:** future
- **Component:** `Shared Storage` or `RTA`

**Description Template:**
```
## Background
[Explain the context and why this work is needed]

## Action Items
[Describe expected deliverables in natural sentences, not bullet points]
```

#### Ticket Closure Requirements
Complete these fields before closing:
- Notify Customer
- Affected Vehicle Types
- Issue Description
- Root Cause
- How to Fix
- Manual Test
- Automated Test
- Vehicle Category
- Customer Ticket Links
- RN Component

---

### Phase 2: Git Branch & Development

**Branch Naming Convention:** Branch name must match Jira ticket number
- Example: `CCU2-17999` or `feature/CCU2-17999`

#### Implementation Guidelines

**Code Formatting (Required before commit):**
```bash
# Apply linter/formatter to project
./run-dev-container.sh -x "./build.py -m {project} --format-apply"

# Example: Apply formatting to RTA project
./run-dev-container.sh -x "./build.py -m rta --format-apply"
```

**Important:** All code changes must pass linter checks before creating a PR. Run `--format-apply` to automatically fix formatting issues.

#### Git Commit

When committing changes, always use the `/x:commit` command instead of direct git commit. This ensures consistent conventional commit format.

---

### Phase 3: Build

#### Host Build (Development & Unit Test)
```bash
# Navigate to parent directory of project
cd ..

# Build project
./run-dev-container.sh -x "./build.py -m {project}"

# Build tests only
./run-dev-container.sh -x "./build.py -m {project} --tests-build-only"

```
#### Target Build (Yocto)

##### Yocto SDK Build
To deploy target, we need cross compile using Yocto SDK. To build

```bash

source ~/workspace/sdk/fsl-auto/0.26.0/environment-setup-cortexa53-crypto-fsl-linux
cd build
cmake .. -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=Debug -GNinja
ninja

```


##### Yocto Build

This is for the Sonatus CCU2 image and Yocto SDK builds only

**Prerequisites:**
- Repository: `CCU_GEN2.0_SONATUS.manifest`
- meta-sonatus layer available
```bash
# Prebuilt binary build (internal only)
./run-dev-container.sh -x "cd lge && build.py --snt"

# Sonatus image build
./run-dev-container.sh -x "cd lge && build.py"

# Yocto SDK build
./run-dev-container.sh -x "cd lge && build.py -c populate_sdk"
```

<!-- TODO: Add SDK installation path and environment setup -->

---

### Phase 4: Target Management & Deploy

#### Target Device Management

**Claim Priority:** `ccu2-kr-17` > `ccu2-kr-xx` > `ccu2-xx`
```bash
# List available targets
list all ccu2
list all ccu2-kr

# Claim target (default: 3 hours)
claim ccu2-27
claim ccu2-27 for 8 hours nss_test  # Extended time requires reason

# Check current target
target   # Output: ccu2-27
tester   # Output: ccu2-tester-27

# Release target
release ccu2-27
```

#### SSH Access
```bash
# Direct CCU2 access (port 13408 -> 22 forwarding configured)
ssh $(target)

# Tester access
ssh $(tester)
```

#### Deploy Binaries to Target

**Prerequisites:**
- Yocto SDK build completed
- `install_binaries.sh` available
- Valid target claimed (`$(target)` returns device name)
- SSH access confirmed
```bash
# From Yocto SDK build directory
cd build
DESTDIR=./out cmake --install . --strip
scp -r ./out $(target):/var/progmgr

ssh $(target) << 'EOF'
kill -9 $(pidof snt_rta)
find /var/progmgr/out -type f -exec sh -c 'dest="${1#/var/progmgr/out}"; /replace_binary.sh "$1" "$dest"' _ {} \;
rm -rf /var/progmgr/out
EOF
```

<!-- TODO: Add rollback procedure if deployment fails -->

---

### Phase 5: Test

#### Unit Test (Host)
```bash
# Build test binary
./run-dev-container.sh -x "./build.py -m {project} --tests-build-only"

# Run all tests
./run-dev-container.sh -x "./build/{project}/{project}_test"

# Run filtered tests
./run-dev-container.sh -x "./build/{project}/{project}_test --gtest_filter=Foo.*"
```

#### Integration Test (Target/Tester)

**Prerequisites:**
- SSH access to tester: `ssh $(tester)`
- Integration test framework at `~/integration-test-framework`

**Framework Setup (if not exists):**
```bash
git clone --reference-if-able /RepoCache/snt-integration-tests/ \
    git@github.com:sonatus/snt-integration-tests.git

# If SSH key error, copy from builder:
scp ~/.ssh/id_rsa* $(tester):~/.ssh/
```

**Run Tests:**
```bash
# SSH to tester
ssh $(tester)
cd ~/integration-test-framework

# Run test suite
sudo /qatools/bin/python ./build.py --suite ./suites/ccu2_nss_suite_basic.yml

# Run individual tests
# TODO: Add individual test execution command
```

<!-- TODO: Add available test suites list -->
<!-- TODO: Add test result interpretation guide -->

---

### Phase 6: Pull Request

#### PR Title Format
```
[CCU2-XXXXX] <Concise description>
```
Example: `[CCU2-17999] Fix memory leak in RTA signal handler`

#### PR Description Requirements
- Maximum 100 lines summary
- Clear explanation for reviewers
- Reference related Jira tickets

<!-- TODO: Add PR template -->
<!-- TODO: Add CI/CD pipeline expectations -->

---

### Phase 7: Ticket Finalization

After PR merge:
1. Update Jira ticket with final status
2. Complete all closure required fields
3. Link PR to ticket
4. Transition ticket to Done

---

## Quick Reference Commands

| Action | Command |
|--------|---------|
| Claim target | `claim ccu2-27 for 8 hours {reason}` |
| SSH to target | `ssh $(target)` |
| SSH to tester | `ssh $(tester)` |
| Host build | `./run-dev-container.sh -x "./build.py -m {project}"` |
| Unit test | `./run-dev-container.sh -x "./build/{project}/{project}_test"` |
| SDK build | `./run-dev-container.sh -x "cd lge && build.py -c populate_sdk"` |

---

## Claude Assistance Guidelines

**When creating Jira tickets:**
- Always use English
- Apply required fields automatically
- Use natural sentences for Action Items (no bullet points)

**When reviewing code:**
- Check for memory leaks (C++ focus)
- Validate against coding standards
- Ensure proper error handling

**When troubleshooting:**
- Verify target is claimed and accessible
- Check build prerequisites
- Validate SSH connectivity

<!-- TODO: Add coding standards reference -->
<!-- TODO: Add common troubleshooting scenarios -->
<!-- TODO: Add team contact information for escalation -->
