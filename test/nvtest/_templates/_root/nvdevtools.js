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
function isFirstChild(node){
	return node.parentNode.firstChild==node;
}
handleEvent(window,'load',function(){
	// Add first-child CSS class since :first-child pseudo-class doesn't work for old IE
	for ( var tags=['h2','h3','p','ul','dl','ol'],i=tags.length-1; i>=0; --i ){
		for ( var all=document.getElementsByTagName(tags[i]),j=all.length-1; j>=0; --j ){
			if (isFirstChild(all[j])) cssClass.add(all[j],'first-child');
		} 
	}
});