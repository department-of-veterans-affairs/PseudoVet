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

var input=''; var numLines=0;
var output='';
var fields='';
var skip='';
var label='';
var delimiter=''; var delimiterName='';

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
	if(val.match(helpPattern) == "--h"){ help(); } 
    if(val.match(inputPattern) == "--i"){
		consoleLabel='input file'; input = fs.createReadStream(value);
	}
	if(val.match(outputPattern) == "--o"){
		consoleLabel='output file'; output = value; 
		// fs.createWriteStream(value);
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

// todo: get number of lines of input file
fs.createReadStream(input).on('data',function readStreamOnData(chunk){
	numLines += chunk
		.toString('utf8')
		.split(/\r\n|[\n\r\u0085\u2028\u2029]/g)
		.length-1;
});

// setup output file to be json
var prependlabel=''; if(label != null){ prependlabel='\t\"'+label+'\": {\n'; }
var postpendlabel=''; if(label != null){ postpendlabel='\t}\n'; }

// put opening json tags into output file
fs.appendFile(output,"{\n"+prependlabel,function(err){ if(err) throw err; });

// process input file
readLines(input, append);

// -------------- functions ---------------
function readLines(input, append) {
	var remaining = '';
	input.on('data', function(data) {
		remaining += data;
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
			append(remaining);
		}
		else{
			// remove last , on last line
			
			// put closing tags into output json document
			fs.appendFile(output,postpendlabel+'}\n',function(err){ if(err) throw err; });
		}
	});
}

function append(data){
	console.log(data);
	var jsondata='';
	// manipulate data to append json format

	// split a line of data by delimiter
	var dataArray=data.split(delimiter);
	
	// here we care about fields...
	for(var i=0; i < fieldArray.length; i++){
		var skipfield=false;
		for(var s=0; s < skipArray.length; s++){
			if(fieldArray[i] == skipArray[s]){
				skipfield=true;
			}
		}
		if(skipfield == false){
			if(i==0){
				fs.appendFile(output,'\t\t\"'+fieldArray[i]+'\": "'+dataArray[i]+'\",\n',function(err){
					if(err) throw err;
				});
			}
// deal with more fields...
//			else{
//				fs.appendFile(output,'\t, {}')
//			}
		}
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
