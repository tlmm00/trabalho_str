import heapq
import sys
import os

target_directory = os.path.abspath('model')
sys.path.append(target_directory)

from models import Task, Job

def rm(tasks, total_sim_time):
    return