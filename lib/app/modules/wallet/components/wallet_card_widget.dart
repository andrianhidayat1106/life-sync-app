import 'package:flutter/material.dart';

class WalletCardWidget extends StatelessWidget {
  final String title;
  final String balance;
  final Color backgroundColor;

  const WalletCardWidget({
    super.key,
    required this.title,
    required this.balance,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            // Menggunakan .withOpacity karena .withValues adalah fitur baru (Flutter 3.27+)
            // Ambil textPrimary sebagai fallback bayangan tipis agar elegan
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title
                    .toUpperCase(), // Memaksa kapital untuk kecocokan gaya letterSpacing
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            balance,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12), // Memberikan ruang sebelum Divider
          const Divider(
            color: Colors
                .white24, // Membuat warna divider tipis transparan agar estetik
            thickness: 1,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Total Saldo",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Icon(Icons.circle, size: 24, color: Colors.white24),
            ],
          ),
        ],
      ),
    );
  }
}
