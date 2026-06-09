import '../../../../core/entities/destination_entity.dart';

class DestinationDto extends DestinationEntity {
  DestinationDto({
    required super.id,
    required super.name,
    required super.nameEn,
  });

  factory DestinationDto.fromJson(String id, Map<String, dynamic> json) {
    return DestinationDto(
      id: id,
      name: json['name'] ?? '',
      nameEn: json['nameEn'] ?? '',
    );
  }
}
