;(function ($) {

var fixtureMemo = {}

this.fixture = function (fname) {
  if (typeof(fixtureMemo[fname]) === 'undefined') {
    fixtureMemo[fname] = $.ajax({
      url: 'fixtures/' + fname,
      async: false
    }).responseText
  }

  var $fix = $('#fixture').empty()
  var $div = $('<div>' + fixtureMemo[fname] + '</div>').appendTo($fix)

  return $div.get(0)
}

})(jQuery)

