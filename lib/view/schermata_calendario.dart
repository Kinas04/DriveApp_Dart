import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../view_model/calendario_view_model.dart';
import '../model/lezione.dart';
import '../model/esame.dart';
import '../model/slot_guida.dart';

class SchermataCalendario extends StatefulWidget {
  const SchermataCalendario({super.key});

  @override
  State<SchermataCalendario> createState() => _SchermataCalendarioState();
}

class _SchermataCalendarioState extends State<SchermataCalendario> {
  int _tabSelezionato = 0;
  DateTime _dataSelezionata = DateTime.now();

  //Inzializzo le tre liste necessarie a vuoote
  List<Lezione> _lezioni = [];
  List<Esame> _esami = [];
  List<SlotGuida> _guide = [];

  bool _inCaricamento = false;
  bool _erroreCaricamento = false;

  @override
  void initState() {
    super.initState();
    //caricamento iniziale post-frame (dopo che arrivo sulla schermata) per avere il contesto pronto ed evitare errori di build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _caricaEventi();
    });
  }

  //chiamata al ViewModel per recuperare gli eventi filtrati per data e tab selezionato
  Future<void> _caricaEventi() async {
    final viewModel = Provider.of<CalendarioViewModel>(context, listen: false);
    
    setState(() {
      _inCaricamento = true;
      _erroreCaricamento = false;
    });

    await viewModel.caricaEventiCalendario(
      _dataSelezionata,
      _tabSelezionato,
      (lezioni, esami, guide, errore) {
        if (mounted) {
          setState(() {
            //Carico ora le liste con le varie lezioni
            _lezioni = lezioni;
            _esami = esami;
            _guide = guide;
            _erroreCaricamento = errore;
            _inCaricamento = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //determiniamo se lo schermo è cellulare o tablet per gestire il layout responsive
    final double larghezzaSchermo = MediaQuery.of(context).size.width;
    final bool isCompatto = larghezzaSchermo < 600;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: isCompatto ? _buildLayoutCompatto() : _buildLayoutTablet(),
      ),
    );
  }

  //layout verticale ottimizzato per smartphone
  Widget _buildLayoutCompatto() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitolo(),
          const SizedBox(height: 24),
          _buildSelettoreTabs(),
          const SizedBox(height: 24),
          _buildCalendario(),
          const SizedBox(height: 24),
          _buildLabelData(),
          const SizedBox(height: 16),
          _buildListaEventi(),
        ],
      ),
    );
  }

  //layout a due colonne ottimizzato per tablet o schermi larghi
  Widget _buildLayoutTablet() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //colonna sinistra con titolo e calendario selezionabile
          Expanded(
            flex: 12,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitolo(),
                  const SizedBox(height: 24),
                  _buildCalendario(),
                ],
              ),
            ),
          ),
          const SizedBox(width: 32),
          //colonna destra con selettore categoria e lista degli eventi caricati
          Expanded(
            flex: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSelettoreTabs(),
                const SizedBox(height: 24),
                _buildLabelData(),
                const SizedBox(height: 16),
                Expanded(child: _buildListaEventi()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitolo() {
    return const Text(
      "Calendario",
      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    );
  }

  //barra dei tab per switchare tra visualizzazione lezioni, esami e guide
  Widget _buildSelettoreTabs() {
    final tabs = ["Lezioni", "Esami", "Guide"];
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
                setState(() => _tabSelezionato = index);
                _caricaEventi();
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
                    color: isSelezionato ? Colors.white : Colors.black87,
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

  //widget del calendario per selezionare il giorno desiderato
  Widget _buildCalendario() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: CalendarDatePicker(
        initialDate: _dataSelezionata,
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        onDateChanged: (nuovaData) {
          setState(() => _dataSelezionata = nuovaData);
          _caricaEventi();
        },
      ),
    );
  }

  //mostra la data selezionata formattata in italiano
  Widget _buildLabelData() {
    final format = DateFormat('EEEE d MMMM', 'it_IT');
    return Text(
      format.format(_dataSelezionata).toUpperCase(),
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  //gestisce il rendering della lista di eventi in base allo stato di caricamento
  Widget _buildListaEventi() {
    if (_inCaricamento) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_erroreCaricamento) {
      return const Center(
        child: Text("Errore durante il caricamento degli eventi", style: TextStyle(color: Colors.red)),
      );
    }

    //associo gli elementi corretti alla lista corretta in base al tab selezionato
    final List items = _tabSelezionato == 0 ? _lezioni : (_tabSelezionato == 1 ? _esami : _guide);

    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 20),
        child: Text("Nessun evento per questa data", style: TextStyle(color: Colors.black54)),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = items[index];
        if (item is Lezione) {
          return _buildEventoItem("${item.oraInizio} - ${item.oraFine}", item.argomento, item.aula);
        } else if (item is Esame) {
          return _buildEventoItem("${item.oraInizio} - ${item.oraFine}", "Esame ${item.tipologia} (Cat. ${item.categoriaPatente})", item.luogo);
        } else if (item is SlotGuida) {
          final stato = item.utentePrenotato == null ? "Disponibile" : "Prenotata";
          return _buildEventoItem("${item.oraInizio} - ${item.oraFine}", "Guida Categoria ${item.categoriaPatente}", "${item.istruttore} - $stato");
        }
        return const SizedBox.shrink();
      },
    );
  }

  //costruisce il singolo elemento della lista con orario, titolo e sottotitolo
  Widget _buildEventoItem(String ora, String titolo, String sottotitolo) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.chat_bubble_outline, size: 20, color: Colors.black.withValues(alpha: 0.7)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ora, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 2),
              Text(titolo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(sottotitolo, style: const TextStyle(fontSize: 14, color: Colors.black54)),
            ],
          ),
        ),
      ],
    );
  }
}
