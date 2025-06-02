class Mascota {
  final String id;
  final String nombre;
  final String especie;
  final String raza;
  final int edad;

  Mascota({
    required this.id,
    required this.nombre,
    required this.especie,
    required this.raza,
    required this.edad,
  });

  factory Mascota.fromJson(Map<String, dynamic> json) {
    return Mascota(
      id: json['id'].toString(),
      nombre: json['nombre'] ?? '',
      especie: json['especie'] ?? '',
      raza: json['raza'] ?? '',
      edad: json['edad'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'especie': especie,
      'raza': raza,
      'edad': edad,
    };
  }
}