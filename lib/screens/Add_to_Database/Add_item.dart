import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddtoDatabase extends StatelessWidget {
  const AddtoDatabase({super.key});

  Future<void> add() async {
    await FirebaseFirestore.instance.collection('Tryon').add({});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ElevatedButton(
        onPressed: () {
          add();
        },
        child: Text('Add'),
      ),
    );
  }
}
