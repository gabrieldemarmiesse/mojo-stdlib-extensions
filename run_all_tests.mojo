from stdlib_extensions.stdlib_tests.builtins import test_string, test_list
from stdlib_extensions.stdlib_tests.datetime import classes


def main():
    test_string.run_tests()
    test_list.run_tests()
    classes.run_tests()
    print("All tests passed! 🔥🎉🔥")
