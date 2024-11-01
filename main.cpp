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

void ShowRandomFact()
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
    // Înainte de a face un request la un API trebuie să specificăm în header cum vrem să primim răspunsul (Content-Type), deoarece
    // pot exista API-uri care nu întorc neapărat un JSON (de exemplu, unele pot returna un XML).

    cpr::Header header = {
        {"Content-Type", "application/json"}
    };

    // Adăugăm timeout la request, deoarece pot exista situații când durează foarte mult.
    const int miliseconds = 2000;
    cpr::Response res = cpr::Get(api_link, header, cpr::Timeout{miliseconds}); // Facem o cerere la API

    if(res.elapsed * 1000 > miliseconds)
    {
        std::cout << "Request timeout" << std::endl;
        return;
    }
    if(res.status_code != 200) // Dacă status code-ul nu este 200 înseamnă că a apărut o eroare
    {
        std::cout << "Oops!!" << std::endl;
        return;
    }
    if(res.text.empty())
    {
        std::cout << "Empty response" << std::endl;
        return;
    }

    // res.text este doar un string cu datele descărcate din API.

    // Așa arată res.text (nu este parsat)
    std::cout << std::endl << "======== res.text neparsat =========" << std::endl;
    std::cout << res.text;
    std::cout << "======================" << std::endl;

    // Pentru a ne ușura munca cu JSON-ul primit de la API este recomandat să îl parsăm.
    nlohmann::json json = nlohmann::json::parse(res.text);

    // Acum putem folosi mult mai ușor datele primite folosind următoarea sintaxă: json["un_nume_de_câmp].get<tip_de_date>();
    std::string fact = json["text"].get<std::string>(); // accesăm câmpul "text" și îi facem convert la string

    std::cout << "Uite un random fact: " << fact;
}




/*
    << OBSERVAȚIE >>
        Modul în care sunt făcute request-urile la API-ul din funcția ShowGithubAccountData() este supus unui rate
    limit deoarece facem request-uri fără să folosim un key/token. Pentru a mări acest rate limit este necesar să
    facem request-urile folosind un token.

        Mai multe detalii despre creșterea rate limit-ului se pot găsi în documentația oficială a API-ului.
    https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api?apiVersion=2022-11-28#getting-a-higher-rate-limit

        Pentru testare mai avansată, am putea să facem mocking, adică să simulăm cererile către API cu ajutorul unor fișiere locale.
        Exemplu: https://github.com/Bogdanctx/Radar-Contact
*/
void ShowGithubAccountData(const std::string& user)
{
    /*
        API-ul   https://api.github.com/users/{{username}}   ne dă informații legate de un utilizator al platformei GitHub
        având username-ul 'user'.

        Printre toate câmpurile returnat de API, cele de jos reprezintă doar câteva:

        {
            name: "...",
            public_repos: ...,
            followers: ...,
            following: ...,
            created_at: "...",
        }
    */

    cpr::Url api_link = "https://api.github.com/users/" + user; // Link-ul către API

    // Setăm header-ul
    cpr::Header header = {
        {"Content-Type", "application/json"}
    };


    // Adăugăm timeout la request, deoarece pot exista situații când durează foarte mult.
    const int miliseconds = 2000;
    cpr::Response res = cpr::Get(api_link, header, cpr::Timeout{miliseconds}); // Facem o cerere la API

    if(res.elapsed * 1000 > miliseconds)
    {
        std::cout << "Request timeout" << std::endl;
        return;
    }
    if(res.status_code != 200) // Dacă status code-ul nu este 200 înseamnă că a apărut o eroare
    {
        std::cout << "Oops!!" << std::endl;
        return;
    }
    if(res.text.empty())
    {
        std::cout << "Empty response" << std::endl;
        return;
    }

    nlohmann::json json = nlohmann::json::parse(res.text); // Parsăm răspunsul primit

    if(json.contains("status")) // Dacă JSON-ul are câmpul 'status' înseamnă că a apărut o eroare
    {
        std::string status_code = json["status"].get<std::string>();
        std::string message = json["message"].get<std::string>();

        std::cout << "API-ul a returnat status code-ul " << status_code << " avand mesajul: " << message << std::endl;
        return;
    }

    int public_repos = json["public_repos"].get<int>();
    int followers = json["followers"].get<int>();
    int following = json["following"].get<int>();
    std::string created_at = json["created_at"].get<std::string>();

    std::cout << "Utilizatorul " << user << " are urmatoarele date:" << std::endl;
    std::cout << "=> Are " << public_repos << " repository-uri publice." << std::endl;
    std::cout << "=> Are " << followers << " urmaritori." << std::endl;
    std::cout << "=> Urmareste " << following << " persoane." << std::endl;
    std::cout << "=> Contul a fost creat la data " << created_at << '.' << std::endl;
}

int main()
{
    std::cout << std::endl << "================= Random Fact =================" << std::endl;
    ShowRandomFact();

    std::cout << std::endl;

    std::cout << std::endl << "================= Date GitHub =================" << std::endl;

    std::string user;
    std::cout << "Introdu un nume: "; std::cin >> user;

    ShowGithubAccountData(user);

    return 0;
}
