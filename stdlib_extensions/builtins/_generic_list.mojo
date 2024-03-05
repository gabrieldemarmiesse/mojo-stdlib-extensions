from collections.vector import DynamicVector


@value
struct list[T: CollectionElement](Sized, Movable):
    var _internal_vector: DynamicVector[T]

    fn __init__(inout self):
        self._internal_vector = DynamicVector[T]()

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

    fn pop(inout self, index: Int = -1) -> T:
        var new_index = self._normalize_index(index)
        var element = self[new_index]
        for i in range(new_index, len(self) - 1):
            self[i] = self[i + 1]
        self._internal_vector.resize(len(self._internal_vector) - 1, element)
        return element

    fn reverse(inout self):
        for i in range(len(self) // 2):
            var mirror_i = len(self) - 1 - i
            var tmp = self[i]
            self[i] = self[mirror_i]
            self[mirror_i] = tmp

    @always_inline
    fn __getitem__(self, index: Int) -> T:
        return self._internal_vector[self._normalize_index(index)]

    @always_inline
    fn __setitem__(inout self, key: Int, value: T):
        self._internal_vector[self._normalize_index(key)] = value

    @always_inline
    fn __len__(self) -> Int:
        return len(self._internal_vector)
