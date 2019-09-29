from utils.something import a_thing


def handler(request):
    return f"This {a_thing()} is world"
