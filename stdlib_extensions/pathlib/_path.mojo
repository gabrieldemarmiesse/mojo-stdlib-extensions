from pathlib import Path as MojoStdPath
from pathlib import cwd
from ..os import unlink, rmdir
from ..builtins.string import endswith


@value
struct Path:
    var _mojo_std_path: MojoStdPath

    # here it's just a copy of what's in the stdlib since
    # we can't inherit :(
    fn __init__(inout self: Self) raises -> None:
        self._mojo_std_path = MojoStdPath()

    fn __init__(inout self: Self, path: StringLiteral):
        self._mojo_std_path = MojoStdPath(path)

    fn __init__(inout self: Self, path: MojoStdPath):
        self._mojo_std_path = path

    fn __init__(inout self: Self, path: String):
        self._mojo_std_path = MojoStdPath(path)

    fn __init__(inout self: Self, path: StringRef):
        self._mojo_std_path = MojoStdPath(path)

    fn __truediv__(self: Self, suffix: Path) -> Self:
        return self / suffix.__fspath__()

    fn __truediv__(self: Self, suffix: StringLiteral) -> Self:
        return self.__truediv__(String(suffix))

    fn __truediv__(self: Self, suffix: StringRef) -> Self:
        return self.__truediv__(String(suffix))

    fn __truediv__(self: Self, suffix: String) -> Self:
        let ends_with_slash: Bool
        try:
            ends_with_slash = endswith(self.__fspath__(), "/")
        except:
            print(
                "Couldn't call endswith when using Path / . This should never happen."
                " Please report this to"
                " https://github.com/gabrieldemarmiesse/mojo-stdlib-extensions/issues"
            )
            ends_with_slash = False

        if ends_with_slash:
            return Path(self.__fspath__() + suffix)
        else:
            return Path(self.__fspath__() + "/" + suffix)

    fn __fspath__(self) -> String:
        return self._mojo_std_path.__str__()

    fn __str__(self: Self) -> String:
        return self.__fspath__()

    fn __repr__(self: Self) -> String:
        return self.__fspath__()

    @staticmethod
    fn cwd() raises -> Self:
        return Path(cwd())

    # now functions that don't have a direct equivalent in the stdlib
    fn open(self: Self, mode: StringLiteral) raises -> FileHandle:
        return open(self.__str__(), mode)

    # TODO: fuse those when we have unions
    fn write_text(self: Self, text: StringLiteral) raises -> None:
        with self.open("w") as f:
            f.write(text)

    fn write_text(self: Self, text: StringRef) raises -> None:
        with self.open("w") as f:
            f.write(text)

    fn write_text(self: Self, text: String) raises -> None:
        with self.open("w") as f:
            f.write(text)

    fn read_text(self: Self) raises -> String:
        with self.open("r") as f:
            return f.read()

    fn unlink(self: Self) raises -> None:
        return unlink(self.__str__())

    fn rmdir(self: Self) raises -> None:
        return rmdir(self.__str__())
