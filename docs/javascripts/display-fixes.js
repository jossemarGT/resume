fixScale = function(doc) {

	var addEvent = 'addEventListener',
	    type = 'gesturestart',
	    qsa = 'querySelectorAll',
	    scales = [1, 1],
	    meta = qsa in doc ? doc[qsa]('meta[name=viewport]') : [];

	function fix() {
		meta.content = 'width=device-width,minimum-scale=' + scales[0] + ',maximum-scale=' + scales[1];
		doc.removeEventListener(type, fix, true);
	}

	if ((meta = meta[meta.length - 1]) && addEvent in doc) {
		fix();
		scales = [.25, 1.6];
		doc[addEvent](type, fix, true);
	}

};

appendToSidebar = function(doc, ids) {
	var sidebar = doc.getElementById('main-header');

	ids.forEach(function(id) {
		var elem =  doc.getElementById(id);
		var clone = elem.cloneNode(true);
		sidebar.appendChild(clone);
		elem.remove();
	})
}

fixBreaklines = function (doc) {
	var paragraphs = Array.from(doc.getElementsByTagName('p'))
	var pipeRegx = /\|/g

	paragraphs.forEach(function(e){ e.innerHTML = e.innerHTML.replace('|', '').replace(pipeRegx,'<br/>'); })
}
