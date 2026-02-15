#include <iostream>

#include "Database.h"

Database::Database(const bool& withDropTables) {
    setConnectionString();
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
                password VARCHAR(255) NOT NULL
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

void Database::addUser(const std::string& name, const std::string& password) {
    pqxx::work transaction(*connection);
    std::string hashQuery = "SELECT crypt($1, gen_salt('bf')) AS hashed_password;";
    pqxx::result hashResult = transaction.exec_params(hashQuery,password);
    std::string hashedPassword = hashResult[0]["hashed_password"].c_str();
    std::string insertUserQuery = "INSERT INTO USERS (name, password) VALUES ($1, $2);";
    transaction.exec_params(insertUserQuery, name, hashedPassword);
    transaction.commit();
}

std::vector<std::tuple<std::string,std::string>> Database::showAllUsers() {
    pqxx::work transaction(*connection);
    std::vector<std::tuple<std::string,std::string>> result;
    const auto queryResult = transaction.exec_params("SELECT * FROM USERS");
    for (const auto &row : queryResult)
    {
        result.emplace_back(row[1].as<std::string>(),row[2].as<std::string>());
    }
    return result;
}

std::tuple<std::string,std::string> Database::showUser(const std::string& name) {
    pqxx::work transaction(*connection);
    std::vector<std::tuple<std::string,std::string>> result;
    const auto queryResult = transaction.exec_params("SELECT * FROM USERS WHERE name = $1", name);
    return {queryResult[0][1].as<std::string>(),queryResult[0][2].as<std::string>()};
}

void Database::deleteUser(const std::string& name) {
    pqxx::work transaction(*connection);
    std::string deleteUserQuery = R"(
        DELETE FROM USERS WHERE name = $1;
    )";
    transaction.exec_params(deleteUserQuery,name);
    transaction.commit();
}

void Database::updateUserPassword(const std::string& name, const std::string& newPassword) {
    pqxx::work transaction(*connection);
    std::string hashQuery = "SELECT crypt($1, gen_salt('bf')) AS hashed_password;";
    pqxx::result hashResult = transaction.exec_params(hashQuery,newPassword);
    std::string hashedPassword = hashResult[0]["hashed_password"].c_str();
    std::string updateUserPasswordQuery = R"(
        UPDATE USERS
        SET password = $1
        WHERE name = $2;)";
    transaction.exec_params(updateUserPasswordQuery,hashedPassword, name);
    transaction.commit();
}

void Database::setConnectionString() {
     connString = "dbname=" + std::string(getenv("DATABASE_NAME") ? getenv("DATABASE_NAME") : "''") +
                  " user=" + std::string(getenv("DATABASE_USER") ? getenv("DATABASE_USER") : "''") +
                  " password=" + std::string(getenv("DATABASE_PASSWORD") ?
                                        getenv("DATABASE_PASSWORD") : "''") +
                  " hostaddr=" + std::string(getenv("DATABASE_HOSTADDR") ?
                                        getenv("DATABASE_HOSTADDR") : "127.0.0.1") +
                  " port=" + std::string(getenv("DATABASE_PORT") ? getenv("DATABASE_PORT") : "5432") +
                  " connect_timeout=" + std::string(getenv("DATABASE_CONNECT_TIMEOUT") ?
                                        getenv("DATABASE_CONNECT_TIMEOUT") : "10");
}
