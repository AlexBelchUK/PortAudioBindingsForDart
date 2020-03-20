#pragma once

#include "portaudio.h"
#include "dart_api.h"
#include "dart_native_api.h"

#ifdef PORT_AUDIO_HELPER_EXPORTS
#define PORT_AUDIO_HELPER_API __declspec(dllexport)
#else
#define PORT_AUDIO_HELPER_API 
#endif

extern "C" PORT_AUDIO_HELPER_API PaStreamCallback* Pah_GetStreamCallback(Dart_Port sendPort);
extern "C" PORT_AUDIO_HELPER_API void Pah_SetStreamResult(int64_t result);
extern "C" PORT_AUDIO_HELPER_API PaStreamFinishedCallback* Pah_GetStreamFinishedCallback(Dart_Port sendPort);
