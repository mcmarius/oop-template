#ifndef OOP_DATABASE_H
#define OOP_DATABASE_H

#include <pqxx/pqxx>

class Database {
    std::unique_ptr<pqxx::connection> connection;
    std::string connString;

    Database (const bool&);

    ~Database ();

    void setConnectionString();
public:
    Database(const Database &) = delete;

    Database &operator=(const Database &) = delete;

    Database(Database &&) = delete;

    Database &operator=(Database &&) = delete;

    static Database &getDatabaseInstance(const bool& withDropTables = false);

    void createTables();

    void dropTables();

    void addUser(std::string, std::string);

    std::vector<std::tuple<std::string,std::string>> showAllUsers();

    std::tuple<std::string, std::string> showUser(std::string);

    void deleteUser(std::string);

    void updateUserPassword(std::string, std::string);
};


#endif //OOP_DATABASE_H
