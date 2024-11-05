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

void RandomFact()
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

    cpr::Response res = cpr::Get(api_link, header); // Facem o cerere la API

    if(res.status_code != 200) // Dacă status code-ul nu este 200 înseamnă că a apărut o eroare
    {
        std::cout << "Oops!!" << std::endl;
    }


    // res.text este doar un string cu datele descărcate din API.

    // Așa arată res.text (nu este parsat)
    std::cout << std::endl << "======== res.text neparsat =========" << std::endl;
    std::cout << res.text;
    std::cout << "======================" << std::endl;

    // Pentru a ne ușura munca cu JSON-ul primit de la API este recomandat să îl parsăm.
    nlohmann::json json = nlohmann::json::parse(res.text);

    // Acum putem accesa datele folosind variabila 'json' cu json["nume_camp"]
    std::string fact = json["text"].get<std::string>(); // accesăm câmpul "text" și îi facem convert la string

    std::cout << "Uite un random fact: " << fact;
}

void Trivia(int numar_intrebari)
{
    /*
        API-ul   https://opentdb.com/api.php?amount={{numar_intrebari}}   ne dă următorul JSON
        Documentația API-ului se află aici: https://opentdb.com/api_config.php

        {
            "response_code": 0,
            "results": [
                {
                    "type": "...",
                    "difficulty": "...",
                    "category": "...",
                    "question": "...",
                    "correct_answer": "...",
                    "incorrect_answers": [
                        "...",
                        "...",
                        "..."
                    ]
                },
            ]
        }

        De exemplu, dacă numar_intrebari = 2, atunci API-ul returnează următorul JSON

        {
            "response_code": 0,
            "results": [
                {
                    "type": "multiple",
                    "difficulty": "easy",
                    "category": "Entertainment: Video Games",
                    "question": "Rincewind from the 1995 Discworld game was voiced by which member of Monty Python?",
                    "correct_answer": "Eric Idle",
                    "incorrect_answers": [
                        "John Cleese",
                        "Terry Gilliam",
                        "Michael Palin"
                    ]
                },
                {
                    "type": "boolean",
                    "difficulty": "hard",
                    "category": "Entertainment: Music",
                    "question": "The singer Billie Holiday was also known as &quot;Lady Day&quot;.",
                    "correct_answer": "True",
                    "incorrect_answers": [
                        "False"
                    ]
                }
            ]
        }

    */

    cpr::Url api_link = "https://opentdb.com/api.php?amount=" + std::to_string(numar_intrebari); // Link-ul către API

    // Înainte de a face un request la un API trebuie să specificăm în header cum vrem să primim răspunsul (Content-Type), deoarece
    // pot exista API-uri care nu întorc neapărat un JSON (de exemplu, unele pot returna un XML).

    cpr::Header header = {
        {"Content-Type", "application/json"}
    };

    cpr::Response res = cpr::Get(api_link); // Facem o cerere la API

    if(res.status_code != 200) // Dacă status code-ul nu este 200 înseamnă că a apărut o eroare
    {
        std::cout << "A aparut o eroare!";
        return;
    }

    // Parsăm răspunsul primit de la API
    nlohmann::json json = nlohmann::json::parse(res.text);

    int response_code = json["response_code"].get<int>();
    std::cout << response_code << std::endl;
    if(response_code != 0)
    {
        std::cout << "Eroare. API-ul a dat response code " << response_code << std::endl;
        std::cout << "Verifica documentatia pentru mai multe informatii" << std::endl;
    }

    // Luăm fiecare întrebare din câmpul "results"
    for(const nlohmann::basic_json<>& result: json["results"]) {
        std::cout << "Intrebarea este: " << result["question"] << std::endl;

        std::cout << "Variante de raspuns: " << std::endl;

        std::vector<std::string> variante_raspuns;

        // Următoarele două variante sunt echivalente
        /*

        ======== VARIANTA 1 ======
        for(const nlohmann::basic_json<>& answer: json["results"]["incorrect_answers"])
        {
            variante_raspuns.push_back(answer.get<std::string>());
        }
        variante_raspuns.push_back(json["results"]["incorrect_answers"]);
        ==========================


        ======== VARIANTA 2 =======
        for(const nlohmann::basic_json<>& answer: result["incorrect_answers"]) {
            variante_raspuns.push_back(answer.get<std::string>());
        }
        variante_raspuns.push_back(result["correct_answer"]);
        ===========================

        */

        // Vom folosi varianta 2, sintaxa acesteia fiind mai ușoară.
        for(const nlohmann::basic_json<>& answer: result["incorrect_answers"]) {
            variante_raspuns.push_back(answer.get<std::string>());
        }
        variante_raspuns.push_back(result["correct_answer"]);

        // Ar trebui să amestecăm (shuffle) datele din variante_raspuns.

        for(const std::string& raspuns: variante_raspuns) {
            std::cout << raspuns << std::endl;
        }

        std::string raspuns;
        std::cout << "Raspunsul tau este: "; std::cin >> raspuns;

        if(raspuns == result["correct_answer"].get<std::string>()) { // sau echivalent: raspuns == json["results"]["correct_answer"]
            std::cout << "Ai raspuns corect!" << std::endl;
        }
        else {
            std::cout << "Ai raspuns gresit! Raspunsul corect era " << result["correct_answer"].get<std::string>() << std::endl;
        }

        std::cout << std::endl;
    }
}

int main()
{
    RandomFact();

    std::cout << std::endl << "================= Trivia =================" << std::endl;

    Trivia(2);

    return 0;
}
