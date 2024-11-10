import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
void openAccountBox(){
  showDialog(
    context: context , 
    builder : (context) => const AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           TextField(
        decoration: InputDecoration(
          labelText: "Name",
        )),
        TextField(
        decoration: InputDecoration(
          labelText: "Username",
        )),
        TextField(
        decoration: InputDecoration(
          labelText: "Password",
        )),
        ],
      )
    ));
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[50],
      appBar: AppBar( 
        title: const Center(
        child : Text("PassWord Manager" , 
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ))), 
        backgroundColor: Colors.amber[50]),
      
      
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber[100],
        onPressed: openAccountBox,
        child: const Icon( Icons.add),
      ),
    );
  }
}