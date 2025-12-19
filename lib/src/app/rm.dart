import '../model/process.dart';

SimulationResult rm(List<Process> tasks, int maxTime) {
  // Deep copy para isolamento: Não queremos alterar o estado da view
  List<Process> workList = tasks.map((t) => t.copy()).toList();
  
  // Matriz esparsa: [ProcessID] -> [TimeSlot 0..N]
  // ID -1 representa o processador ocioso (IDLE)
  Map<int, List<int>> executionMatrix = {
    for (var t in tasks) t.id: [],
    -1: [] 
  };

  // RM Policy (Rate Monotonic):
  // Prioridade Estática inversamente proporcional ao período.
  // Menor T = Maior Prioridade. O sort acontece UMA vez antes do loop.
  workList.sort((a, b) => a.period.compareTo(b.period));

  // Time-Triggered Simulation Loop
  for (int time = 0; time < maxTime; time++) {
    
    // 1. Fase de Chegada (Arrival Check)
    // Verifica quais tarefas "nasceram" ou "renovaram" neste tick
    for (var p in workList) {
      p.checkArrival(time); 
    }

    // 2. Filtro da Ready Queue
    // Candidatos: Tarefas que já passaram do offset E têm saldo de execução
    List<Process> readyQueue = workList.where((p) => 
      time >= p.offset && !p.isFinished
    ).toList();

    // 3. Dispatcher
    if (readyQueue.isEmpty) {
      // Nenhuma tarefa pronta -> CPU IDLE
      executionMatrix.forEach((key, list) => list.add(key == -1 ? 1 : 0));
    } else {
      // Preempção implícita:
      // Como a lista já está ordenada por RM, pegamos sempre o first.
      // Se uma tarefa de menor período chegar, ela estará no topo na próxima iteração.
      Process current = readyQueue.first; 
      current.execute();

      // Loga execução na matriz (1 para quem rodou, 0 para os outros)
      executionMatrix.forEach((key, list) {
        list.add(key == current.id ? 1 : 0);
      });
    }
  }

  // Consolidação de erros: Soma os misses detectados nas instâncias copiadas
  int misses = workList.fold(0, (sum, p) => sum + p.deadlineMisses);

  return SimulationResult(executionMatrix, misses);
}