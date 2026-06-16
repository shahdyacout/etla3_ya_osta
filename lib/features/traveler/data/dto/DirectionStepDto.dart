import '../../domain/entities/direction_step.dart';

class DirectionStepDto extends DirectionStep {
  const DirectionStepDto({
    required super.text,
    required super.distance,
    required super.status,
  });

  factory DirectionStepDto.fromJson(Map<String, dynamic> json) {
    return DirectionStepDto(
      text: json['text'] as String? ?? '',
      distance: json['distance'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'distance': distance,
      'status': status,
    };
  }

  factory DirectionStepDto.fromEntity(DirectionStep entity) {
    return DirectionStepDto(
      text: entity.text,
      distance: entity.distance,
      status: entity.status,
    );
  }
}