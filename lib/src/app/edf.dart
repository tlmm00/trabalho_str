import '../model/process.dart';

SimulationResult edf(List<Process> tasks, int maxTime) {
  List<Process> workList = tasks.map((t) => t.copy()).toList();
  
  Map<int, List<int>> executionMatrix = {
    for (var t in tasks) t.id: [],
    -1: [] 
  };

  // Loop tick-a-tick
  for (int time = 0; time < maxTime; time++) {
    
    // 1. Update de estado das tarefas (reset de C se T estourou)
    for (var p in workList) {
      p.checkArrival(time);
    }

    // 2. Construção da Ready Queue
    List<Process> readyQueue = workList.where((p) => 
      time >= p.offset && !p.isFinished
    ).toList();

    // 3. Scheduler EDF (Dynamic Priority):
    // Reordena a fila a cada tick baseado no Deadline Absoluto (d).
    // Quem está mais perto de explodir o prazo ganha a CPU.
    readyQueue.sort((a, b) {
      int cmp = a.absoluteDeadline.compareTo(b.absoluteDeadline);
      
      // Estabilidade: Se deadlines são iguais, usamos ID fixo para evitar 
      // "context switch" desnecessário (ping-pong entre tarefas)
      if (cmp != 0) return cmp;
      return a.id.compareTo(b.id);
    });

    // 4. Context Switch
    if (readyQueue.isEmpty) {
      executionMatrix.forEach((k, v) => v.add(k == -1 ? 1 : 0));
    } else {
      Process current = readyQueue.first;
      current.execute();
      executionMatrix.forEach((k, v) => v.add(k == current.id ? 1 : 0));
    }
  }

  int misses = workList.fold(0, (sum, p) => sum + p.deadlineMisses);
  return SimulationResult(executionMatrix, misses);
}