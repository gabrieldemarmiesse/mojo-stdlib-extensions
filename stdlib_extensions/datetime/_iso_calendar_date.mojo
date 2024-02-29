@value
struct IsoCalendarDate:
    var year: Int
    var week: Int
    var weekday: Int

    fn __getitem__(self, index: Int) -> Int:
        if index == 0:
            return self.year
        elif index == 1:
            return self.week
        elif index == 2:
            return self.weekday
        else:
            # raise error here
            return 0

    fn __len__(self) -> Int:
        return 3

    def __repr__(self) -> String:
        return (
            "IsoCalendarDate(year="
            + str(self[0])
            + ", week="
            + str(self[1])
            + ", weekday="
            + str(self[2])
            + ")"
        )
