import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/donacion_service.dart';

class DonacionesPage extends StatefulWidget {
  final String token;

  const DonacionesPage({super.key, required this.token});

  @override
  State<DonacionesPage> createState() => _DonacionesPageState();
}

class _DonacionesPageState extends State<DonacionesPage> {
  List<Map<String, dynamic>> _donaciones = [];
  List<Map<String, dynamic>> _filtradas = [];
  bool _isLoading = true;

  // Estadísticas
  double _totalRecibido = 0;
  double _promedio = 0;
  int _totalDonaciones = 0;
  int _anonimas = 0;

  // Resumen del mes
  double _totalMesActual = 0;
  double _totalMesAnterior = 0;

  // Filtros
  String _busqueda = '';
  String? _mesFiltro;
  final _searchCtrl = TextEditingController();

  final List<String> _meses = [
    'Todos los meses',
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchCtrl.addListener(() {
      setState(() {
        _busqueda = _searchCtrl.text.toLowerCase();
        _aplicarFiltros();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Convierte monto de forma segura sin importar si viene como String o num
  double _parseMonto(dynamic raw) {
    if (raw == null) return 0.0;
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw.toString()) ?? 0.0;
  }

  Future<void> _loadData() async {
    final data = await DonacionService.getDonaciones();

    final ahora = DateTime.now();
    final mesActual = ahora.month;
    final anioActual = ahora.year;
    final mesAnterior = mesActual == 1 ? 12 : mesActual - 1;
    final anioAnterior = mesActual == 1 ? anioActual - 1 : anioActual;

    double totalMA = 0;
    double totalMant = 0;

    for (final d in data) {
      final monto = _parseMonto(d['monto']);
      final fechaStr = d['fecha_donacion'] ?? d['created_at'] ?? '';
      if (fechaStr.isNotEmpty) {
        try {
          final fecha = DateTime.parse(fechaStr);
          if (fecha.month == mesActual && fecha.year == anioActual) totalMA += monto;
          if (fecha.month == mesAnterior && fecha.year == anioAnterior) totalMant += monto;
        } catch (_) {}
      }
    }

    final total = data.fold<double>(0, (s, d) => s + _parseMonto(d['monto']));

    setState(() {
      _donaciones = data;
      _filtradas = data;
      _totalRecibido = total;
      _totalDonaciones = data.length;
      _anonimas = data.where((d) => d['anonimo'] == true).length;
      _promedio = data.isNotEmpty ? total / data.length : 0;
      _totalMesActual = totalMA;
      _totalMesAnterior = totalMant;
      _isLoading = false;
    });
  }

  void _aplicarFiltros() {
    setState(() {
      _filtradas = _donaciones.where((d) {
        final nombre = (d['anonimo'] == true)
            ? 'anonimo'
            : (d['nombre_donante'] ?? '').toString().toLowerCase();
        final pasaBusqueda = _busqueda.isEmpty || nombre.contains(_busqueda);

        bool pasaMes = true;
        if (_mesFiltro != null && _mesFiltro != 'Todos los meses') {
          final fechaStr = d['fecha_donacion'] ?? d['created_at'] ?? '';
          if (fechaStr.isNotEmpty) {
            try {
              final fecha = DateTime.parse(fechaStr);
              final idxMes = _meses.indexOf(_mesFiltro!);
              pasaMes = fecha.month == idxMes;
            } catch (_) {
              pasaMes = false;
            }
          } else {
            pasaMes = false;
          }
        }

        return pasaBusqueda && pasaMes;
      }).toList();
    });
  }

  String _formatMonto(dynamic monto) {
    final val = _parseMonto(monto); // ← usa el helper seguro
    final formatted = val.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return '\$$formatted';
  }

  String _formatFecha(dynamic fechaStr) {
    if (fechaStr == null || fechaStr.toString().isEmpty) return '';
    try {
      final f = DateTime.parse(fechaStr.toString());
      return '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}';
    } catch (_) {
      return fechaStr.toString();
    }
  }

  double _crecimiento() {
    if (_totalMesAnterior == 0) return 0;
    return ((_totalMesActual - _totalMesAnterior) / _totalMesAnterior) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      body: Column(
        children: [
          _buildHeader(context),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  child: Column(
                    children: [
                      _buildStatCards(),
                      const SizedBox(height: 16),
                      _buildSearchFilter(),
                      const SizedBox(height: 16),
                      _buildDonacionesList(),
                      const SizedBox(height: 16),
                      _buildResumenMes(),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── HEADER ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00C9A7), Color(0xFF007BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                label: Text(
                  'Volver',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                ),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
              ),
              Text(
                'Gestión de Donaciones',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Administra las donaciones recibidas',
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── STAT CARDS ─────────────────────────────────────────────────────────────
  Widget _buildStatCards() {
    return Column(
      children: [
        Row(
          children: [
            _StatCard(
              value: _formatMonto(_totalRecibido),
              label: 'Total Recibido',
              icon: Icons.attach_money,
              isAccent: true,
            ),
            const SizedBox(width: 12),
            _StatCard(
              value: _formatMonto(_promedio),
              label: 'Promedio de donaciones',
              icon: Icons.show_chart,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _StatCard(
              value: '$_totalDonaciones',
              label: 'Donaciones totales',
              icon: Icons.calendar_today_outlined,
            ),
            const SizedBox(width: 12),
            _StatCard(
              value: '$_anonimas',
              label: 'Anónimas',
              icon: Icons.person_outline,
            ),
          ],
        ),
      ],
    );
  }

  // ── SEARCH + FILTER ────────────────────────────────────────────────────────
  Widget _buildSearchFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Buscar
          Row(
            children: [
              const Icon(Icons.search, size: 18, color: Color(0xFF6B7280)),
              const SizedBox(width: 8),
              Text(
                'Buscar',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF374151)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _searchCtrl,
            style: GoogleFonts.inter(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Nombre del donante',
              hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 13),
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Filtrar por mes
          Row(
            children: [
              const Icon(Icons.filter_list, size: 18, color: Color(0xFF6B7280)),
              const SizedBox(width: 8),
              Text(
                'Filtrar por mes',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF374151)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _mesFiltro ?? 'Todos los meses',
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: Color(0xFF6B7280)),
                style: GoogleFonts.inter(fontSize: 13, color: Colors.black87),
                items: _meses
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (val) {
                  setState(() => _mesFiltro = val);
                  _aplicarFiltros();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── LISTA DONACIONES ───────────────────────────────────────────────────────
  Widget _buildDonacionesList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Últimas Donaciones',
            style: GoogleFonts.inter(
                fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937)),
          ),
          const SizedBox(height: 12),
          if (_filtradas.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.volunteer_activism_outlined,
                        size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 8),
                    Text(
                      'No hay donaciones para mostrar',
                      style: GoogleFonts.inter(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else
            ...List.generate(_filtradas.length, (i) {
              final d = _filtradas[i];
              return Column(
                children: [
                  _DonacionItem(
                    donacion: d,
                    formatMonto: _formatMonto,
                    formatFecha: _formatFecha,
                  ),
                  if (i < _filtradas.length - 1)
                    const Divider(height: 1, color: Color(0xFFF3F4F6)),
                ],
              );
            }),
        ],
      ),
    );
  }

  // ── RESUMEN DEL MES ────────────────────────────────────────────────────────
  Widget _buildResumenMes() {
    final crecimiento = _crecimiento();
    final crece = crecimiento >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up,
                  color: crece ? const Color(0xFF00C9A7) : Colors.red,
                  size: 20),
              const SizedBox(width: 8),
              Text(
                'Resumen del Mes',
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ResumenCol(titulo: 'Este mes', valor: _formatMonto(_totalMesActual)),
              _ResumenCol(titulo: 'Mes anterior', valor: _formatMonto(_totalMesAnterior)),
              _ResumenCol(
                titulo: 'Crecimiento',
                valor: '${crece ? '+' : ''}${crecimiento.toStringAsFixed(0)}%',
                valorColor: crece ? const Color(0xFF00C9A7) : Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final bool isAccent;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    this.isAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isAccent ? const Color(0xFF22C55E) : Colors.white;
    final textColor = isAccent ? Colors.white : const Color(0xFF1F2937);
    final subColor = isAccent ? Colors.white70 : const Color(0xFF6B7280);
    final iconColor = isAccent ? Colors.white : const Color(0xFF007BFF);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 11, color: subColor),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Donación Item ─────────────────────────────────────────────────────────────
class _DonacionItem extends StatelessWidget {
  final Map<String, dynamic> donacion;
  final String Function(dynamic) formatMonto;
  final String Function(dynamic) formatFecha;

  const _DonacionItem({
    required this.donacion,
    required this.formatMonto,
    required this.formatFecha,
  });

  @override
  Widget build(BuildContext context) {
    final esAnonimo = donacion['anonimo'] == true;
    final nombre = esAnonimo
        ? 'Anónimo'
        : (donacion['nombre_donante'] ?? 'Sin nombre').toString();
    final metodo = (donacion['metodo_pago'] ?? '').toString();
    final fecha = formatFecha(donacion['fecha_donacion'] ?? donacion['created_at']);
    final monto = formatMonto(donacion['monto']);
    final observaciones = (donacion['observaciones'] ?? donacion['mensaje'] ?? '').toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: esAnonimo
                ? const Color(0xFFE5E7EB)
                : const Color(0xFFDBEAFE),
            child: Icon(
              esAnonimo ? Icons.person_outline : Icons.person,
              color: esAnonimo ? Colors.grey : const Color(0xFF3B82F6),
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      nombre,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        monto,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Fecha y método de pago
                Row(
                  children: [
                    if (fecha.isNotEmpty) ...[
                      const Icon(Icons.calendar_today_outlined,
                          size: 12, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 4),
                      Text(
                        fecha,
                        style: GoogleFonts.inter(
                            fontSize: 11, color: const Color(0xFF9CA3AF)),
                      ),
                      const SizedBox(width: 10),
                    ],
                    if (metodo.isNotEmpty) ...[
                      const Icon(Icons.credit_card_outlined,
                          size: 12, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 4),
                      Text(
                        metodo,
                        style: GoogleFonts.inter(
                            fontSize: 11, color: const Color(0xFF9CA3AF)),
                      ),
                    ],
                  ],
                ),
                // Comentario / observaciones
                if (observaciones.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '"$observaciones"',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Resumen columna ───────────────────────────────────────────────────────────
class _ResumenCol extends StatelessWidget {
  final String titulo;
  final String valor;
  final Color? valorColor;

  const _ResumenCol({required this.titulo, required this.valor, this.valorColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          titulo,
          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280)),
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: valorColor ?? const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }
}