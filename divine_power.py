skill_value = {
	"proj":  4,
	"life": 10,
	"cri": 6,
	"as": 12,
}

armour_max_value = {
	"proj":  2,
	"life": 2,
	"cri": 3,
	"as": 2,
}

current_value = {
	"proj":  1,
	"life": 0,
	"cri": 3,
	"as": 2,
}

sum = 0
for k in skill_value.keys():
	s = skill_value[k]/armour_max_value[k] * current_value[k]
	print("%s: %d/%d = %0.2f" % (k, current_value[k], armour_max_value[k], s))
	sum += s
m = 0
for k in skill_value:
	m += skill_value[k]
print("RESULT: %0.2f/%0.2f = %d%%" % (sum, m, sum/m * 100))