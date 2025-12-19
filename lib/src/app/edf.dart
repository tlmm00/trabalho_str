import '../model/process.dart';

SimulationResult edf(List<Process> tasks, int maxTime) {
  List<Process> workList = tasks.map((t) => t.copy()).toList();
  
  Map<int, List<int>> executionMatrix = {
    for (var t in tasks) t.id: [],
    -1: [] 
  };

  for (int time = 0; time < maxTime; time++) {
    for (var p in workList) {
      p.checkArrival(time);
    }

    List<Process> readyQueue = workList.where((p) => 
      time >= p.offset && !p.isFinished
    ).toList();

    // EDF: Menor Deadline Absoluto
    readyQueue.sort((a, b) {
      int cmp = a.absoluteDeadline.compareTo(b.absoluteDeadline);
      if (cmp != 0) return cmp;
      return a.id.compareTo(b.id);
    });

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