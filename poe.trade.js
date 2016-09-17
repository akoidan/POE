console.log('ok');
var uniqueIgn = [];
var outStr = "";
var blockPesonlist = [];
function execute() {
	var ign =document.querySelectorAll('[data-ign]');
	[].filter.call(ign, function(el) {
		 return !document.querySelector('#'+el.id +' .currency');
	}).filter(function(el){
		return $('#'+el.id +':contains("Merciless Difficulty")');
	}).forEach(function(el) {
		var name = el.getAttribute('data-ign');
		if (uniqueIgn.indexOf(name) < 0 && blockPesonlist.indexOf(name) < 0) {
		 uniqueIgn.push(name);
		}
	});
	uniqueIgn.forEach(function(el){
		outStr += 'o.Insert("@'+el+' Hi, I would like to buy your Twice Enchanted in Standard. My offer is 8chaos.")\n';
	});
	console.log(outStr);
}

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
