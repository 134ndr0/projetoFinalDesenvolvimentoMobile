import 'package:flutter/material.dart';
import '../models/service_model.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback? onFavoriteToggled;
  final VoidCallback? onEditPressed;

  const ServiceCard({
    super.key,
    required this.service,
    this.onFavoriteToggled,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
          leading: Icon(
                service.isOnline! ? Icons.check_circle : Icons.error,
                color: service.isOnline! ? Colors.green : Colors.red,
                size: 32,
              ),
        title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(service.url),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botão de Editar
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blueGrey),
              onPressed: onEditPressed,
            ),
            // Botão de Favorito
            if (onFavoriteToggled != null)
              IconButton(
                icon: Icon(
                  service.isFavorite ? Icons.star : Icons.star_border,
                  color: service.isFavorite ? Colors.amber : Colors.grey,
                ),
                onPressed: onFavoriteToggled,
              ),
          ],
        ),
      ),
    );
  }
}