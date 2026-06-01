// Arquivo: lib/main.dart
import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'pages/dashboard_page.dart';
import 'services/background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notificationService = NotificationService();
  await notificationService.initNotification(); 

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