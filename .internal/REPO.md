# What is in this repository

Checked against `main` and all template branches (`main`, `common-libs`, `descarcare-date-api`,
`baze-de-date/pqxx`, `baze-de-date/sqlite`, `http-server`, `llms`, `ftxui`, `sfml3`,
`sfml3-resurse-locale`, `sfml3-imagini-externe-api`, `raylib-cpp`, `wxwidgets`, `tests/gtest`,
`tests/Boost-ext-ut`) on 2026-10-03. Everything below is **read-only for you** unless the
[INFRA guide](INFRA.md) says otherwise.

## Layout you get on every branch

| Path | What it is |
|---|---|
| `CMakeLists.txt`, `cmake/` | CMake project: options, compiler flags, sanitizers, helpers. Infrastructure. |
| `scripts/` | `cmake.sh`, `run_cppcheck.sh`, `build_cppcheck.sh`, `run_tests.sh`, `run_valgrind.sh` (+ suppressions), `audit_ext_libs.sh`. Same checks CI runs. |
| `.github/` | GitHub Actions: workflows, composite actions, Renovate configs. Infrastructure — and the CI your project requires. |
| `.clang-tidy`, `.gitattributes`, `.gitignore`, `disable_modules.props` | Static analysis + linguist/VCS/MSBuild setup. Infrastructure. |
| `include/` | Public headers of the library — this directory **is** your public interface. Starter example: `Example.h`. |
| `src/` | Library implementation, compiled once. Adding a file means adding it to `target_sources` in `CMakeLists.txt` (an addition, allowed). `src/internal/` is implementation-only: not shipped, not visible to `app/` or `tests/`. |
| `app/` | The executable: `main.cpp`, menus, wiring, I/O. Not reachable from `tests/` — by design. |
| `tests/` | Test suites. `assert` / `static_assert` on `main`; framework examples on `tests/gtest` and `tests/Boost-ext-ut`. |
| `assets/` | Your data/images/fonts (empty `.keep` on most branches). Document precisely where you got these from. |
| `ext/` | Vendored third-party *lightweight* code (e.g. header-only libs), marked `linguist-vendored` in `.gitattributes`. `ext/include` is on your public interface (`SYSTEM PUBLIC`), `ext/private` stays inside `src/`; keep it private unless a header in `include/` names its type. On most branches it only contains `.keep`. |
| `tastatura.txt` | Keyboard input only (`std::cin`); file data goes in your own files under `assets/`. |
| `README.md` | Project description + the homework checkboxes. Yours to edit. |
| `LICENSE`, `LICENSE.template` | AGPLv3 for your code / Unlicense for the template. You can edit the one for your code. |
| `launcher.command` | Double-click launcher template for the built `./oop_main` binary. Do not edit. Infrastructure. |

## Extras that exist only on some branches

| Branch | Extra |
|---|---|
| `baze-de-date/pqxx` | `.env` (database name/user/password/host — edit the values, keep the file), `src/database/Database.{h,cpp}` |
| `http-server` | `main-client.cpp` (client for the server example), `ext/include/httplib.h`, `ext/lib/httplib.cc` |
| `common-libs` | header-only libs under `ext/include/` (`date`, `csv-parser`, `digestpp`, `random`, `rlutil`), `assets/date.csv` |
| `descarcare-date-api`, `llms` | `ext/include/json/` (nlohmann/json) |
| `sfml3-resurse-locale` | `assets/fonts/`, `assets/images/`, `include/ResourceManager.hpp`, `src/ResourceManager.cpp` |
| `tests/gtest` | googletest in `tests/`, `include/BankAccount.h`, `src/exemplu_test_oop/` |
| `tests/Boost-ext-ut` | `ext/include/boost/ut.hpp`, `include/BankAccount.h`, `src/exemplu_test_oop/` |

## Generated — never commit

`build/`, `install_dir/`, `cppcheck-scan-dir/`, and everything CMake drops next to them
(`compile_commands.json`, caches). They are already in `.gitignore`; if you add your own generated
output (models, exports, downloads), add it to `.gitignore` too — but **never** your sources.

## Not in your repo

Maintainer-only material (the private maintainer guide, the grading/automation setup). What *is* in
your repo and must stay untouched: `.github/`, `cmake/`, `scripts/`, the config files above. See
[INFRA.md](INFRA.md).

## Misc

Inspired by [PFL](https://joholl.github.io/pitchfork-website/)
