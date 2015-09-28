var ddi = {};

function helloWorld(options) {
    options = options || {};
    options.message = options.message || 'non message';
    // alert(options.message)
    return {
        start: function (app) {
            app.notify(options.message);
        }
    };
}

function addFieldsToEditor(options) {

    //options = options || {};
    //options.editor = options.editor || 'non message';


    var getKeys = function(obj){
	var keys = [];
	for(var key in obj){
	    keys.push(key);
	}
	return keys;
    }

    alert(getKeys(options.Editor))


    // add new field as part of default - drug name
    options.Editor.addField({
    	label: 'Drug role' + '\u2026',
    	type:  'textarea',
    	load: function (field, annotation) {
    	    $(field).find('#annotator-field-2').val(annotation.role || '');
    	},
    	submit: function (field, annotation){
    	    annotation.drug = $(field).find('#annotator-field-1').val();
    	} 
    });


 }
