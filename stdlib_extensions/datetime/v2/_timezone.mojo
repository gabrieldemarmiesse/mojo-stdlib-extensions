from ...builtins import Optional
from ._timedelta import timedelta


@value
struct timezone:
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

    # TODO: remove inout and make it Hashable
    fn __hash__(inout self) -> Int:
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
        return self.tzname(None)

    fn utcoffset(self, dt: Optional[datetime]) -> timedelta:
        return self._offset

    fn tzname(self, dt: Optional[datetime]) -> String:
        if self._name is None:
            return self._name_from_offset(self._offset)
        else:
            return self._name.value()

    fn dst(self, dt: Optional[datetime]) -> None:
        return None

    # fn fromutc(self, dt: datetime) -> datetime:
    #    #if dt.tzinfo is not self:
    #    #    raise ValueError("fromutc: dt.tzinfo "
    #    #                     "is not self")
    #    return dt + self._offset

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
        try:
            var result = "UTC" + sign + rjust(str(hours), 2, "0") + ":" + rjust(
                str(minutes), 2, "0"
            )
            if seconds or microseconds:
                result += ":" + rjust(str(seconds), 2, "0")
            if microseconds:
                result += "." + rjust(str(microseconds), 6, "0")
            return result
        except Error:
            # should never happen
            return "unknown error in _name_from_offset"


alias UTC = timezone.utc
