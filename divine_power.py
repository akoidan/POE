skill_value = {
	"light":  0.25,
	"acc": 0.3,
	"life": 0.35,
	"cold": 0.15,
	"ele": 0.3,
}

armour_max_value = {
	"light":  7+72,
	"acc": 400,
	"life": 60,
	"cold": 41,
	"ele": 42,
}

armour_min_value = {
	"light":  3+68,
	"acc": 321,
	"life": 50,
	"cold": 36,
	"ele": 37,
}

current_value = {
	"light":  4+71,
	"acc": 389,
	"life": 56,
	"cold": 36,
	"ele": 41,
}

sum = 0
for k in skill_value.keys():
	v = current_value[k] - armour_min_value[k]
	t = armour_max_value[k] - armour_min_value[k]
	s = skill_value[k]*v / t
	print("%s: %d/%d = %0.2f" % (k , v, t, s))
	sum += s
m = 0
for k in skill_value:
	m += skill_value[k]
print("RESULT: %0.2f/%0.2f = %d%%" % (sum, m, sum/m * 100))