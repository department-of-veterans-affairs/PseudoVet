// PseudoVet - Core Reference Database Converter
// Name:	crdconverter.js
// Author: 	Will BC Collins IV for Department of Veterans Affairs
// Purpose:	This utility is for converting text files to json
//			with output json files formatted in a useful way
//			for the PseudoVet Core Reference Database
// Date:	last modified: 2015-06-29

var fs=require("graceful-fs");

console.log("\ncrdconverter.js - PseudoVet :: Core Reference Database Converter");
console.log("\tWritten by: Will BC Collins IV for Dept Veterans Affairs\n");

var input=''; var numLines=0;
var output='';
var fields='';
var skip='';
var label='';
var delimiter=''; var delimiterName='';
var close='';

// process.argv
process.argv.forEach(function (val, index, array) {
	// set up regular expression pattern matching for arguments		
	var inputPattern = new RegExp(/^\-\-i$/); // --i <input file>
	var outputPattern = new RegExp(/^\-\-o$/); // --o <output json file>
	var labelPattern = new RegExp(/^\-\-l$/); // --l <data nesting label>
	var fieldPattern = new RegExp(/^\-\-f$/); // --f <list of fields>
	var delimiterPattern = new RegExp(/^\-\-d$/); // --d <delimiter: comma space tab>
	var fieldSkipPattern = new RegExp(/^\-\-x$/); // --x <fields to skip>
	var helpPattern = new RegExp(/^\-\-h$/); // --h help
	var consoleLabel=''; var value=process.argv[index+1];

	// set global variables for file conversion
	if(val.match(helpPattern) == "--h"){ 
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
		// delete output file if it exists
		//fs.exists(output, function(exists){
		//	console.log("File Exists.  Deleting: "+ output);
		//	fs.unlink(output);
		//});
	}
	if(val.match(labelPattern) == "--l"){
		consoleLabel='label'; label=value;
	}
	if(val.match(fieldPattern) == "--f"){
		consoleLabel='fields'; fields=value;
	}
	if(val.match(fieldSkipPattern) == "--x"){
		consoleLabel='skip fields'; skip=value;
	}
	if(val.match(delimiterPattern) == "--d"){
		consoleLabel='delimiter'; delimiterName=value;
		if(delimiterName == 'comma'){delimiter=',';}
		else if(delimiterName == 'space'){delimiter=' ';}
		else if(delimiterName == 'carrot'){delimiter='^';}
		else if(delimiterName == 'tab'){delimiter='\t';}
		else{delimiterName='comma'; delimiter=',';}
	}
	if(consoleLabel != ''){console.log(consoleLabel + ": " + value);}
});

// todo: check parameters to make sure we have enough information to proceed

// split skip and fields into arrays and get the number of fields
var fieldArray=fields.split(','); var numFields=fieldArray.length;
var skipArray=''; if(skip != null){skipArray=skip.split(',');}

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
  // put closing tags into output json document
  fs.appendFileSync(output,close);
}

function append(data){
	++numLines;

	var lineOut='';

	console.log(data);

	// split a line of data by delimiter
	var dataArray=data.split(delimiter);
	
	// here we care about fields...
	var allowedFieldsArray=[];
	for(var i=0; i < fieldArray.length; ++i){
		var skipfield = false;
		for(var s=0; s < skipArray.length; s++){
			if(fieldArray[i] == skipArray[s]){ skipfield = true; }
		}
		if(skipfield == false){ allowedFieldsArray.push(i); }
	}
	
	if(allowedFieldsArray.length == 0){ console.log("There is nothing to do because no field data is available to convert."); return; }
  else if(allowedFieldsArray.length == 1){
		var field=allowedFieldsArray[0];
		if(numLines == 1){lineOut='{\n\t\"'+label+'\": {\n\t\t\"'+fieldArray[field]+'\": [ '; close='\n\t\t]\n\t}\n}';}else{lineOut=',';}
		lineOut+='\n\t\t\t\"'+dataArray[field]+'\" ';
	}
	else{
		// todo: add a way to deal with deeper nesting from a comma-delimited label
		if(numLines == 1){lineOut='{\n\t\"'+label+'\": [\n\t\t{'; close='\n\t]\n}';}else{lineOut=',\n\t\t{';}
		for(var i=0; i < allowedFieldsArray.length; ++i){
			if(i > 0){ lineOut+=',';}
			var data=dataArray[allowedFieldsArray[i]]; data=data.substring(0,data.length -1);
			lineOut+='\n\t\t\t\"'+fieldArray[allowedFieldsArray[i]]+'\": \"'+ data + '\"';
		}
		lineOut+='\n\t\t}';
	}

	// output to JSON file	
	if(lineOut == null || lineOut == ''){
		console.log('Nothing to write...');
	}
	else{
		fs.appendFileSync(output,lineOut);
	}
}

function help() {
	console.log("crdimport.js - converts text files to json");
	console.log("options:");
	console.log("	--i <name of input file>");
	console.log("	--l <data nesting label>");
	console.log("	--o <name of output json file>");
	console.log("	--f <list of fields from input file>");
	console.log("	--d <delimiter: comma space tab");
	console.log("	--x <list of fileds to skip>");
	return;
}
