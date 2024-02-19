from ...builtins._types import Optional
from ._datetime import datetime


trait tzinfo(CollectionElement):
    """Abstract base class for time zone info classes.

    Subclasses must override the tzname(), utcoffset(), dst(), and fromutc() methods.
    """

    fn tzname(self, dt: Optional[datetime]) -> Optional[String]:
        """Name of time zone."""
        # T is Self
        ...

    fn utcoffset(self, dt: Optional[datetime]) -> Optional[timedelta]:
        """Positive for east of UTC, negative for west of UTC."""
        # T is Self
        ...

    fn dst(self, dt: Optional[datetime]) -> Optional[timedelta]:
        """From datetime -> DST offset as timedelta, positive for east of UTC.

        Return 0 if DST not in effect.  utcoffset() must include the DST
        offset.
        """
        # T is Self
        ...

    fn fromutc(self, dt: datetime) -> datetime:
        # use the default function below
        # T is Self
        ...


# def fromutc[T: tzinfo](self: T, dt: datetime[T]) -> datetime[T]:
#    """From datetime in UTC to datetime in local time."""
#    dtoff = dt.utcoffset()
#    if dtoff is None:
#        raise ValueError("fromutc() requires a non-None utcoffset() "
#                         "result")
#    # See the long comment block at the end of this file for an
#    # explanation of this algorithm.
#    dtdst = dt.dst()
#    if dtdst is None:
#        raise ValueError("fromutc() requires a non-None dst() result")
#    delta = dtoff - dtdst
#    if delta:
#        dt += delta
#        dtdst = dt.dst()
#        if dtdst is None:
#            raise ValueError("fromutc(): dt.dst gave inconsistent "
#                             "results; cannot convert")
#    return dt + dtdst
#
#    # Pickle support.
#
#    def __reduce__(self):
#        getinitargs = getattr(self, "__getinitargs__", None)
#        if getinitargs:
#            args = getinitargs()
#        else:
#            args = ()
#        return (self.__class__, args, self.__getstate__())
#
