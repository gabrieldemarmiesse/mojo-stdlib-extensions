from stdlib_extensions.stdlib_tests.builtins import test_string, test_list, test_bytes
from stdlib_extensions.stdlib_tests.datetime import test_classes
from stdlib_extensions.stdlib_tests.pathlib import test_path
from stdlib_extensions.stdlib_tests.os import test_process
from stdlib_extensions import datetime as dt


def run_each_module():
    test_string.run_tests()
    test_list.run_tests()
    test_bytes.run_tests()
    test_classes.run_tests()
    test_process.run_tests()
    test_path.run_tests()


def main():
    test_suite_start_time = dt.datetime.now()
    run_each_module()
    test_suite_end_time = dt.datetime.now()

    print(
        "All tests passed in "
        + (test_suite_end_time - test_suite_start_time).__repr__()
        + "! 🔥🎉🔥"
    )
