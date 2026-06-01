import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Canal estático para que ambos os lados usem a mesma configuração física no Android
  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'monitor_alerta_id', 
    'Alertas de Queda',   
    description: 'Canal para avisar quando um site monitorado cair',
    importance: Importance.max,
    playSound: true,
  );

  /// 1. INICIALIZAÇÃO PARA A TELA (DASHBOARD)
  /// Pede permissões e registra o canal visualmente.
  Future<void> initNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotificationsPlugin.initialize(
      settings: initializationSettings, 
    );
    
    // Cria o canal no sistema operacional
    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // SOLICITA PERMISSÃO (Apenas aqui na UI onde há tela!)
    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// 2. INICIALIZAÇÃO SEGURA PARA O BACKGROUND
  /// Versão leve: SEM pedir permissões e SEM tocar na UI.
  Future<void> initNotificationForBackground() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // Inicializa estritamente o motor de envio, sem interações de tela
    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
    );
  }

  /// Dispara a notificação visual
  Future<void> showNotification({required String title, required String body}) async {
    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );
    
    await _localNotificationsPlugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000, 
      title: title, 
      body: body, 
      notificationDetails: notificationDetails,
    );
  }
}