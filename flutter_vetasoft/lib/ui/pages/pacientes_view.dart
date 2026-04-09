import 'package:flutter/material.dart';
import 'package:flutter_vetasoft/models/pacientes_model.dart';
import 'package:flutter_vetasoft/services/service_paciente.dart';
import 'historial_medico_view.dart'; // Importa la vista de historial
// INICIO - IMPORTAR LA VISTA DE GESTIÓN DE CITAS (ELIMINAR DESPUÉS)

// FIN - IMPORTAR LA VISTA DE GESTIÓN DE CITAS

class PacientesView extends StatefulWidget {
  const PacientesView({super.key});

  @override
  State<PacientesView> createState() => _PacientesViewState();
}

class _PacientesViewState extends State<PacientesView> {
  List<Paciente> pacientes = [];
  List<Paciente> pacientesFiltrados = [];
  List<Map<String, dynamic>> especies = [];

  bool isLoading = true;
  String? errorMessage;

  final TextEditingController searchController = TextEditingController();
  String especieSeleccionada = 'Todas';

  @override
  void initState() {
    super.initState();
    _cargarDatos();
    searchController.addListener(_filtrarPacientes);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final pacientesData = await ApiServicePaciente.obtenerPacientes();
      final especiesData = await ApiServicePaciente.obtenerEspecies();

      setState(() {
        pacientes = pacientesData;
        pacientesFiltrados = pacientesData;
        especies = especiesData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  void _filtrarPacientes() {
    final busqueda = searchController.text.toLowerCase();

    setState(() {
      pacientesFiltrados = pacientes.where((p) {
        final cumpleBusqueda = busqueda.isEmpty ||
            p.nombre.toLowerCase().contains(busqueda) ||
            p.nombreRaza.toLowerCase().contains(busqueda) ||
            p.clienteNombre.toLowerCase().contains(busqueda);

        final cumpleEspecie = especieSeleccionada == 'Todas' ||
            (p.nombreEspecie).toLowerCase() ==
                especieSeleccionada.toLowerCase();

        return cumpleBusqueda && cumpleEspecie;
      }).toList();
    });
  }

  void _seleccionarEspecie(String? specie) {
    setState(() {
      especieSeleccionada = specie ?? 'Todas';
    });
    _filtrarPacientes();
  }

  List<String> _obtenerEspeciesUnicas() {
    final especiesSet = <String>{'Todas'};
    for (var p in pacientes) {
      if (p.nombreEspecie != null) {
        especiesSet.add(p.nombreEspecie);
      }
    }
    return especiesSet.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: isLoading
                ? _buildLoading()
                : errorMessage != null
                    ? _buildError()
                    : _buildLista(),
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF5D9CC5),
            Color(0xFF664492),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.arrow_back, color: Colors.white, size: 18),
              SizedBox(width: 6),
              Text(
                'Volver',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pacientes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Mascotas registradas',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // INICIO - BOTÓN TEMPORAL PARA GESTIÓN DE CITAS (ELIMINAR DESPUÉS)
                  GestureDetector(
                  //  onTap: () {
                    //  Navigator.push(
                     //   context,
                      //  MaterialPageRoute(
                        //  builder: (_) => const GestionCitasView(),
                      //  ),
                    //  );
                    //},
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.calendar_month, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Citas',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // FIN - BOTÓN TEMPORAL
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '+ Registrar',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color.fromARGB(255, 5, 5, 5),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= FILTROS =================

  Widget _buildFiltros() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: const [
                Icon(Icons.search, size: 18, color: Colors.grey),
                SizedBox(width: 6),
                Text('Buscar', style: TextStyle(fontSize: 14)),
              ],
            ),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Mascota o propietario',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: const [
                Icon(Icons.filter_list, size: 18, color: Colors.grey),
                SizedBox(width: 6),
                Text('Filtrar por especie',
                    style: TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: especieSeleccionada,
              items: _obtenerEspeciesUnicas().map((e) {
                return DropdownMenuItem(value: e, child: Text(e));
              }).toList(),
              onChanged: _seleccionarEspecie,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= LISTA =================

  Widget _buildLista() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildFiltros(),
          if (pacientesFiltrados.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Text('No hay pacientes'),
            ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pacientesFiltrados.length,
            itemBuilder: (context, index) {
              return _buildCard(pacientesFiltrados[index]);
            },
          ),
        ],
      ),
    );
  }

  // ================= CARD =================

  Widget _buildCard(Paciente p) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFF8E7CC3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.pets,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.nombre,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Text(p.nombreRaza),
                        const SizedBox(width: 6),
                        const Text('•'),
                        const SizedBox(width: 6),
                        const Text('•'),
                        const SizedBox(width: 6),
                        Text('${p.edad} años'),
                        const SizedBox(width: 6),
                        const Text('•'),
                        const SizedBox(width: 6),
                        const Text('•'),
                        const SizedBox(width: 6),
                        Text(p.sexo),
                      ],
                    ),
                    Text('Dueño: ${p.clienteNombre}'),
                    Text('Doc: ${p.clienteDocumento}'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF5D9CC5),
                        Color(0xFF664492),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Center(
                    child: Text('Editar',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                 onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => HistorialMedicoView(
        nombreMascota: p.nombre,
        animalId: p.animalId,
      ),
    ),
  );
},
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black26),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                      child: Text('Ver historial',
                          style: TextStyle(
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLoading() =>
      const Center(child: CircularProgressIndicator());

  Widget _buildError() {
    return Center(
      child: ElevatedButton(
        onPressed: _cargarDatos,
        child: const Text('Reintentar'),
      ),
    );
  }
}
