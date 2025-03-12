#include <iostream>
#include <string>
#include <vector>

///////////////////////////////////////////////////////////////////
//// Vom folosi simsimd pentru a calcula similaritatea cosinus ////
#include <simsimd/simsimd.h>                                   ////
///////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
//// Vom folosi cpr pentru a descărca date dintr-un API ////
#include <cpr/cpr.h>                                    ////
////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////
//// Pentru a putea accesa datele din API este nevoie să parsăm datele primite ////
#include <json.hpp>                                                            ////
///////////////////////////////////////////////////////////////////////////////////

/*
    Ce este un JSON?
    JSON = JavaScript Object Notation

    JSON este un format pentru schimbul de date între un server și o aplicație, fiind utilizat și pentru
    stocarea datelor într-un mod structurat și ușor de citit.

    Un exemplu simplu de JSON arată astfel:
    {
        "nume": "Ion",
        "varsta": 20,
        "hobby-uri": ["poo", "citit", "programare"],
        "restant": false
    }
 */

const std::string API_URL = "http://127.0.0.1:8080";

std::vector<simsimd_f32_t> getEmbeddings(const std::string& word)
{
    std::string api_url = API_URL;
    if(const auto* url = std::getenv("LLM_URL")) {
        api_url = url;
    }
    cpr::Url api_link = api_url + "/embedding"; // Link-ul către API

    // Configurăm parametrii să fie URL-encoded
    cpr::Parameters params = {
        {"content", word}
    };

    // Setăm header-ul
    cpr::Header header = {
        {"Content-Type", "application/json"}
    };


    // Adăugăm timeout la request, deoarece pot exista situații când durează foarte mult.
    const int miliseconds = 2000;
    using json = nlohmann::json;
    cpr::Response res = cpr::Get(api_link, params, header, cpr::Timeout{miliseconds}); // Facem o cerere la API

    if(res.elapsed * 1000 > miliseconds)
    {
        std::cout << "Request timeout" << std::endl;
        return {};
    }
    if(res.status_code != 200) // Dacă status code-ul nu este 200 înseamnă că a apărut o eroare
    {
        std::cout << "Oops!! Got status " << res.status_code << std::endl;
        return {};
    }
    if(res.text.empty())
    {
        std::cout << "Empty response" << std::endl;
        return {};
    }

    json json_resp = json::parse(res.text); // Parsăm răspunsul primit
    std::vector<simsimd_f32_t> embedding = json_resp["embedding"];
    // std::cout << json_resp["embedding"].size() << std::endl;
    return embedding;
}

/*
float getScore(const std::string& word1, const std::string& word2)
{
    std::string api_url = API_URL;
    if(const auto* url = std::getenv("LLM_URL")) {
        api_url = url;
    }

    std::string prompt = std::string("return the cosine similarity of ")
        + word1 + " and " + word2
        + ", respond with a real number between 0 and 1, do not respond with anything else, no explanations";
    cpr::Url api_link = api_url + "/v1/chat/completions"; // Link-ul către API

    // Setăm header-ul
    cpr::Header header = {
        {"Content-Type", "application/json"}
    };


    // Adăugăm timeout la request, deoarece pot exista situații când durează foarte mult.
    const int miliseconds = 15000;
    using json = nlohmann::json;
    json json_body;
    json_body["model"] = "local model";

    json_body["messages"] = json::array({
        // json::object({{"role", "system"}, {"content", "You are a helpful assistant"}}),
        json::object({{"role", "user"}, {"content", prompt}, {"temperature", 0.0}, {"seed", 42}})
    });
    // std::cout << "sending " << json_body << "\n";
    cpr::Body body = {json_body.dump()};
    cpr::Response res = cpr::Post(api_link, body, header, cpr::Timeout{miliseconds}); // Facem o cerere la API

    if(res.elapsed * 1000 > miliseconds)
    {
        std::cout << "Request timeout" << std::endl;
        return {};
    }
    if(res.status_code != 200) // Dacă status code-ul nu este 200 înseamnă că a apărut o eroare
    {
        std::cout << "Oops!! Got status " << res.status_code << std::endl;
        return {};
    }
    if(res.text.empty())
    {
        std::cout << "Empty response" << std::endl;
        return {};
    }

    json json_resp = json::parse(res.text); // Parsăm răspunsul primit
    // std::cout << res.text << "\n";
    // std::cout << json_resp["choices"] << "\n";
    std::string str_score = json_resp["choices"][0]["message"]["content"];
    float score = std::stof(str_score);
    return score;
}
*/

int main()
{
    std::cout << std::endl << "================= Date Embeddings =================" << std::endl;

    std::string word1 = "N/A";
    std::string word2 = "N/A";

    while(word1 != "" && word2 != "") {
        std::cout << "> ";
        std::getline(std::cin, word1);
        std::cout << "> ";
        std::getline(std::cin, word2);

        auto emb1 = getEmbeddings(word1);
        auto emb2 = getEmbeddings(word2);
        simsimd_distance_t distance;
        simsimd_cos_f32(emb1.data(), emb2.data(), emb1.size(), &distance);
        std::cout << "similarity " << word1 << " - " << word2 << ": " << distance << "\n";

        // not very reliable, varies too much, not deterministic
        // std::cout << "score: " << getScore(word1, word2) << "\n";
    }
    return 0;
}
