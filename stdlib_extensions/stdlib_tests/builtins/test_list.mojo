from ...builtins import list, list_to_str
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


def test_extend():
    some_list = list[Int]()
    some_list.append(0)
    some_list.append(1)

    second_list = list[Int]()
    second_list.append(2)
    second_list.append(3)

    some_list.extend(second_list)
    assert_equal(len(some_list), 4)
    # this is because of https://github.com/modularml/mojo/issues/1408
    assert_equal(some_list.__getitem__(index=0), 0)
    assert_equal(some_list.__getitem__(index=1), 1)
    assert_equal(some_list.__getitem__(index=2), 2)
    assert_equal(some_list.__getitem__(index=3), 3)


def test_pop_default():
    some_list = list[Int]()
    some_list.append(0)
    some_list.append(1)
    some_list.append(2)
    some_list.append(3)

    assert_equal(some_list.pop(), 3)
    assert_equal(some_list.pop(), 2)
    assert_equal(some_list.pop(), 1)
    assert_equal(some_list.pop(), 0)

    assert_equal(len(some_list), 0)


def test_pop_negative_values():
    some_list = list[Int]()
    some_list.append(0)
    some_list.append(1)
    some_list.append(2)
    some_list.append(3)

    assert_equal(some_list.pop(index=-1), 3)
    assert_equal(some_list.pop(index=-2), 1)

    assert_equal(len(some_list), 2)

    assert_equal(some_list.__getitem__(index=0), 0)
    assert_equal(some_list.__getitem__(index=1), 2)


def test_pop_positive_values():
    some_list = list[Int]()
    some_list.append(0)
    some_list.append(1)
    some_list.append(2)
    some_list.append(3)

    assert_equal(some_list.pop(index=3), 3)
    assert_equal(list_to_str(some_list), "[0, 1, 2]")

    assert_equal(some_list.pop(index=1), 1)
    assert_equal(list_to_str(some_list), "[0, 2]")


def test_reverse_4_elements():
    some_list = list[Int]()
    some_list.append(0)
    some_list.append(1)
    some_list.append(2)
    some_list.append(3)

    some_list.reverse()
    assert_equal(list_to_str(some_list), "[3, 2, 1, 0]")

    some_list.reverse()
    assert_equal(list_to_str(some_list), "[0, 1, 2, 3]")


def test_reverse_5_elements():
    some_list = list[Int]()
    some_list.append(0)
    some_list.append(1)
    some_list.append(2)
    some_list.append(3)
    some_list.append(4)

    some_list.reverse()
    assert_equal(list_to_str(some_list), "[4, 3, 2, 1, 0]")

    some_list.reverse()
    assert_equal(list_to_str(some_list), "[0, 1, 2, 3, 4]")


def test_insert():
    some_list = list[Int]()
    some_list.append(0)
    some_list.append(1)
    some_list.append(2)

    some_list.insert(10, 14)
    assert_equal(list_to_str(some_list), "[0, 1, 2, 14]")

    some_list.insert(-1, 22)
    assert_equal(list_to_str(some_list), "[0, 1, 2, 14, 22]")

    some_list.insert(1, 100)
    assert_equal(list_to_str(some_list), "[0, 100, 1, 2, 14, 22]")


def run_tests():
    test_list_of_strings()
    test_extend()
    test_pop_default()
    test_pop_negative_values()
    test_pop_positive_values()
    test_reverse_4_elements()
    test_reverse_5_elements()
    test_insert()
