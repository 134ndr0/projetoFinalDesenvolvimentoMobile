import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:uuid/uuid.dart';
import 'database_service.dart';
import 'monitoring_service.dart';
import 'notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true, // Mantém o app vivo com uma notificação fixa
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

// O pragma é obrigatório para que o código sobreviva fora da tela
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final dbService = DatabaseService.instance;
  final monitoringService = MonitoringService();
  final notificationService = NotificationService();
  
  await notificationService.initNotification();

  // Cria o Timer imortal de 5 minutos
  Timer.periodic(const Duration(minutes: 5), (timer) async {
    debugPrint('🔄 [BACKGROUND] Iniciando checagem...');

    // 1. Acessa a mesma "caixa forte" que a UI utilizou
    final prefs = await SharedPreferences.getInstance();
    
    // 2. Recupera o UUID salvo pelo dispositivo
    String? deviceUuid = prefs.getString('device_uuid');

    // 3. Segurança: Só roda se o UUID já tiver sido gerado pela tela inicial
    if (deviceUuid != null) {
      
      // 4. AGORA SIM! Passa o UUID correto para buscar apenas os sites deste aparelho
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
    } else {
      debugPrint('⚠️ [BACKGROUND] UUID ainda não foi gerado pela interface do app.');
    }
    
    service.invoke('update', {
      "current_date": DateTime.now().toIso8601String(),
    });
  });
}