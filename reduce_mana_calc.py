import math

TREE_MR = 0.46+0.02+0.06 +0.15
BM_LVL = None
ENL_LVL = None
MORTAL_CONVICTION = True
BASE_RESERV = (1 - TREE_MR)
ENL_LEVELS = {
	None: 1,
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
	less_mana_res = 1
	if MORTAL_CONVICTION:
		less_mana_res = 0.5
	res = math.ceil(math.floor(base_m * ENL_LEVELS[ENL_LVL] * BM_LEVELS[BM_LVL]) * BASE_RESERV * less_mana_res)
	print("{} = {}".format(base_m, res))
	return res


print(ca(35))

