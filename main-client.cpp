// #include <cstdlib>
#include <httplib.h>

int main() {
    std::string url = "http://127.0.0.1:8080";
    // configure server url through env variables
    // to avoid recompiling when changing host or port
    // if(const char* url_chr = std::getenv("SERVER_URL")) {
    //     url = url_chr;
    // }
    // client object
    httplib::Client cli(url);

    // send request
    auto res = cli.Get("/hi");
    // process response
    std::cout << "[client] Got status " << res->status << "\n";
    std::cout << "[client] Got body " << res->body << "\n";
    // of course, the client can send/process multiple requests
    // this is just a minimal example
}
