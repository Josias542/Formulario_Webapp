import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UserForm(),
    );
  }
}

class UserForm extends StatefulWidget {
  @override
  _UserFormState createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _idController = TextEditingController();

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    final response = await http.post(
      Uri.parse('https://us-central1-sistemapiscicola.cloudfunctions.net/usuarios'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "nombre": _nameController.text,
        "telefono": _phoneController.text,
        "email": _emailController.text,
        "password": _passwordController.text
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Usuario registrado: ${data['mensaje']}")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al registrar usuario")),
      );
    }
  }

  Future<void> _fetchUsers() async {
    final response = await http.get(
      Uri.parse('https://us-central1-sistemapiscicola.cloudfunctions.net/usuarios'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> users = jsonDecode(response.body);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Usuarios Registrados"),
            content: SingleChildScrollView(
              child: Column(
                children: users.map((user) {
                  return ListTile(
                    title: Text(user["nombre"]),
                    subtitle: Text(user["email"]),
                  );
                }).toList(),
              ),
            ),
          );
        },
      );
    }
  }

  Future<void> _fetchUserById() async {
    final String id = _idController.text.trim();
    if (id.isEmpty) return;

    final response = await http.get(
      Uri.parse('https://us-central1-sistemapiscicola.cloudfunctions.net/usuarios/$id'),
    );

    if (response.statusCode == 200) {
      final user = jsonDecode(response.body);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Usuario: ${user['nombre']}"),
            content: Text("Email: ${user['email']}\nTeléfono: ${user['telefono']}"),
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Usuario no encontrado")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registro de Usuario")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: "Nombre Completo"),
                    validator: (value) => value!.isEmpty ? "Campo requerido" : null,
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: "Email"),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        value!.contains("@") ? null : "Email inválido",
                  ),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(labelText: "Teléfono"),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value!.length == 10
                        ? null
                        : "Debe tener 10 dígitos",
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: "Contraseña"),
                    obscureText: true,
                    validator: (value) =>
                        value!.length >= 6 ? null : "Mínimo 6 caracteres",
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _registerUser,
                    child: Text("Registrar"),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchUsers,
              child: Text("Ver Usuarios"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: "ID de Usuario",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _fetchUserById,
              child: Text("Buscar Usuario por ID"),
            ),
          ],
        ),
      ),
    );
  }
}
