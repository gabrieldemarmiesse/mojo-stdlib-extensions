@value
struct Optional[T: CollectionElement](CollectionElement):
    var has_value: Bool
    var values: List[T]

    fn __init__(inout self, value: T):
        self.has_value = True
        self.values = List[T]()
        self.values.append(value)

    fn __init__(inout self, value: None):
        self.has_value = False
        self.values = List[T]()

    fn __is__(self, other: None) -> Bool:
        return not self.has_value

    fn __isnot__(self, other: None) -> Bool:
        return self.has_value

    fn value(self) -> T:
        return self.values[0]
