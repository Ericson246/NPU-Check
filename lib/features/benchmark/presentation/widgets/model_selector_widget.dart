import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/model_type.dart';

class ModelSelectorWidget extends StatelessWidget {
  final ModelType selectedModel;
  final Function(ModelType) onModelSelected;
  
  const ModelSelectorWidget({
    super.key,
    required this.selectedModel,
    required this.onModelSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkBgSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neonCyan.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MODELO DE IA',
            style: TextStyle(
              color: AppTheme.neonCyan,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButton<ModelType>(
            value: selectedModel,
            isExpanded: true,
            dropdownColor: AppTheme.darkBgSecondary,
            style: const TextStyle(color: AppTheme.textPrimary),
            underline: Container(
              height: 1,
              color: AppTheme.neonCyan.withOpacity(0.3),
            ),
            items: ModelType.values.map((model) {
              return DropdownMenuItem(
                value: model,
                child: Row(
                  children: [
                    Icon(
                      model.isEmbedded ? Icons.check_circle : Icons.download,
                      color: model.isEmbedded ? AppTheme.neonCyan : AppTheme.neonMagenta,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            model.displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            model.description,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (ModelType? newModel) {
              if (newModel != null) {
                _handleModelSelection(context, newModel);
              }
            },
          ),
        ],
      ),
    );
  }
  
  void _handleModelSelection(BuildContext context, ModelType newModel) {
    if (newModel.isEmbedded) {
      // Modelo embebido - seleccionar directamente
      onModelSelected(newModel);
    } else {
      // Modelo descargable - mostrar advertencia
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.darkBgSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppTheme.neonMagenta.withOpacity(0.3)),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber, color: AppTheme.neonMagenta),
              const SizedBox(width: 8),
              const Text(
                'Descarga Requerida',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            'Este modelo requiere descargar ${newModel.sizeMB.toStringAsFixed(0)} MB a tu dispositivo.\n\n¿Deseas continuar?',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onModelSelected(newModel);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonCyan,
                foregroundColor: AppTheme.darkBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Descargar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }
  }
}
