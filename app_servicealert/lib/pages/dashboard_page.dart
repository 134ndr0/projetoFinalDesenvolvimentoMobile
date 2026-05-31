import 'dart:async';
import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../widgets/service_card.dart';
import '../services/monitoring_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final MonitoringService _monitoringService = MonitoringService();
  Timer? _timer;

  // Controlador para capturar o e-mail digitado pelo usuário
  final TextEditingController _emailController = TextEditingController(text: 'seu-email-teste@gmail.com');

  final List<ServiceModel> _services = [
    ServiceModel(name: 'Google (Simulado Fora)', url: 'https://google-fora-do-ar-teste.com', isOnline: true, isFavorite: true),
    ServiceModel(name: 'Github', url: 'https://github.com', isOnline: true, isFavorite: false),
    ServiceModel(name: 'Github', url: 'https://sistemalogui.com.br', isOnline: true, isFavorite: false),
  ];

  @override
  void initState() {
    super.initState();
    _checkAllServices();
    _timer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _checkAllServices();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose(); // importante fechar o controller para evitar vazamento de memória!
    super.dispose();
  }

  Future<void> _checkAllServices() async {
    debugPrint('🔄 Iniciando checagem dos sites...');
    
    // e-mail atual digitado no campo de texto
    String emailDestino = _emailController.text.trim();

    for (var service in _services) {
      bool isNowOnline = await _monitoringService.checkServiceStatus(service.url);
      
      setState(() {
        service.isOnline = isNowOnline;
      });

      if (!service.isOnline) {
        if (emailDestino.isEmpty) {
          debugPrint('⚠️ Alerta não enviado: Nenhum e-mail de destino foi informado na tela.');
          continue; 
        }

        final DateTime agora = DateTime.now();

        if (service.lastAlertTime == null || 
            agora.difference(service.lastAlertTime!).inMinutes >= 10) {
          
          // Passamos o e-mail digitado como segundo parâmetro
          await _monitoringService.sendEmailAlert(service.name, emailDestino);
          
          service.lastAlertTime = agora;
        } else {
          int minutosRestantes = 10 - agora.difference(service.lastAlertTime!).inMinutes;
          debugPrint('⏳ "${service.name}" continua fora do ar. Próximo e-mail em $minutosRestantes minutos.');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status dos Serviços', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _checkAllServices(),
          )
        ],
      ),
      body: Column(
        children: [
          // SEÇÃO DE CONFIGURAÇÃO DO E-MAIL
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configuração de Alertas',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'E-mail de Destino',
                        hintText: 'Digite o e-mail para receber os alertas',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // LISTA DE SERVIÇOS
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _services.length,
              itemBuilder: (context, index) {
                final service = _services[index];
                return ServiceCard(
                  service: service,
                  onFavoriteToggled: () {
                    setState(() {
                      service.isFavorite = !service.isFavorite;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}