from ._generic_list import list
from .._utils import custom_debug_assert
from .string import rjust
from ._dynamic_vector_list import List


fn get_mapping_byte_to_value() -> list[String]:
    var bytes_display = list[String]()
    bytes_display.append("\\x00")
    bytes_display.append("\\x01")
    bytes_display.append("\\x02")
    bytes_display.append("\\x03")
    bytes_display.append("\\x04")
    bytes_display.append("\\x05")
    bytes_display.append("\\x06")
    bytes_display.append("\\x07")
    bytes_display.append("\\x08")
    bytes_display.append("\\t")
    bytes_display.append("\\n")
    bytes_display.append("\\x0b")
    bytes_display.append("\\x0c")
    bytes_display.append("\\r")
    bytes_display.append("\\x0e")
    bytes_display.append("\\x0f")
    bytes_display.append("\\x10")
    bytes_display.append("\\x11")
    bytes_display.append("\\x12")
    bytes_display.append("\\x13")
    bytes_display.append("\\x14")
    bytes_display.append("\\x15")
    bytes_display.append("\\x16")
    bytes_display.append("\\x17")
    bytes_display.append("\\x18")
    bytes_display.append("\\x19")
    bytes_display.append("\\x1a")
    bytes_display.append("\\x1b")
    bytes_display.append("\\x1c")
    bytes_display.append("\\x1d")
    bytes_display.append("\\x1e")
    bytes_display.append("\\x1f")
    bytes_display.append(" ")
    bytes_display.append("!")
    bytes_display.append('"')
    bytes_display.append("#")
    bytes_display.append("$")
    bytes_display.append("%")
    bytes_display.append("&")
    bytes_display.append("'")
    bytes_display.append("(")
    bytes_display.append(")")
    bytes_display.append("*")
    bytes_display.append("+")
    bytes_display.append(",")
    bytes_display.append("-")
    bytes_display.append(".")
    bytes_display.append("/")
    bytes_display.append("0")
    bytes_display.append("1")
    bytes_display.append("2")
    bytes_display.append("3")
    bytes_display.append("4")
    bytes_display.append("5")
    bytes_display.append("6")
    bytes_display.append("7")
    bytes_display.append("8")
    bytes_display.append("9")
    bytes_display.append(":")
    bytes_display.append(";")
    bytes_display.append("<")
    bytes_display.append("=")
    bytes_display.append(">")
    bytes_display.append("?")
    bytes_display.append("@")
    bytes_display.append("A")
    bytes_display.append("B")
    bytes_display.append("C")
    bytes_display.append("D")
    bytes_display.append("E")
    bytes_display.append("F")
    bytes_display.append("G")
    bytes_display.append("H")
    bytes_display.append("I")
    bytes_display.append("J")
    bytes_display.append("K")
    bytes_display.append("L")
    bytes_display.append("M")
    bytes_display.append("N")
    bytes_display.append("O")
    bytes_display.append("P")
    bytes_display.append("Q")
    bytes_display.append("R")
    bytes_display.append("S")
    bytes_display.append("T")
    bytes_display.append("U")
    bytes_display.append("V")
    bytes_display.append("W")
    bytes_display.append("X")
    bytes_display.append("Y")
    bytes_display.append("Z")
    bytes_display.append("[")
    bytes_display.append("\\")
    bytes_display.append("]")
    bytes_display.append("^")
    bytes_display.append("_")
    bytes_display.append("`")
    bytes_display.append("a")
    bytes_display.append("b")
    bytes_display.append("c")
    bytes_display.append("d")
    bytes_display.append("e")
    bytes_display.append("f")
    bytes_display.append("g")
    bytes_display.append("h")
    bytes_display.append("i")
    bytes_display.append("j")
    bytes_display.append("k")
    bytes_display.append("l")
    bytes_display.append("m")
    bytes_display.append("n")
    bytes_display.append("o")
    bytes_display.append("p")
    bytes_display.append("q")
    bytes_display.append("r")
    bytes_display.append("s")
    bytes_display.append("t")
    bytes_display.append("u")
    bytes_display.append("v")
    bytes_display.append("w")
    bytes_display.append("x")
    bytes_display.append("y")
    bytes_display.append("z")
    bytes_display.append("{")
    bytes_display.append("|")
    bytes_display.append("}")
    bytes_display.append("~")
    bytes_display.append("\\x7f")
    bytes_display.append("\\x80")
    bytes_display.append("\\x81")
    bytes_display.append("\\x82")
    bytes_display.append("\\x83")
    bytes_display.append("\\x84")
    bytes_display.append("\\x85")
    bytes_display.append("\\x86")
    bytes_display.append("\\x87")
    bytes_display.append("\\x88")
    bytes_display.append("\\x89")
    bytes_display.append("\\x8a")
    bytes_display.append("\\x8b")
    bytes_display.append("\\x8c")
    bytes_display.append("\\x8d")
    bytes_display.append("\\x8e")
    bytes_display.append("\\x8f")
    bytes_display.append("\\x90")
    bytes_display.append("\\x91")
    bytes_display.append("\\x92")
    bytes_display.append("\\x93")
    bytes_display.append("\\x94")
    bytes_display.append("\\x95")
    bytes_display.append("\\x96")
    bytes_display.append("\\x97")
    bytes_display.append("\\x98")
    bytes_display.append("\\x99")
    bytes_display.append("\\x9a")
    bytes_display.append("\\x9b")
    bytes_display.append("\\x9c")
    bytes_display.append("\\x9d")
    bytes_display.append("\\x9e")
    bytes_display.append("\\x9f")
    bytes_display.append("\\xa0")
    bytes_display.append("\\xa1")
    bytes_display.append("\\xa2")
    bytes_display.append("\\xa3")
    bytes_display.append("\\xa4")
    bytes_display.append("\\xa5")
    bytes_display.append("\\xa6")
    bytes_display.append("\\xa7")
    bytes_display.append("\\xa8")
    bytes_display.append("\\xa9")
    bytes_display.append("\\xaa")
    bytes_display.append("\\xab")
    bytes_display.append("\\xac")
    bytes_display.append("\\xad")
    bytes_display.append("\\xae")
    bytes_display.append("\\xaf")
    bytes_display.append("\\xb0")
    bytes_display.append("\\xb1")
    bytes_display.append("\\xb2")
    bytes_display.append("\\xb3")
    bytes_display.append("\\xb4")
    bytes_display.append("\\xb5")
    bytes_display.append("\\xb6")
    bytes_display.append("\\xb7")
    bytes_display.append("\\xb8")
    bytes_display.append("\\xb9")
    bytes_display.append("\\xba")
    bytes_display.append("\\xbb")
    bytes_display.append("\\xbc")
    bytes_display.append("\\xbd")
    bytes_display.append("\\xbe")
    bytes_display.append("\\xbf")
    bytes_display.append("\\xc0")
    bytes_display.append("\\xc1")
    bytes_display.append("\\xc2")
    bytes_display.append("\\xc3")
    bytes_display.append("\\xc4")
    bytes_display.append("\\xc5")
    bytes_display.append("\\xc6")
    bytes_display.append("\\xc7")
    bytes_display.append("\\xc8")
    bytes_display.append("\\xc9")
    bytes_display.append("\\xca")
    bytes_display.append("\\xcb")
    bytes_display.append("\\xcc")
    bytes_display.append("\\xcd")
    bytes_display.append("\\xce")
    bytes_display.append("\\xcf")
    bytes_display.append("\\xd0")
    bytes_display.append("\\xd1")
    bytes_display.append("\\xd2")
    bytes_display.append("\\xd3")
    bytes_display.append("\\xd4")
    bytes_display.append("\\xd5")
    bytes_display.append("\\xd6")
    bytes_display.append("\\xd7")
    bytes_display.append("\\xd8")
    bytes_display.append("\\xd9")
    bytes_display.append("\\xda")
    bytes_display.append("\\xdb")
    bytes_display.append("\\xdc")
    bytes_display.append("\\xdd")
    bytes_display.append("\\xde")
    bytes_display.append("\\xdf")
    bytes_display.append("\\xe0")
    bytes_display.append("\\xe1")
    bytes_display.append("\\xe2")
    bytes_display.append("\\xe3")
    bytes_display.append("\\xe4")
    bytes_display.append("\\xe5")
    bytes_display.append("\\xe6")
    bytes_display.append("\\xe7")
    bytes_display.append("\\xe8")
    bytes_display.append("\\xe9")
    bytes_display.append("\\xea")
    bytes_display.append("\\xeb")
    bytes_display.append("\\xec")
    bytes_display.append("\\xed")
    bytes_display.append("\\xee")
    bytes_display.append("\\xef")
    bytes_display.append("\\xf0")
    bytes_display.append("\\xf1")
    bytes_display.append("\\xf2")
    bytes_display.append("\\xf3")
    bytes_display.append("\\xf4")
    bytes_display.append("\\xf5")
    bytes_display.append("\\xf6")
    bytes_display.append("\\xf7")
    bytes_display.append("\\xf8")
    bytes_display.append("\\xf9")
    bytes_display.append("\\xfa")
    bytes_display.append("\\xfb")
    bytes_display.append("\\xfc")
    bytes_display.append("\\xfd")
    bytes_display.append("\\xfe")
    bytes_display.append("\\xff")
    return bytes_display


@value
struct bytes(Stringable, Sized, CollectionElement):
    """A mutable sequence of bytes. Behaves like the python version.

    Note that some_bytes[i] returns an UInt8.
    some_bytes *= 2 modifies the sequence in-place. Same with +=.

    Also __setitem__ is available, meaning you can do some_bytes[7] = 105 or
    even some_bytes[7] = some_other_byte (the latter must be only one byte long).
    """

    var _vector: List[UInt8]

    fn __init__(inout self):
        self._vector = List[UInt8]()

    fn __init__(inout self, owned vector: List[UInt8]):
        self._vector = vector ^

    fn __init__(inout self, size: Int):
        self._vector = List[UInt8](capacity=size)
        for i in range(size):
            self._vector.append(0)

    @staticmethod
    fn from_values(*values: UInt8) -> bytes:
        var vector = List[UInt8](capacity=len(values))
        for value in values:
            vector.append(value)
        return bytes(vector)

    fn __len__(self) -> Int:
        return len(self._vector)

    fn __getitem__(self, index: Int) -> UInt8:
        return self._vector[index]

    fn __setitem__(inout self, index: Int, value: UInt8):
        self._vector[index] = value

    fn __setitem__(inout self, index: Int, value: bytes):
        self._vector[index] = value[0]

    fn __eq__(self, other: bytes) -> Bool:
        if len(self) != len(other):
            return False
        for i in range(len(self)):
            if self[i] != other[i]:
                return False
        return True

    fn __ne__(self, other: bytes) -> Bool:
        return not (self == other)

    fn __add__(owned self, other: bytes) -> bytes:
        self._vector.extend(other._vector)
        return self

    fn __iadd__(inout self: Self, other: bytes):
        self._vector.extend(other._vector)

    fn __mul__(self, other: Int) -> bytes:
        var new_bytes = bytes()
        for i in range(other):
            new_bytes += self
        return new_bytes

    fn __imul__(inout self: Self, other: Int):
        if other <= 0:
            self._vector.clear()
            return
        starting_lenght = len(self)
        var iterations = other - 1
        for _ in range(iterations):
            for j in range(starting_lenght):
                self._vector.append(self[j])

    fn __str__(self) -> String:
        alias mapping = get_mapping_byte_to_value()
        var result_string: String = "b'"
        for i in range(len(self)):
            result_string += mapping[self._vector[i].to_int()]
        result_string += "'"
        return result_string

    fn __repr__(self) -> String:
        return self.__str__()

    fn hex(self) -> String:
        var result: String = ""
        for i in range(len(self)):
            var as_hex = hex(self[i])[2:]
            result += rjust(as_hex, 2, "0")
        return result

    fn __hash__(self) -> Int:
        # TODO: do better
        return hash(str(self))

    @staticmethod
    fn fromhex(string: String) -> bytes:
        # TODO: remove whitespaces on the input string
        var vector_of_bytes = List[UInt8](capacity=len(string) // 2)
        var string_length = len(string)
        for i in range(0, string_length, 2):
            var first_char = string[i]
            var second_char = string[i + 1]
            var first_value = _ascii_char_to_int(first_char)
            var second_value = _ascii_char_to_int(second_char)
            var final_value = (first_value << 4) + second_value
            vector_of_bytes.append(UInt8(final_value))
        return bytes(vector_of_bytes)


fn _ascii_char_to_int(char: String) -> Int:
    var ord_value: Int = ord(char)
    if 48 <= ord_value <= 57:
        return ord_value - 48
    elif 65 <= ord_value <= 70:
        return ord_value - 55
    elif 97 <= ord_value <= 102:
        return ord_value - 87
    else:
        custom_debug_assert(False, "Invalid character in hex string")
        return 0


fn to_bytes(n: Int, length: Int = 1, byteorder: String = "big") -> bytes:
    var order = range(0, length, 1)
    if byteorder == "little":
        order = range(0, length, 1)
    elif byteorder == "big":
        order = range(length - 1, -1, -1)
    else:
        custom_debug_assert(False, "byteorder must be either 'little' or 'big'")

    var result_vector = List[UInt8](capacity=length)

    for i in order:
        result_vector.append((n >> i * 8) & 0xFF)

    return bytes(result_vector)
