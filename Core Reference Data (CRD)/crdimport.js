// PseudoVet - Core Reference Database Import Utility
// crdimpor((t.js
var js=require("FileReader");

console.log("PseudoVet - Core Reference Database Import");
console.log("Written by: Will BC Collins IV");

var inputFileName='lastnames.txt';
var outputFileName='lastnames.json';

// process.argv
process.argv.forEach(function (val, index, array) {
	if (index == 2) {
		var rePattern = new RegExp(/^\-\-help$/);
		var arrMatches = val.match(rePattern);
		if(val.match(rePattern) == "--help"){ help(); }
	}
	console.log("Fin");
});

parseFile(inputFileName);

function copyData(savPath, srcPath) {
	fs.readFile(srcPath, 'utf8', function (err, data) {
		if (err) throw err;
		// process input file
		fs.writeFile (savPath, data, function(err) {
			if (err) throw err;
			console.log('complete');
		});
	});
}

// this is a placeholder for writing files
function writeFile (outputFileName, inputData) {
	fs.writeFile (savPath, data, function(err) {
		if (err) throw err;
		console.log('complete');
	});
}

// -------------- functions ---------------
function parseFile(FileName) {
	var fs=new FileReader();
	fs.readFile(FileName, 'utf8', function (err, data) {
		if (err) throw err;
		var dataArray = data.replace(/(\r\n)|\r|\n/g, '\n').split(/\n+/g);
		for(var line in dataArray) {
			console.log(line);
		}
	})
}

function help() {
	console.log("crdimport.js - converts text files to json");
	console.log("options:");
	console.log("	--i <name of input file>");
	console.log("	--o <name of output json file>");
	console.log("	--f <list of fields from input file>");
	console.log("	--d <delimiter: comma space tab");
	console.log("	--x <list of fileds to skip>");
	return;
}
