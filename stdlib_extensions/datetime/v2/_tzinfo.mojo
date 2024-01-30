trait tzinfo(CollectionElement):
    """Abstract base class for time zone info classes.

    Subclasses must override the tzname(), utcoffset(), dst(), and fromutc() methods.
    """

    fn tzname(self, dt: datetime) -> String:
        """Name of time zone."""
        ...

    fn utcoffset(self, dt: datetime) -> timedelta:
        """Positive for east of UTC, negative for west of UTC."""
        ...

    fn dst(self, dt: datetime) -> timedelta:
        """From datetime -> DST offset as timedelta, positive for east of UTC.

        Return 0 if DST not in effect.  utcoffset() must include the DST
        offset.
        """
        ...

    # fn fromutc(self: Self, dt: datetime) -> datetime[Self]:
    #    # use the default function below
    #    ...


# def fromutc[T: tzinfo](self: T, dt: datetime[T]) -> datetime:
#    """From datetime in UTC to datetime in local time."""
#    if dt.tzinfo is not self:
#        raise ValueError("dt.tzinfo is not self")
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
