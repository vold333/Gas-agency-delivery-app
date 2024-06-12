import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'delivery_form_page.dart';

// Define the GasQuantity model
class GasQuantity {
  final int id;
  final int driverId;
  final int lpgQuantity;
  final double lpgPrice;
  final int butaneQuantity;
  final double butanePrice;
  final int propaneQuantity;
  final double propanePrice;

  GasQuantity({
    required this.id,
    required this.driverId,
    required this.lpgQuantity,
    required this.lpgPrice,
    required this.butaneQuantity,
    required this.butanePrice,
    required this.propaneQuantity,
    required this.propanePrice,
  });

  factory GasQuantity.fromJson(Map<String, dynamic> json) {
    return GasQuantity(
      id: json['id'],
      driverId: json['driverId'],
      lpgQuantity: json['lpgQuantity'],
      lpgPrice: json['lpgPrice'],
      butaneQuantity: json['butaneQuantity'],
      butanePrice: json['butanePrice'],
      propaneQuantity: json['propaneQuantity'],
      propanePrice: json['propanePrice'],
    );
  }
}

// Define the Customer model
class Customer {
  final int id;
  final String name;
  final String contactNumber;
  final String consumerNumber;
  final String address;
  final String email;
  final String document;
  final int lpgQuantity;
  final int butaneQuantity;
  final int propaneQuantity;
  final double totalPrice;
  final DateTime createdAt;
  final String driverName;

  Customer({
    required this.id,
    required this.name,
    required this.contactNumber,
    required this.consumerNumber,
    required this.address,
    required this.email,
    required this.document,
    required this.lpgQuantity,
    required this.butaneQuantity,
    required this.propaneQuantity,
    required this.totalPrice,
    required this.createdAt,
    required this.driverName,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      contactNumber: json['contactNumber'],
      consumerNumber: json['consumerNumber'],
      address: json['address'],
      email: json['email'],
      document: json['document'],
      lpgQuantity: json['lpgQuantity'],
      butaneQuantity: json['butaneQuantity'],
      propaneQuantity: json['propaneQuantity'],
      totalPrice: json['totalPrice'],
      createdAt: DateTime.parse(json['createdAt']),
      driverName: json['driver']['name'],
    );
  }
}

// Fetch gas quantity from API
Future<GasQuantity> fetchGasQuantity(int driverId) async {
  final response =
      await http.get(Uri.parse('http://192.168.1.8:8080/api/gas/$driverId'));

  if (response.statusCode == 200) {
    return GasQuantity.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load gas quantities');
  }
}

// Fetch customer details from API
Future<List<Customer>> fetchCustomerDetails(int driverId) async {
  final response = await http
      .get(Uri.parse('http://192.168.1.8:8080/api/order/get/$driverId'));

  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = jsonDecode(response.body);
    return jsonResponse.map((customer) => Customer.fromJson(customer)).toList();
  } else {
    throw Exception('Failed to load customer details');
  }
}

// HomePage Widget
class HomePage extends StatefulWidget {
  static const routeName = '/home';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<GasQuantity> futureGasQuantity;
  late Future<List<Customer>> futureCustomerDetails;

  String _formatDate(DateTime date) {
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String year = date.year.toString();
    return '$day-$month-$year';
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String userName = arguments['name'];
    final int driverId = arguments['id'];

    futureGasQuantity = fetchGasQuantity(driverId);
    futureCustomerDetails = fetchCustomerDetails(driverId);

    return RefreshIndicator(
      onRefresh: () {
        setState(() {
          futureGasQuantity = fetchGasQuantity(driverId);
          futureCustomerDetails = fetchCustomerDetails(driverId);
        });
        return Future.delayed(Duration(seconds: 1));
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Gas Agency',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
        body: FutureBuilder<GasQuantity>(
          future: futureGasQuantity,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final gasQuantity = snapshot.data!;
              final int a = gasQuantity.lpgQuantity;
              final int b = gasQuantity.butaneQuantity;
              final int c = gasQuantity.propaneQuantity;
              final int total = a + b + c;

              return Stack(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.23,
                            child: Container(
                              padding: EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: Colors.cyan,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Table(
                                    columnWidths: const {
                                      0: FlexColumnWidth(),
                                      1: FlexColumnWidth(),
                                      2: FlexColumnWidth(),
                                    },
                                    children: [
                                      TableRow(
                                        children: [
                                          Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                'LPG',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                'Butane',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                'Propane',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      TableRow(
                                        children: [
                                          Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                '$a',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                '$b',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                '$c',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: FutureBuilder<List<Customer>>(
                                  future: futureCustomerDetails,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Text(
                                        'Delivered: ...',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      );
                                    } else if (snapshot.hasError) {
                                      return Text(
                                        'Delivered: Error',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      );
                                    } else if (snapshot.hasData) {
                                      final customers = snapshot.data!;
                                      int totalDelivered = customers.fold(
                                        0,
                                        (sum, customer) =>
                                            sum +
                                            customer.lpgQuantity +
                                            customer.butaneQuantity +
                                            customer.propaneQuantity,
                                      );

                                      return Text(
                                        'Delivered: $totalDelivered',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      );
                                    } else {
                                      return Text(
                                        'Delivered: 0',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: Text(
                                  'Total: $total',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Center(
                            child: Text(
                              'Delivery Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          FutureBuilder<List<Customer>>(
                            future: futureCustomerDetails,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              } else if (snapshot.hasData) {
                                final customers = snapshot.data!;
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 12),
                                        Expanded(
                                          child: ListView.builder(
                                            itemCount: customers.length,
                                            itemBuilder: (context, index) {
                                              final customer = customers[index];
                                              return Card(
                                                margin:
                                                    EdgeInsets.only(bottom: 12),
                                                elevation: 4,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            'Customer: ${customer.name}',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                          Text(
                                                            'Date: ${_formatDate(customer.createdAt)}',
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 8),
                                                      Text(
                                                        'Contact Number: ${customer.contactNumber}',
                                                      ),
                                                      Text(
                                                        'Consumer Number: ${customer.consumerNumber}',
                                                      ),
                                                      SizedBox(height: 8),
                                                      Text(
                                                        'LPG Quantity: ${customer.lpgQuantity}',
                                                      ),
                                                      Text(
                                                        'Butane Quantity: ${customer.butaneQuantity}',
                                                      ),
                                                      Text(
                                                        'Propane Quantity: ${customer.propaneQuantity}',
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                            'Total Price: ',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            '${customer.totalPrice}',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                return Center(child: Text('No data available'));
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 52,
                    right: 46,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              DeliveryFormPage.routeName,
                              arguments: {'driverId': driverId},
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '+',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(16),
                            backgroundColor: Colors.cyan,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return Center(child: Text('No data available'));
            }
          },
        ),
      ),
    );
  }
}

