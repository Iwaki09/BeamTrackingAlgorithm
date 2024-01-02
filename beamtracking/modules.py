import parameters

class Unit:
    def __init__(self, n_elx, n_elz):
        self.n_elx = n_elx
        self.n_elz = n_elz
        self.n_elall = n_elx * n_elz

        self.dx = parameters.LMD / 2
        self.dz = parameters.LMD / 2
        self.ox = 0
        self.oz = 0


class DU(Unit):
    def __init__(self, n_elx, n_elz, ptx):
        super().__init__(n_elx, n_elz)
        # 送信電力
        self.ptx = 

class RU(Unit):
    def __init__(self, n_elx, n_elz):
        super().__init__(n_elx, n_elz)