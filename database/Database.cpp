#include "Database.h"

Database::Database(const bool& with_create_tables, const bool& with_delete_tables) {
    connString = "Host=localhost;Username=postgres;Password=root;Database=oop";
    connection = std::make_unique<pqxx::connection>(connString);
    if (!connection->is_open())
        throw std::runtime_error("Database exists but a connection couldn't be established");
    if (with_create_tables == true) { createTables(); return; }
    if (with_delete_tables == true) { dropTables(); createTables(); return; }
}

Database::~Database() {
    if (connection) {
        connection->close();
    }
    connection = nullptr;
}

Database &Database::getDatabaseInstance(const bool& with_create_tables, const bool& with_delete_tables) {
    static Database databaseInstance(with_create_tables, with_delete_tables);
    return databaseInstance;
}

void Database::createTables(){
    pqxx::work transaction(*connection);

    std::string create_table_querry = R"(
        CREATE TABLE IF NOT EXISTS USERS (
                id SERIAL PRIMARY KEY,
                name VARCHAR2(20) NOT NULL,
                password VARCHAR2(20) NOT NULL
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
