/**
 * Fix zoom on non-IE browser
 *
 * @param {HTMLDom} doc parent DOM (AKA window.document)
 */
window.fixScale = function (doc) {
  var addEvent = 'addEventListener'
  var type = 'gesturestart'
  var qsa = 'querySelectorAll'
  var scales = [1, 1]
  var meta = qsa in doc ? doc[qsa]('meta[name=viewport]') : []

  function fix() {
    meta.content = 'width=device-width,minimum-scale=' + scales[0] + ',maximum-scale=' + scales[1]
    doc.removeEventListener(type, fix, true)
  }

  if ((meta = meta[meta.length - 1]) && addEvent in doc) {
    fix()
    scales = [0.25, 1.6]
    doc[addEvent](type, fix, true)
  }
}

/**
 * Add required nudges to render the tables as desired.
 *
 * @param {HTMLDom} doc parent DOM (AKA window.document)
 */
window.beautifyTables = function (doc) {
  var tables = Array.prototype.slice.call(doc.getElementsByTagName('table'))

  tables.forEach(function (table) {
    replaceTableRows(doc, table)
    replaceLabelsWithIcons(table)
  })
}

/**
 * Group td pairs elements as tr on small screens (ignoring wkhtmltopdf).
 *
 * @param {HTMLDom} doc parent DOM (AKA window.document)
 * @param {HTMLDom} table target table element
 */
var replaceTableRows = function (doc, table) {
  if (navigator.userAgent.indexOf('wkhtmltopdf') !== -1) {
    return
  }

  if (window.innerWidth >= 820) {
    return
  }

  var newTbody = doc.createElement("tbody")
  var oldTbody = table.getElementsByTagName('tbody')[0]
  var cells = Array.prototype.slice.call(oldTbody.getElementsByTagName('td'))

  var rowHolder = doc.createElement("tr")
  cells.forEach(function (c, i) {
    rowHolder.appendChild(c.cloneNode(true))

    if ((i + 1) % 2 === 0) {
      newTbody.appendChild(rowHolder)
      rowHolder = doc.createElement("tr")
    }
  })

  if (rowHolder.hasChildNodes()) {
    newTbody.appendChild(rowHolder)
  }

  table.replaceChild(newTbody, oldTbody)
}

/**
 * Prepend icons to the contact table labels.
 *
 * Note: There are more optimal implementations, but we are constrained to what
 * webkit 2.2 supports due to wkhtmltopdf.
 *
 * @param {HTMLDom} table target table element
 */
var replaceLabelsWithIcons = function (table) {

  // Icon mapper required for webkit 2.2 backward compatibility
  var icon4Legend = function (l) {
    switch (l.toLowerCase()) {
      case "languages":
        return '\ue894' // "language"
      case "linkedin":
        return '\ue7fe' // "person_add"
      case "email":
        return '\ue0be' // "mail"
      case "website":
        return '\ue0e5' // "rss_feed"
    }

    return '\ue838' // "star"
  }

  var cells = Array.prototype.slice.call(table.getElementsByTagName('td'))
  cells.forEach(function (cell, index) {
    if (index % 2 !== 0) {
      return
    }

    // webkit 2.2 fallbacks
    var cellContent = cell.textContent || cell.innerText || cell.innerHTML.replace(/<[^>]*>/g, '')
    if (!cellContent) {
      return
    }

    var legend = cellContent.trim().split(' ')[0].toLowerCase()
    var icon = document.createElement('span')
    icon.className = 'material-symbols-outlined'
    icon.textContent = icon4Legend(legend)
    cell.insertBefore(icon, cell.firstChild);
  })
}
