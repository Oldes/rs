var _tmDelay;
function hideFuncDescription(){
	$("div.funcDecription").html("").css({"display":"none"});
}
function setPopups(target_items){
	$(target_items).each(function(i){
		if($(this).next().is("div") ){
			$(this).mouseover(function(e) {
				clearTimeout(_tmDelay);
				var target = $(e.target);
				var offset = target.offset();
				var win = $("div.funcDecription");
				win.html(target.next().html());
				var posX = Math.min(Math.max(0, offset.left-20), $(window).width()-win.width()-50);
				var posY = offset.top + 15;
				if (posY+win.height()+30 > $(window).height()){
					posY = offset.top - 45 - win.height();
				}
				if (posY < 0) posY = 0;
				win.css({"top": posY, "left": posX, "display":"block"});
			}).mouseout(function(){
				_tmDelay = setTimeout(hideFuncDescription,200)
			});
		}
	});

	$("div.funcDecription").mouseover(function(e) {
		clearTimeout(_tmDelay);
	}).mouseout(function(){
		_tmDelay = setTimeout(hideFuncDescription,200)
	});
}

$(document).ready(function(){
	 setPopups("a.ql-func");
});

