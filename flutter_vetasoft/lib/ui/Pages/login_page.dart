import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool rememberMe = false;
  bool isLoading = false;

  void handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // 🔎 Validaciones
    if (email.isEmpty || password.isEmpty) {
      showMessage("Completa todos los campos");
      return;
    }

    setState(() => isLoading = true);

    final result = await AuthService.login(
      correo: email,
      contrasena: password,
    );

    setState(() => isLoading = false);

    if (result["success"]) {
      showMessage("Bienvenido 🔥");

      // 👉 Aquí luego navegamos
      // Navigator.pushReplacement(...)

    } else {
      showMessage(result["message"]);
    }
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF2F2C3A),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.purple,
                    child: CircleAvatar(
                      radius: 35,
                      backgroundImage: AssetImage(''),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Vetasoft',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Text(
                    'Bienvenido de vuelta',
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 20),

                  /// EMAIL
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Correo electrónico:"),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: "ejemplo@correo.com",
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// PASSWORD
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Contraseña:"),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "********",
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// RECORDAR + OLVIDAR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: rememberMe,
                            onChanged: (value) {
                              setState(() {
                                rememberMe = value!;
                              });
                            },
                          ),
                          const Text("Recordarme"),
                        ],
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text("¿Olvidaste tu contraseña?"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// BOTÓN LOGIN
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF5A8DEE),
                          Color(0xFF8E5AEF),
                        ],
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: isLoading ? null : handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text("Iniciar sesión"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}