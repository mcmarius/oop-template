#include <gtest/gtest.h>

TEST(SampleTest, Test1)
{
  ASSERT_EQ(1, 1);
}

TEST(SampleTest, Test2)
{
  ASSERT_NE(2, 1);
}

int main(int argc, char **argv) {
  testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}