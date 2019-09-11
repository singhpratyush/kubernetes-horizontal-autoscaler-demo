from flask import Flask

app = Flask(__name__)

@app.route('/')
def work():
    amount = 0.01
    for _ in range(10000000):
        amount += amount ** 0.5
    return 'Hey, just finished a heavy task!!!'
