#include "BankAccount.h"
#include <ut.hpp>
#include <stdexcept>

boost::ut::suite oop_test_suite = [] {
    using namespace boost::ut;

    "Initial Balance Is Set Correctly"_test = [] {
        const BankAccount account("John Doe", 100.0);
        expect(account.GetBalance() == 100.0_d);
        expect(account.GetOwner() == "John Doe");
    };

    "Deposit Increases Balance"_test = [] {
        BankAccount account("John Doe", 100.0);
        account.Deposit(50.0);
        expect(account.GetBalance() == 150.0_d);
    };

    "Deposit Negative Amount Throws Exception"_test = [] {
        BankAccount account("John Doe", 100.0);
        expect(throws<std::invalid_argument>([&] { account.Deposit(-10.0); }));
    };

    "Withdraw Decreases Balance"_test = [] {
        BankAccount account("John Doe", 100.0);
        account.Withdraw(30.0);
        expect(account.GetBalance() == 70.0_d);
    };

    "Withdraw More Than Balance Throws Exception"_test = [] {
        BankAccount account("John Doe", 100.0);
        expect(throws<std::invalid_argument>([&] { account.Withdraw(150.0); }));
    };

    "Withdraw Negative Amount Throws Exception"_test = [] {
        BankAccount account("John Doe", 100.0);
        expect(throws<std::invalid_argument>([&] { account.Withdraw(-20.0); }));
    };
};
