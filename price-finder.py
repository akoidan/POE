import math
import requests
import sys
from bs4 import BeautifulSoup as Soup
import re
import os
import sys

if 'price' not in sys.argv:
	sout = print
else:
	def sout(value):
		pass

clip_path =  os.sep.join((os.path.dirname(os.path.realpath(__file__)), 'clip.txt'))
poe_trade_conf = {
	"league": "Standard",
	"type": "",
	"base": "",
	"name": "",
	"dmg_min": "",
	"dmg_max": "",
	"aps_min": "",
	"aps_max": "",
	"crit_min": "",
	"crit_max": "",
	"dps_min": "",
	"dps_max": "",
	"edps_min": "",
	"edps_max": "",
	"pdps_min": "",
	"pdps_max": "",
	"armour_min": "",
	"armour_max": "",
	"evasion_min": "",
	"evasion_max": "",
	"shield_min": "",
	"shield_max": "",
	"block_min": "",
	"block_max": "",
	"sockets_min": "",
	"sockets_max": "",
	"link_min": "",
	"link_max": "",
	"sockets_r": "",
	"sockets_g": "",
	"sockets_b": "",
	"sockets_w": "",
	"linked_r": "",
	"linked_g": "",
	"linked_b": "",
	"linked_w": "",
	"rlevel_min": "",
	"rlevel_max": "",
	"rstr_min": "",
	"rstr_max": "",
	"rdex_min": "",
	"rdex_max": "",
	"rint_min": "",
	"rint_max": "",
	"mod_name": "",
	"mod_min": "",
	"mod_max": "",
	"group_type": "And",
	"group_min": "",
	"group_max": "",
	"group_count": "1",
	"q_min": "",
	"q_max": "",
	"level_min": "",
	"level_max": "",
	"ilvl_min": "",
	"ilvl_max": "",
	"rarity": "",
	"seller": "",
	"thread": "",
	"identified": "",
	"corrupted": 0,
	"online": "x",
	"buyout": "",
	"altart": "",
	"capquality": "x",
	"buyout_min": "",
	"buyout_max": "",
	"buyout_currency": "",
	"crafted": "",
	"enchanted": ""
}


def get_type(name):
	type_regex = {
		'Shield': r'Buckler\b|Bundle\b|Shield\b',
		'Gloves': r"Gauntlets\b|Gloves\b|Mitts\b",
		'Boots': r'Boots\b|Greaves\b|Slippers\b',
		'Helmet': r'Bascinet\b|Burgonet\b|Cage\b|Circlet\b|Crown\b|Hood\b|Helm\b|Helmet\b|Mask\b|Sallet\b|Tricorne\b',
		'BodyArmour': r'Armour\b|Brigandine\b|Chainmail\b|Coat\b|Doublet\b|Garb\b|Hauberk\b|Jacket\b|Lamellar\b|Leather\b|Plate\b|Raiment\b|Regalia\b|Ringmail\b|Robe\b|Tunic\b|Vest\b|Vestment\b|Chestplate|Full Dragonscale|Full Wyrmscale|Necromancer Silks|Shabby Jerkin|Silken Wrap'
	}
	for base_type in type_regex:
		res = re.search(type_regex[base_type], name)
		if res:
			return base_type
	return None


def decode_utf8(text):
	return ''.join([i if ord(i) < 128 else '?' for i in text])

with open(clip_path, 'r', encoding="UTF-8") as f:
	clip_data = f.read()
rarity = re.search('Rarity\:\s+(.*)\n', clip_data)
if not rarity:
	raise Exception("Go fuck yourself!:)")
rarity_type = rarity.group(1)
is_unique = "Unique" == rarity_type
if "Gem" == rarity_type:
	quality_r = re.search("\nQuality\: \+(\d+)\%", clip_data, )
	if quality_r:
		poe_trade_conf['q_min'] = quality_r.group(1)
	level_r = re.search("\nLevel\:\s*(\d+)", clip_data, )
	if level_r:
		lvl = int(level_r.group(1))
		if lvl > 18:
			poe_trade_conf['level_min'] = lvl
elif is_unique:
	poe_trade_conf['rarity'] = 'unique'
map_tier = re.search("\nMap Tier\: (\d+)", clip_data)
if map_tier:
	poe_trade_conf['level_min'] = map_tier.group(1)
	poe_trade_conf['level_max'] = map_tier.group(1)
if not map_tier or is_unique:
	chat_prefix = '<<set:MS>><<set:M>><<set:S>>'
	chat_pos = clip_data.find(chat_prefix)
	start_name = chat_pos + len(chat_prefix) if chat_pos >= 0 else clip_data.find('\n') + 1
	end_name = clip_data.find('------')-1
	poe_trade_conf['name'] = clip_data[start_name:end_name].replace('\n', ' ')
elif map_tier: # copy only base name if it's not unique map
	poe_trade_conf['name'] = re.search('\n(.*Map).*\n--------', clip_data).group(1)
else:
	poe_trade_conf['name'] = re.search('\n(.*)\n--------', clip_data).group(1)

sup_pref = "Superior "
if poe_trade_conf['name'].startswith(sup_pref):
	poe_trade_conf['name'] = poe_trade_conf['name'][len(sup_pref):]
base_type = get_type(poe_trade_conf['name'])
if base_type and not is_unique:
	poe_trade_conf['name'] = ''
	poe_trade_conf['type'] = base_type
	es = re.search('\nEnergy Shield: (\d+)', clip_data)
	if es and int(es.group(1)) > 100:
		poe_trade_conf['shield_min'] = es.group(1)

	life = re.search('\n\+(\d+) to maximum Life', clip_data)
	#if life and int(life.group(1)) > 40: TODO http://stackoverflow.com/questions/27116424/handling-duplicate-keys-in-http-post-in-order-to-specify-multiple-values
	#	poe_trade_conf['shield_min'] = es.group(1)
	res = re.finditer('\n\+(\d+)% to (Fire|Cold|Lightning) Resistance', clip_data)
	sum_res = 0
	for i in res:
		sum_res += int(i.group(1))
	if sum_res > 0:
		poe_trade_conf['mod_name'] = '(pseudo) +#% total Resistance'
		poe_trade_conf['mod_min'] = sum_res
if re.search('^Corrupted$', clip_data, re.MULTILINE):
	poe_trade_conf['corrupted'] = 1
for k in poe_trade_conf:
	if poe_trade_conf[k] != '' and k not in ('capquality', 'group_count', 'group_type'):
		sout(decode_utf8('{} : {}'.format(k, poe_trade_conf[k])))

sout('-'*10)
url = requests.post('http://poe.trade/search', poe_trade_conf)

soup = Soup(url.content, "html.parser")
all_offers = soup.select('[data-ign]')
result = ''

igns = set()

multi = {
	'chaos': 20,
	'alchemy': 4,
	'alteration': 1,
	'fusing': 10,
}
sum_price = 0
count = 0
for offer in all_offers:
	nick = offer['data-ign']
	if nick in igns:
		continue
	buyout_ = offer['data-buyout']
	bo = re.match('((\d+)\.?\d*) (\w+)', buyout_)
	value = multi.get(bo.group(3))
	if 'price' in sys.argv:
		if not value:
			continue
		count += 1
		sum_price += int(bo.group(1)) * value
	igns.add(nick)
	sout(decode_utf8(buyout_))
	if 'price' in sys.argv and count > 5:
		break
print(round(sum_price/count/multi['chaos']))