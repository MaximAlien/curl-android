# curl-android

Before running ./build.sh make sure you have all dependencies. At least on my Linux Ubuntu machine I had to install:  
$ sudo apt-get install autoconf  

Also make sure you have selected correct path to Android NDK.  

openssl and crypto libraries/includes can be found in openssl folder.  
curl libraries/includes can be found in build/curl/arm64-v8a folder.  

To test .so library on Android device (for dynamically linked curl):  
$ cd test-app  
$ ndk-build NDK_APPLICATION_MK=./jni/Application.mk  
$ cd obj/local/arm64-v8a/  
$ adb push test.out /data/local/tmp/  
$ adb push libcurl.so /data/local/tmp/  
$ adb push libssl.so /data/local/tmp/  
$ adb push libcrypto.so /data/local/tmp/  
$ adb shell  
$ cd /data/local/tmp/  
$ export LD_LIBRARY_PATH=.  
$ ./test.out  

Example output:  
$ ./test.out  
Sending cURL request...
*   Trying 172.217.168.228:443...
* TCP_NODELAY set
* Connected to www.google.com (172.217.168.228) port 443 (#0)
* ALPN, offering http/1.1
* Cipher selection: ALL:!EXPORT:!EXPORT40:!EXPORT56:!aNULL:!LOW:!RC4:@STRENGTH
* SSL certificate problem: unable to get local issuer certificate
* Closing connection 0
