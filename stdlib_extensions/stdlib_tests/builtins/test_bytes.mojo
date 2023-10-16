from ...builtins import bytes
from ..utils import assert_equal
from utils.vector import DynamicVector


def test_bytes_operations_indexing_and_add():
    some_bytes = bytes(10)

    assert_equal(some_bytes.__len__(), 10)

    for i in range(10):
        some_bytes[i] = i

    assert_equal(some_bytes[5], 5)

    new_vector = DynamicVector[UInt8]()
    new_vector.push_back(100)
    new_vector.push_back(101)
    new_vector.push_back(102)

    new_bytes = bytes(new_vector)
    assert_equal(new_bytes[2], 102)

    combinaison = some_bytes + new_bytes
    assert_equal(combinaison[12], 102)
    assert_equal(combinaison.__len__(), 13)
    assert_equal(some_bytes.__len__(), 10)

    some_bytes += new_bytes
    assert_equal(some_bytes[12], 102)
    assert_equal(some_bytes.__len__(), 13)


def test_bytes_operations_multiplying():
    some_bytes = bytes(10)

    assert_equal(some_bytes.__len__(), 10)

    for i in range(10):
        some_bytes[i] = i

    new_bytes = some_bytes * 3

    assert_equal(new_bytes.__len__(), 30)
    assert_equal(new_bytes[12], 2)
    assert_equal(some_bytes.__len__(), 10)  # unchanged

    new_bytes = some_bytes * 0
    assert_equal(new_bytes.__len__(), 0)

    some_bytes *= 4
    assert_equal(some_bytes.__len__(), 40)
    assert_equal(some_bytes[34], 4)

    some_bytes *= 0
    assert_equal(some_bytes.__len__(), 0)


def run_tests():
    test_bytes_operations_indexing_and_add()
    test_bytes_operations_multiplying()