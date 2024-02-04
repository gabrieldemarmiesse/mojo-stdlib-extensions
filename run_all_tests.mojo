from collections.vector import DynamicVector


@value
struct list[T: CollectionElement](Movable):
    var _internal_vector: DynamicVector[T]

    fn __init__(inout self):
        self._internal_vector = DynamicVector[T]()

    @staticmethod
    fn from_values(*values: T) -> list[T]:
        var result = list[T]()
        for value in values:
            result._internal_vector.push_back(value[])
        return result


alias _DAYS_IN_MONTH = list[Int].from_values(
    -1, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
)


def run_each_module():
    a = _DAYS_IN_MONTH._internal_vector[0]


def main():
    run_each_module()
