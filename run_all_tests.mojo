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


fn dodo():
    var components = list[String].from_values("a", "b")
    components._internal_vector.pop_back()


def main():
    dodo()
