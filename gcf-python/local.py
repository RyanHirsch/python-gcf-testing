import sys
import os
import importlib
import site
from flask import Flask, request

# Manipulate our local module resolution to match that which will
#  be occuring on GCP
this_dir = os.path.dirname(os.path.abspath(__file__))
for sub_dir in next(os.walk(this_dir))[1]:
    site.addsitedir(f"{this_dir}/{sub_dir}")

app = Flask(__name__)


@app.route("/<folder>")
def index(folder):
    return importlib.import_module(f"{folder}.main", folder).handler(request)


app.run("127.0.0.1", 5000, debug=True)
