from stdlib_extensions.builtins import list


fn dodo() -> String:
    var components = list[String].from_values("a", "b")
    for _ in range(2):
        if components[-1] == "0":
            components.pop()
    return "dodo"


def main():
    print(dodo())
