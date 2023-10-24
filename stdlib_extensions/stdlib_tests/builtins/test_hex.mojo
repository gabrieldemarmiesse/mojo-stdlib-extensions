from ...builtins import hex
from ..utils import assert_equal


def test_convert_uint8_to_hex():
    assert_equal(hex(0), "0x00")
    assert_equal(hex(1), "0x01")
    assert_equal(hex(15), "0x0f")
    assert_equal(hex(16), "0x10")
    assert_equal(hex(255), "0xff")
    assert_equal(hex(200), "0xc8")
    assert_equal(hex(0x34), "0x34")


def run_tests():
    test_convert_uint8_to_hex()
