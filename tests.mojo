from stdlib_extensions.datetime import (
    datetime,
    datetime_min,
    timedelta,
    datetime_now,
    datetime_max,
)
from python import Python
from stdlib_extensions.builtins.string import ljust


def assert_is_equal(a: datetime, b: PythonObject):
    a_repr = a.__repr__()
    b_repr = b.__repr__().to_string()
    if a_repr != b_repr:
        raise Error(
            "object " + a.__repr__() + " not equal to " + b.__repr__().to_string()
        )

    a_str = a.__str__()
    b_str = b.__str__().to_string()
    if a_str != b_str:
        raise Error("object " + a_str + " not equal to " + b_str)


def try_all_functions_available():
    now = datetime_now()
    print(now.__str__())
    print(now.__repr__())
    print(now.year())
    print(now.month())
    print(now.day())
    print(now.hour())
    print(now.second())
    print(now.microsecond())

    time_elapsed = datetime_now() - now

    print(time_elapsed.total_seconds())
    print(ljust("hello world", 20, "*"))
    print(datetime_min().__str__())
    print(datetime_max().__str__())


def main():
    try_all_functions_available()

    py_datetime_module = Python.import_module("datetime")

    var py_dt = py_datetime_module.datetime.min
    var mojo_dt = datetime_min()
    print(datetime_now().__str__())

    for i in range(100_000):
        py_dt = py_dt + py_datetime_module.timedelta(0, 0, i * 100_000)
        mojo_dt = mojo_dt + timedelta(0, 0, i * 100_000)
        assert_is_equal(mojo_dt, py_dt)
