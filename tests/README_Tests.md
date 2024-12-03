Acest branch utilizează Boost-ext/ut, un framework de teste unitare modern, simplu și performant pentru C++.
Boost-ext/ut oferă un API intuitiv, bazat pe expresii, ceea ce îl face ușor de integrat și citit.

Fiecare fisier din `./tests`reprezinta o suita noua de teste care este adaugata cu `add_tests`.
Acest lucru este facut automat in CMakeLists.

Pentru a mări modularitatea soluției vom pune toate fișierele scrise de noi într-o bibliotecă. Acest lucru ne permite
să refolosim codul deja construit în alte componente/ aplicații. În cazul de față, construim fișierele sursă atunci
când rulăm aplicația, iar acestea vor putea fi folosite direct atunci când rulăm testele.