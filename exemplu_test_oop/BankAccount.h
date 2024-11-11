#ifndef BANKACCOUNT_H
#define BANKACCOUNT_H

#include <string>

class BankAccount {
    std::string owner;
    double balance;
public:
    BankAccount(std::string owner, double initialBalance);

    // cppcheck-suppress unusedFunction
    void Deposit(double amount);
    // cppcheck-suppress unusedFunction
    void Withdraw(double amount);

    // cppcheck-suppress unusedFunction
    [[nodiscard]] double GetBalance() const;
    // cppcheck-suppress unusedFunction
    [[nodiscard]] std::string GetOwner() const;
};

#endif //BANKACCOUNT_H
