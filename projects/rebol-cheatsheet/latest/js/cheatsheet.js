var _tmDelayHide;
var _tmDelayShow;
var funcPopup = $("div.funcDecription");
function hideFuncDescription(){
	$("div.funcDecription").html("").css({"display":"none"});
}
function showFuncDescription(){
	$("div.funcDecription").css({display:"block", opacity:0});
	$("div.funcDecription").animate({opacity:1},80);
}
function setPopups(target_items){
	$(target_items).each(function(i){
		if($(this).next().is("div") ){
			$(this).mouseover(function(e) {
				clearTimeout(_tmDelayHide);
				clearTimeout(_tmDelayShow);
				var target = $(e.target);
				var offset = target.offset();
				var win = $("div.funcDecription");
				win.html(target.next().html());
				var posX = Math.min(Math.max(0, offset.left-20), $(window).width()-win.width()-50);
				var posY = offset.top + 18;
				if (posY+win.height()+30 > $(window).height()){
					posY = offset.top - 45 - win.height();
				}
				if (posY < 0) posY = 0
				win.css({"top": posY, "left": posX});
				if(win.css("display") == "block") {
					showFuncDescription();
				} else {
					_tmDelayShow = setTimeout(showFuncDescription, 300);
				}
			}).mouseout(function(){
				clearTimeout(_tmDelayShow);
				_tmDelayHide = setTimeout(hideFuncDescription,200);
			});
		}
	});

	$("div.funcDecription").mouseover(function(e) {
		clearTimeout(_tmDelayHide);
	}).mouseout(function(){
		_tmDelayHide = setTimeout(hideFuncDescription,200);
	});
}

$(document).ready(function(){
	 setPopups("a.ql-func");
});

