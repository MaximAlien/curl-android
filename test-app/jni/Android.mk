LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)
LOCAL_MODULE := test.out
LOCAL_SRC_FILES := test.cpp
LOCAL_SHARED_LIBRARIES := curl
include $(BUILD_EXECUTABLE)	

include $(CLEAR_VARS)
LOCAL_MODULE := crypto
LOCAL_SRC_FILES := ../lib/libcrypto.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := ssl
LOCAL_SRC_FILES := ../lib/libssl.so
LOCAL_SHARED_LIBRARIES := crypto
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := curl
LOCAL_SRC_FILES := ../lib/libcurl.so
LOCAL_SHARED_LIBRARIES := ssl
LOCAL_EXPORT_C_INCLUDES := include
include $(PREBUILT_SHARED_LIBRARY)


# LOCAL_PATH := $(call my-dir)
# include $(CLEAR_VARS)
# LOCAL_MODULE := test.out
# LOCAL_SRC_FILES := test.cpp
# LOCAL_STATIC_LIBRARIES := curl
# include $(BUILD_EXECUTABLE)	

# include $(CLEAR_VARS)
# LOCAL_MODULE := crypto
# LOCAL_SRC_FILES := ../lib/libcrypto.a
# include $(PREBUILT_STATIC_LIBRARY)

# include $(CLEAR_VARS)
# LOCAL_MODULE := ssl
# LOCAL_SRC_FILES := ../lib/libssl.a
# LOCAL_STATIC_LIBRARIES := crypto
# include $(PREBUILT_STATIC_LIBRARY)

# include $(CLEAR_VARS)
# LOCAL_MODULE := curl
# LOCAL_SRC_FILES := ../lib/libcurl.a
# LOCAL_STATIC_LIBRARIES := ssl
# LOCAL_EXPORT_C_INCLUDES := include
# include $(PREBUILT_STATIC_LIBRARY)