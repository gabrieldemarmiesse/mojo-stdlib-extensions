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


def test_set_version():
    for i in range(1, 6):
        assert_equal(
            UUID("4c123f5a-86fa-11ee-a8d0-c3f648e463f5", version=i).version(), i
        )
        assert_equal(
            UUID("a3b9a1b0-8a53-3239-94cb-59bd25191542", version=i).version(), i
        )
        assert_equal(
            UUID("4d3a88c7-8a53-4239-94cb-59bd25191542", version=i).version(), i
        )
        assert_equal(
            UUID("a3b9a1b0-8a53-5239-94cb-59bd25191542", version=i).version(), i
        )


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


def test_time_low():
    assert_equal(UUID("4c123f5a-86fa-11ee-a8d0-c3f648e463f5").time_low(), 1276264282)
    assert_equal(UUID("a3b9a1b0-8a53-3239-94cb-59bd25191542").time_low(), 2746851760)
    assert_equal(UUID("d3b9c1b0-8a53-5239-94cb-59bd25191542").time_low(), 3552166320)


def test_time_mid():
    assert_equal(UUID("4c123f5a-86fa-11ee-a8d0-c3f648e463f5").time_mid(), 34554)
    assert_equal(UUID("a3b9a1b0-8a53-3239-94cb-59bd25191542").time_mid(), 35411)
    assert_equal(UUID("d3b9c1b0-8a53-5239-94cb-59bd25191542").time_mid(), 35411)
    assert_equal(UUID("f588b9be-929a-4b15-925f-23c9903b847a").time_mid(), 37530)


def test_time_hi_version():
    assert_equal(UUID("4c123f5a-86fa-11ee-a8d0-c3f648e463f5").time_hi_version(), 4590)
    assert_equal(UUID("a3b9a1b0-8a53-3239-94cb-59bd25191542").time_hi_version(), 12857)
    assert_equal(UUID("d3b9c1b0-8a53-5239-94cb-59bd25191542").time_hi_version(), 21049)
    assert_equal(UUID("f588b9be-929a-4b15-925f-23c9903b847a").time_hi_version(), 19221)


def test_clock_seq_hi_variant():
    assert_equal(
        UUID("4c123f5a-86fa-11ee-a8d0-c3f648e463f5").clock_seq_hi_variant(), 168
    )
    assert_equal(
        UUID("a3b9a1b0-8a53-3239-94cb-59bd25191542").clock_seq_hi_variant(), 148
    )
    assert_equal(
        UUID("d3b9c1b0-8a53-5239-94cb-59bd25191542").clock_seq_hi_variant(), 148
    )
    assert_equal(
        UUID("f588b9be-929a-4b15-925f-23c9903b847a").clock_seq_hi_variant(), 146
    )


def test_clock_seq_low():
    assert_equal(UUID("4c123f5a-86fa-11ee-a8d0-c3f648e463f5").clock_seq_low(), 208)
    assert_equal(UUID("a3b9a1b0-8a53-3239-94cb-59bd25191542").clock_seq_low(), 203)
    assert_equal(UUID("d3b9c1b0-8a53-5239-94cb-59bd25191542").clock_seq_low(), 203)
    assert_equal(UUID("f588b9be-929a-4b15-925f-23c9903b847a").clock_seq_low(), 95)


def test_node():
    assert_equal(UUID("4c123f5a-86fa-11ee-a8d0-c3f648e463f5").node(), 215462552298485)
    assert_equal(UUID("a3b9a1b0-8a53-3239-94cb-59bd25191542").node(), 98668906091842)
    assert_equal(UUID("d3b9c1b0-8a53-5239-94cb-59bd25191542").node(), 98668906091842)
    assert_equal(UUID("f588b9be-929a-4b15-925f-23c9903b847a").node(), 39348615218298)


def test_urn():
    assert_equal(
        UUID("4c123f5a-86fa-11ee-a8d0-c3f648e463f5").urn(),
        "urn:uuid:4c123f5a-86fa-11ee-a8d0-c3f648e463f5",
    )
    assert_equal(
        UUID("a3b9a1b0-8a53-3239-94cb-59bd25191542").urn(),
        "urn:uuid:a3b9a1b0-8a53-3239-94cb-59bd25191542",
    )
    assert_equal(
        UUID("d3b9c1b0-8a53-5239-94cb-59bd25191542").urn(),
        "urn:uuid:d3b9c1b0-8a53-5239-94cb-59bd25191542",
    )
    assert_equal(
        UUID("f588b9be-929a-4b15-925f-23c9903b847a").urn(),
        "urn:uuid:f588b9be-929a-4b15-925f-23c9903b847a",
    )


def run_tests():
    test_uuid_class_no_version()
    test_uuid_class_version_1()
    test_uuid_class_version_3()
    test_uuid_class_version_4()
    test_uuid_class_version_5()
    test_set_version()
    test_order()
    test_time_low()
    test_time_mid()
    test_time_hi_version()
    test_clock_seq_hi_variant()
    test_clock_seq_low()
    test_node()
    test_urn()
