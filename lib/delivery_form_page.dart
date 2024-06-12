import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class DeliveryFormPage extends StatefulWidget {
  static const routeName = '/delivery';

  @override
  _DeliveryFormPageState createState() => _DeliveryFormPageState();
}

class _DeliveryFormPageState extends State<DeliveryFormPage> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  int? _driverId;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _consumerNumberController =
  TextEditingController();
  final TextEditingController _contactNumberController =
  TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _lpgController = TextEditingController(text: '0');
  final TextEditingController _propaneController =
  TextEditingController(text: '0');
  final TextEditingController _butaneController =
  TextEditingController(text: '0');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, dynamic> arguments =
    ModalRoute
        .of(context)!
        .settings
        .arguments as Map<String, dynamic>;
    setState(() {
      _driverId = arguments['driverId'];
    });
  }

  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedImage != null) {
        _imageFile = File(pickedImage.path);
      }
    });
  }

  Future<Map<String, dynamic>> _getStock(int driverId) async {
    final response = await http.get(Uri.parse('http://192.168.1.8:8080/api/gas/$driverId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load stock');
    }
  }

  Future<void> _updateStock(int driverId, int lpgQuantity, int butaneQuantity, int propaneQuantity) async {
    final response = await http.post(
      Uri.parse('http://192.168.1.8:8080/api/gas/update'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'driverId': driverId,
        'lpgQuantity': lpgQuantity,
        'butaneQuantity': butaneQuantity,
        'propaneQuantity': propaneQuantity,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update stock');
    }
  }

  void _removeImage() {
    setState(() {
      _imageFile = null;
    });
  }

  Widget _buildBottleInputField(String label,
      TextEditingController controller) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 16),
          ),
        ),
        Container(
          width: 60,
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            maxLength: 1,
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              contentPadding:
              EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Fetch current stock quantities
        final stock = await _getStock(_driverId!);
        final int currentLpg = stock['lpgQuantity'];
        final int currentButane = stock['butaneQuantity'];
        final int currentPropane = stock['propaneQuantity'];

        // Get input values
        final int enteredLpg = int.parse(_lpgController.text);
        final int enteredButane = int.parse(_butaneController.text);
        final int enteredPropane = int.parse(_propaneController.text);

        // Calculate new stock values
        final int newLpg = currentLpg - enteredLpg;
        final int newButane = currentButane - enteredButane;
        final int newPropane = currentPropane - enteredPropane;

        if (enteredLpg > currentLpg || enteredButane > currentButane || enteredPropane > currentPropane) {
          // Build error message content
          String errorMessage = 'Entered quantities exceed the available stock for:';
          if (enteredLpg > currentLpg) errorMessage += '\n- LPG: Available stock: $currentLpg';
          if (enteredButane > currentButane) errorMessage += '\n- Butane: Available stock: $currentButane';
          if (enteredPropane > currentPropane) errorMessage += '\n- Propane: Available stock: $currentPropane';

          // Show the error message
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Oops! Out of Stock'),
                content: Text(errorMessage),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
          return;
        }

        // Update the stock quantities
        await _updateStock(_driverId!, newLpg, newButane, newPropane);

        // Proceed with order submission if stock update is successful
        // Fetch gas prices based on driver ID
        final gasUrl = Uri.parse('http://192.168.1.8:8080/api/gas/$_driverId');
        final gasResponse = await http.get(gasUrl);

        if (gasResponse.statusCode == 200) {
          // Parse the gas prices from the response
          final gasData = json.decode(gasResponse.body);
          final double lpgPrice = gasData['lpgPrice'];
          final double propanePrice = gasData['propanePrice'];
          final double butanePrice = gasData['butanePrice'];

          // Calculate total prices
          final double totalLpgPrice = enteredLpg * lpgPrice;
          final double totalPropanePrice = enteredPropane * propanePrice;
          final double totalButanePrice = enteredButane * butanePrice;

          // Calculate total price
          final double totalPrice = totalLpgPrice + totalPropanePrice + totalButanePrice;

          // Show total prices
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Total Prices'),
                content: Text('Total Price: \$${totalPrice.toStringAsFixed(2)}'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _submitOrder(totalPrice); // Proceed with submitting the form
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Form submitted successfully')),
                      ); // Show success message
                      // Clear the image file after form submission
                      _removeImage();
                    },
                    child: Text('Submit'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                ],
              );
            },
          );
        } else {
          print('Failed to fetch gas prices: ${gasResponse.reasonPhrase}');
        }
      } catch (error) {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error')));
      }
    }
  }


  Future<void> _submitOrder(double totalPrice) async {
    // Continue with submitting the form
    final url = Uri.parse('http://192.168.1.8:8080/api/order/create');
    var request = http.MultipartRequest('POST', url);
    var orderForm = {
      'name': _nameController.text,
      'consumerNumber': _consumerNumberController.text,
      'contactNumber': _contactNumberController.text,
      'email': _emailController.text,
      'address': _addressController.text,
      'lpgQuantity': _lpgController.text,
      'propaneQuantity': _propaneController.text,
      'butaneQuantity': _butaneController.text,
      'totalPrice': totalPrice.toStringAsFixed(2),
      // Add total price to orderForm
      'driver': {
        'id': _driverId,
      }
    };
    request.fields['orderForm'] = json.encode(orderForm);
    if (_imageFile != null) {
      String fileName = _imageFile!
          .path
          .split('/')
          .last;
      request.files.add(await http.MultipartFile.fromPath(
        'document',
        _imageFile!.path,
        filename: fileName,
      ));
    }
    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode == 200) {
      print('Order placed successfully!');
      // Clear all text field controllers
      _nameController.clear();
      _consumerNumberController.clear();
      _contactNumberController.clear();
      _emailController.clear();
      _addressController.clear();
      _lpgController.clear();
      _propaneController.clear();
      _butaneController.clear();
      _imageFile = null; // Clear the image file
    } else {
      print('Failed to place order: ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_driverId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Delivery Form'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Recipient Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                  maxLength: 20, // Maximum length of 50 characters
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _consumerNumberController,
                  decoration: InputDecoration(
                    labelText: 'Consumer Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a consumer number';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  // Numeric keyboard
                  maxLength: 10, // Maximum length of 10 digits
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _contactNumberController,
                  decoration: InputDecoration(
                    labelText: 'Contact Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a contact number';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  // Numeric keyboard
                  maxLength: 10, // Maximum length of 10 digits
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Text('Document'),
                    SizedBox(width: 8),
                    Expanded(
                      child: _imageFile == null
                          ? ElevatedButton(
                        onPressed: _pickImage,
                        child: Text('Upload'),
                        style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.all(Colors.cyan),
                          foregroundColor:
                          MaterialStateProperty.all(Colors.white),
                        ),
                      )
                          : Row(
                        children: [
                          Expanded(child: Image.file(_imageFile!)),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _removeImage,
                            child: Icon(Icons.close),
                            style: ButtonStyle(
                              backgroundColor:
                              MaterialStateProperty.all(Colors.red),
                              foregroundColor:
                              MaterialStateProperty.all(Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      _buildBottleInputField('LPG', _lpgController),
                      SizedBox(height: 16),
                      _buildBottleInputField('Propane', _propaneController),
                      SizedBox(height: 16),
                      _buildBottleInputField('Butane', _butaneController),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        child: Text(
                          'Submit',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.all(Colors.cyan),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

