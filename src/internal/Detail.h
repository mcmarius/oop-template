#ifndef DETAIL_H
#define DETAIL_H

// Implementation-only header. It lives under src/, so it is:
//   * not installed (only the HEADERS file set below include/ is exported),
//   * not on the include path of anyone linking against the library.
// Library sources include it as "internal/Detail.h".
class Detail {
    int x = 1;
    int y = 2;
    void f() const;
public:
    void g();
};

#endif // DETAIL_H
