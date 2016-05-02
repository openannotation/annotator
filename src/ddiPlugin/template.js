"use strict";

var Handlebars = require('handlebars');
//var fs = require("fs");
var extend = require('backbone-extend-standalone');
var Template = function(){console.log("success");};
var $ = require('jquery');
//var source = "<p>Hello, my name is {{name}}. I am from {{hometown}}. I have " +
//    "{{kids.length}} kids:</p>" +
//    "<ul>{{#kids}}<li>{{name}} is {{age}}</li>{{/kids}}</ul>";
//var template = Handlebars.compile(source);
//var source   = $("#entry-template").html();
//var template = Handlebars.compile(source);
/*var data = { "name": "Alan", "hometown": "Somewhere, TX",
  "kids": [{"name": "Jimmy", "age": "12"}, {"name": "Sally", "age": "4"}]};*/

// JSON fields configuration - define form
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
        options:["interact with","inhibits","substrate of"],
        optionsID:["r0","r1","r2"]
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

var context2 = {
  questions: [
    {
      type: "text",
      id: "objectinalter"
    },
    {
      type: "input",
      name: "Dose in MG: ",
      id: "DoseMG_object"
    },
    {
      type: "dropdown",
      name: "Formulation: ",
      id: "FormulationO",
      options:["UNK","Oral","IV","transdermal"]
    },
    {
      type: "input",
      name: "Duration(days): ",
      id: "Duration_object"
    },
    {
      type: "dropdown",
      name: "Regiments: ",
      id: "RegimentsO",
      options:["UNK","SD","QD","BID","TID","QID","Q12","Q8","Q6","Daily"]
    },
    {
      type: "text",
      id: "preciptinalter"
    },
    {
      type: "input",
      name: "Dose in MG: ",
      id: "DoseMG_precipitant"
    },
    {
      type: "dropdown",
      name: "Formulation: ",
      id: "FormulationP",
      options:["UNK","Oral","IV","transdermal"]
    },
    {
      type: "input",
      name: "Duration(days): ",
      id: "Duration_precipitant"
    },
    {
      type: "dropdown",
      name: "Regiments: ",
      id: "RegimentsP",
      options:["UNK","SD","QD","BID","TID","QID","Q12","Q8","Q6","Daily"]
    }
  ]
};

var context3 = {
  questions: [
    {
      type: "input",
      name: "Number of participants: ",
      id: "Number_participants"
    },
    {
      type: "text",
      name: "AUC_i/AUC: "
    },
    {
      type: "input",
      name: "Auc: ",
      id: "Auc"
    },
    {
      type: "dropdown",
      name: "Type: ",
      id: "AucType",
      options:["UNK","Percent","Fold"]
    },
    {
      type: "dropdown",
      name: "Direction: ",
      id: "AucDirection",
      options:["UNK","Increase","Decrease"]
    },
    {
      type: "text",
      name: "CL_i/CL: "
    },
    {
      type: "input",
      name: "Cl: ",
      id: "Cli"
    },
    {
      type: "dropdown",
      name: "Type: ",
      id: "ClType",
      options:["UNK","Percent","Fold"]
    },
    {
      type: "dropdown",
      name: "Direction: ",
      id: "ClDirection",
      options:["UNK","Increase","Decrease"]
    },
    {
      type: "text",
      name: "Cmax: "
    },
    {
      type: "input",
      name: "cmax: ",
      id: "cmax"
    },
    {
      type: "dropdown",
      name: "Type: ",
      id: "cmaxType",
      options:["UNK","Percent","Fold"]
    },
    {
      type: "dropdown",
      name: "Direction: ",
      id: "cmaxDirection",
      options:["UNK","Increase","Decrease"]
    },
    {
      type: "text",
      name: "Cmin: "
    },
    {
      type: "input",
      name: "cmin: ",
      id: "cmin"
    },
    {
      type: "dropdown",
      name: "Type: ",
      id: "cminType",
      options:["UNK","Percent","Fold"]
    },
    {
      type: "dropdown",
      name: "Direction: ",
      id: "cminDirection",
      options:["UNK","Increase","Decrease"]
    },
    {
      type: "text",
      name: "T1/2: "
    },
    {
      type: "input",
      name: "t12: ",
      id: "t12"
    },
    {
      type: "dropdown",
      name: "Type: ",
      id: "t12Type",
      options:["UNK","Percent","Fold"]
    },
    {
      type: "dropdown",
      name: "Direction: ",
      id: "t12Direction",
      options:["UNK","Increase","Decrease"]
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

Handlebars.registerHelper('buildForm3', function(items, options) {
  var out = "";
  out += "<strong>"+items[0].name+"</strong>";
  out += "<input type='text' id='"+items[0].id+"'>";
  out += "<table class='clear-user-agent-styles auc'>";
  for(var i=1, l=items.length; i<l; i++) {
    if((i-1)%4==0)
      out += "<tr>";
    if(items[i].type=="text")
      out += "<td><strong>"+items[i].name+"</strong></td>";
    else if(items[i].type=="input")
      out += "<td>"+items[i].name + "<input style='width:30px;' type='text' id='"+items[i].id+"'></td>";
    else if(items[i].type=="dropdown") {
      out += "<td>"+items[i].name + "<select id='" + items[i].id + "'>";
      for(var j=0, jl=items[i].options.length;j<jl;j++)
      {
        out += "<option value='"+items[i].options[j] +"'>"+ items[i].options[j]+"</option>";
      }
      out += "</select></td>";
      if(i%4==0)
        out += "</tr>";
    }
  }
  return out + "</table>";
});

Handlebars.registerHelper('buildForm2', function(items, options) {
  var out = "";
  for(var i=0, l=items.length; i<l; i++) {
    if(items[i].type=="text")
      out += "<strong id='"+items[i].id+"'></strong><br>";
    else if(items[i].type=="input")
      out += items[i].name + "<input style='width:30px;' type='text' id='"+items[i].id+"'>";
    else if(items[i].type=="dropdown") {
      out += items[i].name + "<select id='" + items[i].id + "'>";
      for(var j=0, jl=items[i].options.length;j<jl;j++)
      {
        out += "<option value='"+items[i].options[j] +"'>"+ items[i].options[j]+"</option>";
      }
      out += "</select>";
      if(items[i].id=="RegimentsP"||items[i].id=="RegimentsO")
        out += "<br>";
    }
  }
  return out;
});

var source = "{{#buildForm1 questions}}{{/buildForm1}}";
var template = Handlebars.compile(source);
var form1 = template(context1);

source = "{{#buildForm2 questions}}{{/buildForm2}}";
template = Handlebars.compile(source);
var form2 = template(context2);

source = "{{#buildForm3 questions}}{{/buildForm3}}";
template = Handlebars.compile(source);
var form3 = template(context3);

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
  '<div><strong>Clinical Trial: </strong><br>',
  '<strong id="modalityinalter"></strong>&nbsp<strong id="evidenceinalter"></strong></div>',

  form2,

  '</div>',
  '<div>',

  form3,

  '</div>',
  '</div>',
  '</div>',
  '</div>',
  '</div>',
  '    <div class="annotator-controls1">',
  '     <a href="#cancel" class="annotator-cancel" onclick="showrightbyvalue()" id="annotator-cancel">Cancel</a>',
  '     <a href="#save" class="annotator-save annotator-focus" onclick="showrightbyvalue()">Save</a>',
  '     <a class="annotator-back" id="back" onclick="backtofirst()" style="display:none">Back</a>',
  '     <a class="annotator-next" id="forward" onclick="forwardtosecond()" style="display:none">Next</a>',
  '    </div>',
  '  </form>',
  '</div>'
].join('\n');


Template.extend = extend;
exports.Template = Template;
