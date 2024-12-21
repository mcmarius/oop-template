#include "Database.h"

Database::Database(const bool& with_delete_tables) {
    connString = "dbname=oop_db user=oop password=ooppa55 host=127.0.0.1 port=5432";
    connection = std::make_unique<pqxx::connection>(connString);
    if (!connection->is_open())
        throw std::runtime_error("Database exists but a connection couldn't be established");
    if (with_delete_tables) { dropTables(); createTables(); }
    else createTables();
}

Database::~Database() {
    if (connection) {
        connection->close();
    }
    connection = nullptr;
}

Database &Database::getDatabaseInstance(const bool& with_delete_tables) {
    static Database databaseInstance(with_delete_tables);
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
