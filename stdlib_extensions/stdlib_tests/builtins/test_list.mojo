from ...builtins import list
from ...stdlib_tests.utils import assert_true, assert_false, assert_equal


def test_list_of_strings():
    my_list = list[String]()

    assert_equal(len(my_list), 0)
    my_list.append("hello")
    my_list.append("world")

    assert_equal(my_list[0], "hello")
    assert_equal(my_list[1], "world")
    assert_equal(len(my_list), 2)


def run_tests():
    test_list_of_strings()
