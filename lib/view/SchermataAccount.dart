import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewModel/UtenteViewModel.dart';
import 'SchermataSicurezza.dart';

class SchermataAccount extends StatelessWidget {
  const SchermataAccount({super.key});

  @override
  Widget build(BuildContext context) {
    //otteniamo l'istanza del ViewModel per accedere ai dati dell'utente loggato
    final viewModel = Provider.of<UtenteViewModel>(context);
    final utente = viewModel.utenteLoggato;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                "Account",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      child: Icon(Icons.person, size: 50),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            utente != null ? "${utente.nome} ${utente.cognome}" : "Nome Cognome",
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Divider(height: 1),
              //collega alla schermata per la gestione della password e cancellazione account
              ListTile(
                title: const Text("Sicurezza ed accesso", style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: const Text("Modifica password, elimina account"),
                trailing: const Icon(Icons.arrow_right, color: Colors.black54),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SchermataSicurezza()),
                  );
                },
              ),
              const Divider(height: 1),
              //mostra le informazioni legali e i crediti dell'applicazione
              ListTile(
                title: const Text("Informazioni sull'app", style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: const Text("Contatti, supporto, info legali"),
                trailing: const Icon(Icons.arrow_right, color: Colors.black54),
                onTap: () {
                  _mostraInfoApp(context);
                },
              ),
              const Divider(height: 1),
              //effettua il logout pulendo le preferenze locali e la sessione Firebase
              ListTile(
                title: const Text("Esci dall'account", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.redAccent)),
                subtitle: const Text("Disconnessione dall'app"),
                trailing: const Icon(Icons.arrow_right, color: Colors.black54),
                onTap: () {
                  _mostraConfermaLogout(context, viewModel);
                },
              ),
              const Divider(height: 1),
            ],
          ),
        ),
      ),
    );
  }

  //mostra un dialog personalizzato con i crediti del progetto
  void _mostraInfoApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Informazioni sull'app"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Drive App", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text("Versione 1.0.0"),
            SizedBox(height: 16),
            Text("Programmazione Mobile A.A 2025/2026", style: TextStyle(fontWeight: FontWeight.w500)),
            Text("Gonzato Cristian, De Cinque Nicola Giorgio"),
            SizedBox(height: 16),
            Text("© 2026 Drive App Team"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CHIUDI"),
          ),
        ],
      ),
    );
  }

  //mostra un alert di sistema per confermare l'intenzione di uscire
  void _mostraConfermaLogout(BuildContext context, UtenteViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Sei sicuro di voler uscire?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ANNULLA"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              viewModel.logout();
            },
            child: const Text("ESCI"),
          ),
        ],
      ),
    );
  }
}
