var LOCAL_STORAGE_PERMA_BLOCK = 'c22c2dc12123b';
var LOCAL_STORAGE_TODAY_BLOCK = '2cc2c123122db';
var offer = ' My offer is 20 chaos';
function extraFilter(el) {
    return true;
    //return $('#' + el.id + ':contains("Merciless Difficulty")').length > 0;
}
var ls = (function() {
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
function loadFileSaver(onReady) {
    if (typeof saveAs == 'undefined') {
        var rawUrl = 'https://rawgit.com/eligrey/FileSaver.js/master/FileSaver.js';
        // download and run the script
        var head = document.getElementsByTagName('head')[0];
        var script = document.createElement('script');
        script.type = 'text/javascript';
        head.appendChild(script);
        script.onload = onReady;
		script.src = rawUrl;
    } else {
        onReady();
    }
}
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
(function() {
    var blockPesonlist = ls.getPermaBlock();
    var blockedToday = ls.getTodayBlock();
    var outStr = "";
    var prices = {}
    var getParent = function (el) {
    	return el.parentElement.parentElement.parentElement.parentElement.parentElement.parentElement;
    }
    var uniqueIgn = {};
    var ign = document.querySelectorAll('.whisper-btn');
    [].filter.call(ign, function(btn) {
        return !document.querySelector('#' + getParent(btn).id + ' .currency');
    }).filter(extraFilter).forEach(function(btn) {
    	var el = getParent(btn);
        var name = el.getAttribute('data-ign');
        if (blockPesonlist.indexOf(name) < 0 && blockedToday.indexOf(name) < 0) {
            ls.blockToday(name);
            uniqueIgn[name] = btn;
        }
    });
    for (var name in uniqueIgn) {
        if (!uniqueIgn.hasOwnProperty(name))
            continue;
        var message = whisperMessage(uniqueIgn[name]);
        outStr += message + '\n';
    }
    if (outStr) {
        console.log(outStr);
        loadFileSaver(function() {
            saveAs(new Blob([outStr], {type: "text/plain;charset=utf-8"}), 'buyItemsList.txt');
        });
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
