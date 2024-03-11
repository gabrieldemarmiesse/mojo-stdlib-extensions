fn divmod(a: Int, b: Int) -> Tuple[Int, Int]:
    return a // b, a % b


fn divmod(a: Int64, b: Int64) -> Tuple[Int64, Int64]:
    return a // b, a % b


fn modf(x: Float64) -> Tuple[Float64, Float64]:
    var floor = math.trunc(x)
    return (x - floor, floor)
