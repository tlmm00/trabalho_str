import heapq
import sys
import os

target_directory = os.path.abspath('model')
sys.path.append(target_directory)

from models import Task, Job

def edf(tasks, total_sim_time):
    """
    Simula o escalonamento EDF para um sistema uniprocessador.
    """
    
    # Fila de Jobs Prontos (Ready Queue) - Min-Heap priorizado por deadline (d)
    ready_queue = []
    
    # Dicionário para rastrear o tempo de liberação do próximo job para cada tarefa
    next_release = {task.task_id: 0 for task in tasks}
    
    # Rastreamento de execução e status
    execution_log = []
    current_job = None
    deadline_misses = 0
    jobs_completed = 0
    
    print(f"Iniciando simulação EDF por {total_sim_time} unidades de tempo...")
    
    # Loop de simulação, unitário no tempo (t)
    for t in range(total_sim_time):
        
        # 1. Geração de Jobs (Instante de Liberação rk)
        for task in tasks:
            if t == next_release[task.task_id]:
                # O deadline implícito é dk = rk + T [3]
                deadline = t + task.T
                
                # Criar o novo job
                new_job = Job(
                    task_id=task.task_id,
                    release_time=t,
                    deadline=deadline,
                    execution_time=task.C
                )
                
                # Adicionar à fila de prioridade
                heapq.heappush(ready_queue, new_job)
                
                # Definir o tempo de liberação do próximo job para esta tarefa
                # Para tarefas periódicas síncronas, rk = kT [1]
                next_release[task.task_id] += task.T
        
        # 2. Verificação de Deadlines (antes da execução)
        # Verifica se o job que estava sendo executado (se houver) perdeu o deadline
        if current_job:
            if current_job.d <= t and current_job.C_rem > 0:
                print(f"[TEMPO {t}] FALHA! Job T{current_job.task_id} perdeu o deadline {current_job.d}.")
                deadline_misses += 1
                current_job = None # O job falho é descartado
                # Tenta realocar o processador no passo 3
        
        # 3. Seleção do próximo Job (Escalonamento EDF)
        
        # Se houver jobs prontos na fila, o job com o deadline mais cedo é escolhido
        if ready_queue:
            # Pega o job de maior prioridade (menor deadline)
            next_job = ready_queue
            
            # Checa se precisamos fazer preempção
            if current_job != next_job:
                # Se o job atual não terminou, ele volta para a fila (preempção)
                if current_job and current_job.C_rem > 0:
                    heapq.heappush(ready_queue, current_job)
                    
                # Escolhe o novo job de maior prioridade
                current_job = heapq.heappop(ready_queue)
            
            # Se a fila estava vazia, mas agora não está, pegamos o job
            elif current_job is None:
                current_job = heapq.heappop(ready_queue)
        
        # 4. Execução
        
        if current_job and current_job.C_rem > 0:
            current_job.C_rem -= 1 # Executa por 1 unidade de tempo
            execution_log.append(f"T{current_job.task_id}")
            
            # Verifica a conclusão
            if current_job.C_rem == 0:
                jobs_completed += 1
                
                # Verifica se o job terminou antes ou exatamente no deadline
                if t + 1 > current_job.d:
                     # Esta verificação é um fallback, já que jobs ativos não devem ter d <= t
                     print(f"[TEMPO {t+1}] FALHA! Job T{current_job.task_id} terminou atrasado (d={current_job.d}).")
                     # Se terminou após o deadline (mas foi executado até o fim), conta a falha
                     deadline_misses += 1
                
                # Se terminou a tempo, registra
                else:
                    print(f"[TEMPO {t+1}] Job T{current_job.task_id} concluído. Deadline cumprido em {current_job.d}.")
                
                current_job = None # Processador livre para o próximo ciclo
        else:
            # Processador ocioso
            execution_log.append("IDLE")
            current_job = None
            
        # 5. Verificação de Deadlines na Fila (Apenas para Jobs liberados mas não escalonados)
        # Verifica se algum job na fila perdeu o deadline enquanto esperava
        missed_while_waiting = []
        for job in ready_queue:
             if job.d <= t + 1 and job.C_rem > 0: # O deadline será perdido no próximo instante
                 missed_while_waiting.append(job)

        if missed_while_waiting:
             for job in missed_while_waiting:
                 # Remove o job perdido da fila (se o Python suportasse remoção fácil de item)
                 # Devido à natureza do heapq, faremos a verificação mais crítica no passo 2
                 pass
                 
    print("\n--- Resultado da Simulação ---")
    print(f"Jobs concluídos: {jobs_completed}")
    print(f"Falhas de deadline (incluindo preempção tardia): {deadline_misses}")
    print(f"Log de execução (cada item é 1 unidade de tempo): {execution_log}")
    