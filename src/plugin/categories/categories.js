/*
Annotator view panel Plugin v1.0 (https://https://github.com/albertjuhe/annotator_view/)
Copyright (C) 2014 Albert Juhé Brugué
License: https://github.com/albertjuhe/annotator_view/License.rst
This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
*/
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Annotator.Plugin.Categories = (function(_super) {
    __extends(Categories, _super);

    
    Categories.prototype.events = {
      'annotationsLoaded': 'onAnnotationsLoaded'
    };

    Categories.prototype.field = null;

    Categories.prototype.input = null;

    Categories.prototype.options = {
      categories: {}
    };

    function Categories(element, categories) {
      this.setAnnotationCat = __bind(this.setAnnotationCat, this);
      this.updateField = __bind(this.updateField, this);
      this.onAnnotationUpdated = __bind(this.onAnnotationUpdated, this);
      this.annotationCreated = __bind(this.annotationCreated, this);      
      this.AnnotationSection = __bind(this.AnnotationSection, this);
      this.AnnotationCategory = __bind(this.AnnotationCategory, this);
      this.updateAnnotation = __bind(this.updateAnnotation, this);

      this.options.categories = categories;
      Categories.__super__.constructor.apply(this, arguments);
    }


    Categories.prototype.pluginInit = function() {      
      if (!Annotator.supported()) {
        return;
      }

      //Call editor after submit.
      this.annotator.subscribe("annotationEditorSubmit",this.AnnotationSection);      

      //Call editor before show and write color checker
      this.annotator.subscribe("annotationEditorShown",this.AnnotationCategory);     

      //Annotation creation
      this.annotator.subscribe("annotationCreated",this.annotationCreated);    

      //Showing annotations
      this.annotator.subscribe("annotationViewerShown",this.AnnotationViewer);   

      this.annotator.subscribe("annotationUpdated ",this.updateAnnotation);  

    };

    //After loading annotations we want to change the annotation color and add the annotation id
    Categories.prototype.onAnnotationsLoaded = function(annotations) {
      var annotation;
      var _categories = this.options.categories; //Categories plug-in

      $('#count-anotations').text( annotations.length );
      if (annotations.length > 0) {
        for(i=0, len = annotations.length; i < len; i++) {
          annotation = annotations[i];    
          var category = "annotator-hl-" + annotation.category;
          if (annotation.category in _categories) {
             category = _categories[annotation.category];
           }           
          $(annotation.highlights).addClass(category);  
          $(annotation.highlights).attr('id', annotation.id ); 
        }
        
      }
      
    };

     //After loading annotations we want to change the annotation color and add the annotation id
    Categories.prototype.updateAnnotation = function(annotation) {    
	
      var category = this.options.categories[annotation.category]; 
     
      $(annotation.highlights).attr("class","annotator-hl " + category);   
     
    };

     //After loading annotations we want to change the annotation color and add the annotation id
    Categories.prototype.AnnotationViewer = function(viewer, annotations) {
      var annotation;
      var isShared = ""; 
      var class_label="label";
      
      if (annotations.length > 0) {
        for(i=0, len = annotations.length; i < len; i++) {
          annotation = annotations[i]; 
          
          if (annotation.estat==1 || annotation.permissions.read.length===0 ) {
            isShared = "<img src=\"../src/img/shared-icon.png\" title=\""+ i18n_dict.share +"\" style=\"margin-left:5px\"/>"
          }
          if (annotation.propietary==0) {
            class_label = "label-compartit";
          }
          //$('ul.annotator-widget > li.annotator-item').prepend('<div class="'+annotation.category+'" style="border: 10px solid #b3b3b3;height:6px;margin:4px;padding:4px;"></div>');
          $( "div.annotator-user" ).html( "<span class='"+class_label+"'>"+annotation.user+"</span>"+isShared);
          
        }
      }
    }


    //Section order and section title
    Categories.prototype.AnnotationSection = function(editor,annotation) {
      //Assign a categoy to the annotation

      //Put the annotation section an annotation title
      var ref = $('.annotator-hl-temporary').closest('div[data-section]');
      if (ref) {
        annotation.section = ref.data('section');
        annotation.section_title = ref.data('title');
      } else {
        console.log("Section not detected!!!")
      }
      annotation.order = $('.annotator-hl-temporary').closest('div[id]').attr('id');       
      annotation.category = $('input:radio[name=categories-annotation]:checked').val();

    }

     //Create the categories section inside the editor
    Categories.prototype.AnnotationCategory = function(editor,annotation) {
      var _categories = this.options.categories; //Categories plug-in
      var editor = $('form.annotator-widget > ul.annotator-listing'); //Place to add categories.
      if ($('li.annotator-radio').length == 0) { //If the category section not exists
        editor.append("<li class='annotator-item annotator-radio'></li>");
        var _radioGroup = $('li.annotator-radio'); //Place to add radiobuttons
        var checked = "checked = 'checked'";
        i=1;
        for (cat in _categories) {
          if (i>1) checked="";
          var radio ="<input id='"+ cat+"' type='radio' "+checked+" placeholder='"+ cat+"' name='categories-annotation' value='"+ cat +"' style='margin-left:5px'/>";
          radio = radio + '<label for="annotator-field-'+i+'" style="vertical-align: middle;text-transform:capitalize;"><div class="'+_categories[cat]+' square" style="display:inline-block;height:15px;width:30px;margin-top:3px;margin-bottom:3px;margin-rigth:5px;vertical-align:middle"></div><span style="margin-left:5px">'+$.i18n._(cat)+'</span></label><br/>';
          i = i + 1;
          _radioGroup.append(radio);
        } 

      }   
      if (annotation.category) {
        $('#' + annotation.category).prop('checked',true);
      }
    }

    //When an annotation is changed we have to change the attributes
    Categories.prototype.onAnnotationUpdated = function(annotation) {
     $( "span[id="+annotation.id+"]" ).attr('class','annotator-hl-'+annotation.category);
    };

    
    Categories.prototype.annotationCreated = function(annotation) {
      var cat, h, highlights, _i, _len, _results;
      
      $( "span[id="+annotation.id+"]" ).attr('id',annotation.id);
      cat = annotation.category;
      highlights = annotation.highlights;
      if (cat) { //If have a category
        _results = [];
        for (_i = 0, _len = highlights.length; _i < _len; _i++) {
          h = highlights[_i];
          _results.push(h.className = h.className + ' ' + this.options.categories[cat]);
        }
        return _results;
      }
    };

    Categories.prototype.updateField = function(field, annotation) {
      var category;
      category = '';
      if (field.checked = 'checked') {
        category = annotation.category;
      }
      console.log('updateField');
      return this.input.val(category);
    };

    Categories.prototype.updateViewer = function(field, annotation) {
      field = $(field);
      field.html('<span class="annotator-hl-' + annotation.category + '">' +$.i18n._(annotation.category).toUpperCase() + '</span>').addClass('annotator-hl-'+ annotation.category );
     
    };

    return Categories;

  })(Annotator.Plugin);

}).call(this);
