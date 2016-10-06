import math

TREE_MR = 0.2
BM_LVL = None
ENL_LVL = 4

BASE_RESERV = (1 - TREE_MR)
ENL_LEVELS = {
	1: 1,
	2: 0.96,
	3: 0.92,
	4: 0.88,
	5: 0.84
}
BM_LEVELS = {
	None: 1,
	20: 1.96,
	21: 1.93,
	22: 1.9
}


def ca(base_m):
	res = math.ceil(math.floor(base_m * ENL_LEVELS[ENL_LVL] * BM_LEVELS[BM_LVL]) * BASE_RESERV)
	print("{} = {}".format(base_m, res))
	return res


#96
print(ca(25)+ca(50)+ca(50))

