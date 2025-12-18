class Process {
  int id;
  int deadline;
  int timeInit;
  int ttf;
  int execTime;

  // Construtor com parâmetros nomeados para maior clareza
  Process({
    required this.id,
    required this.timeInit,
    required this.ttf,
    required this.deadline,
  }) : execTime = ttf;

  // Getters de compatibilidade para o código legado
  int getId() => id;
  int getDeadline() => deadline;
  int getTimeInit() => timeInit;
  int getTtf() => ttf;

  // Reinicia o estado para re-submissão (Tempo Real)
  void resetTtf() => this.ttf = this.execTime;

  // Atualizado: aceita quantum opcional para o Round Robin
  void updateTtf([int quantum = 1]) {
    this.ttf -= quantum;
    if (this.ttf < 0) this.ttf = 0;
  }

  void updateDeadline(int offset) {
    this.deadline += offset;
  }

  Process copy() {
    return Process(
      id: this.id,
      timeInit: this.timeInit,
      ttf: this.ttf,
      deadline: this.deadline,
    );
  }
}