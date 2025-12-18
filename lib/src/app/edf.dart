import '../model/process.dart';

/// Implementação do algoritmo EDF baseada no script Python fornecido.
Map<int, List<int>> edf(List<Process> tasks, num quantum, num overload) {
  // Cópia de trabalho para não afetar os objetos da UI
  List<Process> listTasks = tasks.map((t) => t.copy()).toList();
  List<Process> listDone = [];
  
  // Estrutura de retorno: ID do processo -> Linha do tempo (1 executando, 0 esperando)
  // O ID -1 é reservado para representar estados de Overload ou IDLE se necessário
  Map<int, List<int>> executionMatrix = {
    for (var t in tasks) t.id: [],
    -1: [] // Linha de controle/overload
  };

  int time = 0;
  // O loop roda até que todas as tarefas entrem na lista de concluídas (conforme Python)
  while (listDone.length < listTasks.length) {
    // Filtro: Tarefas que chegaram e não estão concluídas
    List<Process> activeTasks = listTasks.where((task) {
      bool isDone = listDone.any((d) => d.id == task.id);
      return !isDone && task.timeInit <= time;
    }).toList();

    // Ordenação: Earliest Deadline First
    activeTasks.sort((a, b) => a.deadline.compareTo(b.deadline));

    if (activeTasks.isEmpty) {
      // CPU IDLE: Avança o tempo em todas as trilhas
      for (var id in executionMatrix.keys) {
        executionMatrix[id]!.add(0);
      }
      time++;
      continue;
    }

    // Seleciona a tarefa com menor deadline
    Process currTask = activeTasks.first;

    // Registra a execução na matriz
    for (var id in executionMatrix.keys) {
      if (id == currTask.id) {
        executionMatrix[id]!.add(1); // Executando
      } else {
        executionMatrix[id]!.add(0); // Pronta ou bloqueada
      }
    }

    // Executa por 1 unidade de tempo
    currTask.updateTtf();

    // Verifica conclusão
    if (currTask.ttf == 0) {
      currTask.resetTtf();
      listDone.add(currTask);
      
      // Lógica Python: Atualiza deadline baseado no tempo de execução
      currTask.updateDeadline(time - currTask.execTime);
    }

    // Tratamento de Deadlines (conforme lógica Python: remove de 'done' se estourar)
    for (var t in listTasks) {
      if (time >= t.deadline) {
        listDone.removeWhere((doneTask) => doneTask.id == t.id);
      }
    }

    time++;
    
    // Safety break para evitar loop infinito em caso de lógica de tempo real impossível
    if (time > 100) break; 
  }

  return executionMatrix;
}