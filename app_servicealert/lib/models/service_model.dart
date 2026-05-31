/// [ServiceModel] representa a estrutura de dados de um serviço que estamos monitorando.
class ServiceModel {
  String name;
  String url;
  bool isOnline;
  bool isFavorite;
  DateTime? lastAlertTime;

  ServiceModel({
    required this.name,
    required this.url,
    required this.isOnline,
    required this.isFavorite,
    this.lastAlertTime,
  });
}