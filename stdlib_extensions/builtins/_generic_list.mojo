from collections.vector import DynamicVector


@value
struct list[T: CollectionElement](Sized, Movable):
    var _internal_vector: DynamicVector[T]

    fn __init__(inout self):
        self._internal_vector = DynamicVector[T]()

    fn __init__(inout self, owned value: DynamicVector[T]):
        self._internal_vector = value

    @staticmethod
    fn from_values(*values: T) -> list[T]:
        var result = list[T]()
        for value in values:
            result.append(value[])
        return result

    @always_inline
    fn _normalize_index(self, index: Int) -> Int:
        if index < 0:
            return len(self) + index
        else:
            return index

    fn append(inout self, value: T):
        self._internal_vector.push_back(value)

    fn clear(inout self):
        self._internal_vector.clear()

    fn copy(self) -> list[T]:
        return list(self._internal_vector)

    fn __getitem__(self, index: Int) raises -> T:
        if index >= len(self._internal_vector):
            raise Error("list index out of range")
        return self.unchecked_get(self._normalize_index(index))

    @always_inline
    fn unchecked_get(self, index: Int) -> T:
        return self._internal_vector[index]

    @always_inline
    fn __len__(self) -> Int:
        return len(self._internal_vector)
