from sys.info import sizeof


fn custom_hash(x: List[Int]) -> Int:
    """Very simple hash function."""
    var prime = 31
    var hash_value = 0
    for i in range(len(x)):
        hash_value = prime * hash_value + x[i]
    return hash_value
