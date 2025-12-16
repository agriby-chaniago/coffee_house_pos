import 'package:flutter/material.dart';

class OrderStatusBadge extends StatelessWidget {
  final String status;

  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = _getStatusAttributes(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  (Color, IconData, String) _getStatusAttributes(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return (
          const Color(
              0xFFDF8E1D), // orange/yellow (Catppuccin yellow) - better visibility
          Icons.schedule,
          'Pending',
        );
      case 'preparing':
        return (
          const Color(0xFF1E66F5), // blue (Catppuccin blue)
          Icons.restaurant,
          'Preparing',
        );
      case 'ready':
        return (
          const Color(0xFFDF8E1D), // yellow (Catppuccin yellow)
          Icons.done,
          'Ready',
        );
      case 'completed':
        return (
          const Color(0xFF40A02B), // green (Catppuccin green)
          Icons.check_circle,
          'Completed',
        );
      case 'cancelled':
        return (
          const Color(0xFFD20F39), // red (Catppuccin red)
          Icons.cancel,
          'Cancelled',
        );
      default:
        return (
          const Color(0xFF7C7F93),
          Icons.help,
          'Unknown',
        );
    }
  }
}
