import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiket_konser/providers/auth_provider.dart';
import 'package:tiket_konser/providers/order_provider.dart';
import 'package:tiket_konser/models/concert_model.dart';
import 'package:tiket_konser/core/constants.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentPage extends StatefulWidget {
  final ConcertModel concert;
  const PaymentPage({super.key, required this.concert});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'PAYMENT',
          style: GoogleFonts.pressStart2p(fontSize: 14, color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(color: AppColors.border, height: 2),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ORDER SUMMARY", style: GoogleFonts.pressStart2p(fontSize: 8, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: AppTheme.retroCard,
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border, width: 2),
                      image: DecorationImage(
                        image: NetworkImage(widget.concert.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.secondary, width: 1),
                          ),
                          child: Text(
                            "CONCERT",
                            style: GoogleFonts.pressStart2p(fontSize: 6, color: AppColors.textPrimary),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.concert.name.toUpperCase(),
                          style: GoogleFonts.pressStart2p(fontSize: 10, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 12, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('yyyy-MM-dd').format(widget.concert.date),
                              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Promo Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.approved.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.approved, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.approved),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "PROMO APPLIED! 🎉",
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.approved),
                        ),
                        Text(
                          "Retro vibe discount automatically added.",
                          style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text("PAYMENT METHOD", style: GoogleFonts.pressStart2p(fontSize: 8, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary, width: 2),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 10),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: const Icon(Icons.qr_code_scanner, color: AppColors.primary, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("QRIS", style: GoogleFonts.pressStart2p(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text("Pay with any E-Wallet or Bank App", style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle, color: AppColors.primary),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Text("PRICE DETAILS", style: GoogleFonts.pressStart2p(fontSize: 8, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            _priceRow("Ticket Fee", currencyFormat.format(widget.concert.price)),
            _priceRow("Admin Fee", currencyFormat.format(2500)),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: AppColors.border, thickness: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("TOTAL PAY", style: GoogleFonts.pressStart2p(fontSize: 10, fontWeight: FontWeight.bold)),
                Text(
                  currencyFormat.format(widget.concert.price + 2500),
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: AppColors.border, width: 2)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : () async {
              setState(() => _isLoading = true);
              // SQA DATA INTEGRITY: Ensure total price includes admin fee (2500)
              final totalWithFee = widget.concert.price + 2500;
              final success = await orderProvider.createOrder(
                widget.concert.copyWith(price: totalWithFee), 
                authProvider.user!.id
              );
              setState(() => _isLoading = false);
              
              if (success) {
                _showSuccessDialog();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: _isLoading 
              ? const CircularProgressIndicator(color: Colors.white)
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      "PAY NOW • ${currencyFormat.format(widget.concert.price + 2500)}",
                      style: GoogleFonts.pressStart2p(fontSize: 9),
                    ),
                  ],
                ),
          ),
        ),
      ),
    );
  }

  Widget _priceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
          Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: AppTheme.retroCard,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.approved,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 2),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 24),
              Text(
                "PAYMENT SUCCESSFUL!",
                textAlign: TextAlign.center,
                style: GoogleFonts.pressStart2p(fontSize: 14, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              Text(
                "Your payment is being verified. Please wait for admin approval to get your ticket.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    context.go('/orders'); // Navigate
                  },
                  child: const Text("VIEW MY TICKETS"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
