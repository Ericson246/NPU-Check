import 'dart:ffi' as ffi;
import 'dart:io';

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

// Helper class for UTF-8 string conversion
class Utf8 extends ffi.Opaque {}

extension Utf8Pointer on ffi.Pointer<Utf8> {
  static ffi.Pointer<Utf8> fromString(String string) {
    final units = string.codeUnits;
    final ffi.Pointer<ffi.Uint8> result = ffi.malloc.allocate(units.length + 1);
    final nativeString = result.asTypedList(units.length + 1);
    nativeString.setAll(0, units);
    nativeString[units.length] = 0;
    return result.cast();
  }

  String toDartString() {
    final buffer = <int>[];
    var i = 0;
    while (true) {
      final char = (this.cast<ffi.Uint8>() + i).value;
      if (char == 0) break;
      buffer.add(char);
      i++;
    }
    return String.fromCharCodes(buffer);
  }
}
