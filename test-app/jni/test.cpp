#include <iostream>
#include <string>
#include <curl.h>

using namespace std;

int main() {

    cout << "Sending cURL request..." << endl;

    CURL *curl = curl_easy_init();
    CURLcode res;
    string readBuffer;

    if (curl) {
        curl_easy_setopt(curl, CURLOPT_URL, "https://www.google.com");
        curl_easy_setopt(curl, CURLOPT_VERBOSE, 1L);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);

        res = curl_easy_perform(curl);

        cout << readBuffer << endl;

        curl_easy_cleanup(curl);
    }

    return 0;
}