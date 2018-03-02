package
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.SharedObject;
	import flash.system.*;
	import flash.text.*;
	
	import flashx.textLayout.events.*;
	
	import qnx.dialog.*;
	import qnx.display.*;
	import qnx.ui.buttons.*;
	import qnx.ui.core.*;
	import qnx.ui.skins.*;
	import qnx.ui.text.*;
	
	[SWF(height="600", width="1024", frameRate="30", backgroundColor="#000000")]
	public class SciCalc extends Sprite
	{
		public static const HELP:String =
			"Sci Calc for BlackBerry® Playbook™ v1.4.0\n" +
			"(c)2011, Pronic, Meselina Ponikvar Verhovsek s.p.\n\n" +
			"This application is a simple scientific calculator.\n\nInstructions:\n" +
			"EXIT ... leave application\n" +
			"INV ... activate inverse functions\n" +
			"DEG, RAD, GRAD ... switch to DEG, RAD or GRAD mode\n" +
			"0-9, ., +/- ... enter number value\n" +
			"functions ... executing various mathematical functions\n" +
			"+, -, *, /, = ... basic mathematical operations\n" +
			"MS, MR, MC ... store, recall and clear memory\n" +
			"DEL ... delete displayed value\n" + 
			"CLR ... clear all values\n\n" +
			"Example1:\n2 + 3 * 5\n[2] [+] [3] [*] [5] [=]\n\n" +
			"Example2:\n2 / 3 + SQRT(25)\n[2] [/] [3] [+] [25] [SQRT] [=]\n\n" +
			"Example3:\n-2 + 0.5 stored into MEM\n[2] [+/-] [+] [0] [.] [5] [=] [MS]\n\n" +
			"Example4:\n10^MEM * E^2\n[MR] [10^X] [*] [2] [E^X] [=]\n\n" +
			"Example5:\n3! + LN(2) + 2^3\n[3] [N!] [+] [2] [LN] [+] [2] [Y^X] [3] [=]\n\n" +
			"Example6:\nSIN(30deg) + COS(PI) - ASIN(0)\n[3] [0] [SIN] [+] [DEG] [PI] [COS] [-] [0] [INV] [ASIN] [=]";
			
		
		// Orientation consts
		public static const ORIENTATION_PORTRAIT:int = 0;
		public static const ORIENTATION_LANDSCAPE:int = 1;
		
		// TRANGULAR MODES
		public static const DEG:int = 0;
		public static const RAD:int = 1;
		public static const GRAD:int = 2;
		
		public static const DRG_MAX:int = 2;

		// Button GUI consts
		public static const BUTTON_WIDTH:int = 100;
		public static const BUTTON_HEIGHT:int = 100;
		public static const BUTTON_SPACE:int = 10;
		public static const BUTTON_LANDSCAPE_HORIZONTAL_BORDER:int = 22;
		public static const BUTTON_PORTRAIT_HORIZONTAL_BORDER:int = 30;
		public static const BUTTON_LANDSCAPE_VERTICAL_BORDER:int = 15;
		public static const BUTTON_PORTRAIT_VERTICAL_BORDER:int = 30;
		
		// Calc
		public static const OPER_NONE:int = 0;
		public static const OPER_ADD:int = 1;
		public static const OPER_SUB:int = 2;
		public static const OPER_MUL:int = 3;
		public static const OPER_DIV:int = 4;
		public static const OPER_POW:int = 5;
		
		public static const MAX_DIGITS:int = 36;
		public static const RESET_DISPLAY:String = "0";
		public static const NAN:String = "NOT A NUMBER";

		private var isNumber:Boolean = false;
		private var mem:Number = 0;
		private var accuA:Number = 0;
		private var accuB:Number = 0;
		private var accuC:Number = 0;
		private var accuD:Number = 0;
		private var oper1:int = OPER_NONE;
		private var oper2:int = OPER_NONE;
		private var oper3:int = OPER_NONE;
		private var displayAccuA:String = RESET_DISPLAY;
		
		// debug
		private var debugLabel:Label = new Label(); 
		
		// Global values
		public static var screenWidth:int;
		public static var screenHeight:int;
		public static var orientation:int;
		public static var shiftLevel:Boolean = false;
		public static var hypLevel:Boolean = false;
		public static var drgLevel:int = DEG;
		
		// Text formats
		private static var labelTextFormat:TextFormat = new TextFormat();
		private static var labelBoldTextFormat:TextFormat = new TextFormat();
		private static var displayTextFormat:TextFormat = new TextFormat();
		private var addTextFormat:TextFormat = new TextFormat();

		// Display
		private var displayTextInput:TextInput = new TextInput();
		
		// Numeric buttons
		private var zeroButton:LabelButton = new LabelButton();
		private var oneButton:LabelButton = new LabelButton();
		private var twoButton:LabelButton = new LabelButton();
		private var threeButton:LabelButton = new LabelButton();
		private var fourButton:LabelButton = new LabelButton();
		private var fiveButton:LabelButton = new LabelButton();
		private var sixButton:LabelButton = new LabelButton();
		private var sevenButton:LabelButton = new LabelButton();
		private var eightButton:LabelButton = new LabelButton();
		private var nineButton:LabelButton = new LabelButton();
		private var addLabel:Label;
		
		// Decimal additional buttons
		private var dotButton:LabelButton = new LabelButton();
		private var negativeButton:LabelButton = new LabelButton();
		
		// Basic math buttons
		private var equalsButton:LabelButton = new LabelButton();
		private var addButton:LabelButton = new LabelButton();
		private var subButton:LabelButton = new LabelButton();
		private var mulButton:LabelButton = new LabelButton();
		private var divButton:LabelButton = new LabelButton();

		// Memory buttons
		private var mcButton:LabelButton = new LabelButton();
		private var mrButton:LabelButton = new LabelButton();
		private var msButton:LabelButton = new LabelButton();

		// System buttons
		private var shiftButton:LabelButton = new LabelButton();
		private var drgButton:LabelButton = new LabelButton();
		private var xButton:LabelButton = new LabelButton();
		private var helpButton:LabelButton = new LabelButton();
		private var delButton:LabelButton = new LabelButton();
		private var clrButton:LabelButton = new LabelButton();

		// Func buttons
		private var factorButton:LabelButton = new LabelButton();
		private var piButton:LabelButton = new LabelButton();
		
		// Multifunc buttons
		private var sinButton:LabelButton = new LabelButton();
		private var cosButton:LabelButton = new LabelButton();
		private var tanButton:LabelButton = new LabelButton();
		private var squareButton:LabelButton = new LabelButton();
		private var inverseButton:LabelButton = new LabelButton();
		private var expButton:LabelButton = new LabelButton();
		private var lnButton:LabelButton = new LabelButton();
		private var powButton:LabelButton = new LabelButton();
		private var logButton:LabelButton = new LabelButton();
		private var pow10Button:LabelButton = new LabelButton();
		private var sqrtButton:LabelButton = new LabelButton();
		private var qubButton:LabelButton = new LabelButton();
		
		public function SciCalc()
		{
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
//			stage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGE, onOrientationChange);
			stage.nativeWindow.visible = true;
		}
		
		private function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

			// support autoOrients
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			showEula();

			setTextFormats();
			addCalcButtons();
			setToggleButton();
			addDisplay();
			setOrientation();
			
/*			debugLabel.setPosition(0, 0);
			debugLabel.width = 600;
			debugLabel.height = 30;
			addChild(debugLabel);*/
			
//			addEventListeners();

			stage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGE, onOrientationChange);
		}
		
		private function showEula():void
		{
			var so:SharedObject = SharedObject.getLocal("scicalc-eula");
			
			if (so.data.eula == undefined || so.data.eula == 0)
			{
				var eulaDialog:AlertDialog = new AlertDialog();
				eulaDialog.title = "END USER AGREEMENT AND LICENSE";
				eulaDialog.message = EULA;
				eulaDialog.addButton("I agree");
				eulaDialog.dialogSize = DialogSize.SIZE_FULL;
				eulaDialog.addEventListener(Event.SELECT, onEulaClose);
				eulaDialog.show(IowWindow.getAirWindow().group);
			}
		}
		
		private function onEulaClose(event:Event):void
		{
			var so:SharedObject = SharedObject.getLocal("scicalc-eula");
			so.data.eula = 1;
			so.flush();
		}
		
		private function setTextFormats():void
		{
			labelTextFormat.font = "Courier";
			labelTextFormat.bold = true;
			labelTextFormat.size = 24;
			
			labelBoldTextFormat.font = "Courier";
			labelBoldTextFormat.bold = true;
			labelBoldTextFormat.size = 24;

			displayTextFormat.font = "Courier";
			displayTextFormat.bold = true;
			displayTextFormat.size = 28;
			displayTextFormat.align = TextFormatAlign.RIGHT;

			addTextFormat.bold = true;
			addTextFormat.size = 12;
			addTextFormat.font = "Courier";
			addTextFormat.color = 0xffffff;
			addTextFormat.align = "center";
		}
		
		private function onOrientationChange(event:StageOrientationEvent):void
		{
			setOrientation();
		}
		
		private function setOrientation():void
		{
			screenWidth = stage.fullScreenWidth;
			screenHeight = stage.fullScreenHeight;
			if (screenWidth > screenHeight)
			{
				orientation = ORIENTATION_LANDSCAPE;
			}
			else
			{
				orientation = ORIENTATION_PORTRAIT;
			}
			rearrangeButtons(orientation);
		}
		
		private function addCalcButton(button:LabelButton, value:String, color:uint, isBold:Boolean = false):void
		{
			button.label = value;
			button.width = BUTTON_WIDTH;
			button.height = BUTTON_HEIGHT;
			button.addEventListener(MouseEvent.CLICK, onButtonClick);
			button.setTextFormatForState((isBold ? labelBoldTextFormat : labelTextFormat), SkinStates.DISABLED);
			button.setTextFormatForState((isBold ? labelBoldTextFormat : labelTextFormat), SkinStates.DISABLED_SELECTED);
			button.setTextFormatForState((isBold ? labelBoldTextFormat : labelTextFormat), SkinStates.DOWN);
			button.setTextFormatForState((isBold ? labelBoldTextFormat : labelTextFormat), SkinStates.DOWN_SELECTED);
			button.setTextFormatForState((isBold ? labelBoldTextFormat : labelTextFormat), SkinStates.FOCUS);
			button.setTextFormatForState((isBold ? labelBoldTextFormat : labelTextFormat), SkinStates.SELECTED);
			button.setTextFormatForState((isBold ? labelBoldTextFormat : labelTextFormat), SkinStates.UP);
			button.setTextFormatForState((isBold ? labelBoldTextFormat : labelTextFormat), SkinStates.UP_ODD);
			button.opaqueBackground = color;
			addChild(button);
		}
		
		private function addDisplay():void
		{
			displayTextInput.text = displayAccuA;
			displayTextInput.format = displayTextFormat;
			displayTextInput.clearIconMode = TextInputIconMode.NEVER;
			displayTextInput.enabled = false;
			addChild(displayTextInput);
			
			
			addLabel = new Label();
			addLabel.format = addTextFormat;
			addLabel.wordWrap = true;
			addLabel.x = 0;
			addLabel.y = 0;
			addLabel.width = 1024;
			addLabel.height = 25;
			addLabel.text = "PRONIC, Meselina Ponikvar Verhovsek s.p.     PROFOUND TRANSLATIONS     For professional translations contact info@pronic.si";
			addChild(addLabel);
		}
		
		private function rearrangeButton(button:LabelButton, x:int, y:int):void
		{
			button.y = screenHeight - (orientation == ORIENTATION_LANDSCAPE ? BUTTON_LANDSCAPE_VERTICAL_BORDER : BUTTON_PORTRAIT_VERTICAL_BORDER) - 
				(y + 1) * BUTTON_HEIGHT - y * BUTTON_SPACE;
			button.x = (orientation == ORIENTATION_LANDSCAPE ? BUTTON_LANDSCAPE_HORIZONTAL_BORDER : BUTTON_PORTRAIT_HORIZONTAL_BORDER) + 
				x * (BUTTON_WIDTH + BUTTON_SPACE);
		}
		
		private function doShift():void
		{
			shiftLevel = !shiftLevel;
			if (shiftLevel == false)
			{
				sinButton.label = "SIN";
				cosButton.label = "COS";
				tanButton.label = "TAN";
			}
			else
			{
				sinButton.label = "ASIN";
				cosButton.label = "ACOS";
				tanButton.label = "ATAN";
			}
		}
		
		private function setToggleButton():void
		{
//			hypButton.toggle = true;
		}
		
		private function doDrg():void
		{
			drgLevel++;
			if (drgLevel > DRG_MAX)
			{
				drgLevel = 0;
			}
			if (drgLevel == DEG)
			{
				drgButton.label = "DEG";
			}
			else if (drgLevel == RAD)
			{
				drgButton.label = "RAD";
			}
			else
			{
				drgButton.label = "GRAD";
			}
		}
		
		private function addCalcButtons():void
		{
			addCalcButton(zeroButton, "0", 0xccccff, true);
			addCalcButton(dotButton, ".", 0xccccff, true);
			addCalcButton(negativeButton, "+/-", 0xccccff);
			addCalcButton(addButton, "+", 0xccffcc, true);
			addCalcButton(equalsButton, "=", 0xccffcc, true);
			addCalcButton(oneButton, "1", 0xccccff, true);
			addCalcButton(twoButton, "2", 0xccccff, true);
			addCalcButton(threeButton, "3", 0xccccff, true);
			addCalcButton(subButton, "-", 0xccffcc, true);
			addCalcButton(msButton, "MS", 0xffccff);
			addCalcButton(fourButton, "4", 0xccccff, true);
			addCalcButton(fiveButton, "5", 0xccccff, true);
			addCalcButton(sixButton, "6", 0xccccff, true);
			addCalcButton(mulButton, "*", 0xccffcc, true);
			addCalcButton(mrButton, "MR", 0xffccff);
			addCalcButton(sevenButton, "7", 0xccccff, true);
			addCalcButton(eightButton, "8", 0xccccff, true);
			addCalcButton(nineButton, "9", 0xccccff, true);
			addCalcButton(divButton, "/", 0xccffcc, true);
			addCalcButton(mcButton, "MC", 0xffccff);
			addCalcButton(powButton, "Y^X", 0xffffcc);
			addCalcButton(logButton, "LOG", 0xffffcc);
			addCalcButton(shiftButton, "INV", 0xffcccc, true);
			addCalcButton(qubButton, "X^3", 0xffffcc);
			addCalcButton(drgButton, "DEG", 0xffcccc, true);
			addCalcButton(sqrtButton, "SQRT", 0xffffcc);
			addCalcButton(factorButton, "N!", 0xffffcc);
			addCalcButton(piButton, "PI", 0xffffcc);
			addCalcButton(pow10Button, "10^X", 0xffffcc);
			addCalcButton(sinButton, "SIN", 0xffffcc);
			addCalcButton(cosButton, "COS", 0xffffcc);
			addCalcButton(tanButton, "TAN", 0xffffcc);
			addCalcButton(squareButton, "X^2", 0xffffcc);
			addCalcButton(inverseButton, "1/X", 0xffffcc);
			addCalcButton(expButton, "E^X", 0xffffcc);
			addCalcButton(lnButton, "LN", 0xffffcc);
			addCalcButton(xButton, "EXIT", 0xffcccc, true);
			addCalcButton(helpButton, "HELP", 0xffcccc, true);
			addCalcButton(delButton, "DEL", 0xffcccc, true);
			addCalcButton(clrButton, "CLR", 0xffcccc, true);
		}

		private function rearrangeButtons(orientation:int):void
		{
			if (orientation == ORIENTATION_LANDSCAPE)
			{
				rearrangeButton(powButton, 0, 0);
				rearrangeButton(logButton, 1, 0);
				rearrangeButton(lnButton, 2, 0);
				rearrangeButton(pow10Button, 3, 0);
				rearrangeButton(zeroButton, 4, 0);
				rearrangeButton(dotButton, 5, 0);
				rearrangeButton(equalsButton, 6, 0);
				rearrangeButton(addButton, 7, 0);
				rearrangeButton(negativeButton, 8, 0);

				rearrangeButton(factorButton, 0, 1);
				rearrangeButton(tanButton, 1, 1);
				rearrangeButton(expButton, 2, 1);
				rearrangeButton(piButton, 3, 1);
				rearrangeButton(oneButton, 4, 1);
				rearrangeButton(twoButton, 5, 1);
				rearrangeButton(threeButton, 6, 1);
				rearrangeButton(subButton, 7, 1);
				rearrangeButton(msButton, 8, 1);
				
				rearrangeButton(drgButton, 0, 2);
				rearrangeButton(cosButton, 1, 2);
				rearrangeButton(inverseButton, 2, 2);
				rearrangeButton(sqrtButton, 3, 2);
				rearrangeButton(fourButton, 4, 2);
				rearrangeButton(fiveButton, 5, 2);
				rearrangeButton(sixButton, 6, 2);
				rearrangeButton(mulButton, 7, 2);
				rearrangeButton(mrButton, 8, 2);

				rearrangeButton(shiftButton, 0, 3);
				rearrangeButton(sinButton, 1, 3);
				rearrangeButton(squareButton, 2, 3);
				rearrangeButton(qubButton, 3, 3);
				rearrangeButton(sevenButton, 4, 3);
				rearrangeButton(eightButton, 5, 3);
				rearrangeButton(nineButton, 6, 3);
				rearrangeButton(divButton, 7, 3);
				rearrangeButton(mcButton, 8, 3);

				rearrangeButton(xButton, 0, 4);
				rearrangeButton(helpButton, 1, 4);
				rearrangeButton(delButton, 7, 4);
				rearrangeButton(clrButton, 8, 4);
				
				displayTextInput.y = screenHeight - BUTTON_LANDSCAPE_VERTICAL_BORDER - 5 * BUTTON_HEIGHT - 4 * BUTTON_SPACE;
				displayTextInput.x = BUTTON_LANDSCAPE_HORIZONTAL_BORDER + 2 * (BUTTON_WIDTH + BUTTON_SPACE);
				displayTextInput.width = 5 * BUTTON_WIDTH + 4 * BUTTON_SPACE;
				displayTextInput.height = BUTTON_HEIGHT;
			}
			else
			{
				rearrangeButton(zeroButton, 0, 0);
				rearrangeButton(dotButton, 1, 0);
				rearrangeButton(equalsButton, 2, 0);
				rearrangeButton(addButton, 3, 0);
				rearrangeButton(negativeButton, 4, 0);
				
				rearrangeButton(oneButton, 0, 1);
				rearrangeButton(twoButton, 1, 1);
				rearrangeButton(threeButton, 2, 1);
				rearrangeButton(subButton, 3, 1);
				rearrangeButton(msButton, 4, 1);
				
				rearrangeButton(fourButton, 0, 2);
				rearrangeButton(fiveButton, 1, 2);
				rearrangeButton(sixButton, 2, 2);
				rearrangeButton(mulButton, 3, 2);
				rearrangeButton(mrButton, 4, 2);
				
				rearrangeButton(sevenButton, 0, 3);
				rearrangeButton(eightButton, 1, 3);
				rearrangeButton(nineButton, 2, 3);
				rearrangeButton(divButton, 3, 3);
				rearrangeButton(mcButton, 4, 3);

				rearrangeButton(logButton, 0, 4);
				rearrangeButton(powButton, 1, 4);
				rearrangeButton(piButton, 2, 4);
				rearrangeButton(sqrtButton, 3, 4);
				rearrangeButton(pow10Button, 4, 4);
				
				rearrangeButton(lnButton, 0, 5);
				rearrangeButton(expButton, 1, 5);
				rearrangeButton(inverseButton, 2, 5);
				rearrangeButton(qubButton, 3, 5);
				rearrangeButton(squareButton, 4, 5);

				rearrangeButton(drgButton, 0, 6);
				rearrangeButton(sinButton, 1, 6);
				rearrangeButton(cosButton, 2, 6);
				rearrangeButton(tanButton, 3, 6);
				rearrangeButton(factorButton, 4, 6);

				rearrangeButton(xButton, 0, 7);
				rearrangeButton(helpButton, 1, 7);
				rearrangeButton(shiftButton, 2, 7);
				rearrangeButton(delButton, 3, 7);
				rearrangeButton(clrButton, 4, 7);
				
				displayTextInput.y = screenHeight - BUTTON_PORTRAIT_VERTICAL_BORDER - 9 * BUTTON_HEIGHT - 8 * BUTTON_SPACE;
				displayTextInput.x = BUTTON_PORTRAIT_HORIZONTAL_BORDER;
				displayTextInput.width = 5 * BUTTON_WIDTH + 4 * BUTTON_SPACE;
				displayTextInput.height = BUTTON_HEIGHT;
			}
		}
		
		private function reset(withDisplay:Boolean):void
		{
			accuA = 0;
			accuB = 0;
			accuC = 0;
			accuD = 0;
			oper1 = OPER_NONE;
			oper2 = OPER_NONE;
			oper3 = OPER_NONE;
			isNumber = false;
			if (withDisplay)
			{
			    displayAccuA = RESET_DISPLAY;
			}
		}

		private function onButtonClick(event:MouseEvent):void
		{
			var tempButton:Button = (Button)(event.currentTarget);
			switch (tempButton)
			{
				case equalsButton:
					var result:Number = 0;
/*					if (isNumber == false)
					{
						accuA = accuB;
						accuB = 0;
						accuC = 0;
						accuD = 0;
						oper1 = OPER_NONE;
						oper2 = OPER_NONE;
						oper3 = OPER_NONE;
					}
					else
					{*/
						switch (oper1)
						{
							case OPER_POW:
								accuA = Math.pow(accuB, accuA);
								accuB = accuC; 
								accuC = accuD;
								accuD = 0;
								oper1 = oper2;
								oper2 = oper3;
								oper3 = OPER_NONE;
								break;
							case OPER_MUL:
								accuA = accuB * accuA;
								accuB = accuC;
								accuC = accuD;
								accuD = 0;
								oper1 = oper2;
								oper2 = oper3;
								oper3 = OPER_NONE;
								break;
							case OPER_DIV:
								accuA = accuB / accuA;
								accuB = accuC;
								accuC = accuD;
								accuD = 0;
								oper1 = oper2;
								oper2 = oper3;
								oper3 = OPER_NONE;
								break;
							case OPER_ADD:
								accuA = accuB + accuA;
								accuB = accuC;
								accuC = accuD;
								accuD = 0;
								oper1 = oper2;
								oper2 = oper3;
								oper3 = OPER_NONE;
								break;
							case OPER_SUB:
								accuA = accuB - accuA;
								accuB = accuC;
								accuC = accuD;
								accuD = 0;
								oper1 = oper2;
								oper2 = oper3;
								oper3 = OPER_NONE;
								break;
						}
						switch (oper1)
						{
							case OPER_POW:
								accuA = Math.pow(accuB, accuA);
								accuB = accuC;
								accuC = 0;
								oper1 = oper2;
								oper2 = OPER_NONE;
								break;
							case OPER_MUL:
								accuA = accuB * accuA;
								accuB = accuC;
								accuC = 0;
								oper1 = oper2;
								oper2 = OPER_NONE;
								break;
							case OPER_DIV:
								accuA = accuB / accuA;
								accuB = accuC;
								accuC = 0;
								oper1 = oper2;
								oper2 = OPER_NONE;
								break;
							case OPER_ADD:
								accuA = accuB + accuA;
								accuB = accuC;
								accuC = 0;
								oper1 = oper2;
								oper2 = OPER_NONE;
								break;
							case OPER_SUB:
								accuA = accuB - accuA;
								accuB = accuC;
								accuC = 0;
								oper1 = oper2;
								oper2 = OPER_NONE;
								break;
						}
						switch (oper1)
						{
							case OPER_POW:
								accuA = Math.pow(accuB, accuA);
								accuB = 0;
								oper1 = OPER_NONE;
								break;
							case OPER_MUL:
								accuA = accuB * accuA;
								accuB = 0;
								oper1 = OPER_NONE;
								break;
							case OPER_DIV:
								accuA = accuB / accuA;
								accuB = 0;
								oper1 = OPER_NONE;
								break;
							case OPER_ADD:
								accuA = accuB + accuA;
								accuB = 0;
								oper1 = OPER_NONE;
								break;
							case OPER_SUB:
								accuA = accuB - accuA;
								accuB = 0;
								oper1 = OPER_NONE;
								break;
						}
					//}
					displayAccuA = accuA.toString();
					isNumber = false;
					break;
				case addButton:
					switch (oper1)
					{
						case OPER_POW:
							accuA = Math.pow(accuB, accuA);
							accuB = accuC; 
							accuC = accuD;
							accuD = 0;
							oper1 = oper2;
							oper2 = oper3;
							oper3 = OPER_NONE;
							break;
						case OPER_MUL:
							accuA = accuB * accuA;
							accuB = accuC;
							accuC = accuD;
							accuD = 0;
							oper1 = oper2;
							oper2 = oper3;
							oper3 = OPER_NONE;
							break;
						case OPER_DIV:
							accuA = accuB / accuA;
							accuB = accuC;
							accuC = accuD;
							accuD = 0;
							oper1 = oper2;
							oper2 = oper3;
							oper3 = OPER_NONE;
							break;
						case OPER_ADD:
							accuA = accuB + accuA;
							accuB = accuC;
							accuC = accuD;
							accuD = 0;
							oper1 = oper2;
							oper2 = oper3;
							oper3 = OPER_NONE;
							break;
						case OPER_SUB:
							accuA = accuB - accuA;
							accuB = accuC;
							accuC = accuD;
							accuD = 0;
							oper1 = oper2;
							oper2 = oper3;
							oper3 = OPER_NONE;
							break;
					}
					switch (oper1)
					{
						case OPER_POW:
							accuA = Math.pow(accuB, accuA);
							accuB = accuC;
							accuC = 0;
							oper1 = oper2;
							oper2 = OPER_NONE;
							break;
						case OPER_MUL:
							accuA = accuB * accuA;
							accuB = accuC;
							accuC = 0;
							oper1 = oper2;
							oper2 = OPER_NONE;
							break;
						case OPER_DIV:
							accuA = accuB / accuA;
							accuB = accuC;
							accuC = 0;
							oper1 = oper2;
							oper2 = OPER_NONE;
							break;
						case OPER_ADD:
							accuA = accuB + accuA;
							accuB = accuC;
							accuC = 0;
							oper1 = oper2;
							oper2 = OPER_NONE;
							break;
						case OPER_SUB:
							accuA = accuB - accuA;
							accuB = accuC;
							accuC = 0;
							oper1 = oper2;
							oper2 = OPER_NONE;
							break;
					}
					switch (oper1)
					{
						case OPER_POW:
							accuA = Math.pow(accuB, accuA);
							accuB = 0;
							oper1 = OPER_NONE;
							break;
						case OPER_MUL:
							accuA = accuB * accuA;
							accuB = 0;
							oper1 = OPER_NONE;
							break;
						case OPER_DIV:
							accuA = accuB / accuA;
							accuB = 0;
							oper1 = OPER_NONE;
							break;
						case OPER_ADD:
							accuA = accuB + accuA;
							accuB = 0;
							oper1 = OPER_NONE;
							break;
						case OPER_SUB:
							accuA = accuB - accuA;
							accuB = 0;
							oper1 = OPER_NONE;
							break;
					}
					displayAccuA = accuA.toString();
					accuB = accuA;
					oper1 = OPER_ADD;
					isNumber = false;
					break;
				case subButton:
					switch (oper1)
					{
						case OPER_POW:
							accuA = Math.pow(accuB, accuA);
							accuB = accuC; 
							accuC = accuD;
							accuD = 0;
							oper1 = oper2;
							oper2 = oper3;
							oper3 = OPER_NONE;
							break;
						case OPER_MUL:
							accuA = accuB * accuA;
							accuB = accuC;
							accuC = accuD;
							accuD = 0;
							oper1 = oper2;
							oper2 = oper3;
							oper3 = OPER_NONE;
							break;
						case OPER_DIV:
							accuA = accuB / accuA;
							accuB = accuC;
							accuC = accuD;
							accuD = 0;
							oper1 = oper2;
							oper2 = oper3;
							oper3 = OPER_NONE;
							break;
						case OPER_ADD:
							accuA = accuB + accuA;
							accuB = accuC;
							accuC = accuD;
							accuD = 0;
							oper1 = oper2;
							oper2 = oper3;
							oper3 = OPER_NONE;
							break;
						case OPER_SUB:
							accuA = accuB - accuA;
							accuB = accuC;
							accuC = accuD;
							accuD = 0;
							oper1 = oper2;
							oper2 = oper3;
							oper3 = OPER_NONE;
							break;
					}
					switch (oper1)
					{
						case OPER_POW:
							accuA = Math.pow(accuB, accuA);
							accuB = accuC;
							accuC = 0;
							oper1 = oper2;
							oper2 = OPER_NONE;
							break;
						case OPER_MUL:
							accuA = accuB * accuA;
							accuB = accuC;
							accuC = 0;
							oper1 = oper2;
							oper2 = OPER_NONE;
							break;
						case OPER_DIV:
							accuA = accuB / accuA;
							accuB = accuC;
							accuC = 0;
							oper1 = oper2;
							oper2 = OPER_NONE;
							break;
						case OPER_ADD:
							accuA = accuB + accuA;
							accuB = accuC;
							accuC = 0;
							oper1 = oper2;
							oper2 = OPER_NONE;
							break;
						case OPER_SUB:
							accuA = accuB - accuA;
							accuB = accuC;
							accuC = 0;
							oper1 = oper2;
							oper2 = OPER_NONE;
							break;
					}
					switch (oper1)
					{
						case OPER_POW:
							accuA = Math.pow(accuB, accuA);
							accuB = 0;
							oper1 = OPER_NONE;
							break;
						case OPER_MUL:
							accuA = accuB * accuA;
							accuB = 0;
							oper1 = OPER_NONE;
							break;
						case OPER_DIV:
							accuA = accuB / accuA;
							accuB = 0;
							oper1 = OPER_NONE;
							break;
						case OPER_ADD:
							accuA = accuB + accuA;
							accuB = 0;
							oper1 = OPER_NONE;
							break;
						case OPER_SUB:
							accuA = accuB - accuA;
							accuB = 0;
							oper1 = OPER_NONE;
							break;
					}
					displayAccuA = accuA.toString();
					accuB = accuA;
					oper1 = OPER_SUB;
					isNumber = false;
					break;
				case mulButton:
					switch (oper1)
					{
						case OPER_NONE:
							accuB = accuA;
							break;
						case OPER_ADD:							
						case OPER_SUB:
							oper2 = oper1;
							accuC = accuB;
							accuB = accuA;
							break;
						case OPER_MUL:
							accuB = accuB * accuA;
							break;
						case OPER_DIV:
							accuB = accuB / accuA;
							break;
						case OPER_POW:
							accuB = Math.pow(accuB, accuA);
							break;
					}
					oper1 = OPER_MUL;
					accuA = 0;
					isNumber = false;
					displayAccuA = accuB.toString();
					break;
				case divButton:
					switch (oper1)
					{
						case OPER_NONE:
							accuB = accuA;
							break;
						case OPER_ADD:							
						case OPER_SUB:
							oper2 = oper1;
							accuC = accuB;
							accuB = accuA;
							break;
						case OPER_MUL:
							accuB = accuB * accuA;
							break;
						case OPER_DIV:
							accuB = accuB / accuA;
							break;
						case OPER_POW:
							accuB = Math.pow(accuB, accuA);
							break;
					}
					oper1 = OPER_DIV;
					accuA = 0;
					isNumber = false;
					displayAccuA = accuB.toString();
					break;
				case powButton:
					switch (oper2)
					{
						case OPER_NONE:
							break;
						case OPER_POW:
							break;
					}
					switch (oper1)
					{
						case OPER_NONE:
							accuB = accuA;
							break;
						case OPER_ADD:							
						case OPER_SUB:
							oper2 = oper1;
							accuC = accuB;
							accuB = accuA;
							break;
						case OPER_MUL:
							accuB = accuB * accuA;
							break;
						case OPER_DIV:
							accuB = accuB / accuA;
							break;
						case OPER_POW:
							accuB = Math.pow(accuB, accuA);
							break;
					}
					oper1 = OPER_POW;
					accuA = 0;
					isNumber = false;
					displayAccuA = accuB.toString();
					break;
				case xButton:
					stage.nativeWindow.close();
					break;
				case shiftButton:
					doShift();
					break;
				case qubButton:
					accuA = Math.pow(accuA, 3);
					displayAccuA = accuA.toString();
					isNumber = false;
					break;
				case drgButton:
					doDrg();
					break;
				case zeroButton:
					if (isNumber == false)
					{
						isNumber = true;
						displayAccuA = RESET_DISPLAY;
						accuA = 0;
					}
					else
					{
						if (accuA == 0 && displayAccuA.length < 2)
						{
						}
						else
						{
							if (displayAccuA.length >= MAX_DIGITS)
							{
								break;
							}
							displayAccuA = displayAccuA + "0";
							accuA = new Number(displayAccuA);
						}
					}
					break;
				case oneButton:
					if (isNumber == false)
					{
						isNumber = true;
						displayAccuA = "1";
						accuA = 1;
					}
					else
					{
						if (accuA == 0 && displayAccuA.length < 2)
						{
						}
						else
						{
							if (displayAccuA.length >= MAX_DIGITS)
							{
								break;
							}
							displayAccuA = displayAccuA + "1";
							accuA = new Number(displayAccuA);
						}
					}
					break;
				case twoButton:
					if (isNumber == false)
					{
						isNumber = true;
						displayAccuA = "2";
						accuA = 2;
					}
					else
					{
						if (accuA == 0 && displayAccuA.length < 2)
						{
						}
						else
						{
							if (displayAccuA.length >= MAX_DIGITS)
							{
								break;
							}
							displayAccuA = displayAccuA + "2";
							accuA = new Number(displayAccuA);
						}
					}
					break;
				case threeButton:
					if (isNumber == false)
					{
						isNumber = true;
						displayAccuA = "3";
						accuA = 3;
					}
					else
					{
						if (accuA == 0 && displayAccuA.length < 2)
						{
						}
						else
						{
							if (displayAccuA.length >= MAX_DIGITS)
							{
								break;
							}
							displayAccuA = displayAccuA + "3";
							accuA = new Number(displayAccuA);
						}
					}
					break;
				case fourButton:
					if (isNumber == false)
					{
						isNumber = true;
						displayAccuA = "4";
						accuA = 4;
					}
					else
					{
						if (accuA == 0 && displayAccuA.length < 2)
						{
						}
						else
						{
							if (displayAccuA.length >= MAX_DIGITS)
							{
								break;
							}
							displayAccuA = displayAccuA + "4";
							accuA = new Number(displayAccuA);
						}
					}
					break;
				case fiveButton:
					if (isNumber == false)
					{
						isNumber = true;
						displayAccuA = "5";
						accuA = 5;
					}
					else
					{
						if (accuA == 0 && displayAccuA.length < 2)
						{
						}
						else
						{
							if (displayAccuA.length >= MAX_DIGITS)
							{
								break;
							}
							displayAccuA = displayAccuA + "5";
							accuA = new Number(displayAccuA);
						}
					}
					break;
				case sixButton:
					if (isNumber == false)
					{
						isNumber = true;
						displayAccuA = "6";
						accuA = 6;
					}
					else
					{
						if (accuA == 0 && displayAccuA.length < 2)
						{
						}
						else
						{
							if (displayAccuA.length >= MAX_DIGITS)
							{
								break;
							}
							displayAccuA = displayAccuA + "6";
							accuA = new Number(displayAccuA);
						}
					}
					break;
				case sevenButton:
					if (isNumber == false)
					{
						isNumber = true;
						displayAccuA = "7";
						accuA = 7;
					}
					else
					{
						if (accuA == 0 && displayAccuA.length < 2)
						{
						}
						else
						{
							if (displayAccuA.length >= MAX_DIGITS)
							{
								break;
							}
							displayAccuA = displayAccuA + "7";
							accuA = new Number(displayAccuA);
						}
					}
					break;
				case eightButton:
					if (isNumber == false)
					{
						isNumber = true;
						displayAccuA = "8";
						accuA = 8;
					}
					else
					{
						if (accuA == 0 && displayAccuA.length < 2)
						{
						}
						else
						{
							if (displayAccuA.length >= MAX_DIGITS)
							{
								break;
							}
							displayAccuA = displayAccuA + "8";
							accuA = new Number(displayAccuA);
						}
					}
					break;
				case nineButton:
					if (isNumber == false)
					{
						isNumber = true;
						displayAccuA = "9";
						accuA = 9;
					}
					else
					{
						if (accuA == 0 && displayAccuA.length < 2)
						{
						}
						else
						{
							if (displayAccuA.length >= MAX_DIGITS)
							{
								break;
							}
							displayAccuA = displayAccuA + "9";
							accuA = new Number(displayAccuA);
						}
					}
					break;
				case dotButton:
					if (isNumber == false)
					{
						isNumber = true;
						displayAccuA = "0.";
						accuA = 0;
					}
					else
					{
						if (accuA == 0)
						{
							if (displayAccuA == "0.")
							{
								break;
							}
							else
							{
								displayAccuA = "0.";
								accuA = 0;
							}
						}
						else
						{
							if (displayAccuA.length >= MAX_DIGITS)
							{
								break;
							}
							if (displayAccuA.indexOf(".") > -1)
							{
								break;
							}
							else
							{
								displayAccuA = displayAccuA + ".";
								accuA = new Number(displayAccuA);
							}
						}
					}
					break;
				case delButton:
					isNumber = false;
					accuA = 0;
					displayAccuA = RESET_DISPLAY;
					break;
				case clrButton:
					reset(true);
					break;
				case negativeButton:
					if (isNumber == false)
					{
						break;
					}
					if (accuA == 0)
					{
						break;
					}
					var temp:Number = new Number(displayAccuA);
					temp = temp * -1;
					accuA = temp;
					displayAccuA = temp.toString();
					break;
				case mrButton:
					accuA = mem;
					displayAccuA = mem.toString();
					isNumber = false;
					break;
				case msButton:
					mem = accuA;
					break;
				case mcButton:
					mem = 0;
					break;
				case logButton:
					accuA = Math.log(accuA) / Math.log(10);
					displayAccuA = accuA.toString();
					isNumber = false;
					break;
				case sqrtButton:
					accuA = Math.sqrt(accuA);
					displayAccuA = accuA.toString();
					isNumber = false;
					break;
				case factorButton:
					if (accuA < 1)
					{
						accuA = 0;
						displayAccuA = RESET_DISPLAY;
						isNumber = false;
					}
					else
					{
						var resultx:Number = 1;
					    for (var i:int = 1; i <= accuA; i++)
						{
							resultx = resultx * i;
						}
						accuA = resultx;
						displayAccuA = accuA.toString();
						isNumber = false;
					}
					break;
				case piButton:
					accuA = Math.PI;
					displayAccuA = accuA.toString();
					isNumber = false;
					break;
				case pow10Button:
					accuA = Math.pow(10, accuA);
					displayAccuA = accuA.toString();
					isNumber = false;
					break;
				case sinButton:
					if (hypLevel)
					{
						if (shiftLevel)
						{
							accuA = Math.log(accuA + Math.sqrt(Math.pow(accuA, 2) + 1));
							switch (drgLevel)
							{
								case DEG:
									accuA = accuA * 180 / Math.PI;
									break;
								case GRAD:
									accuA = accuA * 200 / Math.PI;
									break;
							}
							if (accuA < 1E-12 && accuA > -1E-12)
							{
								accuA = 0;
							}
							displayAccuA = accuA.toString();
							isNumber = false;
						}
						else
						{
							switch (drgLevel)
							{
								case DEG:
									accuA = accuA * Math.PI / 180;
									break;
								case GRAD:
									accuA = accuA * Math.PI / 200;
									break;
							}
							accuA = 0.5 * (Math.exp(accuA) - Math.exp(-1 * accuA));
							if (accuA < 1E-12 && accuA > -1E-12)
							{
								accuA = 0;
							}
							displayAccuA = accuA.toString();
							isNumber = false;
						}
					}
					else
					{
						if (shiftLevel)
						{
							accuA = Math.asin(accuA);
							switch (drgLevel)
							{
								case DEG:
									accuA = accuA * 180 / Math.PI;
									break;
								case GRAD:
									accuA = accuA * 200 / Math.PI;
									break;
							}
							if (accuA < 1E-12 && accuA > -1E-12)
							{
								accuA = 0;
							}
							displayAccuA = accuA.toString();
							isNumber = false;
						}
						else
						{
							switch (drgLevel)
							{
								case DEG:
									accuA = accuA * Math.PI / 180;
									break;
								case GRAD:
									accuA = accuA * Math.PI / 200;
									break;
							}
							accuA = Math.sin(accuA);
							if (accuA < 1E-12 && accuA > -1E-12)
							{
								accuA = 0;
							}
							displayAccuA = accuA.toString();
							isNumber = false;
						}
					}
					break;
				case cosButton:
					if (hypLevel)
					{
						if (shiftLevel)
						{
							if (accuA < 1)
							{
								isNumber = false;
								accuA = Number.NaN;
								displayAccuA = NAN;
								isNumber = false;
							}
							else
							{
								accuA = Math.log(accuA + Math.sqrt(Math.pow(accuA, 2) - 1));
								switch (drgLevel)
								{
									case DEG:
										accuA = accuA * 180 / Math.PI;
										break;
									case GRAD:
										accuA = accuA * 200 / Math.PI;
										break;
								}
								if (accuA < 1E-12 && accuA > -1E-12)
								{
									accuA = 0;
								}
								displayAccuA = accuA.toString();
								isNumber = false;
							}
						}
						else
						{
							switch (drgLevel)
							{
								case DEG:
									accuA = accuA * Math.PI / 180;
									break;
								case GRAD:
									accuA = accuA * Math.PI / 200;
									break;
							}
							accuA = 0.5 * (Math.exp(accuA) + Math.exp(-1 * accuA));
							if (accuA < 1E-12 && accuA > -1E-12)
							{
								accuA = 0;
							}
							displayAccuA = accuA.toString();
							isNumber = false;
						}
					}
					else
					{
						if (shiftLevel)
						{
							accuA = Math.acos(accuA);
							switch (drgLevel)
							{
								case DEG:
									accuA = accuA * 180 / Math.PI;
									break;
								case GRAD:
									accuA = accuA * 200 / Math.PI;
									break;
							}
							if (accuA < 1E-12 && accuA > -1E-12)
							{
								accuA = 0;
							}
							displayAccuA = accuA.toString();
							isNumber = false;
						}
						else
						{
							switch (drgLevel)
							{
								case DEG:
									accuA = accuA * Math.PI / 180;
									break;
								case GRAD:
									accuA = accuA * Math.PI / 200;
									break;
							}
							accuA = Math.cos(accuA);
							if (accuA < 1E-12 && accuA > -1E-12)
							{
								accuA = 0;
							}
							displayAccuA = accuA.toString();
							isNumber = false;
						}
					}
					break;
				case tanButton:
					if (hypLevel)
					{
						if (shiftLevel)
						{
							if (accuA >= 1 || accuA <= -1)
							{
								isNumber = false;
								displayAccuA = NAN;
								isNumber = false;
							}
							else
							{
								accuA = 0.5 * Math.log((1 + accuA) / (1 - accuA));
								switch (drgLevel)
								{
									case DEG:
										accuA = accuA * 180 / Math.PI;
										break;
									case GRAD:
										accuA = accuA * 200 / Math.PI;
										break;
								}
								if (accuA < 1E-12 && accuA > -1E-12)
								{
									accuA = 0;
								}
								displayAccuA = accuA.toString();
								isNumber = false;
							}
						}
						else
						{
							switch (drgLevel)
							{
								case DEG:
									accuA = accuA * Math.PI / 180;
									break;
								case GRAD:
									accuA = accuA * Math.PI / 200;
									break;
							}
							accuA = (0.5 * (Math.exp(accuA)- Math.exp(-1 * accuA))) / 
								(0.5 * (Math.exp(accuA) + Math.exp(-1 * accuA)));
							if (accuA < 1E-12 && accuA > -1E-12)
							{
								accuA = 0;
							}
							displayAccuA = accuA.toString();
							isNumber = false;
						}
					}
					else
					{
						if (shiftLevel)
						{
							accuA = Math.atan(accuA);
							switch (drgLevel)
							{
								case DEG:
									accuA = accuA * 180 / Math.PI;
									break;
								case GRAD:
									accuA = accuA * 200 / Math.PI;
									break;
							}
							if (accuA < 1E-12 && accuA > -1E-12)
							{
								accuA = 0;
							}
							displayAccuA = accuA.toString();
							isNumber = false;
						}
						else
						{
							switch (drgLevel)
							{
								case DEG:
									accuA = accuA * Math.PI / 180;
									break;
								case GRAD:
									accuA = accuA * Math.PI / 200;
									break;
							}
							accuA = Math.tan(accuA);
							if (accuA < 1E-12 && accuA > -1E-12)
							{
								accuA = 0;
							}
							displayAccuA = accuA.toString();
							isNumber = false;
						}
					}
					break;
				case squareButton:
					accuA = Math.pow(accuA, 2);
					displayAccuA = accuA.toString();
					isNumber = false;
					break;
				case inverseButton:
					accuA = Math.pow(accuA, -1);
					displayAccuA = accuA.toString();
					isNumber = false;
					break;
				case expButton:
					accuA = Math.exp(accuA);
					displayAccuA = accuA.toString();
					isNumber = false;
					break;
				case lnButton:
					accuA = Math.log(accuA);
					displayAccuA = accuA.toString();
					isNumber = false;
					break;
				case helpButton:
					var helpDialog:AlertDialog = new AlertDialog();
					helpDialog.title = "Help";
					helpDialog.message = HELP;
					helpDialog.addButton("Close");
					helpDialog.dialogSize = DialogSize.SIZE_LARGE;
					helpDialog.addEventListener(Event.SELECT, onDialogClose);
					helpDialog.show(IowWindow.getAirWindow().group);
					break;
					
			}

/*			if (accuA == Number.NaN)
			{
				displayAccuA = NAN;
				isNumber = false;
			}*/
			if (displayAccuA.length > MAX_DIGITS)
			{
				accuA = Number.NaN;
				displayAccuA = NAN;
				isNumber = false;
			}
			if (displayAccuA == "NaN")
			{
				accuA = Number.NaN;
				displayAccuA = NAN;
				isNumber = false;
			}
			if (accuA == Number.NEGATIVE_INFINITY)
			{
				displayAccuA = NAN;
				isNumber = false;
			}
			if (accuA == Number.POSITIVE_INFINITY)
			{
				displayAccuA = NAN;
				isNumber = false;
			}
			
			displayTextInput.text = displayAccuA;
//			debugLabel.text = accuA + " " + getOperator(oper1) + " " + accuB + " " + getOperator(oper2) + " " +
//				accuC + " " + getOperator(oper3) + " " + accuD + " [" + mem + "] " + isNumber; 
		}
		
		private function getOperator(oper:int):String
		{
		   switch (oper)
		   {
			   case OPER_ADD:
				   return "+";
			   case OPER_MUL:
				   return "*";
			   case OPER_DIV:
				   return "/";
			   case OPER_SUB:
				   return "-";
			   case OPER_POW:
				   return "^";
			   default:
				   return "NONE";
		   }
		}
		
		private function onDialogClose(event:Event):void
		{
			
		}
		
		public static const EULA:String =
		   "SCI CALC FOR BLACKBERRY® PLAYBOOK™ - END USER AGREEMENT AND LICENSE\n\n" +
		   "You may use this software product only on the condition that you agree to abide by the following terms.\n\n" +
		   "BY INSTALLING OR USING THIS SOFTWARE, YOU ARE AGREEING ELECTRONICALLY TO THE TERMS OF THIS SOFTWARE END USER AGREEMENT (THE 'AGREEMENT' or 'LICENSE'). If you do not agree to the terms of this License, do not install, copy or use the Software. Also, you agree that any claim or dispute that you may have regarding this Agreement or the Software resides in the Courts of the Republic of Slovenia.\n\n" +
		   "1.  SOFTWARE.  This Agreement and the supplemental terms below apply to the software product and any updates for SCI CALC FOR BLACKBERRY® PLAYBOOK™ (hereinafter referred to as the 'Software').  In this Agreement, the term 'you' or 'your' means you as an individual or such entity in whose behalf you act, if any.\n\n" +
		   "2.  OWNERSHIP.  This is a license of the Software and not a sale. The Software is protected by copyright and other intellectual property laws and by international treaties. The Author of the Software and suppliers own all rights in the Software. Your rights to use the Software are specified in this Agreement and we retain and reserve all rights not expressly granted to you.\n\n" +
		   "3.  LICENSE.  Provided that you comply with the terms of this Agreement, we grant you a personal, limited, non-exclusive and non-transferable license to install and use the Software on a single, authorized BlackBerry® PlayBook™ device for personal and internal business purposes. This license does not entitle you to receive from us hard-copy documentation, support, telephone assistance, or enhancements or updates to the Software.\n\n" +
		   "4.  RESTRICTIONS.  You may not: (i) make any copies of the Software other than an archival copy, (ii) modify or create any derivative works of the Software or documentation; (iii) decompile, disassemble, reverse engineer, or otherwise attempt to derive the source code, underlying ideas, or algorithms of the Software, or in any way ascertain, decipher, or obtain the communications protocols for accessing our networks; (iv) copy, reproduce, reuse in another product or service, modify, alter, or display in any manner any files, or parts thereof, included in the Software;\n\n" +
		   "The Software is offered in the United States. You understand and agree that (a) the Software is not designed or customized for distribution for any specific country or jurisdiction ('Territory') and (b) the Software is not intended for distribution to, or use by, any person or entity in any Territory where such distribution or use would be contrary to local law or regulation. You are solely responsible for compliance with local laws as applicable when you use the Software.\n\n" +
		   "5. CONTENT.  Content, information ('Content') that may be accessed through the use of the Software is the property of its respective owner. You may only use such Content for personal, noncommercial purposes and subject to the terms and conditions that accompany such Content. We make no representations or warranties regarding the accuracy or reliability of the information included in such Content.\n\n" +
		   "6. CONTENT DISCLAIMER. All of the content and information within LUX CONVERT, (the 'Content') is provided 'AS IS' and for your convenience only.  RIM, ITS AFFILIATES, ITS INFORMATION PROVIDERS, AIRTIME SERVICE PROVIDERS/TELECOMMUNICATIONS CARRIERS, AND ANY MoR MAKING THE SOFTWARE AVAILABLE THROUGH ITS KIOSK MAKE NO EXPRESS OR IMPLIED WARRANTIES (INCLUDING, WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABLILITY, ACCURACY OR FITNESS FOR A PARTICULAR PURPOSE OR USE) REGARDING ANY CONTENT.\n\n" +
		   "RIM, any telecommunications carriers, its information providers, and any MoR shall not be liable for any decisions you make based upon use of the Content. In addition, RIM, including its affiliates and information or content providers, any telecommunications carriers, and any MoR, will not be liable to anyone for any interruption, inaccuracy, error or omission, regardless of cause, or for any resulting damages (whether direct or indirect, consequential, punitive or exemplary).\n\n" +
		   "7.  DISCLAIMER OF WARRANTY.\n\n" +
		   "WE LICENSE THE SOFTWARE 'AS IS' AND WITH ALL FAULTS. WE DO NOT WARRANT THAT THIS SOFTWARE WILL MEET YOUR REQUIREMENTS OR THAT ITS OPERATION WILL BE UNINTERRUPTED OR ERROR-FREE. THE ENTIRE RISK AS TO SATISFACTORY QUALITY, PERFORMANCE, ACCURACY, EFFORT AND COST OF ANY SERVICE AND REPAIR IS WITH YOU.\n\n" +
		   "WE, OUR SUPPLIERS AND DISTRIBUTORS DISCLAIM ALL EXPRESS WARRANTIES AND ALL IMPLIED WARRANTIES, INCLUDING ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, NON-INTERFERENCE, NON-INFRINGEMENT OR ACCURACY, UNLESS SUCH IMPLIED WARRANTIES ARE LEGALLY INCAPABLE OF EXCLUSION.\n\n" +
		   "NO ORAL OR WRITTEN INFORMATION OR ADVICE GIVEN BY US SHALL CREATE A WARRANTY OR IN ANY WAY INCREASE THE SCOPE OF ANY WARRANTY THAT CANNOT BE DISCLAIMED UNDER APPLICABLE LAW. WE, OUR SUPPLIERS AND DISTRIBUTORS HAVE NO LIABILITY WITH RESPECT TO YOUR USE OF THE SOFTWARE.\n\n" +
		   "IF ANY IMPLIED WARRANTY MAY NOT BE DISCLAIMED UNDER APPLICABLE LAW, THEN SUCH IMPLIED WARRANTY IS LIMITED TO 30 DAYS FROM THE DATE YOU ACQUIRED THE SOFTWARE FROM US OR OUR AUTHORIZED DISTRIBUTOR.\n\n" +
		   "8.  LIMITATION OF LIABILITY.\n\n" +
		   "TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, IN NO EVENT WILL WE, OUR DISTRIBUTORS, CHANNEL PARTNERS, AND ASSOCIATED SERVICE PROVIDERS, BE LIABLE FOR ANY INDIRECT, SPECIAL, INCIDENTAL, CONSEQUENTIAL, OR EXEMPLARY DAMAGES ARISING OUT OF OR IN ANY WAY RELATING TO THIS AGREEMENT OR THE USE OF OR INABILITY TO USE THE SOFTWARE, INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF GOODWILL, WORK STOPPAGE, LOST PROFITS, LOSS OF DATA, COMPUTER OR DEVICE FAILURE OR MALFUNCTION, OR ANY AND ALL OTHER COMMERCIAL DAMAGES OR LOSSES, EVEN IF ADVISED OF THE POSSIBILITY THEREOF, AND REGARDLESS OF THE LEGAL OR EQUITABLE THEORY (CONTRACT, TORT OR OTHERWISE) UPON WHICH THE CLAIM IS BASED.\n\n" +
		   "9.  NO SUPPORT OR UPGRADE OBLIGATIONS.  We, our suppliers and distributors are not obligated to create or provide any support, corrections, updates, upgrades, bug fixes and/or enhancements of the Software.\n\n" +
		   "10.  IMPORT/EXPORT CONTROL.  The Software is subject to export and import laws, regulations, rules and orders of the United States and foreign nations. You must comply with these laws that apply to the Software. You may not directly or indirectly export, re-export, transfer, or release the Software, any other commodities, software or technology received from us, or any direct product thereof, for any proscribed end-use, or to any proscribed country, entity or person (wherever located), without proper authorization from the U.S. and/or foreign government.\n\n" +
		   "11.  U.S. GOVERNMENT END-USERS.  The Software is a 'commercial item,' as that term is defined in 48 C.F.R. 2.101, consisting of 'commercial computer software' and 'commercial computer software documentation,' as such terms are used in 48 C.F.R. 12.212 (Sept. 1995) and 48 C.F.R. 227.7202 (June 1995). Consistent with 48 C.F.R. 12.212, 48 C.F.R. 27.405(b) (2) (June 1998) and 48 C.F.R. 227.7202, all U.S. Government End Users acquire the Software with only those rights as described in this License.\n\n" +
		   "12.  ELECTRONIC NOTICES.  YOU AGREE TO THIS LICENSE ELECTRONICALLY. YOU AUTHORIZE US TO PROVIDE YOU ANY INFORMATION AND NOTICES REGARDING THE SOFTWARE ('NOTICES') IN ELECTRONIC FORM. WE MAY PROVIDE NOTICES TO YOU (1) VIA E-MAIL IF YOU HAVE PROVIDED US WITH A VALID EMAIL ADDRESS OR (2) BY POSTING THE NOTICE ON A WEB OR MOBILE PAGE DESIGNATED BY US FOR THIS PURPOSE. The delivery of any Notice is effective when sent or posted by us, regardless of whether you read the Notice or actually receive the delivery. You can withdraw your consent to receive Notices electronically by discontinuing your use of the Software.\n\n" +
		   "13.  INDEMNIFICATION.  Upon a request by us, you agree to defend, indemnify, and hold harmless us and other affiliated companies, and our respective employees, contractors, officers, directors, suppliers and agents and distributors from all liabilities, claims, and expenses, including attorney's fees that arise from your use or misuse of the Software. We reserve the right, at our own expense, to assume the exclusive defense and control of any matter otherwise subject to indemnification by you, in which event you will cooperate with us in asserting any available defenses.\n\n" +
		   "14. CHOICE OF LAW AND LOCATION FOR RESOLVING DISPUTES. YOU EXPRESSLY AGREE THAT EXCLUSIVE JURISDICTION FOR ANY CLAIM OR DISPUTE RELATING IN ANY WAY TO YOUR USE OF THE SOFTWARE RESIDES IN THE FEDERAL OR STATE COURTS LOCATED IN THE COMMONWEALTH OF CALIFORNIA AND YOU FURTHER AGREE AND EXPRESSLY CONSENT TO THE EXERCISE OF PERSONAL JURISDICTION IN SUCH COURTS IN CONNECTION WITH ANY SUCH DISPUTE INCLUDING ANY CLAIM INVOLVING the software. PLEASE NOTE THAT BY AGREEING TO THESE TERMS OF USE, YOU ARE WAIVING CLAIMS THAT YOU MIGHT OTHERWISE HAVE AGAINST US BASED ON THE LAWS OF OTHER JURISDICTIONS, INCLUDING YOUR OWN.\n\n" +
		   "15.  ENTIRE AGREEMENT.  This Agreement and any supplemental terms constitute the entire agreement between you and us concerning the subject matter of this Agreement, which may only be modified by us.\n\n" +
		   "16.  GENERAL TERMS.  (a) This Agreement shall not be governed by the United Nations Convention on Contracts for the International Sale of Goods. (b) If any part of this Agreement is held invalid or unenforceable, that part shall be construed to reflect the parties' original intent, and the remaining portions remain in full force and effect, or we may at our option terminate this Agreement. (c) The controlling language of this Agreement is English. If you have received a translation into another language, it has been provided for your convenience only. (d) A waiver by either party of any term or condition of this Agreement or any breach thereof, in any one instance, shall not waive such term or condition or any subsequent breach thereof. (e) You may not assign or otherwise transfer by operation of law or otherwise this Agreement or any rights or obligations herein. We may assign this Agreement to any entity at its sole discretion and without notice to you. (f) This Agreement shall be binding upon and shall inure to the benefit of the parties, their successors and permitted assigns. (g) Neither party shall be in default or be liable for any delay, failure in performance or interruption of service resulting directly or indirectly from any cause beyond its reasonable control.\n\n" +
		   "17.  USER OUTSIDE THE U.S.  If you are using the Software outside the U.S., then the provisions of this Section shall apply: (i) Les parties aux prA©sentA©s confirment leur volontA© que cette convention de mAame que tous les documents y compris tout avis qui s'y rattachA©, soient redigA©s en langue anglaise. (translation: 'The parties confirm that this Agreement and all related documentation is and will be in the English language.'); (ii) you are responsible for complying with any local laws in your jurisdiction which might impact your right to import, export or use the Software, and you represent that you have complied with any regulations or registration procedures required by applicable law to make this license enforceable; and (iii) if the laws applicable to your use of the Software would prohibit the enforceability of this Agreement, or confer any rights to you that are materially different from the terms and conditions of this Agreement, then you are not authorized to use the Software and you agree to remove it from your device.\n\n" +
		   "Supplemental Terms for BLACKBERRY®, airtime service providers, and MoRs.\n\n" +
		   "These terms supplement and are in addition to the terms of the Agreement for users who install the Software on hardware products provided by Research In Motion, Limited ('RIM'), airtime service providers, and any MoRs.\n\n" +
		   "a. You understand and agree that RIM, airtime service providers, and any MoRs have no obligation whatsoever to furnish any maintenance and support services regarding the Software.\n\n" +
		   "b. RIM, airtime service providers, and any MoRs shall not be responsible for any claims by you or any third relating to your possession and/or use of the Software, including but not limited to (i) product liability claims, (ii) any claim that the Software fails to conform to any applicable legal or regulatory requirement, (iii) claims arising under consumer protection laws or similar legislation, and (iv) claims by any third party that the Software or your possession and use of the Software infringes the intellectual property rights of the third party.\n\n" +
		   "c. You agree that RIM, RIM's subsidiaries, airtime service providers, and any MoRs are third party beneficiaries of this Agreement, and that upon your acceptance of the terms and conditions of this License, RIM will have the right (and will be deemed to have accepted the right) to enforce this Agreement against you as a third party beneficiary thereof.";
	}
}