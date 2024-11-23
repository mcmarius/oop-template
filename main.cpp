#include <iostream>

#include <SFML/Graphics.hpp>

/////////////////////////////////////////////////////////////
//// Vom folosi cpr pentru a descărca date dintr-un API /////
#include <cpr/cpr.h>                                    /////
/////////////////////////////////////////////////////////////

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
    ///////////////////////////////////////////////////////////////////////////

    SomeClass *c = getC();
    std::cout << c << "\n";
    delete c;  // comentarea acestui rând ar trebui să ducă la semnalarea unui mem leak

    /*
        Vom folosi un API care ne furnizează poze cu pisici.

        Link API >> https://cataas.com
        Link documentație API >> https://cataas.com/doc.html
    */

    cpr::Url api_link = "https://cataas.com/cat?height=800"; // Link-ul către API
    // Când facem o cerere către acest API vom primi o imagine cu o pisică având height-ul de 800px.
    // Documentație >> https://cataas.com/
    // << OBSERVAȚIE >> Dacă imaginea este foarte mare programul poate să crape.

    //    Efectuăm o cerere GET la API pentru a primi imaginea și setăm un timeout de 2 secunde request-ului în cazul în care durează
    // foarte mult să primim răspunsul din varii motive (API-ul este picat, probleme de rețea, etc.)
    constexpr int timeout_ms = 8000;
    cpr::Response res = cpr::Get(
        api_link,
        cpr::Header{{"Content-Type", "image/*"}}, // Setăm `image/*` la Content-Type pentru a primi imagini
        cpr::Timeout{timeout_ms}
    );

    if(res.elapsed * 1000 > timeout_ms) // Răspunsul a sosit mai târziu de 2 secunde (`timeout_ms = 2000ms`)
    {
        std::cout << "Request timeout" << std::endl;
        return 1;
    }

    ///     După ce am primit răspunsul, accesăm șirul de bytes al imaginii folosind
    /// `res.text.data()` și dimensiunea sa cu `res.text.size()`.
    char* buffer = res.text.data(); // Buffer pentru șirul de bytes al imaginii
    size_t buffer_size = res.text.size(); // Dimensiunea șirului de bytes al imaginii


    /// Creăm un obiect de tip sf::Texture pentru a stoca imaginea
    sf::Texture cat_texture;

    /*
        În SFML putem încărca texturi dintr-un buffer apelând funcția `.loadFromMemory()`.
        Antetul funcției loadFromMemory():
            bool loadFromMemory(const void *data, std::size_t size, const IntRect & area = IntRect())

        Dacă nu s-a putut încărca textura din buffer, atunci funcția întoarce `false` și înseamnă că avem o eroare.

        Mai multe informații despre această funcție se află pot găsi în link-ul de jos:
        >>> https://www.sfml-dev.org/documentation/2.6.1/classsf_1_1Texture.php#a2c4adb19dd4cbee0a588eeb85e52a249
    */
    if (!cat_texture.loadFromMemory(buffer, buffer_size)) { // Avem eroare
        std::cout << "Eroare: Poza nu a putut fi incarcata!" << std::endl;
        return 1;
    }
    // Textura a fost încărcată cu succes
    std::cout << "Textura a fost încărcată\n";

    //     Acum vrem să asociem textura cu un sprite. Pentru a realiza acest lucru creăm un obiect de tip sf::Sprite
    // și trimitem `cat_texture` în constructor.
    sf::Sprite cat(cat_texture);

    sf::RenderWindow window;
    ///////////////////////////////////////////////////////////////////////////
    /// NOTE: sync with env variable APP_WINDOW from .github/workflows/cmake.yml:31
    window.create(sf::VideoMode({800, 700}), "My Window", sf::Style::Default);
    ///////////////////////////////////////////////////////////////////////////
    //
    ///////////////////////////////////////////////////////////////////////////
    /// NOTE: mandatory use one of vsync or FPS limit (not both)            ///
    /// This is needed so we do not burn the GPU                            ///
    window.setVerticalSyncEnabled(true);                                    ///
    /// window.setFramerateLimit(60);                                       ///
    ///////////////////////////////////////////////////////////////////////////

    // Bucla principală a aplicației.
    while (window.isOpen())
    {
        sf::Event event{};
        while (window.pollEvent(event))
        {
            switch (event.type)
            {
                case sf::Event::Closed:
                {
                    window.close();
                    break;
                }
                default:
                    break;
            }
        }

        window.clear();

        // Afișăm poza cu pisica pe ecran
        window.draw(cat);

        window.display();
    }

    return 0;
}
