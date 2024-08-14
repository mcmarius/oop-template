//
// Created by marius on 02.02.2024.
//

#ifndef OOP_ENV_FIXES_H
#define OOP_ENV_FIXES_H

#ifdef __linux__
#include <X11/Xlib.h>
#include <filesystem>
#endif

namespace utils {

void init_threads() {
#ifdef __linux__
    XInitThreads();
#endif
}

std::string file_path(const std::string& file) {
    #ifdef __linux
    namespace fs = std::filesystem;
    if(auto dir = std::getenv("RESOURCES_DIR"))
        return fs::path(dir) / file;
    else
        return file;
    #else
    return file;
    #endif
}

}

#endif //OOP_ENV_FIXES_H
