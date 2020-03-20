// port_audio_helper.cpp : This file contains helper functions
#include "pch.h"
#include <iostream>
#include <mutex>      
#include <condition_variable> 
#include "port_audio_helper.h"

#define MESSAGE_TYPE_FINISH 0
#define MESSAGE_TYPE_CALLBACK 1

static Dart_Port Pah_StreamCallbackSendPort = 0;
static int64_t Pah_StreamCallbackResult = 0;
static std::mutex Pah_StreamCallbackMutex;
static std::condition_variable Pah_StreamCallbackConditionVariable;
static bool Pah_StreamCallbackReady = false;

static Dart_Port Pah_StreamFinishedCallbackSendPort = 0;

/*
* Callback method used to post messages to dart isolate thread
* listening on a port
*/
static int Pah_StreamCallback(const void* input,
                              void* output,
                              unsigned long frameCount,
                              const PaStreamCallbackTimeInfo* timeInfo,
                              PaStreamCallbackFlags statusFlags,
                              void* userData) {
    Dart_CObject dartCObject;
    Dart_CObject dartCObjectArray[7];
    Dart_CObject* dartCObjectPtr[7];
    
    std::unique_lock<std::mutex> lock(Pah_StreamCallbackMutex);
    
    dartCObjectArray[0].type = Dart_CObject_kInt32;
    dartCObjectArray[0].value.as_int32 = MESSAGE_TYPE_CALLBACK;

    dartCObjectArray[1].type = Dart_CObject_kInt64;
    dartCObjectArray[1].value.as_int64 = (int64_t)input;

    dartCObjectArray[2].type = Dart_CObject_kInt64;
    dartCObjectArray[2].value.as_int64 = (int64_t)output;

    dartCObjectArray[3].type = Dart_CObject_kInt32;
    dartCObjectArray[3].value.as_int32 = frameCount;

    dartCObjectArray[4].type = Dart_CObject_kInt64;
    dartCObjectArray[4].value.as_int64 = (int64_t)timeInfo;

    dartCObjectArray[5].type = Dart_CObject_kInt32;
    dartCObjectArray[5].value.as_int32 = statusFlags;

    dartCObjectArray[6].type = Dart_CObject_kInt64;
    dartCObjectArray[6].value.as_int64 = (int64_t)userData;

    for (int i = 0; i < 7; i++) {
        dartCObjectPtr[i] = &dartCObjectArray[i];
    }

    dartCObject.type = Dart_CObject_kArray;
    dartCObject.value.as_array.length = 7;
    dartCObject.value.as_array.values = dartCObjectPtr;

    if (!Dart_PostCObject(Pah_StreamCallbackSendPort, &dartCObject)) {
        std::cout << "Pah_StreamCallback: Failed to post object to dart\n";
    }

    // Wait for result to be set in the PahSetStreamResult function    
    Pah_StreamCallbackReady = false;
    while (!Pah_StreamCallbackReady) {
        Pah_StreamCallbackConditionVariable.wait(lock);
    }

    return (int) Pah_StreamCallbackResult;
}

/*
* Return callback handler and store send port number used to send messages
*/
PaStreamCallback* Pah_GetStreamCallback(Dart_Port sendPort) {
    Pah_StreamCallbackSendPort = sendPort;
    return &Pah_StreamCallback;
}

/*
* Set result, signal wait in PahStreamCallback() function to return
*/
void Pah_SetStreamResult(int64_t result) {
    std::unique_lock<std::mutex> lock(Pah_StreamCallbackMutex);

    Pah_StreamCallbackResult = result;
    Pah_StreamCallbackReady = true;
    Pah_StreamCallbackConditionVariable.notify_all();
}

/*
* Called from port audio, posts user data pointer address to the
* Dart isolate listening on the finished callback port
*/
static void Pah_StreamFinishedCallback(void* userData) {
    Dart_CObject dartCObject;
    Dart_CObject dartCObjectArray[2];
    Dart_CObject* dartCObjectPtr[2];

    dartCObjectArray[0].type = Dart_CObject_kInt32;
    dartCObjectArray[0].value.as_int32 = MESSAGE_TYPE_FINISH;

    dartCObjectArray[1].type = Dart_CObject_kInt64;
    dartCObjectArray[1].value.as_int64 = (int64_t)userData;

    for (int i = 0; i < 2; i++) {
        dartCObjectPtr[i] = &dartCObjectArray[i];
    }

    dartCObject.type = Dart_CObject_kArray;
    dartCObject.value.as_array.length = 2;
    dartCObject.value.as_array.values = dartCObjectPtr;

    if (!Dart_PostCObject(Pah_StreamFinishedCallbackSendPort, &dartCObject)) {
        std::cout << "Pah_StreamFinishedCallback: Failed to post object to dart\n";
    }
}

/*
* Stores the port used to send stream finished callback on
* returns a pointer to a function that can be passed on the dart
* side into the callback function
*/
PaStreamFinishedCallback* Pah_GetStreamFinishedCallback(Dart_Port sendPort) {
    Pah_StreamFinishedCallbackSendPort = sendPort;
    return &Pah_StreamFinishedCallback;
}
