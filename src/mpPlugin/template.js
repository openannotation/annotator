"use strict";

var Handlebars = require('handlebars');
var extend = require('backbone-extend-standalone');
var Template = function(){console.log("success");};
var $ = require('jquery');

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
        type:"dropdown",
        name:"Relationship: ",
        id:"relationship",
        options:["interact with","inhibits","substrate of"],
        optionsID:["r0","r1","r2"]
      },
      {
        type:"dropdown",
        name:"Precipitant: ",
        id:"Drug2",
        options:[],
        optionsID:[]
      },
      {
        type:"dropdown",
        name:"Method: ",
        id:"method",
        options:["DDI clinical trial"],
        optionsID:["clinical"]
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
      // {
      //   type:"textarea",
      //   name:"Comment: ",
      //   id:"Comment"
      // },
      {
        type:"space",
        name:"",
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

// Handlebars.registerHelper('buildForm3', function(items, options) {
//   var out = "";
//   out += "<strong>"+items[0].name+"</strong>";
//   out += "<input type='text' id='"+items[0].id+"'>";
//   out += "<table class='clear-user-agent-styles auc'>";
//   for(var i=1, l=items.length; i<l; i++) {
//     if((i-1)%4==0)
//       out += "<tr>";
//     if(items[i].type=="text")
//       out += "<td><strong>"+items[i].name+"</strong></td>";
//     else if(items[i].type=="input")
//       out += "<td>"+items[i].name + "<input style='width:30px;' type='text' id='"+items[i].id+"'></td>";
//     else if(items[i].type=="dropdown") {
//       out += "<td>"+items[i].name + "<select id='" + items[i].id + "'>";
//       for(var j=0, jl=items[i].options.length;j<jl;j++)
//       {
//         out += "<option value='"+items[i].options[j] +"'>"+ items[i].options[j]+"</option>";
//       }
//       out += "</select></td>";
//       if(i%4==0)
//         out += "</tr>";
//     }
//   }
//   return out + "</table>";
// });

// Handlebars.registerHelper('buildForm2', function(items, options) {
//   var out = "";
//   for(var i=0, l=items.length; i<l; i++) {
//     if(items[i].type=="text")
//       out += "<strong id='"+items[i].id+"'></strong><br>";
//     else if(items[i].type=="input")
//       out += items[i].name + "<input style='width:30px;' type='text' id='"+items[i].id+"'>";
//     else if(items[i].type=="dropdown") {
//       out += items[i].name + "<select id='" + items[i].id + "'>";
//       for(var j=0, jl=items[i].options.length;j<jl;j++)
//       {
//         out += "<option value='"+items[i].options[j] +"'>"+ items[i].options[j]+"</option>";
//       }
//       out += "</select>";
//       if(items[i].id=="RegimentsP"||items[i].id=="RegimentsO")
//         out += "<br>";
//     }
//   }
//   return out;
// });

var source = "{{#buildForm1 questions}}{{/buildForm1}}";
var template = Handlebars.compile(source);
var form1 = template(context1);

Template.content = [
  '<div class="annotator-outer annotator-editor annotator-invert-y annotator-invert-x">',
  //'<div class="annotator-outer annotator-editor" style="bottom:50px; right:100px">',
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
