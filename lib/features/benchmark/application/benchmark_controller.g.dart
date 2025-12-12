// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'benchmark_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$benchmarkRepositoryHash() =>
    r'ee744017ba0f3985a88c947b70f749146ac32d22';

/// See also [benchmarkRepository].
@ProviderFor(benchmarkRepository)
final benchmarkRepositoryProvider =
    AutoDisposeProvider<BenchmarkRepository>.internal(
  benchmarkRepository,
  name: r'benchmarkRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$benchmarkRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef BenchmarkRepositoryRef = AutoDisposeProviderRef<BenchmarkRepository>;
String _$benchmarkControllerHash() =>
    r'56980fdf443ae52056dc048089185d9e353284cd';

/// See also [BenchmarkController].
@ProviderFor(BenchmarkController)
final benchmarkControllerProvider =
    AutoDisposeNotifierProvider<BenchmarkController, BenchmarkState>.internal(
  BenchmarkController.new,
  name: r'benchmarkControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$benchmarkControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BenchmarkController = AutoDisposeNotifier<BenchmarkState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
