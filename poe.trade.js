var uniqueIgn = {};
var outStr = "";
var escaper = (function() {
    const escapeMap = {
        '"': '""',
        '#': '"#'
    };
    var replaceHtmlRegex = new RegExp("[" + Object.keys(escapeMap).join("") + "]","g");
    this.encode = function(html) {
        return html.replace(replaceHtmlRegex, function(s) {
            return escapeMap[s];
        });
    }
    return this;
})();
function getLocalStorage(key) {
    var value = localStorage.getItem(key);
    return value ? JSON.parse(value) : [];
}
function setLocalStorage(key, value) {
    localStorage.setItem(key, JSON.stringify(value));
}
var blockPesonlist = getLocalStorage('blockedPerma')
var blockedToday = getLocalStorage('blockedToday');
function execute() {
    var ign = document.querySelectorAll('[data-ign]');
    [].filter.call(ign, function(el) {
        return !document.querySelector('#' + el.id + ' .currency');
    }).filter(function(el) {
        return $('#' + el.id + ':contains("Merciless Difficulty")').length > 0;
    }).forEach(function(el) {
        var name = el.getAttribute('data-ign');
        if (blockPesonlist.indexOf(name) < 0 && blockedToday.indexOf(name) < 0) {
            blockedToday.push(name);
            uniqueIgn[name] = {
                tabName: el.getAttribute('data-tab'),
                top: el.getAttribute('data-y'),
                left: el.getAttribute('data-x')
            };
        }
    });
    for (var name in uniqueIgn) {
        if (!uniqueIgn.hasOwnProperty(name))
            continue;var el = uniqueIgn[name];
        var tabInfo = el.tabName ? ' (stash tab ""' + escaper.encode(el.tabName) + '""; position: left ' + el.left + ", top " + el.top + ')' : '';
        outStr += 'o.Insert("@' + name + ' Hi, I would like to buy your Twice Enchanted in Standard' + tabInfo + '. My offer is 8 chaos")\n';
    }
}
execute();
console.log(outStr);
setLocalStorage('blockedToday', blockedToday);
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
