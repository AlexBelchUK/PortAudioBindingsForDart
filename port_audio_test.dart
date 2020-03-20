import 'package:port_audio/port_audio.dart';
import 'package:test/test.dart';

import 'dart:ffi';
import 'package:ffi/ffi.dart';

void main() {
  group('Port Audio Tests', () {
    
    setUp(() {
      PortAudio.initialize();
    });

    tearDown(() {
      PortAudio.terminate();
    });

    Pointer<Pointer<Void>> getAnOpenStream() {
      var stream =
          Pointer<Pointer<Void>>.fromAddress(allocate<IntPtr>().address);
      var numInputChannels = 2;
      var numOutputChannels = 2;
      var sampleFormat = SampleFormat.int16;
      var sampleRate = 32000.0;
      var framesPerBuffer = 4;
      var userData = nullptr;

      var result = PortAudio.openDefaultStream(
          stream,
          numInputChannels,
          numOutputChannels,
          sampleFormat,
          sampleRate,
          framesPerBuffer,
          null,
          userData);
      expect(result, equals(ErrorCode.noError));

      return stream;
    }

    void closeAStream(Pointer<Pointer<Void>> stream) {
      free(stream);
    }

    test('getVersionText', () {
      var versionText = PortAudio.getVersionText();
      expect(versionText, equals('PortAudio V19.6.0-devel, revision unknown'));
    });

    test('getVersion', () {
      var version = PortAudio.getVersion();
      expect(version, equals(0x130600));
    });

    test('getVersionInfo', () {
      var versionInfo = PortAudio.getVersionInfo();
      expect(versionInfo.versionMajor, equals(0x13));
      expect(versionInfo.versionMinor, equals(0x06));
      expect(versionInfo.versionSubMinor, equals(0x0));
      expect(versionInfo.versionText,
          equals('PortAudio V19.6.0-devel, revision unknown'));
      expect(versionInfo.versionControlRevision, equals('unknown'));
    });

    test('getErrorText', () {
      var errorText = PortAudio.getErrorText(ErrorCode.noError);
      expect(errorText, equals('Success'));

      errorText = PortAudio.getErrorText(ErrorCode.outputUnderflowed);
      expect(errorText, equals('Output underflowed'));

      errorText = PortAudio.getErrorText(ErrorCode.badBufferPtr);
      expect(errorText, equals('Bad buffer pointer'));
    });

    test('getHostApiCount', () {
      var hostApiCount = PortAudio.getHostApiCount();
      print('hostApiCount ${hostApiCount}');
      expect(hostApiCount, greaterThan(0));
    });

    test('getDefaultHostApi', () {
      var defaultHostApi = PortAudio.getDefaultHostApi();
      print('defaultHostApi ${defaultHostApi}');
      expect(defaultHostApi, greaterThanOrEqualTo(0));
    });

    test('getHostApiInfo', () {
      var hostApiInfo = PortAudio.getHostApiInfo(0);
      expect(hostApiInfo.defaultInputDevice, equals(1));
      expect(hostApiInfo.defaultOutputDevice, equals(4));
      expect(hostApiInfo.deviceCount, equals(5));
      expect(hostApiInfo.name, equals('MME'));
      expect(hostApiInfo.structVersion, equals(1));
    });

    test('hostApiTypeIdToHostApiIndex', () {
      var hostApiIndex =
          PortAudio.hostApiTypeIdToHostApiIndex(HostApiTypeId.mme);
      expect(hostApiIndex, greaterThanOrEqualTo(0));
    });

    test('hostApiDeviceIndexToDeviceIndex', () {
      var deviceIndex =
          PortAudio.hostApiDeviceIndexToDeviceIndex(HostApiTypeId.mme, 0);
      expect(deviceIndex, greaterThanOrEqualTo(0));
    });

    test('getLastHostErrorInfo', () {
      var hostErrorInfo = PortAudio.getLastHostErrorInfo();
      expect(hostErrorInfo.errorCode, equals(ErrorCode.noError));
    });

    test('getDeviceCount', () {
      var deviceCount = PortAudio.getDeviceCount();
      expect(deviceCount, equals(40));
    });

    test('getDefaultInputDevice', () {
      var defaultInputDevice = PortAudio.getDefaultInputDevice();
      expect(defaultInputDevice, equals(1));
    });

    test('getDefaultOutputDevice', () {
      var defaultOutputDevice = PortAudio.getDefaultOutputDevice();
      expect(defaultOutputDevice, equals(4));
    });

    test('getDeviceInfo', () {
      var deviceInfo =
          PortAudio.getDeviceInfo(PortAudio.getDefaultOutputDevice());
      expect(deviceInfo.defaultHighInputLatency, equals(0.18));
      expect(deviceInfo.defaultHighOutputLatency, equals(0.18));
      expect(deviceInfo.defaultLowInputLatency, equals(0.09));
      expect(deviceInfo.defaultLowOutputLatency, equals(0.09));
      expect(deviceInfo.defaultSampleRate, equals(44100.0));
      expect(deviceInfo.hostApi, equals(0));
      expect(deviceInfo.maxInputChannels, equals(0));
      expect(deviceInfo.maxOutputChannels, equals(2));
      expect(deviceInfo.name, equals('Speaker / Headphone (2- Realtek'));
      expect(deviceInfo.structVersion, equals(2));
    });

    test('isFormatSupported', () {
      var deviceOutputIndex = PortAudio.getDefaultOutputDevice();
      var deviceOutputInfo = PortAudio.getDeviceInfo(deviceOutputIndex);

      var outputParameters = allocate<StreamParameters>();
      outputParameters.ref
        ..device = deviceOutputIndex
        ..channelCount = deviceOutputInfo.maxOutputChannels
        ..sampleFormat = SampleFormat.int32
        ..suggestedLatency = deviceOutputInfo.defaultHighOutputLatency
        ..hostApiSpecificStreamInfo = nullptr;

      var supported =
          PortAudio.isFormatSupported(null, outputParameters, 44100.0);

      free(outputParameters);
      expect(supported, equals(SampleFormat.formatIsSupported));
    });

    test('openStream', () {
      var stream =
          Pointer<Pointer<Void>>.fromAddress(allocate<IntPtr>().address);

      var inputParameters = allocate<StreamParameters>();
      inputParameters.ref
        ..device = 0
        ..channelCount = 2
        ..sampleFormat = SampleFormat.int16
        ..suggestedLatency = 0.1
        ..hostApiSpecificStreamInfo = nullptr;

      var outputParameters = nullptr;
      var sampleRate = 41000.0;
      var framesPerBuffer = 2;
      var streamFlags = StreamFlags.noFlag;

      var userData = allocate<Uint8>(count: 32);

      var result = PortAudio.openStream(
          stream,
          inputParameters,
          outputParameters,
          sampleRate,
          framesPerBuffer,
          streamFlags,
          null,
          userData.cast<Void>());

      PortAudio.closeStream(stream);

      free(inputParameters);
      free(userData);
      free(stream);

      expect(result, equals(ErrorCode.noError));
    });

    test('openDefaultStream', () {
      var stream =
          Pointer<Pointer<Void>>.fromAddress(allocate<IntPtr>().address);

      var numInputChannels = 2;
      var numOutputChannels = 2;
      var sampleFormat = SampleFormat.int16;
      var sampleRate = 32000.0;
      var framesPerBuffer = 4;

      var userData = allocate<Uint8>(count: 32);

      var result = PortAudio.openDefaultStream(
          stream,
          numInputChannels,
          numOutputChannels,
          sampleFormat,
          sampleRate,
          framesPerBuffer,
          null,
          userData.cast<Void>());

      free(userData);
      free(stream);

      expect(result, equals(ErrorCode.noError));
    });

    test('closeStream', () {
      var stream = getAnOpenStream();

      var result = PortAudio.closeStream(stream);
      expect(result, equals(ErrorCode.noError));

      closeAStream(stream);
    });

    test('setStreamFinishedCallback', () {
      var stream = getAnOpenStream();

      var result = PortAudio.setStreamFinishedCallback(stream, null);

      expect(result, equals(ErrorCode.noError));

      result = PortAudio.closeStream(stream);
      expect(result, equals(ErrorCode.noError));

      closeAStream(stream);
    });

    test('startStream', () {
      var stream = getAnOpenStream();

      var result = PortAudio.startStream(stream);
      expect(result, equals(ErrorCode.noError));

      result = PortAudio.closeStream(stream);
      expect(result, equals(ErrorCode.noError));

      closeAStream(stream);
    });

    test('stopStream', () {
      var stream = getAnOpenStream();

      var result = PortAudio.startStream(stream);
      expect(result, equals(ErrorCode.noError));

      result = PortAudio.stopStream(stream);
      expect(result, equals(ErrorCode.noError));

      result = PortAudio.closeStream(stream);
      expect(result, equals(ErrorCode.noError));

      closeAStream(stream);
    });

    test('abortStream', () {
      var stream = getAnOpenStream();

      var result = PortAudio.startStream(stream);
      expect(result, equals(ErrorCode.noError));

      result = PortAudio.abortStream(stream);
      expect(result, equals(ErrorCode.noError));

      result = PortAudio.closeStream(stream);
      expect(result, equals(ErrorCode.noError));

      closeAStream(stream);
    });

    test('isStreamStopped', () {
      var stream = getAnOpenStream();
      var stopped = PortAudio.isStreamStopped(stream);
      expect(stopped, equals(1));

      var result = PortAudio.closeStream(stream);
      expect(result, equals(ErrorCode.noError));

      closeAStream(stream);
    });

    test('isStreamActive', () {
      var stream = getAnOpenStream();
      var stopped = PortAudio.isStreamActive(stream);
      expect(stopped, equals(0));

      var result = PortAudio.closeStream(stream);
      expect(result, equals(ErrorCode.noError));

      closeAStream(stream);
    });

    test('getStreamInfo', () {
      var stream = getAnOpenStream();
      var streamInfo = PortAudio.getStreamInfo(stream);

      expect(streamInfo.inputLatency, equals(0.02575));
      expect(streamInfo.outputLatency, equals(0.18025));
      expect(streamInfo.sampleRate, equals(32000.0));
      expect(streamInfo.structVersion, equals(0));

      var result = PortAudio.closeStream(stream);
      expect(result, equals(ErrorCode.noError));

      closeAStream(stream);
    });

    test('getStreamTime', () {
      var stream = getAnOpenStream();

      var streamTime = PortAudio.getStreamTime(stream);
      expect(streamTime, greaterThan(1.0));

      var result = PortAudio.closeStream(stream);
      expect(result, equals(ErrorCode.noError));

      closeAStream(stream);
    });

    test('getStreamCpuLoad', () {
      var stream = getAnOpenStream();

      var cpuLoad = PortAudio.getStreamCpuLoad(stream);
      expect(cpuLoad, equals(0.0));

      var result = PortAudio.closeStream(stream);
      expect(result, equals(ErrorCode.noError));

      closeAStream(stream);
    });

    test('readStream', () {
      var stream = getAnOpenStream();

      var result = PortAudio.startStream(stream);
      expect(result, equals(ErrorCode.noError));

      var buffer = allocate<Uint8>(count: 32);
      var frames = 2;

      result = PortAudio.readStream(stream, buffer.cast<Void>(), frames);
      expect(result, equals(ErrorCode.noError));

      result = PortAudio.closeStream(stream);
      expect(result, equals(ErrorCode.noError));

      free(buffer);
      closeAStream(stream);
    });

    test('writeStream', () {
      var stream = getAnOpenStream();

      var result = PortAudio.startStream(stream);
      expect(result, equals(ErrorCode.noError));

      var buffer = allocate<Uint8>();
      var frames = 2;

      result = PortAudio.writeStream(stream, buffer.cast<Void>(), frames);
      expect(result, equals(ErrorCode.noError));

      result = PortAudio.closeStream(stream);
      expect(result, equals(ErrorCode.noError));

      free(buffer);
      closeAStream(stream);
    });

    test('getStreamReadAvailable', () {
      var stream = getAnOpenStream();

      var result = PortAudio.getStreamReadAvailable(stream);
      expect(result, equals(0));

      result = PortAudio.closeStream(stream);
      expect(result, equals(ErrorCode.noError));

      closeAStream(stream);
    });

    test('getStreamWriteAvailable', () {
      var stream = getAnOpenStream();

      var result = PortAudio.getStreamWriteAvailable(stream);
      expect(result, equals(0));

      closeAStream(stream);
    });

    test('getSampleSize', () {
      var format = SampleFormat.int16;
      var size = PortAudio.getSampleSize(format);
      expect(size, equals(2));
    });

    test('sleep', () {
      var time = 1;
      PortAudio.sleep(time);
    });
  });
}
