#include <iostream>
#include "Database.h"

Database::Database(const bool& with_drop_tables) {
    connString = "dbname=oop_db user=oop password=ooppa55 hostaddr=127.0.0.1 port=5432 connect_timeout=10";
    std::cout<< std::flush;
    std::cout << connString;
    connection = std::make_unique<pqxx::connection>(connString);
    std::cout<< std::flush;
    std::cout << "connectionMade\n";
    if (!connection->is_open())
        throw std::runtime_error("Database exists but a connection couldn't be established");
    if (with_drop_tables) { dropTables(); }
    createTables();
    std::cout <<std::flush;
    std::cout <<"database constructor finished";
}

Database::~Database() {
    if (connection) {
        connection->close();
    }
    connection = nullptr;
}

Database &Database::getDatabaseInstance(const bool& with_drop_tables) {
    std::cout<< std::flush;
    std::cout<< with_drop_tables;
    std::cout<< "getdatabaseIntance\n";
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
