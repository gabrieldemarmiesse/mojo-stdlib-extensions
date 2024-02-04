from collections.vector import DynamicVector


fn from_values[T: CollectionElement](*values: T) -> DynamicVector[Int]:
    return DynamicVector[Int]()


alias _DAYS_IN_MONTH = from_values[Int](-1)


def main():
    a = len(_DAYS_IN_MONTH)
