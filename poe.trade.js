var ls = (function() {
    const LOCAL_STORAGE_PERMA_BLOCK = 'blockedPerma2';
    const LOCAL_STORAGE_TODAY_BLOCK = 'blockedToday42233';
    var escaper = (function() {
		const escapeMap = {
			'"': '""',
			'#': '{#}'
		};
		var replaceHtmlRegex = new RegExp("[" + Object.keys(escapeMap).join("") + "]","g");
		this.encode = function(html) {
			return html.replace(replaceHtmlRegex, function(s) {
				return escapeMap[s];
			});
		}
		return this;
	})();
    this.getLocalStorage = function(key) {
        var value = localStorage.getItem(key);
        return value ? JSON.parse(value) : [];
    }
    this.setLocalStorage = function(key, value) {
        localStorage.setItem(key, JSON.stringify(value));
    }
    this.blockPerson = function(name) {
        var list = getLocalStorage(LOCAL_STORAGE_PERMA_BLOCK);
        list.push(name);
        setLocalStorage(LOCAL_STORAGE_PERMA_BLOCK, list);
    }
    this.blockToday = function(name) {
        var list = getLocalStorage(LOCAL_STORAGE_TODAY_BLOCK);
        list.push(name);
        setLocalStorage(LOCAL_STORAGE_TODAY_BLOCK, list);
    }
    this.getPermaBlock = function(value) {
        return this.getLocalStorage(LOCAL_STORAGE_PERMA_BLOCK);
    }
    this.getTodayBlock = function() {
        return this.getLocalStorage(LOCAL_STORAGE_TODAY_BLOCK);
    }
    this.set
    return this;
})();
(function() {
    var offer = ' My offer is 20 chaos';
    var blockPesonlist = ls.getPermaBlock();
    var blockedToday = ls.getTodayBlock();
    var outStr = "";
    var uniqueIgn = {};
    var ign = document.querySelectorAll('[data-ign]');
    [].filter.call(ign, function(el) {
        return !document.querySelector('#' + el.id + ' .currency');
    }).filter(function(el) {
    	return true;
        //return $('#' + el.id + ':contains("Merciless Difficulty")').length > 0;
    }).forEach(function(el) {
        var name = el.getAttribute('data-ign');
        if (blockPesonlist.indexOf(name) < 0 && blockedToday.indexOf(name) < 0) {
        ls.blockToday(name);
        uniqueIgn[name] = {
            tabName: el.getAttribute('data-tab'),
            top: el.getAttribute('data-y'),
            left: el.getAttribute('data-x'),
            name: el.getAttribute('data-name')
        };
        }
    });
    for (var name in uniqueIgn) {
        if (!uniqueIgn.hasOwnProperty(name))
            continue;var el = uniqueIgn[name];
        var tabInfo = el.tabName ? ' (stash tab ""' + escaper.encode(el.tabName) + '""; position: left ' + el.left + ", top " + el.top + ')' : '';
        outStr += 'o.Insert("@' + name + ' Hi, I would like to buy your ' + el.name + ' in Standard' + tabInfo + '.' + offer + '")\n';
    }
    if (outStr) {
        console.log(outStr);
    } else {
        console.error("No new entries found");
    }
})();
/*
printMessage() {
	o := Object()
	;;// PASTE INSERT HERE
	for index, element in o
	{
		send {Enter}
		sleep 100
		send, %element%
		sleep 100
		send {Enter}
		sleep 2000
	}
}*/
