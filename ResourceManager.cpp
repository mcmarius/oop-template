//
// Created by bgd on 12/15/2024.
//

#include "ResourceManager.hpp"

ResourceManager& ResourceManager::Instance()
{
    static ResourceManager instance;
    return instance;
}

ResourceManager::ResourceManager()
{
    loadTexture("images", "airplane.png");

    loadFont("fonts", "FiraSans-Regular.ttf");
}

void ResourceManager::loadTexture(const std::string& path, const std::string& texture_name)
{
    sf::Texture texture;

    if(!texture.loadFromFile(path + '/' + texture_name))
    {
        // Fiind un exemplu demonstrativ aruncăm std::runtime_error, dar la teme va trebui
        // să vă faceți o ierarhie proprie de excepții
        throw std::runtime_error("Textura " + texture_name + " nu a putut fi incarcata.");
    }

    m_textures[texture_name] = texture;
}

void ResourceManager::loadFont(const std::string& path, const std::string& font_name)
{
    sf::Font font;

    if(!font.loadFromFile(path + '/' + font_name))
    {
        // Fiind un exemplu demonstrativ aruncăm std::runtime_error, dar la teme va trebui
        // să vă faceți o ierarhie proprie de excepții
        throw std::runtime_error("Textura " + font_name + " nu a putut fi incarcata.");
    }

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