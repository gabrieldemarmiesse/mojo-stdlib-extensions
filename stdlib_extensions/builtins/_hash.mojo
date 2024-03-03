from sys.info import sizeof
from ._generic_list import list


fn custom_hash(x: list[Int]) -> Int:
    """Very simple hash function."""
    var prime = 31
    var hash_value = 0
    for i in range(len(x)):
        hash_value = prime * hash_value + x[i]
    return hash_value
