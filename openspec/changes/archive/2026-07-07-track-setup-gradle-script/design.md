## Context

The root `Makefile` defines `SETUP_GRADLE := ./scripts/setup-gradle-local.sh` and makes Gradle-backed targets depend on `setup-gradle`. This supports offline or private-network builds by installing locally available `gradle-*-bin.zip` and `gradle-*-all.zip` files into the Gradle wrapper cache.

The script exists in the working tree but was untracked, leaving the Makefile with a repository-local dependency that is missing after clone.

## Goals / Non-Goals

**Goals:**

- Track the existing setup script in Git.
- Preserve executable script semantics and parameterized paths.
- Make the Makefile setup target reproducible from a clean checkout.

**Non-Goals:**

- Change Gradle wrapper distribution URLs.
- Download Gradle distributions from the network.
- Change `make deploy` or artifact publication behavior.

## Decisions

### Decision 1: Track the script as-is

The script already matches the Makefile contract and avoids hard-coded credentials. It uses `LOCAL_GRADLE_DIR`, `GRADLE_USER_HOME`, and `UNPACK`, with defaults suitable for local development.

Alternative considered: inline this logic in the Makefile. Keeping it as a script is clearer because it includes hashing, copy, cleanup, and optional unzip behavior.

### Decision 2: Document the helper under `fork-build-tooling`

This is not a new product capability; it is part of the existing fork build tooling surface. The delta spec extends the Makefile tooling requirement to include the referenced helper script.

## Risks / Trade-offs

- [Python dependency] The script uses `python3` to reproduce Gradle wrapper hashing. Mitigation: this is local setup tooling and Python 3 is already commonly available in maintainer environments.
- [Local path assumptions] The default `LOCAL_GRADLE_DIR` is `${HOME}/dev`. Mitigation: users can override it with `LOCAL_GRADLE_DIR`.
