var stDiv;
var path;
console.log('main');
function $(id) {
	return document.getElementById(id);
}

function onBtnClick() {
  chrome.storage.sync.get({
    path: "buyItemsList.txt"
  }, function (items) {
    chrome.tabs.getSelected(null, function (tab) {
      chrome.tabs.sendRequest(tab.id, {
        action: "getScreamText",
        offer: path.value,
        block: false,
        path: items.path
      }, function (response) {
        console.log(response);
      });
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