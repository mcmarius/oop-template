#ifndef BANKACCOUNT_H
#define BANKACCOUNT_H

#include <string>

class BankAccount {
    std::string owner;
    double balance;
public:
    BankAccount(std::string owner, double initialBalance);

    void Deposit(double amount);

    void Withdraw(double amount);

    [[nodiscard]] double GetBalance() const;

    [[nodiscard]] std::string GetOwner() const;
};


#endif //BANKACCOUNT_H
