# MangaFlow - Personal Manga Library

Applicazione mobile Flutter in lingua italiana per tracciare e organizzare le proprie letture manga.
Progettata con architettura modulare e pulita, offline-first, persistenza locale atomica in JSON e integrazione con API pubbliche documentate (Jikan REST API v4 / Kitsu REST API open data).

---

## Funzionalita Principali

1. **Ricerca Manga su Catalogo Reale**:
   - Connessione a API REST documentate per cercare tra decine di migliaia di manga reali.
   - Debounce automatico a 500ms sulla digitazione.
   - Paginazione infinita e caricamento progressivo con skeleton loader.
   - Esplorazione iniziale dei manga piu popolari quando il campo di ricerca e vuoto.

2. **Dettaglio Manga Completo**:
   - Copertina ad alta risoluzione con transizione Hero.
   - Titolo originale e internazionale, autori, generi, stato editoriale ("In corso", "Concluso", ecc.) e trama completa.
   - Valutazione della community globale.

3. **Gestione Libreria Personale**:
   - Organizzazione per stato di lettura: *In lettura*, *Da leggere*, *Completato*, *In pausa*, *Abbandonato*.
   - Contrassegno dei titoli preferiti.
   - Tracker tattile dei capitoli con pulsanti - / +, digitazione diretta e prompt di completamento automatico al raggiungimento dell'ultimo capitolo.
   - Valutazione personale a stelle (da 1 a 10).
   - Note e recensioni personali modificabili in qualsiasi momento.

4. **Home Dashboard**:
   - Saluto dinamico in italiano (*Buongiorno*, *Buon pomeriggio*, *Buonasera*).
   - Sezione *Continua a leggere* con i manga in corso e pulsante rapido per incrementare il capitolo letto.
   - Sezione *Aggiunti di recente* e *Da leggere*.
   - Statistiche rapide di riepilogo.

5. **Statistiche Reali in Tempo Reale**:
   - Calcolate esclusivamente sui dati della libreria locale (nessun dato inventato o fittizio).
   - Conteggio manga, capitoli letti, media voto e distribuzione percentuale per stato e generi.

6. **Offline-First & Caching Intelligente**:
   - Tutti i dati della libreria personale sono salvati localmente su file JSON e accessibili senza rete.
   - Cache su disco e RAM per le risposte API con TTL di 24 ore e fallback a dati stale in assenza di rete.

7. **Impostazioni & Manutenzione**:
   - Selezione del tema: Scuro, Chiaro o Automatico di sistema.
   - Accessibilita: interruttore per ridurre le animazioni di transizione.
   - Tutorial guidato ripetibile.
   - Ispezione e svuotamento sicuro della cache API (senza intaccare la libreria).
   - Esportazione e importazione del backup JSON della libreria.

---

## Architettura del Progetto

Il codice segue i principi della Clean Architecture con separazione rigorosa delle responsabilita:

```
lib/
├── core/
│   ├── constants/          # Parametri e limiti di sistema (AppConstants)
│   ├── errors/             # Failure ed Exception tipizzate
│   ├── network/            # RateLimiter a token-bucket e intervallo minimo
│   ├── theme/              # Design System (Colori, Tipografia Google Fonts, Temi M3)
│   └── utils/              # Debouncer, Throttler e Formattatori di date in italiano
│
├── data/
│   ├── api/                # Client REST API con backoff e fallback
│   ├── cache/              # HttpCacheManager persistente
│   ├── models/             # DTO (RemoteMangaDto universale, LibraryEntryDto)
│   ├── repositories/       # Implementazioni concrete (MangaRepositoryImpl, LibraryRepositoryImpl)
│   └── storage/            # JsonStorage atomico con lock asincrono e sistema di migrazione
│
├── domain/
│   ├── entities/           # Entita pure (Manga, LibraryEntry, ReadingStatus, LibraryStatistics)
│   └── repositories/       # Contratti astratti (MangaRepository, LibraryRepository)
│
├── presentation/
│   ├── controllers/        # Gestione dello stato reattivo con Provider (ChangeNotifier)
│   ├── screens/            # Schermate (Home, Library, Search, Detail, Statistics, Settings)
│   ├── tutorial/           # Sistema di onboarding guidato interattivo
│   └── widgets/            # Componenti UI (MangaCard, MangaListTile, ProgressStepper, etc.)
│
└── main.dart               # Entry point con Dependency Injection e MultiProvider
```

---

## Persistenza JSON & Affidabilita Atomica

Per evitare qualsiasi perdita o corruzione dei dati personali in caso di crash o interruzione improvvisa:
1. La libreria viene serializzata in memoria e convalidata.
2. Su piattaforme native viene scritta su un file temporaneo `library.json.tmp` con flush forzato su disco.
3. Viene verificata la completezza e la sintassi del file temporaneo.
4. Viene eseguita una sostituzione atomica con il file di destinazione `library.json`.
5. I salvataggi sono gestiti con debounce a 300ms per evitare carichi I/O eccessivi durante le modifiche rapide del contatore capitoli.
6. Il formato JSON e versionato (`version: 1`) ed e presente una pipeline automatica di migrazione schemi (`SchemaMigrationManager`).

---

## Gestione API, Documentazione & Rate Limiting

L'applicazione supporta le specifiche delle API aperte per manga (Jikan REST v4 documentata su `docs.api.jikan.moe` e Kitsu REST API):
- **RateLimiter**: implementato a livello client per rispettare le finestre di rate limiting ed evitare codici 429.
- **Exponential Backoff**: in caso di timeout o rate limit, l'app effettua tentativi controllati con backoff esponenziale.
- **Supporto Multi-Format**: `RemoteMangaDto` e in grado di decodificare sia le risposte REST di Jikan v4 che quelle di Kitsu in entita di dominio standard `Manga`.
- **Debounce**: le ricerche testuali scattano dopo 500ms dall'ultimo tasto premuto.

---

## Istruzioni di Setup & Esecuzione

### Requisiti
- Flutter SDK (versione 3.41 o superiore)
- Dart SDK (versione 3.11 o superiore)

### Installazione delle dipendenze
```bash
flutter pub get
```

### Verifica statica del codice
```bash
flutter analyze
```

### Esecuzione dei test automatici
```bash
flutter test
```

### Avvio dell'applicazione
```bash
flutter run
```

---

## Suite di Test Inclusa

- `test/unit/json_storage_test.dart`: verifica della scrittura/lettura atomica e delle migrazioni di versione.
- `test/unit/rate_limiter_test.dart`: verifica dei vincoli di frequenza e del blocco temporaneo.
- `test/unit/library_statistics_test.dart`: calcolo matematico accurato di generi, capitoli e medie voto.
- `test/unit/models_test.dart`: parsing dei payload reali e serializzazione DTO.
- `test/widget/status_badge_test.dart`: rendering e traduzione corretta dei badge di stato.
- `test/widget/progress_stepper_test.dart`: interazione con i pulsanti di incremento/decremento e completamento.
- `test/widget/empty_state_test.dart`: visualizzazione degli stati vuoti e callback delle azioni.
- `test/widget_test.dart`: smoke test generale dell'app.
