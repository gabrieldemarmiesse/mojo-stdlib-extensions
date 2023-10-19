from ._list import list
from ._bytes import bytes
from ..syscalls.filesystem import read_from_stdin


fn input(prompt: String) raises -> String:
    print(prompt)
    return input()

fn input() raises -> String:
    return read_from_stdin()
