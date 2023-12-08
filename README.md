# mojo-stdlib-extensions
A replica of python's stdlib in mojo 🔥


```python
from stdlib_extensions.datetime import datetime, timedelta
from stdlib_extensions.builtins.string import rjust
from stdlib_extensions.builtins import list, list_to_str

def main():
    now = datetime.now()
    print(now.__str__())
    print(now.__repr__())
    print(now.year())
    print(now.month())
    ...

    time_elapsed = datetime.now() - now
    
    print(time_elapsed.total_seconds())

    print(rjust("hello world", 20, "*"))
    
    my_list = list[String]()
    my_list.append("hello")
    my_list.append("world")
    print(list_to_str(my_list))
```

Refer to the python documention for the documentation of those functions.

### New! `list` and `dict` are now available!

```python
from stdlib_extensions.builtins import (
    dict, list, HashableInt, HashableStr, HashableCollectionElement
)

def main():
    # since Int and String don't have __hash__ yet, we use the wrapper
    # classes HashableInt and HashableStr instead, there is automatic
    # type conversion between them and the original types.
    # For custom structs, you must implement the trait HashableCollectionElement yourself.

    words = list[String]()
    words.append("hello")
    words.append("world")
    words.append("hello")
    words.append("there")

    counter = dict[HashableStr, Int]()
    for word in words:
        counter[word] = counter.get(word, 0) + 1
    
    for key_value in counter.items():
        print(key_value.key, "was seen" , key_value.value, "times.")
```

### Complete list of what is available here:

```
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

stdlib_extensions.builtins.hex
stdlib_extensions.builtins.to_bytes
stdlib_extensions.builtins.input
stdlib_extensions.builtins.list
-> append, clear, copy, extend, pop, reverse, insert, __len__, __getitem__, 
   unchecked_get, unchecked_set (for performance)
stdlib_extensions.builtins.list_to_str
-> for Int and Strings, because Mojo doesn't support multiple traits for the same type yet

stdlib_extensions.builtins.dict

stdlib_extensions.builtins.bytes
-> __len__, __str__, __getitem__, __setitem__, ==,
   !=, +, *, +=, *=, fromhex, hex

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
