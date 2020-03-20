import 'package:port_audio/port_audio.dart';

import 'dart:io';
import 'dart:isolate';
import 'dart:ffi';
import 'package:ffi/ffi.dart';

const sampleRate = 44100.0;
const numSeconds = 5;

var leftPhase = 0.0;
var rightPhase = 0.0;

var stream;

void start () {
  var result = PortAudio.initialize();
  checkForError('initialize', result);

  stream = Pointer<Pointer<Void>>.fromAddress(allocate<IntPtr>().address);

  Isolate.spawn(streamRequestProcessing, 0);

  /* Sleep for several seconds. */
  PortAudio.sleep(numSeconds * 1000);

  result = PortAudio.stopStream(stream);
  checkForError('stopStream', result);

  result = PortAudio.closeStream(stream);
  checkForError('closeStream', result);

  free(stream.value);
  free(stream);

  PortAudio.terminate();
  checkForError('terminate', result);
}
  
void checkForError (String text, int result) {
  if (result != ErrorCode.noError) {
    var errText = PortAudio.getErrorText(result);
    print ('Error $text - $errText');
    exit(1);
  }
}

void streamRequestProcessing(var param) {    
  var stream = Pointer<Pointer<Void>>.fromAddress(allocate<IntPtr>().address);
  var receivePort = ReceivePort();
  
  var result = PortAudio.openDefaultStream(
      stream,
      0, /* no input channels */
      2, /* stereo output */
      SampleFormat.float32,  /* 32 bit floating point output */
      sampleRate,
      256,        /* frames per buffer, i.e. the number
                     of sample frames that PortAudio will
                     request from the callback. Many apps
                     may want to use paFramesPerBufferUnspecified, 
                     which tells PortAudio to pick the best,
                     possibly changing, buffer size.*/
      receivePort.sendPort, /* this is your callback function receive port */
      null); /*This is a pointer that will be passed to your callback*/
  checkForError('openDefaultStream', result);    

  result = PortAudio.setStreamFinishedCallback(stream, receivePort.sendPort);   
  checkForError('setStreamFinishedCallback', result);    

  result = PortAudio.startStream(stream);
  checkForError('startStream', result);

  receivePort.listen((message) {
    final translatedMessage = MessageTranslator(message);
    final messageType = translatedMessage.messageType;
    final outputPointer = translatedMessage.outputPointer.cast<Float>();
    final frameCount = translatedMessage.frameCount;

    for(var i=0; messageType == MessageTranslator.messageTypeCallback && i < frameCount; i++) {
      outputPointer[(i * 2) + 0] = leftPhase; 
      outputPointer[(i * 2) + 1] = rightPhase;
        
      /* Generate simple sawtooth phaser that ranges between -1.0 and 1.0. */
      leftPhase += 0.01;
        
      /* When signal reaches top, drop back down. */
      if (leftPhase >= 1.0) { 
        leftPhase -= 2.0; 
      }
      
      /* higher pitch so we can distinguish left and right. */
      rightPhase += 0.03;
      if (rightPhase >= 1.0) {
        rightPhase -= 2.0; 
      }
    }

    PortAudio.setStreamResult(StreamCallbackResult.continueProcessing);
  });
}

void main() {
  start();
}
