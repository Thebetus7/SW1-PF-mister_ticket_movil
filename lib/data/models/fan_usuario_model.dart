class FanUsuarioModel {
  final int id;
  final String username;

  FanUsuarioModel({
    required this.id,
    required this.username,
  });

  factory FanUsuarioModel.fromJson(Map<String, dynamic> json) {
    return FanUsuarioModel(
      id: json['id'],
      username: json['username'] ?? '',
    );
  }
}
