function Youtube(id){
	if(id==1){
	iBox.showURL("http://www.youtube.com/watch?v=_i-suTH6OF4","聖なるかな ―オリハルコンの名の下に―：PSP版新規OPムービー");
	}else if(id==2){
	iBox.showURL("http://www.youtube.com/watch?v=Yg6y1CTgO_8","※本動画にはゲーム音声は収録されておりません。実際の音声は製品版でお楽しみください。");
	}else{

	}

}

var now=1;
var end=16;

function Comic(label){
	if(label=='next'){
		now++;
		if(now >= end){
			now = end;
			document.getElementById("next").src = "comic/none.png";
		}else{
			document.getElementById("next").src = "comic/next.png";
		}
		
		if(now == 1){
			document.getElementById("previous").src = "comic/none.png";
		}else{
			document.getElementById("previous").src = "comic/previous.png";
		}
	}else if(label=='previous'){
		now--;
		if(now <= 1){
			now = 1;
			document.getElementById("previous").src = "comic/none.png";
		}else{
			document.getElementById("previous").src = "comic/previous.png";
		}
		if(now == end){
			document.getElementById("next").src = "comic/none.png";
		}else{
			document.getElementById("next").src = "comic/next.png";
		}
	}else{

	}


	document.getElementById("comic").src = "comic/" + now + ".jpg";
}

function Comicselect(label){
		now = label
		if(now >= end){
			now = end;
			document.getElementById("next").src = "comic/none.png";
		}else{
			document.getElementById("next").src = "comic/next.png";
		}
		
		if(now == 1){
			document.getElementById("previous").src = "comic/none.png";
		}else{
			document.getElementById("previous").src = "comic/previous.png";
		}

		document.getElementById("comic").src = "comic/" + now + ".jpg";
	

}