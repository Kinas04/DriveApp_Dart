import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ui/theme/UtenteViewModel.dart';

class SchermataSicurezza extends StatefulWidget {
  const SchermataSicurezza({super.key});

  @override
  State<SchermataSicurezza> createState() => _SchermataSicurezzaState();
}

class _SchermataSicurezzaState extends State<SchermataSicurezza> {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  bool inCaricamento = false;
  String messaggioErrore = "";

  //procedura di cambio password che verifica la credenziale precedente
  void _cambiaPassword(UtenteViewModel viewModel) async {
    setState(() {
      inCaricamento = true;
      messaggioErrore = "";
    });

    await viewModel.avviaCambioPassword(
      oldPasswordController.text,
      newPasswordController.text,
      (successo, messaggio) {
        if (mounted) {
          setState(() => inCaricamento = false);
          if (successo) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(messaggio)));
            Navigator.pop(context);
          } else {
            setState(() => messaggioErrore = messaggio);
          }
        }
      },
    );
  }

  //apre un popup di conferma per la cancellazione definitiva dell'account
  void _eliminaAccount(UtenteViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Elimina Account", style: TextStyle(color: Colors.red)),
        content: const Text("Sei sicuro? Questa operazione è irreversibile e cancellerà tutti i tuoi dati."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ANNULLA")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await viewModel.eliminaAccount((successo, messaggio) {
                if (mounted && !successo) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(messaggio)));
                }
              });
            },
            child: const Text("ELIMINA", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<UtenteViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Sicurezza ed Accesso")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Cambia Password", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Vecchia Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Nuova Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Text(messaggioErrore, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: inCaricamento ? null : () => _cambiaPassword(viewModel),
                child: inCaricamento 
                    ? const CircularProgressIndicator() 
                    : const Text("AGGIORNA PASSWORD"),
              ),
            ),
            const SizedBox(height: 48),
            const Divider(),
            const SizedBox(height: 24),
            const Text("Zona Pericolo", style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text("L'eliminazione dell'account comporterà la perdita di tutte le prenotazioni e degli esiti salvati."),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _eliminaAccount(viewModel),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                child: const Text("ELIMINA ACCOUNT"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
