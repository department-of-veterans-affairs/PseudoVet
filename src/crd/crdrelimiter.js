// PseudoVet - Core Reference Database Relimiter
// Name:	crdrelimiter.js
// Author: 	Will BC Collins IV for Department of Veterans Affairs
// Purpose:	This utility is for reformating delimiters in reference 
//          data files for the PseudoVet Core Reference Database
// Date:	last modified: 2015-07-08

var fs=require("graceful-fs");

console.log("\ncrdrelimiter.js - PseudoVet :: Core Reference Database Relimiter");
console.log("\tWritten by: Will BC Collins IV for Dept Veterans Affairs\n");

var input=''; var numLines=0;
var output='';
var occurances='';
var relimiter=''; var relimiterName='';
var delimiter=''; var delimiterName='';

// process.argv
process.argv.forEach(function (val, index, array) {
	// set up regular expression pattern matching for arguments		
	var helpPattern = new RegExp(/^\-\-h$/); // --i <input file>
	var inputPattern = new RegExp(/^\-\-i$/); // --i <input file>
	var outputPattern = new RegExp(/^\-\-o$/); // --o <output file>
	var delimiterPattern = new RegExp(/^\-\-d$/); // --d <delimiter: comma space tab>
	var relimiterPattern = new RegExp(/^\-\-r$/); // --r <relimiter>
	var occurancePattern = new RegExp(/^\-\-n$/); // --n <number of times to re define delimiters per line>
	var consoleLabel=''; var value=process.argv[index+1];

	// set global variables for file conversion
	if(val.match(helpPattern) == "--h"){ 
		//consoleLabel='help';
		help();
	}
  if(val.match(inputPattern) == "--i"){
		consoleLabel='input file'; input = value;
	}
	if(val.match(outputPattern) == "--o"){
		consoleLabel='output file'; output = value;
		var csvpattern = new RegExp(/\.csv$/);
		if(output.match(csvpattern) == '.csv'){
			delimiter=',';
		}
	}
	if(val.match(delimiterPattern) == "--d"){
		consoleLabel='delimiter'; delimiterName=value;
		if(delimiterName == 'comma'){delimiter=',';}
		else if(delimiterName == 'space'){delimiter=' ';}
		else if(delimiterName == 'carrot'){delimiter='^';}
		else if(delimiterName == 'tilde'){delimiter='~';}
		else if(delimiterName == 'tab'){delimiter='\t';}
		else{delimiterName='comma'; delimiter=',';}
	}
	if(val.match(relimiterPattern) == "--r"){
		consoleLabel='relimiter'; relimiterName=value;
		if(relimiterName == 'comma'){relimiter=',';}
		else if(relimiterName == 'space'){relimiter=' ';}
		else if(relimiterName == 'carrot'){relimiter='^';}
		else if(relimiterName == 'tilde'){relimiter='~';}
		else if(relimiterName == 'tab'){relimiter='\t';}
		else{relimiterName='comma'; relimiter=',';}
	}

	if(val.match(occurancePattern) == "--n"){
		consoleLabel='occurances'; occurances=value;
	}
	
	if(consoleLabel != ''){console.log(consoleLabel + ": " + value);}
});

// todo: check parameters to make sure we have enough information to proceed

// process input file
gobble(input);

// -------------- functions ---------------

function gobble(input){
  var fileContent=fs.readFileSync(input).toString();
  var lineArray=fileContent.split('\n');
  for(var i=0; i<lineArray.length; i++){
		if(lineArray[i].toString() != ''){
      append(lineArray[i].toString()); 
		}
  }	
}

function append(data){
	++numLines;

	var lineOut='';

	//console.log(data);

	// split a line of data by delimiter
	var dataArray=data.split(delimiter);
	
	// here we care about fields...

	for(var i=0; i < dataArray.length; ++i){
		var tempDelimiter=delimiter;
		if(i<occurances){
			tempDelimiter=relimiter;
		}
		lineOut+=dataArray[i]+tempDelimiter;
	}

	// output to output file	
	if(lineOut == null || lineOut == ''){
		console.log('Nothing to write...');
	}
	else{
		fs.appendFileSync(output,lineOut);
		console.log(lineOut);
	}
}

function help() {
	console.log("crdrelimiter.js - changes a number of delimiters per line");
	console.log("options:");
	console.log("	--i <name of input file>");
	console.log("	--o <name of output file>");
	console.log("	--d <data nesting label>");
	console.log("	--d <delimiter: comma space tab>");
	console.log("	--r <relimiter: new delimiter to replace original>");
	console.log("	--n <number of times per line to replace delimiter>");
	return;
}
