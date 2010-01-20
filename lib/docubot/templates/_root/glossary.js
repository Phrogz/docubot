function handleEvent(obj,eventName,callback,useCapture){
	return obj.addEventListener ? obj.addEventListener(eventName,callback,useCapture||false) : obj.attachEvent("on"+eventName,callback);
}

cssClass = {
	_killCache : {},
	_findCache : {},
	add : function cssClassAdd(obj,className){
		this.kill(obj,className);
		obj.className+=(obj.className.length?' ':'')+className;
	},
	kill : function cssClassKill(obj,className){
		var re = this._killCache[className] || (this._killCache[className]=new RegExp('(?:^|\\s+)'+className+'(?:\\s+|$)','g') );
		obj.className = obj.className.replace(re,'');
	},
	has : function cssClassHas(obj,className){
		var re = this._findCache[className] || (this._findCache[className]=new RegExp('(?:^|\\s+)'+className+'(?:\\s+|$)') );
		return re.test( obj.className );
	}
};

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
	box.innerHTML = html;
	
	evt.cancelBubble = true;
	if (evt.stopPropogation) evt.stopPropogation();
	return false;
}

handleEvent(window,'load',function(){
	for ( var spans=document.getElementsByTagName('span'),i=spans.length-1; i>=0; --i ){
		var span = spans[i];
		if (cssClass.has(span,'glossary')){
			var term = span.getAttribute('term') || span.innerHTML;
			if ($glossaryTerms[term.toLowerCase()]){
				handleEvent(span,'click',glossaryClick);
			}else{
				cssClass.kill(span,'glossary');
				cssClass.add(span,'glossary-missing');
			}
			
		}
	}
	var box = document.getElementById('glossary-box');
	handleEvent( document.body, 'click', function(){
		box.style.display = 'none';
	});
});