from ...builtins import dict, hash
from ...builtins import HashableCollectionElement
from ..utils import assert_equal


@value
struct DummyStruct(HashableCollectionElement):
    """This is to test the dict since Int cannot be used yet."""

    var integer: Int

    fn __hash__(self) -> Int:
        return hash(self.integer)

    fn __eq__(self, other: DummyStruct) -> Bool:
        return self.integer == other.integer


def test_simple_dict_usage():
    some_dict = dict[DummyStruct, DummyStruct]()
    some_dict[DummyStruct(1)] = DummyStruct(2)
    assert_equal(some_dict[DummyStruct(1)].integer, 2)

    some_dict[DummyStruct(1)] = DummyStruct(3)
    assert_equal(some_dict[DummyStruct(1)].integer, 3)


def run_tests():
    test_simple_dict_usage()
