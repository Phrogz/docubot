function glossaryClick(evt){
	if (!evt) evt=event;
	var target = evt.target || evt.srcElement;
	var term = target.getAttribute('term') || target.innerHTML;
	var box = document.getElementById('glossary-box');
	box.style.display = 'block';
	var scroll = (document.documentElement.scrollTop || document.body.scrollTop )*1;
	box.style.left    = (evt.clientX+5) + 'px';
	box.style.top     = (evt.clientY+5) + scroll + 'px';

	var html = $glossaryTerms[term.toLowerCase()];
	document.getElementById('glossary-defn').innerHTML = html;
}

handleEvent(window,'load',function(){
	for ( var spans=document.getElementsByTagName('span'),i=spans.length-1; i>=0; --i ){
		if (cssClass.has(spans[i],'glossary')) handleEvent(spans[i],'click',glossaryClick);
	}
	var box = document.getElementById('glossary-box');
	handleEvent( document.body, 'click', function(){
		box.style.display = 'none';
	});
});