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
		
	var inputPattern = new RegExp(/^\-\-i$/); // --i <input file>
	var outputPattern = new RegExp(/^\-\-o$/); // --o <output json file>
	var fieldPattern = new RegExp(/^\-\-f$/); // --f <list of fields>
	var delimiterPattern = new RegExp(/^\-\-d$/); // --d <delimiter: comma space tab>
	var fieldSkipPattern = new RegExp(/^\-\-x$/); // --x <fields to skip>
	var helpPattern = new RegExp(/^\-\-h$/); // --h help

	if(val.match(helpPattern) == "--h"){ help(); } 
    if(val.match(inputPattern) == "--i"){
		input = fs.createReadStream(process.argv[index+1]);
		console.log("input file: " + process.argv[index+1]);
	}
	if(val.match(outputPattern) == "--o"){
		output = fs.createWriteStream(process.argv[index+1]);
		console.log("output file: " + process.argv[index+1]);
	}
	if(val.match(fieldPattern) == "--f"){
		fields=process.argv[index+1];
		console.log("fields: " + fields);
	}
	if(val.match(fieldSkipPattern) == "--x"){
		skip=process.argv[index+1];
		console.log("skip fields: "+ skip);
	}
	if(val.match(delimiterPattern) == "--d"){
		delimiter=process.argv[index+1];
		console.log("delimiter: "+ delimiter);
	}
	
});


//readLines(input, func);

// this is a placeholder for writing files
function writeFile (outputFileName, inputData) {
	fs.writeFile (savPath, data, function(err) {
		if (err) throw err;
		console.log('complete');
	});
}

// -------------- functions ---------------
function readLines(input, func) {
	var remaining = '';
	input.on('data', function(data) {
		remaining += data;
		var index = remaining.indexOf('\n');
		while (index > 1) {
			var line = remaining.substring(0, index);
			remaining = remaining.substring(index + 1);
			func(line);
			index = remaining.indexOf('\n');
		}
	});
	input.on('end', function() {
		if (remaining.length > 0){
			func(remaining);
		}
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
