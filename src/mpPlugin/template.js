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
        options:["UNK","cyp1a1","cyp1a2","cyp1b1","cyp2a6","cyp2a13","cyp2b6","cyp2c8","cyp2c9","cyp2c19","cyp2d6","cyp2e1","cyp2j2","cyp3a4","cyp3a5","cyp4a11","cyp2c8","cyp2c9","cyp2c19"],
        optionsID:[]
      },
      {
        type:"space",
        name:""
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

// Data - Drug 1 dosage form
var context3 = {
    questions: [
        {
            type: "input",
            name: "Dose: ",
            id: "drug1Dose"
        },
        {
            type:"dropdown",
            name:"Formulation: ",
            id:"drug1Formulation",
            options:["UNK","Oral","IV","transdermal"],
            optionsID:[]
        },
        {
            type: "input",
            name: "Duration: ",
            id: "drug1Duration"
        },
        {
            type:"dropdown",
            name:"Regimens: ",
            id:"drug1Regimens",
            options:["UNK","SD","QD","BID", "TID", "QID", "Q12", "Q8", "Q6", "Daily"],
            optionsID:[]
      }
    ]
};

// Data - Drug 2 dosage form
var context4 = {
    questions: [
        {
            type: "input",
            name: "Dose: ",
            id: "drug2Dose"
        },
        {
            type:"dropdown",
        name:"Formulation: ",
            id:"drug2Formulation",
            options:["UNK","Oral","IV","transdermal"],
            optionsID:[]
        },
        {
            type: "input",
            name: "Duration: ",
            id: "drug2Duration"
        },
        {
            type:"dropdown",
            name:"Regimens: ",
            id:"drug2Regimens",
            options:["UNK","SD","QD","BID", "TID", "QID", "Q22", "Q8", "Q6", "Daily"],
            optionsID:[]
        }
    ]
};

// handlerbar - build form1 function
// @inputs: JSON config - context1
// @outputs: form1 in html
Handlebars.registerHelper('buildFormClaim', function(items, options) {
    var out = "";
    
    for (var i=0, l=items.length; i<l; i++) {
        if (((i)%3==0))
            out = out + "<tr>";
        if(items[i].id!="enzyme")
            out = out + "<td><strong>" + items[i].name +"</strong></td><td>";
        else
            out = out + "<td><strong id='enzymesection1'>" + items[i].name +"</strong></td><td>";
        if (items[i].type=="checkbox")
        {
            for (var j = 0, sl = items[i].options.length; j < sl; j++)
                out = out + "<input type='radio' name='" + items[i].id + "' id='" + items[i].id + "' class='" + items[i].id + "' value='" + items[i].options[j] + "'>" + items[i].options[j] + "</input>";
            
        } 
        else if (items[i].type=="dropdown") {
            out = out + "<select id='" + items[i].id + "'>";
            for(var j = 0, sl = items[i].options.length; j<sl; j++) {
                if(items[i].optionsID.length==0)
                    out = out + "<option value='" + items[i].options[j] + "'>" + items[i].options[j] + "</option>";
                else
                    out = out + "<option id='" + items[i].optionsID[j] + "' value='" + items[i].options[j] + "'>" + items[i].options[j] + "</option>";
            }
            out = out + "</select>";
        } 
        else if(items[i].type=="textarea")
        {
            out = out + "<textarea id='" + items[i].id + "' class='" + items[i].id + "'></textarea>";
        }
        out = out + "</td>";
        if(((i+1)%3==0))
            out = out + "</tr>";
    }
    return out;
});

Handlebars.registerHelper('buildFormData', function(items, options) {
    var out = "";
    for(var i=0, l=items.length; i<l; i++) {
        if(items[i].type=="text")
            out += "<strong id='"+items[i].id+"'></strong><br>";
        else if(items[i].type=="input")
            out += items[i].name + "<input style='width:30px;' type='text' id='"+items[i].id+"'>";
        else if (items[i].type=="dropdown") {
            out = out + "<select id='" + items[i].id + "'>";
            for(var j = 0, sl = items[i].options.length; j<sl; j++) {
                if(items[i].optionsID.length==0)
                    out = out + "<option value='" + items[i].options[j] + "'>" + items[i].options[j] + "</option>";
                else
                    out = out + "<option id='" + items[i].optionsID[j] + "' value='" + items[i].options[j] + "'>" + items[i].options[j] + "</option>";
            }
            out = out + "</select>";
        } 
    }
    return out;
});


// Claim
var source = "{{#buildFormClaim questions}}{{/buildFormClaim}}";
var template = Handlebars.compile(source);
var form1 = template(context1);

// Data - number of participants
source = "{{#buildFormData questions}}{{/buildFormData}}";
template = Handlebars.compile(source);
var form2 = template(context2);

// Data - dosage 1
source = "{{#buildFormData questions}}{{/buildFormData}}";
template = Handlebars.compile(source);
var form3 = template(context3);

// Data - dosage 2
source = "{{#buildFormData questions}}{{/buildFormData}}";
template = Handlebars.compile(source);
var form4 = template(context4);

Template.content = [
    '<div class="annotator-outer annotator-editor annotator-invert-y annotator-invert-x">',
    '<form class="annotator-widget">',
    '<ul class="annotator-listing"></ul>',
    '<div class="annotationbody" style="margin-left:5px;margin-right:0px;height:100%;line-height:200%;margin-top:0px;overflow-y: hidden">',
    '<div id="tabs">',
    '<div id="tabs-1" style="margin-bottom:0px;">',

    // Type of editor
    '<div id="mp-editor-type" style="display: none;"></div>',
    // The Claim currently working on
    '<div id="mp-annotation-work-on" style="display: none;"></div>',

    // links 
    '<div id="mp-data-nav" style="display: none;">',
    '<button type="button" onclick="switchDataForm(\'participants\')" >Participants</button> &nbsp;->&nbsp;',
    '<button type="button" onclick="switchDataForm(\'dose1\')" >Drug 1 Dose</button> &nbsp;->&nbsp;',
    '<button type="button" onclick="switchDataForm(\'dose2\')" >Drug 2 Dose</button>',
    '</div>',

    // Claim form
    '<div id="mp-claim-form" style="margin-top:10px;margin-left:5px;display: none;">',
    '<table class="clear-user-agent-styles">',
    form1,
    '</table>',
    '</div>',
    
    // Data & material - Num of Participants
    '<div id="mp-data-form-participants" style="margin-top:10px;margin-left:5px;display: none;">',
    form2,
    '</div>',

    // Data & material - Drug1 Dosage
    '<div id="mp-data-form-dose1" style="margin-top:10px;margin-left:5px;display: none;">',
    form3,
    '</div>',

    // Data & material - Drug2 Dosage
    '<div id="mp-data-form-dose2" style="margin-top:10px;margin-left:5px;display: none;">',
    form4,
    '</div>',
    
    '</div>',
    '</div>',
    '</div>',
    '    <div class="annotator-controls1">',
    '     <a href="#cancel" class="annotator-cancel" onclick="showrightbyvalue()" id="annotator-cancel">Cancel</a>',
    '     <a href="#delete" class="annotator-delete" onclick="" id="annotator-delete">Delete</a>',
    '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;',
    '     <a href="#save" class="annotator-save annotator-focus" onclick="postEditorSave()">Save</a>',
    '     <a href="#save-close" class="annotator-save-close" onclick="postEditorSaveAndClose()" id="annotator-save-close">Save and Close</a>',
  '    </div>',
    '  </form>',
    '</div>'
].join('\n');


Template.extend = extend;
exports.Template = Template;
