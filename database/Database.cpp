#include <iostream>
#include "Database.h"

Database::Database(const bool& with_drop_tables) {
    connString = "dbname=oop_db user=oop password=ooppa55 hostaddr=127.0.0.1 port=5432 connect_timeout=10";
    connection = std::make_unique<pqxx::connection>(connString);
    if (!connection->is_open())
        throw std::runtime_error("Database exists but a connection couldn't be established");
    if (with_drop_tables) { dropTables(); }
    createTables();
}

Database::~Database() {
    if (connection) {
        connection->close();
    }
    connection = nullptr;
}

Database &Database::getDatabaseInstance(const bool& with_drop_tables) {
    static Database databaseInstance(with_drop_tables);
    return databaseInstance;
}

void Database::createTables(){
    pqxx::work transaction(*connection);

    std::string create_table_querry = R"(
        CREATE TABLE IF NOT EXISTS USERS (
                id SERIAL PRIMARY KEY,
                name VARCHAR(20) NOT NULL,
                password VARCHAR(20) NOT NULL
        )
    )";

    transaction.exec(create_table_querry);
    transaction.commit();
}

void Database::dropTables(){
    pqxx::work transaction(*connection);
    std::string drop_table_query = R"(
        DROP TABLE IF EXISTS USERS
    )";

    transaction.exec(drop_table_query);
    transaction.commit();
}

void Database::addUser() {
    pqxx::work transaction(*connection);
    std::string insertUserQuery = R"(
        INSERT INTO USERS (name, password) VALUES ('Test', 'TEST');
    )";
    transaction.exec(insertUserQuery);
    transaction.commit();
}

std::vector<std::tuple<std::string,std::string>> Database::showUsers() {
    pqxx::work transaction(*connection);
    std::vector<std::tuple<std::string,std::string>> result;
    const auto queryResult = transaction.exec_params("SELECT * FROM USERS");
    for (const auto &row : queryResult)
    {
        result.push_back({row[1].as<std::string>(),row[2].as<std::string>()});
    }
    return result;
}
