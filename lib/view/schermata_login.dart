import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/utente_view_model.dart';

//Schermata iniziale per l'autenticazione dell'utente tramite codice fiscale e password
class SchermataLogin extends StatefulWidget {
  //Callback per passare alla schermata di registrazione
  final VoidCallback onVaiARegistrazione;
  const SchermataLogin({super.key, required this.onVaiARegistrazione});

  @override
  State<SchermataLogin> createState() => _SchermataLoginState();
}

class _SchermataLoginState extends State<SchermataLogin> {
  //Controller per gestire l'input di testo dei campi del modulo
  final codiceController = TextEditingController();
  final passwordController = TextEditingController();

  String messaggioErrore = "";
  bool inCaricamento = false;

  @override
  void dispose() {
    //Liberiamo le risorse dei controller per evitare memory leak durante la chiusura
    codiceController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  //gestisce la procedura di login tramite il ViewModel e visualizza l'esito all'utente
  Future<void> login(UtenteViewModel viewModel) async {
    //Attivo lo stato di caricamento e pulisco eventuali errori precedenti
    setState(() {
      inCaricamento = true;
      messaggioErrore = "";
    });

    //Inviio i dati al ViewModel per la verifica su Firebase
    await viewModel.eseguiLogin(
      codiceController.text.trim(),
      passwordController.text.trim(),
      (successo, messaggio) {
        //Verifico che la schermata sia ancora attiva (mounted) prima di aggiornare lo stato per evitare crash
        if (mounted) {
          setState(() {
            inCaricamento = false;
            if (!successo) {
              //Mostro il messaggio di errore se l'autenticazione fallisce
              messaggioErrore = messaggio;
            } else {
              //In caso di successo, mostro una notifica rapida (SnackBar)
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
    //Adatto il layout della schermata in base alla larghezza del dispositivo (Smartphone vs Tablet)
    final double larghezzaSchermo = MediaQuery.of(context).size.width;
    final bool isCompatto = larghezzaSchermo < 600;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          //Uso SingleChildScrollView per prevenire overflow grafici quando la tastiera è aperta
          child: SingleChildScrollView(
            child: isCompatto ? _buildLayoutCompatto(viewModel) : _buildLayoutTablet(viewModel),
          ),
        ),
      ),
    );
  }

  //layout verticale ottimizzato per smartphone con elementi incolonnati
  Widget _buildLayoutCompatto(UtenteViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //Padding superiore ridotto per allineare l'intestazione alle altre schermate
          const SizedBox(height: 24),
          _buildIntestazione(),
          const SizedBox(height: 32),
          _buildModuloLogin(viewModel),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  //layout orizzontale per tablet con logo a sinistra e modulo di login a destra
  Widget _buildLayoutTablet(UtenteViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: Center(child: _buildIntestazione()),
        ),
        Expanded(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(32.0),
              //Rimozione di elementi ridondanti per pulizia layout su tablet
              child: _buildModuloLogin(viewModel),
            ),
          ),
        ),
      ],
    );
  }

  //sezione dell'intestazione con il messaggio di benvenuto e il logo dell'applicazione
  Widget _buildIntestazione() {
    return Column(
      children: [
        const Text(
          "Benvenuto su DriveAPP!",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Container(
          width: 200,
          height: 200,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          // Visualizzazione del logo circolare caricato dagli asset di progetto
          child: Center(
            child: Image.asset(
              'assets/images/logo_circle.webp',
              width: 160,
              height: 160,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          "Effettua l'accesso:",
          style: TextStyle(fontSize: 14, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  //costruisce il modulo di input (Form) per le credenziali e i pulsanti di azione
  Widget _buildModuloLogin(UtenteViewModel viewModel) {
    return Column(
      children: [
        //Campo per l'inserimento del Codice Fiscale con gestione della posizione del cursore
        TextField(
          controller: codiceController,
          onChanged: (v) {
            String testoFormattato = viewModel.formattaCodiceFiscale(v);
            //Mantengo la posizione del cursore per una migliore esperienza utente
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
        //Campo per la password con oscuramento dei caratteri
        TextField(
          controller: passwordController,
          onChanged: (v) => setState(() => messaggioErrore = ""),
          obscureText: true,
          decoration: InputDecoration(
            labelText: "Password",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 8),
        //Area dinamica per la visualizzazione dei messaggi di errore (supporta più righe per l'avviso offline)
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
        //Pulsante di accesso con indicatore di caricamento integrato
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: inCaricamento ? null : () => login(viewModel),
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
                : const Text("ACCEDI", style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(height: 24),
        const Text("Non hai ancora un account?", style: TextStyle(fontSize: 14)),
        const SizedBox(height: 8),
        //Pulsante per navigare verso la creazione di un nuovo profilo
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: widget.onVaiARegistrazione,
            icon: const Icon(Icons.add),
            label: const Text("REGISTRATI", style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.4),
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            ),
          ),
        ),
      ],
    );
  }
}
