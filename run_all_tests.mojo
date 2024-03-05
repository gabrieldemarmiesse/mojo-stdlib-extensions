@value
struct list[T: CollectionElement]:
    var _internal_vector: DynamicVector[T]

    fn __init__(inout self):
        self._internal_vector = DynamicVector[T]()

    @staticmethod
    fn from_values(*values: T) -> list[T]:
        var result = list[T]()
        for value in values:
            result._internal_vector.append(value[])
        return result

    fn pop(inout self) -> T:
        return self._internal_vector.pop_back()


fn dodo() -> String:
    var components = list[String].from_values("a", "b")
    for _ in range(2):
        if True:
            components.pop()
    return "dodo"


def main():
    print(dodo())
