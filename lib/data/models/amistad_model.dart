class AmistadModel {
  final int id;
  final int solicitanteId;
  final String solicitanteUsername;
  final int receptorId;
  final String receptorUsername;
  final String estado;
  final DateTime createdAt;

  AmistadModel({
    required this.id,
    required this.solicitanteId,
    required this.solicitanteUsername,
    required this.receptorId,
    required this.receptorUsername,
    required this.estado,
    required this.createdAt,
  });

  factory AmistadModel.fromJson(Map<String, dynamic> json) {
    return AmistadModel(
      id: json['id'],
      solicitanteId: json['solicitante'] ?? 0,
      solicitanteUsername: json['solicitante_username'] ?? '',
      receptorId: json['receptor'] ?? 0,
      receptorUsername: json['receptor_username'] ?? '',
      estado: json['estado'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
