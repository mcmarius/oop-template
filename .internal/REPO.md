# What is in this repository

Layout — shared and per branch — lives in [BRANCHES.md](BRANCHES.md), which is also where you find out
which stack your tree is. This file is only what does not depend on the branch: what is generated, and what
is not in your repo at all.

## Generated — never commit

`build/`, `install_dir/`, `cppcheck-scan-dir/`, and everything CMake drops next to them
(`compile_commands.json`, caches). They are already in `.gitignore`; if you add your own generated
output (models, exports, downloads), add it to `.gitignore` too — but **never** your sources.

## Not in your repo

Maintainer-only material (the private maintainer guide, the grading/automation setup). What *is* in
your repo and must stay untouched: `.github/`, `cmake/`, `scripts/`, the config files listed in
[BRANCHES.md](BRANCHES.md). See [INFRA.md](INFRA.md) for why, and for what you may add.

## Misc

Inspired by [PFL](https://joholl.github.io/pitchfork-website/)
