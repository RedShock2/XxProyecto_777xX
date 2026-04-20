import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/pokemon.dart';
import '../utils/type_colors.dart';
import 'type_badge.dart';

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;
  final bool compact;

  const PokemonCard({
    super.key,
    required this.pokemon,
    this.onTap,
    this.onAdd,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = TypeColors.of(pokemon.types.first);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryColor.withOpacity(0.6), const Color(0xFF16213E)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: compact ? _buildCompact() : _buildFull(context),
      ),
    );
  }

  Widget _buildCompact() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _sprite(60),
          const SizedBox(height: 4),
          Text(
            pokemon.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: pokemon.types
                .map((t) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: TypeBadge(type: t, fontSize: 8),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFull(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _sprite(80),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${pokemon.id.toString().padLeft(3, '0')}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
                Text(
                  pokemon.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  children: pokemon.types.map((t) => TypeBadge(type: t)).toList(),
                ),
                const SizedBox(height: 6),
                Text(
                  'BST: ${pokemon.totalStats}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          if (onAdd != null)
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.white),
              onPressed: onAdd,
            ),
        ],
      ),
    );
  }

  Widget _sprite(double size) {
    return CachedNetworkImage(
      imageUrl: pokemon.spriteUrl,
      width: size,
      height: size,
      fit: BoxFit.contain,
      placeholder: (_, __) => SizedBox(
        width: size,
        height: size,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (_, __, ___) => Icon(
        Icons.catching_pokemon,
        size: size * 0.6,
        color: Colors.white54,
      ),
    );
  }
}
