class Process {
  int id;
  int period;           // T (Período)
  int computationTime;  // C (Custo computacional / WCET)
  int offset;           // O (Tempo de chegada inicial)
  
  // --- Estado Mutável da Simulação ---
  int remainingTime;    // Contador regressivo de execução
  int absoluteDeadline; // Instante absoluto onde a tarefa DEVE terminar (d = arrival + T)
  int nextArrival;      // Instante exato da próxima chegada (sem drift)
  
  // --- Métricas ---
  int deadlineMisses = 0; 

  Process({
    required this.id,
    required this.offset,
    required this.computationTime,
    required this.period,
  }) : remainingTime = computationTime, 
       nextArrival = offset,
       absoluteDeadline = offset + period;

  /// Core Logic: Gerencia o ciclo de vida da tarefa periódica.
  /// Retorna true se uma nova instância foi disparada (útil para logs).
  bool checkArrival(int currentTime) {
    // Checagem exata: Sistemas de tempo real são discretos neste simulador
    if (currentTime == nextArrival) {
      
      // Detecção de Falha:
      // Se chegou a hora da nova instância (t) e a anterior ainda tem 
      // trabalho a fazer (remainingTime > 0), houve violação temporal.
      // Nota: currentTime > 0 evita falso positivo no boot do sistema.
      if (currentTime > 0 && remainingTime > 0) {
        deadlineMisses++; 
      }

      // Spawn da nova instância:
      // Só reseta o contador se já passamos do offset inicial.
      if (currentTime >= offset) {
        remainingTime = computationTime; // Recarrega o WCET
        absoluteDeadline = currentTime + period; // Define novo teto temporal
      }
      
      // Agendamento Absoluto:
      // Calculamos o próximo arrival baseado no ATUAL + T.
      // Isso garante periodicidade estrita (sem acumular atrasos de execução).
      nextArrival += period; 
      return true;
    }
    return false;
  }

  /// Consome 1 tick de CPU
  void execute([int quantum = 1]) {
    if (remainingTime > 0) {
      remainingTime -= quantum;
    }
  }

  bool get isFinished => remainingTime <= 0;

  // Pattern Prototype: Essencial para simular sem sujar os objetos originais da UI
  Process copy() {
    return Process(
      id: this.id,
      offset: this.offset,
      computationTime: this.computationTime,
      period: this.period,
    );
  }
}

/// DTO para trafegar o resultado da simulação + metadados de erro
class SimulationResult {
  final Map<int, List<int>> matrix; // Gantt Data
  final int totalMisses;            // Hard Real-Time Constraint Violation count

  SimulationResult(this.matrix, this.totalMisses);
}