#ifndef DETAIL_H
#define DETAIL_H

// Implementation-only header: not shipped (only include/ is exported) and not on the include
// path of anyone linking the library. Library sources include it as "internal/Detail.h".
class Detail {
    int x = 1;
    int y = 2;
    void f() const;
public:
    void g();
};

#endif // DETAIL_H
