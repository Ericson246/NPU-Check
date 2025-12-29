
import 'dart:ffi';
import 'dart:io';

// Native callback function signature
typedef TokenCallbackNative = Void Function(Pointer<Char> token, Int64 timeMs);
typedef TokenCallbackDart = void Function(Pointer<Char> token, int timeMs);

// Native function signatures
typedef LoadModelNative = Int32 Function(Pointer<Char> modelPath);
typedef LoadModelDart = int Function(Pointer<Char> modelPath);

typedef RunInferenceNative = Int32 Function(Pointer<Char> prompt, Int32 maxTokens);
typedef RunInferenceDart = int Function(Pointer<Char> prompt, int maxTokens);

typedef DisposeModelNative = Void Function();
typedef DisposeModelDart = void Function();

typedef SetTokenCallbackNative = Void Function(Pointer<NativeFunction<TokenCallbackNative>> callback);
typedef SetTokenCallbackDart = void Function(Pointer<NativeFunction<TokenCallbackNative>> callback);

typedef GetGeneratedTextNative = Pointer<Char> Function();
typedef GetGeneratedTextDart = Pointer<Char> Function();

typedef StopInferenceNative = Void Function();
typedef StopInferenceDart = void Function();

class LlamaBindings {
  late final DynamicLibrary _dylib;
  late final LoadModelDart loadModel;
  late final RunInferenceDart runInference;
  late final DisposeModelDart disposeModel;
  late final GetGeneratedTextDart getGeneratedText;
  late final StopInferenceDart stopInference;
  SetTokenCallbackDart? setTokenCallback;

  LlamaBindings() {
    // Load the native library
    if (Platform.isAndroid) {
      _dylib = DynamicLibrary.open('libneural_gauge_native.so');
    } else if (Platform.isIOS) {
      _dylib = DynamicLibrary.process();
    } else {
      throw UnsupportedError('Platform not supported');
    }

    // Look up functions
    loadModel = _dylib
        .lookup<NativeFunction<LoadModelNative>>('load_model')
        .asFunction();
    
    runInference = _dylib
        .lookup<NativeFunction<RunInferenceNative>>('run_inference')
        .asFunction();
    
    disposeModel = _dylib
        .lookup<NativeFunction<DisposeModelNative>>('dispose_model')
        .asFunction();
    
    getGeneratedText = _dylib
        .lookup<NativeFunction<GetGeneratedTextNative>>('get_generated_text')
        .asFunction();

    stopInference = _dylib
        .lookup<NativeFunction<StopInferenceNative>>('stop_inference')
        .asFunction();
    
    // setTokenCallback is optional for now
    try {
      setTokenCallback = _dylib
          .lookup<NativeFunction<SetTokenCallbackNative>>('set_token_callback')
          .asFunction();
    } catch (e) {
      // Function not found - that's okay for now
      setTokenCallback = null;
    }
  }
}
