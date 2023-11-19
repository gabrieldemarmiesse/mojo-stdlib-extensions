from ..utils import assert_equal
from ...uuid import UUID
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


def test_uuid_class_version():
    # version 1
    assert_equal(UUID("4c123f5a-86fa-11ee-a8d0-c3f648e463f5").version(), 1)

    # version 3
    assert_equal(UUID("a3b9a1b0-8a53-4239-94cb-59bd25191542").version(), 3)

    # version 4
    assert_equal(UUID("4d3a88c7-8a53-4239-94cb-59bd25191542").version(), 4)

    # version 5
    assert_equal(UUID("a3b9a1b0-8a53-5239-94cb-59bd25191542").version(), 5)


def run_tests():
    test_uuid_class_no_version()
    test_uuid_class_version()
