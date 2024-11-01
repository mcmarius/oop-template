#include <iostream>
#include <string>

/////////////////////////////////////////////////////////////
//// Vom folosi cpr pentru a descărca date dintr-un API /////
#include <cpr/cpr.h>                                    /////
/////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////
/// Pentru a putea accesa datele din API este nevoie să parsăm datele primite /////
#include <json.hpp>                                                           /////
///////////////////////////////////////////////////////////////////////////////////


std::string RandomFact()
{
    /*
        API-ul   https://uselessfacts.jsph.pl/api/v2/facts/random   ne dă următorul JSON

        {
            id: "...",
            text: "...",
            source: "...",
            source_url: "...",
            language: "en",
            permalink: "..."
        }

    */


    cpr::Url api_link = "https://uselessfacts.jsph.pl/api/v2/facts/random"; // Link-ul către API
    cpr::Response res = cpr::Get(api_link); // Facem o cerere la API

    if(res.status_code != 200) // Dacă status code-ul nu este 200 înseamnă că a apărut o eroare
    {
        return "A apărut o eroare!";
    }


    // res.text este doar un string cu datele descărcate din API, dar nu pot fi accesate sau folosite
    nlohmann::json json = nlohmann::json::parse(res.text); // Parsăm res.text pentru a folosi datele din JSON

    // Acum putem accesa datele folosind variabila 'json' cu json["nume_camp"]
    std::string fact = json["text"].get<std::string>(); // accesăm câmpul "text" și îi facem convert la string

    return fact;
}


bool IsEven(int numar)
{
    /*
        API-ul   https://api.isevenapi.xyz/api/iseven/{{numar}}   ne dă următorul JSON

        {
            ad: "...",
            iseven: "true/false"
        }

        În caz de eroare are următoarea structură:
        {
            error: "..."
        }

    */


    cpr::Url api_link = "https://api.isevenapi.xyz/api/iseven/" + std::to_string(numar); // Link-ul către API
    cpr::Response res = cpr::Get(api_link); // Facem o cerere la API

    nlohmann::json un_json = nlohmann::json::parse(res.text); // Parsăm res.text pentru a folosi datele din JSON

    if(un_json.contains("error"))
    {
        std::string eroare = un_json["error"].get<std::string>();
        throw std::runtime_error("Eroare!! API-ul a spus: " + eroare); // :)
    }

    // Acum putem accesa datele folosind variabila 'un_json' cu un_json["nume_camp"]
    bool isEven = un_json["iseven"].get<bool>(); // accesăm câmpul "iseven" și îi facem convert la bool

    return isEven;
}


int main()
{
    std::cout << "Uite un random fact: " << RandomFact() << std::endl;

    int numar;
    std::cout << "Introdu un număr: "; std::cin >> numar;

    try
    {
        if(IsEven(numar))
        {
            std::cout << numar << " este par!";
        }
        else
        {
            std::cout << numar << " nu este par!";
        }
    } catch (std::exception& exception)
    {
        std::cout << exception.what() << std::endl;
    }

    return 0;
}
