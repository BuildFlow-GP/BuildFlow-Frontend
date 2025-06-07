import 'package:buildflow_frontend/themes/app_colors.dart'; // تأكد أن هذا المسار صحيح لمشروعك
import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  final double totalAmount;
  const PaymentScreen({super.key, this.totalAmount = 150.0});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _isLoading = false;
  bool _areFieldsFilled = false;

  @override
  void initState() {
    super.initState();
    _cardNumberController.addListener(_updateButtonState);
    _expiryDateController.addListener(_updateButtonState);
    _cvvController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _cardNumberController.removeListener(_updateButtonState);
    _expiryDateController.removeListener(_updateButtonState);
    _cvvController.removeListener(_updateButtonState);
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      _areFieldsFilled =
          _cardNumberController.text.isNotEmpty &&
          _expiryDateController.text.isNotEmpty &&
          _cvvController.text.isNotEmpty;
    });
  }

  void _processPayment() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _isLoading = false;
      });
      _showPaymentResultDialog(
        context,
        title: 'Payment Successful',
        content:
            'You have successfully paid \$${widget.totalAmount.toStringAsFixed(2)} via Credit Card.',
        isSuccess: true,
      );
      _cardNumberController.clear();
      _expiryDateController.clear();
      _cvvController.clear();
      _updateButtonState();
    } else {
      _showPaymentResultDialog(
        context,
        title: 'Payment Failed',
        content: 'Please check your card details and try again.',
        isSuccess: false,
      );
    }
  }

  void _showPaymentResultDialog(
    BuildContext context, {
    required String title,
    required String content,
    required bool isSuccess,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            title: Row(
              children: [
                Icon(
                  isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                  color: isSuccess ? AppColors.success : AppColors.error,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ],
            ),
            content: Text(
              content,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (isSuccess) {
                    // يمكنك هنا الانتقال إلى شاشة أخرى أو تحديث الحالة
                    // Navigator.of(context).pushReplacement(...);
                  }
                },
                child: Text('OK', style: TextStyle(color: AppColors.accent)),
              ),
            ],
          ),
    );
  }

  String? _validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Expiry date is required';
    }
    final parts = value.split('/');
    if (parts.length != 2) {
      return 'Invalid format (MM/YY)';
    }
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);

    if (month == null || year == null || month < 1 || month > 12) {
      return 'Invalid month/year';
    }
    final currentYear = DateTime.now().year % 100; // آخر رقمين من السنة الحالية
    final currentMonth = DateTime.now().month;

    if (year < currentYear || (year == currentYear && month < currentMonth)) {
      return 'Card has expired';
    }
    return null;
  }

  String? _validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Card number is required';
    }
    if (value.replaceAll(' ', '').length != 16) {
      return 'Card number must be 16 digits';
    }
    return null;
  }

  String? _validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'CVV is required';
    }
    if (value.length < 3 || value.length > 4) {
      return 'CVV must be 3 or 4 digits';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobileLayout = screenWidth < 700;
    final bool useMaxWidth = screenWidth > 1000;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: null, // AppBar المدمج معطل لأننا نستخدم AppBar مخصص
      body: Column(
        children: [
          // AppBar المخصص
          Container(
            padding: const EdgeInsets.fromLTRB(
              16,
              0,
              16,
              20,
            ), // padding من الأعلى سيكون بواسطة SafeArea
            decoration: BoxDecoration(
              color: AppColors.primary,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              // لضمان عدم تداخل AppBar مع شريط الحالة
              bottom: false, // لا نحتاج safe area من الأسفل هنا
              child: Padding(
                // إضافة padding إضافي داخل الـ SafeArea إذا لزم الأمر للتحكم الدقيق
                padding: const EdgeInsets.only(
                  top: 8.0,
                ), // مسافة إضافية من الأعلى داخل الـ SafeArea
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 28,
                      ),
                      color: AppColors.accent,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        "Secure Payment",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                          letterSpacing: 0.8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // لموازنة زر الرجوع
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: useMaxWidth ? 800 : double.infinity,
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    isMobileLayout ? 12.0 : 20.0, // يسار
                    20.0, // أعلى (مسافة من الـ AppBar المخصص)
                    isMobileLayout ? 12.0 : 20.0, // يمين
                    isMobileLayout ? 12.0 : 20.0, // أسفل
                  ),
                  child: Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        isMobileLayout ? 12.0 : 16.0,
                      ),
                    ),
                    color: AppColors.card,
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: EdgeInsets.all(isMobileLayout ? 16.0 : 24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildPaymentSummary(isMobileLayout),
                            const SizedBox(height: 24),
                            _buildCardDetailsSection(isMobileLayout),
                            const SizedBox(height: 32),
                            _buildPayButton(),
                            const SizedBox(height: 16),
                            _buildSecureGatewayNotice(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(bool isMobileLayout) {
    return Card(
      elevation: 1.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: AppColors.card.withOpacity(0.95),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: EdgeInsets.all(isMobileLayout ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.receipt_long,
                color: AppColors.accent,
                size: 28,
              ),
              title: const Text(
                'Service Fee',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
              ),
              trailing: Text(
                '\$ ${widget.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardDetailsSection(bool isMobileLayout) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter Card Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 20),
        _buildTextFormField(
          controller: _cardNumberController,
          labelText: 'Card Number',
          hintText: 'xxxx xxxx xxxx xxxx',
          keyboardType: TextInputType.number,
          icon: Icons.credit_card,
          validator: _validateCardNumber,
        ),
        const SizedBox(height: 16),
        isMobileLayout
            ? Column(
              children: [
                _buildTextFormField(
                  controller: _expiryDateController,
                  labelText: 'Expiry Date',
                  hintText: 'MM/YY',
                  keyboardType: TextInputType.datetime,
                  icon: Icons.calendar_today,
                  validator: _validateExpiryDate,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _cvvController,
                  labelText: 'CVV',
                  hintText: 'xxx',
                  keyboardType: TextInputType.number,
                  isObscure: true,
                  icon: Icons.lock_outline,
                  validator: _validateCVV,
                ),
              ],
            )
            : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildTextFormField(
                    controller: _expiryDateController,
                    labelText: 'Expiry Date',
                    hintText: 'MM/YY',
                    keyboardType: TextInputType.datetime,
                    icon: Icons.calendar_today,
                    validator: _validateExpiryDate,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextFormField(
                    controller: _cvvController,
                    labelText: 'CVV',
                    hintText: 'xxx',
                    keyboardType: TextInputType.number,
                    isObscure: true,
                    icon: Icons.lock_outline,
                    validator: _validateCVV,
                  ),
                ),
              ],
            ),
      ],
    );
  }

  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _areFieldsFilled
                  ? AppColors.accent
                  : AppColors.primary.withOpacity(0.5),
          foregroundColor:
              _areFieldsFilled ? Colors.white : Colors.white.withOpacity(0.7),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: _areFieldsFilled ? 3 : 0,
        ),
        onPressed: (_areFieldsFilled && !_isLoading) ? _processPayment : null,
        child:
            _isLoading
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
                : const Text('Pay Now'),
      ),
    );
  }

  Widget _buildSecureGatewayNotice() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.verified_user_outlined,
            color: AppColors.textSecondary,
            size: 16,
          ),
          const SizedBox(width: 8),
          const Text(
            "Secure Payment Gateway",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required TextInputType keyboardType,
    required IconData icon,
    bool isObscure = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isObscure,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.7)),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: AppColors.accent, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: AppColors.error, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: AppColors.error, width: 2.0),
        ),
        filled: true,
        fillColor: AppColors.card.withOpacity(0.8),
      ),
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
