import FileSaver from 'file-saver'
function getDefaultOffer(userText) {
  return function (element) {
    return whisperMessage(element) + ' ' + userText;
  }
}

function whisperMessage(o) {
  let getData = (function () {
    let item = o.closest(".item");
    return function (attr) {
      return item.getAttribute('data-' + attr);
    }
  })();
  let bo = getData("buyout") ? " listed for " + getData("buyout") : "";
  let prefix = "";
  if (getData("level"))
    prefix += "level " + getData("level") + " ";
  if (getData("quality"))
    prefix += getData("quality") + "% ";
  let message = "@" + getData("ign") + " Hi, I would like to buy your " + prefix + getData("name") + bo + " in " + getData("league");
  let tab = getData("tab");
  if (tab) {
    let x = getData("x")
        , y = getData("y");
    message += ' (stash tab "' + tab + '"';
    if (x >= 0 && y >= 0)
      message += "; position: left " + (x + 1) + ", top " + (y + 1);
    message += ')';
  }
  return message;
}

function getCalcOffer(paramNames, paramMap) {
  return function (element) {
    let summ = 0;
    paramNames.forEach(function (p) {
      let v = getAttr(element, p);
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
function escapeHtml(html) {
  let escapeMap = {
    '#': '{#}',
    '+': '{+}',
    '{': '{{}',
    '}': '{}}'
  };
  let replaceHtmlRegex = new RegExp("[" + Object.keys(escapeMap).join("") + "]", "g");
  return html.replace(replaceHtmlRegex, function (s) {
    return escapeMap[s];
  });
}

export function saveCurrentData(block, offer) {
  let offerStr= getDefaultOffer(offer);
    // offer = getCalcOffer(request.attributes.paramNames, request.attributes.paramMap);
  let result = parsePage(block, offerStr);
  let escaped = escapeHtml(result);
  FileSaver.saveAs(new Blob([escaped], {
    type: "text/plain;charset=utf-8"
  }), 'buyItemsList.txt');
  return true;
}

export function clearBlock(block) {
  new Blocker(block).clear();
}

export function showBlockInfo(block) {
  return new Blocker(block).getTodayBlockInfo();
}



function getAttr(element, atr) {
  return element.closest(".item").querySelector('[data-name="' + atr + '"]').getAttribute('data-value');
}

class Blocker {
  constructor(blockName) {
    this.lsPerma = blockName;
    this.lsToday = blockName +'t';
  }

  getLocalStorage(key) {
    let value = localStorage.getItem(key);
    return value ? JSON.parse(value) : [];
  }

  setLocalStorage(key, value) {
    localStorage.setItem(key, JSON.stringify(value));
  };

  getTodayBlockInfo() {
    return localStorage.getItem(this.lsToday);
  }

  clear() {
    localStorage.removeItem(this.lsPerma);
    localStorage.removeItem(this.lsToday);
  }

  blockPerson(name) {
    let list = this.getLocalStorage(this.lsPerma);
    list.push(name);
    this.setLocalStorage(this.lsPerma, list);
  };

  blockToday(name) {
    let list = this.getLocalStorage(this.lsToday);
    list.push(name);
    this.setLocalStorage(this.lsToday, list);
  };

  getPermaBlock() {
    return this.getLocalStorage(this.lsPerma);
  };

  getTodayBlock() {
    return this.getLocalStorage(this.lsToday);
  };

  isAvailable(name) {
    return this.getPermaBlock().indexOf(name) < 0 && this.getTodayBlock().indexOf(name) < 0;
  };
}


function parsePage(blockName, getOffer) {
  let ls;
  if (blockName) {
    ls = new Blocker(blockName);
  }
  let outStr = "";
  let getParent = function (el) {
    return el.parentElement.parentElement.parentElement.parentElement.parentElement.parentElement;
  };
  let uniqueIgn = {};
  let ign = document.querySelectorAll('.whisper-btn');
  [].filter.call(ign, function currencyFilter(btn) {
    return !btn.closest('.item').querySelector('.currency');
  }).forEach(function (btn) {
    let el = getParent(btn);
    let name = el.getAttribute('data-ign');
    if (blockName) {
      if (ls.isAvailable(name)) {
        ls.blockToday(name);
        uniqueIgn[name] = btn;
      }
    } else {
      uniqueIgn[name] = btn;
    }
  });
  for (let name in uniqueIgn) {
    if (!uniqueIgn.hasOwnProperty(name))
      continue;
    let offer = getOffer(uniqueIgn[name]);
    if (offer) {
      outStr += offer + '\n';
    }
  }
  return outStr;
}
