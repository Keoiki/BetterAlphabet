fl.outputPanel.clear();

var doc = fl.getDocumentDOM();

if (!doc)
{
	alert("Please open or create a flashfile.");
}
else
{
	ExportItemsAsSVG();
}

function ExportItemsAsSVG()
{
	var items = doc.library.items;
	var cwd = doc.pathURI.replace(".fla", "/");
	for (var i = 0; i < items.length; i++)
	{
		var item = items[i];
		if (item.itemType == "movie clip" || item.itemType == "graphic")
		{
			var fullName = cwd + item.name + ".svg";
			// fl.trace(fullName);
			doc.library.editItem(item.name);
			doc.exportSVG(fullName, true, true);
		}
	}
	doc.exitEditMode();
}