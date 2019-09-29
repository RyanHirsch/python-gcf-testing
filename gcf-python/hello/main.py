from utils.something import a_thing


def handler(request):
    return "This is hello " + a_thing()
