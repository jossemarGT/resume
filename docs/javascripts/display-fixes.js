window.fixScale = function (doc) {
  var addEvent = 'addEventListener'
  var type = 'gesturestart'
  var qsa = 'querySelectorAll'
  var scales = [1, 1]
  var meta = qsa in doc ? doc[qsa]('meta[name=viewport]') : []

  function fix () {
    meta.content = 'width=device-width,minimum-scale=' + scales[0] + ',maximum-scale=' + scales[1]
    doc.removeEventListener(type, fix, true)
  }

  if ((meta = meta[meta.length - 1]) && addEvent in doc) {
    fix()
    scales = [0.25, 1.6]
    doc[addEvent](type, fix, true)
  }
}

window.appendToSidebar = function (doc, ids) {
  var sidebar = doc.getElementById('main-header')

  ids.forEach(function (id) {
    var elem = doc.getElementById(id)
    var clone = elem.cloneNode(true)
    sidebar.appendChild(clone)
    elem.remove()
  })
}

window.fixBreaklines = function (doc) {
  var paragraphs = Array.from(doc.getElementsByTagName('p'))
  var pipeRegx = /\|/g

  paragraphs.forEach(function (e) {
    e.innerHTML = e.innerHTML.replace('|', '').replace(pipeRegx, '<br/>')
  })
}
