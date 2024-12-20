#include <iostream>
#include <array>

#include "Database.h"

int main() {
    std::cout << "Hello, world!\n";
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
    ///                Exemplu de utilizare pqxx                            ///
    ///////////////////////////////////////////////////////////////////////////
    Database &database = Database::getDatabaseInstance(true);

    std::cout << "\nBaza de date a fost inițializată\n\n";

    database.addUser("User1","Password1");
    database.addUser("User2","Password2");
    std::cout << "Au fost adăugați 2 utilizatori!\n";

    std::cout << "Afișarea unui utilizator după nume:\n";
    std::tuple<std::string,std::string> user = database.showUser("User1");
    // Observație! Parolele sunt afișate aici doar cu scop demonstrativ
    // De obicei nu vrem să expunem deloc informații secrete, chiar dacă sunt criptate.
    std::cout << std::get<0>(user) << " " << std::get<1>(user) << "\n\n";

    std::cout << "Afișarea tuturor utilizatorilor:\n";
    auto result = database.showAllUsers();
    for (const auto& row : result)
    {
        std::cout << std::get<0>(row) << " " << std::get<1>(row) << '\n';
    }

    database.deleteUser("User1");
    std::cout << "\nUtilizatorul 1 a fost șters!\nUtilizatori finali:\n";
    result = database.showAllUsers();
    for (const auto& row : result)
    {
        std::cout << std::get<0>(row) << " " << std::get<1>(row) << '\n';
    }

    std::cout<< "\nSchimbarea parolei utilizatorului rămas!\n";
    database.updateUserPassword("User2","NewUser2Password");
    user = database.showUser("User2");
    std::cout << std::get<0>(user) << " " << std::get<1>(user);
    return 0;
}
