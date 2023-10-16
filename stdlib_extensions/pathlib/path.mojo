from pathlib import Path as MojoStdPath
from pathlib import cwd
from stdlib_extensions import os


@value
struct Path:
    var mojo_std_path: MojoStdPath

    # here it's just a copy of what's in the stdlib since
    # we can't inherit :(
    fn __init__(inout self: Self) raises -> None:
        self.mojo_std_path = MojoStdPath()

    fn __init__(inout self: Self, path: StringLiteral):
        self.mojo_std_path = MojoStdPath(path)

    fn __init__(inout self: Self, path: MojoStdPath):
        self.mojo_std_path = path

    fn __init__(inout self: Self, path: String):
        self.mojo_std_path = MojoStdPath(path)

    fn __init__(inout self: Self, path: StringRef):
        self.mojo_std_path = MojoStdPath(path)

    fn __truediv__(self: Self, suffix: Self) -> Self:
        return Path(self.mojo_std_path / suffix.mojo_std_path)

    fn __truediv__(self: Self, suffix: StringLiteral) -> Self:
        return Path(self.mojo_std_path / suffix)

    fn __truediv__(self: Self, suffix: StringRef) -> Self:
        return Path(self.mojo_std_path / suffix)

    fn __str__(self: Self) -> String:
        return self.mojo_std_path.__str__()

    fn __repr__(self: Self) -> String:
        return self.mojo_std_path.__repr__()

    @staticmethod
    fn cwd() raises -> Self:
        return Path(cwd())

    # now functions that don't have a direct equivalent in the stdlib
    fn open(self: Self, mode: StringLiteral) raises -> FileHandle:
        return open(self.__str__(), mode)

    fn rmdir(self: Self) raises -> None:
        return os.rmdir(self.__str__())
