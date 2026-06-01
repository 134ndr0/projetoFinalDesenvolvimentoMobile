import 'dart:async';
import 'dart:ui'; // NOVO: Obrigatório para o DartPluginRegistrant
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'database_service.dart';
import 'monitoring_service.dart';
import 'notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
      
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'monitor_alerta_id', 
    'Alertas de Queda',   
    description: 'Canal para avisar quando um site monitorado cair',
    importance: Importance.max,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true, 
      notificationChannelId: 'monitor_alerta_id',
      initialNotificationTitle: 'Monitor Ativo',
      initialNotificationContent: 'Vigiando seus servidores...',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
    ),
  );

  await service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // 1. CORREÇÃO: Obrigatório inicializar o motor e os plugins do Flutter dentro do Isolate!
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized(); 

  final dbService = DatabaseService.instance;
  final monitoringService = MonitoringService();
  final notificationService = NotificationService();
  
  // 2. CORREÇÃO: Usar estritamente a versão leve focada no Background (sem interações com tela)
  await notificationService.initNotificationForBackground();

  // Cria o Timer imortal de 5 minutos
  Timer.periodic(const Duration(minutes: 5), (timer) async {
    debugPrint('🔄 [BACKGROUND] Iniciando checagem...');

    try {
      final prefs = await SharedPreferences.getInstance();
      String? deviceUuid = prefs.getString('device_uuid');

      if (deviceUuid != null) {
        final servicos = await dbService.getServicesByUuid(deviceUuid);

        for (var s in servicos) {
          bool isOnline = await monitoringService.checkServiceStatus(s.url);
          
          if (!isOnline) {
            final DateTime agora = DateTime.now();
            if (s.lastAlertTime == null || agora.difference(s.lastAlertTime!).inMinutes >= 10) {
              
              await notificationService.showNotification(
                title: '🚨 ${s.name} Caiu!',
                body: 'O serviço não está respondendo. Verifique agora.',
              );
              
              s.lastAlertTime = agora;
              s.isOnline = false;
              await dbService.updateService(s);
            }
          } else if (s.isOnline == false) {
            s.isOnline = true;
            await dbService.updateService(s);
          }
        }

        // Avisa a tela que os status foram atualizados
        service.invoke('update_tela', {
          "hora_checagem": DateTime.now().toIso8601String(),
        });
      } else {
        debugPrint('⚠️ [BACKGROUND] UUID ainda não foi gerado pela interface do app.');
      }

      service.invoke('update', {
        "last_check": DateTime.now().toIso8601String(),
      });

    } catch (e) {
      debugPrint('❌ [BACKGROUND] Erro crítico na execução do Timer: $e');
    }
  });
}