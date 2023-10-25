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


def run_tests():
    test_uuid_class_no_version()
