#include <rlutil.h>
#include <digestpp.hpp>
#include <random.hpp>
#include <csv.hpp>
#include <date.h>

#include <iostream>
#include <cctype>
#include <chrono>
#include <thread>

std::string make_salt() {
    // important este ca salt-ul să fie unic, nu contează că nu este aleator
    // se stochează ca text clar, lângă parola hashed
    static uint64_t nr = 1u;
    std::string salt;
    auto bytes = static_cast<unsigned char*>(static_cast<void*>(&nr));
    for(unsigned i = 0; i < 16; i++) {
        salt += bytes[i%8];
    }
    ++nr;
    return salt;
}

std::string hash_password(const std::string& plain) {
    return digestpp::blake2b(512).set_salt(make_salt()).absorb(plain).hexdigest();
}

int main() {
    std::cout << "-----------------------------------------------\n";

    std::string plain = "temaOOP12345$";
    std::cout << hash_password(plain) << "\n"
              << hash_password(plain) << "\n";

    std::cout << "-----------------------------------------------\n";

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

    using namespace std::chrono_literals;
    std::cout << "begin sleep\n";
    std::this_thread::sleep_for(600ms);
    std::cout << "end sleep\n";

    std::cout << "-----------------------------------------------\n";

    using Random = effolkronium::random_static;
    // Random::seed(42);
    std::cout << Random::get(1, 1000) << "\n";

    std::cout << "-----------------------------------------------\n";

    using namespace csv;
    CSVReader reader{"date.csv"};
    for (CSVRow& row : reader) {
        std::cout << "nume: " << row["nume"].get_sv() << "\n";
        // std::cout << "nume: " << row["nume"].get<>() << "\n";
    }

    std::cout << "-----------------------------------------------\n";

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
