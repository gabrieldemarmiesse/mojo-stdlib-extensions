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

    my_list[0] = "big"
    assert_equal(my_list[0], "big")
    assert_equal(my_list[1], "world")

    new_list = my_list.copy()
    assert_equal(new_list[0], "big")
    assert_equal(new_list[1], "world")
    assert_equal(len(new_list), 2)

    my_list.clear()
    assert_equal(len(my_list), 0)
    # only the old list changed
    assert_equal(len(new_list), 2)


def run_tests():
    test_list_of_strings()
