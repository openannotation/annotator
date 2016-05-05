"use strict";

var Handlebars = require('handlebars');
var extend = require('backbone-extend-standalone');
var Template = function(){console.log("success");};
var $ = require('jquery');

// JSON fields configuration
// Claim form
var context1 = {
    questions: [
      {
        type:"dropdown",
        name:"Drug1: ",
        id:"Drug1",
        options:[],
        optionsID:[]
      },
      {
        type:"dropdown",
        name:"Relationship: ",
        id:"relationship",
        options:["interact with","inhibits","substrate of"],
        optionsID:["r0","r1","r2"]
      },
      {
        type:"dropdown",
        name:"Method: ",
        id:"method",
        options:["DDI clinical trial"],
        optionsID:["clinical"]
      },
      {
        type:"dropdown",
        name:"Drug2: ",
        id:"Drug2",
        options:[],
        optionsID:[]
      },
      {
        type:"dropdown",
        name:"Enzyme: ",
        id:"enzyme",
        options:["cyp1a1","cyp1a2","cyp1b1","cyp2a6","cyp2a13","cyp2b6","cyp2c8","cyp2c9","cyp2c19","cyp2d6","cyp2e1","cyp2j2","cyp3a4","cyp3a5","cyp4a11","cyp2c8","cyp2c9","cyp2c19"],
        optionsID:[]
      },
      {
        type:"space",
        name:"",
      },
      {
        type:"space",
        name:"",
      }
    ]
};

// Data - Number of participants form
var context2 = {
  questions: [
      {
          type: "input",
          name: "Number of Participants: ",
          id: "participants"
      }
  ]
};


// handlerbar - build form1 function
// @inputs: JSON config - context1
// @outputs: form1 in html
Handlebars.registerHelper('buildForm1', function(items, options) {
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

  return out;
});

Handlebars.registerHelper('buildForm2', function(items, options) {
    var out = "";
    for(var i=0, l=items.length; i<l; i++) {
        if(items[i].type=="text")
            out += "<strong id='"+items[i].id+"'></strong><br>";
        else if(items[i].type=="input")
            out += items[i].name + "<input style='width:30px;' type='text' id='"+items[i].id+"'>";
    }
    return out;
});


// Claim
var source = "{{#buildForm1 questions}}{{/buildForm1}}";
var template = Handlebars.compile(source);
var form1 = template(context1);

// Data - number of participants
source = "{{#buildForm2 questions}}{{/buildForm2}}";
template = Handlebars.compile(source);
var form2 = template(context2);



Template.content = [
    '<div class="annotator-outer annotator-editor annotator-invert-y annotator-invert-x">',
    '<form class="annotator-widget">',
    '<ul class="annotator-listing"></ul>',
    '<div class="annotationbody" style="margin-left:5px;margin-right:0px;height:100%;line-height:200%;margin-top:0px;overflow-y: hidden">',
    '<div id="tabs">',
    '<div id="tabs-1" style="margin-bottom:0px;">',
    
    // Claim form
    '<div id="mp-claim-form" style="margin-top:10px;margin-left:5px;">',
    '<div onclick="flipdrug()" style="float:left" class="flipicon"></div>',
    '<table class="clear-user-agent-styles">',
    form1,
    '</table>',
    '</div>',
    
    // Data & material - Num of Participants
    '<div id="mp-data-form-np" style="margin-top:10px;margin-left:5px;">',
    form2,
    '</div>',
    
    '</div>',
    '</div>',
    '</div>',
    '    <div class="annotator-controls1">',
    '     <a href="#cancel" class="annotator-cancel" onclick="showrightbyvalue()" id="annotator-cancel">Cancel</a>',
    '     <a href="#save" class="annotator-save annotator-focus" onclick="showrightbyvalue()">Save</a>',
  '    </div>',
    '  </form>',
    '</div>'
].join('\n');


Template.extend = extend;
exports.Template = Template;
