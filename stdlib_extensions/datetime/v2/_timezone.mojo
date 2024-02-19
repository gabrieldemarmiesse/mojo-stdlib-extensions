from ...builtins._types import Optional
from ...builtins.string import rjust
from ._timedelta import timedelta
from ._datetime import datetime
from ._tzinfo import tzinfo


@value
struct timezone(CollectionElement, Stringable, Hashable, tzinfo):
    var _offset: timedelta
    var _name: Optional[String]

    alias _maxoffset = timedelta(hours=24, microseconds=-1)
    alias _minoffset = -timezone._maxoffset
    alias utc = timezone(timedelta(0), None)

    # bpo-37642: These attributes are rounded to the nearest minute for backwards
    # compatibility, even though the constructor will accept a wider range of
    # values. This may change in the future.
    alias min = timezone(-timedelta(hours=23, minutes=59))
    alias max = timezone(timedelta(hours=23, minutes=59))

    fn __init__(inout self, offset: timedelta, name: Optional[String] = None):
        # if not cls._minoffset <= offset <= cls._maxoffset:
        #     raise ValueError("offset must be a timedelta "
        #                      "strictly between -timedelta(hours=24) and "
        #                      "timedelta(hours=24).")
        self._offset = offset
        self._name = name

    fn __eq__(self, other: timezone) -> Bool:
        return self._offset == other._offset

    fn __hash__(self) -> Int:
        return self._offset.__hash__()

    fn __repr__(self) -> String:
        """Convert to formal string, for repr().

        >>> tz = timezone.utc
        >>> repr(tz)
        'datetime.timezone.utc'
        >>> tz = timezone(timedelta(hours=-5), 'EST')
        >>> repr(tz)
        "datetime.timezone(datetime.timedelta(-1, 68400), 'EST')"
        """
        if self == timezone.utc:
            return "datetime.timezone.utc"

        var result: String = "datetime.timezone(" + self._offset.__repr__()
        if self._name is not None:
            result += ", " + self._name.value()
        return result + ")"

    fn __str__(self) -> String:
        return self._tzname_str()

    fn utcoffset(self, dt: Optional[datetime]) -> Optional[timedelta]:
        return self._offset

    fn _tzname_str(self) -> String:
        if self._name is None:
            return self._name_from_offset(self._offset)
        else:
            return self._name.value()

    fn tzname(self, dt: Optional[datetime]) -> Optional[String]:
        return self._tzname_str()

    fn dst(self, dt: Optional[datetime]) -> Optional[timedelta]:
        return None

    fn fromutc(self, dt: datetime) -> datetime:
        # T is Self
        return dt + self._offset

    @staticmethod
    fn _name_from_offset(owned delta: timedelta) -> String:
        if not delta:
            return "UTC"
        var sign: String
        if delta < timedelta(0):
            sign = "-"
            delta = -delta
        else:
            sign = "+"
        # can use divmod later when we support non-register-passable for Tuple
        var hours = delta // timedelta(hours=1)
        var rest = delta % timedelta(hours=1)
        var minutes = rest // timedelta(minutes=1)
        rest = rest % timedelta(minutes=1)
        var seconds = rest.seconds
        var microseconds = rest.microseconds
        var result = "UTC" + sign + rjust(str(hours), 2, "0") + ":" + rjust(
            str(minutes), 2, "0"
        )
        if seconds or microseconds:
            result += ":" + rjust(str(seconds), 2, "0")
        if microseconds:
            result += "." + rjust(str(microseconds), 6, "0")
        return result


alias UTC = timezone.utc
