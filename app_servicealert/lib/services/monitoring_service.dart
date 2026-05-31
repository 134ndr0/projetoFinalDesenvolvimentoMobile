import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MonitoringService {
  //Adicione a chave de api BREVO
  final String _brevoApiKey = '.';
  
  final String _emailRemetente = 'leandro.jc.coelho@gmail.com'; 
  
  /// Função que checa se o site está online
  Future<bool> checkServiceStatus(String url) async {
    try {
      String formattedUrl = url.startsWith('http') ? url : 'https://$url';
      Uri uri = Uri.parse(formattedUrl);
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      return false; 
    }
  }

  Future<void> sendEmailAlert(String serviceName, String targetEmail) async {
    debugPrint('📧 Tentando enviar e-mail de alerta para: $targetEmail...');

    final Uri url = Uri.parse('https://api.brevo.com/v3/smtp/email');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'api-key': _brevoApiKey,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "sender": {
            "name": "Monitor Flutter",
            "email": _emailRemetente
          },
          "to": [
            {
              "email": targetEmail, // Usa o e-mail que o usuário digitou na tela
              "name": "Administrador do Sistema"
            }
          ],
          "subject": "🚨 ALERTA: O serviço $serviceName CAIU!",
          "textContent": "Atenção!\n\nO sistema de monitoramento identificou que o serviço '$serviceName' está fora do ar.\n\nVerifique o servidor o quanto antes.",
        }),
      );

      if (response.statusCode == 201) {
        debugPrint('✅ E-mail enviado com sucesso para $targetEmail!');
      } else {
        debugPrint('❌ Erro da API do Brevo: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Erro de conexão com o servidor do Brevo: $e');
    }
  }
}
