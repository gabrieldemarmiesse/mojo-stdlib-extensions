@value
struct list[T: CollectionElement]:
    var _internal_vector: DynamicVector[T]

    fn __init__(inout self):
        self._internal_vector = DynamicVector[T]()


fn dodo():
    var components = list[String]()
    components._internal_vector.append("a")
    components._internal_vector.pop_back()


def main():
    dodo()
