from ..syscalls import process, filesystem
from ..syscalls import random as syscalls_random
from pathlib import Path
from ..builtins import bytes


fn getpid() -> Int:
    return process.getpid().to_int()


fn fspath(path: String) -> String:
    return path


fn fspath(path: StringLiteral) -> String:
    return String(path)


fn fspath(path: Path) -> String:
    # should actually return __fspath__ but we don't have that yet
    return path.__str__()


fn rmdir(path: String) raises:
    return filesystem.rmdir(path)


fn rmdir(path: StringLiteral) raises:
    return rmdir(fspath(path))


fn rmdir(path: Path) raises:
    return rmdir(fspath(path))


fn unlink(path: String) raises:
    return filesystem.unlink(path)


fn unlink(path: StringLiteral) raises:
    return unlink(fspath(path))


fn unlink(path: Path) raises:
    return unlink(fspath(path))


fn urandom(size: Int) raises -> bytes:
    # TODO: we currently use the getrandom syscalls, but it will work only in linux.
    # to be compatible with other systems, we should follow what cpython does, which is by order
    # of priority:
    # BCryptGenRandom() on Windows
    # getrandom() function (ex: Linux and Solaris)
    # getentropy() function (ex: OpenBSD)
    # /dev/urandom device

    return syscalls_random.getrandom(size)
