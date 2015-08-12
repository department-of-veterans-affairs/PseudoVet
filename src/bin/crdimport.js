// PseudoVet - Core Reference Database Importer
// Name:	crdimport.js
// Author: 	Will BC Collins IV for Department of Veterans Affairs
// Purpose:	This utility is for importing json files into the
//			PseudoVet Core Reference Database
// Date:	last modified: 2015-06-29
// This script is really unnecessary obfuscation but, it may be convenient because it allows everything 
// to be done the same way running javascript utilities instead of switching to mongodb commands.

var fs=require("fs");

console.log("\ncrdimporter.js - PseudoVet :: Core Reference Database Importer");
console.log("\tWritten by: Will BC Collins IV for Dept Veterans Affairs\n");

// global vars
var input, database, collection, drop, dropflag;
	
// process.argv
process.argv.forEach(function (val, index, array) {
	// set up regular expression pattern matching for arguments		
	var helpPattern = new RegExp(/^\-\-h$/); // --h help
	var inputPattern = new RegExp(/^\-\-i$/); // --i <input JSON file>
	var dbPattern = new RegExp(/^\-\-d$/); // --d <name of database>
	var collectionPattern = new RegExp(/^\-\-c$/); // --c collection name
	var dropPattern = new RegExp(/^\-\-x$/); // --x true|false drop existing
	var consoleLabel=''; var value=process.argv[index+1];

	// set global variables for file conversion
	if(val.match(helpPattern) == "--h"){ 
		//consoleLabel='help';
		help();
	}
  if(val.match(inputPattern) == "--i"){ consoleLabel='import file'; input = value; }
	if(val.match(dbPattern) == "--d"){ consoleLabel='database'; database=value; }
	if(val.match(collectionPattern) == "--c"){ consoleLabel='collection'; collection=value; }
	if(val.match(dropPattern) == "--x"){ consoleLabel='dropflag'; drop=value; if(drop == 'true'){dropflag=' --drop ';} }
	if(consoleLabel != ''){console.log(consoleLabel + ": " + value);}
});

// build and run command
// example:
// mongoimport --db crd --collection diagnosis --drop --file primer-dataset.json
var command = 'mongoimport --db ' + database + '--collection ' + collection + dropflag + '--file ' + input; 
var code = execSync(command);

function help(){
	console.log("crdimport.js - imports JSON file to mongodb");
	console.log("options:");
	console.log("	--i <name of inport file>");
	console.log("	--d <database>");
	console.log("	--c <collection>");
	console.log("	--x <true|false to drop existing>");
	console.log("	--h <help>");
	return;	
}