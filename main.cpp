#include <iostream>
#include <array>
#include <chrono>
#include <thread>

#include <raylib-cpp.hpp>

#include "include/Example.h"
// This also works if you do not want `include/`, but some editors might not like it
// #include "Example.h"

//////////////////////////////////////////////////////////////////////
/// This class is used to test that the memory leak checks work as expected even when using a GUI
class SomeClass {
public:
    explicit SomeClass(int) {}
};

SomeClass *getC() {
    return new SomeClass{2};
}
//////////////////////////////////////////////////////////////////////


int main() {
    std::cout << "Hello, world!\n";
    Example e1;
    e1.g();
    std::array<int, 100> v{};
    int nr;
    std::cout << "Introduceți nr: ";
    /////////////////////////////////////////////////////////////////////////
    /// Observație: dacă aveți nevoie să citiți date de intrare de la tastatură,
    /// dați exemple de date de intrare folosind fișierul tastatura.txt
    /// Trebuie să aveți în fișierul tastatura.txt suficiente date de intrare
    /// (în formatul impus de voi) astfel încât execuția programului să se încheie.
    /// De asemenea, trebuie să adăugați în acest fișier date de intrare
    /// pentru cât mai multe ramuri de execuție.
    /// Dorim să facem acest lucru pentru a automatiza testarea codului, fără să
    /// mai pierdem timp de fiecare dată să introducem de la zero aceleași date de intrare.
    ///
    /// Pe GitHub Actions (bife), fișierul tastatura.txt este folosit
    /// pentru a simula date introduse de la tastatură.
    /// Bifele verifică dacă programul are erori de compilare, erori de memorie și memory leaks.
    ///
    /// Dacă nu puneți în tastatura.txt suficiente date de intrare, îmi rezerv dreptul să vă
    /// testez codul cu ce date de intrare am chef și să nu pun notă dacă găsesc vreun bug.
    /// Impun această cerință ca să învățați să faceți un demo și să arătați părțile din
    /// program care merg (și să le evitați pe cele care nu merg).
    ///
    /////////////////////////////////////////////////////////////////////////
    std::cin >> nr;
    /////////////////////////////////////////////////////////////////////////
    for(int i = 0; i < nr; ++i) {
        std::cout << "v[" << i << "] = ";
        std::cin >> v[i];
    }
    std::cout << "\n\n";
    std::cout << "Am citit de la tastatură " << nr << " elemente:\n";
    for(int i = 0; i < nr; ++i) {
        std::cout << "- " << v[i] << "\n";
    }
    ///////////////////////////////////////////////////////////////////////////
    /// Pentru date citite din fișier, NU folosiți tastatura.txt. Creați-vă voi
    /// alt fișier propriu cu ce alt nume doriți.
    /// Exemplu:
    /// std::ifstream fis("date.txt");
    /// for(int i = 0; i < nr2; ++i)
    ///     fis >> v2[i];
    ///
    ///////////////////////////////////////////////////////////////////////////

    SomeClass *c = getC();
    std::cout << c << "\n";
    delete c;  // comentarea acestui rând ar trebui să ducă la semnalarea unui mem leak

// Dimensiunile ferestrei
    int screenWidth = 800;
    int screenHeight = 700;

    // Crearea ferestrei (constructorul raylib::Window o inițializează automat)
    // NOTE: sync with env variable APP_WINDOW from .github/workflows/cmake.yml:31
    raylib::Window window(screenWidth, screenHeight, "My Window");

    std::cout << "Fereastra a fost creată\n";

    // NOTE: mandatory use one of vsync or FPS limit (not both)
    // În Raylib, setarea FPS limitează automat și consumul GPU
    window.SetTargetFPS(60); 
    // Dacă preferi VSync: SetConfigFlags(FLAG_VSYNC_HINT); înainte de init

    // Loop-ul principal
    while (!window.ShouldClose()) { // ShouldClose verifică automat butonul de închidere (X)
        bool shouldExit = false;

        // Gestionarea evenimentelor (Raylib verifică starea în fiecare frame)
        
        // Verificare Resize
        if (window.IsResized()) {
            std::cout << "New width: " << window.GetWidth() << '\n'
                      << "New height: " << window.GetHeight() << '\n';
        }

        // Verificare Taste
        if (IsKeyPressed(KEY_X)) {
            std::cout << "Received key X\n";
        }

        if (IsKeyPressed(KEY_ESCAPE)) {
            shouldExit = true;
        }

        if (shouldExit) {
            std::cout << "Fereastra a fost închisă (shouldExit == true)\n";
            break; // Ieșim din loop, fereastra se închide la distrugerea obiectului
        }

        // Simulare delay din exemplul tău (atenție: strică fluiditatea ferestrei)
        using namespace std::chrono_literals;
        std::this_thread::sleep_for(300ms);

        // Randare
        BeginDrawing();
            window.ClearBackground(RAYWHITE); // Echivalentul lui window.clear()
            
            // Aici poți desena chestii
            
        EndDrawing(); // Echivalentul lui window.display()
    }

    std::cout << "Fereastra a fost închisă\n";
    std::cout << "Programul a terminat execuția\n";

    return 0;
}
