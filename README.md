# mojo-stdlib-extensions
A replica of python's stdlib in mojo


```python
from stdlib_extensions.datetime import datetime, timedelta
from stdlib_extensions.builtins.string import rjust, ljust, endswith
from stdlib_extensions.builtins import list

def main():
    now = datetime.now()
    print(now.__str__())
    print(now.__repr__())
    print(now.year())
    print(now.month())
    print(now.day())
    print(now.hour())
    print(now.second())
    print(now.microsecond())

    time_elapsed = datetime.now() - now
    
    print(time_elapsed.total_seconds())

    print(rjust("hello world", 20, "*"))
    print(datetime.min().__str__())
    print(datetime.max().__str__())

    # only String is supported at the moment. And they are copied in the list.
    # If you want Ints, use utils.vector in the mojo standard library
    my_list = list[String]()
    my_list.append("hello")
    my_list.append("world")
    print(my_list.__str__())
    print(my_list[0])
    print(my_list[:1].__str__())
```

Refer to the python documention for the documentation of those functions.


### Complete list of what is available here:

```python
stdlib_extensions.os.getpid
stdlib_extensions.os.fspath
stdlib_extensions.os.rmdir

stdlib_extensions.builtins.string.rjust
stdlib_extensions.builtins.string.ljust
stdlib_extensions.builtins.string.endswith
stdlib_extensions.builtins.string.split

stdlib_extensions.builtins.list # only with String for now

stdlib_extensions.datetime.datetime
stdlib_extensions.datetime.timedelta
```


### Features missing from mojo to have a perfect replica of the api:
* `@property` decorator
* struct attributes
* a good list


### Features missing from mojo to improve code readability:
* `String.__mul__()`
* f-strings
* subclassing struct
* absolute imports working with `mojo package`

### Contributing:

Any function from the Python stdlib is welcome. Make sure to have the same signatures and apis
(or as close as possible if mojo doesn't support something yet).

Run the tests with `mojo run_all_tests.mojo`.
Reformat with `mojo format ./`.

You can also use the pre-commit hook if you don't want to run manually `mojo format ./` before each commit.

```bash
pip install pre-commit
pre-commit install
```
