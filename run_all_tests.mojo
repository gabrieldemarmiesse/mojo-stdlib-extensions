from stdlib_extensions.builtins import list


@value
struct datetime(CollectionElement):
    var _dummy: Int

    fn __init__(
        inout self,
    ):
        self._dummy = 0

    fn __repr__(self) -> String:
        """Convert to formal string, for repr()."""
        var result: String = "datetime.datetime("
        var components = list[String].from_values("a", "b")
        for _ in range(2):
            if components[-1] == "0":
                components.pop()
        return result


def main():
    print(datetime().__repr__())
