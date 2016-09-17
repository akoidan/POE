var uniqueIgn = [];
var outStr = "";
var blockPesonlist = ["SsenseChampion", "MajsanIBajsan", "Luciferr", "BlowUpEarth", "TimothySanchez", "BVarianCream", "Sprooce", "AssSense", "Drugbabe", "NiknonUltraShield", "DAMN_SHES_HOT", "CapBigode", "Streeze", "LibritanniaCS", "SnKCreepingDeath", "OBAFGKM", "AntiBvortex", "Krhuljcina", "EssenceBug", "Loirinhadobanheiro", "ФобияБоли", "Злая_Тетька", "Yagul", "AtlasTrickster", "Atlas_saltA", "Keledrain", "SlingshotEssence", "DerpiusMinimus", "kushivthejag", "MickGordon", "Aoobixofeio", "JasonKnox", "Quintileous", "Fapioh", "JesseWeNeedToCook"];
function execute() {
	var ign =document.querySelectorAll('[data-ign]');
	[].filter.call(ign, function(el) {
		 return !document.querySelector('#'+el.id +' .currency');
	}).filter(function(el){
		return  $('#'+el.id +':contains("Merciless Difficulty")').length > 0;
	}).forEach(function(el) {
		var name = el.getAttribute('data-ign');
		if (uniqueIgn.indexOf(name) < 0 && blockPesonlist.indexOf(name) < 0) {
		 uniqueIgn.push(name);
		}
	});
	uniqueIgn.forEach(function(el){
		outStr += 'o.Insert("@'+el+' Hi, I would like to buy your Twice Enchanted in Standard. My offer is 8chaos.")\n';
	});
	
}
execute();
console.log(outStr);
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
