#include <iostream>
#include <array>
#include <chrono>
#include <thread>

#include <SFML/Graphics.hpp>

#include "ResourceManager.hpp"

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

void PersonalizeazaAvion(sf::Sprite& avion)
{
    avion.setScale({0.3f, 0.3f});
    avion.setPosition({400, 350});

    sf::FloatRect bounds = avion.getGlobalBounds();
    avion.setOrigin({
        bounds.position.x + bounds.size.x / 2,
        bounds.position.y + bounds.size.y / 2
    });
}

int main() {
    ///////////////////////////////////////////////////////////////////////////

    SomeClass *c = getC();
    std::cout << c << "\n";
    delete c;  // comentarea acestui rând ar trebui să ducă la semnalarea unui mem leak

    sf::RenderWindow window;
    ///////////////////////////////////////////////////////////////////////////
    /// NOTE: sync with env variable APP_WINDOW from .github/workflows/cmake.yml:31
    window.create(sf::VideoMode({800, 700}), "My Window", sf::Style::Default);
    ///////////////////////////////////////////////////////////////////////////
    std::cout << "Fereastra a fost creată\n";
    ///////////////////////////////////////////////////////////////////////////
    /// NOTE: mandatory use one of vsync or FPS limit (not both)            ///
    /// This is needed so we do not burn the GPU                            ///
    // window.setVerticalSyncEnabled(true);                                 ///
    window.setFramerateLimit(60);                                           ///
    ///////////////////////////////////////////////////////////////////////////

    /////////////////////////////////////////////////////////
    /// Pentru a putea folosi resurse locale în cadrul programului trebuie modificat `CMakeLists.txt`.
    /// Deschide `CMakeLists.txt` și dă scroll la final, unde sunt apelurile la funcția `copy_files()`.
    ///
    /// După pasul anterior, putem folosi resursele locale folosind sintaxa `ResourceManager::Instance().get*`, unde
    /// * poate fi Texture, Font, Sound sau orice alt tip de resursă de care avem nevoie.
    ////////////////////////////////////////////////////////

    // Decomentează liniile marcate cu `@` de mai jos pentru a vedea ce se întâmplă atunci când încerci să primești o textură inexistentă.

    sf::Font font = ResourceManager::Instance().getFont("FiraSans-Regular.ttf");

    sf::Texture avion_texture;
    sf::Text tip_avion(font);
    // sf::Texture dummyTexture; // @

    try {
        avion_texture = ResourceManager::Instance().getTexture("airplane.png");
        // dummyTexture = ResourceManager::Instance().getTexture("fizzbuzz.png"); // @
    } catch(std::exception& exp) {
        std::cout << exp.what() << std::endl;
        return 0;
    }

    sf::Sprite avion(avion_texture);

    PersonalizeazaAvion(avion); // Este o funcție care modifică dimensiunea avionului și îi pune originea în centru.

    tip_avion.setString("An airplane");

    while(window.isOpen()) {
        bool shouldExit = false;

        while(const std::optional event = window.pollEvent()) {
            if (event->is<sf::Event::Closed>()) {
                window.close();
                std::cout << "Fereastra a fost închisă\n";
            }
            else if (event->is<sf::Event::Resized>()) {
                std::cout << "New width: " << window.getSize().x << '\n'
                          << "New height: " << window.getSize().y << '\n';
            }
            else if (event->is<sf::Event::KeyPressed>()) {
                const auto* keyPressed = event->getIf<sf::Event::KeyPressed>();
                std::cout << "Received key " << (keyPressed->scancode == sf::Keyboard::Scancode::X ? "X" : "(other)") << "\n";
                if(keyPressed->scancode == sf::Keyboard::Scancode::Escape) {
                    shouldExit = true;
                }
            }
        }

        if(shouldExit) {
            window.close();
            std::cout << "Fereastra a fost închisă (shouldExit == true)\n";
            break;
        }

        using namespace std::chrono_literals;
        std::this_thread::sleep_for(150ms);


        float new_angle = avion.getRotation().asDegrees() + 1;
        sf::Angle angle = sf::degrees(new_angle);
        avion.setRotation(angle);

        window.clear();

        window.draw(avion); // Afișăm avionul încărcat pe ecran
        window.draw(tip_avion); // Afișăm tipul avionului

        window.display();
    }

    std::cout << "Programul a terminat execuția\n";
    return 0;
}
