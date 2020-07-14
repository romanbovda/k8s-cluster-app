import multiprocessing
from os import environ as env


workers = multiprocessing.cpu_count() * 2 + 1
threads = 2 * multiprocessing.cpu_count()
PORT = int(env.get("PORT", 5000))