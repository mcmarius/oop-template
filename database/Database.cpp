#include <iostream>
#include "Database.h"

Database::Database(const bool& withDropTables) {
    setConnectionString();
    connString = "dbname=oop_db user=oop password=ooppa55 hostaddr=127.0.0.1 port=5432 connect_timeout=10";
    connection = std::make_unique<pqxx::connection>(connString);
    if (!connection->is_open())
        throw std::runtime_error("Database exists but a connection couldn't be established");
    if (withDropTables) { dropTables(); }
    createTables();
}

Database::~Database() {
    if (connection) {
        connection->close();
    }
    connection = nullptr;
}

Database &Database::getDatabaseInstance(const bool& withDropTables) {
    static Database databaseInstance(withDropTables);
    return databaseInstance;
}

void Database::createTables(){
    pqxx::work transaction(*connection);

    std::string createTableQuery = R"(
        CREATE TABLE IF NOT EXISTS USERS (
                id SERIAL PRIMARY KEY,
                name VARCHAR(20) NOT NULL,
                password VARCHAR(20) NOT NULL
        )
    )";

    transaction.exec(createTableQuery);
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

void Database::addUser(std::string name, std::string password) {
    pqxx::work transaction(*connection);
    std::string insertUserQuery = "INSERT INTO USERS (name, password) VALUES ($1, $2);";
    transaction.exec_params(insertUserQuery, name, password);
    transaction.commit();
}

std::vector<std::tuple<std::string,std::string>> Database::showAllUsers() {
    pqxx::work transaction(*connection);
    std::vector<std::tuple<std::string,std::string>> result;
    const auto queryResult = transaction.exec_params("SELECT * FROM USERS");
    for (const auto &row : queryResult)
    {
        result.push_back({row[1].as<std::string>(),row[2].as<std::string>()});
    }
    return result;
}

std::tuple<std::string,std::string> Database::showUser(std::string name) {
    pqxx::work transaction(*connection);
    std::vector<std::tuple<std::string,std::string>> result;
    const auto queryResult = transaction.exec_params("SELECT * FROM USERS WHERE name = $1", name);
    return {queryResult[0][1].as<std::string>(),queryResult[0][2].as<std::string>()};
}

void Database::deleteUser(std::string name) {
    pqxx::work transaction(*connection);
    std::string deleteUserQuery = R"(
        DELETE FROM USERS WHERE name = $1;
    )";
    transaction.exec_params(deleteUserQuery,name);
    transaction.commit();
}

void Database::updateUserPassword(std::string name, std::string newPassword) {
    pqxx::work transaction(*connection);
    std::string updateUserPasswordQuery = R"(
        UPDATE USERS
        SET password = $1
        WHERE name = $2;)";
    transaction.exec_params(updateUserPasswordQuery,newPassword, name);
    transaction.commit();
}

void Database::setConnectionString() {
     connString = "dbname=" + std::string(std::getenv("DB_NAME")) +
                             " user=" + std::string(std::getenv("DB_USER")) +
                             " password=" + std::string(std::getenv("DB_PASSWORD")) +
                             " hostaddr=" + std::string(std::getenv("DB_HOSTADDR")) +
                             " port=" + std::string(std::getenv("DB_PORT")) +
                             " connect_timeout=" + std::string(std::getenv("DB_CONNECT_TIMEOUT"));
}
