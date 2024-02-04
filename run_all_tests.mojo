fn factory[T: CollectionElement](*values: T) -> String:
    return "hello"


alias some_string = factory[Int](46)


fn main():
    var a = some_string[0]
