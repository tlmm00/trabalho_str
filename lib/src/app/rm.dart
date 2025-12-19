import '../model/process.dart';

SimulationResult rm(List<Process> tasks, int maxTime) {
  List<Process> workList = tasks.map((t) => t.copy()).toList();
  
  Map<int, List<int>> executionMatrix = {
    for (var t in tasks) t.id: [],
    -1: [] 
  };

  // RM: Ordena por Menor Período
  workList.sort((a, b) => a.period.compareTo(b.period));

  for (int time = 0; time < maxTime; time++) {
    // 1. Verificar Chegadas
    for (var p in workList) {
      p.checkArrival(time); 
    }

    // 2. Fila de Prontos
    List<Process> readyQueue = workList.where((p) => 
      time >= p.offset && !p.isFinished
    ).toList();

    // 3. Execução
    if (readyQueue.isEmpty) {
      executionMatrix.forEach((key, list) => list.add(key == -1 ? 1 : 0));
    } else {
      Process current = readyQueue.first; 
      current.execute();

      executionMatrix.forEach((key, list) {
        list.add(key == current.id ? 1 : 0);
      });
    }
  }

  // Soma os erros encontrados nas cópias de trabalho
  int misses = workList.fold(0, (sum, p) => sum + p.deadlineMisses);

  return SimulationResult(executionMatrix, misses);
}