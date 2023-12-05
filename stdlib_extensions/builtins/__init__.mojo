from ._generic_list import list, list_to_str
from ._bytes import bytes, to_bytes
from ..syscalls.filesystem import read_from_stdin
from ._hash import hash, Hashable, HashableCollectionElement


fn input(prompt: String) raises -> String:
    print_no_newline(prompt)
    return input()


fn input() raises -> String:
    return read_from_stdin()[:-1]  # we remove the trailing newline


fn hex(x: UInt8) -> String:
    alias hex_table: String = "0123456789abcdef"
    return "0x" + hex_table[(x >> 4).to_int()] + hex_table[(x & 0xF).to_int()]
