import 'package:flutter/material.dart';
import 'package:mini_shop/app/strings.dart';
import 'package:mini_shop/app/theme.dart';

/// A product photo on a soft, always-light background (store photos are white).
class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.url, this.padding = 16, this.radius = 18});

  final String url;
  final double padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: ColoredBox(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Image.network(
            url,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
            frameBuilder: (context, child, frame, sync) => AnimatedOpacity(
              opacity: frame == null && !sync ? 0 : 1,
              duration: const Duration(milliseconds: 300),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class RatingStars extends StatelessWidget {
  const RatingStars({super.key, required this.rating, this.count, this.size = 14});

  final double rating;
  final int? count;
  final double size;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Semantics(
      label: 'Rated ${rating.toStringAsFixed(1)} out of 5',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= 5; i++)
            Icon(
              rating >= i ? Icons.star_rounded : (rating >= i - 0.5 ? Icons.star_half_rounded : Icons.star_outline_rounded),
              size: size,
              color: gold,
            ),
          const SizedBox(width: 4),
          Text(
            count == null ? rating.toStringAsFixed(1) : '${rating.toStringAsFixed(1)} ($count)',
            style: TextStyle(fontSize: size - 2, color: muted, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({super.key, required this.value, required this.onChanged, this.min = 1, this.compact = false});

  final int value;
  final int min;
  final bool compact;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final size = compact ? 32.0 : 42.0;
    Widget button(IconData icon, VoidCallback? onTap, String label) => SizedBox(
          width: size,
          height: size,
          child: IconButton.filledTonal(
            tooltip: label,
            padding: EdgeInsets.zero,
            iconSize: compact ? 16 : 20,
            onPressed: onTap,
            icon: Icon(icon),
          ),
        );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        button(Icons.remove_rounded, value > min ? () => onChanged(value - 1) : null, context.t('Decrease')),
        SizedBox(
          width: compact ? 30 : 40,
          child: Text('$value',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: compact ? 14 : 16, color: scheme.onSurface)),
        ),
        button(Icons.add_rounded, () => onChanged(value + 1), context.t('Increase')),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.message, this.action});

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(color: scheme.primaryContainer, shape: BoxShape.circle),
              child: Icon(icon, size: 44, color: scheme.onPrimaryContainer),
            ),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: scheme.onSurfaceVariant, height: 1.4)),
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}

String titleCase(String value) =>
    value.split(' ').map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');

IconData categoryIcon(String category) {
  final c = category.toLowerCase();
  if (c.contains('jewel')) return Icons.diamond_outlined;
  if (c.contains('electronic')) return Icons.headphones_outlined;
  if (c.contains('women')) return Icons.woman_outlined;
  if (c.contains('men')) return Icons.man_outlined;
  return Icons.category_outlined;
}
