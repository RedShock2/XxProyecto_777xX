import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/pokemon.dart';
import '../utils/type_colors.dart';

class TeamSlotWidget extends StatelessWidget {
  final int index;
  final Pokemon? pokemon;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const TeamSlotWidget({
    super.key,
    required this.index,
    this.pokemon,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: pokemon != null
              ? LinearGradient(
                  colors: [
                    TypeColors.of(pokemon!.types.first).withOpacity(0.5),
                    const Color(0xFF16213E),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: pokemon == null ? Colors.white10 : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: pokemon != null
                ? TypeColors.of(pokemon!.types.first).withOpacity(0.7)
                : Colors.white24,
            width: 1.5,
          ),
        ),
        child: pokemon != null ? _filledSlot() : _emptySlot(),
      ),
    );
  }

  Widget _filledSlot() {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CachedNetworkImage(
              imageUrl: pokemon!.spriteUrl,
              height: 60,
              fit: BoxFit.contain,
              errorWidget: (_, __, ___) => const Icon(
                Icons.catching_pokemon,
                size: 40,
                color: Colors.white54,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                pokemon!.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        if (onRemove != null)
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Widget _emptySlot() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.add, color: Colors.white38, size: 28),
        Text(
          'Slot ${index + 1}',
          style: const TextStyle(color: Colors.white38, fontSize: 10),
        ),
      ],
    );
  }
}
