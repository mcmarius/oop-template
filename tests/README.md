Acest branch folosește [Boost.UT](https://boost-ext.github.io/ut/) (header-only, macro-free,
cu API bazat pe expresii). Fiecare fișier din `tests/` este o suită nouă, adăugată la
executabilul de teste în [`CMakeLists.txt`](CMakeLists.txt).

Testele se înregistrează automat în `tests/CMakeLists.txt` (`register_tests`, vezi
`cmake/RegisterTests.cmake`): câte o intrare CTest pentru fiecare test, nu pentru tot
executabilul. Se rulează cu CTest:

```sh
ctest --test-dir build -N                        # lista testelor înregistrate
ctest --test-dir build -R "Add"                  # doar testele care se potrivesc
ctest --test-dir build --output-on-failure
# sau ./scripts/cmake.sh test -c Debug
```

* Testați logica de domeniu din `src/`, prin interfața publică din `include/`. `app/`
  (meniu, I/O, `std::cin`) nu este vizibil din `tests/` — așa este conceput.
* Logica de domeniu compilează o singură dată, în biblioteca `oop`, și testele o folosesc
  direct, fără să dubleze cod din `app/`. Testele legă însă `oop_nslib`, aceeași sursă construită
  fără sanitizers (pe MSVC testele nu merg instrumentate): un fișier nou din `src/` îl adaugi în
  `MAIN_LIBRARY_SOURCES` din [`CMakeLists.txt`](../CMakeLists.txt), ambele variante îl iau de acolo.
* Un test fără nicio aserțiune doar rulează codul, nu verifică nimic.
* Testele nu citesc de la `std::cin` și nu folosesc căi absolute; CTest le rulează cu
  `WORKING_DIRECTORY` = rădăcina proiectului și cu `TIMEOUT` (60 s), ca să nu atârne CI.
* Ce este greu de testat — UI complex, evenimente aleatoare, dependența de un server
  real — rămâne în `app/` și se verifică pe cât posibil cât mai mult în CI sau la demo.
* Executabilul de teste se livrează împreună cu aplicația (la rădăcina arhivei, lângă
  `oop_main`), deci testele pot fi rulate și din pachetul descărcat: `./oop_test`.

Numele testelor: CTest le citește de la executabilul de teste (`--list-test-names-only`), de aceea
un nume trebuie să fie unic între toate suitele și să nu conțină `*`, `?`, `!`, `.` sau `\` — ut
alege un test după nume ca după un tipar, iar aceste caractere devin metacaractere (un nume
ambiguu face înregistrarea să eșueze zgomotos).
