/*import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  final double totalAmount = 150.0; // يمكنك تغيير هذا الرقم حسب الحاجة

  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        centerTitle: true,
        backgroundColor: Color(0xFFA0C1BF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // معلومات الدفع
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Service Fee'),
              trailing: Text('\$$totalAmount'),
            ),
            const Divider(),

            const SizedBox(height: 24),

            const Text(
              'Choose Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // الدفع بالبطاقة
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('Credit Card'),
              onTap: () {
                _showCardPaymentDialog(context);
              },
            ),

            // الدفع عند الاستلام
            ListTile(
              leading: const Icon(Icons.money_off),
              title: const Text('Cash on Delivery'),
              onTap: () {
                _confirmPayment(context, 'Cash on Delivery');
              },
            ),

            const Spacer(),

            // زر التأكيد
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA0C1BF),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                _confirmPayment(context, 'Credit Card');
              },
              child: const Center(child: Text('Complete Payment')),
            ),
          ],
        ),
      ),
    );
  }

  // نافذة إدخال بيانات البطاقة
  void _showCardPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Enter Credit Card Details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Card Number'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Expiry Date (MM/YY)',
                  ),
                  keyboardType: TextInputType.text,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'CVV'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _confirmPayment(context, 'Credit Card');
                },
                child: const Text('Pay Now'),
              ),
            ],
          ),
    );
  }

  // رسالة التأكيد بعد الدفع
  void _confirmPayment(BuildContext context, String paymentMethod) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Payment Successful'),
            content: Text(
              'You have successfully paid \$150 via $paymentMethod.',
            ),
            actions: [
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
*/

import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  final double totalAmount = 150.0; // يمكنك تعديل هذا الرقم لاحقًا ديناميكيًا

  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        centerTitle: true,
        backgroundColor: Color(0xFFA0C1BF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات الدفع
            const Text(
              'Payment Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Service Fee'),
              trailing: Text('\$ $totalAmount'),
            ),
            const Divider(),

            const SizedBox(height: 24),

            // عنوان قسم البطاقة
            const Text(
              'Credit Card Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // حقل رقم البطاقة
            const TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Card Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // حقل تاريخ الانتهاء
            const TextField(
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'Expiry Date (MM/YY)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // حقل CVV
            const TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'CVV',
                border: OutlineInputBorder(),
              ),
            ),

            const Spacer(),

            // زر التأكيد
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA0C1BF),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                _confirmPayment(context, 'Credit Card');
              },
              child: const Center(child: Text('Complete Payment')),
            ),
          ],
        ),
      ),
    );
  }

  // رسالة التأكيد بعد الدفع
  void _confirmPayment(BuildContext context, String paymentMethod) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Payment Successful'),
            content: Text(
              'You have successfully paid \$150 via $paymentMethod.',
            ),
            actions: [
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
