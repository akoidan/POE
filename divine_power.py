skill_value = {
	"dam":  3,
	"life": 10,
	"cri": 4,
	"as": 10,
}

armour_max_value = {
	"dam":  2,
	"life": 2,
	"cri": 3,
	"as": 2,
}

current_value = {
	"dam":  2,
	"life": 2,
	"cri": 1,
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