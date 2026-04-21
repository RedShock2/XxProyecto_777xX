import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trainer_provider.dart';
import '../providers/team_provider.dart';
import '../services/camera_service.dart';
import '../services/preferences_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _ctrl.forward();
    _init();
  }

  Future<void> _init() async {
    await Future.wait([
      context.read<TrainerProvider>().load(),
      context.read<TeamProvider>().loadTeams(),
    ]);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trainer = context.watch<TrainerProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Stack(
        children: [
          // Background pokeball pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                ),
                itemCount: 50,
                itemBuilder: (_, __) => const Icon(
                  Icons.catching_pokemon,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ProfileAvatar(trainer: trainer),
                    const SizedBox(height: 24),
                    const Text(
                      'XxProyecto_777xX',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Construye tu equipo Pokémon perfecto',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                    const SizedBox(height: 40),
                    if (!trainer.loaded)
                      const CircularProgressIndicator(color: Color(0xFFCC0000))
                    else if (!trainer.hasProfile)
                      _SetupCard(onDone: _goHome)
                    else
                      _ContinueButton(
                        trainerName: trainer.trainer.name,
                        onContinue: _goHome,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goHome() {
    Navigator.pushReplacementNamed(context, '/home');
  }
}

class _ProfileAvatar extends StatelessWidget {
  final TrainerProvider trainer;
  const _ProfileAvatar({required this.trainer});

  @override
  Widget build(BuildContext context) {
    final path = trainer.trainer.profileImagePath;
    return GestureDetector(
      onTap: () => _pickPhoto(context),
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFCC0000), width: 3),
          color: Colors.white10,
        ),
        child: ClipOval(
          child: path != null
              ? Image.file(File(path), fit: BoxFit.cover)
              : const Icon(
                  Icons.person,
                  size: 64,
                  color: Colors.white38,
                ),
        ),
      ),
    );
  }

  Future<void> _pickPhoto(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSourceType>(
      context: context,
      backgroundColor: const Color(0xFF16213E),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.white),
            title: const Text('Tomar foto', style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.pop(context, ImageSourceType.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library, color: Colors.white),
            title: const Text('Galería', style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.pop(context, ImageSourceType.gallery),
          ),
        ],
      ),
    );
    if (source != null && context.mounted) {
      await context.read<TrainerProvider>().pickProfilePhoto(source);
    }
  }
}

class _SetupCard extends StatefulWidget {
  final VoidCallback onDone;
  const _SetupCard({required this.onDone});

  @override
  State<_SetupCard> createState() => _SetupCardState();
}

class _SetupCardState extends State<_SetupCard> {
  final _formKey = GlobalKey<FormState>();
  final _ctrl = TextEditingController(text: 'Entrenador');

  static final _validName = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ0-9 ]+$');

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFCC0000).withOpacity(0.5)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Text(
              '¿Cuál es tu nombre?',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ctrl,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                errorStyle: const TextStyle(color: Color(0xFFFF6B6B)),
              ),
              validator: (value) {
                final v = value?.trim() ?? '';
                if (v.isEmpty) return 'El nombre no puede estar vacío';
                if (v.length < 3) return 'Mínimo 3 caracteres';
                if (v.length > 16) return 'Máximo 16 caracteres';
                if (!_validName.hasMatch(v)) return 'Solo letras, números y espacios';
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCC0000),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('¡Comenzar!',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<TrainerProvider>().setName(_ctrl.text.trim());
    await PreferencesService.setSetupDone(true);
    widget.onDone();
  }
}

class _ContinueButton extends StatelessWidget {
  final String trainerName;
  final VoidCallback onContinue;
  const _ContinueButton({
    required this.trainerName,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onContinue,
      icon: const Icon(Icons.catching_pokemon),
      label: Text('Continuar como $trainerName'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFCC0000),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
