import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../ui/pages/veterinarioview/veterinarian_panel_page.dart';
import '../../ui/pages/forgot_password_page.dart';
import '../../ui/pages/pettview/pets_view.dart';

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
      showErrorDialog("Por favor, completa el correo y la contraseña.");
      return;
    }

    setState(() => isLoading = true);

    final result = await AuthService.login(correo: email, contrasena: password);

    setState(() => isLoading = false);

    
    if (result["success"]) {
      showSuccessSnack("Bienvenido 🔥");

      if (!mounted) return;

      // ✅ Navegación por rol  (3 = cliente, cualquier otro = veterinario/admin)
      final rolVal = int.tryParse(result["rol"].toString()) ?? 0;

      if (rolVal == 3) {
        // Cliente → ir a su panel de mascotas
        final clienteId = await AuthService.obtenerClienteId();
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PetsView(clienteId: clienteId ?? 0),
          ),
        );
      } else {
        // Veterinario / admin
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => VeterinarianPanelPage()),
        );
      }
    } else {
      showErrorDialog(result["message"] ?? "Credenciales inválidas");
    }
  }

  /// Alerta de error prominente (credenciales inválidas, conexión, etc.)
  void showErrorDialog(String msg) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF2F2C3A),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícono de error
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFD94040).withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: Color(0xFFD94040),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            // Título
            const Text(
              'Credenciales inválidas',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Mensaje del backend
            Text(
              msg,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            // Botón Aceptar
            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD94040), Color(0xFFB02020)],
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Intentar de nuevo',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// SnackBar de éxito (login correcto)
  void showSuccessSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(msg, style: const TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: const Color(0xFF5A8DEE),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFF2F2C3A)),
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
                  ClipOval(
                    child: Image.asset(
                      'assets/login_bg.jpg',
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.purple,
                        child: Icon(Icons.pets, color: Colors.white, size: 36),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Vetasoft',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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

                  /// RECORDARME
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

                  /// RECUPERAR CONTRASEÑA (separado, debajo)
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordPage(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                      child: const Text(
                        "¿Olvidaste tu contraseña?",
                        style: TextStyle(
                          color: Color(0xFF5A8DEE),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// BOTÓN LOGIN
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5A8DEE), Color(0xFF8E5AEF)],
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
                          ? const CircularProgressIndicator(color: Colors.white)
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
