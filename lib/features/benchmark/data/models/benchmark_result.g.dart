// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'benchmark_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BenchmarkResultAdapter extends TypeAdapter<BenchmarkResult> {
  @override
  final int typeId = 0;

  @override
  BenchmarkResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BenchmarkResult(
      timestamp: fields[0] as DateTime,
      deviceModel: fields[1] as String,
      aiModelName: fields[2] as String,
      tokensPerSecond: fields[3] as double,
      ramUsageMB: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, BenchmarkResult obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.deviceModel)
      ..writeByte(2)
      ..write(obj.aiModelName)
      ..writeByte(3)
      ..write(obj.tokensPerSecond)
      ..writeByte(4)
      ..write(obj.ramUsageMB);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BenchmarkResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
