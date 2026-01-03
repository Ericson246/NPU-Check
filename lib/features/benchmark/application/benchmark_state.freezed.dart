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
  double get averageSpeed =>
      throw _privateConstructorUsedError; // average tokens per second
  String get generatedText => throw _privateConstructorUsedError;
  double get progress => throw _privateConstructorUsedError; // 0.0 to 1.0
  bool get isOfflineMode => throw _privateConstructorUsedError;
  double get ramUsageMB => throw _privateConstructorUsedError;
  double get ramPeakMB => throw _privateConstructorUsedError;
  BenchmarkStatus get status => throw _privateConstructorUsedError;
  ModelType get selectedModel => throw _privateConstructorUsedError;
  bool get showTerminal => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  String? get modelName => throw _privateConstructorUsedError;
  BenchmarkWorkload get workload => throw _privateConstructorUsedError;
  List<ModelType> get downloadedModels => throw _privateConstructorUsedError;
  bool get hasPartialDownload => throw _privateConstructorUsedError;

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
      double averageSpeed,
      String generatedText,
      double progress,
      bool isOfflineMode,
      double ramUsageMB,
      double ramPeakMB,
      BenchmarkStatus status,
      ModelType selectedModel,
      bool showTerminal,
      String? errorMessage,
      String? modelName,
      BenchmarkWorkload workload,
      List<ModelType> downloadedModels,
      bool hasPartialDownload});
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
    Object? averageSpeed = null,
    Object? generatedText = null,
    Object? progress = null,
    Object? isOfflineMode = null,
    Object? ramUsageMB = null,
    Object? ramPeakMB = null,
    Object? status = null,
    Object? selectedModel = null,
    Object? showTerminal = null,
    Object? errorMessage = freezed,
    Object? modelName = freezed,
    Object? workload = null,
    Object? downloadedModels = null,
    Object? hasPartialDownload = null,
  }) {
    return _then(_value.copyWith(
      currentSpeed: null == currentSpeed
          ? _value.currentSpeed
          : currentSpeed // ignore: cast_nullable_to_non_nullable
              as double,
      averageSpeed: null == averageSpeed
          ? _value.averageSpeed
          : averageSpeed // ignore: cast_nullable_to_non_nullable
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
      ramPeakMB: null == ramPeakMB
          ? _value.ramPeakMB
          : ramPeakMB // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as BenchmarkStatus,
      selectedModel: null == selectedModel
          ? _value.selectedModel
          : selectedModel // ignore: cast_nullable_to_non_nullable
              as ModelType,
      showTerminal: null == showTerminal
          ? _value.showTerminal
          : showTerminal // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      modelName: freezed == modelName
          ? _value.modelName
          : modelName // ignore: cast_nullable_to_non_nullable
              as String?,
      workload: null == workload
          ? _value.workload
          : workload // ignore: cast_nullable_to_non_nullable
              as BenchmarkWorkload,
      downloadedModels: null == downloadedModels
          ? _value.downloadedModels
          : downloadedModels // ignore: cast_nullable_to_non_nullable
              as List<ModelType>,
      hasPartialDownload: null == hasPartialDownload
          ? _value.hasPartialDownload
          : hasPartialDownload // ignore: cast_nullable_to_non_nullable
              as bool,
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
      double averageSpeed,
      String generatedText,
      double progress,
      bool isOfflineMode,
      double ramUsageMB,
      double ramPeakMB,
      BenchmarkStatus status,
      ModelType selectedModel,
      bool showTerminal,
      String? errorMessage,
      String? modelName,
      BenchmarkWorkload workload,
      List<ModelType> downloadedModels,
      bool hasPartialDownload});
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
    Object? averageSpeed = null,
    Object? generatedText = null,
    Object? progress = null,
    Object? isOfflineMode = null,
    Object? ramUsageMB = null,
    Object? ramPeakMB = null,
    Object? status = null,
    Object? selectedModel = null,
    Object? showTerminal = null,
    Object? errorMessage = freezed,
    Object? modelName = freezed,
    Object? workload = null,
    Object? downloadedModels = null,
    Object? hasPartialDownload = null,
  }) {
    return _then(_$BenchmarkStateImpl(
      currentSpeed: null == currentSpeed
          ? _value.currentSpeed
          : currentSpeed // ignore: cast_nullable_to_non_nullable
              as double,
      averageSpeed: null == averageSpeed
          ? _value.averageSpeed
          : averageSpeed // ignore: cast_nullable_to_non_nullable
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
      ramPeakMB: null == ramPeakMB
          ? _value.ramPeakMB
          : ramPeakMB // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as BenchmarkStatus,
      selectedModel: null == selectedModel
          ? _value.selectedModel
          : selectedModel // ignore: cast_nullable_to_non_nullable
              as ModelType,
      showTerminal: null == showTerminal
          ? _value.showTerminal
          : showTerminal // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      modelName: freezed == modelName
          ? _value.modelName
          : modelName // ignore: cast_nullable_to_non_nullable
              as String?,
      workload: null == workload
          ? _value.workload
          : workload // ignore: cast_nullable_to_non_nullable
              as BenchmarkWorkload,
      downloadedModels: null == downloadedModels
          ? _value._downloadedModels
          : downloadedModels // ignore: cast_nullable_to_non_nullable
              as List<ModelType>,
      hasPartialDownload: null == hasPartialDownload
          ? _value.hasPartialDownload
          : hasPartialDownload // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$BenchmarkStateImpl implements _BenchmarkState {
  const _$BenchmarkStateImpl(
      {this.currentSpeed = 0.0,
      this.averageSpeed = 0.0,
      this.generatedText = '',
      this.progress = 0.0,
      this.isOfflineMode = false,
      this.ramUsageMB = 0.0,
      this.ramPeakMB = 0.0,
      this.status = BenchmarkStatus.idle,
      this.selectedModel = ModelType.tinyStories,
      this.showTerminal = false,
      this.errorMessage,
      this.modelName,
      this.workload = BenchmarkWorkload.standard,
      final List<ModelType> downloadedModels = const [],
      this.hasPartialDownload = false})
      : _downloadedModels = downloadedModels;

  @override
  @JsonKey()
  final double currentSpeed;
// tokens per second
  @override
  @JsonKey()
  final double averageSpeed;
// average tokens per second
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
  final double ramPeakMB;
  @override
  @JsonKey()
  final BenchmarkStatus status;
  @override
  @JsonKey()
  final ModelType selectedModel;
  @override
  @JsonKey()
  final bool showTerminal;
  @override
  final String? errorMessage;
  @override
  final String? modelName;
  @override
  @JsonKey()
  final BenchmarkWorkload workload;
  final List<ModelType> _downloadedModels;
  @override
  @JsonKey()
  List<ModelType> get downloadedModels {
    if (_downloadedModels is EqualUnmodifiableListView)
      return _downloadedModels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_downloadedModels);
  }

  @override
  @JsonKey()
  final bool hasPartialDownload;

  @override
  String toString() {
    return 'BenchmarkState(currentSpeed: $currentSpeed, averageSpeed: $averageSpeed, generatedText: $generatedText, progress: $progress, isOfflineMode: $isOfflineMode, ramUsageMB: $ramUsageMB, ramPeakMB: $ramPeakMB, status: $status, selectedModel: $selectedModel, showTerminal: $showTerminal, errorMessage: $errorMessage, modelName: $modelName, workload: $workload, downloadedModels: $downloadedModels, hasPartialDownload: $hasPartialDownload)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BenchmarkStateImpl &&
            (identical(other.currentSpeed, currentSpeed) ||
                other.currentSpeed == currentSpeed) &&
            (identical(other.averageSpeed, averageSpeed) ||
                other.averageSpeed == averageSpeed) &&
            (identical(other.generatedText, generatedText) ||
                other.generatedText == generatedText) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.isOfflineMode, isOfflineMode) ||
                other.isOfflineMode == isOfflineMode) &&
            (identical(other.ramUsageMB, ramUsageMB) ||
                other.ramUsageMB == ramUsageMB) &&
            (identical(other.ramPeakMB, ramPeakMB) ||
                other.ramPeakMB == ramPeakMB) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.selectedModel, selectedModel) ||
                other.selectedModel == selectedModel) &&
            (identical(other.showTerminal, showTerminal) ||
                other.showTerminal == showTerminal) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.modelName, modelName) ||
                other.modelName == modelName) &&
            (identical(other.workload, workload) ||
                other.workload == workload) &&
            const DeepCollectionEquality()
                .equals(other._downloadedModels, _downloadedModels) &&
            (identical(other.hasPartialDownload, hasPartialDownload) ||
                other.hasPartialDownload == hasPartialDownload));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      currentSpeed,
      averageSpeed,
      generatedText,
      progress,
      isOfflineMode,
      ramUsageMB,
      ramPeakMB,
      status,
      selectedModel,
      showTerminal,
      errorMessage,
      modelName,
      workload,
      const DeepCollectionEquality().hash(_downloadedModels),
      hasPartialDownload);

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
      final double averageSpeed,
      final String generatedText,
      final double progress,
      final bool isOfflineMode,
      final double ramUsageMB,
      final double ramPeakMB,
      final BenchmarkStatus status,
      final ModelType selectedModel,
      final bool showTerminal,
      final String? errorMessage,
      final String? modelName,
      final BenchmarkWorkload workload,
      final List<ModelType> downloadedModels,
      final bool hasPartialDownload}) = _$BenchmarkStateImpl;

  @override
  double get currentSpeed;
  @override // tokens per second
  double get averageSpeed;
  @override // average tokens per second
  String get generatedText;
  @override
  double get progress;
  @override // 0.0 to 1.0
  bool get isOfflineMode;
  @override
  double get ramUsageMB;
  @override
  double get ramPeakMB;
  @override
  BenchmarkStatus get status;
  @override
  ModelType get selectedModel;
  @override
  bool get showTerminal;
  @override
  String? get errorMessage;
  @override
  String? get modelName;
  @override
  BenchmarkWorkload get workload;
  @override
  List<ModelType> get downloadedModels;
  @override
  bool get hasPartialDownload;
  @override
  @JsonKey(ignore: true)
  _$$BenchmarkStateImplCopyWith<_$BenchmarkStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
