fl.outputPanel.clear();

var doc = fl.getDocumentDOM();

if (!doc) {
	alert("Please open or create a flashfile.");
} else {
	AutomateSymbolCreationWithGrid();
}

function AutomateSymbolCreationWithGrid() {
	var alignments = ["top left", "top center", "top right", "center left", "center", "center right", "bottom left", "bottom center", "bottom right"];

	var dialogXML = ''
	dialogXML += '<label width="300" value="Horizontal Divisions:" />';
	dialogXML += '<textbox id="hdiv" width="300" value=""/>';
	dialogXML += '<label width="300" value="Vertical Divisions:" />';
	dialogXML += '<textbox id="vdiv" width="300" value=""/>';
	dialogXML += '<label width="300" value="Starting Count: (Decimal)" />';
	dialogXML += '<textbox id="startcount" width="300" value=""/>';
	dialogXML += '<label width="300" value="Alignment:"/>';
	dialogXML += '<menulist id="alignment" editable="false" width="300"><menupopup>';
	for (var i = 0; i < alignments.length; i++) dialogXML += '<menuitem selected="' + (i == 0) + '" label="' + alignments[i] + '"/>';
	dialogXML += '</menupopup></menulist>';

	var dialogData = createDialogXML(dialogXML, "Create Letters from a grid.");

	if (dialogData && dialogData.hdiv && dialogData.vdiv && dialogData.startcount && dialogData.alignment) {
		var a = -1;
		var selectionWidth = Math.floor(doc.width / dialogData.hdiv);
		var selectionHeight = Math.floor(doc.height / dialogData.vdiv);

		for (var i = 0; i < dialogData.vdiv; i++) {
			for (var j = 0; j < dialogData.hdiv; j++) {
				a++;
				doc.setSelectionRect({
					left: selectionWidth * j,
					top: selectionHeight * i,
					right: selectionWidth * j + selectionWidth,
					bottom: selectionHeight * i + selectionHeight
				}, true);
				if (doc.selection == null) {
					fl.outputPanel.trace("Selection was empty!");
					continue;
				}
				for each(var selectedItem in doc.selection) {
					selectedItem.selected = true;
					var itemIndex = parseInt(parseInt(dialogData.startcount) + a);
					var indexHex = itemIndex.toString(16);
					while (indexHex.length < 4) {
						indexHex = "0" + indexHex;
					}
					doc.convertToSymbol("movie clip", itemIndex.toString() + "-" + indexHex.toUpperCase(), dialogData.alignment);
					selectedItem.selected = false;
				}
			}
		}
		doc.selectNone();
	}

	function createDialogXML(xmlString, description) {
		var dialogXML = '<dialog title="' + description + '" buttons="accept, cancel">';
		dialogXML += '<vbox>';
		dialogXML += xmlString;
		dialogXML += '</vbox>';
		dialogXML += '</dialog>';

		var url = fl.configURI + 'Commands/temp-dialog-' + parseInt(Math.random() * 256) + '.xml';
		FLfile.write(url, dialogXML);

		var panelOutput = fl.getDocumentDOM().xmlPanel(url);
		FLfile.remove(url);

		return panelOutput;
	}
}