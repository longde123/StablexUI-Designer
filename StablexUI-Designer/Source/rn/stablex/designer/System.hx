package rn.stablex.designer;

import neko.vm.Loader;
import neko.vm.Module;

import haxe.xml.Printer;

import sys.io.File;
import haxe.io.Path;
import sys.FileSystem;

import openfl.events.Event;
import openfl.events.MouseEvent;

import ru.stablex.ui.*;
import ru.stablex.ui.skins.*;
import ru.stablex.ui.widgets.*;
import ru.stablex.ui.layouts.Row;
import ru.stablex.ui.events.WidgetEvent;

import tjson.TJSON;
import rn.TjsonStyleCl;

using StringTools;
using rn.typext.ext.XmlExtender;
using rn.typext.ext.BoolExtender;
using rn.typext.ext.StringExtender;

class System {
	public static var guiSettings:GuiDataInfo;
	
	public static var wgtUiXmlMap:Map<{}, Xml>; // <widget>, <xml>
	public static var wgtPropsMap:Map<String, WgtPropInfo>; // <class name>, <set of properties>
	public static var wgtSuitsMap:Map<String, SuitInfo>; // <class name>, <set of suits>
	public static var wgtSkinsMap:Map<String, WgtPropInfo>; // <class name>, <set of properties>
	
	public static var frameXml:Xml;
	public static var frameWgt:Widget;
	public static var frameData:FrameInfo;
	
	public static var guiElementsXml:Xml;
	public static var guiElementsWgt:Widget;
	
	public static var selWgt:Dynamic;
	public static var selWgtData:WgtDataInfo;
	
	public static var selWgtProp:HBox;
	public static var selWgtProps:Map<String, HBox>;
	public static var selPropName:String;
	
	public static var moveWgt:Dynamic;
	public static var moveWgtY:Float;
	public static var moveWgtX:Float;
	
	public static var uiDirPath:String;
	public static var uiXmlPath:String;
	
	//-----------------------------------------------------------------------------------------------
	// additional xml-functions
	
	public static function parseXml (xmlStr:String) : Xml
		return Xml.parse((~/^ +</gm).replace((~/^	+</gm).replace(xmlStr, "<"), "<").replace("\n", ""));
	
	public static function printXml (xml:Xml, indent:String) : String
		return Printer.print(xml, true).replace(">", ">\n").replace("	", indent).replace("   ", indent);
	
	//-----------------------------------------------------------------------------------------------
	// gui settings
	
	public static function saveUiSettingsToXml (xml:Xml = null) : Void {
		if (System.guiSettings == null)
			return;
		
		for(elem in (xml == null ? System.frameXml: xml))
			if (elem.nodeType == Xml.XmlType.Comment)
				elem.removeSelf();
		
		System.guiSettings.guiName = MainWindowInstance.guiName.text;
		
		if (MainWindowInstance.wgtSrcActLink.selected)
			System.guiSettings.wgtSrcAct = 1;
		else if (MainWindowInstance.wgtSrcActCopy.selected)
			System.guiSettings.wgtSrcAct = 2;
		else
			System.guiSettings.wgtSrcAct = 0;
		
		System.guiSettings.project = MainWindowInstance.projectPath.text;
		System.guiSettings.srcDir = MainWindowInstance.wgtSrcDirPath.text;
		
		System.guiSettings.makeInstance = MainWindowInstance.wgtMakeUiInst.selected;
		System.guiSettings.guiInstanceTemplate = MainWindowInstance.guiInstanceTemplate.value;
		System.guiSettings.guiInstancePath = MainWindowInstance.guiInstancePath.text;
		System.guiSettings.rootName = MainWindowInstance.rootName.text;
		
		System.guiSettings.preset = MainWindowInstance.presetsList.value;
		
		System.guiSettings.guiWidth = Std.parseInt(MainWindowInstance.guiWidth.text);
		System.guiSettings.guiHeight = Std.parseInt(MainWindowInstance.guiHeight.text);
		System.guiSettings.fixedWindowSize = MainWindowInstance.fixedWindowSize.selected;
		System.guiSettings.frameTemplate = MainWindowInstance.framesList.value;
		
		(xml == null ? System.frameXml: xml).addChild(Xml.createComment(TJSON.encode(System.guiSettings, new TjsonStyleCl())));
	}
	
	public static function loadUiSettingsFromXml (xml:Xml = null) : Void {
		for(elem in (xml == null ? System.frameXml: xml))
			if (elem.nodeType == Xml.XmlType.Comment) {
				System.guiSettings = TJSON.parse(elem.nodeValue);
				System.refreshGuiSettings();
				
				break;
			}
	}
	
	public static function refreshGuiSettings () : Void {
		MainWindowInstance.guiName.text = System.guiSettings.guiName.escNull();
		MainWindowInstance.guiName.dispatchEvent(new Event(Event.CHANGE));
		
		switch(System.guiSettings.wgtSrcAct) {
			case 1:
				MainWindowInstance.wgtSrcActLink.selected = true;
			case 2:
				MainWindowInstance.wgtSrcActCopy.selected = true;
			default:
				MainWindowInstance.wgtSrcActNoth.selected = true;
		}
		
		MainWindowInstance.projectPath.text = System.guiSettings.project.escNull();
		MainWindowInstance.wgtSrcDirPath.text = System.guiSettings.srcDir.escNull();
		
		MainWindowInstance.wgtMakeUiInst.selected = System.guiSettings.makeInstance;
		MainWindowInstance.guiInstanceTemplate.value = System.guiSettings.guiInstanceTemplate;
		MainWindowInstance.guiInstancePath.text = System.guiSettings.guiInstancePath.escNull();
		MainWindowInstance.rootName.text = System.guiSettings.rootName.escNull();
		
		MainWindowInstance.presetsList.value = System.guiSettings.preset;
		
		MainWindowInstance.framesList.value = System.guiSettings.frameTemplate;
		MainWindowInstance.framesList.dispatchEvent(new WidgetEvent(WidgetEvent.CHANGE));
		
		MainWindowInstance.guiWidth.text = Std.string(System.guiSettings.guiWidth);
		MainWindowInstance.guiHeight.text = Std.string(System.guiSettings.guiHeight);
		MainWindowInstance.guiHeight.dispatchEvent(new Event(Event.CHANGE));
		
		MainWindowInstance.fixedWindowSize.selected = System.guiSettings.fixedWindowSize;
	}
	
	//-----------------------------------------------------------------------------------------------
	// tab Designer: widget's movement
	
	public static function onBoxClick (e:MouseEvent) : Void {
		var selWgt:Dynamic = null;
		
		if (System.selWgtData != null)
			if (FileSystem.exists(System.selWgtData.xml.escNull())) {
				if (FileSystem.exists(System.selWgtData.bin.escNull())) {
					
					trace(Loader.local().loadModule(System.selWgtData.bin).exportsTable());
					return;
					
					var wgtBinCls:Dynamic = Reflect.field(Loader.local().loadModule(System.selWgtData.bin).exportsTable().__classes, "GridWidget");
					untyped wgtBinCls.__super__ = Widget;
					
					RTXml.regClass(wgtBinCls);
				}
				
				var selXml:Xml = System.parseXml(File.getContent(System.selWgtData.xml)).firstElement();
				selWgt = RTXml.buildFn(selXml.toString())();
				
				selWgt.applySkin(); // workaround for http://disq.us/p/1crbq7g
				
				var targetWgt:Widget = cast(e.currentTarget, Widget);
				targetWgt.addChild(selWgt);
				
				var targetXml:Xml = System.wgtUiXmlMap.get(targetWgt);
				targetXml.addChild(selXml);
				
				System.wgtUiXmlMap.set(selWgt, selXml);
				System.setWgtEventHandlers(selWgt);
			}
		
		MainWindowInstance.wlSelectBtn.selected = true;
		
		if (selWgt != null) {
			System.setWgtProperty(selWgt, "top", Std.string(Std.int(e.localY)));
			System.setWgtProperty(selWgt, "left", Std.string(Std.int(e.localX)));
			
			cast(selWgt, Widget).dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
			cast(selWgt, Widget).dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
		}
		
		e.stopPropagation();
	}
	
	public static function onMoveWgtMouseDown (e:MouseEvent) : Void {
		if (MainWindowInstance.wlDeleteBtn.selected)
			System.deleteWidget(e.currentTarget);
		else {
			System.selWgt = e.currentTarget;
			
			System.moveWgt  = e.currentTarget;
			System.moveWgtX = e.stageX;
			System.moveWgtY = e.stageY;
			
			System.showWgtPropList();
		}
		
		e.stopPropagation();
	}
	
	public static function onMoveWgtMouseMove (e:MouseEvent) : Void {
		if (System.moveWgt != null) {
			var nTop:Float = cast(System.moveWgt, Widget).top + e.stageY - System.moveWgtY;
			
			if (nTop > 0 && (nTop + cast(System.moveWgt, Widget).h) < cast(System.moveWgt.parent, Widget).h) {
				System.setWgtProperty(System.moveWgt, "top", Std.string(nTop));
				System.moveWgtY = e.stageY;
			}
			
			var nLeft:Float = cast(System.moveWgt, Widget).left + e.stageX - System.moveWgtX;
			
			if (nLeft > 0 && (nLeft + cast(System.moveWgt, Widget).w) < cast(System.moveWgt.parent, Widget).w) {
				System.setWgtProperty(System.moveWgt, "left", Std.string(nLeft));
				System.moveWgtX = e.stageX;
			}
		}
		
		e.stopPropagation();
	}
	
	public static function onMoveWgtMouseUp (e:MouseEvent) : Void {
		System.moveWgt = null;
		System.moveWgtX = 0;
		System.moveWgtY = 0;
	}
	
	//-----------------------------------------------------------------------------------------------
	// gui builder
	
	public static function isBox (wgtClass:Dynamic) : Bool {
		return
			wgtClass == GuiElements ||
			wgtClass == ru.stablex.ui.widgets.Box ||
			wgtClass == ru.stablex.ui.widgets.VBox ||
			wgtClass == ru.stablex.ui.widgets.HBox ||
			wgtClass == ru.stablex.ui.widgets.Widget ||
			wgtClass == ru.stablex.ui.widgets.Scroll ||
			wgtClass == ru.stablex.ui.widgets.TabPage ||
			wgtClass == ru.stablex.ui.widgets.TabStack ||
			wgtClass == ru.stablex.ui.widgets.ViewStack ||
			wgtClass == ru.stablex.ui.widgets.Floating;
	}
	
	public static function iterateWidgets (wgt:Dynamic, onBefore:Dynamic = null, onBox:Dynamic = null, onChild:Dynamic = null, onWgt:Dynamic = null) : Void {
		if (onBefore != null)
			onBefore(wgt);
		
		if (System.isBox(Type.getClass(wgt))) {
			if (onBox != null)
				onBox(wgt);
			
			for (i in 0...cast(wgt, Widget).numChildren) {
				var chWgt:Dynamic = cast(wgt, Widget).getChildAt(i);
				
				if (Std.is(chWgt, Widget)) {
					if (onChild != null)
						onChild(wgt, chWgt, i);
					
					System.iterateWidgets(chWgt, onBefore, onBox, onChild, onWgt);
				}
			}
		}
		else if (onWgt != null)
			onWgt(wgt);
	}
	
	public static function setWgtEventHandlers (rWgt:Dynamic) : Void {
		System.iterateWidgets(rWgt,
			function (dWgt:Dynamic) {
				var wgt:Widget = cast(dWgt, Widget);
				
				wgt.addEventListener(MouseEvent.MOUSE_DOWN, function (e:MouseEvent) MainWindowInstance.mainWnd.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN)));
				
				wgt.addEventListener(MouseEvent.MOUSE_UP, System.onMoveWgtMouseUp);
				wgt.addEventListener(MouseEvent.RIGHT_CLICK, function (e:MouseEvent) MainWindowInstance.wlSelectBtn.selected = true);
				
				if (Type.getClass(dWgt) != GuiElements) {
					MainWindowInstance.guiWgtsList.options.push(['${wgt.name}:${Type.getClassName(Type.getClass(dWgt))}', wgt.name]);
					
					wgt.addEventListener(MouseEvent.MOUSE_DOWN, System.onMoveWgtMouseDown);
					wgt.addEventListener(MouseEvent.MOUSE_MOVE, System.onMoveWgtMouseMove);
				}
			},
			function (dWgt:Dynamic) {
				cast(dWgt, Widget).addEventListener(MouseEvent.CLICK, System.onBoxClick);
			},
			function (dpWgt:Dynamic, dcWgt:Dynamic, cInd:Int) {
				if (System.wgtUiXmlMap.get(dcWgt) == null)
					System.wgtUiXmlMap.set(dcWgt, System.wgtUiXmlMap.get(dpWgt).getChildAt(cInd));
			},
			function (dWgt:Dynamic) {
				cast(dWgt, Widget).addEventListener(MouseEvent.CLICK, function (e:MouseEvent) MainWindowInstance.wlSelectBtn.selected = true);
			}
		);
	}
	
	public static function selectFirstWidget () : Void {
		if (MainWindowInstance.guiWgtsList.options.length > 1)
			if (!(MainWindowInstance.guiWgtsList.options[0][1] > ""))
				MainWindowInstance.guiWgtsList.options.remove(MainWindowInstance.guiWgtsList.options[0]);
		
		MainWindowInstance.guiWgtsList.value = MainWindowInstance.guiWgtsList.options[0][1];
		MainWindowInstance.guiWgtsList.text = MainWindowInstance.guiWgtsList.options[0][0];
		MainWindowInstance.guiWgtsList.dispatchEvent(new WidgetEvent(WidgetEvent.CHANGE));
	}
	
	public static function loadUiFromXml (xml:Xml) : Bool {
		//try {
			//var xml:Xml = System.parseXml(xmlStr).firstElement();
			
			if (xml.nodeName == "GuiElements") {
				System.guiElementsWgt = null;
				System.guiElementsXml = System.guiElementsXml.replaceWith(xml);
				
				xml = System.frameXml;
			}
			
			var savedGuiElemsWgt = (System.guiElementsWgt != null ? System.guiElementsWgt.numChildren > 0 : false) ? System.guiElementsWgt : null;
			var savedGuiElemsXml = System.guiElementsXml != null ? System.guiElementsXml.clone() : null;
			
			if (savedGuiElemsWgt != null)
				savedGuiElemsWgt.parent.removeChild(savedGuiElemsWgt);
			
			MainWindowInstance.wgtMainWndContainer.freeChildren(true);
			MainWindowInstance.guiWgtsList.options = [ ["", null] ];
			MainWindowInstance.wgtsPropsLst.freeChildren(true);
			System.wgtUiXmlMap = new Map<{}, Xml>();
			
			var wgtDyn:Dynamic = RTXml.buildFn(System.printXml(xml, "   "))();
			
			if (Type.getClass(wgtDyn) == ru.stablex.ui.widgets.Floating)
				cast(wgtDyn, Floating).show();
			
			System.frameWgt = cast(wgtDyn, Widget);
			System.frameXml = xml;
			
			if (savedGuiElemsWgt != null && savedGuiElemsXml != null) {
				System.guiElementsWgt = savedGuiElemsWgt;
				
				var parent:Widget = cast(System.frameWgt.getChild("guiElements").parent, Widget);
				parent.removeChild(parent.getChild("guiElements"));
				parent.addChild(System.guiElementsWgt);
				
				for (elem in System.guiElementsXml.elements())
					System.guiElementsXml.removeChild(elem);
				
				for (elem in savedGuiElemsXml.elements()) {
					savedGuiElemsXml.removeChild(elem);
					System.guiElementsXml.addChild(elem);
				}
				
				System.guiElementsXml = System.frameXml.getByXpath("//GuiElements").replaceWith(System.guiElementsXml);
			}
			else {
				System.guiElementsWgt = cast(System.frameWgt.getChild("guiElements"), Widget);
				System.guiElementsXml = System.frameXml.getByXpath("//GuiElements");
			}
			
			MainWindowInstance.wgtMainWndContainer.addChild(System.frameWgt);
			
			System.wgtUiXmlMap.set(System.guiElementsWgt, System.guiElementsXml);
			System.setWgtEventHandlers(System.guiElementsWgt);
			System.selectFirstWidget();
			
			MainWindowInstance.xmlSource.text = System.printXml(System.guiElementsXml, "   ");
		//}
		//catch (ex:Dynamic) {
		//	this.newGuiBtn.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		//	return false;
		//}
		
		return true;
	}
	
	//-----------------------------------------------------------------------------------------------
	// gui file
	
	public static function loadUiFromFile (xmlPath:String) : Bool {
		System.uiDirPath = Path.directory(xmlPath);
		System.uiXmlPath = xmlPath;
		
		var guiXml:Xml = System.parseXml(File.getContent(xmlPath)).firstElement();
		System.loadUiSettingsFromXml(guiXml);
		
		return System.loadUiFromXml(guiXml);
	}
	
	public static function saveUiToFile (xmlPath:String) : Bool {
		if (MainWindowInstance.designerTabs.activeTab().name != "tabXml")
			MainWindowInstance.xmlSource.text = System.printXml(System.guiElementsXml, "   ");
		
		System.saveUiSettingsToXml();
		
		if (System.loadUiFromXml(System.parseXml(MainWindowInstance.xmlSource.text).firstElement())) {
			if (System.guiSettings.makeInstance)
				SourceControl.makeInstance();
			
			
			File.saveContent(xmlPath, System.printXml(System.frameXml, "	"));
			
			return true;
		}
		
		return false;
	}
	
	//-----------------------------------------------------------------------------------------------
	// widget
	
	public static function deleteWidget (wgt:Dynamic) : Void {
		if (!Std.is(wgt, Widget))
			return;
		
		if (wgt == System.selWgt) {
			System.selWgt = null;
			System.selPropName = "";
			System.selWgtProp = null;
			System.selWgtProps = null;
			MainWindowInstance.wgtsPropsLst.freeChildren(true);
		}
		
		if (System.isBox(Type.getClass(wgt)))
			for (i in 0...cast(wgt, Widget).numChildren)
				System.deleteWidget(cast(wgt, Widget).getChildAt(i));
		
		if (System.wgtUiXmlMap.exists(wgt)) {
			System.wgtUiXmlMap.get(wgt).removeSelf();
			System.wgtUiXmlMap.remove(wgt);
		}
		
		System.iterateWidgets(wgt, function (delWgt:Dynamic) {
			if (MainWindowInstance.guiWgtsList.options.length > 1) {
				for (opt in MainWindowInstance.guiWgtsList.options)
					if (opt[1] == cast(delWgt, Widget).name) {
						MainWindowInstance.guiWgtsList.options.remove(opt);
						MainWindowInstance.guiWgtsList.refresh();
						break;
					}
			}
			else
				MainWindowInstance.guiWgtsList.options = [ ["", null] ];
		});
		
		System.selectFirstWidget();
		
		cast(wgt, Widget).parent.removeChild(wgt);
	}
	
	//-----------------------------------------------------------------------------------------------
	// widget's propety
	
	public static function propNameMap (propName:String) : String {
		return switch (propName.toLowerCase()) {
			case "w": "width";
			case "h": "height";
			default: propName;
		}
	}
	
	public static function showWgtPropList () : Void {
		System.selWgtProps = new Map<String, HBox>();
		
		MainWindowInstance.guiWgtsList.value = cast(System.selWgt, Widget).name;
		
		MainWindowInstance.wgtsPropsLst.freeChildren(true);
		MainWindowInstance.wgtsPropsLst.layout = new Row();
		cast(MainWindowInstance.wgtsPropsLst.layout, Row).rows = new Array<Float>();
		
		var sx:Xml = System.wgtUiXmlMap.get(System.selWgt);
		
		for (att in sx.attributes())
			System.addPropRow(att, sx.get(att));
	}
	
	public static function setWgtProperty (wgt:Dynamic, property:String, propValue:String) : Void {
		var wgtXml:Xml = System.wgtUiXmlMap.get(wgt);
		
		if (wgtXml.exists(property)) {
			var ownerInfo:GuiObjPropOwnerInfo = System.setGuiObjProperties(wgt, [{ name: property, value: propValue }]).pop();
			
			if (propValue > "")
				wgtXml.set(property, Std.is(Reflect.getProperty(ownerInfo.propOwner, ownerInfo.propName), Float) ? propValue.replace(",", ".") : propValue);
			else
				wgtXml.remove(property);
			
			if (System.selWgtProps != null)
				if (System.selWgtProps.exists(property))
					cast(cast(System.selWgtProps.get(property), HBox).getChild("propValue"), Text).text = Std.string(wgtXml.get(property));
			
			cast(wgt, Widget).refresh();
		}
	}
	
	public static function addPropRow (prop:String, value:String) : Void {
		var row:HBox = UIBuilder.buildFn("XmlGui/WgtPropRow.xml")();
		
		cast(row.getChild("propLabel"), Text).text = System.propNameMap(prop);
		cast(row.getChild("propValue"), Text).text = value.toLowerCase() == "null" ? "" : value;
		
		row.addEventListener(MouseEvent.CLICK, function (e:MouseEvent) {
			if (System.selWgtProp != null) {
				cast(System.selWgtProp.skin, Paint).border = 0;
				try { System.selWgtProp.refresh(); } catch (ex:Dynamic) { } // skin prop selection after wgt_moved "Uncaught exception - Invalid field access : get_width"
			}
			
			System.selWgtProp = cast(e.currentTarget, HBox);
			System.selPropName = prop;
			
			cast(System.selWgtProp.skin, Paint).border = 1;
			System.selWgtProp.refresh();
		});
		
		cast(MainWindowInstance.wgtsPropsLst.layout, Row).rows.push(20);
		MainWindowInstance.wgtsPropsLst.addChild(row);
		
		System.selWgtProps.set(prop, row);
	}
	
	//-----------------------------------------------------------------------------------------------
	// gui objects's propety
	
	public static function setGuiObjProperties (obj:Dynamic, properies:Array<GuiObjPropInfo>) : Array<GuiObjPropOwnerInfo> {
		var owners:Array<GuiObjPropOwnerInfo> = new Array<GuiObjPropOwnerInfo>();
		
		var parser = new hscript.Parser();
		var interp = new hscript.Interp();
		
		for (propInfo in properies) {
			var ownerInfo:GuiObjPropOwnerInfo = System.getPropertyOwner(obj, propInfo.name);
			var prop:Dynamic = Reflect.getProperty(ownerInfo.propOwner, ownerInfo.propName);
			
			for(cls in RTXml.imports.keys())
				interp.variables.set("__ui__" + cls, RTXml.imports.get(cls));
			
			Reflect.setProperty(ownerInfo.propOwner, ownerInfo.propName, interp.execute(parser.parseString(ru.stablex.ui.RTXml.Attribute.fillShortcuts(StringTools.replace(propInfo.value, "%SUIDCWD", '"${Sys.getCwd()}"')))));
			
			owners.push(ownerInfo);
		}
		
		return owners;
	}
	
	public static function getPropertyOwner (wgt:Dynamic, property:String) : GuiObjPropOwnerInfo {
		var propLst:Array<String> = property.split("-");
		
		var propOwner:Dynamic = wgt;
		var propName:String = property;
		
		for (i in 0...propLst.length) {
			var ppInfo:Array<String> = propLst[i].split(":");
			propName = ppInfo[0];
			
			if (Reflect.getProperty(propOwner, propName) == null && i < (propLst.length - 1)) {
				Reflect.setProperty(
					propOwner,
					propName,
					Type.createInstance(
						ppInfo.length > 1 ?
						Type.resolveClass(ppInfo[1]) :
						Type.getClass(Reflect.getProperty(propOwner, propName)),
						[]
					)
				);
			}
			
			if (i < (propLst.length - 1))
				propOwner = Reflect.getProperty(propOwner, propName);
		}
		
		return { propOwner: propOwner, propName: propName };
	}
}