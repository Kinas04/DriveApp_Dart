import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/utente_view_model.dart';

//Schermata per la creazione di un nuovo account utente con inserimento dati anagrafici e scelta patente
class SchermataRegistrazione extends StatefulWidget {
  //Callback per tornare alla visualizzazione del login
  final VoidCallback onTornaAlLogin;
  const SchermataRegistrazione({super.key, required this.onTornaAlLogin});

  @override
  State<SchermataRegistrazione> createState() => _SchermataRegistrazioneState();
}

class _SchermataRegistrazioneState extends State<SchermataRegistrazione> {
  //Controller per la gestione degli input di testo nei vari campi del form
  final nomeController = TextEditingController();
  final cognomeController = TextEditingController();
  final codiceController = TextEditingController();
  final passwordController = TextEditingController();
  
  String? etaSelezionata;
  String? categoriaSelezionata;
  
  String messaggioErrore = "";
  bool inCaricamento = false;

  @override
  void dispose() {
    //Liberiamo le risorse dei controller per evitare memory leak (Punto 2.8)
    nomeController.dispose();
    cognomeController.dispose();
    codiceController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  //Elenchi statici per le opzioni dei menu a tendina (Dropdown)
  final List<String> opzioniEta = List.generate(77, (index) => (index + 14).toString());
  final List<String> opzioniCategorie = [
    "AM", "A1", "A2", "A", "B1", "B", "B96", "BE", "C1", "C1E", "C", "CE", "D1", "D1E", "D", "DE"
  ];

  //invia i dati al ViewModel per validare e creare il nuovo profilo su Auth e Firestore
  Future<void> registrazione(UtenteViewModel viewModel) async {
    setState(() {
      inCaricamento = true;
      messaggioErrore = "";
    });

    //Chiamata asincrona al ViewModel passando tutti i campi inseriti
    await viewModel.avviaRegistrazione(
      nome: nomeController.text.trim(),
      cognome: cognomeController.text.trim(),
      cf: codiceController.text.trim(),
      password: passwordController.text.trim(),
      eta: etaSelezionata ?? "",
      categoria: categoriaSelezionata ?? "",
      onRisultato: (successo, messaggio) {
        //Verifica mounted per garantire che il widget sia ancora nell'albero prima di chiamare setState
        if (mounted) {
          setState(() {
            inCaricamento = false;
            if (!successo) {
              //Mostro l'errore specifico (es. CF già esistente o validazione fallita)
              messaggioErrore = messaggio;
            } else {
              //Successo: notifica l'utente e l'app passerà automaticamente alla MainScreen tramite il Consumer
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(messaggio)),
              );
            }
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<UtenteViewModel>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //Allineamento altezza titolo coerente con il resto del progetto
                  const SizedBox(height: 24),
                  const Text(
                    "Crea un account",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  //Campo Nome con fix posizione cursore (Punto 2.2)
                  TextField(
                    controller: nomeController,
                    onChanged: (v) {
                      String testoFormattato = viewModel.formattaNome(v);
                      nomeController.value = TextEditingValue(
                        text: testoFormattato,
                        selection: TextSelection.collapsed(offset: testoFormattato.length),
                      );
                      setState(() => messaggioErrore = "");
                    },
                    decoration: const InputDecoration(
                      labelText: "Nome",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  //Campo Cognome con fix posizione cursore
                  TextField(
                    controller: cognomeController,
                    onChanged: (v) {
                      String testoFormattato = viewModel.formattaNome(v);
                      cognomeController.value = TextEditingValue(
                        text: testoFormattato,
                        selection: TextSelection.collapsed(offset: testoFormattato.length),
                      );
                      setState(() => messaggioErrore = "");
                    },
                    decoration: const InputDecoration(
                      labelText: "Cognome",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  //Campo Codice Fiscale con fix posizione cursore
                  TextField(
                    controller: codiceController,
                    onChanged: (v) {
                      String testoFormattato = viewModel.formattaCodiceFiscale(v);
                      codiceController.value = TextEditingValue(
                        text: testoFormattato,
                        selection: TextSelection.collapsed(offset: testoFormattato.length),
                      );
                      setState(() => messaggioErrore = "");
                    },
                    decoration: InputDecoration(
                      labelText: "Codice Fiscale",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  //Campo Password con oscuramento
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  //Menu a tendina per la selezione dell'età dell'utente (Punto 2.3: initialValue -> value)
                  DropdownButtonFormField<String>(
                    value: etaSelezionata,
                    decoration: InputDecoration(
                      labelText: "Età",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: opzioniEta.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => etaSelezionata = v),
                  ),
                  const SizedBox(height: 16),
                  
                  //Selettore per la categoria di patente ministeriale (Punto 2.3: fixed parameter)
                  DropdownButtonFormField<String>(
                    value: categoriaSelezionata,
                    decoration: InputDecoration(
                      labelText: "Patente richiesta",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: opzioniCategorie.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => categoriaSelezionata = v),
                  ),
                  
                  const SizedBox(height: 8),
                  //Area per la visualizzazione dei messaggi di errore
                  Container(
                    constraints: const BoxConstraints(minHeight: 20),
                    width: double.infinity,
                    child: Text(
                      messaggioErrore,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  //Pulsante principale per avviare la procedura di registrazione
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: inCaricamento ? null : () => registrazione(viewModel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        foregroundColor: Theme.of(context).colorScheme.onSecondary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      ),
                      child: inCaricamento
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text("REGISTRATI", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  const Text("Hai già un account?", style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                  
                  //Pulsante per tornare alla schermata di login
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: widget.onTornaAlLogin,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text("ACCEDI", style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.4),
                        foregroundColor: Theme.of(context).colorScheme.onSurface,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
