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

    print(ljust("hello world", 20, "*"))
    print(datetime_min().__str__())
    print(datetime_max().__str__())


```
