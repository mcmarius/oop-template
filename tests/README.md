Acest branch folosește [googletest](https://google.github.io/googletest/). Fiecare fișier din
`tests/` este o suită nouă, adăugată la executabilul de teste în
[`CMakeLists.txt`](CMakeLists.txt).

Testele se înregistrează în `tests/CMakeLists.txt` (`register_tests`, vezi
`cmake/RegisterTests.cmake`) și se rulează cu CTest:

```sh
ctest --test-dir build -N                        # lista testelor înregistrate
ctest --test-dir build --output-on-failure
# sau ./scripts/cmake.sh test -c Debug
```

* Testați logica de domeniu din `src/`, prin interfața publică din `include/`. `app/`
  (meniu, I/O, `std::cin`) nu este vizibil din `tests/` — așa este conceput. Tot codul
  vostru se compilează o dată, în biblioteca `oop`, de aceea testele îl folosesc fără să
  dubleze din `app/`.
* Un test fără nicio aserțiune doar rulează codul, nu verifică nimic.
* Testele nu citesc de la `std::cin` și nu folosesc căi absolute; CTest le rulează cu
  `WORKING_DIRECTORY` = rădăcina proiectului și cu `TIMEOUT` (60 s), ca să nu atârne CI.
* Ce este greu de testat — UI complex, evenimente aleatoare, dependența de un server
  real — rămâne în `app/` și se verifică pe cât posibil cât mai mult în CI sau la demo.
* Executabilul de teste se livrează împreună cu aplicația (la rădăcina arhivei, lângă
  `oop_main`), deci testele pot fi rulate și din pachetul descărcat: `./oop_test`.
