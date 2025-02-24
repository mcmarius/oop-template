#include <iostream>
// #include <array>
#include <thread>
#include <csignal>
#include <semaphore>

#include <httplib.h>

// we need this global variable for graceful shutdown
std::binary_semaphore quit_semaphore(0);

void stopHandler(int /*signal*/) {
    // do as little as possible in the signal handler; no std::cout
    quit_semaphore.release();
}

int main() {
    // set global signal handlers
    std::signal(SIGTERM, stopHandler); // stopping by IDE
    std::signal(SIGINT, stopHandler); // stopping by Ctrl+C

    // HTTP server object
    // HTTPS would require additional configuration
    httplib::Server server;

    // request handlers
    // decide how to handle each request based on route/path
    // the path can contain segments for params
    server.Get("/hi", [](const httplib::Request &req, httplib::Response &res) {
        std::cout << "[server] Got req on path " << req.path << "\n";
        res.set_content("Hello World!", "text/plain");
    });
    server.Get("/.*", [](const httplib::Request &req, httplib::Response &res) {
        std::cout << "[server] Got req on unknown path " << req.path << "\n";
        res.status = 404;
        res.set_content("Not found", "text/plain");
    });

    // thread used for graceful shutdown
    std::thread stopper([&]() {
        quit_semaphore.acquire();  // this is a blocking call
        server.stop();
    });
    stopper.detach();

    std::cout << "[server] Starting server\n";
    // bind the server to a port and start accepting requests
    // this runs a "while(true)" loop until the process is stopped
    // port could be configured through an env variable to avoid recompiling
    server.listen("0.0.0.0", 8080);
    std::cout << "[server] Shutting down server\n";
    // std::cout << "Hello, world!\n";
    // std::array<int, 100> v{};
    // int nr;
    // std::cout << "Introduceți nr: ";
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
    // std::cin >> nr;
    /////////////////////////////////////////////////////////////////////////
    // for(int i = 0; i < nr; ++i) {
    //     std::cout << "v[" << i << "] = ";
    //     std::cin >> v[i];
    // }
    // std::cout << "\n\n";
    // std::cout << "Am citit de la tastatură " << nr << " elemente:\n";
    // for(int i = 0; i < nr; ++i) {
    //     std::cout << "- " << v[i] << "\n";
    // }
    ///////////////////////////////////////////////////////////////////////////
    /// Pentru date citite din fișier, NU folosiți tastatura.txt. Creați-vă voi
    /// alt fișier propriu cu ce alt nume doriți.
    /// Exemplu:
    /// std::ifstream fis("date.txt");
    /// for(int i = 0; i < nr2; ++i)
    ///     fis >> v2[i];
    ///
    ///////////////////////////////////////////////////////////////////////////
    return 0;
}
