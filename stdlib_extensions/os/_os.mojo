from ..syscalls import process, filesystem
from pathlib import Path


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
