///
/// Port Audio Mappings
///
library port_audio;

import 'dart:ffi';
import 'dart:io' show Platform;
import 'dart:isolate';
import 'package:ffi/ffi.dart';

///
/// Mapping class to native audio library
///
class PortAudio {
  static bool _loaded = false;
  
  // Port Audio Helper Library
  static int Function(void) _PaGetVersion;
  static Pointer<Utf8> Function(void) _PaGetVersionText;
  static Pointer<VersionInfo> Function(void) _PaGetVersionInfo;
  static Pointer<Utf8> Function(int) _PaGetErrorText;
  static int Function(void) _PaInitialize;
  static int Function(void) _PaTerminate;
  static int Function(void) _PaGetHostApiCount;
  static int Function(void) _PaGetDefaultHostApi;
  static Pointer<HostApiInfo> Function(int) _PaGetHostApiInfo;
  static int Function(int) _PaHostApiTypeIdToHostApiIndex;
  static int Function(int, int) _PaHostApiDeviceIndexToDeviceIndex;
  static Pointer<HostErrorInfo> Function(void) _PaGetLastHostErrorInfo;
  static int Function(void) _PaGetDeviceCount;
  static int Function(void) _PaGetDefaultInputDevice;
  static int Function(void) _PaGetDefaultOutputDevice;
  static Pointer<DeviceInfo> Function(int) _PaGetDeviceInfo;
  static int Function(Pointer<StreamParameters>, Pointer<StreamParameters>, double)
      _PaIsFormatSupported;
  static int Function(
      Pointer<Pointer<Void>>,
      Pointer<StreamParameters>,
      Pointer<StreamParameters>,
      double,
      int,
      int,
      Pointer<NativeFunction<StreamCallback>>,
      Pointer<Void>) _PaOpenStream;
  static int Function(
      Pointer<Pointer<Void>>,
      int,
      int,
      int,
      double,
      int,
      Pointer<NativeFunction<StreamCallback>>,
      Pointer<Void>) _PaOpenDefaultStream;
  static int Function(Pointer<Void>) _PaCloseStream;
  static int Function(Pointer<Void>, Pointer<NativeFunction<StreamFinishedCallback>>)
      _PaSetStreamFinishedCallback;
  static int Function(Pointer<Void>) _PaStartStream;
  static int Function(Pointer<Void>) _PaStopStream;
  static int Function(Pointer<Void>) _PaAbortStream;
  static int Function(Pointer<Void>) _PaIsStreamStopped;
  static int Function(Pointer<Void>) _PaIsStreamActive;
  static Pointer<StreamInfo> Function(Pointer<Void>) _PaGetStreamInfo;
  static double Function(Pointer<Void>) _PaGetStreamTime;
  static double Function(Pointer<Void>) _PaGetStreamCpuLoad;
  static int Function(Pointer<Void>, Pointer<Void>, int) _PaReadStream;
  static int Function(Pointer<Void>, Pointer<Void>, int) _PaWriteStream;
  static int Function(Pointer<Void>) _PaGetStreamReadAvailable;
  static int Function(Pointer<Void>) _PaGetStreamWriteAvailable;
  static int Function(int) _PaGetSampleSize;
  static void Function(int) _PaSleep;

  // Port Audio Helper Library
  static Pointer<NativeFunction<StreamCallback>> Function(int) _PahGetStreamCallback;
  static void Function(int) _PahSetStreamResult;
  static Pointer<NativeFunction<StreamFinishedCallback>> Function(int) _PahGetStreamFinishedCallback;
  
  ///
  /// Contructor loads the library and looks up functions
  /// according to their function signtature and name
  ///
  const PortAudio();
  
  static  void _load() {
    
    var bits = 'x64';
    if (sizeOf<IntPtr>() == 4) {
      bits = 'x86';
    }

    // Port Audio Library ----------------------------------------------------

    var paPath = '';
    if (Platform.environment['PORT_AUDIO_LIBRARY'] != null) {
      paPath = Platform.environment['PORT_AUDIO_LIBRARY'];
    } else if (Platform.isWindows) {
      paPath = 'native/windows/portaudio_' + bits + '.dll';
    } else if (Platform.isMacOS) {
      paPath = 'native/mac/libportaudio_' + bits + '.dynlib';
    } else if (Platform.isLinux) {
      paPath = 'native/linux/libportaudio_' + bits + '.so';
    } else {
      throw Exception(
          'PortAudio: Unsupported platform, try specifying environment variable PORT_AUDIO_LIBRARY');
    }

    final paLib = DynamicLibrary.open(paPath);

    _PaGetVersion = paLib
        .lookup<NativeFunction<Int32 Function(Void)>>('Pa_GetVersion')
        .asFunction();

    _PaGetVersionText = paLib
        .lookup<NativeFunction<Pointer<Utf8> Function(Void)>>(
            'Pa_GetVersionText')
        .asFunction();

    _PaGetVersionInfo = paLib
        .lookup<NativeFunction<Pointer<VersionInfo> Function(Void)>>(
            'Pa_GetVersionInfo')
        .asFunction();

    _PaGetErrorText = paLib
        .lookup<NativeFunction<Pointer<Utf8> Function(Int32)>>(
            'Pa_GetErrorText')
        .asFunction();

    _PaInitialize = paLib
        .lookup<NativeFunction<Int32 Function(Void)>>('Pa_Initialize')
        .asFunction();

    _PaTerminate = paLib
        .lookup<NativeFunction<Int32 Function(Void)>>('Pa_Terminate')
        .asFunction();

    _PaGetHostApiCount = paLib
        .lookup<NativeFunction<Int32 Function(Void)>>('Pa_GetHostApiCount')
        .asFunction();

    _PaGetDefaultHostApi = paLib
        .lookup<NativeFunction<Int32 Function(Void)>>('Pa_GetDefaultHostApi')
        .asFunction();

    _PaGetHostApiInfo = paLib
        .lookup<NativeFunction<Pointer<HostApiInfo> Function(Int32)>>(
            'Pa_GetHostApiInfo')
        .asFunction();

    _PaHostApiTypeIdToHostApiIndex = paLib
        .lookup<NativeFunction<Int32 Function(Int32)>>(
            'Pa_HostApiTypeIdToHostApiIndex')
        .asFunction();

    _PaHostApiDeviceIndexToDeviceIndex = paLib
        .lookup<NativeFunction<Int32 Function(Int32, Int32)>>(
            'Pa_HostApiDeviceIndexToDeviceIndex')
        .asFunction();

    _PaGetLastHostErrorInfo = paLib
        .lookup<NativeFunction<Pointer<HostErrorInfo> Function(Void)>>(
            'Pa_GetLastHostErrorInfo')
        .asFunction();

    _PaGetDeviceCount = paLib
        .lookup<NativeFunction<Int32 Function(Void)>>('Pa_GetDeviceCount')
        .asFunction();

    _PaGetDefaultInputDevice = paLib
        .lookup<NativeFunction<Int32 Function(Void)>>(
            'Pa_GetDefaultInputDevice')
        .asFunction();

    _PaGetDefaultOutputDevice = paLib
        .lookup<NativeFunction<Int32 Function(Void)>>(
            'Pa_GetDefaultOutputDevice')
        .asFunction();

    _PaGetDeviceInfo = paLib
        .lookup<NativeFunction<Pointer<DeviceInfo> Function(Int32)>>(
            'Pa_GetDeviceInfo')
        .asFunction();

    _PaIsFormatSupported = paLib
        .lookup<
            NativeFunction<
                Int32 Function(Pointer<StreamParameters>,
                    Pointer<StreamParameters>, Double)>>('Pa_IsFormatSupported')
        .asFunction();

    _PaOpenStream = paLib
        .lookup<
            NativeFunction<
                Int32 Function(
                    Pointer<Pointer<Void>>,
                    Pointer<StreamParameters>,
                    Pointer<StreamParameters>,
                    Double,
                    Int32,
                    Int32,
                    Pointer<NativeFunction<StreamCallback>>,
                    Pointer<Void>)>>('Pa_OpenStream')
        .asFunction();

    _PaOpenDefaultStream = paLib
        .lookup<
            NativeFunction<
                Int32 Function(
                    Pointer<Pointer<Void>>,
                    Int32,
                    Int32,
                    Int32,
                    Double,
                    Int32,
                    Pointer<NativeFunction<StreamCallback>>,
                    Pointer<Void>)>>('Pa_OpenDefaultStream')
        .asFunction();

    _PaCloseStream = paLib
        .lookup<NativeFunction<Int32 Function(Pointer<Void>)>>('Pa_CloseStream')
        .asFunction();

    _PaSetStreamFinishedCallback = paLib
        .lookup<
                NativeFunction<
                    Int32 Function(Pointer<Void>,
                        Pointer<NativeFunction<StreamFinishedCallback>>)>>(
            'Pa_SetStreamFinishedCallback')
        .asFunction();

    _PaStartStream = paLib
        .lookup<NativeFunction<Int32 Function(Pointer<Void>)>>('Pa_StartStream')
        .asFunction();

    _PaStopStream = paLib
        .lookup<NativeFunction<Int32 Function(Pointer<Void>)>>('Pa_StopStream')
        .asFunction();

    _PaAbortStream = paLib
        .lookup<NativeFunction<Int32 Function(Pointer<Void>)>>('Pa_AbortStream')
        .asFunction();

    _PaIsStreamStopped = paLib
        .lookup<NativeFunction<Int32 Function(Pointer<Void>)>>(
            'Pa_IsStreamStopped')
        .asFunction();

    _PaIsStreamActive = paLib
        .lookup<NativeFunction<Int32 Function(Pointer<Void>)>>(
            'Pa_IsStreamActive')
        .asFunction();

    _PaGetStreamInfo = paLib
        .lookup<NativeFunction<Pointer<StreamInfo> Function(Pointer<Void>)>>(
            'Pa_GetStreamInfo')
        .asFunction();

    _PaGetStreamTime = paLib
        .lookup<NativeFunction<Double Function(Pointer<Void>)>>(
            'Pa_GetStreamTime')
        .asFunction();

    _PaGetStreamCpuLoad = paLib
        .lookup<NativeFunction<Double Function(Pointer<Void>)>>(
            'Pa_GetStreamCpuLoad')
        .asFunction();

    _PaReadStream = paLib
        .lookup<
            NativeFunction<
                Int32 Function(
                    Pointer<Void>, Pointer<Void>, Int32)>>('Pa_ReadStream')
        .asFunction();

    _PaWriteStream = paLib
        .lookup<
            NativeFunction<
                Int32 Function(
                    Pointer<Void>, Pointer<Void>, Int32)>>('Pa_WriteStream')
        .asFunction();

    _PaGetStreamReadAvailable = paLib
        .lookup<NativeFunction<Int32 Function(Pointer<Void>)>>(
            'Pa_GetStreamReadAvailable')
        .asFunction();

    _PaGetStreamWriteAvailable = paLib
        .lookup<NativeFunction<Int32 Function(Pointer<Void>)>>(
            'Pa_GetStreamWriteAvailable')
        .asFunction();

    _PaGetSampleSize = paLib
        .lookup<NativeFunction<Int32 Function(Int32)>>('Pa_GetSampleSize')
        .asFunction();

    _PaSleep = paLib
        .lookup<NativeFunction<Void Function(Int32)>>('Pa_Sleep')
        .asFunction();

    // Port Audio Helper Library ---------------------------------------------

    var pahPath = '';
    if (Platform.environment['PORT_AUDIO_HELPER_LIBRARY'] != null) {
      pahPath = Platform.environment['PORT_AUDIO_HELPER_LIBRARY'];
    } else if (Platform.isWindows) {
      pahPath = 'native/windows/port_audio_helper_' + bits + '.dll';
    } else if (Platform.isMacOS) {
      pahPath = 'native/mac/libportaudiohelper_' + bits + '.dynlib';
    } else if (Platform.isLinux) {
      pahPath = 'native/linux/libportaudiohelper_' + bits + '.so';
    } else {
      throw Exception(
          'PortAudio: Unsupported platform, try specifying environment variable PORT_AUDIO_HELPER_LIBRARY');
    }

    final pahLib = DynamicLibrary.open(pahPath);

    _PahGetStreamCallback = pahLib
        .lookup<NativeFunction<Pointer<NativeFunction<StreamCallback>> Function(Int64)>>('Pah_GetStreamCallback')
        .asFunction();

    _PahSetStreamResult = pahLib
        .lookup<NativeFunction<Void Function(Int64)>>('Pah_SetStreamResult')
        .asFunction();

    _PahGetStreamFinishedCallback = pahLib
        .lookup<NativeFunction<Pointer<NativeFunction<StreamFinishedCallback>> Function(Int64)>>('Pah_GetStreamFinishedCallback')
        .asFunction();

    _loaded = true;
  }

  ///
  ///  Retrieve the release number of the currently running PortAudio build.
  ///  For example, for version "19.5.1" this will return 0x00130501.
  ///
  static int getVersion() {
    if (! _loaded) {
      _load();
    }

    return _PaGetVersion(Void);
  }

  ///
  /// Retrieve a textual description of the current PortAudio build,
  /// e.g. "PortAudio V19.5.0-devel, revision 1952M".
  ///
  /// The format of the text may change in the future. Do not try to parse the
  /// returned string.
  ///
  /// As of 19.5.0, use GetVersionInfo()->versionText instead.
  ///
  static String getVersionText() {
    if (! _loaded) {
      _load();
    }

    var textPtr = _PaGetVersionText(Void);
    return Utf8.fromUtf8(textPtr);
  }

  ///
  /// Retrieve version information for the currently running PortAudio build.
  /// A class instance to an immutable PaVersionInfo structure.
  ///
  /// This function can be called at any time. It does not require PortAudio
  /// to be initialized. The structure pointed to is statically allocated.
  ///
  /// See PaVersionInfo
  ///
  static VersionInfo getVersionInfo() {
    if (! _loaded) {
      _load();
    }

    return _PaGetVersionInfo(Void).ref;
  }

  ///
  /// Translate the supplied PortAudio error code into a human readable
  /// message.
  ///
  static String getErrorText(int errorCode) {
    if (! _loaded) {
      _load();
    }

    var textPtr = _PaGetErrorText(errorCode);
    return Utf8.fromUtf8(textPtr);
  }

  ///
  /// Library initialization function - call this before using PortAudio.
  /// This function initializes internal data structures and prepares underlying
  /// host APIs for use.  With the exception of GetVersion(), PGetVersionText()
  /// and GetErrorText(), this function MUST be called before using any other
  /// PortAudio API functions.
  ///
  /// If Initialize() is called multiple times, each successful
  /// call must be matched with a corresponding call to Terminate().
  /// Pairs of calls to Initialize()/Terminate() may overlap, and are not
  /// required to be fully nested.
  ///
  /// Note that if Initialize() returns an error code, Terminate() should
  /// NOT be called.
  /// NoError if successful, otherwise an error code indicating the cause
  /// of failure.
  ///
  /// See Terminate
  ///
  static int initialize() {
    if (! _loaded) {
      _load();
    }

    return _PaInitialize(Void);
  }

  /// Library termination function - call this when finished using PortAudio.
  /// This function deallocates all resources allocated by PortAudio since it was
  /// initialized by a call to Initialize(). In cases where Initialise() has
  /// been called multiple times, each call must be matched with a corresponding call
  /// to Terminate(). The final matching call to Terminate() will automatically
  /// close any PortAudio streams that are still open.
  ///
  /// Terminate() MUST be called before exiting a program which uses PortAudio.
  /// Failure to do so may result in serious resource leaks, such as audio devices
  /// not being available until the next reboot.
  ///
  /// return NoError if successful, otherwise an error code indicating the cause
  /// of failure.
  ///
  /// See Initialize
  ///
  static int terminate() {
    if (! _loaded) {
      _load();
    }

    return _PaTerminate(Void);
  }

  ///
  /// Retrieve the number of available host APIs. Even if a host API is
  /// available it may have no devices available.
  ///
  /// Return a non-negative value indicating the number of available host APIs
  /// or, a PaErrorCode (which are always negative) if PortAudio is not initialized
  /// or an error is encountered.
  ///
  static int getHostApiCount() {
    if (! _loaded) {
      _load();
    }

    return _PaGetHostApiCount(Void);
  }

  ///
  /// Retrieve the index of the default host API. The default host API will be
  /// the lowest common denominator host API on the current platform and is
  /// unlikely to provide the best performance.
  ///
  /// Return a non-negative value ranging from 0 to (GetHostApiCount()-1)
  /// indicating the default host API index or, a PaErrorCode (which are always
  /// negative) if PortAudio is not initialized or an error is encountered.
  ///
  static int getDefaultHostApi() {
    if (! _loaded) {
      _load();
    }

    return _PaGetDefaultHostApi(Void);
  }

  ///
  /// Retrieve a pointer to a structure containing information about a specific
  /// host Api.
  ///
  /// [hostApi] A valid host API index ranging from 0 to (GetHostApiCount()-1)
  ///
  /// Return a pointer to an immutable PaHostApiInfo structure describing
  /// a specific host API. If the hostApi parameter is out of range or an error
  /// is encountered, the function returns NULL.
  ///
  /// The returned structure is owned by the PortAudio implementation and must not
  /// be manipulated or freed. The pointer is only guaranteed to be valid between
  /// calls to Initialize() and Terminate().
  ///
  static HostApiInfo getHostApiInfo(int hostApi) {
    if (! _loaded) {
      _load();
    }

    return _PaGetHostApiInfo(hostApi).ref;
  }

  ///
  /// Convert a static host API unique identifier, into a runtime
  /// host API index.
  /// [type] A unique host API identifier belonging to the PaHostApiTypeId
  /// enumeration.
  ///
  /// Return a valid PaHostApiIndex ranging from 0 to (GetHostApiCount()-1) or,
  /// a PaErrorCode (which are always negative) if PortAudio is not initialized
  /// or an error is encountered.
  ///
  /// The hostApiNotFound error code indicates that the host API specified by the
  /// type parameter is not available.
  ///
  static int hostApiTypeIdToHostApiIndex(int type) {
    if (! _loaded) {
      _load();
    }

    return _PaHostApiTypeIdToHostApiIndex(type);
  }

  ///
  /// Convert a host-API-specific device index to standard PortAudio device index.
  /// This function may be used in conjunction with the deviceCount field of
  /// PaHostApiInfo to enumerate all devices for the specified host API.
  ///
  /// [hostApi] A valid host API index ranging from 0 to (GetHostApiCount()-1)
  ///
  /// [hostApiDeviceIndex] A valid per-host device index in the range
  /// 0 to (GetHostApiInfo(hostApi)->deviceCount-1)
  ///
  /// Return a non-negative PaDeviceIndex ranging from 0 to (GetDeviceCount()-1)
  /// or, a PaErro rCode (which are always negative) if PortAudio is not initialized
  /// or an error is encountered.
  ///
  /// A invalidHostApi error code indicates that the host API index specified by
  /// the hostApi parameter is out of range.
  ///
  /// A invalidDevice error code indicates that the hostApiDeviceIndex parameter
  /// is out of range.
  ///
  static int hostApiDeviceIndexToDeviceIndex(int hostApi, int hostApiDeviceIndex) {
    if (! _loaded) {
      _load();
    }

    return _PaHostApiDeviceIndexToDeviceIndex(hostApi, hostApiDeviceIndex);
  }

  ///
  /// Return information about the last host error encountered. The error
  /// information returned by GetLastHostErrorInfo() will never be modified
  /// asynchronously by errors occurring in other PortAudio owned threads
  /// (such as the thread that manages the stream callback.)
  ///
  /// This function is provided as a last resort, primarily to enhance debugging
  /// by providing clients with access to all available error information.
  ///
  /// Return a pointer to an immutable structure constraining information about
  /// the host error. The values in this structure will only be valid if a
  /// PortAudio function has previously returned the unanticipatedHostError
  /// error code.
  static HostErrorInfo getLastHostErrorInfo() {
    if (! _loaded) {
      _load();
    }

    return _PaGetLastHostErrorInfo(Void).ref;
  }

  ///
  /// Retrieve the number of available devices. The number of available devices
  /// may be zero.
  ///
  /// Return a non-negative value indicating the number of available devices or,
  /// a PaErrorCode (which are always negative) if PortAudio is not initialized
  /// or an error is encountered.
  ///
  static int getDeviceCount() {
    if (! _loaded) {
      _load();
    }

    return _PaGetDeviceCount(Void);
  }

  ///
  /// Retrieve the index of the default input device. The result can be
  /// used in the inputDevice parameter to OpenStream().
  /// Return The default input device index for the default host API, or noDevice
  /// if no default input device is available or an error was encountered.
  ///
  static int getDefaultInputDevice() {
    if (! _loaded) {
      _load();
    }

    return _PaGetDefaultInputDevice(Void);
  }

  ///
  /// Retrieve the index of the default output device. The result can be
  /// used in the outputDevice parameter to OpenStream().
  ///
  /// Return The default output device index for the default host API, or noDevice
  /// if no default output device is available or an error was encountered.
  ///
  /// Note
  /// On the PC, the user can specify a default device by
  /// setting an environment variable. For example, to use device #1.
  /// <pre>
  /// set PA_RECOMMENDED_OUTPUT_DEVICE=1
  /// </pre>
  ///
  static int getDefaultOutputDevice() {
    if (! _loaded) {
      _load();
    }

    return _PaGetDefaultOutputDevice(Void);
  }

  ///
  /// Retrieve a pointer to a PaDeviceInfo structure containing information
  /// about the specified device.
  /// Return a pointer to an immutable PaDeviceInfo structure. If the device
  /// parameter is out of range the function returns NULL.
  ///
  /// [device] A valid device index in the range 0 to (GetDeviceCount()-1)
  ///
  /// Note PortAudio manages the memory referenced by the returned pointer,
  /// the client must not manipulate or free the memory. The pointer is only
  /// guaranteed to be valid between calls to Initialize() and Terminate().
  ///
  static DeviceInfo getDeviceInfo(int device) {
    if (! _loaded) {
      _load();
    }

    return _PaGetDeviceInfo(device).ref;
  }

  ///
  /// Determine whether it would be possible to open a stream with the specified
  /// parameters.
  /// [inputParameters] A structure that describes the input parameters used to
  /// open a stream. The suggestedLatency field is ignored. See PaStreamParameters
  /// for a description of these parameters. inputParameters must be NULL for
  /// output-only streams.
  ///
  /// [outputParameters] A structure that describes the output parameters used
  /// to open a stream. The suggestedLatency field is ignored. See PaStreamParameters
  /// for a description of these parameters. outputParameters must be NULL for
  /// input-only streams.
  ///
  /// [sampleRate] The required sampleRate. For full-duplex streams it is the
  /// sample rate for both input and output
  ///
  /// Returns 0 if the format is supported, and an error code indicating why
  /// the format is not supported otherwise. The constant formatIsSupported is
  /// provided to compare with the return value for success.
  ///
  static int isFormatSupported(Pointer<StreamParameters> inputParameters,
      Pointer<StreamParameters> outputParameters, double sampleRate) {
    if (! _loaded) {
      _load();
    }

    return _PaIsFormatSupported(
        inputParameters ?? nullptr, outputParameters ?? nullptr, sampleRate);
  }

  /// Opens a stream for either input, output or both.
  ///
  /// [stream] The address of a PaStream pointer which will receive
  /// a pointer to the newly opened stream.
  /// [inputParameters] A structure that describes the input parameters used by
  /// the opened stream. See PaStreamParameters for a description of these parameters.
  /// inputParameters must be NULL for output-only streams.
  ///
  /// [outputParameters] A structure that describes the output parameters used by
  /// the opened stream. See PaStreamParameters for a description of these parameters.
  /// outputParameters must be NULL for input-only streams.
  ///
  /// [sampleRate] The desired sampleRate. For full-duplex streams it is the
  /// sample rate for both input and output
  ///
  /// [framesPerBuffer] The number of frames passed to the stream callback
  /// function, or the preferred block granularity for a blocking read/write stream.
  /// The special value framesPerBufferUnspecified (0) may be used to request that
  /// the stream callback will receive an optimal (and possibly varying) number of
  /// frames based on host requirements and the requested latency settings.
  /// Note: With some host APIs, the use of non-zero framesPerBuffer for a callback
  /// stream may introduce an additional layer of buffering which could introduce
  /// additional latency. PortAudio guarantees that the additional latency
  /// will be kept to the theoretical minimum however, it is strongly recommended
  /// that a non-zero framesPerBuffer value only be used when your algorithm
  /// requires a fixed number of frames per stream callback.
  ///
  /// [streamFlags] Flags which modify the behavior of the streaming process.
  /// This parameter may contain a combination of flags ORed together. Some flags may
  /// only be relevant to certain buffer formats.
  ///
  /// [streamCallback] A pointer to a client supplied function that is responsible
  /// for processing and filling input and output buffers. If this parameter is NULL
  /// the stream will be opened in 'blocking read/write' mode. In blocking mode,
  /// the client can receive sample data using ReadStream and write sample data
  /// using WriteStream, the number of samples that may be read or written
  /// without blocking is returned by GetStreamReadAvailable and
  /// GetStreamWriteAvailable respectively.
  ///
  /// [userData] A client supplied pointer which is passed to the stream callback
  /// function. It could for example, contain a pointer to instance data necessary
  /// for processing the audio buffers. This parameter is ignored if streamCallback
  /// is NULL.
  ///
  /// Return
  /// Upon success OpenStream() returns noError and places a pointer to a
  /// valid PaStream in the stream argument. The stream is inactive (stopped).
  /// If a call to OpenStream() fails, a non-zero error code is returned (see
  /// PaError for possible error codes) and the value of stream is invalid.
  ///
  static int openStream(
      Pointer<Pointer<Void>> stream,
      Pointer<StreamParameters> inputParameters,
      Pointer<StreamParameters> outputParameters,
      double sampleRate,
      int framesPerBuffer,
      int streamFlags,
      SendPort sendPort,
      Pointer<Void> userData) {
    
    if (! _loaded) {
      _load();
    }

    var streamCallback = nullptr;
    if (sendPort != null) {
      streamCallback = _PahGetStreamCallback(sendPort.nativePort);
    }

    return _PaOpenStream(
        stream,
        inputParameters ?? nullptr,
        outputParameters ?? nullptr,
        sampleRate,
        framesPerBuffer,
        streamFlags,
        streamCallback,
        userData ?? nullptr);
  }

  /// A simplified version of OpenStream() that opens the default input
  /// and/or output devices.
  ///
  /// [stream] The address of a PaStream pointer which will receive
  /// a pointer to the newly opened stream.
  ///
  /// [numInputChannels] The number of channels of sound that will be supplied
  /// to the stream callback or returned by ReadStream. It can range from 1 to
  /// the value of maxInputChannels in the PaDeviceInfo record for the default input
  /// device. If 0 the stream is opened as an output-only stream.
  ///
  /// [numOutputChannels] The number of channels of sound to be delivered to the
  /// stream callback or passed to WriteStream. It can range from 1 to the value
  /// of maxOutputChannels in the PaDeviceInfo record for the default output device.
  /// If 0 the stream is opened as an output-only stream.
  ///
  /// [sampleFormat] The sample format of both the input and output buffers
  /// provided to the callback or passed to and from ReadStream and WriteStream.
  /// sampleFormat may be any of the formats described by the PaSampleFormat
  /// enumeration.
  ///
  /// [sampleRate] Same as OpenStream parameter of the same name.
  /// [framesPerBuffer] Same as OpenStream parameter of the same name.
  /// [streamCallback] Same as OpenStream parameter of the same name.
  /// [userData] Same as OpenStream parameter of the same name.
  ///
  /// Return As for OpenStream
  ///
  static int openDefaultStream(
      Pointer<Pointer<Void>> stream,
      int numInputChannels,
      int numOutputChannels,
      int sampleFormat,
      double sampleRate,
      int framesPerBuffer,
      SendPort sendPort,
      Pointer<Void> userData) {
    
    if (! _loaded) {
      _load();
    }

    var streamCallback ;
    if (sendPort != null) {
      var value = sendPort.nativePort;
      print (value);
      streamCallback = _PahGetStreamCallback(sendPort.nativePort);
    } else {
      streamCallback = nullptr;
    }

    return _PaOpenDefaultStream(
        stream,
        numInputChannels,
        numOutputChannels,
        sampleFormat,
        sampleRate,
        framesPerBuffer,
        streamCallback,
        userData ?? nullptr);
  }

  ///
  /// Call the return function, passing result code
  /// 
  static void setStreamResult(int result) {
    
    if (! _loaded) {
      _load();
    }

    _PahSetStreamResult(result);
  }

  ///
  /// Closes an audio stream. If the audio stream is active it
  /// discards any pending buffers as if AbortStream() had been called.
  ///
  static int closeStream(Pointer<Pointer<Void>> stream) {
    if (! _loaded) {
      _load();
    }

    return _PaCloseStream(stream.value);
  }

  ///
  /// Register a stream finished callback function which will be called when the
  /// stream becomes inactive. See the description of PaStreamFinishedCallback for
  /// further details about when the callback will be called.
  ///
  /// [stream] a pointer to a PaStream that is in the stopped state - if the
  /// stream is not stopped, the stream's finished callback will remain unchanged
  /// and an error code will be returned.
  ///
  /// [streamFinishedCallback] a pointer to a function with the same signature
  /// as PaStreamFinishedCallback, that will be called when the stream becomes
  /// inactive. Passing NULL for this parameter will un-register a previously
  /// registered stream finished callback function.
  ///
  /// Return on success returns noError, otherwise an error code indicating the cause
  /// of the error.
  ///
  static int setStreamFinishedCallback(Pointer<Pointer<Void>> stream,
                                       SendPort sendPort) {
    if (! _loaded) {
      _load();
    }

    var streamFinishedCallback;
    if (sendPort != null) {
      streamFinishedCallback = _PahGetStreamFinishedCallback(sendPort.nativePort);
    } else {
      streamFinishedCallback = nullptr;
    }
    return _PaSetStreamFinishedCallback(
        stream.value, streamFinishedCallback);
  }

  ///
  /// Commences audio processing.
  ///
  static int startStream(Pointer<Pointer<Void>> stream) {
    if (! _loaded) {
      _load();
    }

    return _PaStartStream(stream.value);
  }

  ///
  /// Terminates audio processing. It waits until all pending
  /// audio buffers have been played before it returns.
  ///
  static int stopStream(Pointer<Pointer<Void>> stream) {
    if (! _loaded) {
      _load();
    }

    return _PaStopStream(stream.value);
  }

  ///
  /// Terminates audio processing immediately without waiting for pending
  /// buffers to complete.
  ///
  static int abortStream(Pointer<Pointer<Void>> stream) {
    if (! _loaded) {
      _load();
    }

    return _PaAbortStream(stream.value);
  }

  ///
  /// Determine whether the stream is stopped.
  /// A stream is considered to be stopped prior to a successful call to
  /// StartStream and after a successful call to StopStream or AbortStream.
  /// If a stream callback returns a value other than continue the stream is NOT
  /// considered to be stopped.
  ///
  /// Returns one (1) when the stream is stopped, zero (0) when
  /// the stream is running or, a PaErrorCode (which are always negative) if
  /// PortAudio is not initialized or an error is encountered.
  ///
  static int isStreamStopped(Pointer<Pointer<Void>> stream) {
    if (! _loaded) {
      _load();
    }

    return _PaIsStreamStopped(stream.value);
  }

  ///
  /// Determine whether the stream is active.
  /// A stream is active after a successful call to StartStream(), until it
  /// becomes inactive either as a result of a call to StopStream() or
  /// AbortStream(), or as a result of a return value other than continue from
  /// the stream callback. In the latter case, the stream is considered inactive
  /// after the last buffer has finished playing.
  ///
  /// Returns one (1) when the stream is active (ie playing or recording
  /// audio), zero (0) when not playing or, a PaErrorCode (which are always negative)
  /// if PortAudio is not initialized or an error is encountered.
  ///
  static int isStreamActive(Pointer<Pointer<Void>> stream) {
    if (! _loaded) {
      _load();
    }

    return _PaIsStreamActive(stream.value);
  }

  ///
  /// Retrieve a pointer to a PaStreamInfo structure containing information
  /// about the specified stream.
  /// Return A pointer to an immutable PaStreamInfo structure. If the stream
  /// parameter is invalid, or an error is encountered, the function returns NULL.
  ///
  /// [stream] A pointer to an open stream previously created with OpenStream.
  ///
  /// Note PortAudio manages the memory referenced by the returned pointer,
  /// the client must not manipulate or free the memory. The pointer is only
  /// guaranteed to be valid until the specified stream is closed.
  ///
  static StreamInfo getStreamInfo(Pointer<Pointer<Void>> stream) {
    if (! _loaded) {
      _load();
    }

    return _PaGetStreamInfo(stream.value).ref;
  }

  ///
  /// Returns the current time in seconds for a stream according to the same clock used
  /// to generate callback PaStreamCallbackTimeInfo timestamps. The time values are
  /// monotonically increasing and have unspecified origin.
  ///
  /// GetStreamTime returns valid time values for the entire life of the stream,
  /// from when the stream is opened until it is closed. Starting and stopping the stream
  /// does not affect the passage of time returned by GetStreamTime.
  ///
  /// This time may be used for synchronizing other events to the audio stream, for
  /// example synchronizing audio to MIDI.
  ///
  /// Return The stream's current time in seconds, or 0 if an error occurred.
  ///
  static double getStreamTime(Pointer<Pointer<Void>> stream) {
    if (! _loaded) {
      _load();
    }

    return _PaGetStreamTime(stream.value);
  }

  ///
  /// Retrieve CPU usage information for the specified stream.
  /// The "CPU Load" is a fraction of total CPU time consumed by a callback stream's
  /// audio processing routines including, but not limited to the client supplied
  /// stream callback. This function does not work with blocking read/write streams.
  ///
  /// This function may be called from the stream callback function or the
  /// application.
  ///
  /// Return
  /// A floating point value, typically between 0.0 and 1.0, where 1.0 indicates
  /// that the stream callback is consuming the maximum number of CPU cycles possible
  /// to maintain real-time operation. A value of 0.5 would imply that PortAudio and
  /// the stream callback was consuming roughly 50% of the available CPU time. The
  /// return value may exceed 1.0. A value of 0.0 will always be returned for a
  /// blocking read/write stream, or if an error occurs.
  static double getStreamCpuLoad(Pointer<Pointer<Void>> stream) {
    if (! _loaded) {
      _load();
    }

    return _PaGetStreamCpuLoad(stream.value);
  }

  ///
  /// Read samples from an input stream. The function doesn't return until
  /// the entire buffer has been filled - this may involve waiting for the operating
  ///system to supply the data.
  ///
  /// [stream] A pointer to an open stream previously created with OpenStream.
  ///
  /// [buffer] A pointer to a buffer of sample frames. The buffer contains
  /// samples in the format specified by the inputParameters->sampleFormat field
  /// used to open the stream, and the number of channels specified by
  /// inputParameters->numChannels. If non-interleaved samples were requested using
  /// the nonInterleaved sample format flag, buffer is a pointer to the first element
  /// of an array of buffer pointers, one non-interleaved buffer for each channel.
  ///
  /// [frames] The number of frames to be read into buffer. This parameter
  /// is not constrained to a specific range, however high performance applications
  /// will want to match this parameter to the framesPerBuffer parameter used
  /// when opening the stream.
  ///
  /// Return On success PaNoError will be returned, or PaInputOverflowed if input
  /// data was discarded by PortAudio after the previous call and before this call.
  ///
  static int readStream(
      Pointer<Pointer<Void>> stream, Pointer<Void> buffer, int frames) {
    if (! _loaded) {
      _load();
    }

    return _PaReadStream(stream.value, buffer, frames);
  }

  ///
  /// Write samples to an output stream. This function doesn't return until the
  /// entire buffer has been written - this may involve waiting for the operating
  /// system to consume the data.
  ///
  /// [stream] A pointer to an open stream previously created with OpenStream.
  ///
  /// [buffer] A pointer to a buffer of sample frames. The buffer contains
  /// samples in the format specified by the outputParameters->sampleFormat field
  /// used to open the stream, and the number of channels specified by
  /// outputParameters->numChannels. If non-interleaved samples were requested using
  /// the paNonInterleaved sample format flag, buffer is a pointer to the first element
  /// of an array of buffer pointers, one non-interleaved buffer for each channel.
  ///
  /// [frames] The number of frames to be written from buffer. This parameter
  /// is not constrained to a specific range, however high performance applications
  /// will want to match this parameter to the framesPerBuffer parameter used
  /// when opening the stream.
  ///
  /// Return On success PaNoError will be returned, or outputUnderflowed if
  /// additional output data was inserted after the previous call and before this
  /// call.
  ///
  static int writeStream(
      Pointer<Pointer<Void>> stream, Pointer<Void> buffer, int frames) {
    if (! _loaded) {
      _load();
    }

    return _PaWriteStream(stream.value, buffer, frames);
  }

  ///
  /// Retrieve the number of frames that can be read from the stream without
  /// waiting.
  ///
  /// Returns a non-negative value representing the maximum number of frames
  /// that can be read from the stream without blocking or busy waiting or, a
  /// PaErrorCode (which are always negative) if PortAudio is not initialized or an
  /// error is encountered.
  ///
  static int getStreamReadAvailable(Pointer<Pointer<Void>> stream) {
    if (! _loaded) {
      _load();
    }

    return _PaGetStreamReadAvailable(stream.value);
  }

  ///
  /// Retrieve the number of frames that can be written to the stream without
  /// waiting.
  ///
  /// Returns a non-negative value representing the maximum number of frames
  /// that can be written to the stream without blocking or busy waiting or, a
  /// PaErrorCode (which are always negative) if PortAudio is not initialized or an
  /// error is encountered.
  ///
  static int getStreamWriteAvailable(Pointer<Pointer<Void>> stream) {
    if (! _loaded) {
      _load();
    }

    return _PaGetStreamWriteAvailable(stream.value);
  }

  ///
  /// Retrieve the size of a given sample format in bytes.
  ///
  /// Return The size in bytes of a single sample in the specified format,
  /// or sampleFormatNotSupported if the format is not supported.
  ///
  static int getSampleSize(int format) {
    if (! _loaded) {
      _load();
    }

    return _PaGetSampleSize(format);
  }

  ///
  /// Put the caller to sleep for at least 'msec' milliseconds. This function is
  /// provided only as a convenience for authors of portable code (such as the tests
  /// and examples in the PortAudio distribution.)
  ///
  /// The function may sleep longer than requested so don't rely on this for accurate
  /// musical timing.
  ///
  static void sleep(int msec) {
    if (! _loaded) {
      _load();
    }

    _PaSleep(msec);
  }
}

class DeviceIndex {
  const DeviceIndex();

  ///
  /// A special PaDeviceIndex value indicating that no device is available,
  /// or should be used.
  ///
  static const noDevice = -1;

  /// A special PaDeviceIndex value indicating that the device(s) to be used
  /// are specified in the host api specific stream info structure.
  ///
  static const useHostApiSpecificDeviceSpecification = -2;
}

class SampleFormat {
  const SampleFormat();

  ///
  /// A type used to specify one or more sample formats. Each value indicates
  /// a possible format for sound data passed to and from the stream callback,
  /// ReadStream and WriteStream.
  ///
  /// The standard formats paFloat32, paInt16, paInt32, paInt24, paInt8
  /// and aUInt8 are usually implemented by all implementations.
  ///
  /// The floating point representation (paFloat32) uses +1.0 and -1.0 as the
  /// maximum and minimum respectively.
  ///
  /// paUInt8 is an unsigned 8 bit format where 128 is considered "ground"
  ///
  /// The paNonInterleaved flag indicates that audio data is passed as an array
  /// of pointers to separate buffers, one buffer for each channel. Usually,
  /// when this flag is not used, audio data is passed as a single buffer with
  /// all channels interleaved.
  ///
  static const float32 = 0x00000001;
  static const int32 = 0x00000002;
  static const int24 = 0x00000004;

  /// Packed 24 bit format.
  static const int16 = 0x00000008;
  static const int8 = 0x00000010;
  static const uInt8 = 0x00000020;

  static const customFormat = 0x00010000;

  static const nonInterleaved = 0x80000000;

  ///
  /// Return code for IsFormatSupported indicating success.
  ///
  static const formatIsSupported = 0;

  ///
  /// Can be passed as the framesPerBuffer parameter to OpenStream()
  /// or OpenDefaultStream() to indicate that the stream callback will
  /// accept buffers of any size.
  ///
  static const framesPerBufferUnspecified = 0;
}

class StreamFlags {
  const StreamFlags();

  ///
  /// Flags used to control the behavior of a stream. They are passed as
  /// parameters to OpenStream or OpenDefaultStream. Multiple flags may be
  /// ORed together.
  ///
  /// See OpenStream, OpenDefaultStream
  /// See noFlag, clipOff, ditherOff, neverDropInput,
  /// primeOutputBuffersUsingStreamCallback, platformSpecificFlags
  ///
  static const noFlag = 0;

  /// Disable default clipping of out of range samples.
  static const clipOff = 0x00000001;

  /// Disable default dithering.
  static const ditherOff = 0x00000002;

  ///
  /// Flag requests that where possible a full duplex stream will not discard
  /// overflowed input samples without calling the stream callback. This flag is
  /// only valid for full duplex callback streams and only when used in combination
  /// with the paFramesPerBufferUnspecified (0) framesPerBuffer parameter. Using
  /// this flag incorrectly results in a paInvalidFlag error being returned from
  /// OpenStream and OpenDefaultStream.
  ///
  static const neverDropInput = 0x00000004;

  ///
  /// Call the stream callback to fill initial output buffers, rather than the
  /// default behavior of priming the buffers with zeros (silence). This flag has
  /// no effect for input-only and blocking read/write streams.
  ///
  static const primeOutputBuffersUsingStreamCallback = 0x00000008;

  /// A mask specifying the platform specific bits.
  static const platformSpecificFlags = 0xFFFF0000;

  ///
  /// Flag bit constants for the statusFlags to PaStreamCallback.
  /// See paInputUnderflow, paInputOverflow, paOutputUnderflow, paOutputOverflow,
  /// paPrimingOutput
  ///

  ///
  /// In a stream opened with paFramesPerBufferUnspecified, indicates that
  /// input data is all silence (zeros) because no real data is available. In a
  /// stream opened without paFramesPerBufferUnspecified, it indicates that one or
  /// more zero samples have been inserted into the input buffer to compensate
  /// for an input underflow.
  static const inputUnderflow = 0x00000001;

  ///
  /// In a stream opened with paFramesPerBufferUnspecified, indicates that data
  /// prior to the first sample of the input buffer was discarded due to an
  /// overflow, possibly because the stream callback is using too much CPU time.
  /// Otherwise indicates that data prior to one or more samples in the
  /// input buffer was discarded.
  ///
  static const inputOverflow = 0x00000002;

  ///
  /// Indicates that output data (or a gap) was inserted, possibly because the
  /// stream callback is using too much CPU time.
  ///
  static const outputUnderflow = 0x00000004;

  ///
  /// Indicates that output data will be discarded because no room is available.
  ///
  static const outputOverflow = 0x00000008;

  ///
  /// Some of all of the output data will be used to prime the stream, input
  /// data may be zero.
  ///
  static const primingOutput = 0x00000010;
}

///
/// A structure containing PortAudio API version information.
/// see GetVersionInfo
///
class VersionInfo extends Struct {
  @Int32()
  int versionMajor;

  @Int32()
  int versionMinor;

  @Int32()
  int versionSubMinor;

  ///
  /// This is currently the Git revision hash but may change in the future.
  /// The versionControlRevision is updated by running a script before compiling the library.
  /// If the update does not occur, this value may refer to an earlier revision.
  ///
  Pointer<Utf8> _versionControlRevision;

  ///
  /// Version as a string, for example "PortAudio V19.5.0-devel, revision 1952M" */
  ///
  Pointer<Utf8> _versionText;
}

extension VersionInfoExtension on VersionInfo {  
  String get versionControlRevision {
    return Utf8.fromUtf8(_versionControlRevision);
  }

  String get versionText {
    return Utf8.fromUtf8(_versionText);
  }
}

///
/// Error codes returned by PortAudio functions.
/// Note that with the exception of paNoError, all PaErrorCodes are negative.
///
class ErrorCode {
  const ErrorCode();

  static const noError = 0;
  static const notInitialized = -10000;
  static const unanticipatedHostError = -9999;
  static const invalidChannelCount = -9998;
  static const invalidSampleRate = -9997;
  static const invalidDevice = -9996;
  static const invalidFlag = -9995;
  static const sampleFormatNotSupported = -9994;
  static const badIODeviceCombination = -9993;
  static const insufficientMemory = -9992;
  static const bufferTooBig = -9991;
  static const bufferTooSmall = -9990;
  static const nullCallback = -9989;
  static const badStreamPtr = -9988;
  static const timedOut = -9987;
  static const internalError = -9986;
  static const deviceUnavailable = -9985;
  static const incompatibleHostApiSpecificStreamInfo = -9984;
  static const streamIsStopped = -9983;
  static const streamIsNotStopped = -9982;
  static const inputOverflowed = -9981;
  static const outputUnderflowed = -9980;
  static const hostApiNotFound = -9979;
  static const invalidHostApi = -9978;
  static const canNotReadFromACallbackStream = -9977;
  static const canNotWriteToACallbackStream = -9976;
  static const canNotReadFromAnOutputOnlyStream = -9975;
  static const canNotWriteToAnInputOnlyStream = -9974;
  static const incompatibleStreamHostApi = -9973;
  static const badBufferPtr = -9972;
}

///
/// Unchanging unique identifiers for each supported host API. This type
/// is used in the PaHostApiInfo structure. The values are guaranteed to be
/// unique and to never change, thus allowing code to be written that
/// conditionally uses host API specific extensions.
///
/// New type ids will be allocated when support for a host API reaches
/// "public alpha" status, prior to that developers should use the
/// paInDevelopment type id.
///
class HostApiTypeId {
  const HostApiTypeId();

  /// use while developing support for a new host API
  static const inDevelopment = 0;

  static const directSound = 1;
  static const mme = 2;
  static const asio = 3;
  static const soundManager = 4;
  static const coreAudio = 5;
  static const oss = 7;
  static const alsa = 8;
  static const al = 9;
  static const beOs = 10;
  static const wdmks = 11;
  static const jack = 12;
  static const wasapi = 13;
  static const audioScienceHpi = 14;
}

///
/// A structure containing information about a particular host API.
///
class HostApiInfo extends Struct {
  /// this is struct version 1
  @Int32()
  int structVersion;

  /// The well known unique identifier of this host API
  @Int32()
  int type;

  /// A textual description of the host API for display on user interfaces.
  Pointer<Utf8> _name;

  /// The number of devices belonging to this host API. This field may be
  /// used in conjunction with HostApiDeviceIndexToDeviceIndex() to enumerate
  /// all devices for this host API.
  @Int32()
  int deviceCount;

  /// The default input device for this host API. The value will be a
  /// device index ranging from 0 to (GetDeviceCount()-1), or paNoDevice
  /// if no default input device is available.
  @Int32()
  int defaultInputDevice;

  /// The default output device for this host API. The value will be a
  /// device index ranging from 0 to (GetDeviceCount()-1), or paNoDevice
  /// if no default output device is available.
  @Int32()
  int defaultOutputDevice;
}

extension HostApiInfoExtension on HostApiInfo {  
  String get name {
    return Utf8.fromUtf8(_name);
  }
}

///
/// Structure used to return information about a host error condition.
///
class HostErrorInfo extends Struct {
  /// The host API which returned the error code
  @Int32()
  int hostApiType;

  /// The error code returned
  @Int32()
  int errorCode;

  /// A textual description of the error if available, otherwise a zero-length string
  Pointer<Utf8> _errorText;
}

extension HostErrorInfoExtension on HostErrorInfo {  
  String get errorText {
    return Utf8.fromUtf8(_errorText);
  }
}

///
/// A structure providing information and capabilities of PortAudio devices.
/// Devices may support input, output or both input and output.
///
class DeviceInfo extends Struct {
  /// This is struct version 2
  @Int32()
  int structVersion;

  /// A textual description of the error if available, otherwise a zero-length string
  Pointer<Utf8> _name;

  /// Note this is a host API index, not a type id
  @Int32()
  int hostApi;

  @Int32()
  int maxInputChannels;

  @Int32()
  int maxOutputChannels;

  /// Default latency values for interactive performance.
  @Double()
  double defaultLowInputLatency;

  @Double()
  double defaultLowOutputLatency;

  /// Default latency values for robust non-interactive applications (eg. playing sound files).
  @Double()
  double defaultHighInputLatency;

  @Double()
  double defaultHighOutputLatency;

  @Double()
  double defaultSampleRate;
}

extension DeviceInfoExtension on DeviceInfo {  

  String get name {
    return Utf8.fromUtf8(_name);
  }
}

///
/// Parameters for one direction (input or output) of a stream.
///
class StreamParameters extends Struct {
  /// A valid device index in the range 0 to (GetDeviceCount()-1)
  /// specifying the device to be used or the special constant
  /// paUseHostApiSpecificDeviceSpecification which indicates that the actual
  /// device(s) to use are specified in hostApiSpecificStreamInfo.
  /// This field must not be set to paNoDevice.
  @Int32()
  int device;

  /// The number of channels of sound to be delivered to the
  /// stream callback or accessed by ReadStream() or WriteStream().
  /// It can range from 1 to the value of maxInputChannels in the
  /// PaDeviceInfo record for the device specified by the device parameter.
  @Int32()
  int channelCount;

  /// The sample format of the buffer provided to the stream callback,
  /// ReadStream() or WriteStream(). It may be any of the formats described
  /// by the PaSampleFormat enumeration.
  @Int32()
  int sampleFormat;

  /// The desired latency in seconds. Where practical, implementations should
  /// configure their latency based on these parameters, otherwise they may
  /// choose the closest viable latency instead. Unless the suggested latency
  /// is greater than the absolute upper limit for the device implementations
  /// should round the suggestedLatency up to the next practical value - ie to
  /// provide an equal or higher latency than suggestedLatency wherever possible.
  /// Actual latency values for an open stream may be retrieved using the
  /// inputLatency and outputLatency fields of the PaStreamInfo structure
  /// returned by GetStreamInfo().
  @Double()
  double suggestedLatency;

  /// An optional pointer to a host api specific data structure
  /// containing additional information for device setup and/or stream processing.
  /// hostApiSpecificStreamInfo is never required for correct operation,
  /// if not used it should be set to NULL.
  Pointer<Void> hostApiSpecificStreamInfo;
}

///
/// Timing information for the buffers passed to the stream callback.
///
/// Time values are expressed in seconds and are synchronised with the time base used by GetStreamTime() for the associated stream.
///
class StreamCallbackTimeInfo extends Struct {
  /// The time when the first sample of the input buffer was captured at the ADC input
  @Double()
  double inputBufferAdcTime;

  /// The time when the stream callback was invoked
  @Double()
  double currentTime;

  /// The time when the first sample of the output buffer will output the DAC
  @Double()
  double outputBufferDacTime;
}

///
/// Allowable return values for the PaStreamCallback.
/// See PaStreamCallback
///
class StreamCallbackResult {
  const StreamCallbackResult();

  /// Signal that the stream should continue invoking the callback and processing audio.
  static const continueProcessing = 0;

  /// Signal that the stream should stop invoking the callback and finish once all output samples have played.
  static const completeProcessing = 1;

  /// Signal that the stream should stop invoking the callback and finish as soon as possible.
  static const abortProcessing = 2;
}

///
/// Functions of type PaStreamCallback are implemented by PortAudio clients.
/// They consume, process or generate audio in response to requests from an
/// active PortAudio stream.
///
/// When a stream is running, PortAudio calls the stream callback periodically.
/// The callback function is responsible for processing buffers of audio samples
/// passed via the input and output parameters.
///
/// The PortAudio stream callback runs at very high or real-time priority.
/// It is required to consistently meet its time deadlines. Do not allocate
/// memory, access the file system, call library functions or call other functions
/// from the stream callback that may block or take an unpredictable amount of
/// time to complete.
///
/// In order for a stream to maintain glitch-free operation the callback
/// must consume and return audio data faster than it is recorded and/or
/// played. PortAudio anticipates that each callback invocation may execute for
/// a duration approaching the duration of frameCount audio frames at the stream
/// sample rate. It is reasonable to expect to be able to utilise 70% or more of
/// the available CPU time in the PortAudio callback. However, due to buffer size
/// adaption and other factors, not all host APIs are able to guarantee audio
/// stability under heavy CPU load with arbitrary fixed callback buffer sizes.
/// When high callback CPU utilisation is required the most robust behavior
/// can be achieved by using paFramesPerBufferUnspecified as the
/// OpenStream() framesPerBuffer parameter.
///
/// [input] and [output] are either arrays of interleaved samples or;
/// if non-interleaved samples were requested using the paNonInterleaved sample
/// format flag, an array of buffer pointers, one non-interleaved buffer for
/// each channel.
///
/// The format, packing and number of channels used by the buffers are
/// determined by parameters to OpenStream().
///
/// [frameCount] The number of sample frames to be processed by
/// the stream callback.
///
/// [timeInfo] Timestamps indicating the ADC capture time of the first sample
/// in the input buffer, the DAC output time of the first sample in the output buffer
/// and the time the callback was invoked.
/// See PaStreamCallbackTimeInfo and GetStreamTime()
///
/// [statusFlags] Flags indicating whether input and/or output buffers
/// have been inserted or will be dropped to overcome underflow or overflow
/// conditions.
///
/// [userData] The value of a user supplied pointer passed to
/// OpenStream() intended for storing synthesis data etc.
///
/// Return The stream callback should return one of the values in the
/// PaStreamCallbackResult enumeration. To ensure that the callback continues
/// to be called, it should return paContinue (0). Either paComplete or paAbort
/// can be returned to finish stream processing, after either of these values is
/// returned the callback will not be called again. If paAbort is returned the
/// stream will finish as soon as possible. If paComplete is returned, the stream
/// will continue until all buffers generated by the callback have been played.
/// This may be useful in applications such as soundfile players where a specific
/// duration of output is required. However, it is not necessary to utilize this
/// mechanism as StopStream(), AbortStream() or CloseStream() can also
/// be used to stop the stream. The callback must always fill the entire output
/// buffer irrespective of its return value.
///
///
/// Note With the exception of GetStreamCpuLoad() it is not permissible to call
/// PortAudio API functions from within the stream callback.
///
///
typedef StreamCallback = Int32 Function(
    Pointer<Void> input,
    Pointer<Void> output,
    Int32 frameCount,
    Pointer<StreamCallbackTimeInfo> timeInfo,
    Int32 statusFlags,
    Pointer<Void> userData);

class MessageTranslator {
  static const int messageTypeFinish = 0;
  static const int messageTypeCallback = 1;  
  
  int messageType;
  Pointer<Void> inputPointer;
  Pointer<Void> outputPointer;
  int frameCount;
  Pointer<StreamCallbackTimeInfo> streamCallbackTimeInfo;
  int statusFlags;
  Pointer<Void> userData;
  
  MessageTranslator(dynamic message) {
    messageType = message[0];

    if (messageType == 0) {
      userData = Pointer<Void>.fromAddress(message[1]);
    }
    else {
      inputPointer = Pointer<Void>.fromAddress(message[1]);
      outputPointer = Pointer<Void>.fromAddress(message[2]);;
      frameCount = message[3];
      streamCallbackTimeInfo = Pointer<StreamCallbackTimeInfo>.fromAddress(message[4]);
      statusFlags = message[4];
      userData = Pointer<Void>.fromAddress(message[6]);
    }
  }
}

///
/// Functions of type PaStreamFinishedCallback are implemented by PortAudio
/// clients. They can be registered with a stream using the SetStreamFinishedCallback
/// function. Once registered they are called when the stream becomes inactive
/// (ie once a call to StopStream() will not block).
/// A stream will become inactive after the stream callback returns non-zero,
/// or when StopStream or AbortStream is called. For a stream providing audio
/// output, if the stream callback returns paComplete, or StopStream() is called,
/// the stream finished callback will not be called until all generated sample data
/// has been played.
///
/// [userData] The userData parameter supplied to OpenStream()
///
typedef StreamFinishedCallback = Void Function(Pointer<Void> userData);

///
/// A structure containing unchanging information about an open stream.
///
class StreamInfo extends Struct {
  // this is struct version 1
  @Int32()
  int structVersion;

  /// The input latency of the stream in seconds. This value provides the most
  /// accurate estimate of input latency available to the implementation. It may
  /// differ significantly from the suggestedLatency value passed to OpenStream().
  /// The value of this field will be zero (0.) for output-only streams.
  @Double()
  double inputLatency;

  /// The output latency of the stream in seconds. This value provides the most
  /// accurate estimate of output latency available to the implementation. It may
  /// differ significantly from the suggestedLatency value passed to OpenStream().
  /// The value of this field will be zero (0.) for input-only streams.
  @Double()
  double outputLatency;

  /// The sample rate of the stream in Hertz (samples per second). In cases
  /// where the hardware sample rate is inaccurate and PortAudio is aware of it,
  /// the value of this field may be different from the sampleRate parameter
  /// passed to OpenStream(). If information about the actual hardware sample
  /// rate is not available, this field will have the same value as the sampleRate
  /// parameter passed to OpenStream().
  @Double()
  double sampleRate;
}
