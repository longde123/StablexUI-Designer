package rn.stablex.designer;

import ru.stablex.ui.*;
import ru.stablex.ui.widgets.*;

@:noCompletion class ClockTime { // workaround for https://github.com/RealyUniqueName/StablexUI/issues/235
	public static function getCurrSeconds () : Int
		return Date.now().getHours() * 60 * 60 + Date.now().getMinutes() * 60 + Date.now().getSeconds(); 
}

class MainWindowInstance {
	macro static public function geInit () : Void {
		UIBuilder.buildClass("XmlGui/MainWindowMenu.xml", "MainWindowMenu");
		UIBuilder.buildClass("XmlGui/MainWindowTabDesigner.xml", "MainWindowTabDesigner");
		UIBuilder.buildClass("XmlGui/MainWindowTabProject.xml", "MainWindowTabProject");
		UIBuilder.buildClass("XmlGui/MainWindowTabXml.xml", "MainWindowTabXml");
		UIBuilder.buildClass("XmlGui/GuiElements.xml", "GuiElements");
		UIBuilder.buildClass("XmlGui/WgtSelector.xml", "WgtSelector");
		UIBuilder.buildClass("XmlGui/DesignerArea.xml", "DesignerArea");
		UIBuilder.buildClass("XmlGui/WgtPropRow.xml", "WgtPropRow");
		UIBuilder.buildClass("XmlGui/WgtsPropsLst.xml", "WgtsPropsLst");
	}
	
	#if !macro
	//-----------------------------------------------------------------------------------------------
	// gui elements
	
	public static var mainWnd:Floating;
	
	public static var newGuiBtn:Button;
	public static var loadGuiBtn:Button;
	public static var saveGuiBtn:Button;
	
	public static var designerTabs:TabStack;
	public static var tabProject:TabPage;
	public static var tabDesigner:TabPage;
	public static var tabXml:TabPage;
	
	public static var guiName:InputText;
	
	public static var wgtSrcActNoth:Radio;
	public static var wgtSrcActLink:Radio;
	public static var projectPath:InputText;
	public static var wgtSrcActCopy:Radio;
	public static var wgtSrcDirPath:InputText;
	
	public static var wgtMakeUiInst:Checkbox;
	public static var guiInstanceTemplate:Options;
	public static var guiInstancePath:InputText;
	public static var rootName:InputText;
	public static var presetsList:Options;
	public static var guiWidth:InputText;
	public static var guiHeight:InputText;
	public static var fixedWindowSize:Checkbox;
	public static var framesList:Options;
	
	public static var wgtGroupsLst:Options;
	public static var wlSelectBtn:Radio;
	public static var wlDeleteBtn:Radio;
	public static var wgtsLst:HBox;
	
	public static var wgtMainWndContainer:VBox;
	
	public static var guiWgtsList:Options;
	
	public static var wgtsPropsLst:VBox;
	public static var showWgtPropsBtn:Button;
	public static var showEditWgtPropBtn:Button;
	public static var deleteWgtPropBtn:Button;
	
	public static var wgtPropWnd:Floating;
	public static var wgtPropTypesLst:Options;
	public static var wgtPropNamesLst:Options;
	public static var wgtAddPropBtn:Button;
	
	public static var wgtEditPropWnd:Floating;
	public static var editPropName:Text;
	public static var editPropType:Text;
	public static var editPropValue:InputText;
	public static var editPropValueSaveBtn:Button;
	
	public static var xmlSource:InputText;
	
	//-----------------------------------------------------------------------------------------------
	// gui initialization
	
	public static function setupInstance () : Void {
		UIBuilder.regClass("haxe.io.Path");
		UIBuilder.regClass("openfl.display.BitmapData");
		UIBuilder.regClass("ru.stablex.ui.skins.Skin");
		UIBuilder.regClass("ClockTime");
		
		UIBuilder.customStringReplace = function (strValue:String) : String return StringTools.replace(strValue, "SUIDCWD", Sys.getCwd());
		UIBuilder.init(null, true);
		
		MainWindowInstance.mainWnd = UIBuilder.buildFn("XmlGui/MainWindow.xml")();
		
		MainWindowInstance.guiName = cast(MainWindowInstance.mainWnd.getChild("guiName"), InputText);
		
		MainWindowInstance.newGuiBtn = cast(MainWindowInstance.mainWnd.getChild("newGuiBtn"), Button);
		MainWindowInstance.loadGuiBtn = cast(MainWindowInstance.mainWnd.getChild("loadGuiBtn"), Button);
		MainWindowInstance.saveGuiBtn = cast(MainWindowInstance.mainWnd.getChild("saveGuiBtn"), Button);
		
		MainWindowInstance.designerTabs = cast(MainWindowInstance.mainWnd.getChild("designerTabs"), TabStack);
		MainWindowInstance.tabProject = cast(MainWindowInstance.mainWnd.getChild("tabProject"), TabPage);
		MainWindowInstance.tabDesigner = cast(MainWindowInstance.mainWnd.getChild("tabDesigner"), TabPage);
		MainWindowInstance.tabXml = cast(MainWindowInstance.mainWnd.getChild("tabXml"), TabPage);
		
		MainWindowInstance.wgtSrcActNoth = cast(MainWindowInstance.mainWnd.getChild("wgtSrcActNoth"), Radio);
		MainWindowInstance.wgtSrcActLink = cast(MainWindowInstance.mainWnd.getChild("wgtSrcActLink"), Radio);
		MainWindowInstance.projectPath = cast(MainWindowInstance.mainWnd.getChild("projectPath"), InputText);
		MainWindowInstance.wgtSrcActCopy = cast(MainWindowInstance.mainWnd.getChild("wgtSrcActCopy"), Radio);
		MainWindowInstance.wgtSrcDirPath = cast(MainWindowInstance.mainWnd.getChild("wgtSrcDirPath"), InputText);
		
		MainWindowInstance.wgtMakeUiInst = cast(MainWindowInstance.mainWnd.getChild("wgtMakeUiInst"), Checkbox);
		MainWindowInstance.guiInstanceTemplate = cast(MainWindowInstance.mainWnd.getChild("guiInstanceTemplate"), Options);
		MainWindowInstance.guiInstancePath = cast(MainWindowInstance.mainWnd.getChild("guiInstancePath"), InputText);
		MainWindowInstance.rootName = cast(MainWindowInstance.mainWnd.getChild("rootName"), InputText);
		MainWindowInstance.presetsList = cast(MainWindowInstance.mainWnd.getChild("presetsList"), Options);
		MainWindowInstance.guiWidth = cast(MainWindowInstance.mainWnd.getChild("guiWidth"), InputText);
		MainWindowInstance.guiHeight = cast(MainWindowInstance.mainWnd.getChild("guiHeight"), InputText);
		MainWindowInstance.fixedWindowSize = cast(MainWindowInstance.mainWnd.getChild("fixedWindowSize"), Checkbox);
		MainWindowInstance.framesList = cast(MainWindowInstance.mainWnd.getChild("framesList"), Options);
		
		MainWindowInstance.wgtGroupsLst = cast(MainWindowInstance.mainWnd.getChild("wgtGroupsLst"), Options);
		MainWindowInstance.wlSelectBtn = cast(MainWindowInstance.mainWnd.getChild("wlSelectBtn"), Radio);
		MainWindowInstance.wlDeleteBtn = cast(MainWindowInstance.mainWnd.getChild("wlDeleteBtn"), Radio);
		MainWindowInstance.wgtsLst = cast(MainWindowInstance.mainWnd.getChild("wgtsLst"), HBox);
		
		MainWindowInstance.wgtMainWndContainer = cast(MainWindowInstance.mainWnd.getChild("wgtMainWndContainer"), VBox);
		
		MainWindowInstance.guiWgtsList = cast(MainWindowInstance.mainWnd.getChild("guiWgtsList"), Options);
		
		MainWindowInstance.wgtsPropsLst = cast(MainWindowInstance.mainWnd.getChild("wgtsPropsLst"), VBox);
		MainWindowInstance.showWgtPropsBtn = cast(MainWindowInstance.mainWnd.getChild("showWgtPropsBtn"), Button);
		MainWindowInstance.showEditWgtPropBtn = cast(MainWindowInstance.mainWnd.getChild("showEditWgtPropBtn"), Button);
		MainWindowInstance.deleteWgtPropBtn = cast(MainWindowInstance.mainWnd.getChild("deleteWgtPropBtn"), Button);
		
		MainWindowInstance.wgtPropWnd = UIBuilder.buildFn("XmlGui/AddPropWindow.xml")();
		MainWindowInstance.wgtPropTypesLst = cast(MainWindowInstance.wgtPropWnd.getChild("wgtPropTypesLst"), Options);
		MainWindowInstance.wgtPropNamesLst = cast(MainWindowInstance.wgtPropWnd.getChild("wgtPropNamesLst"), Options);
		MainWindowInstance.wgtAddPropBtn = cast(MainWindowInstance.wgtPropWnd.getChild("wgtAddPropBtn"), Button);
		
		MainWindowInstance.wgtEditPropWnd = UIBuilder.buildFn("XmlGui/EditPropWindow.xml")();
		MainWindowInstance.editPropName = cast(MainWindowInstance.wgtEditPropWnd.getChild("editPropName"), Text);
		MainWindowInstance.editPropType = cast(MainWindowInstance.wgtEditPropWnd.getChild("editPropType"), Text);
		MainWindowInstance.editPropValue = cast(MainWindowInstance.wgtEditPropWnd.getChild("editPropValue"), InputText);
		MainWindowInstance.editPropValueSaveBtn = cast(MainWindowInstance.wgtEditPropWnd.getChild("editPropValueSaveBtn"), Button);
		
		MainWindowInstance.xmlSource = cast(MainWindowInstance.mainWnd.getChild("xmlSource"), InputText);
	}
	#end
}