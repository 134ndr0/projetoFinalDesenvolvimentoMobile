class ServiceModel {
  int? id; 
  String name;
  String url;
  bool isOnline;
  bool isFavorite;
  String deviceUuid; // Identificador único do dispositivo
  DateTime? lastAlertTime;

  ServiceModel({
    this.id,
    required this.name,
    required this.url,
    this.isOnline = true,
    this.isFavorite = false,
    required this.deviceUuid,
    this.lastAlertTime,
  });

  // Converte um ServiceModel em um Map (formato que o SQLite aceita para salvar)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'isFavorite': isFavorite ? 1 : 0, // SQLite não tem booleano, usamos 1 para true e 0 para false
      'deviceUuid': deviceUuid,
    };
  }

  // Cria um ServiceModel a partir de um Map vindo do banco de dados
  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'],
      name: map['name'],
      url: map['url'],
      isFavorite: map['isFavorite'] == 1,
      deviceUuid: map['deviceUuid'] ?? '',
      isOnline: true, // Começa como online até a primeira checagem de rede
    );
  }
}