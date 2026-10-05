# Common mistakes — read them early, not the night before the deadline

> **Reading this as an AI assistant?** Load it when you are about to review code or hand it over,
> then work from the items that apply — it is not worth keeping in context for every question.

This is a catalogue of the mistakes that keep showing up in this course's projects.
It exists so you can avoid them *while designing*, not so you can patch them in a panic
commit an hour before the deadline.

* The **binding rules** are the checkboxes in the [README](../README.md) plus what is said at labs
  and at the oral. This file only collects the recurring ways students misread those rules.
* It is **not exhaustive** and it is **not a points menu**. "Not listed here" does not mean allowed,
  and ticking items off this list is not the same as building a project that makes sense.
* You are graded on code you wrote, understand and can defend. A mistake you can explain and
  justify is worth far more than a requirement satisfied by code you cannot discuss.

Severity: 🔴 the requirement counts as **not met** · 🟠 **costs points** · ⚪ polish, fix it when you notice it.

---

## 1. Hard rules

| Rule | Why it matters | What to do instead |
|---|---|---|
| 🔴 No public data members — **fără atribute publice!** | The object's invariants can be broken from anywhere, so the class has no behaviour to speak of. | Private members, public *operations*. A getter is not an operation; `private:` is the default in `class`. |
| 🔴 No global / file-scope variables — **fără variabile globale!** | Hidden coupling; state that no constructor, test or `main` controls. | Pass what you need; make it a member or a parameter. `static const`/`constexpr` constants are fine. |
| 🔴 No filler — **fără cod de umplutură/fără sens!** | Members that nothing calls (or that are "called" somewhere only to look used) are noise: they tell me nothing was learned. | Write a member when the scenario needs it. Generated code you did not contribute to earns at most bonus points, and only if it genuinely helps. |
| 🔴 No copy-paste — **fără copy-paste!** | Duplicated blocks double every future bug and are the clearest sign the design was not thought through. | Pull the shared part into a function, a template, or a base class. |
| 🔴 No data in the code — **fără date în cod!** | A project that hardcodes its dataset is not a program, it is a transcript with `if`s. | Read from your own data files as csv/json/other well-known format; do not hand-roll your own parser, use dedicated libraries (you have examples on other branches). And read from a library/DB where the topic requires it. `tastatura.txt` is for keyboard input only. |
| 🔴 `.gitattributes` set correctly (most likely no-op) | Linguist decides what counts as C++: ≥52–60% (T1), 75–78% (T2), 80–90% (T3). Wrong settings will put a bad project under even stricter checks. | Check the language bar on GitHub after your first real commit, not after the last one. Tests do not count towards this limit. |
| 🔴 CI green, **all** checkboxes ticked, a git tag per homework | CI is the entry ticket; an unticked box or a missing tag is a purely administrative way to lose chances to enter the exam. | Budget time for CI round-trips; see [section 6](#6-checking-your-own-work). |
| 🔴 No OS-specific headers (`conio.h`, `windows.h`, …) | CI builds on more than one OS; these headers break it and make the code non-portable. | Standard I/O only. Ask if you really think you need one. Portable alternatives are provided in branches. |
| 🔴 Source files must be in the repo | An empty or partially committed repo has nothing to grade. | Check `git status --ignored` once in a while: `build/` and `install_dir/` belong in `.gitignore`, your sources do not. |
| 🔴 No memory errors | Leaks, out-of-bounds, UB. These are already checked automatically. | Run Valgrind and ASan yourself, see below. |

## 2. Theme requirements — how students usually misread them

**Tema 1**
* 🟠 *3–4 classes "made" by inheritance.* The requirement is **composition with classes you defined**;
  inheritance does not count here.
* 🟠 *`operator<<` per class that prints everything flat.* The point is **composition of `operator<<` calls** —
  each class prints its own part and delegates to the members it holds.
* 🟠 *"3 public functions" = read a file, print a vector, remove an element.* Those are trivial;
  the requirement asks for project-specific functionality.
* 🟠 *`main` that constructs objects but never talks to them.* The scenario must be **cu sens**: every
  public function is used, and the sequence shows *why* these classes exist together.

**Tema 2**
* 🟠 *Code still all in headers, or all in one file, or mixed (header does not read cleanly).*
  Split declaration (`.h`/`.hpp`) from definition (`.cpp`). One should understand a class just from the header.
* 🟠 *Base class taken from the STL or from some class you already had.* The hierarchy needs **your own base**.
  Borrowing interfaces from external libraries (or inheriting from them) does not count either.
* 🟠 *Virtuals declared and then called on concrete types.* They must be called **through a base pointer**
  held by the class that owns the collection — that pointer member is the whole exercise.
* 🟠 *Only `print`/`read`/`draw`/`update` virtuals.* At least one virtual must be **specific to your theme**;
  library-ish verbs and clone constructors don't qualify.
* 🔴 *Missing `virtual` destructor in a polymorphic base.* Deleting through a base pointer is undefined
  behaviour and leaks.
* 🟠 *`dynamic_cast` sprinkled around, or never used.* A downcast needs a reason; say it in the review.
  Useful only sparingly. When used for most derived classes, it is definitely code smell.
* 🟠 *Exception hierarchy built on top of the class hierarchy, or one class reused for every error.*
  Own base derived from `std::exception`, **≥3 distinct error categories**, and that hierarchy is
  **independent** of the one with the virtuals.
* 🟠 *The 4th derived class added at the end as decoration.* It has to be **integrated** — reachable and
  used, without touching the rest of the code. Mandatory as separate commit.
  If not fulfilled, you will be requested to add a 5th class.

**Tema 3**
* 🟠 *Patterns mislabelled.* If you have to stretch the definition, it is not that pattern (see section 4).
* 🟠 *Template with one instantiation.* Minimum **2**, and it must be a template because the *logic* is the
  same, not because the type name changed. Slop not allowed: no "stats"/"min" or low-effort wrappers over STL containers.

## 3. Code quality

* ⚪→🟠 **Magic numbers.** → `constexpr`, `enum class`, or derive it (`sizeof`, a named constant).
* 🟠 **`std::cout` hardcoded inside members.** Display goes through `operator<<(std::ostream&, …)` so it can go anywhere.
* 🟠 **Getter/setter spam.** A public API of one-liners is not a design; expose high-level operations and keep the rest `private`.
* ⚪ **`static` misuse.** T2 asks for static functions *and* static data — use them where they actually belong, not as global helpers in disguise.
* 🟠 **Hand-rolled arrays / raw `new`/`delete`.** `std::vector` and smart pointers; `cppcoreguidelines-owning-memory` will point them out.
* 🟠 **`friend` between unrelated classes.** Treated the same as public data members.
* ⚪ **Pass by value where `const&` fits** (`performance-unnecessary-value-param`), ⚪ **shadowing** (`-Wshadow`).
* 🟠 **`#define N 5`** instead of `constexpr`; 🟠 **`goto`**; 🟠 **`final` classes** — all explicitly discouraged in this course.
* 🟠 **`throw` caught in the same function that threw it**, or exceptions wrapping a `switch`/`if` as control flow.
  Throw where the error is detected, catch where it can be handled (usually `main`) — and handle it with a message that means something.
  Avoid wrapping the entire `main` in a big `try`/`catch`.
* ⚪ **Calling a base-class helper in every derived class** instead of moving the common code up into the base.
* 🟠 **Storing a computed value as a member** instead of a function that returns it — the cached value goes stale.
* 🟠 **I/O, menus and prints that serve no requirement.** Extra interaction is not extra OOP.

## 4. Design & meaning

This is the part no script can grade for you, and the part the oral is about.

* 🟠 A **factory** that takes five parameters and reads from `std::cin` is not a factory.
* 🟠 A **singleton** that is copyable (or whose destructor is public, or that is just a namespace with extra steps) is not a singleton.
* 🟠 A hierarchy whose virtuals nothing calls through a base pointer, a template nobody instantiates,
  a design pattern used once in three lines: the label is not the point, the structure is.
* 🔴 **"Cu sens"**: a reader should be able to tell what your domain is, why these classes collaborate,
  and what each requirement actually buys you in your project. If the answer is "it was required",
  the requirement is not met.

## 5. Repo, git, review

* 🟠 A tag per homework/stage (`v0.1`, `v0.2`, `v0.3`) with optional patch versions, placed on the commit where everything for that part is done.
* 🟠 External libraries, datasets and resources not cited in the **Resurse** section of the README.
* ⚪ Everything in one giant commit. Commit per feature, so a history exists to review and code review #1–#3 has something to discuss.
* 🟠 **A test that hangs or reads `std::cin`.** CTest kills it after 60 s, but the ASan, Valgrind and smoke steps run the same test binary directly, with **no timeout**, and eat the whole job. Tests take data from fixtures, never from `std::cin`; at EOF a "read until the input is valid" loop spins forever.
* 🟠 **A test with no assertion.** It runs code, it verifies nothing.
* 🟠 **Making a member public so it can be tested.** Widen nothing for a check — test through the public interface.
* 🔴 **`tests/` written to raise the C++ share.** The percentage is measured without `tests/`, and filler is penalised anyway.
* ⚪ **Library code whose only effect is `std::cout`.** Catalog C2, visible now that the library is separate from `app/`.
* 🟠 **A vendored type in a public header that could have stayed private.** Parse in the `.cpp`, hand out std types, keep that dep `SYSTEM PRIVATE`.

## 6. Checking your own work

The same things CI runs, you can run locally — see the [README](../README.md) for the full instructions:

```sh
./scripts/cmake.sh configure      # add -e "-DUSE_ASAN=ON" for AddressSanitizer
./scripts/cmake.sh build
./scripts/run_cppcheck.sh
./scripts/run_valgrind.sh
clang-tidy -p build src/*.cpp app/*.cpp tests/*.cpp   # uses the repo's .clang-tidy
```

Practical notes:

* Fix **all** the independent CI failures in one push; each round-trip is minutes of waiting.
* Keep a recent green commit on your default branch and re-run a workflow from time to time —
  the CI dependency cache expires, and pushing on a cold cache after weeks of silence is slow.
* A green CI means your code compiles and passes the mechanical checks. It is the **minimum**, not a proof of design.

## 7. Beyond CI

There are additional automated checks besides CI. They **cannot be circumvented**;
attempting to route around a requirement is an instant fail for the whole
project, so the only strategy that works is writing it properly. If a rule seems impossible
or unclear in your particular project, ask — there is always a legitimate way to do it.

## 8. When something is stuck

Ask early, with specifics: what you tried, what you expected, what happened. A five-minute
discussion at lab usually beats five hours (or five days) of guessing, and design problems
do not get cheaper with age — fixed late, they become rewrites. Read [INFRA.md](INFRA.md)
before changing/deleting anything in any `CMakeLists.txt`, `cmake/`, `scripts/` or `.github/`.
