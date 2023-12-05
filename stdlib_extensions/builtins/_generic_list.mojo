from utils.vector import DynamicVector


trait ListElement(CollectionElement, Stringable):
    pass


@value
struct list[T: CollectionElement](Sized):
    var _internal_vector: DynamicVector[T]

    fn __init__(inout self):
        self._internal_vector = DynamicVector[T]()

    fn __init__(inout self, owned value: DynamicVector[T]):
        self._internal_vector = value

    fn append(inout self, value: T):
        self._internal_vector.push_back(value)

    fn __getitem__(self, index: Int) raises -> T:
        if index >= len(self._internal_vector):
            raise Error("list index out of range")
        return self._getitem_without_raise(index)

    fn __getitem__(self: Self, limits: slice) raises -> Self:
        var new_list: Self = Self()
        for i in range(limits.start, limits.end, limits.step):
            new_list.append(self[i])
        return new_list

    fn _getitem_without_raise(self, index: Int) -> T:
        let new_index: Int
        if index < 0:
            new_index = len(self) + index
        else:
            new_index = index

        return self._internal_vector[new_index]

    fn __len__(self) -> Int:
        return len(self._internal_vector)

    @staticmethod
    fn from_string(input_value: String) -> list[String]:
        var result = list[String]()
        for i in range(len(input_value)):
            result.append(input_value[i])
        return result


fn list_to_str(input_list: list[String]) raises -> String:
    var result: String = "["
    for i in range(len(input_list)):
        let repr = "'" + str(input_list[i]) + "'"
        if i != len(input_list) - 1:
            result += repr + ", "
        else:
            result += repr
    return result + "]"
