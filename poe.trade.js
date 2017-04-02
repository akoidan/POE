var LOCAL_STORAGE_PERMA_BLOCK = $('#name').val() ;
var LOCAL_STORAGE_TODAY_BLOCK = LOCAL_STORAGE_PERMA_BLOCK;
var DEBUG = false;
var getOffer = function(element) {
    var message = whisperMessage(element);
    var blck = getAttr(element, '##% Chance to Block during Flask effect');
    var blckSpl = getAttr(element, '##% Chance to Block Spells during Flask effect');
    var map = {
        53: '9ex',
        54: '10ex',
        55: '12ex',
        56: '14.5ex',
        57: '17ex',
        58: '21ex',
        59: '25ex',
        60: false
    };
    if (map[blck + blckSpl]) {
        return whisperMessage(element) + ' My offer is ' + map[blck + blckSpl];
    }
};
function currencyFilter(btn) {
       return !document.querySelector('#' + $(btn).parents(".item")[0].id + ' .currency');
}
getOffer = function(element) {
    return whisperMessage(element) + ' My offer is 5ex';
};
function getAttr(element, atr) {
    return parseInt($($(element).parents(".item")[0]).find('[data-name="' + atr + '"]')[0].getAttribute('data-value'))
}
var ls = (function() {
    this.getLocalStorage = function(key) {
        var value = localStorage.getItem(key);
        return value ? JSON.parse(value) : [];
    };
    this.setLocalStorage = function(key, value) {
        localStorage.setItem(key, JSON.stringify(value));
    };
    this.blockPerson = function(name) {
        if (!DEBUG) {
            var list = getLocalStorage(LOCAL_STORAGE_PERMA_BLOCK);
            list.push(name);
            setLocalStorage(LOCAL_STORAGE_PERMA_BLOCK, list);
        }
    };
    this.blockToday = function(name) {
        if (!DEBUG) {
            var list = getLocalStorage(LOCAL_STORAGE_TODAY_BLOCK);
            list.push(name);
            setLocalStorage(LOCAL_STORAGE_TODAY_BLOCK, list);
        }
    };
    this.getPermaBlock = function(value) {
        return this.getLocalStorage(LOCAL_STORAGE_PERMA_BLOCK);
    };
    this.getTodayBlock = function() {
        return this.getLocalStorage(LOCAL_STORAGE_TODAY_BLOCK);
    };
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
        '#': '{#}',
        '+': '{+}',
        '{': '{{}',
        '}': '{}}'
    };
    var replaceHtmlRegex = new RegExp("[" + Object.keys(escapeMap).join("") + "]","g");
    this.encode = function(html) {
        return html.replace(replaceHtmlRegex, function(s) {
            return escapeMap[s];
        });
    };
    return this;
})();
(function() {
    var blockPesonlist = ls.getPermaBlock();
    var blockedToday = ls.getTodayBlock();
    var outStr = "";
    var getParent = function(el) {
        return el.parentElement.parentElement.parentElement.parentElement.parentElement.parentElement;
    };
    var uniqueIgn = {};
    var ign = document.querySelectorAll('.whisper-btn');
    [].filter.call(ign, currencyFilter).forEach(function(btn) {
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
        var offer = getOffer(uniqueIgn[name]);
        if (offer) {
            outStr += offer + '\n';
        }
    }
    if (outStr) {
        console.log(outStr);
        loadFileSaver(function() {
            saveAs(new Blob([escaper.encode(outStr)], {
                type: "text/plain;charset=utf-8"
            }), 'buyItemsList.txt');
        });
    } else {
        console.error("No new entries found");
    }
})();
