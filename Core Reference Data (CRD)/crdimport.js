// PseudoVet - Core Reference Database Import Utility
// 

// print process.argv
//
console.log("PseudoVet - Core Reference Database Import");
console.log("Written by: Will BC Collins IV");

process.argv.forEach(function (val, index, array) {
	if (index == 2) {
		var rePattern = new RegExp(/^\-\-help$/);
		var arrMatches = val.match(rePattern);
		if(val.match(rePattern) == "--help"){ help(); }
	}
	console.log("Fin");
});

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

function writeFile () {
	fs.writeFile (savPath, data, function(err) {
		if (err) throw err;
		console.log('complete');
	});	
}

// -------------- functions ---------------
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
