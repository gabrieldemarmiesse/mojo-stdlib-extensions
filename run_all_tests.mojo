from stdlib_extensions.stdlib_tests.datetime import test_utils

from stdlib_extensions import datetime as dt



def run_each_module():
    test_utils.run_tests()


def main():
    test_suite_start_time = dt.datetime.now()
    run_each_module()
    test_suite_end_time = dt.datetime.now()

    print(
        "All tests passed in "
        + (test_suite_end_time - test_suite_start_time).__repr__()
        + "! 🔥🎉🔥"
    )
