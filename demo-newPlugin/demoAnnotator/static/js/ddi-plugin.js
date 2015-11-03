if (typeof annotator === 'undefined') {
    alert("Oops! it looks like you haven't built Annotator. " +
          "Either download a tagged release from GitHub, or build the " +
          "package by running `make`");
} else {
    
    var app = new annotator.App();
    app.include(annotator.ui.main, {element: document.querySelector('#content'), editorExtensions: [annotator.ui.tags.editorExtension], viewerExtensions: [annotator.ui.tags.viewerExtension]});
    
    app.include(annotator.storage.debug);
    app.include(annotator.identity.simple);

    app.include(annotator.authz.acl);

    //app.include(annotator.authz.AclAuthzPolicy);
    //app.include(annotator.authz.AclAuthzPolicy.prototype.permits);

    app.include(annotator.storage.http, {
	prefix: 'http://127.0.0.1:5000'
    });


    app.start().then(function () 
		     {   
                 //app.ident.identity = "yifan";

                 var currUser = getCookie('email');

                 if (currUser != null){
                     app.ident.identity = currUser;
                 } else{
                     app.ident.identity = 'anonymous@gmail.com';                 
                 }
                 app.annotations.load();
		     });
}


function getCookie(cname) {

    //alert('get cookie by name: ' + cname)
    var name = cname + "=";
    var ca = document.cookie.split(';');
    for(var i=0; i<ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0)==' ') c = c.substring(1);
        if (c.indexOf(name) == 0) return c.substring(name.length,c.length);
    }
    return "";
} 
