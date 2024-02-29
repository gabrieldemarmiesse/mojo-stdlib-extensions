from collections.vector import DynamicVector
from .._utils import custom_debug_assert


struct ListIter[T: CollectionElement]:
    var data: list[T]
    var idx: Int

    fn __init__(inout self, data: list[T]):
        self.idx = -1
        self.data = data

    fn __len__(self) -> Int:
        return len(self.data) - self.idx - 1

    fn __next__(inout self) -> T:
        self.idx += 1
        return self.data[self.idx]


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

    fn extend(inout self, other: list[T]):
        for i in range(len(other)):
            self.append(other[i])

    fn pop(inout self, index: Int = -1) -> T:
        custom_debug_assert(
            index < len(self._internal_vector), "list index out of range"
        )
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

    fn insert(inout self, key: Int, value: T):
        var index = self._normalize_index(key)
        if index >= len(self):
            self.append(value)
            return
        # we increase the size of the array before insertion
        self.append(self[-1])
        for i in range(len(self) - 2, index, -1):
            self[i] = self[i - 1]
        self[key] = value

    @always_inline
    fn __getitem__(self, index: Int) -> T:
        custom_debug_assert(
            index < len(self._internal_vector), "list index out of range"
        )
        return self._internal_vector[self._normalize_index(index)]

    @always_inline
    fn __getitem__(self: Self, limits: Slice) -> Self:
        var new_list: Self = Self()
        for i in range(limits.start, limits.end, limits.step):
            new_list.append(self[i])
        return new_list

    @always_inline
    fn __setitem__(inout self, key: Int, value: T):
        custom_debug_assert(key < len(self._internal_vector), "list index out of range")
        self._internal_vector[self._normalize_index(key)] = value

    @always_inline
    fn __len__(self) -> Int:
        return len(self._internal_vector)

    fn __iter__(self: Self) -> ListIter[T]:
        return ListIter(self)

    @staticmethod
    fn from_string(input_value: String) -> list[String]:
        var result = list[String]()
        for i in range(len(input_value)):
            result.append(input_value[i])
        return result


fn list_to_str(input_list: list[String]) -> String:
    var result: String = "["
    for i in range(len(input_list)):
        var repr = "'" + str(input_list[i]) + "'"
        if i != len(input_list) - 1:
            result += repr + ", "
        else:
            result += repr
    return result + "]"


fn list_to_str(input_list: list[Int]) -> String:
    var result: String = "["
    for i in range(len(input_list)):
        var repr = str(input_list.__getitem__(index=i))
        if i != len(input_list) - 1:
            result += repr + ", "
        else:
            result += repr
    return result + "]"


fn _cmp_list(a: list[Int], b: list[Int]) -> Int:
    for i in range(len(a)):
        if i >= len(b):
            return 1

        if a[i] < b[i]:
            return -1
        elif a[i] == b[i]:
            continue
        else:
            return 1

    if len(a) < len(b):
        return -1
    else:
        return 0
