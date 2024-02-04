from collections.vector import DynamicVector


@value
struct list:
    var _internal_vector: DynamicVector[Int]


fn from_values[T: CollectionElement](*values: T) -> list:
    return list(DynamicVector[Int]())


alias _DAYS_IN_MONTH = from_values[Int](-1)


def main():
    a = _DAYS_IN_MONTH._internal_vector
