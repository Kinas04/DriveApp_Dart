import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewModel/UtenteViewModel.dart';

class SchermataRegistrazione extends StatefulWidget {
  final VoidCallback onTornaAlLogin;
  const SchermataRegistrazione({super.key, required this.onTornaAlLogin});

  @override
  State<SchermataRegistrazione> createState() => _SchermataRegistrazioneState();
}

class _SchermataRegistrazioneState extends State<SchermataRegistrazione> {
  final nomeController = TextEditingController();
  final cognomeController = TextEditingController();
  final codiceController = TextEditingController();
  final passwordController = TextEditingController();
  
  String? etaSelezionata;
  String? categoriaSelezionata;
  
  String messaggioErrore = "";
  bool inCaricamento = false;

  final List<String> opzioniEta = List.generate(77, (index) => (index + 14).toString());
  final List<String> opzioniCategorie = [
    "AM", "A1", "A2", "A", "B1", "B", "B96", "BE", "C1", "C1E", "C", "CE", "D1", "D1E", "D", "DE"
  ];

  //invia i dati al ViewModel per creare un nuovo account su Auth e Firestore
  Future<void> registrazione(UtenteViewModel viewModel) async {
    setState(() {
      inCaricamento = true;
      messaggioErrore = "";
    });

    await viewModel.avviaRegistrazione(
      nome: nomeController.text.trim(),
      cognome: cognomeController.text.trim(),
      cf: codiceController.text.trim(),
      password: passwordController.text.trim(),
      eta: etaSelezionata ?? "",
      categoria: categoriaSelezionata ?? "",
      onRisultato: (successo, messaggio) {
        if (mounted) {
          setState(() {
            inCaricamento = false;
            if (!successo) {
              messaggioErrore = messaggio;
            } else {
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
                  const SizedBox(height: 32),
                  const Text(
                    "Crea un account",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

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
                    decoration: const InputDecoration(labelText: "Nome"),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: cognomeController,
                    onChanged: (v) {
                      String testoFormattato = viewModel.formattaNome(v);

                      nomeController.value = TextEditingValue(
                        text: testoFormattato,
                        selection: TextSelection.collapsed(offset: testoFormattato.length),
                      );

                      setState(() => messaggioErrore = "");
                    },
                    decoration: const InputDecoration(labelText: "Cognome"),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: codiceController,
                    onChanged: (v) => codiceController.text = viewModel.formattaCodiceFiscale(v),
                    decoration: InputDecoration(
                      labelText: "Codice Fiscale",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  //menu a tendina per la selezione dell'età dell'utente
                  DropdownButtonFormField<String>(
                    initialValue: etaSelezionata,
                    decoration: InputDecoration(
                      labelText: "Età",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: opzioniEta.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => etaSelezionata = v),
                  ),
                  const SizedBox(height: 16),
                  
                  //stessa cosa per scegliere la categoria di patente ministeriale richiesta
                  DropdownButtonFormField<String>(
                    initialValue: categoriaSelezionata,
                    decoration: InputDecoration(
                      labelText: "Patente richiesta",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: opzioniCategorie.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => categoriaSelezionata = v),
                  ),
                  
                  const SizedBox(height: 8),
                  //Racchiudo il testo in un Container senza altezza fissa per permettere il wrapping su più righe
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
