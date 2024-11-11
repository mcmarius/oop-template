Acest branch utilizează Boost-ext/ut, un framework de teste unitare modern, simplu și performant pentru C++.
Boost-ext/ut oferă un API intuitiv, bazat pe expresii, ceea ce îl face ușor de integrat și citit.

Fiecare fișier din `./tests` reprezintă o suită nouă de teste unitare, fiecare fiind adăugată
cu `add_tests`. Acest lucru este făcut automat în [CMakeLists](../CMakeLists.txt). Toate testele vor fi rulate
folosind [CTest](https://cmake.org/cmake/help/book/mastering-cmake/chapter/Testing%20With%20CMake%20and%20CTest.html).

Pentru a mări modularitatea soluției, vom pune toate fișierele scrise de noi într-o bibliotecă. Această abordare ne permite
să refolosim codul deja construit în alte componente/aplicații. În cazul de față, compilăm fișierele sursă atunci
când rulăm aplicația, fiind disponibile direct pentru rularea testelor.