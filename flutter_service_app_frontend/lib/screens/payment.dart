import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

class PaymentPage extends StatefulWidget {
  final String userToken;
  final String requestId;
  final String workerName;
  final String requestTitle;

  const PaymentPage({
    Key? key,
    required this.userToken,
    required this.requestId,
    required this.workerName,
    required this.requestTitle,
  }) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  
  bool _isProcessing = false;

  @override
  void dispose() {
    _amountController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }
