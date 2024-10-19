import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddVisit extends StatefulWidget {
  @override
  _AddVisitState createState() => _AddVisitState();
}

class _AddVisitState extends State<AddVisit> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String restaurant = 'Your Hardcoded Restaurant Name'; // Hardcoded restaurant
  DateTime? visitDate;
  TimeOfDay? visitTime;
  final List<Dish> dishes = [];
  final TextEditingController _dishController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  double? _rating; // Nullable rating

  Future<void> _saveVisit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await _firestore.collection('visits').add({
          'restaurant': restaurant,
          'date': visitDate,
          'time': visitTime,
          'dishes': dishes.map((d) => d.toMap()).toList(),
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Visit added successfully!')));
        Navigator.pop(context); // Navigate back after saving
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to add visit: $e')));
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: visitDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != visitDate) {
      setState(() {
        visitDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: visitTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != visitTime) {
      setState(() {
        visitTime = picked;
      });
    }
  }

  void _addDish() {
    if (_dishController.text.isNotEmpty && _rating != null) {
      setState(() {
        dishes.add(Dish(
            name: _dishController.text,
            rating: _rating!,
            review: _reviewController.text));
        _dishController.clear();
        _reviewController.clear();
        _rating = null; // Reset the rating after adding the dish
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Visit')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: restaurant,
                decoration: InputDecoration(labelText: 'Restaurant'),
                readOnly: true,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Date'),
                onTap: () => _selectDate(context),
                controller: TextEditingController(
                    text: visitDate != null
                        ? "${visitDate!.toLocal()}".split(' ')[0]
                        : ''),
                readOnly: true,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Time'),
                onTap: () => _selectTime(context),
                controller: TextEditingController(
                    text: visitTime != null ? visitTime!.format(context) : ''),
                readOnly: true,
              ),
              TextFormField(
                controller: _dishController,
                decoration: InputDecoration(labelText: 'Dish Name'),
              ),
              SizedBox(height: 30),
              Text(
                  'Rate the Dish: ${_rating != null ? _rating!.toStringAsFixed(1) : 'Not rated'}'),
              Slider(
                value: _rating ?? 0,
                min: 0,
                max: 5,
                divisions: 50, // This allows for half-point increments
                onChanged: (value) {
                  setState(() {
                    _rating = value;
                  });
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _reviewController,
                decoration: InputDecoration(labelText: 'Review'),
              ),
              SizedBox(height: 25),
              ElevatedButton(
                onPressed: _addDish,
                child: Text('Add Dish'),
              ),
              SizedBox(height: 10),
              Text('Dishes:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...dishes.map((dish) => ListTile(
                    title: Text(dish.name),
                    subtitle:
                        Text('Rating: ${dish.rating}, Review: ${dish.review}'),
                  )),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveVisit,
                child: Text('Save Visit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Dish {
  final String name;
  final double rating;
  final String review;

  Dish({required this.name, required this.rating, required this.review});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'rating': rating,
      'review': review,
    };
  }
}
