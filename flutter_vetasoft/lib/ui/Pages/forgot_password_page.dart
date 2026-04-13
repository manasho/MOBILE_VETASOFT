import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';

/// ──────────────────────────────────────────────
///  FLUJO DE RECUPERACIÓN DE CONTRASEÑA  (3 pasos)
///  Paso 1 → Ingresar correo electrónico
///  Paso 2 → Ingresar código OTP (6 dígitos)
///  Paso 3 → Establecer nueva contraseña
/// ──────────────────────────────────────────────
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with TickerProviderStateMixin {
  // ── Paso actual ──
  int _step = 0; // 0: correo | 1: OTP | 2: nueva contraseña

  // ── Controladores ──
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _confirmPassCtrl = TextEditingController();
  final List<TextEditingController> _otpCtrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocus = List.generate(6, (_) => FocusNode());

  // ── Estado ──
  bool _isLoading = false;
  bool _showPass = false;
  bool _showConfirm = false;
  String _correoGuardado = '';

  // ── Animación ──
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    for (final c in _otpCtrls) c.dispose();
    for (final f in _otpFocus) f.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  //  NAVEGAR AL PASO SIGUIENTE (con animación)
  // ─────────────────────────────────────────────
  void _animateToStep(int step) async {
    await _slideCtrl.reverse();
    setState(() => _step = step);
    _slideCtrl.forward();
  }

  // ─────────────────────────────────────────────
  //  PASO 1 → enviar correo
  // ─────────────────────────────────────────────
  Future<void> _enviarCodigo() async {
    final correo = _emailCtrl.text.trim();
    if (correo.isEmpty || !correo.contains('@')) {
      _showSnack('Ingresa un correo válido', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    final res = await AuthService.solicitarRecuperacion(correo: correo);
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      _correoGuardado = correo;
      _showSnack('✅ Código enviado a $correo');
      _animateToStep(1);
    } else {
      _showSnack(res['message'] ?? 'Error al enviar código', isError: true);
    }
  }

  // ─────────────────────────────────────────────
  //  PASO 2 → verificar OTP
  // ─────────────────────────────────────────────
  Future<void> _verificarCodigo() async {
    final codigo = _otpCtrls.map((c) => c.text).join();
    if (codigo.length < 6) {
      _showSnack('Ingresa los 6 dígitos del código', isError: true);
      return;
    }
    // Validación local: pasamos el código al paso 3
    // (la validación real ocurre en el paso 3 junto con la nueva contraseña)
    _animateToStep(2);
  }

  // ─────────────────────────────────────────────
  //  PASO 3 → resetear contraseña
  // ─────────────────────────────────────────────
  Future<void> _resetearContrasena() async {
    final pass = _passCtrl.text.trim();
    final confirm = _confirmPassCtrl.text.trim();
    final codigo = _otpCtrls.map((c) => c.text).join();

    if (pass.isEmpty || pass.length < 6) {
      _showSnack('La contraseña debe tener al menos 6 caracteres', isError: true);
      return;
    }
    if (pass != confirm) {
      _showSnack('Las contraseñas no coinciden', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    final res = await AuthService.resetearContrasena(
      correo: _correoGuardado,
      codigo: codigo,
      nuevaContrasena: pass,
    );
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      _showSnack('✅ Contraseña actualizada. Inicia sesión.');
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pop(context);
    } else {
      _showSnack(res['message'] ?? 'Error al restablecer', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? const Color(0xFFD94040) : const Color(0xFF5A8DEE),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1A28),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStepIndicator(),
            Expanded(
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  child: _buildCurrentStep(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HEADER ──
  Widget _buildHeader() {
    final titles = [
      'Recuperar contraseña',
      'Verificar código',
      'Nueva contraseña',
    ];
    final subtitles = [
      'Ingresa tu correo y te enviaremos un código de verificación',
      'Revisa tu correo e ingresa el código de 6 dígitos',
      'Elige una nueva contraseña segura',
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2F2C3A), Color(0xFF1C1A28)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botón volver
          GestureDetector(
            onTap: () {
              if (_step == 0) {
                Navigator.pop(context);
              } else {
                _animateToStep(_step - 1);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white70, size: 18),
            ),
          ),
          const SizedBox(height: 20),
          // Icono principal
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5A8DEE), Color(0xFF8E5AEF)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5A8DEE).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.lock_reset_rounded,
                color: Colors.white, size: 30),
          ),
          const SizedBox(height: 14),
          Text(
            titles[_step],
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitles[_step],
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  // ── INDICADOR DE PASOS ──
  Widget _buildStepIndicator() {
    return Container(
      color: const Color(0xFF1C1A28),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
      child: Row(
        children: List.generate(3, (i) {
          final isActive = i <= _step;
          final isCurrent = i == _step;
          return Expanded(
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isCurrent ? 32 : 24,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? const LinearGradient(
                            colors: [Color(0xFF5A8DEE), Color(0xFF8E5AEF)],
                          )
                        : null,
                    color: isActive ? null : Colors.white12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: i < _step
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 14)
                        : Text(
                            '${i + 1}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isActive ? Colors.white : Colors.white38,
                            ),
                          ),
                  ),
                ),
                if (i < 2)
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        gradient: i < _step
                            ? const LinearGradient(
                                colors: [Color(0xFF5A8DEE), Color(0xFF8E5AEF)],
                              )
                            : null,
                        color: i < _step ? null : Colors.white12,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── PASO ACTUAL ──
  Widget _buildCurrentStep() {
    switch (_step) {
      case 0:
        return _buildStepEmail();
      case 1:
        return _buildStepOtp();
      case 2:
        return _buildStepNewPassword();
      default:
        return const SizedBox();
    }
  }

  // ────────────────────────────────────────────
  //  PASO 1 — Correo electrónico
  // ────────────────────────────────────────────
  Widget _buildStepEmail() {
    return Column(
      children: [
        const SizedBox(height: 12),
        _inputLabel('Correo electrónico'),
        const SizedBox(height: 8),
        _styledTextField(
          controller: _emailCtrl,
          hint: 'ejemplo@correo.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 32),
        _primaryButton(
          label: 'Enviar código',
          onPressed: _enviarCodigo,
          icon: Icons.send_rounded,
        ),
        const SizedBox(height: 16),
        _secondaryButton(
          label: 'Volver al inicio de sesión',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────
  //  PASO 2 — Código OTP
  // ────────────────────────────────────────────
  Widget _buildStepOtp() {
    return Column(
      children: [
        const SizedBox(height: 12),
        // Resumen de correo
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF5A8DEE).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF5A8DEE).withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.email_rounded, color: Color(0xFF5A8DEE), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _correoGuardado,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF5A8DEE),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        _inputLabel('Código de verificación'),
        const SizedBox(height: 16),
        // Casillas OTP
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) => _otpBox(i)),
        ),
        const SizedBox(height: 10),
        // Reenviar código
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('¿No recibiste el correo?  ',
                style: GoogleFonts.inter(color: Colors.white38, fontSize: 13)),
            GestureDetector(
              onTap: _enviarCodigo,
              child: Text(
                'Reenviar',
                style: GoogleFonts.inter(
                  color: const Color(0xFF5A8DEE),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _primaryButton(
          label: 'Verificar código',
          onPressed: _verificarCodigo,
          icon: Icons.verified_outlined,
        ),
        const SizedBox(height: 16),
        _secondaryButton(
          label: 'Cambiar correo',
          onPressed: () => _animateToStep(0),
        ),
      ],
    );
  }

  Widget _otpBox(int index) {
    return SizedBox(
      width: 44,
      height: 54,
      child: TextField(
        controller: _otpCtrls[index],
        focusNode: _otpFocus[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white.withOpacity(0.07),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF5A8DEE), width: 2),
          ),
        ),
        onChanged: (val) {
          if (val.isNotEmpty && index < 5) {
            _otpFocus[index + 1].requestFocus();
          } else if (val.isEmpty && index > 0) {
            _otpFocus[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  // ────────────────────────────────────────────
  //  PASO 3 — Nueva contraseña
  // ────────────────────────────────────────────
  Widget _buildStepNewPassword() {
    return Column(
      children: [
        const SizedBox(height: 12),
        _inputLabel('Nueva contraseña'),
        const SizedBox(height: 8),
        _styledTextField(
          controller: _passCtrl,
          hint: '••••••••',
          icon: Icons.lock_outline_rounded,
          obscure: !_showPass,
          suffixIcon: IconButton(
            icon: Icon(
              _showPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: Colors.white38,
            ),
            onPressed: () => setState(() => _showPass = !_showPass),
          ),
        ),
        const SizedBox(height: 16),
        _inputLabel('Confirmar nueva contraseña'),
        const SizedBox(height: 8),
        _styledTextField(
          controller: _confirmPassCtrl,
          hint: '••••••••',
          icon: Icons.lock_outline_rounded,
          obscure: !_showConfirm,
          suffixIcon: IconButton(
            icon: Icon(
              _showConfirm
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.white38,
            ),
            onPressed: () => setState(() => _showConfirm = !_showConfirm),
          ),
        ),
        const SizedBox(height: 12),
        // Indicador de requisitos
        _reqRow('Al menos 6 caracteres'),
        const SizedBox(height: 32),
        _primaryButton(
          label: 'Cambiar contraseña',
          onPressed: _resetearContrasena,
          icon: Icons.check_circle_outline_rounded,
        ),
      ],
    );
  }

  Widget _reqRow(String text) {
    return Row(
      children: [
        const Icon(Icons.info_outline_rounded, color: Colors.white24, size: 14),
        const SizedBox(width: 6),
        Text(text,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white38)),
      ],
    );
  }

  // ────────────────────────────────────────────
  //  WIDGETS HELPER
  // ────────────────────────────────────────────

  Widget _inputLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget _styledTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: Colors.white24),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF5A8DEE), width: 1.8),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5A8DEE), Color(0xFF8E5AEF)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5A8DEE).withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : onPressed,
          icon: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(icon, size: 18),
          label: Text(
            _isLoading ? 'Procesando...' : label,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _secondaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: Colors.white38,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
