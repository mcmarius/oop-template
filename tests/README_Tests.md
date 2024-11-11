Acest branch utilizează Boost-ext/ut, un framework de teste unitare modern, simplu și performant pentru C++.
Boost-ext/ut oferă un API intuitiv, bazat pe expresii, ceea ce îl face ușor de integrat și citit.

Fiecare fișier din `./tests` reprezintă o suită nouă de teste unitare. Testele sunt înregistrate
în [CTest](https://cmake.org/cmake/help/book/mastering-cmake/chapter/Testing%20With%20CMake%20and%20CTest.html)
cât se rulează, automat, în `tests/CMakeLists.txt` prin `register_tests` (vezi `cmake/RegisterTests.cmake`):
câte o intrare pentru fiecare test, nu pentru tot executabilul.

```bash
ctest --test-dir build -N      # lista testelor înregistrate
ctest --test-dir build -R "sum"   # rulează doar testele care se potrivesc
```

Lista este produsă de executabilul de teste (`--list-test-names-only`), de aceea:
* numele unui test trebuie să fie unic între toate suitele (ctest nu acceptă două intrări cu același nume);
* în nume nu folosi `*`, `?`, `!`, `.` sau `\` - ut alege un test dupa nume ca și cum ar fi un tipar,
  iar aceste caractere devin metacaractere (dacă un nume devine ambiguu, înregistrarea eșuează zgomotos).

Pentru a mări modularitatea soluției, vom pune toate fișierele scrise de noi într-o bibliotecă. Această abordare ne permite
să refolosim codul deja construit în alte componente/aplicații. În cazul de față, compilăm fișierele sursă atunci
când rulăm aplicația, fiind disponibile direct pentru rularea testelor.