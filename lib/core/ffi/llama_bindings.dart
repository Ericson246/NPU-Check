import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';

/// FFI bindings for the native llama.cpp library
class LlamaBindings {
  late final ffi.DynamicLibrary _lib;
  
  // Function signatures
  late final LoadModelNative loadModel;
  late final SetTokenCallbackNative setTokenCallback;
  late final RunInferenceNative runInference;
  late final GetRamUsageNative getRamUsage;
  late final DisposeModelNative disposeModel;

  LlamaBindings() {
    // Load the native library
    if (Platform.isAndroid) {
      _lib = ffi.DynamicLibrary.open('libneural_gauge_native.so');
    } else if (Platform.isIOS) {
      _lib = ffi.DynamicLibrary.process();
    } else {
      throw UnsupportedError('Platform not supported');
    }

    // Bind functions
    loadModel = _lib.lookupFunction<
        ffi.Int32 Function(ffi.Pointer<Utf8>),
        int Function(ffi.Pointer<Utf8>)>('load_model');

    setTokenCallback = _lib.lookupFunction<
        ffi.Void Function(ffi.Pointer<ffi.NativeFunction<TokenCallbackNative>>),
        void Function(ffi.Pointer<ffi.NativeFunction<TokenCallbackNative>>)>(
      'set_token_callback',
    );

    runInference = _lib.lookupFunction<
        ffi.Int32 Function(ffi.Pointer<Utf8>, ffi.Int32),
        int Function(ffi.Pointer<Utf8>, int)>('run_inference');

    getRamUsage = _lib.lookupFunction<
        ffi.Double Function(),
        double Function()>('get_ram_usage');

    disposeModel = _lib.lookupFunction<
        ffi.Void Function(),
        void Function()>('dispose_model');
  }
}

// Native function type definitions
typedef LoadModelNative = int Function(ffi.Pointer<Utf8> modelPath);
typedef SetTokenCallbackNative = void Function(
  ffi.Pointer<ffi.NativeFunction<TokenCallbackNative>> callback,
);
typedef RunInferenceNative = int Function(
  ffi.Pointer<Utf8> prompt,
  int maxTokens,
);
typedef GetRamUsageNative = double Function();
typedef DisposeModelNative = void Function();

// Token callback signature
typedef TokenCallbackNative = ffi.Void Function(
  ffi.Pointer<Utf8> token,
  ffi.Int64 timeMs,
);

