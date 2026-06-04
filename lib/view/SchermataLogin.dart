import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewModel/UtenteViewModel.dart';

class SchermataLogin extends StatefulWidget {
  final VoidCallback onVaiARegistrazione;
  const SchermataLogin({super.key, required this.onVaiARegistrazione});

  @override
  State<SchermataLogin> createState() => _SchermataLoginState();
}

class _SchermataLoginState extends State<SchermataLogin> {
  final codiceController = TextEditingController();
  final passwordController = TextEditingController();

  String messaggioErrore = "";
  bool inCaricamento = false;

  //gestisce la procedura di login tramite il ViewModel e visualizza l'esito
  Future<void> login(UtenteViewModel viewModel) async {
    setState(() {
      inCaricamento = true;
      messaggioErrore = "";
    });

    await viewModel.eseguiLogin(
      codiceController.text.trim(),
      passwordController.text.trim(),
      (successo, messaggio) {
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
    final double larghezzaSchermo = MediaQuery.of(context).size.width;
    final bool isCompatto = larghezzaSchermo < 600;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: isCompatto ? _buildLayoutCompatto(viewModel) : _buildLayoutTablet(viewModel),
      ),
    );
  }

  //layout verticale con una singola colonna per smartphone
  Widget _buildLayoutCompatto(UtenteViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          _buildIntestazione(),
          const SizedBox(height: 32),
          _buildModuloLogin(viewModel),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  //layout a due colonne con testi a sinistra e form a destra per tablet
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
              child: SingleChildScrollView(child: _buildModuloLogin(viewModel)),
            ),
          ),
        ),
      ],
    );
  }

  //sezione superiore contenente il titolo di benvenuto e il logo circolare
  Widget _buildIntestazione() {
    return Column(
      children: [
        const Text(
          "Bentornato!",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Container(
          width: 236,
          height: 236,
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.directions_car, size: 120, color: Colors.blue),
        ),
        const SizedBox(height: 32),
        const Text(
          "Accedi per gestire le tue guide e i tuoi esami",
          style: TextStyle(fontSize: 14, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  //modulo di login con i campi di testo e i pulsanti per accedere o registrarsi
  Widget _buildModuloLogin(UtenteViewModel viewModel) {
    return Column(
      children: [
        TextField(
          controller: codiceController,
          onChanged: (v) {
            codiceController.text = viewModel.formattaCodiceFiscale(v);
            setState(() => messaggioErrore = "");
          },
          decoration: InputDecoration(
            labelText: "Codice Fiscale",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 16),
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
        SizedBox(
          height: 20,
          child: Text(
            messaggioErrore,
            style: const TextStyle(color: Colors.red, fontSize: 14),
          ),
        ),
        const SizedBox(height: 8),
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
