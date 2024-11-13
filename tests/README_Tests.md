Acest branch utilizează Boost-ext/ut, un framework de teste unitare modern, simplu și performant pentru C++.
Boost-ext/ut oferă un API intuitiv, bazat pe expresii, ceea ce îl face ușor de integrat și citit.

Fiecare fisier din `./tests`reprezinta o suita noua de teste care este adaugata cu `add_tests`.
Acest lucru este facut automat in CMakeLists.

Pentru a reduce timpul de build trebuie sa se adauge tot codul scris de voi(in afara de `main.cpp`) intr-o librarie
asa cum este exemplificat in CMakeLists.txt. Fisierele pe care le creati ar trebui sa fie puse in directoare
pentru a fi mai usor de adaugat in aceasta librarie.