import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:manga_library/core/constants/app_constants.dart';
import 'package:manga_library/core/theme/app_colors.dart';
import 'package:manga_library/presentation/controllers/library_controller.dart';
import 'package:manga_library/presentation/controllers/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _confirmClearData(BuildContext context, SettingsController settingsCtrl, LibraryController libraryCtrl) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancellare tutti i dati?'),
          content: const Text(
            'Questa operazione eliminerà definitivamente tutti i manga salvati nella tua libreria, i progressi e le note.\n\nQuesta azione non può essere annullata.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final nav = Navigator.of(dialogContext);
                await libraryCtrl.clearAll();
                await settingsCtrl.clearAllData();
                nav.pop();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Tutti i dati locali sono stati eliminati')),
                );
              },
              child: const Text('Elimina tutto'),
            ),
          ],
        );
      },
    );
  }

  void _confirmClearCache(BuildContext context, SettingsController settingsCtrl) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Svuota cache temporanea'),
          content: const Text(
            'La cache contiene le risposte API salvate per velocizzare l\'app e consentire la visualizzazione offline.\n\nI tuoi manga salvati nella libreria NON verranno toccati.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final nav = Navigator.of(dialogContext);
                await settingsCtrl.clearCache();
                nav.pop();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Cache temporanea svuotata')),
                );
              },
              child: const Text('Svuota cache'),
            ),
          ],
        );
      },
    );
  }

  void _showExportDialog(BuildContext context, SettingsController settingsCtrl) async {
    final jsonStr = await settingsCtrl.exportLibrary();
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Backup Libreria JSON'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Copia il payload JSON sottostante per eseguire un backup manuale dei tuoi dati:'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  height: 160,
                  child: SingleChildScrollView(
                    child: SelectableText(
                      jsonStr,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Chiudi'),
            ),
          ],
        );
      },
    );
  }

  void _showImportDialog(BuildContext context, SettingsController settingsCtrl, LibraryController libraryCtrl) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Importa Libreria JSON'),
          content: TextField(
            controller: textController,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'Incolla qui il JSON della libreria...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final nav = Navigator.of(dialogContext);
                try {
                  await settingsCtrl.importLibrary(textController.text.trim());
                  await libraryCtrl.loadLibrary();
                  nav.pop();
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Libreria importata con successo')),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Formato JSON non valido')),
                  );
                }
              },
              child: const Text('Importa'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsCtrl = context.watch<SettingsController>();
    final libraryCtrl = context.watch<LibraryController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // Sezione Aspetto
          _buildSectionHeader(context, 'Aspetto & Tema'),
          ListTile(
            title: const Text('Tema Scuro'),
            subtitle: const Text('Design moderno scuro ad alto contrasto'),
            leading: const Icon(Icons.dark_mode_outlined),
            trailing: settingsCtrl.themeMode == ThemeMode.dark ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
            onTap: () => settingsCtrl.setThemeMode(ThemeMode.dark),
          ),
          ListTile(
            title: const Text('Tema Chiaro'),
            subtitle: const Text('Design luminoso ad alta leggibilità'),
            leading: const Icon(Icons.light_mode_outlined),
            trailing: settingsCtrl.themeMode == ThemeMode.light ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
            onTap: () => settingsCtrl.setThemeMode(ThemeMode.light),
          ),
          ListTile(
            title: const Text('Tema di Sistema'),
            subtitle: const Text('Segue l\'impostazione del tuo dispositivo'),
            leading: const Icon(Icons.brightness_auto_outlined),
            trailing: settingsCtrl.themeMode == ThemeMode.system ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
            onTap: () => settingsCtrl.setThemeMode(ThemeMode.system),
          ),

          const Divider(height: 24),

          // Sezione Accessibilità & Animazioni
          _buildSectionHeader(context, 'Accessibilità & Movimento'),
          SwitchListTile(
            title: const Text('Riduci Animazioni'),
            subtitle: const Text('Disattiva gli effetti di transizione più marcati'),
            value: settingsCtrl.reduceAnimations,
            onChanged: settingsCtrl.toggleReduceAnimations,
          ),
          ListTile(
            leading: const Icon(Icons.school_outlined),
            title: const Text('Guida e Tutorial'),
            subtitle: const Text('Rivedi la guida introduttiva alle funzionalità'),
            onTap: () {
              settingsCtrl.resetTutorial();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tutorial reimpostato. Lo vedrai nella schermata principale.')),
              );
            },
          ),

          const Divider(height: 24),

          // Sezione Cache & Rete
          _buildSectionHeader(context, 'Memoria & Cache API'),
          ListTile(
            leading: const Icon(Icons.cached_rounded),
            title: const Text('Svuota Cache Temporanea'),
            subtitle: Text('Dimensione attuale: ${settingsCtrl.cacheSizeFormatted}'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _confirmClearCache(context, settingsCtrl),
          ),

          const Divider(height: 24),

          // Sezione Backup & Dati Locali
          _buildSectionHeader(context, 'Gestione Dati Locali'),
          ListTile(
            leading: const Icon(Icons.file_download_outlined),
            title: const Text('Esporta Backup JSON'),
            subtitle: Text('Libreria salvata: ${settingsCtrl.storageSizeFormatted}'),
            onTap: () => _showExportDialog(context, settingsCtrl),
          ),
          ListTile(
            leading: const Icon(Icons.file_upload_outlined),
            title: const Text('Importa Backup JSON'),
            subtitle: const Text('Ripristina una libreria salvata in precedenza'),
            onTap: () => _showImportDialog(context, settingsCtrl, libraryCtrl),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever_rounded, color: AppColors.error),
            title: const Text('Cancella Tutti i Dati Locali', style: TextStyle(color: AppColors.error)),
            subtitle: const Text('Elimina l\'intera libreria dal dispositivo'),
            onTap: () => _confirmClearData(context, settingsCtrl, libraryCtrl),
          ),

          const Divider(height: 24),

          // Sezione Informazioni
          _buildSectionHeader(context, 'Informazioni Applicazione'),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('Versione'),
            subtitle: const Text('${AppConstants.appName} v${AppConstants.appVersion}'),
          ),
          ListTile(
            leading: const Icon(Icons.api_rounded),
            title: const Text('Fornitore Dati API'),
            subtitle: const Text('Jikan REST API v4 (MyAnimeList open data)\nRate limit: 3 req/sec con backoff'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
      ),
    );
  }
}
