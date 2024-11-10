#include <gtest/gtest.h>
#include "BankAccount.h"

/// Acest fixture inițializează o instanță a clasei
/// BankAccount ce va fi folosită in toate testele din această suită

class BankAccountTest : public ::testing::Test {
protected:
    BankAccountTest() : account("John Doe", 100.0) {}

    BankAccount account;
};

TEST_F(BankAccountTest, InitialBalanceIsSetCorrectly) {
    EXPECT_EQ(account.GetBalance(), 100.0);
    EXPECT_EQ(account.GetOwner(), "John Doe");
}

TEST_F(BankAccountTest, DepositIncreasesBalance) {
    account.Deposit(50.0);
    EXPECT_EQ(account.GetBalance(), 150.0);
}

TEST_F(BankAccountTest, DepositNegativeAmountThrowsException) {
    EXPECT_THROW(account.Deposit(-10.0), std::invalid_argument);
}

TEST_F(BankAccountTest, WithdrawDecreasesBalance) {
    account.Withdraw(30.0);
    EXPECT_EQ(account.GetBalance(), 70.0);
}

TEST_F(BankAccountTest, WithdrawMoreThanBalanceThrowsException) {
    EXPECT_THROW(account.Withdraw(150.0), std::invalid_argument);
}

TEST_F(BankAccountTest, WithdrawNegativeAmountThrowsException) {
    EXPECT_THROW(account.Withdraw(-20.0), std::invalid_argument);
}
