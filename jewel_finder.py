import requests
import urllib.parse
import re
min = 4
modes = {
	'+#% to Critical Strike Multiplier while affected by Anger' : 2,
	'#% increased Critical Strike Chance while affected by Wrath': 2,
	'Damage Penetrates #% Fire Resistance while affected by Anger': 1,
	'Damage Penetrates #% Lightning Resistance while affected by Wrath': 2,
	'You take #% reduced Extra Damage from Critical Strikes while affected by Determination': 2,
	'#% chance to Dodge Attack Hits while affected by Grace': 1,
	'#% increased Movement Speed while affected by Grace': 1,
	'You have Phasing while affected by Haste': 1,
	'#% increased Lightning Damage while affected by Wrath': 1,
	'Adds # to # Cold Damage while affected by Hatred': 1,
	'+#% to Critical Strike Chance while affected by Hatred': 2,
}

group_count = 0
url_request = ''
for k in modes:
	for i in range(modes[k]):
		url_request += '&mod_name='+ urllib.parse.quote_plus(k)
		url_request += '&mod_min='
		url_request += '&mod_max='
		url_request += '&mod_weight='
		group_count += 1
poe_trade_conf = {
	"league": "Standard",
}

poe_trade_conf_after = {
	"group_type": "Count",
	"group_min": min,
	"group_max": "",
	"group_count": group_count,
}

res = urllib.parse.urlencode(poe_trade_conf)
res += url_request
res += '&'
res += urllib.parse.urlencode(poe_trade_conf_after)

url = requests.post('http://poe.trade/search', data=res, headers={'Content-Type': 'application/x-www-form-urlencoded'})

res =re.search(r'\/search\/(\w+)\/live', url.text)
print('http://poe.trade/search/{}'.format(res.group(1)))



with open("Output.html", "w") as text_file:
    text_file.write(url.text)

