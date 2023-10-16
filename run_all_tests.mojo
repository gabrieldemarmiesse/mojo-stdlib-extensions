from stdlib_extensions.stdlib_tests.builtins import test_string, test_list, test_bytes
from stdlib_extensions.stdlib_tests.datetime import classes
from stdlib_extensions.stdlib_tests.pathlib import test_path
from stdlib_extensions.stdlib_tests.os import test_process


def main():
    test_string.run_tests()
    test_list.run_tests()
    test_bytes.run_tests()
    classes.run_tests()
    test_process.run_tests()
    test_path.run_tests()
    print("All tests passed! 🔥🎉🔥")
