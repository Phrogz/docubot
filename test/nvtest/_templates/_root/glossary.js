function glossaryClick(evt){
	if (!evt) evt=event;
	var target = evt.target || evt.srcElement;
	var term = target.getAttribute('term') || target.innerHTML;
	var html = $glossaryTerms[term.toLowerCase()];
	var box = document.getElementById('glossary-box');
	box.innerHTML = html;
	box.style.display = 'block';
	// TODO: move to the mouse cursor
}

handleEvent(window,'load',function(){
	for ( var spans=document.getElementsByTagName('span'),i=spans.length-1; i>=0; --i ){
		if (cssClass.has(spans[i],'glossary')) handleEvent(spans[i],'click',glossaryClick);
	}
});