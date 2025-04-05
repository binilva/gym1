import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required String username});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final Razorpay _razorpay = Razorpay();
  final TextEditingController _amountController = TextEditingController();
  String? userName;
  String? userEmail;
  bool isLoading = true;

  List<Map<String, String>> trainerDetails =
  []; // List to store trainer names and emails
  String? selectedTrainer; // Selected trainer name
  String? selectedTrainerEmail; // Selected trainer email

  @override
  void initState() {
    super.initState();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    fetchUserData();
    fetchTrainers(); // Fetch trainer names and emails
  }

  Future<void> fetchUserData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        print("No user logged in.");
        return;
      }

      userEmail = user.email;
      print("User Email: $userEmail");

      final response = await Supabase.instance.client
          .from('profiles')
          .select('name')
          .eq('email', userEmail!)
          .maybeSingle();

      setState(() {
        userName = response?['name'] ?? userEmail;
        isLoading = false;
      });

      print("Fetched User Name: $userName");
    } catch (error) {
      print("Error fetching user data: $error");
      setState(() {
        userName = "Guest";
        isLoading = false;
      });
    }
  }

  Future<void> fetchTrainers() async {
    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('name, email') // Fetch names and emails
          .eq('role', 'trainer'); // Fetch where role is 'trainer'

      List<Map<String, String>> trainers = (response as List<dynamic>)
          .map((trainer) => {
        'name': trainer['name'].toString(),
        'email': trainer['email'].toString()
      })
          .toList();

      setState(() {
        trainerDetails = trainers;
        if (trainerDetails.isNotEmpty) {
          selectedTrainer = trainerDetails[0]['name']; // Default selection
          selectedTrainerEmail = trainerDetails[0]['email']; // Default email
        }
      });
    } catch (error) {
      print("Error fetching trainers: $error");
    }
  }

  void makePayment() {
    double amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0 || selectedTrainer == null) return;

    var options = {
      'key': 'rzp_test_zH10qs9atlSzwy',
      'amount': (amount * 100).toInt(),
      'currency': 'INR',
      'name': userName ?? "User",
      'description': 'Payment for Trainer: $selectedTrainer',
      'prefill': {'contact': '9876543210', 'email': userEmail ?? "unknown"},
    };
    _razorpay.open(options);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    await Supabase.instance.client.from('payments').insert({
      'payment_id': response.paymentId,
      'user_name': userName,
      'user_email': userEmail,
      'trainer_name': selectedTrainer,
      'trainer_email': selectedTrainerEmail, // Save trainer email
      'amount': _amountController.text,
      'status': 'success',
      'timestamp': DateTime.now().toIso8601String(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Successful: ${response.paymentId}")),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("External Wallet Selected: ${response.walletName}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Flutter Payment App")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const CircularProgressIndicator()
            else
              Column(
                children: [
                  Text(
                    "User Name: ${userName ?? 'N/A'}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

            const SizedBox(height: 20),

            // Dropdown for selecting trainer
            DropdownButtonFormField<String>(
              value: selectedTrainer,
              items: trainerDetails.map((trainer) {
                return DropdownMenuItem<String>(
                  value: trainer['name'],
                  child: Text('${trainer['name']} '),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedTrainer = value;
                  selectedTrainerEmail = trainerDetails.firstWhere(
                          (trainer) => trainer['name'] == value)['email'];
                });
              },
              decoration: const InputDecoration(
                labelText: "Select Trainer",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter Amount",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: makePayment,
              child: const Text("Pay Now"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentHistoryScreen(),
                ),
              ),
              child: const Text("View Payment History"),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentHistoryScreen extends StatelessWidget {
  final SupabaseClient supabase = Supabase.instance.client;

  PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment History")),
      body: FutureBuilder(
        future: supabase
            .from('payments')
            .select()
            .order('timestamp', ascending: false),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final payments = snapshot.data as List<dynamic>;
          return ListView.builder(
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final payment = payments[index];
              return ListTile(
                title: Text("Payment ID: ${payment['payment_id']}"),
                subtitle: Text(
                    "Trainer: ${payment['trainer_name']} - Amount: ₹${payment['amount']}"),
                trailing: Text(payment['status'].toUpperCase()),
              );
            },
          );
        },
      ),
    );
  }
}
