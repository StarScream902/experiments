import multiprocessing
import time
import psutil
import socket
from flask import Flask


app = Flask(__name__)


def worker():
    while True:
        pass

@app.route('/cpu_load', methods=['GET', 'POST'])
def cpu_load():
    num_processes = multiprocessing.cpu_count()

    print(f'Starting {num_processes} workers')

    # Start num_processes worker processes
    processes = [multiprocessing.Process(target=worker) for i in range(num_processes)]

    for p in processes:
        p.start()

    # Let the processes run for 10 seconds
    time.sleep(1)

    # Terminate the processes
    for p in processes:
        p.terminate()

    hostname = str(socket.gethostname())
    cpu_avg_load = str(psutil.getloadavg())
    mem_stats = str(psutil.virtual_memory())
    body = f'''<!doctype html>
                <p>{hostname}</p>
                <p>CPU AVG load: {cpu_avg_load}</p>
                <p>Virt mem info: {mem_stats}</p>
              '''

    return body

if __name__ == "__main__":
    app.run(port=80, host="0.0.0.0")

# python3 ./main.py > game-$(date +%Y-%m-%d_%H-%M).log
