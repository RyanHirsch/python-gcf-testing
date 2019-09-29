import importlib
from flask import Flask, request

app = Flask(__name__)


@app.route("/<folder>")
def index(folder):
    return importlib.import_module(f"{folder}.main", folder).handler(request)


app.run("127.0.0.1", 5000, debug=True)
