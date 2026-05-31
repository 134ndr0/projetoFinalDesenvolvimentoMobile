// Arquivo: lib/main.dart
import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'pages/dashboard_page.dart';
import 'services/background_service.dart';

void main() async {
  // Garante que os recursos do Flutter estejam prontos antes de iniciar o serviço
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa o serviço de notificações
  await NotificationService().initNotification();
  await initializeBackgroundService();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Monitor de Serviços',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: const DashboardPage(),
    );
  }
}