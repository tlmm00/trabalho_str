import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Importações dos modelos e lógica
import 'src/model/process.dart';
import 'src/app/edf.dart';
import 'src/app/rm.dart';
import 'card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Real-Time Scheduler',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const MyAppHome(),
    );
  }
}

class MyAppHome extends StatefulWidget {
  const MyAppHome({Key? key}) : super(key: key);

  @override
  State<MyAppHome> createState() => _MyAppHomeState();
}

class _MyAppHomeState extends State<MyAppHome> {
  // Lista de cards (UI)
  final List<ProcessCard> cardList = [];
  
  // Contador para garantir processId único mesmo após remoções
  int _idCounter = 0;

  // Estado do seletor: [0] EDF, [1] RM
  final List<bool> _selectedMethods = [true, false];
  int _selectedMethodId = 0;

  @override
  void initState() {
    super.initState();
    _addProcess(); // Inicia com um processo
  }

  /// Adiciona um novo processo garantindo o 'processId' obrigatório
  void _addProcess() {
    setState(() {
      cardList.add(ProcessCard(
        key: UniqueKey(),
        processId: _idCounter, // CORREÇÃO: Passando o parâmetro obrigatório
      ));
      _idCounter++;
    });
  }

  /// Remove um processo específico
  void _removeProcess(Key key) {
    setState(() {
      cardList.removeWhere((card) => card.key == key);
    });
  }

  /// Ponte entre a UI e os Algoritmos de Tempo Real
  Tuple3<List<Process>, Map<int, List<int>>, double> _runSimulation() {
    final List<Process> processes = [];
    
    for (int i = 0; i < cardList.length; i++) {
      final card = cardList[i];
      // O ID do processo para o escalonador será o processId do Card
      processes.add(Process(
        id: card.processId, 
        timeInit: card.getInitTime().toInt(),
        ttf: card.getTtf().toInt(),
        deadline: card.getDeadline().toInt(),
      ));
    }

    Map<int, List<int>> executionMatrix;

    // Executa conforme paradigma de Tempo Real
    if (_selectedMethodId == 0) {
      executionMatrix = edf(processes, 0, 0); 
    } else {
      executionMatrix = rm(processes); 
    }

    // Cálculo do tempo médio de execução (Turnaround Lógico)
    double totalTurnaround = 0;
    for (var p in processes) {
      final int lastTick = executionMatrix[p.id]?.lastIndexOf(1) ?? -1;
      final int endTime = (lastTick != -1) ? lastTick + 1 : 0;
      totalTurnaround += (endTime - p.timeInit);
    }
    
    final double avgTime = processes.isNotEmpty ? totalTurnaround / processes.length : 0;
    return Tuple3(processes, executionMatrix, avgTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Escalonador Real-Time (EDF / RM)"),
        centerTitle: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Seletor de Algoritmo
          Center(
            child: ToggleButtons(
              isSelected: _selectedMethods,
              borderRadius: BorderRadius.circular(10),
              selectedColor: Colors.white,
              fillColor: Colors.indigo,
              onPressed: (int index) {
                setState(() {
                  for (int i = 0; i < _selectedMethods.length; i++) {
                    _selectedMethods[i] = (i == index);
                  }
                  _selectedMethodId = index;
                });
              },
              children: const [
                Padding(padding: EdgeInsets.symmetric(horizontal: 32), child: Text("EDF")),
                Padding(padding: EdgeInsets.symmetric(horizontal: 32), child: Text("RM")),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: cardList.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(child: cardList[index]),
                      IconButton(
                        icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                        onPressed: () => _removeProcess(cardList[index].key!),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              FloatingActionButton(
                heroTag: "btn_add",
                mini: true,
                onPressed: _addProcess,
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: "btn_run",
            backgroundColor: Colors.green.shade700,
            onPressed: () {
              if (cardList.isEmpty) return;
              final result = _runSimulation();
              showGridViewDialog(context, result.item2, result.item1, result.item3);
            },
            label: const Text("SIMULAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            icon: const Icon(Icons.play_arrow, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void showGridViewDialog(BuildContext context, Map<int, List<int>> matrix, List<Process> processes, double avgTime) {
    int totalTicks = matrix.isNotEmpty ? matrix.values.first.length : 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Gantt: ${_selectedMethodId == 0 ? 'EDF' : 'RM'}"),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: totalTicks * 52.0,
                    child: GridView.builder(
                      shrinkWrap: true,
                      itemCount: (processes.length + 1) * totalTicks, 
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: totalTicks,
                      ),
                      itemBuilder: (context, index) {
                        int rowId = index ~/ totalTicks;
                        int colId = index % totalTicks;
                        
                        // ID -1 para linha de IDLE (conforme script Python)
                        int processKey = (rowId < processes.length) ? processes[rowId].id : -1;
                        int status = matrix[processKey]?[colId] ?? 0;

                        Color color = Colors.grey.shade100;
                        Widget content = Text("$colId", style: TextStyle(fontSize: 10, color: Colors.grey.shade400));

                        if (status == 1) {
                          color = processKey == -1 ? Colors.orangeAccent : Colors.indigoAccent;
                          content = Text(processKey == -1 ? "Zz" : "P$processKey", 
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold));
                        }

                        return Container(
                          margin: const EdgeInsets.all(1.5),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.black12, width: 0.5),
                          ),
                          child: Center(child: content),
                        ).animate().scale(delay: Duration(milliseconds: colId * 30), duration: 200.ms);
                      },
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text("O tempo avança em unidades discretas (ticks).", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
              ),
              Text("Média Turnaround: ${avgTime.toStringAsFixed(2)} ticks",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("FECHAR")),
        ],
      ),
    );
  }
}