from collections.vector import DynamicVector


@value
struct list[T: CollectionElement]:
    var _internal_vector: DynamicVector[T]

    fn __init__(inout self):
        self._internal_vector = DynamicVector[T]()


fn from_values[T: CollectionElement](*values: T) -> list[Int]:
    return list[Int]()


alias _DAYS_IN_MONTH = from_values(-1)


def main():
    a = _DAYS_IN_MONTH._internal_vector[0]
