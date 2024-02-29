from stdlib_extensions.stdlib_tests.builtins import (
    test_string,
    test_list,
    test_bytes,
    test_hex,
    test_math,
)
from stdlib_extensions.stdlib_tests.datetime import (
    test_utils,
    test_timedelta,
    test_date,
    test_time_class,
    test_timezone,
    test_datetime,
)
from stdlib_extensions.stdlib_tests.pathlib import test_path
from stdlib_extensions.stdlib_tests.os import test_process
from stdlib_extensions import datetime as dt
from stdlib_extensions.stdlib_tests.time import test_time
from stdlib_extensions.stdlib_tests.uuid import test_uuid_class
from stdlib_extensions.stdlib_tests.builtins import test_dict


def run_each_module():
    print("running tests for dict")
    test_dict.run_tests()
    print("running tests for string")
    test_string.run_tests()
    print("running tests for list")
    test_list.run_tests()
    print("running tests for bytes")
    test_bytes.run_tests()
    print("running tests for hex")
    test_hex.run_tests()
    print("running tests for process")
    test_process.run_tests()
    print("running tests for path")
    test_path.run_tests()
    print("running tests for time")
    test_time.run_tests()
    print("running tests for uuid")
    test_uuid_class.run_tests()
    print("running tests for math")
    test_math.run_tests()
    print("running tests for utils")
    test_utils.run_tests()
    print("running tests for timedelta")
    test_timedelta.run_tests()
    print("running tests for time")
    test_time_class.run_tests()
    print("running tests for date")
    test_date.run_tests()
    print("running tests for timezone")
    test_timezone.run_tests()
    print("running tests for datetime")
    test_datetime.run_tests()


def main():
    test_suite_start_time = dt.datetime.now()
    run_each_module()
    test_suite_end_time = dt.datetime.now()

    print(
        "All tests passed in "
        + (test_suite_end_time - test_suite_start_time).__repr__()
        + "! 🔥🎉🔥"
    )
