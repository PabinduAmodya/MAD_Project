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
