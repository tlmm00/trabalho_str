import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
      title: 'RT Scheduler',
      theme: ThemeData(
        primarySwatch: Colors.indigo, 
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey.shade100,
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
  final List<ProcessCard> cardList = [];
  int _idCounter = 0;
  final List<bool> _selectedMethods = [true, false]; 
  int _selectedMethodId = 0;

  @override
  void initState() {
    super.initState();
    _addProcess(); 
  }

  void _addProcess() {
    setState(() {
      cardList.add(ProcessCard(key: UniqueKey(), processId: _idCounter));
      _idCounter++;
    });
  }

  void _removeProcess(Key key) {
    setState(() {
      cardList.removeWhere((card) => card.key == key);
    });
  }

  int gcd(int a, int b) => b == 0 ? a : gcd(b, a % b);
  int lcm(int a, int b) => (a * b) ~/ gcd(a, b);

  int calculateHyperperiod(List<Process> processes) {
    if (processes.isEmpty) return 0;
    int res = processes[0].period;
    for (int i = 1; i < processes.length; i++) {
      res = lcm(res, processes[i].period);
    }
    return res > 100 ? 100 : res; 
  }

  void _runSimulation() {
    if (cardList.isEmpty) return;

    final List<Process> processes = cardList.map((card) => Process(
      id: card.processId, 
      offset: card.getOffset(),
      computationTime: card.getComputation(),
      period: card.getPeriod(),
    )).toList();

    int simulationTime = calculateHyperperiod(processes);
    
    double theoreticalUtil = 0;
    for (var p in processes) {
      theoreticalUtil += (p.computationTime / p.period);
    }

    // Agora recebemos um Objeto de Resultado (SimulationResult)
    SimulationResult result;
    if (_selectedMethodId == 0) {
      result = edf(processes, simulationTime);
    } else {
      result = rm(processes, simulationTime);
    }

    // Cálculo Real
    int busyTicks = 0;
    for (int t = 0; t < simulationTime; t++) {
      bool isBusy = false;
      for (var key in result.matrix.keys) {
        if (key != -1 && result.matrix[key]!.length > t && result.matrix[key]![t] == 1) {
          isBusy = true; 
          break;
        }
      }
      if (isBusy) busyTicks++;
    }
    
    double realUtil = simulationTime > 0 ? busyTicks / simulationTime : 0;
    
    // Agora verificamos result.totalMisses que vem da simulação real
    bool isSchedulable = theoreticalUtil <= 1.0 && result.totalMisses == 0;
    
    _showResults(result.matrix, processes, theoreticalUtil, realUtil, isSchedulable, simulationTime, result.totalMisses);
  }

  void _showResults(
    Map<int, List<int>> matrix, 
    List<Process> processes, 
    double theoryU, 
    double realU, 
    bool feasible,
    int duration,
    int misses
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.bar_chart),
            const SizedBox(width: 10),
            Text("${_selectedMethodId == 0 ? 'EDF' : 'RM'} (LCM: $duration)"),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: feasible ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: feasible ? Colors.green : Colors.red),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat("Teórico (U)", "${(theoryU * 100).toStringAsFixed(1)}%"),
                    _buildStat("Real (U)", "${(realU * 100).toStringAsFixed(1)}%"),
                    Column(
                      children: [
                        Text(
                          feasible ? "SUCESSO" : "FALHA",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: feasible ? Colors.green : Colors.red
                          ),
                        ),
                        if (misses > 0)
                          Text("$misses Deadline Misses!", style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold))
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 50),
                          ...List.generate(duration, (i) => Container(
                            width: 30, 
                            alignment: Alignment.center,
                            child: Text("$i", style: const TextStyle(fontSize: 10)),
                          ))
                        ],
                      ),
                      const Divider(),
                      ...processes.map((p) => _buildGanttRow(p.id, matrix[p.id]!, duration)),
                      const Divider(),
                      _buildGanttRow(-1, matrix[-1]!, duration, isIdle: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("FECHAR")),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(children: [Text(label, style: const TextStyle(fontSize: 10)), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))]);
  }

  Widget _buildGanttRow(int pid, List<int> timeline, int duration, {bool isIdle = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Container(
            width: 50,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 8),
            child: Text(isIdle ? "IDLE" : "P$pid", style: TextStyle(fontWeight: FontWeight.bold, color: isIdle ? Colors.grey : Colors.indigo)),
          ),
          ...List.generate(duration, (t) {
            int val = (t < timeline.length) ? timeline[t] : 0;
            return Container(
              width: 30, height: 20,
              margin: const EdgeInsets.symmetric(horizontal: 1), 
              decoration: BoxDecoration(
                color: val == 1 
                  ? (isIdle ? Colors.grey.shade400 : Colors.indigo) 
                  : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          })
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Simulador Tempo Real"), elevation: 2),
      body: Column(
        children: [
          const SizedBox(height: 10),
          ToggleButtons(
            isSelected: _selectedMethods,
            borderRadius: BorderRadius.circular(30),
            fillColor: Colors.indigo,
            selectedColor: Colors.white,
            onPressed: (idx) => setState(() {
              for(int i=0; i<2; i++) _selectedMethods[i] = i == idx;
              _selectedMethodId = idx;
            }),
            children: const [
              Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Text("EDF")),
              Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Text("RM")),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: cardList.length,
              itemBuilder: (context, index) {
                final card = cardList[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: card),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeProcess(card.key!),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _runSimulation,
        label: const Text("SIMULAR"),
        icon: const Icon(Icons.play_arrow),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: BottomAppBar(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text("Adicionar Tarefa ", style: TextStyle(color: Colors.indigo.shade900, fontWeight: FontWeight.bold)),
            IconButton(
              onPressed: _addProcess, 
              icon: const Icon(Icons.add_circle, size: 32, color: Colors.indigo)
            )
          ],
        ),
      ),
    );
  }
}