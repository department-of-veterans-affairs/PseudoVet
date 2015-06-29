// PseudoVet - Core Reference Database Converter
// Name:	crdconverter.js
// Author: 	Will BC Collins IV for Department of Veterans Affairs
// Purpose:	This utility is for converting text files to json
//			with output json files formatted in a useful way
//			for the PseudoVet Core Reference Database
// Date:	last modified: 2015-06-29

var fs=require("fs");

console.log("\ncrdconverter.js - PseudoVet :: Core Reference Database Converter");
console.log("\tWritten by: Will BC Collins IV for Dept Veterans Affairs\n");

var input='';
var output='';
var fields='';
var delimiter='';

// process.argv
process.argv.forEach(function (val, index, array) {
	// set up regular expression pattern matching for
	// command line arguments		
	var inputPattern = new RegExp(/^\-\-i$/); // --i <input file>
	var outputPattern = new RegExp(/^\-\-o$/); // --o <output json file>
	var fieldPattern = new RegExp(/^\-\-f$/); // --f <list of fields>
	var delimiterPattern = new RegExp(/^\-\-d$/); // --d <delimiter: comma space tab>
	var fieldSkipPattern = new RegExp(/^\-\-x$/); // --x <fields to skip>
	var helpPattern = new RegExp(/^\-\-h$/); // --h help
	var consoleLabel=''; var value=process.argv[index+1];
	// set global variables for file conversion
	if(val.match(helpPattern) == "--h"){ help(); } 
    if(val.match(inputPattern) == "--i"){
		consoleLabel='input file'; input = fs.createReadStream(value);
	}
	if(val.match(outputPattern) == "--o"){
		consoleLabel='output file'; output = fs.createWriteStream(value);
	}
	if(val.match(fieldPattern) == "--f"){
		consoleLabel='fields'; fields=value;
	}
	if(val.match(fieldSkipPattern) == "--x"){
		consoleLabel='skip fields'; skip=value;
	}
	if(val.match(delimiterPattern) == "--d"){
		consoleLabel='delimiter'; delimiter=value;
	}
	if(consoleLabel != ''){console.log(consoleLabel + ": " + value);}
});

//readLines(input, func);

// -------------- functions ---------------
function readLines(input, append) {
	var remaining = '';
	input.on('data', function(data) {
		remaining += data;
		// need to deal with both unix and windows line endings...
		var index = remaining.indexOf('\n');
		while (index > 1) {
			var line = remaining.substring(0, index);
			remaining = remaining.substring(index + 1);
			append(line);
			index = remaining.indexOf('\n');
		}
	});
	input.on('end', function() {
		if (remaining.length > 0){
			// func(remaining);
			append(remaining);
		}
	});
}

function append(data){
	fs.appendFile(output,data,function(err){
		
	});
}
function func(data){
	console.log('Line:' + data);
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
