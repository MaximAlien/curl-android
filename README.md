# curl-android

To test  .so library on Android device:
$ cd test-app
$ ndk-build NDK_APPLICATION_MK=./jni/Application.mk
$ cd obj/
$ adb push test.out /data/local/tmp
$ adb push libcurl.so /data/local/tmp/
$ adb push libssl.so /data/local/tmp/
$ adb push libcrypto.so /data/local/tmp/
$ adb shell
$ cd /data/local/tmp/
$ export LD_LIBRARY_PATH=.
$ ./test.out
