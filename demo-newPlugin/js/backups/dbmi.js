$(document).ready(function () {
    $('#splitter').jqxSplitter({ width: 1270, height: '100%',  panels: [{ size: '100%', min: 100 }, { size: '0%', min: 0}] });
    //$(".sidebar.right").sidebar({side: "right"});
  });

  // Sidebar on right side
  function showrightbyvalue(){
    //$(".sidebar.right").sidebar({side: "right"});
    //alert($('#splitter').jqxSplitter.panels.length);
    if($('.btn-success').val()=="hide") {
      
      $('#splitter').jqxSplitter({
        width: 1270,
        height: '100%',
        panels: [{size: '67%', min: 850}, {size: '33%', min: 410}]
      });
      $('.btn-success').val("show");
      $('.annotator-outer').show();
      $('.btn-success').css("margin-right",420);
    }
    else {
      $('#splitter').jqxSplitter({
        width: 1270,
        height: '100%',
        panels: [{size: '100%', min: 100}, {size: '0%', min: 0}]
      });
      $('.btn-success').val("hide");
      $('.annotator-outer').hide();
      $('.btn-success').css("margin-right",0);
    }

  }

  function showright(){
    //$(".sidebar.right").sidebar({side: "right"});
    //alert($('#splitter').jqxSplitter.panels.length);
    //if($('.annotator-outer').css('display')=="block") {
      $('#splitter').jqxSplitter({
        width: 1270,
        height: '100%',
        panels: [{size: '67%', min: 850}, {size: '33%', min: 410}]
      });
      $('.btn-success').val("show");
      $('.btn-success').css("margin-right",420);
    /*}
    else {
      $('#splitter').jqxSplitter({
        width: 1270,
        height: '100%',
        panels: [{size: '100%', min: 100}, {size: '0%', min: 0}]
      });
      $('.btn-success').val("hide");
    }*/

  }
  /*$(document).ready(function () {
    $('#mainSplitter').jqxSplitter({ width: 850, height: 400, orientation: 'horizontal', panels: [{ size: 100 }, { size: 300 }] });
  });*/