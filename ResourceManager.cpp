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
        <<< Folosiți căi relative >>>

        Exemplu cale absolută:
        loadTexture("C:\\Users\\andrei\\Desktop\\oop-template\\images", "airplane.png");

        Exemplu cale relativă:
        loadTexture("images", "airplane.png");
    */


    loadTexture("images", "airplane.png");
    loadFont("fonts", "FiraSans-Regular.ttf");
}

void ResourceManager::loadTexture(const std::string& path, const std::string& texture_name)
{
    sf::Texture texture;

    // Încercăm să încărcăm textura din fișier
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

    // Încercăm să încărcăm fontul din fișier
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
        // Fiind un exemplu demonstrativ aruncăm std::runtime_error, dar la teme va trebui
        // să vă faceți o ierarhie proprie de excepții
        throw std::runtime_error("Textura " + texture_name + " nu a fost gasita.");
    }

    return m_textures[texture_name];
}

sf::Font& ResourceManager::getFont(const std::string& font_name)
{
    // Înainte de a returna un font trebuie să verificăm dacă acel font există.
    if(m_fonts.find(font_name) == m_fonts.end())
    {
        // Fiind un exemplu demonstrativ aruncăm std::runtime_error, dar la teme va trebui
        // să vă faceți o ierarhie proprie de excepții
        throw std::runtime_error("Font-ul " + font_name + " nu a fost gasit.");
    }

    return m_fonts[font_name];
}