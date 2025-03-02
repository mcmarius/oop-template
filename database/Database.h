#ifndef OOP_DATABASE_H
#define OOP_DATABASE_H

#include <pqxx/pqxx>

class Database {
    std::unique_ptr<pqxx::connection> connection;
    std::string connString;

    Database (const bool&);
    ~Database ();
public:
    Database(const Database &) = delete;

    Database &operator=(const Database &) = delete;

    Database(Database &&) = delete;

    Database &operator=(Database &&) = delete;

    static Database &getDatabaseInstance(const bool& with_drop_tables = false);

    void createTables();

    void dropTables();

    void addUser();

    std::vector<std::tuple<std::string,std::string>> showUsers();
};


#endif //OOP_DATABASE_H
