#include <iostream>
#include <array>

#include <sqlite3.h>

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
    ///                Exemplu de utilizare sqlite                          ///
    ///////////////////////////////////////////////////////////////////////////
    sqlite3* db;
    char* errorMessage = nullptr;
    int exit = 0;
    exit = sqlite3_open("example.db", &db);
    /// Deschide o conexiune către o bază de date SQLite persistentă numită "example.db".
    /// Dacă baza de date nu există, aceasta va fi creată în același director cu executabilul.
    // exit = sqlite3_open(":memory:", &db);
    /// Deschide o conexiune către o bază de date SQLite stocată în memorie.
    /// Această bază de date există doar pe durata execuției aplicației.

    if (exit) {
        std::cout << "DB Open Error: " << sqlite3_errmsg(db) << '\n';

    } else {
        std::cout << "Opened Database Successfully!" << '\n';
    }

    const char* createTableSQL = R"(
        CREATE TABLE IF NOT EXISTS Users (
            ID INTEGER PRIMARY KEY AUTOINCREMENT,
            Name TEXT NOT NULL,
            Age INTEGER
        );
    )";
    const char* insertSQL1 = "INSERT INTO Users (Name, Age) VALUES ('Alice', 25);";
    const char* insertSQL2 = "INSERT INTO Users (Name, Age) VALUES ('Bob', 30);";
    const char* updateSQL = "UPDATE Users SET Age = 26 WHERE Name = 'Alice';";
    const char* deleteSQL = "DELETE FROM Users WHERE Name = 'Bob';";

    /// OPERAȚIE CREATE TABLE
    exit = sqlite3_exec(db, createTableSQL, nullptr, 0, &errorMessage);
    if (exit != SQLITE_OK) {
        std::cerr << "Error creating table: " << errorMessage << '\n';
        sqlite3_free(errorMessage);
    } else {
        std::cout << "Table created successfully." << '\n';
    }

    ///OPERAȚII INSERT
    exit = sqlite3_exec(db, insertSQL1, nullptr, 0, &errorMessage);
    if (exit != SQLITE_OK) {
        std::cerr << "Error inserting first record: " << errorMessage << '\n';
        sqlite3_free(errorMessage);
    } else {
        std::cout << "First record inserted successfully." << '\n';
    }

    exit = sqlite3_exec(db, insertSQL2, nullptr, 0, &errorMessage);
    if (exit != SQLITE_OK) {
        std::cerr << "Error inserting second record: " << errorMessage << '\n';
        sqlite3_free(errorMessage);
    } else {
        std::cout << "Second record inserted successfully." << '\n';
    }

    /// OPERAȚIE DE SELECT
    const char* selectSQL = "SELECT ID, Name, Age FROM Users;";
    sqlite3_stmt* stmt;

    exit = sqlite3_prepare_v2(db, selectSQL, -1, &stmt, nullptr);
    if (exit != SQLITE_OK) {
        std::cerr << "Error preparing SELECT statement: " << sqlite3_errmsg(db) << '\n';
    } else {
        std::cout << "ID | Name | Age" << '\n';
        std::cout << "----------------" << '\n';

        while (sqlite3_step(stmt) == SQLITE_ROW) {
            int id = sqlite3_column_int(stmt, 0);
            const unsigned char* name = sqlite3_column_text(stmt, 1);
            int age = sqlite3_column_int(stmt, 2);

            std::cout << id << " | " << name << " | " << age << '\n';
        }
    }
    sqlite3_finalize(stmt);

    /// OPERAȚIE DE UPDATE
    exit = sqlite3_exec(db, updateSQL, nullptr, 0, &errorMessage);
    if (exit != SQLITE_OK) {
        std::cerr << "Error updating record: " << errorMessage << '\n';
        sqlite3_free(errorMessage);
    } else {
        std::cout << "Record updated successfully." << '\n';
    }

    /// OPERAȚIE DE DELETE
    exit = sqlite3_exec(db, deleteSQL, nullptr, 0, &errorMessage);
    if (exit != SQLITE_OK) {
        std::cerr << "Error deleting record: " << errorMessage << '\n';
        sqlite3_free(errorMessage);
    } else {
        std::cout << "Record deleted successfully." << '\n';
    }

    /// Închide conexiunea cu baza de date utilizând sqlite3_close.
    /// În cazul unei baze de date în memorie, toate datele vor fi pierdute la închidere.
    sqlite3_close(db);
    return 0;
}
