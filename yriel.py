skill_value = {
	"as": 1.2,
	"ac": 0.5,
	"li": 0.4,
	"cr": 0.9,
	"ev": 0.2
}

armour_max_value = {
	"as":  5,
	"ac": 100,
	"li":10,
	"cr": 20,
	"ev": 20
}

current_value = {
	"as": 5,
	"ac": 71,
	"li": 2,
	"cr": 19,
	"ev": 23
}

sum = 0
for k in ["as", "ac", "li", "cr", "ev"]:
	s = skill_value[k]/armour_max_value[k] * current_value[k]
	print("%s: %d/%d = %0.2f" % (k, current_value[k], armour_max_value[k], s))
	sum += s
m = 0
for k in skill_value:
	m += skill_value[k]
print("RESULT: %0.2f/%0.2f = %d%%" % (sum, m, sum/m * 100))