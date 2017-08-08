var path ;
var stDiv;
var i = 0;

function save_options() {
	var pathV = path.value;
	chrome.storage.sync.set({
		path: pathV
	}, function () {
		setStatus("Options saved");
	});
}

function setStatus(text) {
	i++;
	stDiv.textContent = '[' + i + '] ' + text;
	setTimeout(function () {
		stDiv.textContent = '';
	}, 2000);
}

function restore_options() {
	chrome.storage.sync.get({
		path: "D:\\Downloads\\buyItemsList.txt"
	}, function (items) {
		path.value = items.path;
		setStatus("Options loaded");
	});
}

document.addEventListener("DOMContentLoaded", function () {
	path = document.getElementById('path');
	console.log(stDiv);
	stDiv = document.getElementById('status');
	console.log(stDiv);
	document.getElementById('save').addEventListener('click', save_options);
	restore_options();
});