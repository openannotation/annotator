$(function () {
  var roleList = ["copy-editor", "English professor", "critical edition", "[citation needed]"]

  var rollRole = function () {
    roleList.push(roleList.shift())

    $('h2 span#role').fadeOut(function () {
      $(this).text(roleList[0]).fadeIn()
    })
  }

  // Rotate title, etc.
  setInterval(rollRole, 5000)

  // What we're here for...
  $('#airlock').annotator()
})