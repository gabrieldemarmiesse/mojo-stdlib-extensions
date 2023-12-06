"""This is an implementation of dict taken from the 
awesome https://github.com/mzaks/mojo-hash"""

from memory import memset_zero, memcpy
from ._hash import hash, HashableCollectionElement
from ._generic_list import list


struct dict[K: HashableCollectionElement, V: CollectionElement](Sized):
    var keys: list[K]
    var values: list[V]
    var key_map: list[Int]
    var deleted_mask: DTypePointer[DType.uint8]
    var count: Int
    var capacity: Int

    fn __init__(inout self):
        self.count = 0
        self.capacity = 16
        self.keys = list[K]()
        self.values = list[V]()
        self.key_map = list[Int]()
        for i in range(self.capacity):
            self.key_map.append(0)
        self.deleted_mask = DTypePointer[DType.uint8].alloc(self.capacity >> 3)
        memset_zero(self.deleted_mask, self.capacity >> 3)

    fn __setitem__(inout self, key: K, value: V):
        if self.count / self.capacity >= 0.8:
            self._rehash()

        self._put(key, value, -1)

    fn _rehash(inout self):
        let old_mask_capacity = self.capacity >> 3
        self.capacity *= 2
        let mask_capacity = self.capacity >> 3
        self.key_map = list[Int]()
        for i in range(self.capacity):
            self.key_map.append(0)

        let _deleted_mask = DTypePointer[DType.uint8].alloc(mask_capacity)
        memset_zero(_deleted_mask, mask_capacity)
        memcpy(_deleted_mask, self.deleted_mask, old_mask_capacity)
        self.deleted_mask.free()
        self.deleted_mask = _deleted_mask

        for i in range(len(self.keys)):
            self._put(self.keys.unchecked_get(i), self.values.unchecked_get(i), i + 1)

    fn _put(inout self, key: K, value: V, rehash_index: Int):
        let key_hash = hash(key)
        let modulo_mask = self.capacity - 1
        var key_map_index = int(key_hash & modulo_mask)
        while True:
            let key_index = int(self.key_map.unchecked_get(index=key_map_index))
            if key_index == 0:
                let new_key_index: Int
                if rehash_index == -1:
                    self.keys.append(key)
                    self.values.append(value)
                    self.count += 1
                    new_key_index = len(self.keys)
                else:
                    new_key_index = rehash_index
                self.key_map.unchecked_set(key_map_index, new_key_index)
                return

            let other_key = self.keys.unchecked_get(key_index - 1)
            if other_key == key:
                self.values.unchecked_set(key_index - 1, value)
                if self._is_deleted(key_index - 1):
                    self.count += 1
                    self._not_deleted(key_index - 1)
                return

            key_map_index = (key_map_index + 1) & modulo_mask

    fn __getitem__(self, key: K) raises -> V:
        let key_hash = hash(key)
        let modulo_mask = self.capacity - 1
        var key_map_index = int(key_hash & modulo_mask)
        while True:
            let key_index = self.key_map.__getitem__(index=key_map_index)
            if key_index == 0:
                raise Error("Key not found")
            let other_key = self.keys.unchecked_get(key_index - 1)
            if other_key == key:
                if self._is_deleted(key_index - 1):
                    raise Error("Key not found")
                return self.values[key_index - 1]
            key_map_index = (key_map_index + 1) & modulo_mask

    fn get(self, key: K, default: V) -> V:
        try:
            return self[key]
        except Error:
            return default

    fn pop(inout self, key: K) raises:
        let key_hash = hash(key)
        let modulo_mask = self.capacity - 1
        var key_map_index = int(key_hash & modulo_mask)
        while True:
            let key_index = self.key_map.__getitem__(index=key_map_index)
            if key_index == 0:
                raise Error("KeyError, key not found.")
            let other_key = self.keys.unchecked_get(key_index - 1)
            if other_key == key:
                self.count -= 1
                return self._deleted(key_index - 1)
            key_map_index = (key_map_index + 1) & modulo_mask

    @always_inline
    fn _deleted(self, index: Int):
        let offset = index // 8
        let bit_index = index % 8
        self.deleted_mask[offset] = self.deleted_mask[offset] | (1 << bit_index)

    @always_inline
    fn _is_deleted(self, index: Int) -> Bool:
        let offset = index // 8
        let bit_index = index % 8
        return self.deleted_mask[offset] & (1 << bit_index) != 0

    @always_inline
    fn _not_deleted(self, index: Int):
        let offset = index // 8
        let bit_index = index % 8
        self.deleted_mask[offset] = self.deleted_mask[offset] & ~(1 << bit_index)

    fn __len__(self) -> Int:
        return self.count
