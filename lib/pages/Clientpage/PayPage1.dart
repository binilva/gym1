import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PayPage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pay for Gym Membership')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Payment Page',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'Here you can make payments for your gym membership.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // Handle payment action here
                  print('Payment Processed');
                },
                child: Text('Proceed with Payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
