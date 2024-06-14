// ignore: file_names
import 'package:flutter/material.dart';

class InfoLatLong extends StatefulWidget {
  const InfoLatLong(
      {super.key, required this.Latitude, required this.Longitude});
  final String Latitude;
  final String Longitude;
  @override
  State<StatefulWidget> createState() => _InfoLatLongState();
}

class _InfoLatLongState extends State<InfoLatLong> {
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _longController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    _latController.text = widget.Latitude;
    _longController.text = widget.Longitude;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Wrap(
        children: [
          const Text(
            'Latitud:',
            style: TextStyle(fontSize: 16.0),
          ),
          TextField(
            controller: _latController,
            readOnly: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16.0),
          const Text(
            'Longitud:',
            style: TextStyle(fontSize: 16.0),
          ),
          TextField(
            controller: _longController,
            readOnly: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
