import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/team_provider.dart';
import '../models/team.dart';

class QrScreen extends StatefulWidget {
  final String? teamJson;
  const QrScreen({super.key, this.teamJson});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  bool _scanned = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.teamJson != null ? 0 : 1,
    );
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR de Equipo'),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: const Color(0xFFCC0000),
          tabs: const [
            Tab(icon: Icon(Icons.qr_code), text: 'Mostrar QR'),
            Tab(icon: Icon(Icons.qr_code_scanner), text: 'Escanear'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _ShowQrTab(teamJson: widget.teamJson),
          _ScanQrTab(
            onScanned: _scanned ? null : (json) => _importTeam(context, json),
          ),
        ],
      ),
    );
  }

  Future<void> _importTeam(BuildContext context, String json) async {
    if (_scanned) return;
    setState(() => _scanned = true);

    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      final team = Team.fromJson(data);
      await context.read<TeamProvider>().importTeam(team);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Equipo "${team.name}" importado'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (_) {
      setState(() => _scanned = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR inválido o equipo corrupto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _ShowQrTab extends StatelessWidget {
  final String? teamJson;
  const _ShowQrTab({this.teamJson});

  @override
  Widget build(BuildContext context) {
    if (teamJson == null) {
      final teams = context.watch<TeamProvider>().teams;
      if (teams.isEmpty) {
        return const Center(
          child: Text(
            'No hay equipos para mostrar',
            style: TextStyle(color: Colors.white54),
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: teams.length,
        itemBuilder: (_, i) => _TeamQrCard(team: teams[i]),
      );
    }
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _QrDisplay(data: teamJson!),
      ),
    );
  }
}

class _TeamQrCard extends StatefulWidget {
  final Team team;
  const _TeamQrCard({required this.team});

  @override
  State<_TeamQrCard> createState() => _TeamQrCardState();
}

class _TeamQrCardState extends State<_TeamQrCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.qr_code, color: Colors.white70),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.team.name,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white54,
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 16),
                _QrDisplay(data: widget.team.toQrJson()),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QrDisplay extends StatelessWidget {
  final String data;
  const _QrDisplay({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: QrImageView(
            data: data,
            version: QrVersions.auto,
            size: 240,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Escanea con otro dispositivo\npara importar el equipo',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
      ],
    );
  }
}

class _ScanQrTab extends StatefulWidget {
  final ValueChanged<String>? onScanned;
  const _ScanQrTab({this.onScanned});

  @override
  State<_ScanQrTab> createState() => _ScanQrTabState();
}

class _ScanQrTabState extends State<_ScanQrTab> {
  final _ctrl = MobileScannerController();
  bool _detected = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller: _ctrl,
          onDetect: (capture) {
            if (_detected || widget.onScanned == null) return;
            final barcode = capture.barcodes.firstOrNull;
            final value = barcode?.rawValue;
            if (value != null) {
              setState(() => _detected = true);
              widget.onScanned!(value);
            }
          },
        ),
        // Scan overlay
        Center(
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFCC0000), width: 3),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        Positioned(
          bottom: 32,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Apunta la cámara al código QR del equipo',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: IconButton(
            onPressed: () => _ctrl.toggleTorch(),
            icon: ValueListenableBuilder(
              valueListenable: _ctrl,
              builder: (_, state, __) => Icon(
                state.torchState == TorchState.on
                    ? Icons.flash_on
                    : Icons.flash_off,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
