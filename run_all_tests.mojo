from stdlib_extensions.stdlib_tests.builtins import test_string, test_list
from stdlib_extensions.stdlib_tests.datetime import classes

# from stdlib_extensions.stdlib_tests.os import test_process


def main():
    test_string.run_tests()
    test_list.run_tests()
    classes.run_tests()
    # test_process.run_tests()
    print("All tests passed! 🔥🎉🔥")
