var saveAs = (function (view) {
  "use strict";
  // IE <10 is explicitly unsupported
  if (typeof view === "undefined" || typeof navigator !== "undefined" && /MSIE [1-9]\./.test(navigator.userAgent)) {
    return;
  }
  var
      doc = view.document
      // only get URL when necessary in case Blob.js hasn't overridden it yet
      , get_URL = function () {
        return view.URL || view.webkitURL || view;
      }
      , save_link = doc.createElementNS("http://www.w3.org/1999/xhtml", "a")
      , can_use_save_link = "download" in save_link
      , click = function (node) {
        var event = new MouseEvent("click");
        node.dispatchEvent(event);
      }
      , is_safari = /constructor/i.test(view.HTMLElement) || view.safari
      , is_chrome_ios = /CriOS\/[\d]+/.test(navigator.userAgent)
      , throw_outside = function (ex) {
        (view.setImmediate || view.setTimeout)(function () {
          throw ex;
        }, 0);
      }
      , force_saveable_type = "application/octet-stream"
      // the Blob API is fundamentally broken as there is no "downloadfinished" event to subscribe to
      , arbitrary_revoke_timeout = 1000 * 40 // in ms
      , revoke = function (file) {
        var revoker = function () {
          if (typeof file === "string") { // file is an object URL
            get_URL().revokeObjectURL(file);
          } else { // file is a File
            file.remove();
          }
        };
        setTimeout(revoker, arbitrary_revoke_timeout);
      }
      , dispatch = function (filesaver, event_types, event) {
        event_types = [].concat(event_types);
        var i = event_types.length;
        while (i--) {
          var listener = filesaver["on" + event_types[i]];
          if (typeof listener === "function") {
            try {
              listener.call(filesaver, event || filesaver);
            } catch (ex) {
              throw_outside(ex);
            }
          }
        }
      }
      , auto_bom = function (blob) {
        // prepend BOM for UTF-8 XML and text/* types (including HTML)
        // note: your browser will automatically convert UTF-16 U+FEFF to EF BB BF
        if (/^\s*(?:text\/\S*|application\/xml|\S*\/\S*\+xml)\s*;.*charset\s*=\s*utf-8/i.test(blob.type)) {
          return new Blob([String.fromCharCode(0xFEFF), blob], {type: blob.type});
        }
        return blob;
      }
      , FileSaver = function (blob, name, no_auto_bom) {
        if (!no_auto_bom) {
          blob = auto_bom(blob);
        }
        // First try a.download, then web filesystem, then object URLs
        var
            filesaver = this
            , type = blob.type
            , force = type === force_saveable_type
            , object_url
            , dispatch_all = function () {
              dispatch(filesaver, "writestart progress write writeend".split(" "));
            }
            // on any filesys errors revert to saving with object URLs
            , fs_error = function () {
              if ((is_chrome_ios || (force && is_safari)) && view.FileReader) {
                // Safari doesn't allow downloading of blob urls
                var reader = new FileReader();
                reader.onloadend = function () {
                  var url = is_chrome_ios ? reader.result : reader.result.replace(/^data:[^;]*;/, 'data:attachment/file;');
                  var popup = view.open(url, '_blank');
                  if (!popup) view.location.href = url;
                  url = undefined; // release reference before dispatching
                  filesaver.readyState = filesaver.DONE;
                  dispatch_all();
                };
                reader.readAsDataURL(blob);
                filesaver.readyState = filesaver.INIT;
                return;
              }
              // don't create more object URLs than needed
              if (!object_url) {
                object_url = get_URL().createObjectURL(blob);
              }
              if (force) {
                view.location.href = object_url;
              } else {
                var opened = view.open(object_url, "_blank");
                if (!opened) {
                  // Apple does not allow window.open, see https://developer.apple.com/library/safari/documentation/Tools/Conceptual/SafariExtensionGuide/WorkingwithWindowsandTabs/WorkingwithWindowsandTabs.html
                  view.location.href = object_url;
                }
              }
              filesaver.readyState = filesaver.DONE;
              dispatch_all();
              revoke(object_url);
            }
        ;
        filesaver.readyState = filesaver.INIT;

        if (can_use_save_link) {
          object_url = get_URL().createObjectURL(blob);
          setTimeout(function () {
            save_link.href = object_url;
            save_link.download = name;
            click(save_link);
            dispatch_all();
            revoke(object_url);
            filesaver.readyState = filesaver.DONE;
          });
          return;
        }

        fs_error();
      }
      , FS_proto = FileSaver.prototype
      , saveAs = function (blob, name, no_auto_bom) {
        return new FileSaver(blob, name || blob.name || "download", no_auto_bom);
      }
  ;
  // IE 10+ (native saveAs)
  if (typeof navigator !== "undefined" && navigator.msSaveOrOpenBlob) {
    return function (blob, name, no_auto_bom) {
      name = name || blob.name || "download";

      if (!no_auto_bom) {
        blob = auto_bom(blob);
      }
      return navigator.msSaveOrOpenBlob(blob, name);
    };
  }

  FS_proto.abort = function () {
  };
  FS_proto.readyState = FS_proto.INIT = 0;
  FS_proto.WRITING = 1;
  FS_proto.DONE = 2;

  FS_proto.error =
      FS_proto.onwritestart =
          FS_proto.onprogress =
              FS_proto.onwrite =
                  FS_proto.onabort =
                      FS_proto.onerror =
                          FS_proto.onwriteend =
                              null;

  return saveAs;
}(
    typeof self !== "undefined" && self
    || typeof window !== "undefined" && window
    || this.content
));


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
    paramNames.forEach(function (p) {
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
function escapeHtml(html) {
  var escapeMap = {
    '#': '{#}',
    '+': '{+}',
    '{': '{{}',
    '}': '{}}'
  };
  var replaceHtmlRegex = new RegExp("[" + Object.keys(escapeMap).join("") + "]", "g");
  return html.replace(replaceHtmlRegex, function (s) {
    return escapeMap[s];
  });
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
    var escaped = escapeHtml(result);
    saveAs(new Blob([escaped], {
                type: "text/plain;charset=utf-8"
            }), request.path);
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
  this.isAvailable = function () {
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
