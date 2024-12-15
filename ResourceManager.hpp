//
// Created by bgd on 12/15/2024.
//

#ifndef RESOURCEMANAGER_HPP
#define RESOURCEMANAGER_HPP

#include <SFML/Graphics.hpp>
#include <unordered_map>

/*
 *  Pentru ușurință clasa `ResourceManager` va fi un Singleton.
 */

//////////////////////////////////////////
////
/// << OBSERVAȚIE >> Fără atribute statice la sf::Texture, sf::Font, sf::SoundBuffer, etc. -> Segmentation Fault
///
///////////////////////////////////////////

class ResourceManager {
public:
    ResourceManager(const ResourceManager&) = delete;
    ResourceManager& operator=(const ResourceManager&) = delete;

    static ResourceManager& Instance();

    sf::Texture& getTexture(const std::string& texture_name);
    sf::Font& getFont(const std::string& font_name);
private:
    ResourceManager();
    ~ResourceManager() = default;

    // Funcțiile de `load*()` pot fi modificate în funcție de preferințele voastre
    void loadTexture(const std::string& path, const std::string& texture_name);
    void loadFont(const std::string& path, const std::string& font_name);

    std::unordered_map<std::string, sf::Texture> m_textures; // Aici vom ține toate texturile încărcate
    std::unordered_map<std::string, sf::Font> m_fonts; // Aici vom ține toate font-urile încărcate
};



#endif //RESOURCEMANAGER_HPP
