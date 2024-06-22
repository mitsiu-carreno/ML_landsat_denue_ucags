class Entidad {
  final String name;
  final dynamic mensajes;

  Entidad({
    required this.name,
    required this.mensajes,
  });

  factory Entidad.fromJson(Map<String, dynamic> json) {
    return Entidad(
      mensajes: json['cantidad_mensajes'],
      name: json['estado'],
    );
  }
}
