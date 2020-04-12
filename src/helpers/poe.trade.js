import FileSaver from 'file-saver'
import PoeItem from "./PoeItem";

import notable from '../utils/cluster_jewels/notable';
import minor from '../utils/cluster_jewels/minor';
import keystones from '../utils/cluster_jewels/keystones';

var clusterJewels = Object.assign({}, notable, minor, keystones)

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
  saveToFile(result);
}

function saveToFile(data) {
  let escaped = escapeHtml(data);
  FileSaver.saveAs(new Blob([escaped], {
    type: "text/plain;charset=utf-8"
  }), 'buyItemsList.txt');
  return true;
}

function findGetParameter(parameterName) {
  var result = null,
      tmp = [];
  var items = location.search.substr(1).split("&");
  for (var index = 0; index < items.length; index++) {
    tmp = items[index].split("=");
    if (tmp[0] === parameterName) result = decodeURIComponent(tmp[1]);
  }
  return result;
}

function createOffer(o) {
  return {
    "username": o.getAttribute("data-username"),
    "sellcurrency": parseInt(o.getAttribute("data-sellcurrency")),
    "buycurrency": parseInt(o.getAttribute("data-buycurrency")),
    "sellvalue": parseFloat(o.getAttribute("data-sellvalue")),
    "buyvalue": parseFloat(o.getAttribute("data-buyvalue")),
    "ign": o.getAttribute("data-ign"),
    "stock": o.getAttribute("data-stock"),
  };
}

export function saveCurrencyData(amount, limit) {
  let data = parseCurrencyPage(amount, limit);
  saveToFile(data);
}

export function clearBlock(block) {
  new Blocker(block).clear();
}

export function showBlockInfo(block) {
  return new Blocker(block).getTodayBlockInfo();
}


function appendAccount() {
  [].forEach.call(document.querySelectorAll('[data-seller]'), e => e.querySelector('h5').innerHTML += e.getAttribute('data-seller'))
}

export function getMods() {
  let modDivs = document.querySelectorAll('.mods [data-name]');
  let modNames = [].map.call(modDivs, a => a.getAttribute('data-name'));
  let excludeMods = item => item.indexOf('#(enchant)') < 0;
  return modNames.filter((item, pos) => modNames.indexOf(item) === pos && excludeMods(item));
}


function copyTextToClipboard(text) {
  let textArea = document.createElement("textarea");
  // Place in top-left corner of screen regardless of scroll position.
  textArea.style.position = 'fixed';
  textArea.style.top = 0;
  textArea.style.left = 0;
  // Ensure it has a small width and height. Setting to 1px / 1em
  // doesn't work as this gives a negative w/h on some browsers.
  textArea.style.width = '2em';
  textArea.style.height = '2em';
  // We don't need padding, reducing the size if it does flash render.
  textArea.style.padding = 0;
  // Clean up any borders.
  textArea.style.border = 'none';
  textArea.style.outline = 'none';
  textArea.style.boxShadow = 'none';
  // Avoid flash of white box if rendered for any reason.
  textArea.style.background = 'transparent';
  textArea.value = text;
  document.body.appendChild(textArea);
  textArea.select();
  let success = false;
  try {
    success = document.execCommand('copy');
  } catch (err) {
    console.log('Oops, unable to copy');
  }
  document.body.removeChild(textArea);
  return success;
}


function poeClip() {
  [].forEach.call(document.querySelectorAll('*[id^="item-container-"]'), e => {
    let li = document.createElement('li');
    let a = document.createElement('a');
    li.appendChild(a);
    e.querySelector('.requirements .proplist').appendChild(li);
    var clusterMods = e.querySelectorAll('li[data-name*="Added Passive Skill is"]');
    clusterMods.forEach(clusterMode => {
      let match = /#\w Added Passive Skill is (.*)/.exec(clusterMode.getAttribute('data-name'));
      if (match && clusterJewels[match[1]]) {
        clusterMode.title = clusterJewels[match[1]];
      }
    })
    a.innerText = 'Copy';
    a.onclick = () => {
      let poeObject = new PoeItem(e);
      let succ = copyTextToClipboard(poeObject.buildItem());
      a.innerText = succ ? 'Copied' : 'Error';
    };
  });
}


export function init() {
  appendAccount();
  poeClip();
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

function getCurrencyText() {
  const regex = /CURRENCY_TEXTS = (\[.*\])/g;
  let res = regex.exec(document.body.innerHTML);
  if (res && res[1]) {
    return JSON.parse(res[1]);
  } else {
    alert ("can't evaluate CURRENCY_TEXTS var ");
    throw "Invalid state exception";
  }
}

function parseCurrencyPage(amount, limit) {
  let els = document.querySelectorAll('.displayoffer');
  let outstr = '';
  let CURRENCY_TEXTS = getCurrencyText();
  Array.prototype.forEach.call(els, e => {
        let offer = createOffer(e);
        let price = offer.buyvalue / offer.sellvalue;
        if (limit) {
          if (price > 1 && price > limit) {
            return;
          } else if (price < 1 && 1 / price < limit) {
            return
          }
        }

        let buying;
        let selling;
        let end = '';
        let currencyName = CURRENCY_TEXTS[offer.sellcurrency];
        let currencyNameSell = CURRENCY_TEXTS[offer.buycurrency];
        if (price > 1) {
          if (amount && offer.sellvalue > amount) {
            selling = price * amount;
            buying = amount;
          } else {
            buying = offer.sellvalue;
            selling = offer.buyvalue;
          }
          if (amount && offer.sellvalue < amount) {
            end = ` I need ${amount} ${currencyName}.`
          }
        } else {
          if (amount && offer.buyvalue > amount) {
            selling = amount;
            buying = amount / price;
          } else {
            buying = offer.sellvalue;
            selling = offer.buyvalue;
          }
          if (amount && offer.buyvalue < amount) {
            end = ` I need ${amount} ${currencyNameSell} worth.`
          }
        }
        outstr += `@${offer.ign} Hi, I'd like to buy your ${Math.floor(buying)} ${currencyName} for my ${Math.floor(selling)} ${currencyNameSell} in ${findGetParameter('league')}.${end}\n`;
      }
  );
  return outstr;
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
  [].forEach.call(ign, function (btn) {
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
