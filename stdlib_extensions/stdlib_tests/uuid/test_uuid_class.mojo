from ..utils import assert_equal, assert_true, assert_false
from ...uuid import UUID, RFC_4122
from ...builtins import bytes


def test_uuid_class_no_version():
    assert_equal(
        UUID(bytes=bytes(16)).__str__(), "00000000-0000-0000-0000-000000000000"
    )
    assert_equal(
        UUID("76fb1595-8b2f-456a-b809-bc2e00c70a45").__str__(),
        "76fb1595-8b2f-456a-b809-bc2e00c70a45",
    )

    some_uuid = UUID("162bb388-b33a-1fe3-be31-7e5993496eb8")
    assert_equal(some_uuid.__str__(), "162bb388-b33a-1fe3-be31-7e5993496eb8")
    corresponding_bytes = some_uuid.bytes()
    assert_equal(corresponding_bytes.__len__(), 16)
    assert_equal(UUID(corresponding_bytes).__str__(), some_uuid.__str__())

    assert_equal(
        UUID("76fb1595-8b2f-456a-b809-bc2e00c70a45").__repr__(),
        "UUID('76fb1595-8b2f-456a-b809-bc2e00c70a45')",
    )


def test_uuid_class_version_1():
    some_uuid = UUID("4c123f5a-86fa-11ee-a8d0-c3f648e463f5")
    assert_equal(some_uuid.variant(), RFC_4122)
    assert_equal(some_uuid.version(), 1)


def test_uuid_class_version_3():
    some_uuid = UUID("a3b9a1b0-8a53-3239-94cb-59bd25191542")
    assert_equal(some_uuid.variant(), RFC_4122)
    assert_equal(some_uuid.version(), 3)


def test_uuid_class_version_4():
    some_uuid = UUID("4d3a88c7-8a53-4239-94cb-59bd25191542")
    assert_equal(some_uuid.variant(), RFC_4122)
    assert_equal(some_uuid.version(), 4)


def test_uuid_class_version_5():
    some_uuid = UUID("a3b9a1b0-8a53-5239-94cb-59bd25191542")
    assert_equal(some_uuid.variant(), RFC_4122)
    assert_equal(some_uuid.version(), 5)


def test_order():
    assert_true(
        UUID("00000000-0000-0000-0000-000000000000")
        < UUID("00000000-0000-0000-0000-000000000001"),
        "not less",
    )
    assert_false(
        UUID("00000000-0000-0000-0000-000000000000")
        > UUID("00000000-0000-0000-0000-000000000001"),
        "not greater",
    )
    assert_true(
        UUID("00000000-0000-0000-0000-000000000000")
        <= UUID("00000000-0000-0000-0000-000000000001"),
        "not less or equal",
    )
    assert_false(
        UUID("00000000-0000-0000-0000-000000000000")
        >= UUID("00000000-0000-0000-0000-000000000001"),
        "not greater or equal",
    )
    assert_true(
        UUID("00000000-0000-0000-0000-000000000000")
        == UUID("00000000-0000-0000-0000-000000000000"),
        "not equal",
    )
    assert_false(
        UUID("00000000-0000-0000-0000-000000000000")
        != UUID("00000000-0000-0000-0000-000000000000"),
        "not not equal",
    )

    assert_true(
        UUID("e0000000-0000-0000-0000-000000000000")
        < UUID("f0000000-0000-0000-0000-000000000000"),
        "not less",
    )
    assert_false(
        UUID("e0000000-0000-0000-0000-000000000000")
        > UUID("f0000000-0000-0000-0000-000000000000"),
        "not greater",
    )
    assert_true(
        UUID("e0000000-0000-0000-0000-000000000000")
        <= UUID("f0000000-0000-0000-0000-000000000000"),
        "not less or equal",
    )
    assert_false(
        UUID("e0000000-0000-0000-0000-000000000000")
        >= UUID("f0000000-0000-0000-0000-000000000000"),
        "not greater or equal",
    )
    assert_true(
        UUID("e0000000-0000-0000-0000-000000000000")
        == UUID("e0000000-0000-0000-0000-000000000000"),
        "not equal",
    )
    assert_false(
        UUID("e0000000-0000-0000-0000-000000000000")
        != UUID("e0000000-0000-0000-0000-000000000000"),
        "not not equal",
    )


def run_tests():
    test_uuid_class_no_version()
    test_uuid_class_version_1()
    test_uuid_class_version_3()
    test_uuid_class_version_4()
    test_uuid_class_version_5()
    test_order()
