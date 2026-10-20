# Template branches — layout and per-branch differences

One row per branch in [`branches.txt`](../branches.txt) + `main` (the default branch).
You work on **one** of them: find the row your tree matches, read that row, treat the others as
background. Branch differences are not yours to reconcile.

`Base` records where the branch's infrastructure came from. It is **not** an upstream to rebase, merge or
sync with: you start from a branch and stay on it, cherry-picking from another one when you want a feature
it has. That makes your tree a mix, so **match the tree, not the branch name** — a fork defaults to
`main` or `master`, and a setup of another branch ported onto a `main` fork is legitimate work, not a mistake.

* **Detect / ships** — evidence in the tree, strongest first, and the files the branch adds. `*` marks
  starter code: adapt, rename or delete it freely; what must survive is the separation of `include/`,
  `src/`, `src/internal/`, `app/`, `tests/`, not the example that illustrates it.
* **Extra `scripts/`** — on top of the set in [the layout below](#the-layout-every-branch-has).
* **CI** — the profiles are in [Reading CI](#reading-ci); the cell lists only what differs.

## The layout every branch has

Same on every branch — what yours adds is its row below. [INFRA.md](INFRA.md) says what is read-only for
you, [REPO.md](REPO.md) what is generated and never committed.

| Path | What it is |
|---|---|
| any `CMakeLists.txt`, `cmake/` | CMake project: options, compiler flags, sanitizers, helpers. Infrastructure. |
| `scripts/` | `cmake.sh`, `run_cppcheck.sh`, `build_cppcheck.sh`, `run_tests.sh`, `run_valgrind.sh` + `valgrind-suppressions.supp`, `audit_ext_libs.sh` — the same checks CI runs. |
| `.github/` | GitHub Actions: workflows, composite actions, Renovate configs. Infrastructure — and the CI your project requires. |
| `.clang-tidy`, `.gitattributes`, `.gitignore`, `disable_modules.props` | Static analysis + linguist/VCS/MSBuild setup. Infrastructure. |
| `include/` | Public headers of the library — this directory **is** your public interface. |
| `src/` | Library implementation, compiled once; a new file goes into the target that declares it ([registering](#registering-a-source-a-test-or-a-target)). `src/internal/` is implementation-only: not shipped, not visible to `app/` or `tests/`. |
| `app/` | The executable: `main.cpp`, menus, wiring, I/O. Not reachable from `tests/` — by design. |
| `tests/` | Test suites, one executable registered with CTest; the frameworks themselves come from `ext/` or the build dir. |
| `assets/` | Your data/images/fonts, copied by the configured `install()`/`copy_files()` step. |
| `ext/` | Vendored third-party *lightweight* code, marked `linguist-vendored` in `.gitattributes`. `ext/include/` is on your public interface (`SYSTEM PUBLIC`), `ext/private/` stays inside `src/`; where present, `ext/lib/` holds a vendored dep's compilable code. |
| `tastatura.txt` | Comprehensive keyboard input only (`std::cin`); file data goes in your own files under `assets/`. |
| `README.md` | Project description + the homework checkboxes. Yours to edit. |
| `LICENSE`, `LICENSE.template` | AGPLv3 for your code / Unlicense for the template. You can edit the one for your code. |
| `launcher.command` | Double-click launcher template for the built `./oop_main` binary for macOS. Do not edit. Infrastructure. |

## Branches

| Branch | Base | Detect / ships | Extra `scripts/` | CI |
|---|---|---|---|---|
| `main` | N/A | starter branch with no dependencies | — | A |
| `baze-de-date/pqxx` | `main` | `include/Database.h`\*, `src/database/Database.cpp`\*, `cmake/MinGWLibpq.cmake`, `.env.example`, `find_package(PostgreSQL)`, `PQXX_VERSION` | `configure_postgres.sh` — creates database and `pgcrypto` (for creating a user, see `README.md`); CI runs it on every OS | A, but **no ASan row on Windows MSVC** |
| `baze-de-date/sqlite` | `main` | `FetchContent` `sqlite3`, `add_library(sqlite3 STATIC …/sqlite3.c)` | — | A |
| `common-libs` | `main` | `ext/include/{date,csv-parser}` (public), `ext/private/{digestpp,random,rlutil}`, `assets/date.csv`\* | — | A |
| `descarcare-date-api` | `main` | `FetchContent` `cpr`, `ext/include/json/` | — | A; macOS-GCC row commented |
| `ftxui` | `main` | `FetchContent` `ftxui`, links `ftxui::screen` / `::dom` / `::component` | — | A |
| `http-server` | `main` | `ext/include/httplib.h` + `ext/lib/httplib.cc` (library target `httplib`), `app/main-client.cpp`\*, target `${MAIN_EXECUTABLE_NAME}_client` | — | A; the runtime rows start the server in the background, and Valgrind analyses `oop_main_client` + `oop_test` |
| `llms` | `descarcare-date-api` | `FetchContent` `cpr numkong`, `NUMKONG_VERSION`, `ext/include/json/` | `run_llm.sh` — fetches and starts a llamafile; CI sources it before every runtime row | A; macOS-GCC row commented |
| `raylib-cpp` | `sfml3` | `FetchContent` `raylib raylib-cpp`, `target_link_libraries(oop PUBLIC raylib)` | GUI set (see `sfml3`) | B; see `sfml3` |
| `sfml3` | `main` | `FetchContent` `SFML`, links `SFML::Graphics`, window title `"My Window"`\* | `install-linux-deps.sh` (dev packages per distro family), `run_sanitizers.sh`, `run_ui_test.sh` | B; macOS-GCC row commented, macOS 15 instead of 26, Clang 17 instead of 21 |
| `sfml3-imagini-externe-api` | `sfml3` | `FetchContent` `SFML cpr` — images fetched over HTTP | GUI set (see `sfml3`) | B; see `sfml3` |
| `sfml3-resurse-locale` | `sfml3` | `include/ResourceManager.hpp`\*, `src/ResourceManager.cpp`\*, `assets/fonts/`\*, `assets/images/`\*, `target_link_libraries(oop PUBLIC SFML::…)` | GUI set (see `sfml3`) | B; see `sfml3` |
| `tests/Boost-ext-ut` | `main` | `ext/include/boost/ut.hpp`, `MAIN_LIBRARY_SOURCES`, second library target `oop_nslib` | — | A; the tests and `oop_nslib` are built **without** sanitizers |
| `tests/gtest` | `main` | `app/CMakeLists.txt` and `src/CMakeLists.txt` exist, `FetchContent` `gtest` inside `tests/CMakeLists.txt`, `include/BankAccount.h`\* | — | A |
| `wxwidgets` | `sfml3` | `FetchContent` `wx`, `target_link_libraries(oop PUBLIC wx::core)` — GUI plumbing only, no SFML in the tree | GUI set (see `sfml3`) | B; see `sfml3` |

## Different on purpose

Every branch rewrites the README for its own stack (`1. Pasul de configurare`),
and `Resurse` belongs to the student. That is by design: never copy a README
region from another branch or from `main`, and never "align" two branches.

## Registering a source, a test or a target

Three shapes exist and all three are correct on their branch. Adding your own `CMakeLists.txt` is fine
too — the freeze is on deleting and changing, not on adding ([INFRA.md](INFRA.md)). By addition,
we mean net genuine additions, not "additions" that modify or delete in disguise.

* **Root `CMakeLists.txt`** (every branch but the two below): sources listed in
  `add_library` / `add_executable` / `target_sources`, tests in `tests/CMakeLists.txt`.
* **Per directory** (`tests/gtest`): library sources in `src/CMakeLists.txt`, the executable in
  `app/CMakeLists.txt`, tests in `tests/CMakeLists.txt`.
* **Shared source list** (`tests/Boost-ext-ut`): one `MAIN_LIBRARY_SOURCES` variable feeds the two library
  targets, `oop` and the uninstrumented `oop_nslib`.

Lists are registered directly even where a variable would read better because IDEs write into
`add_executable` regardless; pick the shape your branch has and do not switch it without a strong reason.

## Reading CI

* **A red row is the only certainty**: something is wrong, and the log of that step says what. A green
  row says nothing about the checks that did not run — never tell a student a leak check or a test
  "passed" because a row was green.
* **Profile A** (all non-GUI branches): every row blocks except the *Sanitizers (Windows MSVC)* step,
  which is `continue-on-error` on every branch, and Clang-tidy, which is advisory.
  You should still have a clean clang-tidy as best-practice.
* **Profile B** (the 5 GUI branches): on Linux the ASan and Valgrind steps are `continue-on-error` and end
  in `|| true`; no ASan/Valgrind step that starts the app can fail; GUI smoke tests are skipped because they
  hang a headless runner; only tests are re-ran again in the context of the delivered artifacts.
  The sanitizer and Valgrind outputs are in the step logs and you are expected to
  read it, locally too (`./scripts/run_valgrind.sh`, an ASan configure). Note that valgrind may need
  additional suppressions for ext libs: those are fine to add (and please contribute them) as long as
  you do not exclude your own code.
* Commented matrix rows and advisory steps are **intentional**: the template keeps as many checks as it can
  and drops only what is genuinely incompatible, with 3 OSes × 2 compilers as the floor.
  Deleting or changing a row is a forbidden edit — if a row looks broken, ask the teacher.
* Some external libraries do not play nice with sanitizers on some OSes; that is why
  `tests/Boost-ext-ut` compiles an uninstrumented twin of the library for the test binary.
* `scripts/run_ui_test.sh` (sends keystrokes with `xdotool` to the window named by `APP_WINDOW`, which must
  match the window title set in `app/`) and `scripts/run_sanitizers.sh` are **CI-internal**: they
  need `xvfb`/`xdotool`; the second expects the unpacked artifact bundle as its working directory. Neither is
  related to `scripts/run_tests.sh`.
