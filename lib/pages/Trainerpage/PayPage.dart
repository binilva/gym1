import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentListView extends StatefulWidget {
  const PaymentListView({super.key});

  @override
  State<PaymentListView> createState() => _PaymentListViewState();
}

class _PaymentListViewState extends State<PaymentListView> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _payments = [];

  @override
  void initState() {
    super.initState();
    _fetchPayments();
  }

  Future<void> _fetchPayments() async {
    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client
          .from('payments')
          .select()
          .order('timestamp', ascending: false);

      setState(() => _payments = List<Map<String, dynamic>>.from(response));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchPayments,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _payments.isEmpty
          ? const Center(child: Text('No payments found'))
          : ListView.builder(
        itemCount: _payments.length,
        itemBuilder: (context, index) {
          final payment = _payments[index];
          return PaymentCard(payment: payment);
        },
      ),
    );
  }
}

class PaymentCard extends StatelessWidget {
  final Map<String, dynamic> payment;

  const PaymentCard({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment ID: ${payment['payment_id'] ?? 'N/A'}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Amount: ₹${payment['amount'] ?? '0'}'),
            const SizedBox(height: 8),
            Text(
                'Status: ${payment['status']?.toString().toUpperCase() ?? 'UNKNOWN'}'),
            const SizedBox(height: 8),
            Text('Date: ${_formatDate(payment['timestamp'])}'),
            const SizedBox(height: 8),
            Text('User: ${payment['user_name']} (${payment['user_email']})'),
            const SizedBox(height: 8),
            Text(
                'Trainer: ${payment['trainer_name']} (${payment['trainer_email']})'),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown date';
    try {
      return DateTime.parse(timestamp).toLocal().toString();
    } catch (e) {
      return timestamp.toString();
    }
  }
}
