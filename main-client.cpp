#include <cstdlib>
// #define CPPHTTPLIB_OPENSSL_SUPPORT
#include <httplib.h>

int main() {
    // HTTP
    std::string url = "http://127.0.0.1:8080";
    if(const char* url_chr = std::getenv("SERVER_URL"))
        url = url_chr;
    httplib::Client cli(url);

    auto res = cli.Get("/hi");
    std::cout << "[client] Got status " << res->status << "\n";
    std::cout << "[client] Got body " << res->body << "\n";
}
