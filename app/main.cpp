#include <iostream>
#include <array>
#include <cctype>

#include <csv.hpp>
#include <date.h>

#include "Example.h"


int main() {
    std::cout << "Hello, world!\n";
    Example e1;
    e1.add(3);
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

    std::cin.ignore(); // clear last \n

    std::cout << "-----------------------------------------------\n";

    e1.demo();

    ///////////////////////////////////////////////////////////////////////////
    ///           Exemplu fișier CSV (comma separated value)                ///
    ///////////////////////////////////////////////////////////////////////////
    using namespace csv;
    CSVReader reader{"assets/date.csv"};
    for (CSVRow& row : reader) {
        std::cout << "nume: " << row["nume"].get_sv() << "\n";
        // std::cout << "nume: " << row["nume"].get<>() << "\n";
    }

    std::cout << "-----------------------------------------------\n";

    ///////////////////////////////////////////////////////////////////////////
    ///              Exemplu de lucru cu date calendaristice                ///
    ///////////////////////////////////////////////////////////////////////////
    using namespace std::chrono;
    using namespace date;
    using date::sys_days;
    using date::days;
    using date::weeks;
    using date::months;
    auto d1 = 2022_y/10/01;
    auto d2 = 2023_y/05/26;

    auto dp1 = sys_days{d1};
    auto dp2 = sys_days{d2};

    std::cout << "Anul 2022-2023 are "
              << duration<float, months::period>(dp2 - dp1).count() << " luni"
              << " sau "
              << duration<float, weeks::period>(dp2 - dp1).count() << " săptămâni"
              << " sau "
              << duration<float, days::period>(dp2 - dp1).count() << " zile"
              << ", adică "
              << floor<months>(dp2 - dp1).count() << " luni, "
              << floor<weeks>(dp2 - dp1 - floor<months>(dp2 - dp1)).count() << " săptămâni, "
              << floor<days>(dp2 - dp1 - floor<weeks>(dp2 - dp1)).count() - 1 << " zile."
              << "\n";

    std::cout << "-----------------------------------------------\n";
    return 0;
}
