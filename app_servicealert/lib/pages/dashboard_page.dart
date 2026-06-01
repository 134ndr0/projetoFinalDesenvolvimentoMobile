import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/service_model.dart';
import '../widgets/service_card.dart';
import '../services/monitoring_service.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart'; 

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final NotificationService _notificationService = NotificationService();
  final MonitoringService _monitoringService = MonitoringService();
  final DatabaseService _dbService = DatabaseService.instance;

  String _proxVerificacaoText = "Calculando..."; 
  List<ServiceModel> _services = [];
  String _deviceUuid = '';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Executa a checagem manual e exibe o feedback visual exato solicitado
  Future<void> _atualizarManualmente() async {
    // 1. Roda a checagem manual dos sites na tela
    await _checkAllServices();
    
    // 2. Após checar manualmente, atualiza provisoriamente a previsão na tela
    _atualizarPrevisaoProximaChecagem();
    
    // 3. Verifica se existe algum sistema fora do ar na lista atual
    bool temSistemaForaDoAr = _services.any((service) => !service.isOnline);
    
    // 4. Define as mensagens exatamente como solicitado
    String mensagem = temSistemaForaDoAr 
        ? '⚠️ Ainda existem serviços fora do ar. Verifique!' 
        : '😃 Está tudo certo.';
    
    // 5. Exibe o balão de aviso (SnackBar) na parte inferior da tela
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Inicializa o UUID e configura a escuta ativa do Segundo Plano
  Future<void> _initializeApp() async {
    await _notificationService.initNotification();

    final prefs = await SharedPreferences.getInstance();
    String? savedUuid = prefs.getString('device_uuid');
    
    if (savedUuid == null) {
      savedUuid = const Uuid().v4();
      await prefs.setString('device_uuid', savedUuid);
    }

    setState(() {
      _deviceUuid = savedUuid!; 
    });
    
    await _loadServicesFromDatabase();
    _atualizarPrevisaoProximaChecagem(); // Previsão inicial calculada ao abrir o app

    // Sempre que o background rodar a checagem de 5 em 5 minutos, ele dispara este bloco:
    FlutterBackgroundService().on('update').listen((event) {
      if (event != null && event['current_date'] != null) {
        final DateTime ultimaChecagemBackground = DateTime.parse(event['current_date']);
        final DateTime proximaExecucao = ultimaChecagemBackground.add(const Duration(minutes: 5));
        
        final String horaFormatada = 
            "${proximaExecucao.hour.toString().padLeft(2, '0')}:${proximaExecucao.minute.toString().padLeft(2, '0')}:${proximaExecucao.second.toString().padLeft(2, '0')}";
        
        if (mounted) {
          setState(() {
            _proxVerificacaoText = horaFormatada; // Atualiza o relógio da próxima verificação
          });
          _loadServicesFromDatabase(); // Recarrega a tela com as atualizações que o background fez no SQLite
        }
      }
    });
  }

  /// Método auxiliar para calcular uma previsão baseada no horário atual
  void _atualizarPrevisaoProximaChecagem() {
    final DateTime agora = DateTime.now();
    final DateTime proxima = agora.add(const Duration(minutes: 5));
    
    final String horaFormatada = 
        "${proxima.hour.toString().padLeft(2, '0')}:${proxima.minute.toString().padLeft(2, '0')}:${proxima.second.toString().padLeft(2, '0')}";
    
    setState(() {
      _proxVerificacaoText = horaFormatada;
    });
  }

  /// Carrega os dados salvos no SQLite filtrando pelo UUID do aparelho
  Future<void> _loadServicesFromDatabase() async {
    final databaseServices = await _dbService.getServicesByUuid(_deviceUuid);

    for (var novoServico in databaseServices) {
      // Procura se este serviço já existia na lista velha
      int indexAntigo = _services.indexWhere((s) => s.id == novoServico.id);
      
      if (indexAntigo != -1) {
        // Se existia, copia o status online/offline e a hora do último alerta
        novoServico.isOnline = _services[indexAntigo].isOnline;
        novoServico.lastAlertTime = _services[indexAntigo].lastAlertTime;
      }
    }

    // Agora sim, atualiza a tela com os serviços novos + status preservados
    setState(() {
      _services = databaseServices;
    });
  }

  /// Varre os serviços testando a conexão de cada um
  Future<void> _checkAllServices() async {
    debugPrint('🔄 Iniciando checagem manual dos sites...');
    for (var service in _services) {
      bool isNowOnline = await _monitoringService.checkServiceStatus(service.url);
      
      setState(() {
        service.isOnline = isNowOnline;
      });
      
      // 2. Lógica de controle da Notificação
      if (!isNowOnline) {
        final DateTime agora = DateTime.now();
        if (service.lastAlertTime == null || 
            agora.difference(service.lastAlertTime!).inMinutes >= 10) {
          
          await _notificationService.showNotification(
            title: '🚨 Serviço Fora do Ar!',
            body: 'O serviço "${service.name}" acabou de cair. Verifique!!.',
          );
          
          service.lastAlertTime = agora;
        }
      }
      await _dbService.updateService(service);
    }
  }

  /// Janela para cadastrar um novo site
  void _showAddServiceDialog() {
    final nameController = TextEditingController();
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Novo Serviço', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome do Serviço (Ex: Meu Blog)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(labelText: 'URL ou IP (Ex: google.com)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && urlController.text.isNotEmpty) {
                final newService = ServiceModel(
                  name: nameController.text,
                  url: urlController.text,
                  deviceUuid: _deviceUuid,
                );
                await _dbService.insertService(newService);
                if (mounted) Navigator.pop(context);
                _checkAllServices();
                _loadServicesFromDatabase();
                
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
            child: const Text('Salvar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Janela para editar ou excluir um serviço existente
  void _showEditServiceDialog(ServiceModel service) {
    final nameController = TextEditingController(text: service.name);
    final urlController = TextEditingController(text: service.url);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Serviço', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome do Serviço'),
            ),
            const SizedBox(height: 8, width: 10),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(labelText: 'URL ou IP'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              bool confirmar = await showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Excluir?'),
                      content: const Text('Tem certeza que deseja apagar este serviço?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Não')),
                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sim', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  ) ?? false;

              if (confirmar && service.id != null) {
                await _dbService.deleteService(service.id!);
                if (mounted) {
                  Navigator.pop(context);
                  _loadServicesFromDatabase();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Serviço excluído com sucesso!')));
                }
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
          
          const Spacer(),
          
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && urlController.text.isNotEmpty) {
                service.name = nameController.text;
                service.url = urlController.text;

                await _dbService.updateService(service);
                
                if (mounted) Navigator.pop(context);
                _loadServicesFromDatabase(); 
                _checkAllServices();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
            child: const Text('Salvar', style: TextStyle(color: Colors.white)),
          ),
        ],
        actionsAlignment: MainAxisAlignment.spaceBetween,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status dos Serviços', style: TextStyle(color: Color.fromARGB(255, 12, 69, 175), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color.fromARGB(255, 12, 69, 175)),
            onPressed: _atualizarManualmente, 
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddServiceDialog,
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.blueGrey[50],
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            child: Text(
              'ID do Dispositivo (UUID): $_deviceUuid',
              style: TextStyle(fontSize: 11, color: Colors.blueGrey[700], fontFamily: 'monospace'),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Card(
            color: Colors.blueGrey.shade50,
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Frequência de Checagem',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Automática a cada 5 minutos', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Próxima verificação:',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        _proxVerificacaoText,
                        style: const TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.blueGrey
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _services.isEmpty
                ? const Center(child: Text('Nenhum serviço cadastrado ainda.\nToque no botão + para adicionar!', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _services.length,
                    itemBuilder: (context, index) {
                      final service = _services[index];
                      return ServiceCard(
                        service: service,
                        onEditPressed: () => _showEditServiceDialog(service),
                        onFavoriteToggled: () async {
                          setState(() {
                            service.isFavorite = !service.isFavorite;
                          });
                          await _dbService.updateService(service);
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