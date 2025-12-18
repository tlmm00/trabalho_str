import '../model/process.dart';
import 'package:tuple/tuple.dart';

class Aux {
  /// Ordena processos pelo tempo de chegada (usado para preparar a fila inicial).
  List<Process> quickSortProcessByInitTime(List<Process> processList) {
    if (processList.length <= 1) {
      return processList;
    } else {
      int middleIndex = processList.length ~/ 2;
      // Utiliza o getter de compatibilidade getTimeInit()
      int pivotTime = processList[middleIndex].getTimeInit();

      List<Process> left =
          processList.where((p) => p.getTimeInit() < pivotTime).toList();
      List<Process> middle =
          processList.where((p) => p.getTimeInit() == pivotTime).toList();
      List<Process> right =
          processList.where((p) => p.getTimeInit() > pivotTime).toList();

      return quickSortProcessByInitTime(left) +
          middle +
          quickSortProcessByInitTime(right);
    }
  }

  /// Retorna o processo com o menor deadline absoluto.
  Tuple2<Process, int> getMinDeadline(List<Process> processList) {
    int minDeadline = -1;
    // CORREÇÃO: Uso de parâmetros nomeados conforme o novo modelo
    Process minDeadlineProcess = Process(id: -2, timeInit: -2, ttf: -2, deadline: -2);

    for (var p in processList) {
      // No paradigma de tempo real, o deadline já é absoluto conforme o script Python
      int pDeadline = p.getDeadline();
      if (minDeadline == -1 || pDeadline < minDeadline) {
        minDeadline = pDeadline;
        minDeadlineProcess = p;
      }
    }

    return Tuple2(minDeadlineProcess, minDeadline);
  }

  /// Retorna o processo com o menor tempo restante (TTF).
  Tuple2<Process, int> getMinTtf(List<Process> processList) {
    int minTtf = -1;
    // CORREÇÃO: Uso de parâmetros nomeados
    Process minTtfProcess = Process(id: -2, timeInit: -2, ttf: -2, deadline: -2);

    for (Process p in processList) {
      int pTtf = p.getTtf();
      if (minTtf == -1 || pTtf < minTtf) {
        minTtf = pTtf;
        minTtfProcess = p;
      }
    }

    return Tuple2(minTtfProcess, minTtf);
  }

  /// Converte uma lista de IDs de execução em uma matriz para a interface do Flutter.
  Map<int, List<int>> listToMatrix(List<int> processIdList) {
    Map<int, List<int>> finalMap = {};
    finalMap[-1] = []; // Linha para Sobrecarga/Idle
    
    // Identifica todos os processos únicos (ignorando IDs de controle)
    Set<int> uniqueIds = processIdList.toSet();
    for (int n in uniqueIds) {
      if (!([-1, -3].contains(n))) finalMap[n] = [];
    }

    for (int id in processIdList) {
      if (!([-1, -3].contains(id))) {
        // Processo normal executando
        finalMap[-1]?.add(0);
        finalMap.forEach((key, list) {
          if (key != -1) {
            list.add(key == id ? 1 : 0);
          }
        });
      } else {
        // ID -1 (Sobrecarga) ou -3 (Idle)
        finalMap[-1]?.add(id == -1 ? 1 : 0);
        finalMap.forEach((key, list) {
          if (key != -1) list.add(0);
        });
      }
    }
    return finalMap;
  }
}