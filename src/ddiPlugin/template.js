"use strict";

var Handlebars = require('handlebars');
var fs = require("fs");
var extend = require('backbone-extend-standalone');
var Template = function(){console.log("success");};
var $ = require('jquery');
//var source = "<p>Hello, my name is {{name}}. I am from {{hometown}}. I have " +
//    "{{kids.length}} kids:</p>" +
//    "<ul>{{#kids}}<li>{{name}} is {{age}}</li>{{/kids}}</ul>";
//var template = Handlebars.compile(source);
//var source   = $("#entry-template").html();
//var template = Handlebars.compile(source);
var data = { "name": "Alan", "hometown": "Somewhere, TX",
  "kids": [{"name": "Jimmy", "age": "12"}, {"name": "Sally", "age": "4"}]};

//Template.result = template(data);
/*var content;
// First I want to read the file
fs.readFile('./test.html', function read(err, data) {
  if (err) {
    throw err;
  }
  content = data;

  // Invoke the next step here however you like
  console.log(content);   // Put all of the code here (not the best solution)
  //processFile();          // Or put the next step in a function and invoke it
});*/


var context1 = {
    questions: [
      {
        type:"dropdown",
        name:"Object: ",
        id:"Drug1",
        options:[],
        optionsID:[]
      },
      {
        type:"checkbox",
        name:"Type: ",
        id:"Type1",
        options:["active ingredient", "metabolite", "drug product", "drug group"]
      },
      {
        type:"checkbox",
        name:"Evidence: ",
        id:"Evidence_modality",
        options:["for", "against"]
      },
      {
        type:"dropdown",
        name:"Precipitant: ",
        id:"Drug2",
        options:[],
        optionsID:[]
      },
      {
        type:"checkbox",
        name:"Type: ",
        id:"Type2",
        options:["active ingredient", "metabolite", "drug product", "drug group"]
      },
      {
        type:"checkbox",
        name:"Modality: ",
        id:"Modality",
        options:["Positive", "Negative"]
      },
      {
        type:"dropdown",
        name:"Relationship: ",
        id:"relationship",
        options:["interact with","inhibit","substrate of"],
        optionsID:["r2","r0","r1"]
      },
      {
        type:"dropdown",
        name:"Assertion Type: ",
        id:"assertion_type",
        options:["Drug Drug Interaction","DDI clinical trial"],
        optionsID:["DDI","clinical"]
      },
      {
        type:"space",
        name:"",
      },
      {
        type:"dropdown",
        name:"Enzyme: ",
        id:"enzyme",
        options:["cyp1a1","cyp1a2","cyp1b1","cyp2a6","cyp2a13","cyp2b6","cyp2c8","cyp2c9","cyp2c19","cyp2d6","cyp2e1","cyp2j2","cyp3a4","cyp3a5","cyp4a11","cyp2c8","cyp2c9","cyp2c19"],
        optionsID:[]
      },
      {
        type:"textarea",
        name:"Comment: ",
        id:"Comment"
      },
      {
        type:"space",
        name:"",
      }
    ]
};

Handlebars.registerHelper('buildForm', function(items, options) {
  var out = "";

  for(var i=0, l=items.length; i<l; i++) {
    if(((i)%3==0))
      out = out + "<tr>";
    if(items[i].id!="enzyme")
      out = out + "<td><strong>" + items[i].name +"</strong></td><td>";
    else
      out = out + "<td><strong id='enzymesection1'>" + items[i].name +"</strong></td><td>";
    if(items[i].type=="checkbox")
    {
      for (var j = 0, sl = items[i].options.length; j < sl; j++)
        out = out + "<input type='radio' name='" + items[i].id + "' id='" + items[i].id + "' class='" + items[i].id + "' value='" + items[i].options[j] + "'>" + items[i].options[j] + "</input>";

    }else if(items[i].type=="dropdown")
    {
      out = out + "<select id='" + items[i].id + "'>";
      for(var j = 0, sl = items[i].options.length; j<sl; j++) {
        if(items[i].optionsID.length==0)
          out = out + "<option value='" + items[i].options[j] + "'>" + items[i].options[j] + "</option>";
        else
          out = out + "<option id='" + items[i].optionsID[j] + "' value='" + items[i].options[j] + "'>" + items[i].options[j] + "</option>";
      }
      out = out + "</select>";

    }else if(items[i].type=="textarea")
    {
      out = out + "<textarea id='" + items[i].id + "' class='" + items[i].id + "'></textarea>";
    }

    out = out + "</td>";
    if(((i+1)%3==0))
      out = out + "</tr>";
  }

  return out + "";
});

var source = "{{#buildForm questions}}{{/buildForm}}";

var template = Handlebars.compile(source);

var form1 = template(context1);

Template.content = [
  '<div class="annotator-outer annotator-editor annotator-invert-y annotator-invert-x">',
  '  <form class="annotator-widget">',
  '    <ul class="annotator-listing"></ul>',
  '<div class="annotationbody" style="margin-left:5px;margin-right:0px;height:100%;line-height:200%;margin-top:0px;overflow-y: hidden">',
  '<div id="tabs">',

  '<div id="tabs-1" style="margin-bottom:0px;">',
  '<div id="firstsection" style="margin-top:10px;margin-left:5px;">',
  '<div onclick="flipdrug()" style="float:left" class="flipicon"></div>',
  '<table class="clear-user-agent-styles">',

  form1,

  '</table>',

  '</div>',

  '<div id = "altersection" style="display: none;">',

  '<div style="float:left;margin-right: 15px">',


  '<div><strong>Clinical Trial: </strong><strong id="modalityinalter"></strong>&nbsp<strong id="evidenceinalter"></strong></div>',
  '<strong id="objectinalter"></strong>',
  '<div>',
  'Dose in MG: <input style="width:30px;" type="text" id="DoseMG_precipitant">',
  'Formulation: <select id="FormulationP">',
  '<option value="UNK">UNK</option>',
  '<option value="Oral">Oral</option>',
  '<option value="IV">IV</option>',
  '<option value="transdermal">transdermal</option>',
  '</select>',
  'Duration(days): <input style="width:30px;" type="text" id="Duration_precipitant">',
  'Regiments: <select id="RegimentsP">',
  '<option value="UNK">UNK</option>',
  '<option value="SD">SD</option>',
  '<option value="QD">QD</option>',
  '<option value="BID">BID</option>',
  '<option value="TID">TID</option>',
  '<option value="QID">QID</option>',
  '<option value="Q12">Q12</option>',
  '<option value="Q8">Q8</option>',
  '<option value="Q6">Q6</option>',
  '<option value="Daily">Daily</option>',
  '</select>',
  '</div>',

  '<strong id="preciptinalter"></strong>',
  '<div>',
  'Dose in MG: <input style="width:30px;" type="text" id="DoseMG_object">',
  'Formulation: <select id="FormulationO">',
  '<option value="UNK">UNK</option>',
  '<option value="Oral">Oral</option>',
  '<option value="IV">IV</option>',
  '<option value="transdermal">transdermal</option>',
  '</select>',
  'Duration(days): <input style="width:30px;" type="text" id="Duration_object">',
  'Regiments: <select id="RegimentsO">',
  '<option value="UNK">UNK</option>',
  '<option value="SD">SD</option>',
  '<option value="QD">QD</option>',
  '<option value="BID">BID</option>',
  '<option value="TID">TID</option>',
  '<option value="QID">QID</option>',
  '<option value="Q12">Q12</option>',
  '<option value="Q8">Q8</option>',
  '<option value="Q6">Q6</option>',
  '<option value="Daily">Daily</option>',
  '</select>',
  '</div></div>',
  '<div><div><strong>The number of participants: </strong>',
  '<input type="text" id="Number_participants">',
  '</div>',
  '<table class="clear-user-agent-styles auc"><tr><td width="70px"><strong>AUC_i/AUC: </strong></td>',
  '<td>Auc: <input style="width:30px;" type="text" id="Auc"></td>',
  '<td>Type: <select id="AucType">',
  '<option value="UNK">UNK</option>',
  '<option value="Percent">Percent</option>',
  '<option value="Fold">Fold</option>',
  '</select></td>',
  '<td>Direction: <select id="AucDirection">',
  '<option value="UNK">UNK</option>',
  '<option value="Increase">Increase</option>',
  '<option value="Decrease">Decrease</option>',
  '</select>',
  '</td></tr>',

  '<tr><td width="70px"><strong>CL_i/CL: </strong></td>',
  '<td>Cl: <input style="width:30px;" type="text" id="Cli"></td>',
  '<td>Type: <select id="ClType">',
  '<option value="UNK">UNK</option>',
  '<option value="Percent">Percent</option>',
  '<option value="Fold">Fold</option>',
  '</select></td>',
  '<td>Direction: <select id="ClDirection">',
  '<option value="UNK">UNK</option>',
  '<option value="Increase">Increase</option>',
  '<option value="Decrease">Decrease</option>',
  '</select>',
  '</td></tr>',

  '<tr><td width="70px"><strong>Cmax:</strong></td>',
  '<td>cmax: <input style="width:30px;" type="text" id="cmax"></td>',
  '<td>Type: <select id="cmaxType">',
  '<option value="UNK">UNK</option>',
  '<option value="Percent">Percent</option>',
  '<option value="Fold">Fold</option>',
  '</select></td>',
  '<td>Direction: <select id="cmaxDirection">',
  '<option value="UNK">UNK</option>',
  '<option value="Increase">Increase</option>',
  '<option value="Decrease">Decrease</option>',
  '</select>',
  '</td></tr>',

  '<tr><td width="70px"><strong>Cmin:</strong></td>',
  '<td>cmin: <input style="width:30px;" type="text" id="cmin"></td>',
  '<td>Type: <select id="cminType">',
  '<option value="UNK">UNK</option>',
  '<option value="Percent">Percent</option>',
  '<option value="Fold">Fold</option>',
  '</select></td>',
  '<td>Direction: <select id="cminDirection">',
  '<option value="UNK">UNK</option>',
  '<option value="Increase">Increase</option>',
  '<option value="Decrease">Decrease</option>',
  '</select>',
  '</td></tr>',

  '<tr><td width="70px"><strong>T1/2:</strong></td>',
  '<td>t12: <input style="width:30px;" type="text" id="t12"></td>',
  '<td>Type: <select id="t12Type">',
  '<option value="UNK">UNK</option>',
  '<option value="Percent">Percent</option>',
  '<option value="Fold">Fold</option>',
  '</select></td>',
  '<td>Direction: <select id="t12Direction">',
  '<option value="UNK">UNK</option>',
  '<option value="Increase">Increase</option>',
  '<option value="Decrease">Decrease</option>',
  '</select>',
  '</td></tr>',


  '</table></div>',
  '</div>',
  '</div>',

  '</div>',
  '</div>',
  '    <div class="annotator-controls1">',
  '     <a href="#cancel" class="annotator-cancel" onclick="showrightbyvalue()" id="annotator-cancel">',
  'Cancel',
  '</a>',
  '      <a href="#save"',
  '         class="annotator-save annotator-focus" onclick="showrightbyvalue()">',
  'Save',
  '</a>',
  '         <a class="annotator-back" id="back" onclick="backtofirst()" style="display:none">',
  'Back',
  '</a>',
  '         <a class="annotator-next" id="forward" onclick="forwardtosecond()" style="display:none">',
  'Next',
  '</a>',
  '    </div>',
  '  </form>',
  '</div>'
].join('\n');


Template.extend = extend;
exports.Template = Template;
