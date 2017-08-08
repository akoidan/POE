function getDefaultOffer(userText) {
  return function (element) {
    return whisperMessage(element) + ' ' + userText;
  }
}

function whisperMessage(o) {
  var data = (function () {
    var item = o.closest(".item");
    return function (attr) {
      return item.getAttribute('data-' + attr);
    }
  })();
  var bo = data("buyout") ? " listed for " + data("buyout") : "";
  var prefix = "";
  if (data("level"))
    prefix += "level " + data("level") + " ";
  if (data("quality"))
    prefix += data("quality") + "% ";
  var message = "@" + data("ign") + " Hi, I would like to buy your " + prefix + data("name") + bo + " in " + data("league");
  var tab = data("tab");
  if (tab) {
    var x = data("x")
        , y = data("y");
    message += ' (stash tab "' + tab + '"';
    if (x >= 0 && y >= 0)
      message += "; position: left " + (x + 1) + ", top " + (y + 1);
    message += ')';
  }
  return message;
}

function getCalcOffer(paramNames, paramMap) {
  return function (element) {
    var summ = 0;
    paramNames.forEach(function(p) {
      var v = getAttr(element, p);
      if (isNaN(v)) {
        console.warn(element, v + " is nan");
      } else {
       summ += parseInt(v);
      }
    });
    if (paramMap[summ]) {
      return getDefaultOffer('My offer is ' + paramMap[summ])(element);
    } else {
      console.warn(element, 'Sum "' + summ + '"  missmatch');
      return '';
    }
  }
}

chrome.extension.onRequest.addListener(function (request, sender, sendResponse) {
  if (request.action === "getScreamText") {
    var offer;
    if (request.offer) {
      offer = getDefaultOffer(request.offer);
    } else if (request.attributes) {
      offer = getCalcOffer(request.attributes.paramNames, request.attributes.paramMap);
    }
    var result = parsePage(request.block, offer);
    sendResponse(result);
    return true;
  }
});


function getAttr(element, atr) {
  return element.closest(".item").querySelector('[data-name="' + atr + '"]').getAttribute('data-value');
}

var blocker = (function (LOCAL_STORAGE_PERMA_BLOCK, LOCAL_STORAGE_TODAY_BLOCK) {
  this.getLocalStorage = function (key) {
    var value = localStorage.getItem(key);
    return value ? JSON.parse(value) : [];
  };
  this.setLocalStorage = function (key, value) {
    localStorage.setItem(key, JSON.stringify(value));
  };
  this.blockPerson = function (name) {
    var list = getLocalStorage(LOCAL_STORAGE_PERMA_BLOCK);
    list.push(name);
    setLocalStorage(LOCAL_STORAGE_PERMA_BLOCK, list);
  };
  this.blockToday = function (name) {
    var list = getLocalStorage(LOCAL_STORAGE_TODAY_BLOCK);
    list.push(name);
    setLocalStorage(LOCAL_STORAGE_TODAY_BLOCK, list);
  };
  this.getPermaBlock = function (value) {
    return this.getLocalStorage(LOCAL_STORAGE_PERMA_BLOCK);
  };
  this.getTodayBlock = function () {
    return this.getLocalStorage(LOCAL_STORAGE_TODAY_BLOCK);
  };
  this.isAvailable = function() {
    return this.getPermaBlock.indexOf(name) < 0 && this.getTodayBlock.indexOf(name) < 0;
  };
  return this;
});

function parsePage(useBlock, getOffer) {
   var ls;
  if (useBlock) {
    var lsPerma = document.getElementById('name').value || document.querySelector('#base_chosen a span').innerHTML;
    ls = blocker(lsPerma, lsPerma)
  }
  var outStr = "";
  var getParent = function (el) {
    return el.parentElement.parentElement.parentElement.parentElement.parentElement.parentElement;
  };
  var uniqueIgn = {};
  var ign = document.querySelectorAll('.whisper-btn');
  [].filter.call(ign, function currencyFilter(btn) {
    return !btn.closest('.item').querySelector('.currency');
  }).forEach(function (btn) {
    var el = getParent(btn);
    var name = el.getAttribute('data-ign');
    if (useBlock) {
      if (ls.isAvailable(name)) {
        ls.blockToday(name);
        uniqueIgn[name] = btn;
      }
    } else {
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
  return outStr;
}
