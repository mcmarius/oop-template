#include "ResourceManager.hpp"

/*
    Clasa ResourceManager este implementată ca un Singleton.
    Ideea de bază: vrem să avem un singur "manager" de resurse (texturi, fonturi etc.) care să fie accesibil
din orice parte a programului.
*/
ResourceManager& ResourceManager::Instance()
{
    // Instanța statică este creată doar o singură dată la prima apelare a metodei Instance().
    static ResourceManager instance;
    return instance;
}

/*
    Constructorul clasei.
    Aici încărcăm câteva resurse pentru a ne asigura că programul are texturi și fonturi de bază disponibile.
*/
ResourceManager::ResourceManager()
{
    /*
        La `path` NU folosiți căi absolute!

        Problema căilor absolute este că acestea vor funcționa doar pe calculatorul vostru, iar
        dacă altcineva va încerca să ruleze programul pe alt calculator, este foarte probabil
        ca acele căi absolute să nu mai fie valide și programul să nu mai funcționeze corect.

        Rezolvarea acestei probleme: <<< Folosiți căi relative >>>

        Exemplu cale absolută:
        loadTexture("C:\\Users\\andrei\\Desktop\\oop-template\\images", "airplane.png");

        Exemplu cale relativă:
        loadTexture("images", "airplane.png"); // va accesa folderul `images` din directorul curent al programului (./images/airplane.png)
    */

    loadTexture("images", "airplane.png");
    loadFont("fonts", "FiraSans-Regular.ttf");
}

void ResourceManager::loadTexture(const std::string& path, const std::string& texture_name)
{
    sf::Texture texture;

    // Încercăm să încărcăm textura din fișier, dacă nu există se va arunca o excepție
    if(!texture.loadFromFile(path + '/' + texture_name))
    {
        // Fiind un exemplu demonstrativ aruncăm std::runtime_error, dar la teme va trebui
        // să vă faceți o ierarhie proprie de excepții
        throw std::runtime_error("Textura " + texture_name + " nu a putut fi incarcata.");
    }

    // Dacă încărcarea a reușit, salvăm textura în map-ul intern
    m_textures[texture_name] = texture;
}

// Similar cu loadTexture, dar pentru fonturi
void ResourceManager::loadFont(const std::string& path, const std::string& font_name)
{
    sf::Font font;

    // Încercăm să încărcăm fontul din fișier, dacă nu există se va arunca o excepție
    if(!font.openFromFile(path + '/' + font_name))
    {
        // Fiind un exemplu demonstrativ aruncăm std::runtime_error, dar la teme va trebui
        // să vă faceți o ierarhie proprie de excepții
        throw std::runtime_error("Textura " + font_name + " nu a putut fi incarcata.");
    }

    // Dacă încărcarea a reușit, salvăm fontul în map-ul intern
    m_fonts[font_name] = font;
}


sf::Texture& ResourceManager::getTexture(const std::string& texture_name)
{
    // Înainte de a returna o textură trebuie să verificăm dacă acea textură există.
    if(m_textures.find(texture_name) == m_textures.end())
    {
        // Dacă textura nu există, aruncăm o excepție.

        // Fiind un exemplu demonstrativ aruncăm std::runtime_error, dar la teme va trebui
        // să vă faceți o ierarhie proprie de excepții
        throw std::runtime_error("Textura " + texture_name + " nu a fost gasita.");
    }

    // Textura există și o returnăm
    return m_textures[texture_name];
}

sf::Font& ResourceManager::getFont(const std::string& font_name)
{
    // Înainte de a returna un font trebuie să verificăm dacă acel font există.
    if(m_fonts.find(font_name) == m_fonts.end())
    {
        // Dacă fontul nu există, aruncăm o excepție.

        // Fiind un exemplu demonstrativ aruncăm std::runtime_error, dar la teme va trebui
        // să vă faceți o ierarhie proprie de excepții
        throw std::runtime_error("Font-ul " + font_name + " nu a fost gasit.");
    }

    // Fontul există și îl returnăm
    return m_fonts[font_name];
}