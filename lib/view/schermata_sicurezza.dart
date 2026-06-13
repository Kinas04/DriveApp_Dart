import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/utente_view_model.dart';

//Schermata dedicata alla gestione della sicurezza dell'account (Cambio Password ed Eliminazione Profilo)
class SchermataSicurezza extends StatefulWidget {
  const SchermataSicurezza({super.key});

  @override
  State<SchermataSicurezza> createState() => _SchermataSicurezzaState();
}

class _SchermataSicurezzaState extends State<SchermataSicurezza> {
  //Controller per acquisire la vecchia e la nuova password dai campi di testo
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  
  bool inCaricamento = false;
  String messaggioErrore = "";

  @override
  void dispose() {
    //Rilascio dei controller per evitare memory leak (Punto 2.8)
    oldPasswordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  //procedura di cambio password (Punto 2.5: corretta firma in Future<void>)
  Future<void> _cambiaPassword(UtenteViewModel viewModel) async {
    setState(() {
      inCaricamento = true;
      messaggioErrore = "";
    });

    //Invia i dati al ViewModel per la logica di business e la comunicazione con Firebase Auth
    await viewModel.avviaCambioPassword(
      oldPasswordController.text,
      newPasswordController.text,
      (successo, messaggio) {
        if (mounted) {
          setState(() => inCaricamento = false);
          if (successo) {
            //In caso di successo, notifica l'utente e chiude la schermata tornando all'account
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(messaggio)));
            Navigator.pop(context);
          } else {
            //Se la vecchia password è errata o ci sono altri problemi, visualizza l'errore
            setState(() => messaggioErrore = messaggio);
          }
        }
      },
    );
  }

  //apre un popup (Dialog) di avviso critico per confermare la cancellazione definitiva dell'account
  void _eliminaAccount(UtenteViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Elimina Account", style: TextStyle(color: Colors.red)),
        content: const Text("Sei sicuro? Questa operazione è irreversibile e cancellerà tutti i tuoi dati e prenotazioni dal sistema."),
        actions: [
          //Pulsante per annullare l'azione
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ANNULLA")),
          //Pulsante distruttivo per procedere alla cancellazione
          TextButton(
            onPressed: () async {
              Navigator.pop(context); //Chiude il popup prima di avviare la procedura
              await viewModel.eliminaAccount((successo, messaggio) {
                if (mounted) {
                  if (successo) {
                    //Se l'eliminazione va a buon fine, resettiamo il navigatore e torniamo alla radice (Schermata Login)
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  } else {
                    //Visualizza un errore se la procedura fallisce (es. sessione scaduta che richiede re-login)
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(messaggio)));
                  }
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
            //Input per la password attuale
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Vecchia Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            //Input per la nuova password desiderata
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Nuova Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            //Visualizzazione di eventuali errori di validazione o di sistema
            Text(messaggioErrore, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            //Pulsante per attivare l'aggiornamento della password
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: inCaricamento ? null : () => _cambiaPassword(viewModel),
                child: inCaricamento 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)) 
                    : const Text("AGGIORNA PASSWORD"),
              ),
            ),
            const SizedBox(height: 48),
            const Divider(),
            const SizedBox(height: 24),
            //Sezione dedicata alle azioni irreversibili
            const Text("Zona Pericolo", style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text("L'eliminazione dell'account comporterà la perdita di tutte le prenotazioni, delle guide e degli esiti salvati finora."),
            const SizedBox(height: 16),
            //Pulsante per avviare il processo di cancellazione account
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
