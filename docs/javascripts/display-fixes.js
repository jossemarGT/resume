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

window.fixBreaklines = function (doc) {
  var paragraphs = Array.prototype.slice.call(doc.getElementsByTagName('p'))
  var pipeRegx = /\|/g

  paragraphs.forEach(function (e) {
    e.innerHTML = e.innerHTML.replace('|', '').replace(pipeRegx, '<br/>')
  })
}

window.evenTables = function (doc) {
  if (window.innerWidth < 540) {
    return
  }

  var tables = Array.prototype.slice.call(doc.getElementsByTagName('table'))

  tables.forEach(function (elem) {
    fixTable(doc, elem)
  })
}

var fixTable = function(doc, table) {
  var newTbody = doc.createElement("tbody")
  var oldTbody = table.getElementsByTagName('tbody')[0]
  var cells = Array.prototype.slice.call(oldTbody.getElementsByTagName('td'))

  var rowHolder = doc.createElement("tr")
  cells.forEach(function(c, i){
    rowHolder.appendChild(c.cloneNode(true))

    if ( (i+1) % 4 === 0 ) {
      newTbody.appendChild(rowHolder)
      rowHolder = doc.createElement("tr")
    }
  })

  if (rowHolder.hasChildNodes()) {
    newTbody.appendChild(rowHolder)
  }

  table.replaceChild(newTbody, oldTbody)
}
