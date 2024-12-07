#include "BankAccount.h"

#include <stdexcept>
#include <utility>

BankAccount::BankAccount(std::string  owner, const double initialBalance)
    : owner(std::move(owner)), balance(initialBalance) {}

// cppcheck-suppress unusedFunction
void BankAccount::Deposit(const double amount) {
    if (amount < 0) {
        throw std::invalid_argument("Deposit amount cannot be negative");
    }
    balance += amount;
}

// cppcheck-suppress unusedFunction
void BankAccount::Withdraw(const double amount) {
    if (amount < 0) {
        throw std::invalid_argument("Withdrawal amount cannot be negative");
    }
    if (amount > balance) {
        throw std::invalid_argument("Insufficient funds");
    }
    balance -= amount;
}

// cppcheck-suppress unusedFunction
double BankAccount::GetBalance() const {
    return this->balance;
}

// cppcheck-suppress unusedFunction
std::string BankAccount::GetOwner() const {
    return this->owner;
}
