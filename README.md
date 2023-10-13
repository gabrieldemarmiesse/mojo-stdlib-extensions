# mojo-stdlib-extensions
A replica of python's stdlib in mojo


```python
from stdlib_extensions.datetime import (
    datetime, 
    datetime_now, 
    datetime_min, 
    datetime_max, 
    timedelta
)
from stdlib_extensions.builtins.string import rjust, ljust, endswith


def main():
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

    print(rjust("hello world", 20, "*"))
    print(datetime_min().__str__())
    print(datetime_max().__str__())
```

Refer to the python documention for the documentation of those functions.

### Features missing from mojo to have a perfect replica of the api:
* `@property` decorator
* struct attributes
* struct staticmethods


### Features missing from mojo to improve code readability:
* `String.__mul__()`
* f-strings
* subclassing struct

### Contributing:

Any function from the Python stdlib is welcome. Make sure to have the same signatures and apis
(or as close as possible if mojo doesn't support something yet).

Run the tests with `mojo run_all_tests.mojo`.
