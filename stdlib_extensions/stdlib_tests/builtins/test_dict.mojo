from ...builtins import dict, hash, HashableInt, HashableStr, list
from ...builtins import HashableCollectionElement
from ..utils import assert_equal


def test_simple_dict_usage_int():
    some_dict = dict[HashableInt, Int]()
    some_dict[1] = 2
    # TODO: fix bug
    a = some_dict[1]
    assert_equal(some_dict[1], 2)
    assert_equal(len(some_dict), 1)

    some_dict[1] = 3
    assert_equal(some_dict[1], 3)
    assert_equal(len(some_dict), 1)

    some_dict[2] = 20
    assert_equal(some_dict[2], 20)
    assert_equal(len(some_dict), 2)

    some_dict.pop(1)
    assert_equal(some_dict[2], 20)
    assert_equal(len(some_dict), 1)


def test_lots_of_insersion_and_deletion_int():
    some_dict = dict[HashableInt, Int]()
    for i in range(100_000):
        some_dict[i] = i * 10

    for i in range(100_000):
        assert_equal(some_dict[i], i * 10)
    assert_equal(len(some_dict), 100_000)

    for i in range(50_000):
        some_dict.pop(i)

    assert_equal(len(some_dict), 50_000)
    for i in range(50_000, 100_000):
        assert_equal(some_dict[i], i * 10)


# now we do the same with strings


def test_simple_dict_usage_str():
    some_dict = dict[HashableStr, String]()
    some_dict["hello"] = "world"
    assert_equal(some_dict["hello"], "world")
    assert_equal(len(some_dict), 1)

    some_dict["hello"] = "alice"
    assert_equal(some_dict["hello"], "alice")
    assert_equal(len(some_dict), 1)

    some_dict["hi"] = "bob"
    assert_equal(some_dict["hi"], "bob")
    assert_equal(len(some_dict), 2)

    some_dict.pop("hello")
    assert_equal(some_dict["hi"], "bob")
    assert_equal(len(some_dict), 1)


def test_lots_of_insersion_and_deletion_str():
    some_dict = dict[HashableStr, String]()
    for i in range(10_000):
        some_dict[str(i)] = str(i * 10)

    for i in range(10_000):
        assert_equal(some_dict[str(i)], str(i * 10))
    assert_equal(len(some_dict), 10_000)

    for i in range(5_000):
        some_dict.pop(str(i))

    assert_equal(len(some_dict), 5_000)
    for i in range(5_000, 10_000):
        assert_equal(some_dict[str(i)], str(i * 10))


def test_lots_of_insersion_and_deletion_str_interleaved():
    some_dict = dict[HashableStr, String]()
    for i in range(10_000):
        some_dict[str(i)] = str(i * 10)

    for i in range(10_000):
        assert_equal(some_dict[str(i)], str(i * 10))
    assert_equal(len(some_dict), 10_000)

    for i in range(0, 10_000, 2):
        some_dict.pop(str(i))
    assert_equal(len(some_dict), 5_000)
    for i in range(1, 10_000, 2):
        assert_equal(some_dict[str(i)], str(i * 10))


def test_iterator():
    words = list[String]()
    words.append("hello")
    words.append("world")
    words.append("hello")
    words.append("there")

    counter = dict[HashableStr, Int]()
    for word in words:
        counter[word] = counter.get(word, 0) + 1

    idx = 0
    for key_value in counter.items():
        idx += 1
        if key_value.key == "hello":
            assert_equal(key_value.value, 2)
        elif key_value.key == "world":
            assert_equal(key_value.value, 1)
        elif key_value.key == "there":
            assert_equal(key_value.value, 1)
        else:
            raise Error("Unexpected key" + str(key_value.key))

    assert_equal(idx, 3)


def run_tests():
    test_simple_dict_usage_int()
    test_lots_of_insersion_and_deletion_int()
    test_simple_dict_usage_str()
    test_lots_of_insersion_and_deletion_str()
    test_lots_of_insersion_and_deletion_str_interleaved()
    test_iterator()
