class Process {
  int id;
  int period;           // T
  int computationTime;  // C
  int offset;           // O
  
  // Variáveis de estado dinâmico
  int remainingTime;
  int absoluteDeadline; 
  int nextArrival;      
  
  // Diagnóstico
  int deadlineMisses = 0; 

  Process({
    required this.id,
    required this.offset,
    required this.computationTime,
    required this.period,
  }) : remainingTime = computationTime, 
       nextArrival = offset,
       absoluteDeadline = offset + period;

  bool checkArrival(int currentTime) {
    if (currentTime == nextArrival) {
      // Se a tarefa anterior não terminou, conta como erro
      if (currentTime > 0 && remainingTime > 0) {
        deadlineMisses++; 
      }

      if (currentTime >= offset) {
        remainingTime = computationTime;
        absoluteDeadline = currentTime + period;
      }
      
      nextArrival += period; 
      return true;
    }
    return false;
  }

  void execute([int quantum = 1]) {
    if (remainingTime > 0) {
      remainingTime -= quantum;
    }
  }

  bool get isFinished => remainingTime <= 0;

  Process copy() {
    return Process(
      id: this.id,
      offset: this.offset,
      computationTime: this.computationTime,
      period: this.period,
    );
  }
}

/// Classe auxiliar para retornar a Matriz + Erros
class SimulationResult {
  final Map<int, List<int>> matrix;
  final int totalMisses;

  SimulationResult(this.matrix, this.totalMisses);
}