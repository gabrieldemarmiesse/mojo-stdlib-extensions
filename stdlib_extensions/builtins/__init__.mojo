from ._generic_list import list_to_str
from ._bytes import bytes, to_bytes
from ..syscalls.filesystem import read_from_stdin
from ._hash import custom_hash
from ._types import Optional
from ._math import divmod, modf
from ._custom_equality import ___eq__


fn input(prompt: String) -> String:
    print(prompt, end="")
    return input()


fn input() -> String:
    return read_from_stdin()[:-1]  # we remove the trailing newline


fn hex(x: UInt8) -> String:
    var hex_table: String = "0123456789abcdef"
    return "0x" + hex_table[(x >> 4).to_int()] + hex_table[(x & 0xF).to_int()]


fn bool_to_int(x: Bool) -> Int:
    """Since int(x) is not available."""
    if x:
        return 1
    else:
        return 0
