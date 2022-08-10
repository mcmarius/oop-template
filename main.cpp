#include <iostream>

int main() {
    int v[2];
    v[10] = 4;
    std::cout << "Hello, world!\n";
    std::cout << v[11] << "\n";
    int *q = new int[12];
    std::cout << q[4] << "\n";
    return 0;
}
