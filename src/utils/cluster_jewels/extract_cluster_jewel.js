// this script parses html of poe.wiki and creates json file with data required for poe.trade extension

// 1. open https://pathofexile.gamepedia.com/Cluster_Jewel
// 2. copy this file to devconsole and execute
// 2. paste result in json files in this directory

function getData(text) {
    // get header h2 above the table by Xpath innerText
    let listNotHeader = document.evaluate(`//h2[contains(., '${text}')]`, document, null, XPathResult.ANY_TYPE, null).iterateNext();
    let listNotableTable = listNotHeader.nextElementSibling.querySelector('table');

    let result = {};
    // skips first child  as its a header of the table
    listNotableTable.querySelectorAll('tr:not(:first-child)').forEach(a => {
        // 1st column is a passive name, 2nd is its mods
        result[a.querySelector('td:nth-child(1)').innerText] = a.querySelector('td:nth-child(2)').innerText;
    });
    return result;
}
function printDataToConsole(text) {
    console.log(text)
    console.log(JSON.stringify(getData(text)))
}
printDataToConsole('List of keystone nodes')
printDataToConsole('List of notable passive')
printDataToConsole('List of minor passives')
