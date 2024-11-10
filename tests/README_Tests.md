Acest branch utilizează GTest, un framework de teste unitare modern, simplu și performant pentru C++.

Fiecare fișier din ./tests reprezintă o suită nouă de teste care trebuie adăugată în executabilul de teste.
Acest pas trebuie configurat în [CMakeLists.txt](./CMakeLists.txt).
Testele vor fi rulate cu ajutorul [CTest](https://cmake.org/cmake/help/book/mastering-cmake/chapter/Testing%20With%20CMake%20and%20CTest.html).

Pentru a mări modularitatea soluției, vom pune toate fișierele scrise de noi într-o bibliotecă.
Acest lucru ne permite să refolosim codul deja construit în alte componente/aplicații.
În cazul de față, compilăm fișierele sursă atunci când rulăm aplicația, fiind disponibile
direct pentru rularea testelor unitare.