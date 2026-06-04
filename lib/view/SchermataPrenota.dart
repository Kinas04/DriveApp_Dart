import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewModel/UtenteViewModel.dart';
import '../viewModel/PrenotaViewModel.dart';
import '../model/Esame.dart';
import '../model/SlotGuida.dart';

class SchermataPrenota extends StatefulWidget {
  final VoidCallback? onMenuClick;
  const SchermataPrenota({super.key, this.onMenuClick});

  @override
  State<SchermataPrenota> createState() => _SchermataPrenotaState();
}

class _SchermataPrenotaState extends State<SchermataPrenota> with TickerProviderStateMixin {
  late TabController _tabController;
  
  List<Esame> _listaEsami = [];
  List<SlotGuida> _listaGuide = [];
  Set<String> _elementiPrenotati = {};
  
  bool _inCaricamento = true;
  bool _erroreCaricamento = false;
  bool _inPrenotazione = false;

  @override
  void initState() {
    super.initState();
    //inizializziamo il TabController per gestire i due tab della schermata
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _caricaDati();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _caricaDati();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  //chiamata al ViewModel per caricare le liste degli elementi prenotabili dal database
  Future<void> _caricaDati() async {
    final utenteViewModel = Provider.of<UtenteViewModel>(context, listen: false);
    final prenotaViewModel = Provider.of<PrenotaViewModel>(context, listen: false);

    final utente = utenteViewModel.utenteLoggato;
    if (utente == null) return;
    
    setState(() {
      _inCaricamento = true;
      _erroreCaricamento = false;
    });

    await prenotaViewModel.caricaElementiPrenotabili(
      utente.categoriaRichiesta,
      utente.codiceFiscale,
      _tabController.index,
      (esami, guide, prenotati, errore) {
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

  //mostra un popup di avviso per chiedere conferma all'utente prima di prenotare
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
                    _tabController.index,
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

  @override
  Widget build(BuildContext context) {
    final double larghezzaSchermo = MediaQuery.of(context).size.width;
    final bool isCompatto = larghezzaSchermo < 600;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildTitolo(isCompatto),
                const SizedBox(height: 16),
                _buildSelettoreTabs(),
                const SizedBox(height: 16),
                _buildSottotitolo(),
                const SizedBox(height: 16),
                Expanded(child: _buildContenuto()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //settiamo il titolo della pagina e gestiamo l'icona menu per il tablet
  Widget _buildTitolo(bool isCompatto) {
    return Row(
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
    );
  }

  //inseriamo il selettore a tab per switchare tra "Esami" e "Guide"
  Widget _buildSelettoreTabs() {
    return Container(
      height: 56,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(28),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(24),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
        tabs: const [
          Tab(text: "Esami"),
          Tab(text: "Guide"),
        ],
      ),
    );
  }

  //mostra un testo dinamico in base alla disponibilità degli elementi nella lista
  Widget _buildSottotitolo() {
    if (_inCaricamento || _erroreCaricamento) return const SizedBox.shrink();

    String testo = "";
    if (_tabController.index == 0) {
      testo = _listaEsami.isEmpty ? "Nessun esame disponibile" : "Scegli un esame da prenotare";
    } else {
      testo = _listaGuide.isEmpty ? "Nessuna guida disponibile" : "Scegli una guida da prenotare";
    }

    return Text(
      testo,
      style: TextStyle(fontSize: 16, color: Colors.black.withValues(alpha: 0.8)),
    );
  }

  //gestisce il corpo della pagina caricando la lista corretta in base al tab
  Widget _buildContenuto() {
    if (_inCaricamento) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erroreCaricamento) {
      return Center(
        child: Text(
          _tabController.index == 0 ? "Errore caricamento esami" : "Errore caricamento guide",
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    final items = _tabController.index == 0 ? _listaEsami : _listaGuide;

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

  //crea la riga della lista con icone e testi che variano se l'elemento è già prenotato
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
      onTap: isPrenotato ? null : () => _mostraPopupConferma(id),
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
