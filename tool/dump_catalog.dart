import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Script di Utilità per Dump Locale Offline del Catalogo Manga.
///
/// NOTE LEGALI & GIT:
/// La cartella 'dump/' e tutti i file '*.dump.json' sono inclusi in .gitignore
/// e NON verranno mai committati o tracciati su Git.
///
/// UTILIZZO:
///   dart run tool/dump_catalog.dart
///   oppure
///   dart run tool/dump_catalog.dart --download-covers
void main(List<String> args) async {
  final bool downloadCovers = args.contains('--download-covers');
  final int count = 50;

  stdout.writeln('====================================================');
  stdout.writeln('  MANGAFLOW - TOOL DI DUMP LOCALE DEL CATALOGO');
  stdout.writeln('====================================================');
  stdout.writeln('Scaricamento dei primi $count manga da AniList API...');
  if (downloadCovers) {
    stdout.writeln('Modalità copertine: Download offline in dump/covers/');
  }

  final dumpDir = Directory('dump');
  if (!dumpDir.existsSync()) {
    dumpDir.createSync(recursive: true);
  }

  final coversDir = Directory('dump/covers');
  if (downloadCovers && !coversDir.existsSync()) {
    coversDir.createSync(recursive: true);
  }

  const String graphQLQuery = '''
    query (\$perPage: Int) {
      Page(page: 1, perPage: \$perPage) {
        media(type: MANGA, sort: POPULARITY_DESC) {
          id
          title {
            romaji
            english
            native
          }
          description(asHtml: false)
          coverImage {
            extraLarge
            large
            medium
          }
          genres
          staff {
            nodes {
              name {
                full
              }
            }
          }
          status
          chapters
          volumes
          averageScore
          popularity
          startDate {
            year
            month
            day
          }
          format
        }
      }
    }
  ''';

  final client = http.Client();
  try {
    final response = await client.post(
      Uri.parse('https://graphql.anilist.co'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'query': graphQLQuery,
        'variables': {'perPage': count},
      }),
    );

    if (response.statusCode != 200) {
      stderr.writeln('Errore HTTP API: ${response.statusCode}');
      stderr.writeln(response.body);
      exit(1);
    }

    final Map<String, dynamic> jsonResponse =
        jsonDecode(response.body) as Map<String, dynamic>;
    final mediaList =
        jsonResponse['data']?['Page']?['media'] as List<dynamic>? ?? [];

    stdout.writeln('Ricevuti ${mediaList.length} manga. Elaborazione...');

    final List<Map<String, dynamic>> processedList = [];

    for (int i = 0; i < mediaList.length; i++) {
      final item = Map<String, dynamic>.from(mediaList[i] as Map);
      final id = item['id'];
      final titles = item['title'] as Map<String, dynamic>?;
      final title = titles?['romaji'] ?? titles?['english'] ?? 'Senza Titolo';

      stdout.writeln(' [${i + 1}/${mediaList.length}] ID: $id - $title');

      if (downloadCovers) {
        final coverMap = item['coverImage'] as Map<String, dynamic>?;
        final coverUrl =
            coverMap?['extraLarge'] ??
            coverMap?['large'] ??
            coverMap?['medium'];
        if (coverUrl != null && coverUrl.toString().isNotEmpty) {
          try {
            final imgRes = await client.get(Uri.parse(coverUrl.toString()));
            if (imgRes.statusCode == 200) {
              final imgFile = File('dump/covers/$id.jpg');
              await imgFile.writeAsBytes(imgRes.bodyBytes);
              stdout.writeln('   -> Copertina salvata in dump/covers/$id.jpg');
              item['local_cover_path'] = 'dump/covers/$id.jpg';
            }
          } catch (e) {
            stdout.writeln('   -> Errore download copertina $id: $e');
          }
        }
      }

      processedList.add(item);
    }

    final dumpData = {
      'exported_at': DateTime.now().toIso8601String(),
      'count': processedList.length,
      'source': 'AniList GraphQL API',
      'items': processedList,
    };

    final dumpFile = File('dump/manga_catalog_dump.json');
    await dumpFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(dumpData),
    );

    stdout.writeln('====================================================');
    stdout.writeln('DUMP COMPLETATO CON SUCCESSO!');
    stdout.writeln('File generato: ${dumpFile.path} (${dumpData['count']} manga)');
    stdout.writeln('Nota: Questo file e la cartella dump/ sono protetti e ignorati da Git.');
    stdout.writeln('====================================================');
  } catch (e) {
    stderr.writeln('Eccezione durante il dump: $e');
    exit(1);
  } finally {
    client.close();
  }
}
