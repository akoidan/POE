import requests
from bs4 import BeautifulSoup as Soup
import re

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
	"corrupted": "",
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
with open('e:\clip.txt') as f:
	clip_data = f.read()
start_name = clip_data.find('\n')
end_name = clip_data.find('------')-1
poe_trade_conf['name'] = clip_data[start_name+1:end_name].replace('\n', ' ')
if "Gem" in clip_data[0:start_name]:
	poe_trade_conf['q_min'] = re.search("\nQuality\: \+(\d+)\%", clip_data, ).group(1)
url = requests.post('http://poe.trade/search', poe_trade_conf)

soup = Soup(url.content, "html.parser")
all_offers = soup.select('[data-ign]')
result = ''
i = 0
for offer in all_offers:
	i += 1
	if i > 6:
		break
	print(offer['data-buyout'])
