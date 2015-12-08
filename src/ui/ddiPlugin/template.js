"use strict";

var extend = require('backbone-extend-standalone');
var Template = function(){console.log("success");};
Template.content = [
  //'<script src="./js/backups/jquery-1.11.1.min.js"></script>',
  //'<script>function() {$( "#tabs" ).tabs();}</script>',
  '<style>.question {background: rgba(211, 211, 211, 0.3);font-weight: 800;line-height:145%;}',
  '.annotator-widget {font-size:115%;}</style>',
  '<script type="text/javascript">',
    'function changeFunc() {',
    'if($("#assertion_type option:selected").text()=="DDI clinical trial") $("#altersection").show();',
    'else $("#altersection").hide();}',
  '</script>',
  '<div class="annotator-outer annotator-editor annotator-hide">',
  '  <form class="annotator-widget">',
  '    <ul class="annotator-listing"></ul>',
  '<div style="margin-left: 10px;margin-right: 10px;margin-bottom: 10px">',
    '<div id="tabs">',
    //'<ul>',
    //'<li><a href="#tabs-1">PK DDI</a></li>',
  //'</ul>',
  '<div id="tabs-1" style="margin-bottom:30px">',
  '<div  style="float:left;margin-bottom:30px">',
  '<div class="question">Drug 1 in DDI:</div>',
  '<div>Drug mentions:',
  '<select id="Drug1">',
  //'<option value="simvastatin">simvastatin</option>',
  //'<option value="ketoconazole">ketoconazole</option>',
  '</select>',
  '</div>',

  '<div class="question">Type</div>',
  '<div>',
  '<input type="radio" name="Type1" id="Type1" class="Type1" value="active ingredient">active ingredient',
  '<input type="radio" name="Type1" class="Type1" value="metabolite">metabolite',
  '<input type="radio" name="Type1" class="Type1" value="drug product">drug product',
  '<input type="radio" name="Type1" class="Type1" value="drug group">drug group',
  '</div>',

  '<div class="question">Role</div>',
  '<div>',
  '<input type="radio" name="Role1" id="Role1" class="Role1" value="Precipitant"> Precipitant',
  '<input type="radio" name="Role1" id="Role1" class="Role1" value="Object"> Object',
  '</div>',

  '<div class="question">Drug 2 in DDI:</div>',
  '<div>Drug mentions:',
  '<select id="Drug2">',
  //'<option value="simvastatin">simvastatin</option>',
  //'<option value="ketoconazole">ketoconazole</option>',
  '</select>',
  '</div>',

  '<div class="question">Type</div>',
  '<div>',
  '<input type="radio" name="Type2" id="Type2" class="Type2" value="active_ingredient">active ingredient',
  '<input type="radio" name="Type2" id="Type2" class="Type2" value="metabolite">metabolite',
  '<input type="radio" name="Type2" id="Type2" class="Type2" value="drug_product">drug product',
  '<input type="radio" name="Type2" id="Type2" class="Type2" value="drug_group">drug group',
  '</div>',

  '<div class="question">Role</div>',
  '<div>',
  '<input type="radio" name="Role2" id="Role2" class="Role2" value="Precipitant">Precipitant',
  '<input type="radio" name="Role2" id="Role2" class="Role2" value="Object">Object',
  '</div>',

  '</div>',


  '<div style="margin-left: 350px">',

  '<div class="question">DIKB Assertion type:</div>',
  '<div>',
  '<select id="assertion_type" onchange="changeFunc();">',
  '<option id="DDI" value="Drug Drug Interaction">Drug Drug Interaction</option>',
  '<option id="clinical" value="DDI clinical trial">DDI clinical trial</option>',
  '</select>',

  '<div class="question">Modality</div>',
  '<div>',
  '<input type="radio" name="Modality" id="Modality" class="Modality" value="Positive">Positive',
  '<input type="radio" name="Modality" id="Modality" class="Modality" value="Negative">Negative',
  '</div>',

  '<div class="question">Evidence modality</div>',
  '<div>',
  '<input type="radio" name="Evidence_modality" id="Evidence_modality" class="Evidence_modality" value="for">Evidence for',
  '<input type="radio" name="Evidence_modality" id="Evidence_modality" class="Evidence_modality" value="against">Evidence against',
  '</div>',

  '<div class="question">Comment</div>',
  '<div>',
  '<textarea id="Comment" class="Comment"></textarea>',
  '</div>',

  '</div>',

  '<div id = "altersection" style="margin-left: 0px;display: none;float:left;">',
  '<br>',

  '<div class="question">The number of participants:</div>',
  '<div>',
  '<input type="text" id="Number_participants">',
  '</div>',

  '<div class="question">Precipitant drug dosage:</div>',
  '<div>',
  'Dose in MG: <input type="text" id="DoseMG_precipitant"><br>',
  'Formulation: <select id="FormulationP">',
  //'<option value="simvastatin">simvastatin</option>',
  //'<option value="ketoconazole">ketoconazole</option>',
  '</select>',
  'Duration(days): <input type="text" id="Duration_precipitant"><br>',
  'Regiments: <select id="RegimentsP">',
  '</select>',
  '</div>',

  '<div class="question">Object drug dosage:</div>',
  '<div>',
  'Dose in MG: <input type="text" id="DoseMG_object"><br>',
  'Formulation: <select id="FormulationO">',
  //'<option value="simvastatin">simvastatin</option>',
  //'<option value="ketoconazole">ketoconazole</option>',
  '</select>',
  'Duration(days): <input type="text" id="Duration_object"><br>',
  'Regiments: <select id="RegimentsO">',
  '</select>',
  '</div>',

  '</div>',

    '</div>',
  '</div>',
  '</div>',
  '</div>',
  '    <div class="annotator-controls">',
  '     <a href="#cancel" class="annotator-cancel" id="annotator-cancel">',
  'Cancel',
  '</a>',
  '      <a href="#save"',
  '         class="annotator-save annotator-focus">',
  'Save',
  '</a>',
  '    </div>',
  '  </form>',
  '</div>'
].join('\n');


Template.extend = extend;
exports.Template = Template;
