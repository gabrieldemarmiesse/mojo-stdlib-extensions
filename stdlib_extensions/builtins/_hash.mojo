from sys.info import sizeof
from ._generic_list import list


trait Equalable:
    fn __eq__(self: Self, other: Self) -> Bool:
        ...


trait Hashable(Equalable):
    fn __hash__(self) -> Int:
        ...


fn custom_hash[T: Hashable](x: T) -> Int:
    return x.__hash__()


fn custom_hash(x: Int) -> Int:
    return x


fn custom_hash(x: Int64) -> Int:
    """We assume 64 bits here, which is a big assumption.
    TODO: Make it work for 32 bits.
    """
    return hash(x.to_int())


fn custom_hash(x: String) -> Int:
    """Very simple hash function."""
    var prime = 31
    var hash_value = 0
    for i in range(len(x)):
        hash_value = prime * hash_value + ord(x[i])
    return hash_value


fn custom_hash(x: list[Int]) -> Int:
    """Very simple hash function."""
    var prime = 31
    var hash_value = 0
    for i in range(len(x)):
        hash_value = prime * hash_value + x[i]
    return hash_value


trait HashableCollectionElement(CollectionElement, Hashable):
    pass
