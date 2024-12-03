Acest branch utilizează GTest, un framework de teste unitare modern, simplu și performant pentru C++.

Fiecare fisier din ./tests reprezintă o suita noua de teste care trebuie adaugată în executabilul de teste.
Acest lucru trebuie făcut în [CMakeLists.txt](./CMakeLists.txt).

Pentru a mări modularitatea soluției vom pune toate fișierele scrise de noi într-o bibliotecă.
âAcest lucru ne permite să refolosim codul deja construit în alte componente/ aplicații.
În cazul de față, construim fișierele sursă atunci când rulăm aplicația,
iar acestea vor putea fi folosite direct atunci când rulăm testele.