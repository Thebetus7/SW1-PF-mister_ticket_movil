class AmigoModel {
  final int id;
  final String username;
  final int amistadId;

  AmigoModel({
    required this.id,
    required this.username,
    required this.amistadId,
  });

  factory AmigoModel.fromJson(Map<String, dynamic> json) {
    return AmigoModel(
      id: json['id'],
      username: json['username'] ?? '',
      amistadId: json['amistad_id'] ?? 0,
    );
  }
}
