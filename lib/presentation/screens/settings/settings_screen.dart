import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:manga_library/core/constants/app_constants.dart';
import 'package:manga_library/core/theme/app_colors.dart';
import 'package:manga_library/core/theme/app_radii.dart';
import 'package:manga_library/core/theme/app_typography.dart';
import 'package:manga_library/presentation/controllers/library_controller.dart';
import 'package:manga_library/presentation/controllers/settings_controller.dart';
import 'package:manga_library/presentation/widgets/editorial_section_header.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _confirmClearData(BuildContext context, SettingsController settingsCtrl, LibraryController libraryCtrl) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('CANCELLARE TUTTI I DATI?'),
          content: const Text(
            'Questa operazione eliminerà definitivamente tutti i manga salvati nel catalogo, i capitoli segnati, i volumi e le note.\n\nL\'azione non è reversibile.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.editorialRed),
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
              child: const Text('ELIMINA TUTTO'),
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
          title: const Text('SVUOTA CACHE TEMPORANEA'),
          content: const Text(
            'La cache memorizza le risposte del catalogo per consentire la visualizzazione offline rapida.\n\nI manga salvati nella tua collezione NON verranno cancellati.',
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
              child: const Text('SVUOTA CACHE'),
            ),
          ],
        );
      },
    );
  }

  void _showExportDialog(BuildContext context, SettingsController settingsCtrl) async {
    final jsonStr = await settingsCtrl.exportLibrary();
    if (!context.mounted) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('BACKUP CATALOGO JSON'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Copia il testo JSON per conservare un backup manuale della tua collezione:'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.nightSurfaceVariant : AppColors.paperSurfaceVariant,
                    borderRadius: AppRadii.brXs,
                    border: Border.all(
                      color: isDark ? AppColors.nightBorder : AppColors.paperBorder,
                    ),
                  ),
                  height: 160,
                  child: SingleChildScrollView(
                    child: SelectableText(
                      jsonStr,
                      style: AppTypography.volumeMono(
                        isDark: isDark,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('CHIUDI'),
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
          title: const Text('IMPORTA CATALOGO JSON'),
          content: TextField(
            controller: textController,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'Incolla qui il codice JSON del catalogo...',
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
                    const SnackBar(content: Text('Catalogo importato con successo')),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Formato JSON non valido')),
                  );
                }
              },
              child: const Text('IMPORTA'),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'IMPOSTAZIONI',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              'CONFIGURAZIONE CATALOGO • 設定',
              style: AppTypography.volumeMono(
                isDark: isDark,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.nightInkMuted : AppColors.inkMuted,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // Sezione 01: Aspetto & Tema
          const EditorialSectionHeader(
            index: '01',
            title: 'ASPETTO E TEMA',
            subtitle: 'Stile di stampa e contrasto',
          ),
          ListTile(
            title: const Text('Night Bookstore (Scuro)'),
            subtitle: const Text('Atmosfera libreria serale con accenti rosso inchiostro'),
            trailing: settingsCtrl.themeMode == ThemeMode.dark
                ? const Icon(Icons.check_rounded, color: AppColors.editorialRed, size: 20)
                : null,
            onTap: () => settingsCtrl.setThemeMode(ThemeMode.dark),
          ),
          ListTile(
            title: const Text('Stampa su Carta (Chiaro)'),
            subtitle: const Text('Toni caldi avorio/carta con inchiostro nero e vermiglio'),
            trailing: settingsCtrl.themeMode == ThemeMode.light
                ? const Icon(Icons.check_rounded, color: AppColors.editorialRed, size: 20)
                : null,
            onTap: () => settingsCtrl.setThemeMode(ThemeMode.light),
          ),
          ListTile(
            title: const Text('Segui Sistema Operativo'),
            subtitle: const Text('Sincronizza automaticamente con il dispositivo'),
            trailing: settingsCtrl.themeMode == ThemeMode.system
                ? const Icon(Icons.check_rounded, color: AppColors.editorialRed, size: 20)
                : null,
            onTap: () => settingsCtrl.setThemeMode(ThemeMode.system),
          ),

          const SizedBox(height: 16),

          // Sezione 02: Accessibilità & Movimento
          const EditorialSectionHeader(
            index: '02',
            title: 'ACCESSIBILITÀ E GUIDA',
          ),
          SwitchListTile(
            activeTrackColor: AppColors.editorialRed,
            title: const Text('Riduci Animazioni'),
            subtitle: const Text('Minimizza le transizioni e gli effetti di sfoglio'),
            value: settingsCtrl.reduceAnimations,
            onChanged: settingsCtrl.toggleReduceAnimations,
          ),
          ListTile(
            title: const Text('Guida e Tutorial Iniziale'),
            subtitle: const Text('Rivedi la guida alle funzioni del catalogo'),
            onTap: () {
              settingsCtrl.resetTutorial();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Guida reimpostata. Sarà mostrata nella schermata principale.')),
              );
            },
          ),

          const SizedBox(height: 16),

          // Sezione 03: Memoria & Dati Locali
          const EditorialSectionHeader(
            index: '03',
            title: 'MEMORIA E DATI LOCALI',
          ),
          ListTile(
            title: const Text('Svuota Cache Temporanea'),
            subtitle: Text('Memoria occupata: ${settingsCtrl.cacheSizeFormatted}'),
            trailing: const Icon(Icons.chevron_right_rounded, size: 20),
            onTap: () => _confirmClearCache(context, settingsCtrl),
          ),
          ListTile(
            title: const Text('Esporta Backup JSON'),
            subtitle: Text('Dimensioni collezione: ${settingsCtrl.storageSizeFormatted}'),
            onTap: () => _showExportDialog(context, settingsCtrl),
          ),
          ListTile(
            title: const Text('Importa Backup JSON'),
            subtitle: const Text('Ripristina una collezione salvata in precedenza'),
            onTap: () => _showImportDialog(context, settingsCtrl, libraryCtrl),
          ),
          ListTile(
            title: const Text('Cancella Tutti i Dati Locali', style: TextStyle(color: AppColors.editorialRed)),
            subtitle: const Text('Elimina definitivamente la libreria dal dispositivo'),
            onTap: () => _confirmClearData(context, settingsCtrl, libraryCtrl),
          ),

          const SizedBox(height: 16),

          // Sezione 04: Informazioni
          const EditorialSectionHeader(
            index: '04',
            title: 'INFORMAZIONI EDITORIALI',
          ),
          ListTile(
            leading: ClipRRect(
              borderRadius: AppRadii.brXs,
              child: Image.asset(
                'assets/icons/app_logo.png',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
              ),
            ),
            title: const Text('Applicazione'),
            subtitle: const Text('${AppConstants.appName} • Versione ${AppConstants.appVersion}'),
          ),
          ListTile(
            title: const Text('Catalogo Dati Remoto'),
            subtitle: const Text('AniList GraphQL Open API • Dati ufficiali in tempo reale'),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
