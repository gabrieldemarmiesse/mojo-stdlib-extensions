from ...builtins import dict, hash
from ...builtins import HashableCollectionElement
from ..utils import assert_equal


@value
struct DummyStructInt(HashableCollectionElement):
    """This is to test the dict since Int cannot be used yet."""

    var integer: Int

    fn __hash__(self) -> Int:
        return hash(self.integer)

    fn __eq__(self, other: DummyStructInt) -> Bool:
        return self.integer == other.integer


def test_simple_dict_usage_int():
    some_dict = dict[DummyStructInt, DummyStructInt]()
    some_dict[1] = 2
    assert_equal(some_dict[1].integer, 2)
    assert_equal(len(some_dict), 1)

    some_dict[1] = 3
    assert_equal(some_dict[1].integer, 3)
    assert_equal(len(some_dict), 1)

    some_dict[2] = 20
    assert_equal(some_dict[2].integer, 20)
    assert_equal(len(some_dict), 2)

    some_dict.pop(1)
    assert_equal(some_dict[2].integer, 20)
    assert_equal(len(some_dict), 1)


def test_lots_of_insersion_and_deletion_int():
    some_dict = dict[DummyStructInt, DummyStructInt]()
    for i in range(100_000):
        some_dict[i] = i * 10

    assert_equal(some_dict[1_000].integer, 10_000)
    assert_equal(len(some_dict), 100_000)

    for i in range(50_000):
        some_dict.pop(i)

    assert_equal(len(some_dict), 50_000)
    assert_equal(some_dict[50_000].integer, 500_000)


def run_tests():
    test_simple_dict_usage_int()
    test_lots_of_insersion_and_deletion_int()
