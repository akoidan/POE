var stDiv;
var path;
console.log('main');
function $(id) {
	return document.getElementById(id);
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


function onBtnClick () {
	chrome.tabs.getSelected(null, function(tab) {
  chrome.tabs.sendRequest(tab.id, {
  	action: "getScreamText",
		offer: path.value,
		block: false
	}, function(response) {
    console.log(response);
  });
});
}
document.addEventListener("DOMContentLoaded", function () {
	path = $('path');
	$('save').onclick = onBtnClick;
	path.value = 'My offer is 1 chaos';
	stDiv = $('status');
	console.log('loaded')
});