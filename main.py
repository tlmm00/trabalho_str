import sys
import os

target_directory = os.path.abspath('./src')
sys.path.append(target_directory)

target_directory = os.path.abspath('./model')
sys.path.append(target_directory)

from edf import edf
from rm import rm
#from escalonador import *
from models import Task, Job


def main():
    # --- Exemplo de Uso ---

    # Exemplo baseado no exercíccio uniprocessado onde EDF é ótimo (U <= 1) [2]
    # τ1:(C=2, T=4), τ2:(C=3, T=6)
    # Utilização Total = 2/4 + 3/6 = 0.5 + 0.5 = 1.0. Escalonável por EDF [2].

    try:
        T1 = Task(task_id=1, C=2, T=4)
        T2 = Task(task_id=2, C=3, T=6)
        
        tasks_set = [T1, T2]
        
        total_utilization = sum(t.get_utilization() for t in tasks_set)
        print(f"Utilização total do sistema: {total_utilization}")
        
        # Simular por um período de tempo equivalente ao MMC dos períodos (12) mais um ciclo
        edf(tasks_set, total_sim_time=13) 

    except ValueError as e:
        print(e)
    


if __name__ == "__main__":
    main()
