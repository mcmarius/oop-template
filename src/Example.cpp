#include "Example.h"

#include <iostream>
#include <stdexcept>
#include <chrono>
#include <thread>

#include <digestpp.hpp>
#include <rlutil.h>
#include <random.hpp>


#include "internal/Detail.h"   // not visible to app/ and tests/

namespace {
// no header declares this, so it is tested through the public interface, never directly
bool allowed(int value) {
    return value >= 0 && value <= Example::limit;
}
} // namespace

Example::Example(int initial) {
    if (!allowed(initial)) {
        throw std::invalid_argument("Example: initial value must be in [0, limit]");
    }
    value_ = initial;
}

int Example::value() const {
    return value_;
}

void Example::add(int delta) {
    const int next = value_ + delta;
    if (!allowed(next)) {
        throw std::invalid_argument("Example::add: the value must stay in [0, limit]");
    }
    value_ = next;
}

void Example::g() const {
    Detail d;
    d.g();
    std::cout << "value: " << value_ << "\n";
}

/////////////////////////////////////////////////////////////////////////////////////////
/// Exemplu de funcții pentru a stoca parole de utilizatori
/// Folosim biblioteca digestpp pentru a nu stoca parolele în clar
std::string make_salt() {
    /// important este ca salt-ul să fie unic, nu contează că nu este aleatoriu
    /// pentru fiecare user, salt-ul se stochează ca text clar, lângă parola hashed
    /// Exemplu:
    /// class User {
    ///     std::string hashed_password;
    ///     std::string salt;
    /// };
    ///
    static uint64_t nr = 1u;
    std::string salt;
    auto bytes = static_cast<const char*>(static_cast<void*>(&nr));
    for(unsigned i = 0; i < 16; i++) {
        salt += bytes[i%8];
    }
    ++nr;
    return salt;
}

std::string hash_password(const std::string& plain, const std::string& salt) {
    return digestpp::blake2b(512).set_salt(salt).absorb(plain).hexdigest();
}

/////////////////////////////////////////////////////////////////////////////////////////

void Example::demo() {
    ///////////////////////////////////////////////////////////////////////////
    ///                Exemplu criptare parole (digestpp)                   ///
    ///////////////////////////////////////////////////////////////////////////
    std::string plain = "temaOOP12345$";
    auto salt1 = make_salt();  // salt pt user1
    auto salt2 = make_salt();  // salt pt user2
    /// Explicație: deși userii au aceeași parolă, vor avea hash-uri diferite
    /// De ce am vrea asta? Dacă aflăm hash-ul pt un user, nu vom avea automat hash-urile
    /// și pentru alți utilizatori care au folosit aceeași parolă
    /// Alte explicații aici: https://en.wikipedia.org/wiki/Rainbow_table
    ///
    std::cout << "Parola hashed pt user1: " << hash_password(plain, salt1) << "\n"
              << "Parola hashed pt user2: " << hash_password(plain, salt2) << "\n";
    ///
    /// Altă variantă pentru parole criptate este cu bcrypt, dar trebuie compilat.
    /// Un exemplu demo (mai vechi) este aici: https://github.com/zackartz/Bcrypt.cpp
    ///
    std::cout << "-----------------------------------------------\n";

    ///////////////////////////////////////////////////////////////////////////
    ///               Exemplu terminal interactiv (rlutil)                  ///
    ///////////////////////////////////////////////////////////////////////////
    rlutil::setConsoleTitle("test");
    rlutil::saveDefaultColor();
    rlutil::setColor(rlutil::BLUE);
    rlutil::cls();
    int key = rlutil::getkey(); // apel blocant; apelează kbhit și getch
    switch(std::tolower(key)) {
        case rlutil::KEY_SPACE:
            std::cout << "pressed space\n";
            break;
        case 'w':
            std::cout << "pressed w\n";
            break;
        case 'a':
            std::cout << "pressed a\n";
            break;
        case 's':
            std::cout << "pressed s\n";
            break;
        case 'd':
            std::cout << "pressed d\n";
            break;
        default:
            std::cout << "other key (" << key << ")\n";
            break;
    }
    std::cout << "test color text\n";
    rlutil::resetColor();

    std::cout << "-----------------------------------------------\n";

    ///////////////////////////////////////////////////////////////////////////
    ///                           Exemplu sleep                             ///
    ///////////////////////////////////////////////////////////////////////////
    using namespace std::chrono_literals;
    std::cout << "begin sleep\n";
    std::this_thread::sleep_for(600ms);
    std::cout << "end sleep\n";
    std::cout << "value: " << value_ << "\n";

    std::cout << "-----------------------------------------------\n";

    ///////////////////////////////////////////////////////////////////////////
    ///                     Exemplu numere aleatoare                        ///
    ///////////////////////////////////////////////////////////////////////////
    using Random = effolkronium::random_static;
    // Random::seed(42);
    std::cout << Random::get(1, 1000) << "\n";

    std::cout << "-----------------------------------------------\n";
}
