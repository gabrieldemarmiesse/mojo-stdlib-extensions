from .. import datetime as dt
from ._utils import ymd2ord, MAXORDINAL, _check_date_fields, _check_time_fields
from ..builtins import divmod, list
from ..builtins._types import Optional
from .._utils import custom_debug_assert
from ._utils import (
    _check_utc_offset,
    _check_time_fields,
    _build_struct_time,
)
from ..time import struct_time
from ..builtins.string import join
from utils.variant import Variant
from python import Python
from ..syscalls.clocks import clock_gettime
from ..builtins import custom_hash


# TODO: time methods must be transferred to datetime

alias _EPOCH = datetime(1970, 1, 1, tzinfo=dt.timezone(dt.timedelta(0)))


@value
struct datetime(CollectionElement):
    #    """datetime(year, month, day[, hour[, minute[, second[, microsecond[,tzinfo]]]]])
    #
    #    The year, month and day arguments are required. tzinfo may be None, or an
    #    instance of a tzinfo subclass. The remaining arguments may be ints.
    #    """
    var year: Int
    var month: Int
    var day: Int
    var hour: Int
    var minute: Int
    var second: Int
    var microsecond: Int
    # TODO: use the trait tzinfo instead.
    # traits are too strict right now to do what we want here.

    # this is to avoid conflicting with the @value constructor
    # TODO: remove when https://github.com/modularml/mojo/issues/1705 is fixed
    var _dummy: Int

    alias min = datetime(1, 1, 1)
    alias max = datetime(9999, 12, 31, 23, 59, 59, 999999)
    alias resolution = dt.timedelta(microseconds=1)

    fn __init__(
        inout self,
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 0,
        minute: Int = 0,
        second: Int = 0,
        microsecond: Int = 0,
    ):
        # _check_date_fields(year, month, day)
        self.year = year
        self.month = month
        self.day = day
        self.hour = hour
        self.minute = minute
        self.second = second
        self.microsecond = microsecond
        # TODO: remove when https://github.com/modularml/mojo/issues/1705 is fixed
        self._dummy = 0

    fn __repr__(self) -> String:
        """Convert to formal string, for repr()."""
        var result: String = "datetime.datetime("
        var components = list[String].from_values(
            str(self.year),
            str(self.month),
            str(self.day),
            str(self.hour),
            str(self.minute),
            str(self.second),
            str(self.microsecond),
        )
        for _ in range(2):
            if components[-1] == "0":
                components.pop()
        return result


@value
struct TzinfoReplacement:
    var _value: Variant[Optional[dt.timezone], Bool]

    fn __init__(inout self, value: Bool):
        self._value = value

    fn __init__(inout self, value: None):
        self._value = Optional[dt.timezone](value)

    fn __init__(inout self, value: dt.timezone):
        self._value = Optional[dt.timezone](value)

    fn get_tzinfo(self) -> Optional[dt.timezone]:
        return self._value.get[Optional[dt.timezone]]()[]

    fn is_bool(self) -> Bool:
        return self._value.isa[Bool]()


fn optional_equal_timedelta(
    a: Optional[dt.timedelta], b: Optional[dt.timedelta]
) -> Bool:
    # remove this when Optional supports __eq__
    if a is None:
        return b is None
    if b is None:
        return False
    return a.value() == b.value()
