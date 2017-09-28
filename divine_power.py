skill_value = {
	"fl": 1,
	"li": 0.3,
	"el": 0.25,
}

armour_max_value = {
	"el":  5,
	"li": 10,
	"fl": 10,
}

current_value = {
	"el": 4,
	"li": 0,
	"fl": 7,
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