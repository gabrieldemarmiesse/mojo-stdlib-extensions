from ...builtins import dict, hash
from ...builtins import HashableCollectionElement
from ..utils import assert_equal


@value
struct DummyStructInt(HashableCollectionElement, Intable):
    """This is to test the dict since Int cannot be used yet."""

    var integer: Int

    fn __hash__(self) -> Int:
        return hash(self.integer)

    fn __eq__(self, other: DummyStructInt) -> Bool:
        return self.integer == other.integer

    fn __int__(self) -> Int:
        return self.integer


def test_simple_dict_usage_int():
    some_dict = dict[DummyStructInt, DummyStructInt]()
    some_dict[1] = 2
    assert_equal(int(some_dict[1]), 2)
    assert_equal(len(some_dict), 1)

    some_dict[1] = 3
    assert_equal(int(some_dict[1]), 3)
    assert_equal(len(some_dict), 1)

    some_dict[2] = 20
    assert_equal(int(some_dict[2]), 20)
    assert_equal(len(some_dict), 2)

    some_dict.pop(1)
    assert_equal(int(some_dict[2]), 20)
    assert_equal(len(some_dict), 1)


def test_lots_of_insersion_and_deletion_int():
    some_dict = dict[DummyStructInt, DummyStructInt]()
    for i in range(100_000):
        some_dict[i] = i * 10

    for i in range(100_000):
        assert_equal(int(some_dict[i]), i * 10)
    assert_equal(len(some_dict), 100_000)

    for i in range(50_000):
        some_dict.pop(i)

    assert_equal(len(some_dict), 50_000)
    for i in range(50_000, 100_000):
        assert_equal(int(some_dict[i]), i * 10)


# now we do the same with strings


@value
struct DummyStructStr(HashableCollectionElement, Stringable):
    """This is to test the dict since Int cannot be used yet."""

    var str: String

    fn __init__(inout self, x: StringLiteral):
        self.str = x

    fn __init__(inout self, x: String):
        self.str = x

    fn __hash__(self) -> Int:
        return hash(self.str)

    fn __eq__(self, other: DummyStructStr) -> Bool:
        return self.str == other.str

    fn __str__(self) -> String:
        return self.str


def test_simple_dict_usage_str():
    some_dict = dict[DummyStructStr, DummyStructStr]()
    some_dict["hello"] = "world"
    assert_equal(str(some_dict["hello"]), "world")
    assert_equal(len(some_dict), 1)

    some_dict["hello"] = "alice"
    assert_equal(str(some_dict["hello"]), "alice")
    assert_equal(len(some_dict), 1)

    some_dict["hi"] = "bob"
    assert_equal(str(some_dict["hi"]), "bob")
    assert_equal(len(some_dict), 2)

    some_dict.pop("hello")
    assert_equal(str(some_dict["hi"]), "bob")
    assert_equal(len(some_dict), 1)


def test_lots_of_insersion_and_deletion_str():
    some_dict = dict[DummyStructStr, DummyStructStr]()
    for i in range(10_000):
        some_dict[str(i)] = str(i * 10)

    for i in range(10_000):
        assert_equal(str(some_dict[str(i)]), str(i * 10))
    assert_equal(len(some_dict), 10_000)

    for i in range(5_000):
        some_dict.pop(str(i))

    assert_equal(len(some_dict), 5_000)
    for i in range(5_000, 10_000):
        assert_equal(str(some_dict[str(i)]), str(i * 10))


def test_lots_of_insersion_and_deletion_str_interleaved():
    some_dict = dict[DummyStructStr, DummyStructStr]()
    for i in range(10_000):
        some_dict[str(i)] = str(i * 10)

    for i in range(10_000):
        assert_equal(str(some_dict[str(i)]), str(i * 10))
    assert_equal(len(some_dict), 10_000)

    for i in range(0, 10_000, 2):
        some_dict.pop(str(i))
    assert_equal(len(some_dict), 5_000)
    for i in range(1, 10_000, 2):
        assert_equal(str(some_dict[str(i)]), str(i * 10))


def run_tests():
    test_simple_dict_usage_int()
    test_lots_of_insersion_and_deletion_int()
    test_simple_dict_usage_str()
    test_lots_of_insersion_and_deletion_str()
    test_lots_of_insersion_and_deletion_str_interleaved()
