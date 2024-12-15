#include <iostream>
#include <array>
#include <chrono>
#include <thread>

#include <SFML/Graphics.hpp>

#include <Helper.h>

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
    avion.setScale(0.3f, 0.3f);
    avion.setPosition(400, 350);

    sf::FloatRect bounds = avion.getGlobalBounds();
    avion.setOrigin(bounds.left + bounds.width / 2, bounds.top + bounds.height / 2);
}

int main() {
    ///////////////////////////////////////////////////////////////////////////
    ///                Exemplu de utilizare cod generat                     ///
    ///////////////////////////////////////////////////////////////////////////
    Helper helper;
    helper.help();
    ///////////////////////////////////////////////////////////////////////////

    SomeClass *c = getC();
    std::cout << c << "\n";
    delete c;  // comentarea acestui rând ar trebui să ducă la semnalarea unui mem leak

    sf::RenderWindow window;
    ///////////////////////////////////////////////////////////////////////////
    /// NOTE: sync with env variable APP_WINDOW from .github/workflows/cmake.yml:31
    window.create(sf::VideoMode({800, 700}), "My Window", sf::Style::Default);
    ///////////////////////////////////////////////////////////////////////////
    //
    ///////////////////////////////////////////////////////////////////////////
    /// NOTE: mandatory use one of vsync or FPS limit (not both)            ///
    /// This is needed so we do not burn the GPU                            ///
    // window.setVerticalSyncEnabled(true);                                    ///
    window.setFramerateLimit(60);                                       ///
    ///////////////////////////////////////////////////////////////////////////

    /////////////////////////////////////////////////////////
    /// Pentru a putea folosi resurse locale în cadrul programului trebuie modificat `CMakeLists.txt`.
    /// Deschide `CMakeLists.txt` la linia 101.
    ///
    /// După pasul anterior, putem folosi resursele locale folosind sintaxa `ResourceManager::Instance().get*`, unde
    /// * poate fi Texture, Font, Sound sau orice alt tip de resursă de care avem nevoie.
    ////////////////////////////////////////////////////////

    sf::Texture a380_texture;
    try {
        a380_texture = ResourceManager::Instance().getTexture("a380_emirates.png");
    } catch(std::exception& exp) {
        std::cout << exp.what() << std::endl;
        return 0;
    }

    // Decomentează exemplul de mai jos pentru a vedea ce se întâmplă atunci când încerci să primești o textură inexistentă.
    /*
    sf::Texture dummyTexture;
    try {
        dummyTexture = ResourceManager::Instance().getTexture("fizzbuzz.png");
    } catch(std::exception& exp) {
        std::cout << exp.what();
        return 0;
    }
    */

    sf::Sprite a380;
    a380.setTexture(a380_texture);

    PersonalizeazaAvion(a380); // Este o funcție care modifică dimensiunea avionului și îi pune originea în centru.


    sf::Text tip_avion;
    try {
        tip_avion.setFont(ResourceManager::Instance().getFont("FiraSans-Regular.ttf"));
    } catch(std::exception& exp) {
        std::cout << exp.what();
        return 0;
    }

    tip_avion.setString("A380 Emirates");

    while(window.isOpen()) {
        bool shouldExit = false;
        sf::Event e{};
        while(window.pollEvent(e)) {
            switch(e.type) {
                case sf::Event::Closed:
                    window.close();
                    break;
                case sf::Event::Resized:
                    std::cout << "New width: " << window.getSize().x << '\n'
                              << "New height: " << window.getSize().y << '\n';
                    break;
                case sf::Event::KeyPressed:
                    std::cout << "Received key " << (e.key.code == sf::Keyboard::X ? "X" : "(other)") << "\n";
                    if(e.key.code == sf::Keyboard::Escape)
                        shouldExit = true;
                    break;
                default:
                    break;
            }
        }
        if(shouldExit) {
            window.close();
            break;
        }
        using namespace std::chrono_literals;
        std::this_thread::sleep_for(150ms);

        a380.setRotation(a380.getRotation() + 1);

        window.clear();

        window.draw(a380); // Afișăm avionul încărcat pe ecran
        window.draw(tip_avion); // Afișăm tipul avionului

        window.display();
    }
    return 0;
}
