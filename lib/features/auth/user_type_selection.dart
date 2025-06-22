import 'package:flutter/material.dart';

class UserTypeSelectionScreen extends StatelessWidget {
  const UserTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selecione o Tipo de Usuário'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildUserTypeOption(
            context,
            'Tutor',
            'Gerenciar pets e agendar serviços',
            Icons.pets,
            'tutor',
          ),
          const SizedBox(height: 12),
          _buildUserTypeOption(
            context,
            'Veterinário',
            'Oferecer serviços veterinários',
            Icons.medical_services,
            'veterinario',
          ),
          const SizedBox(height: 12),
          _buildUserTypeOption(
            context,
            'Lojista',
            'Vender produtos para pets',
            Icons.store,
            'lojista',
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeOption(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    String value,
  ) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF667eea),
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
} 