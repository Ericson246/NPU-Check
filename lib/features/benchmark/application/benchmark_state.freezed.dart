// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'benchmark_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$BenchmarkState {
  double get currentSpeed =>
      throw _privateConstructorUsedError; // tokens per second
  String get generatedText => throw _privateConstructorUsedError;
  double get progress => throw _privateConstructorUsedError; // 0.0 to 1.0
  bool get isOfflineMode => throw _privateConstructorUsedError;
  double get ramUsageMB => throw _privateConstructorUsedError;
  BenchmarkStatus get status => throw _privateConstructorUsedError;
  ModelType get selectedModel => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  String? get modelName => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $BenchmarkStateCopyWith<BenchmarkState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BenchmarkStateCopyWith<$Res> {
  factory $BenchmarkStateCopyWith(
          BenchmarkState value, $Res Function(BenchmarkState) then) =
      _$BenchmarkStateCopyWithImpl<$Res, BenchmarkState>;
  @useResult
  $Res call(
      {double currentSpeed,
      String generatedText,
      double progress,
      bool isOfflineMode,
      double ramUsageMB,
      BenchmarkStatus status,
      ModelType selectedModel,
      String? errorMessage,
      String? modelName});
}

/// @nodoc
class _$BenchmarkStateCopyWithImpl<$Res, $Val extends BenchmarkState>
    implements $BenchmarkStateCopyWith<$Res> {
  _$BenchmarkStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentSpeed = null,
    Object? generatedText = null,
    Object? progress = null,
    Object? isOfflineMode = null,
    Object? ramUsageMB = null,
    Object? status = null,
    Object? selectedModel = null,
    Object? errorMessage = freezed,
    Object? modelName = freezed,
  }) {
    return _then(_value.copyWith(
      currentSpeed: null == currentSpeed
          ? _value.currentSpeed
          : currentSpeed // ignore: cast_nullable_to_non_nullable
              as double,
      generatedText: null == generatedText
          ? _value.generatedText
          : generatedText // ignore: cast_nullable_to_non_nullable
              as String,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      isOfflineMode: null == isOfflineMode
          ? _value.isOfflineMode
          : isOfflineMode // ignore: cast_nullable_to_non_nullable
              as bool,
      ramUsageMB: null == ramUsageMB
          ? _value.ramUsageMB
          : ramUsageMB // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as BenchmarkStatus,
      selectedModel: null == selectedModel
          ? _value.selectedModel
          : selectedModel // ignore: cast_nullable_to_non_nullable
              as ModelType,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      modelName: freezed == modelName
          ? _value.modelName
          : modelName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BenchmarkStateImplCopyWith<$Res>
    implements $BenchmarkStateCopyWith<$Res> {
  factory _$$BenchmarkStateImplCopyWith(_$BenchmarkStateImpl value,
          $Res Function(_$BenchmarkStateImpl) then) =
      __$$BenchmarkStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double currentSpeed,
      String generatedText,
      double progress,
      bool isOfflineMode,
      double ramUsageMB,
      BenchmarkStatus status,
      ModelType selectedModel,
      String? errorMessage,
      String? modelName});
}

/// @nodoc
class __$$BenchmarkStateImplCopyWithImpl<$Res>
    extends _$BenchmarkStateCopyWithImpl<$Res, _$BenchmarkStateImpl>
    implements _$$BenchmarkStateImplCopyWith<$Res> {
  __$$BenchmarkStateImplCopyWithImpl(
      _$BenchmarkStateImpl _value, $Res Function(_$BenchmarkStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentSpeed = null,
    Object? generatedText = null,
    Object? progress = null,
    Object? isOfflineMode = null,
    Object? ramUsageMB = null,
    Object? status = null,
    Object? selectedModel = null,
    Object? errorMessage = freezed,
    Object? modelName = freezed,
  }) {
    return _then(_$BenchmarkStateImpl(
      currentSpeed: null == currentSpeed
          ? _value.currentSpeed
          : currentSpeed // ignore: cast_nullable_to_non_nullable
              as double,
      generatedText: null == generatedText
          ? _value.generatedText
          : generatedText // ignore: cast_nullable_to_non_nullable
              as String,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      isOfflineMode: null == isOfflineMode
          ? _value.isOfflineMode
          : isOfflineMode // ignore: cast_nullable_to_non_nullable
              as bool,
      ramUsageMB: null == ramUsageMB
          ? _value.ramUsageMB
          : ramUsageMB // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as BenchmarkStatus,
      selectedModel: null == selectedModel
          ? _value.selectedModel
          : selectedModel // ignore: cast_nullable_to_non_nullable
              as ModelType,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      modelName: freezed == modelName
          ? _value.modelName
          : modelName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$BenchmarkStateImpl implements _BenchmarkState {
  const _$BenchmarkStateImpl(
      {this.currentSpeed = 0.0,
      this.generatedText = '',
      this.progress = 0.0,
      this.isOfflineMode = false,
      this.ramUsageMB = 0.0,
      this.status = BenchmarkStatus.idle,
      this.selectedModel = ModelType.tinyStories,
      this.errorMessage,
      this.modelName});

  @override
  @JsonKey()
  final double currentSpeed;
// tokens per second
  @override
  @JsonKey()
  final String generatedText;
  @override
  @JsonKey()
  final double progress;
// 0.0 to 1.0
  @override
  @JsonKey()
  final bool isOfflineMode;
  @override
  @JsonKey()
  final double ramUsageMB;
  @override
  @JsonKey()
  final BenchmarkStatus status;
  @override
  @JsonKey()
  final ModelType selectedModel;
  @override
  final String? errorMessage;
  @override
  final String? modelName;

  @override
  String toString() {
    return 'BenchmarkState(currentSpeed: $currentSpeed, generatedText: $generatedText, progress: $progress, isOfflineMode: $isOfflineMode, ramUsageMB: $ramUsageMB, status: $status, selectedModel: $selectedModel, errorMessage: $errorMessage, modelName: $modelName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BenchmarkStateImpl &&
            (identical(other.currentSpeed, currentSpeed) ||
                other.currentSpeed == currentSpeed) &&
            (identical(other.generatedText, generatedText) ||
                other.generatedText == generatedText) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.isOfflineMode, isOfflineMode) ||
                other.isOfflineMode == isOfflineMode) &&
            (identical(other.ramUsageMB, ramUsageMB) ||
                other.ramUsageMB == ramUsageMB) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.selectedModel, selectedModel) ||
                other.selectedModel == selectedModel) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.modelName, modelName) ||
                other.modelName == modelName));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      currentSpeed,
      generatedText,
      progress,
      isOfflineMode,
      ramUsageMB,
      status,
      selectedModel,
      errorMessage,
      modelName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BenchmarkStateImplCopyWith<_$BenchmarkStateImpl> get copyWith =>
      __$$BenchmarkStateImplCopyWithImpl<_$BenchmarkStateImpl>(
          this, _$identity);
}

abstract class _BenchmarkState implements BenchmarkState {
  const factory _BenchmarkState(
      {final double currentSpeed,
      final String generatedText,
      final double progress,
      final bool isOfflineMode,
      final double ramUsageMB,
      final BenchmarkStatus status,
      final ModelType selectedModel,
      final String? errorMessage,
      final String? modelName}) = _$BenchmarkStateImpl;

  @override
  double get currentSpeed;
  @override // tokens per second
  String get generatedText;
  @override
  double get progress;
  @override // 0.0 to 1.0
  bool get isOfflineMode;
  @override
  double get ramUsageMB;
  @override
  BenchmarkStatus get status;
  @override
  ModelType get selectedModel;
  @override
  String? get errorMessage;
  @override
  String? get modelName;
  @override
  @JsonKey(ignore: true)
  _$$BenchmarkStateImplCopyWith<_$BenchmarkStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
