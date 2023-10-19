from ._list import list
from ._bytes import bytes
from ..syscalls.filesystem import read_from_stdin


fn input(prompt: String) raises -> String:
    print_no_newline(prompt)
    return input()


fn input() raises -> String:
    return read_from_stdin()[:-1]  # we remove the trailing newline
