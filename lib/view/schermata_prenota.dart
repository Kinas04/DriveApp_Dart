import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../view_model/utente_view_model.dart';
import '../view_model/prenota_view_model.dart';
import '../model/esame.dart';
import '../model/slot_guida.dart';

//Schermata che permette all'utente di visualizzare e prenotare nuovi appelli d'esame o guide pratiche
class SchermataPrenota extends StatefulWidget {
  //Callback facoltativa per l'apertura del menu laterale (usata su Tablet)
  final VoidCallback? onMenuClick;
  const SchermataPrenota({super.key, this.onMenuClick});

  @override
  State<SchermataPrenota> createState() => _SchermataPrenotaState();
}

class _SchermataPrenotaState extends State<SchermataPrenota> {

  // variabile per tab selezionata
  int _tabSelezionato = 0;

  //Liste locali per memorizzare i dati ricevuti dal database
  List<Esame> _listaEsami = [];
  List<SlotGuida> _listaGuide = [];

  //Insieme di identificativi per tracciare quali elementi l'utente ha già prenotato
  Set<String> _elementiPrenotati = {};

  bool _inCaricamento = true;
  bool _erroreCaricamento = false;

  //Flag per gestire lo stato di attesa durante la scrittura sul database
  bool _inPrenotazione = false;

  @override
  void initState() {
    super.initState();

    //Avviamo il caricamento iniziale dei dati non appena il frame è pronto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _caricaDati();
    });
  }

  //chiamata al ViewModel per caricare le liste degli elementi prenotabili filtrati per l'utente loggato
  Future<void> _caricaDati() async {
    final utenteViewModel = Provider.of<UtenteViewModel>(context, listen: false);
    final prenotaViewModel = Provider.of<PrenotaViewModel>(context, listen: false);

    final utente = utenteViewModel.utenteLoggato;
    if (utente == null) return;

    //Attiviamo l'indicatore di caricamento a video
    setState(() {
      _inCaricamento = true;
      _erroreCaricamento = false;
    });

    //Recuperiamo gli elementi disponibili dal database tramite il ViewModel dedicato
    await prenotaViewModel.caricaElementiPrenotabili(
      utente.categoriaRichiesta,
      utente.codiceFiscale,
      _tabSelezionato,
          (esami, guide, prenotati, errore) {
        //controllo mounted per evitare errori se l'utente cambia pagina durante il caricamento
        if (mounted) {
          setState(() {
            _listaEsami = esami;
            _listaGuide = guide;
            _elementiPrenotati = prenotati;
            _erroreCaricamento = errore;
            _inCaricamento = false;
          });
        }
      },
    );
  }

  //mostra un popup (Dialog) di avviso per chiedere conferma definitiva prima di salvare la prenotazione
  void _mostraPopupConferma(String id) {
    showDialog(
      context: context,
      barrierDismissible: !_inPrenotazione,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Conferma Prenotazione"),
            content: const Text("Vuoi confermare la prenotazione per questo elemento?"),
            actions: [
              TextButton(
                onPressed: _inPrenotazione ? null : () => Navigator.pop(context),
                child: const Text("ANNULLA"),
              ),
              TextButton(
                onPressed: _inPrenotazione ? null : () async {
                  setDialogState(() => _inPrenotazione = true);

                  final utenteViewModel = Provider.of<UtenteViewModel>(context, listen: false);
                  final prenotaViewModel = Provider.of<PrenotaViewModel>(context, listen: false);

                  final cf = utenteViewModel.utenteLoggato?.codiceFiscale;
                  if (cf == null) return;

                  await prenotaViewModel.prenotaElemento(
                    _tabSelezionato,
                    id,
                    cf,
                        (successo, messaggio) {
                      if (mounted) {
                        setDialogState(() => _inPrenotazione = false);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(messaggio)),
                        );
                        if (successo) {
                          _caricaDati();
                        }
                      }
                    },
                  );
                },
                child: _inPrenotazione
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text("CONFERMA"),
              ),
            ],
          );
        },
      ),
    );
  }

  //mostra un popup di avviso per permettere all'utente di cancellare una prenotazione già effettuata
  void _mostraPopupAnnulla(String id) {
    showDialog(
      context: context,
      barrierDismissible: !_inPrenotazione,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Annulla Prenotazione"),
            content: const Text("Vuoi davvero annullare la prenotazione per questo elemento?"),
            actions: [
              TextButton(
                onPressed: _inPrenotazione ? null : () => Navigator.pop(context),
                child: const Text("NO"),
              ),
              TextButton(
                onPressed: _inPrenotazione ? null : () async {
                  setDialogState(() => _inPrenotazione = true);

                  final utenteViewModel = Provider.of<UtenteViewModel>(context, listen: false);
                  final prenotaViewModel = Provider.of<PrenotaViewModel>(context, listen: false);

                  final cf = utenteViewModel.utenteLoggato?.codiceFiscale;
                  if (cf == null) return;

                  await prenotaViewModel.annullaPrenotazione(
                    _tabSelezionato,
                    id,
                    cf,
                        (successo, messaggio) {
                      if (mounted) {
                        setDialogState(() => _inPrenotazione = false);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(messaggio)),
                        );
                        if (successo) {
                          _caricaDati();
                        }
                      }
                    },
                  );
                },
                child: _inPrenotazione
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text("SÌ, ANNULLA"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double larghezzaSchermo = MediaQuery.of(context).size.width;
    final bool isCompatto = larghezzaSchermo < 600;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitolo(isCompatto),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    isCompatto
                        ? _buildSelettoreTabs()
                        : Center(
                        child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: _buildSelettoreTabs()
                        )
                    ),
                    const SizedBox(height: 16),
                    _buildSottotitolo(),
                    const SizedBox(height: 16),
                    Expanded(child: _buildContenuto()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitolo(bool isCompatto) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        children: [
          if (!isCompatto && widget.onMenuClick != null)
            IconButton(
              onPressed: widget.onMenuClick,
              icon: const Icon(Icons.menu),
            ),
          const Text(
            "Prenota",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSelettoreTabs() {
    final tabs = ["Esami", "Guide"];
    return Container(
      height: 56,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelezionato = _tabSelezionato == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (_tabSelezionato != index) {
                  setState(() => _tabSelezionato = index);
                  _caricaDati();
                }
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelezionato
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    // Colore del testo adattato al tema quando non è selezionato
                    color: isSelezionato ? Colors.white : Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSottotitolo() {
    if (_inCaricamento || _erroreCaricamento) return const SizedBox.shrink();

    String testo = "";
    if (_tabSelezionato == 0) {
      testo = _listaEsami.isEmpty ? "Nessun esame disponibile." : "Scegli un esame da prenotare:";
    } else {
      testo = _listaGuide.isEmpty ? "Nessuna guida disponibile." : "Scegli una guida da prenotare:";
    }

    return Text(
      testo,
      style: TextStyle(fontSize: 16, color: Colors.black.withValues(alpha: 0.8)),
    );
  }

  Widget _buildContenuto() {
    if (_inCaricamento) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erroreCaricamento) {
      return Center(
        child: Text(
          _tabSelezionato == 0 ? "Errore caricamento esami." : "Errore caricamento guide.",
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    final items = _tabSelezionato == 0 ? _listaEsami : _listaGuide;

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        if (item is Esame) {
          return _buildRigaPrenotazione(
            id: item.idEsame,
            titolo: "Esame ${item.tipologia} (Cat. ${item.categoriaPatente})",
            data: item.data,
            ora: "${item.oraInizio}-${item.oraFine}",
            isPrenotato: _elementiPrenotati.contains(item.idEsame),
          );
        } else if (item is SlotGuida) {
          return _buildRigaPrenotazione(
            id: item.idGuida,
            titolo: "Guida (${item.istruttore})",
            data: item.data,
            ora: "${item.oraInizio}-${item.oraFine}",
            isPrenotato: _elementiPrenotati.contains(item.idGuida),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildRigaPrenotazione({
    required String id,
    required String titolo,
    required DateTime data,
    required String ora,
    required bool isPrenotato,
  }) {
    final formatData = DateFormat('EEE d MMM', 'it_IT');
    final Color colorePrincipale = isPrenotato ? Colors.green : Colors.black;
    final IconData iconaStato = isPrenotato ? Icons.check : Icons.access_time;

    return InkWell(
      onTap: () => isPrenotato ? _mostraPopupAnnulla(id) : _mostraPopupConferma(id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(iconaStato, color: colorePrincipale, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titolo,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: colorePrincipale,
                    ),
                  ),
                  Text(
                    "${formatData.format(data)}, $ora",
                    style: TextStyle(
                      fontSize: 15,
                      color: colorePrincipale.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (!isPrenotato)
              const Icon(Icons.keyboard_arrow_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}