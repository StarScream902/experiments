import json
from flask import Flask, request, Response

app = Flask(__name__)

@app.route('/aim_infer', methods=['GET', 'POST'])
def aim_infer():
    req = request
    print(req.get_json())
    # event = json.loads(req.get_json()['event'])
    # print(event['attacker']['angles'])
    return "OK"

@app.route('/save', methods=['GET', 'POST'])
def save():
    req = request
    print(req.get_json())
    # event = json.loads(req.get_json())
    # print(event)
    return "OK"

if __name__ == "__main__":
    app.run(port=5000, host="0.0.0.0")

# python3 ./interface.py > game-$(date +%Y-%m-%d_%H-%M).log
