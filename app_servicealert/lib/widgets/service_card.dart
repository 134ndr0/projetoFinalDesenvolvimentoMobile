import 'package:flutter/material.dart';
import '../models/service_model.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onFavoriteToggled;

  const ServiceCard({
    super.key,
    required this.service,
    required this.onFavoriteToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: CircleAvatar(
          backgroundColor: service.isOnline ? Colors.green[100] : Colors.red[100],
          child: Icon(
            service.isOnline ? Icons.check_circle : Icons.error,
            color: service.isOnline ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          service.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(service.url),
        trailing: IconButton(
          icon: Icon(
            service.isFavorite ? Icons.star : Icons.star_border,
            color: service.isFavorite ? Colors.amber : Colors.grey,
          ),
          onPressed: onFavoriteToggled, // Aciona a função recebida da página principal
        ),
      ),
    );
  }
}