import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

@Preview()
Widget previewSchermataEsiti() {
  return const MaterialApp(
    home: SchermataEsiti(),
  );
}


class SchermataEsiti extends StatelessWidget {
  const SchermataEsiti({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Esiti esami"),
        titleSpacing: 10,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          //Utilizzo una widget personalizzato dedicato che creo sotto e richiamo qua
          _buildEsitoCard(
            context,
            isPromosso: true,
            titolo: "PROMOSSO",
            esame: "Esame di teoria",
            patente: "patente B",
            dataLuogo: "Ven 17 apr, Campobasso",
            color: const Color(0xFFDEE1F3),
          ),
          const SizedBox(height: 16),
          _buildEsitoCard(
            context,
            isPromosso: false,
            titolo: "RESPINTO",
            esame: "Esame di guida",
            patente: "patente B",
            dataLuogo: "Gio 30 apr, Campobasso",
            color: const Color(0xFFF9F1F7),
          ),
        ],
      ),
    );
  }

  Widget _buildEsitoCard(
    BuildContext context, {
    required bool isPromosso,
    required String titolo,
    required String esame,
    required String patente,
    required String dataLuogo,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isPromosso ? Icons.check : Icons.close,
            size: 24,
            color: Colors.black87,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titolo,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  esame,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  patente,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dataLuogo,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {/* Da implementare: navigazione al dettaglio esito */},
            child: const Row(
              children: [
                Text(
                  "Vedi",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_right, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
