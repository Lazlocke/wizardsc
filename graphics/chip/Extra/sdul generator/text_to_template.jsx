var f = new File("C:/Users/Lazlocke/Desktop/image/Sdule.txt");
f.open('r');

var doc = app.activeDocument;

while(!f.eof)
{
	var txtLayer = doc.activeLayer.duplicate();
	var l = f.readln();

	var l2 = l.split(';');
	
	txtLayer.name = l2[1];
	txtLayer.textItem.contents = l2[0];
}

f.close();