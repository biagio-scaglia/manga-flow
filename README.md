# MangaFlow - Personal Manga Library

Applicazione mobile Flutter in lingua italiana per catalogare, tracciare e gestire la propria collezione e lettura manga.
Progettata secondo i principi della **Clean Architecture**, con approccio **offline-first**, persistenza locale atomica su file JSON con auto-recovery da backup, e integrazione con API pubbliche documentate (Jikan REST API v4 / Kitsu open data).

L'interfaccia adotta un'identità visiva ispirata al mondo dell'editoria manga e delle fumetterie specializzate (contrasto carta/inchiostro, tipografia editoriale, etichette a timbro e indicatori fisici per volumi e capitoli).

---

## Funzionalita Principali

### 1. Ricerca Manga su Catalogo Reale
- Connessione ad API REST documentate per esplorare cataloghi manga reali.
- **Debounce automatico** a 500ms durante la digitazione.
- **Prevenzione Stale Responses**: tracciamento delle richieste con ID incrementale per impedire che risposte lente sovrascrivano ricerche piu recenti.
- Paginazione infinita e caricamento progressivo con skeleton loader.
- Esplorazione iniziale dei titoli piu popolari a campo vuoto.

### 2. Scheda Catalogo & Dettaglio Manga
- Copertina ad alta risoluzione con effetto costa/dorso e transizione Hero.
- Metadati editoriali completi: titolo originale/internazionale, autori, generi, stato di pubblicazione (*In corso*, *Concluso*, ecc.) e sinossi.
- Punteggio della community globale.

### 3. Gestione Completa della Libreria (CRUD)
- **Stati di lettura**: *In lettura*, *Da leggere*, *Completato*, *In pausa*, *Abbandonato*.
- **Preferiti con Toggle Rapido**: possibilita di aggiungere/rimuovere dai preferiti sia per manga gia in catalogo che direttamente dalla ricerca.
- **Tracker Capitoli Letti**: stepper incrementale con pulsanti - / +, digitazione numerica diretta e prompt di completamento automatico all'ultimo capitolo.
- **Collezione Volumi Fisici**: conteggio dei volumi fisici posseduti con vincolo stringente al totale della serie (es. impossibile superare 24 volumi se la serie ne ha 24), indicatore dinamico *-X DA COMPRARE* e badge *COMPLETA*.
- **Valutazione Personale**: sistema a stelle da 1 a 10 con feedback immediato.
- **Note Editoriali**: area appunti e recensioni personali modificabile e salvabile.
- **Rimozione Sicura**: dialogo di conferma con eliminazione atomica e navigazione reattiva.

### 4. Home Dashboard
- Saluto orario dinamico in italiano (*Buongiorno*, *Buon pomeriggio*, *Buonasera*).
- Sezione *Continua a leggere* con i titoli in corso e stepper rapido.
- Sezioni *Aggiunti di recente* e *Da leggere*.
- Matrice riassuntiva con statistiche immediate.

### 5. Statistiche Reali & Zero Dati Fittizi
- Calcolate esclusivamente sulle voci reali presenti nella libreria locale.
- Conteggio totale manga, capitoli letti, volumi posseduti, media voto e distribuzione percentuale per stato e genere.

### 6. Architettura Offline-First & Separazione delle Fonti
- **Local Data Source come Single Source of Truth**: tutta la libreria personale dell'utente, i progressi di lettura, i volumi collezionati, i voti e le note risiedono esclusivamente su storage locale JSON. L'app e al 100% funzionante offline per qualsiasi operazione sulla propria libreria anche in caso di totale indisponibilita dei server remoti.
- **Remote API per Discovery ed Enrichment**: la rete viene interrogata esclusivamente per la ricerca di nuovi titoli e per l'arricchimento dei metadati editoriali, con cache HTTP a disco/RAM (TTL 24 ore).

### 7. Impostazioni, Manutenzione & Onboarding
- Scelta del tema grafico: Scuro (Night Ink), Chiaro (Paper) o Automatico di sistema.
- Accessibilita: interruttore per riduzione delle animazioni di transizione.
- Guida e tutorial iniziale a schede, con salvataggio sincrono delle preferenze per evitare aperture ripetute e possibilita di rieseguirlo dalle Impostazioni.
- Ispezione e svuotamento sicuro della sola cache API (senza toccare la libreria personale).
- Esportazione e importazione del backup JSON della libreria.

---

## Architettura del Progetto

Il codice e strutturato secondo la **Clean Architecture** a livelli indipendenti:

```
lib/
├── core/
│   ├── constants/          # Parametri di sistema, limiti e chiavi di configurazione
│   ├── errors/             # Failure ed Exception fortemente tipizzate
│   ├── network/            # RateLimiter token-bucket con supporto Retry-After
│   ├── theme/              # Design System editoriale (Colori, Tipografia, Radii)
│   └── utils/              # Debouncer, Throttler e Formattatori di date in italiano
│
├── data/
│   ├── api/                # Client REST API con backoff esponenziale e rate limit
│   ├── cache/              # HttpCacheManager su memoria e disco
│   ├── models/             # DTO e mapper di serializzazione
│   ├── repositories/       # Implementazioni concrete (MangaRepositoryImpl, LibraryRepositoryImpl)
│   └── storage/            # JsonStorage atomico, backup .bak e SchemaMigrationManager
│
├── domain/
│   ├── entities/           # Entita di dominio pure (Manga, LibraryEntry, ReadingStatus, LibraryStatistics)
│   │   └── library_entry_merger.dart # Logica di deduplicazione e merge deterministico
│   └── repositories/       # Interfacce astratte (MangaRepository, LibraryRepository)
│
├── presentation/
│   ├── controllers/        # Gestione dello stato con Provider / ChangeNotifier
│   ├── screens/            # Schermate (Home, Library, Search, Detail, Statistics, Settings)
│   ├── tutorial/           # Sistema di onboarding guidato interattivo
│   └── widgets/            # Componenti riutilizzabili (MangaCard, ProgressStepper, etc.)
│
└── main.dart               # Entry point, inizializzazione sincrona delle preferenze e DI
```

---

## Data Integrity, Deduplicazione & Invarianti di Dominio

1. **Deduplicazione Atomica & `LibraryEntryMerger`**:
   - Ogni manga e identificato univocamente dal suo `mangaId` remoto.
   - Non e possibile creare voci duplicate per lo stesso manga.
   - In caso di salvataggi concorrenti o dati legacy, `LibraryEntryMerger` esegue una fusione deterministica: conserva il massimo tra i capitoli letti e i volumi posseduti, il rating piu recente, l'unione dei generi e delle note personali, lo stato piu avanzato e il flag preferito.
2. **Invarianti di Dominio (`LibraryEntry.validated`)**:
   - `0 <= currentChapter <= totalChapters` (se noto).
   - `0 <= ownedVolumes <= totalVolumes` (se noto).
   - `0 <= rating <= 10`.
   - Calcolo di `progressPercentage` matematicamente protetto contro divisori nulli o pari a zero, senza produzione di `NaN`, `Infinity` o percentuali negative.

---

## Persistenza JSON & Auto-Recovery da Backup

1. **Scrittura Atomica a Doppio Stadio**:
   - Serializzazione e validazione della struttura JSON in memoria.
   - Scrittura su file temporaneo `library.json.tmp` con flush forzato su disco.
   - Sostituzione atomica del file di destinazione `library.json`.
2. **Auto-Recovery da File `.bak`**:
   - A ogni salvataggio riuscito viene aggiornata una copia di backup `library.json.bak`.
   - Se il file principale dovesse risultare troncato o corrotto (es. spegnimento del dispositivo durante una scrittura), `JsonStorage` preserva il file corrotto come `.corrupted` per analisi e ripristina automaticamente la libreria dall'ultimo backup valido senza perdita di dati.
3. **Migrazione Idempotente Schemi**:
   - Pipeline `SchemaMigrationManager` con controllo di versione che impedisce downgrade accidentali e applica trasformazioni sequenziali.

---

## Gestione API, Concorrenza & Rate Limiting

- **RateLimiter**: implementato a livello client per rispettare la frequenza massima delle API ed evitare ban IP (HTTP 429).
- **Header `Retry-After`**: parsing del tempo di attesa indicato dal server remoto con backoff controllato.
- **Stale Response Discard**: ricerca protetta da ID di richiesta incrementali; le risposte arrivate fuori ordine vengono scartate.
- **Multi-Format DTO**: parsing unificato compatibile con formati Jikan v4, Kitsu e GraphQL AniList.

---

## Istruzioni di Setup & Esecuzione

### Requisiti
- Flutter SDK (versione 3.24 o superiore)
- Dart SDK (versione 3.5 o superiore)

### Installazione delle dipendenze
```bash
flutter pub get
```

### Verifica statica del codice
```bash
flutter analyze
```

### Formattazione del codice
```bash
dart format .
```

### Esecuzione della suite di test automatici
```bash
flutter test
```

### Avvio dell'applicazione
```bash
flutter run
```

---

## Suite di Test Inclusa (28 Test)

La suite di test automatizzati copre le principali regole di dominio, persistenza e concorrenza dell'applicazione:

| File di Test | Descrizione della Copertura |
| :--- | :--- |
| `test/unit/crud_and_limits_test.dart` | Inizializzazione sincrona delle preferenze, vincolo massimo volumi (es. 25 su 24), toggle preferiti, aggiornamenti e rimozione. |
| `test/unit/deduplication_test.dart` | Scenario completo di aggiunta singola, ripetuta, 3x multi-tap concorrente, riavvio del repository e merge deterministico `LibraryEntryMerger`. |
| `test/unit/domain_invariants_test.dart` | Invarianti entita `LibraryEntry`: capitoli, volumi, rating `0..10`, calcolo sicuro di `progressPercentage` e fallback titoli. |
| `test/unit/json_recovery_test.dart` | Ripristino automatico da file di backup `.bak` su JSON corrotto e protezione downgrade versioni schema. |
| `test/unit/search_controller_test.dart` | Scarto stale response fuori ordine e cancellazione istantanea delle ricerche in volo tramite `clearSearch`. |
| `test/unit/json_storage_test.dart` | Scrittura e lettura atomica del JSON e migrazione automatica schema v0 -> v1. |
| `test/unit/library_statistics_test.dart` | Calcolo statistico accurato su libreria popolata e gestione coerente di libreria vuota. |
| `test/unit/rate_limiter_test.dart` | Rispetto del rate limit e gestione dei blocchi temporanei. |
| `test/unit/models_test.dart` | Deserializzazione e serializzazione DTO (`RemoteMangaDto`, `LibraryEntryDto`). |
| `test/widget/empty_state_test.dart` | Rendering, messaggi e trigger di azione per gli stati vuoti. |
| `test/widget/progress_stepper_test.dart` | Interazione con pulsanti stepper, inserimento manuale e prompt di completamento opera. |
| `test/widget/status_badge_test.dart` | Rendering dei badge di stato con colori e stili editoriali coerenti. |
