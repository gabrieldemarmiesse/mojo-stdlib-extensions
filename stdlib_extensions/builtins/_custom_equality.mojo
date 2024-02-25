from ..datetime.v2 import time, timedelta

# TODO: move those to __eq__ of the corresponding type when we have conditional traits


fn ___eq__(left: Optional[time], right: Optional[time]) -> Bool:
    if left is None and right is None:
        return True
    if left is not None and right is not None:
        return left.value() == right.value()
    return False


fn ___eq__(left: Optional[timedelta], right: Optional[timedelta]) -> Bool:
    if left is None and right is None:
        return True
    if left is not None and right is not None:
        return left.value() == right.value()
    return False
