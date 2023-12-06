"""This is an implementation of dict taken from the 
awesome https://github.com/mzaks/mojo-hash"""

from memory import memset_zero, memcpy
from ._hash import hash, HashableCollectionElement
from ._generic_list import list

alias EMPTY_BUCKET = -1


struct dict[K: HashableCollectionElement, V: CollectionElement](Sized):
    var keys: list[K]
    var values: list[V]
    var key_map: list[Int]
    var deleted_mask: DTypePointer[DType.bool]
    var count: Int
    var capacity: Int

    fn __init__(inout self):
        self.count = 0
        self.capacity = 16
        self.keys = list[K]()
        self.values = list[V]()
        self.key_map = list[Int]()
        self.deleted_mask = DTypePointer[DType.bool].alloc(self.capacity)
        memset_zero(self.deleted_mask, self.capacity)
        self._initialize_key_map(self.capacity)

    fn __setitem__(inout self, key: K, value: V):
        if self.count / self.capacity >= 0.8:
            self._rehash()

        self._put(key, value, -1)

    fn _initialize_key_map(inout self, size: Int):
        self.key_map.clear()
        for i in range(size):
            self.key_map.append(EMPTY_BUCKET)  # -1 means unused

    fn _make_deleted_mask_bigger(inout self, old_size: Int, new_size: Int):
        let _deleted_mask = DTypePointer[DType.bool].alloc(new_size)
        memset_zero(_deleted_mask, new_size)
        memcpy(_deleted_mask, self.deleted_mask, old_size)
        self.deleted_mask.free()
        self.deleted_mask = _deleted_mask

    fn _rehash(inout self):
        let old_mask_capacity = self.capacity
        self.capacity *= 2
        self._initialize_key_map(self.capacity)

        self._make_deleted_mask_bigger(old_mask_capacity, self.capacity)

        for i in range(len(self.keys)):
            self._put(self.keys.unchecked_get(i), self.values.unchecked_get(i), i)

    fn _put(inout self, key: K, value: V, rehash_index: Int):
        let key_hash = hash(key)
        let modulo_mask = self.capacity
        var key_map_index = key_hash % modulo_mask
        while True:
            let key_index = self.key_map.unchecked_get(index=key_map_index)
            if key_index == EMPTY_BUCKET:
                let new_key_index: Int
                if rehash_index == -1:
                    self.keys.append(key)
                    self.values.append(value)
                    self.count += 1
                    new_key_index = len(self.keys) - 1
                else:
                    new_key_index = rehash_index
                self.key_map.unchecked_set(key_map_index, new_key_index)
                return

            let existing_key = self.keys.unchecked_get(key_index)
            if existing_key == key:
                self.values.unchecked_set(key_index, value)
                if self.deleted_mask[key_index]:
                    self.count += 1
                    self.deleted_mask[key_index] = False
                return

            key_map_index = (key_map_index + 1) % modulo_mask

    fn __getitem__(self, key: K) raises -> V:
        let key_hash = hash(key)
        let modulo_mask = self.capacity
        var key_map_index = key_hash % modulo_mask
        while True:
            let key_index = self.key_map.__getitem__(index=key_map_index)
            if key_index == EMPTY_BUCKET:
                raise Error("Key not found")
            let other_key = self.keys.unchecked_get(key_index)
            if other_key == key:
                if self.deleted_mask[key_index]:
                    raise Error("Key not found")
                return self.values[key_index]
            key_map_index = (key_map_index + 1) % modulo_mask

    fn get(self, key: K, default: V) -> V:
        try:
            return self[key]
        except Error:
            return default

    fn pop(inout self, key: K) raises:
        let key_hash = hash(key)
        let modulo_mask = self.capacity
        var key_map_index = key_hash % modulo_mask
        while True:
            let key_index = self.key_map.__getitem__(index=key_map_index)
            if key_index == EMPTY_BUCKET:
                raise Error("KeyError, key not found.")
            let other_key = self.keys.unchecked_get(key_index)
            if other_key == key:
                self.count -= 1
                self.deleted_mask[key_index] = True
                return
            key_map_index = (key_map_index + 1) % modulo_mask

    fn __len__(self) -> Int:
        return self.count
