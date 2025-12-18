import '../model/process.dart';

Map<int, List<int>> rm(List<Process> tasks) {
  List<Process> listTasks = tasks.map((t) => t.copy()).toList();
  List<Process> listDone = [];
  
  Map<int, List<int>> executionMatrix = {
    for (var t in tasks) t.id: [],
    -1: [] // Linha de controle/IDLE
  };

  int time = 0;
  // RM Priority: Prioridade fixa baseada no período (deadline inicial)
  // Sort executado uma vez para definir a ordem de prioridade
  List<Process> listPriority = List.from(listTasks);
  listPriority.sort((a, b) => a.deadline.compareTo(b.deadline));

  while (listDone.length < listTasks.length && time < 100) {
    // Filtro: Tarefas que chegaram e não estão concluídas no período atual
    List<Process> activeTasks = listPriority.where((task) {
      bool isDone = listDone.any((d) => d.id == task.id);
      return !isDone && task.timeInit <= time;
    }).toList();

    if (activeTasks.isEmpty) {
      executionMatrix.forEach((key, list) => list.add(0));
      time++;
      continue;
    }

    // Pega a tarefa de maior prioridade (menor período) que está pronta
    Process currTask = activeTasks.first;

    // Registra execução
    executionMatrix.forEach((id, list) {
      if (id == currTask.id) {
        list.add(1);
      } else {
        list.add(0);
      }
    });

    currTask.updateTtf();

    if (currTask.ttf == 0) {
      currTask.resetTtf();
      listDone.add(currTask);

      // Lógica Python: Atualiza deadline e define nova chegada (periodicidade)
      currTask.updateDeadline(time - currTask.execTime);
      currTask.timeInit = currTask.deadline; 
    }

    // Verifica se tarefas concluídas devem ser reativadas para o próximo período
    for (var t in listTasks) {
      if (time >= t.deadline) {
        listDone.removeWhere((task) => task.id == t.id);
      }
    }

    time++;
  }
  return executionMatrix;
}