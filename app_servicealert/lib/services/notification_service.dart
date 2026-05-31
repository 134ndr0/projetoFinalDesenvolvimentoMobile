import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // Instância do plugin
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    // Configuração para o Android (usa o ícone padrão do aplicativo)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // Inicializa o plugin
    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
    );
    
    // Solicita permissão para exibir notificações (Obrigatório para Android 13+)
    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Dispara a notificação visual na tela do celular
  Future<void> showNotification({required String title, required String body}) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'monitor_alerta_id', // ID único do canal
      'Alertas de Queda',   // Nome do canal visível nas configurações do celular
      channelDescription: 'Canal para avisar quando um site monitorado cair',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );
    
    // Exibe a notificação de fato
    await _localNotificationsPlugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000, 
      title: title, 
      body: body, 
      notificationDetails: notificationDetails,
    );
  }
}