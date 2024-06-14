class ChartData {
  //final dynamic year;
  final dynamic month;
  final dynamic conteo;
  ChartData(this.month, this.conteo);

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      json['Mes'], // Manejo de posible valor nulo para 'month'
      json['conteo'] != null
          ? json['conteo'].toDouble()
          : 0.0, // Convertir a double y manejar nulos
    );
  }
}
