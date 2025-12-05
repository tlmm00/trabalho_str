import heapq
import math

class Job:
    """
    Representa um Job (instância de execução de uma tarefa).
    Contém r (tempo de liberação) e d (deadline), conforme o modelo temporal [3].
    Adicionamos C_init (tempo de execução total) e C_rem (tempo restante).
    """
    def __init__(self, task_id, release_time, deadline, execution_time):
        self.task_id = task_id # ID da tarefa parental
        self.r = release_time  # Tempo de liberação (rk) [3]
        self.d = deadline      # Deadline (dk = rk + T) [3]
        self.C_init = execution_time # Tempo de execução inicial (C) [3]
        self.C_rem = execution_time  # Tempo de execução restante

    # Sobrescreve o método de comparação (Less Than) para que o heap funcione.
    # A prioridade é determinada pelo deadline mais cedo (EDF).
    def __lt__(self, other):
        # Prioriza o job com o deadline (d) menor
        return self.d < other.d

    def __repr__(self):
        return f"Job(T{self.task_id}, d={self.d}, C_rem={self.C_rem})"

class Task:
    """
    Representa uma Tarefa periódica de tempo real τ:(C,T) [3].
    """
    # Remoção das variáveis de classe para evitar compartilhamento indesejado entre instâncias.
    def __init__(self, task_id, C, T):
        self.task_id = task_id
        self.T = T  # Período (intervalo mínimo entre jobs) [3]
        
        # A fonte indica que C (tempo de execução) deve ser menor ou igual a T [3]
        if C <= T:
            self.C = C  # Tempo de execução (WCET) [3]
        else:
            # Em vez de retornar uma string, lançamos uma exceção
            raise ValueError("Error: Tempo de execução de job maior que o período (C > T)")
    
    def get_utilization(self):
        """Calcula a utilização da tarefa: C / T"""
        # Note que a taxa de requisição é geralmente interpretada como C/T no contexto de utilização.
        return self.C / self.T 