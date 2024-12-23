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

    void addUser(const std::string&, const std::string&);

    std::vector<std::tuple<std::string,std::string>> showAllUsers();

    std::tuple<std::string, std::string> showUser(const std::string&);

    void deleteUser(const std::string&);

    void updateUserPassword(const std::string&, const std::string&);
};


#endif //OOP_DATABASE_H
