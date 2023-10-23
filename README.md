# mojo-stdlib-extensions
A replica of python's stdlib in mojo 🔥


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
stdlib_extensions.os.unlink
stdlib_extensions.os.urandom

stdlib_extensions.pathlib.Path
-> /, cwd, open, __fspath__, write_text, read_text, unlink, rmdir 

stdlib_extensions.builtins.string.rjust
stdlib_extensions.builtins.string.ljust
stdlib_extensions.builtins.string.endswith
stdlib_extensions.builtins.string.startswith
stdlib_extensions.builtins.string.split
stdlib_extensions.builtins.string.join
stdlib_extensions.builtins.string.replace
stdlib_extensions.builtins.string.removeprefix
stdlib_extensions.builtins.string.removesuffix
stdlib_extensions.builtins.string.expandtabs
stdlib_extensions.builtins.string.rstrip
stdlib_extensions.builtins.string.lstrip
stdlib_extensions.builtins.string.strip

stdlib_extensions.builtins.input
stdlib_extensions.builtins.list # only with String for now
-> append, __len__, __str__, __getitem__

stdlib_extensions.builtins.bytes
-> __len__, __str__, __getitem__, __setitem__, ==,
   !=, +, *, +=, *=

stdlib_extensions.datetime.datetime
-> microsecond, second, minute, ..., year, +, -, now, min, max

stdlib_extensions.datetime.timedelta
-> total_seconds, total_microseconds, microseconds, seconds, days, +, -, /

stdlib_extensions.datetime.time
-> microsecond, second, minute, hour, min, max

stdlib_extensions.datetime.date
-> year, month, day, min, max, today

stdlib_extensions.time.time_ns()
```


### Features missing from mojo to have a perfect replica of the api:
* `__iter__` (we need this badly to avoid indexing errors)
* `@property` decorator
* struct attributes
* a good list


### Features missing from mojo to improve code readability:
* Union types (we need this badly to avoid code duplication)
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
