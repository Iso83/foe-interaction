#SingleInstance, Force

; info https://autohotkey.com/board/topic/52826-call-one-script-from-another/

;________________ Tools ________________ 

InputBox(Title, Prompt, o := "") 
{ 
	; example: MsgBox, % InputBox("Test", "Tester", {Input:"Hide", Width:300, Height:150, x:0, y:0, Default:"Type here"})

	InputBox, Out, % Title, % Prompt, % o["Input"], % o["Width"], % o["Height"], % o["X"], % o["Y"], , % o["Timeout"], % o["Default"]
	Return Out
}

DisplayColor(location:="", markMouse:=false)
{
	if(location=="")
		MouseGetPos, X1, Y1
	Else
	{
		X1 := location.X
		Y1 := location.Y
	}
	PixelGetColor, color, %X1%, %Y1%

	if(markMouse)
		MouseMove, X1, Y1

	MsgBox The color at the current cursor position is %color%.

	return
}

TryMouseColor(bnt_rect) ; Test current pixel in rectangle
{
	MouseGetPos, MouseX, MouseY
	PixelGetColor, color, %MouseX%, %MouseY%

	PixelSearch, PixelX, PixelY, bnt_rect.X, bnt_rect.Y, bnt_rect.Right, bnt_rect.Bottom, color

	If (ErrorLevel = 0) 
		MsgBox Found a valid color %color%.
	Else
	{
		SplashTextOn,,, Color %color% is not valid.
		Sleep 1500
		SplashTextOff
	}
}

DisplayMouseLocation()
{
	MouseGetPos, X1, Y1
	MsgBox cursor position is %X1%, %Y1%.

	return
}

SplashText(text, delay:=1500)
{
	SplashTextOn,,, %text%
	Sleep delay
	SplashTextOff
}

Test_Bnt(checkID)
{
	WinGetPos, X, Y, WinW, WinH, A
	rect_Bnt := Rect_Bnt_History(X, Y, WinW, WinH)
	offset_Bnt := { xOffset:10, yOffset:10 } ;Offset_Click()
	color_Bnt := FoE_cYellow_Sel

	if(color_Bnt == "")
	{
		MsgBox, invalid color.
		return
	}

	switch checkID
	{
	case 1:
		MouseMove, rect_Bnt.X, rect_Bnt.Y
	case 2:
		MouseMove, rect_Bnt.Right, rect_Bnt.Bottom
	case 3:
		MouseMove, rect_Bnt.Right-offset_Bnt.xOffset, rect_Bnt.Bottom-offset_Bnt.yOffset
	case 4:
		{
			if(ClickFind_Bnt(rect_Bnt, color_Bnt, offset_Bnt))
				SplashTextOn,,, Found button and clicked it.
			Else
				SplashTextOn,,, Color %color_Bnt% has not be found.

			Sleep 1500
			SplashTextOff
		}

	case 5:
		TryMouseColor(rect_Bnt)
	}
}

IsPixel(X, Y, color)
{
	PixelSearch, PixelX, PixelY, X, Y, X+1, Y+1, color, 0

	return ErrorLevel == 0
}

;________________ Foe tools ________________ 

global FoE_cRed := 0x192479

global FoE_cYellow := 0x1C498C
global FoE_cYellow2 := 0x001571 ;big yellow button
global FoE_cYellow3 := 0x064996 ;big yellow button gbg
global FoE_cYellow_Sel := 0x216FAD
global FoE_cYellow3_Sel := 0x2D6AC4

global FoE_cGreen := 0x1D7F53
global FoE_cGreen_Sel := 0x219661

global FoE_cBlue := 0x6F5544
global FoE_cBlue2 := 0x6A5248

Chrome_OpenFoE(worldID)
{
	url:="https://nl" worldID ".forgeofempires.com/game/index?"

	IF !WinActive("ahk_exe Chrome.exe")
		Run, Chrome.exe %url%
	Else
	{ ;open the website in the current tab
		SetKeyDelay, 200
		Send, ^l^a
		SendInput, %url%
		Send, {Return}
	}
	return
}

Offset_Click()
{
	return { xOffset:100, yOffset:11 }
}

Click_Bnt(rect, oClick:="", delay:=1000)
{
	if(oClick == "")
		oClick := Offset_Click()

	MouseClick, Left, rect.Right-oClick.xOffset, rect.Bottom-oClick.yOffset, 1, 5
	sleep, delay
}

Find_Rect(rect, color, variation:=0, mode:="Fast")
{
	PixelSearch, PixelX, PixelY, rect.X, rect.Y, rect.Right, rect.Bottom, color, variation, %mode%

	return ErrorLevel=0
}

ClickFind_Bnt(rect, color, oClick:="", delay:=1000, variation:=0, mode:="Fast", onFirstFind:=false)
{
	PixelSearch, PixelX, PixelY, rect.X, rect.Y, rect.Right, rect.Bottom, color, variation, %mode%

	If (ErrorLevel = 0) 
	{
		if(oClick == "")
			oClick := Offset_Click()

		if(onFirstFind)
			MouseClick, Left, PixelX+oClick.xOffset, PixelY+oClick.yOffset, 1, 5
		else
			MouseClick, Left, rect.Right-oClick.xOffset, rect.Bottom-oClick.yOffset, 1, 5

		sleep, delay

		return true
	}

	return false
}

Click_Speed(rect, mouseSpeed:=5, oClick:="", delay:=1000)
{
	if(oClick == "")
		oClick := Offset_Click()

	MouseClick, Left, rect.Right-oClick.xOffset, rect.Bottom-oClick.yOffset, 1, mouseSpeed

	sleep, delay
}

ClickFind_Speed_Bnt(rect, color, mouseSpeed:=5, oClick:="", delay:=1000, variation:=0, mode:="Fast", onFirstFind:=false)
{
	PixelSearch, PixelX, PixelY, rect.X, rect.Y, rect.Right, rect.Bottom, color, variation, %mode%

	If (ErrorLevel = 0) 
	{
		if(oClick == "")
			oClick := Offset_Click()

		if(onFirstFind)
			MouseClick, Left, PixelX+oClick.xOffset, PixelY+oClick.yOffset, 1, mouseSpeed
		else
			MouseClick, Left, rect.Right-oClick.xOffset, rect.Bottom-oClick.yOffset, 1, mouseSpeed

		sleep, delay

		return true
	}

	return false
}

Click_MO(x, y, winW, winH, listID, delay:=500)
{
	/*
		1: 	Neighbourhood
		2:	Guild
		3:	Friends
		4:	List_Start
		5:	List_Next
		6:	Help_1
		7:	Help_2
		8:	Help_3
		9:	Help_4
		10:	Help_5
		11:	Visit_1
		12:	Visit_2
		13:	Visit_3
		14:	Visit_4
		15:	Visit_5
		16: List_Show (docked button)
	*/

	offsetHelp:={ xOffset:20, yOffset:8 }
	offsetTav:={ xOffset:1, yOffset:1 }
	offsetSquareRect:={ xOffset:10, yOffset:10 }

	colorTav:=0x5D8494
	colorBlueSquareRect:=0x5A4339

	switch listID
	{
	case 1:
		X1:=750
		Y1:=winH-150
	case 2:
		X1:=815
		Y1:=winH-150
	case 3:
		X1:=907
		Y1:=winH-150
	case 4:
		X1:=252
		Y1:=winH-41
	case 5:
		X1:=963
		Y1:=winH-75

	case 6:
	return ClickFind_Bnt({ X:270, Y:winH-30, Right:370, Bottom:winH-12 }, FoE_cYellow, offsetHelp, delay)
	case 7:
	return ClickFind_Bnt({ X:(270+114), Y:winH-30, Right:477, Bottom:winH-12 }, FoE_cYellow, offsetHelp, delay)
	case 8:
	return ClickFind_Bnt({ X:(270+114*2), Y:winH-30, Right:584, Bottom:winH-12 }, FoE_cYellow, offsetHelp, delay)
	case 9:
	return ClickFind_Bnt({ X:(270+114*3), Y:winH-30, Right:691, Bottom:winH-12 }, FoE_cYellow, offsetHelp, delay)
	case 10:
	return ClickFind_Bnt({ X:(270+114*4), Y:winH-30, Right:798, Bottom:winH-12 }, FoE_cYellow, offsetHelp, delay)

	case 11:
	return ClickFind_Bnt({ X:364, Y:winH-50, Right:365, Bottom:winH-51 }, colorTav, offsetTav, delay, 3, "")
	case 12:
	return ClickFind_Bnt({ X:(364+114), Y:winH-50, Right:(364+114)+1, Bottom:winH-51 }, colorTav, offsetTav, delay, 3, "")
	case 13:
	return ClickFind_Bnt({ X:(364+114*2), Y:winH-50, Right:(364+114*2)+1, Bottom:winH-51 }, colorTav, offsetTav, delay, 3, "")
	case 14:
	return ClickFind_Bnt({ X:(364+114*3), Y:winH-50, Right:(364+114*3)+1, Bottom:winH-51 }, colorTav, offsetTav, delay, 3, "")
	case 15:
	return ClickFind_Bnt({ X:(364+114*4), Y:winH-50, Right:(364+114*4)+1, Bottom:winH-51 }, colorTav, offsetTav, delay, 3, "")

	case 16:
	return ClickFind_Bnt({ X:269, Y:winH-26, Right:289, Bottom:winH-6 }, colorBlueSquareRect, offsetSquareRect, delay)
}

MouseClick, Left, X1, Y1, 1, 5 ; Click Neighbourhood
sleep, delay
}

Run_Taverne(count:=80)
{
	WinGetPos, X, Y, WinW, WinH, A
	Click_MO(X, Y, WinW, WinH, 16, 3000)
	Click_MO(X, Y, WinW, WinH, listID)
	Click_MO(X, Y, WinW, WinH, 4, 3000)

	curr:=0

	if(count > 0)
		count:=((count-1)/5+1)*5

	while(curr < count)
	{
		WinGetPos, X, Y, WinW, WinH, A

		sub:=Mod(curr,5)

		Click_MO(X, Y, WinW, WinH, 11+sub, 850)

		if(ClickFind_Bnt(Rect_Bnt_BP(X, Y, WinW, WinH), FoE_cRed,, 1000))
		{
			curr:=(curr/5)*5
			Continue
		}

		curr+=1
		if(sub==4 && curr < count)
			Click_MO(X, Y, WinW, WinH, 5, 1500)
	}
}

Run_MO(listID, count:=80, taverne:=true)
{
	WinGetPos, X, Y, WinW, WinH, A
	Click_MO(X, Y, WinW, WinH, 16, 3000)
	Click_MO(X, Y, WinW, WinH, listID)
	Click_MO(X, Y, WinW, WinH, 4, 3000)

	curr:=0

	if(count > 0)
		count:=((count-1)/5+1)*5

	while(curr < count)
	{
		WinGetPos, X, Y, WinW, WinH, A

		sub:=Mod(curr,5)

		if(taverne && listID==3)
			Click_MO(X, Y, WinW, WinH, 11+sub, 850)

		Click_MO(X, Y, WinW, WinH, 6+sub, 700)

		if(ClickFind_Bnt(Rect_Bnt_BP(X, Y, WinW, WinH), FoE_cRed,, 1000))
		{
			curr:=(curr/5)*5
			Continue
		}

		curr+=1
		if(sub==4 && curr < count)
			Click_MO(X, Y, WinW, WinH, 5, 1500)
	}
}

Run_MO_Full(worldID, neighbourhood:=75, guild:=80, friends:=145)
{
	; Open foe-world
	Chrome_OpenFoE(worldID)
	Sleep, 2000

	WinGetPos, X, Y, WinW, WinH, A

	rect_Login:=Rect_Bnt_OpenWorld_Login(X, Y, WinW, WinH)
	if(Find_Rect(rect_Login, FoE_cBlue2))
	{
		MouseClick, Left, Round((WinW/2)+345,0), 155
		Sleep, 250
		Click_Bnt(rect_Login, { xOffset:20, yOffset:10 }, 2500)
	}

	if(ClickFind_Bnt(Rect_Bnt_OpenWorld_Play(X, Y, WinW, WinH),FoE_cYellow2,, 750))
		Click_Bnt(Rect_Bnt_OpenWorld_Select(X, Y, WinW, WinH, worldID))

	SplashText("Opening world", 8000)

	WinGetPos, X, Y, WinW, WinH, A

	; Clear messages
	ClickFind_Bnt(Rect_Bnt_PVP_Result(X, Y, WinW, WinH), FoE_cGreen,,750)
	ClickFind_Bnt(Rect_Bnt_GG_Reward(X, Y, WinW, WinH), FoE_cYellow,,750)
	ClickFind_Bnt(Rect_Bnt_History(X, Y, WinW, WinH), FoE_cYellow,, 750)
	ClickFind_Bnt(Rect_Bnt_GS_Info_Close(X, Y, WinW, WinH), FoE_cBlue, { xOffset:10, yOffset:10 }, 750)

	; Visit players-lists
	if(neighbourhood > 0)
	{
		Run_MO(1, neighbourhood)

		if(guild > 0 || friends > 0)
			Sleep, 2000
	}

	if(guild > 0)
	{
		Run_MO(2, guild)
		if(friends > 0)
			Sleep, 2000
	}

	if(friends > 0)
		Run_MO(3, friends)
}

Run_Trade(n)
{
	if(n is Integer)
	{
		WinGetPos, X, Y, WinW, WinH, A
		rect_Bnt_Place := Rect_Bnt_Trade_Place(X, Y, WinW, WinH)
		rect_Bnt_OK := Rect_Bnt_Trade_OK(X, Y, WinW, WinH)
		offset_Bnt := { xOffset:10, yOffset:10 } ;Offset_Click()
		color_Bnt := FoE_cYellow

		curr:=0
		while(curr < n)
		{
			if(ClickFind_Bnt(rect_Bnt_Place, color_Bnt, offset_Bnt, 1500) & ClickFind_Bnt(rect_Bnt_OK, color_Bnt, offset_Bnt, 250))
			{
				
			}
			Else
				return

			curr+=1
		}
	}
}




/*
	Button Locations
	----------------
*/
Rect_Bnt_OpenWorld_Login(x, y, winW, winH) ;checked
{
	X1:=Round((WinW/2)+535,0)
	Y1:=115
	X2:=X1+100
	Y2:=Y1+20

Return { X: X1, Y: Y1, Right: X2, Bottom: Y2 }
}

Rect_Bnt_OpenWorld_Play(x, y, winW, winH) ;checked
{
	X1:=Round((WinW/2)+218,0)
	Y1:=460
	X2:=Round((WinW/2)+399,0)
	Y2:=540

Return { X: X1, Y: Y1, Right: X2, Bottom: Y2 }
}

Rect_Bnt_OpenWorld_Select(x, y, winW, winH, wordID) ;checked
{
	column:=Mod(wordID-1,3)

	switch column
	{
	case 0:
		X1:=Round((WinW/2)-241,0)
	case 1:
		X1:=Round((WinW/2)-80,0)
	case 2:
		X1:=Round((WinW/2)+80,0)
	}

	if(wordID < 4)
		Y1:=342
	else
		Y1:=394

	X2:=X1+143
	Y2:=Y1+37

	Return { X: X1, Y: Y1, Right: X2, Bottom: Y2 }
}

Rect_Bnt_BP(x, y, winW, winH) ;checked
{
	X1:=Round((WinW/2)+7,0)
	Y1:=Round((WinH/2)+232,0)
	X2:=Round((WinW/2)+176,0)
	Y2:=Round((WinH/2)+252,0)

	Return { X: X1, Y: Y1, Right: X2, Bottom: Y2 }
}

Rect_Bnt_GG_Reward(x, y, winW, winH) ;checked
{
	X1:=Round((WinW/2)-179,0)
	Y1:=Round((WinH/2)+162,0)
	X2:=Round((WinW/2)-10,0)
	Y2:=Round((WinH/2)+182,0)

	Return { X: X1, Y: Y1, Right: X2, Bottom: Y2 }
}

Rect_Bnt_History(x, y, winW, winH) ;ckecked
{
	X1:=Round((WinW/2)-86,0)
	Y1:=Round((WinH/2)+332,0)
	X2:=Round((WinW/2)+82,0)
	Y2:=Round((WinH/2)+352,0)

	Return { X: X1, Y: Y1, Right: X2, Bottom: Y2 }
}

Rect_Bnt_PVP_Result(x, y, winW, winH) ;ckecked
{
	X1:=Round((WinW/2)-53,0)
	Y1:=Round((WinH/2)+193,0)
	X2:=X1+120
	Y2:=Y1+20

	Return { X: X1, Y: Y1, Right: X2, Bottom: Y2 }
}

Rect_Bnt_Reward(x, y, winW, winH) ;ckecked: Medals, FP, Coins, GE_Gildpoints, Army, Diamons
{
	X1:=Round((WinW/2)-76,0)
	Y1:=Round((WinH/2)+135,0)
	X2:=Round((WinW/2)+54,0)
	Y2:=Round((WinH/2)+156,0)

	Return { X: X1, Y: Y1, Right: X2, Bottom: Y2 }
}

Rect_Bnt_Battle_Result(x, y, winW, winH, stats:=false) ;ckecked: pvp_Arena, ge_result
{
	X1:=Round((WinW/2)-83,0)
	Y1:=Round((WinH/2)+(stats ? 298 : 245),0)
	X2:=Round((WinW/2)+85,0)
	Y2:=Y1+20

	Return { X: X1, Y: Y1, Right: X2, Bottom: Y2 }
}

Rect_Bnt_GS_Info_Play(x, y, winW, winH) ;Message for start of new GS
{
	X1:=Round((WinW/2)-46,0)
	Y1:=Round((WinH/2)+121,0)
	X2:=X1+93
	Y2:=Y1+25

	Return { X: X1, Y: Y1, Right: X2, Bottom: Y2 }
}

Rect_Bnt_GS_Info_Close(x, y, winW, winH) ;Message for start of new GS
{
	X1:=Round((WinW/2)+106,0)
	Y1:=Round((WinH/2)-99,0)
	X2:=X1+18
	Y2:=Y1+20

	Return { X: X1, Y: Y1, Right: X2, Bottom: Y2 }
}

Rect_Bnt_Trade_Place(x, y, winW, winH)
{
	X1:=Round((WinW/2)+205,0)
	Y1:=Round((WinH/2)-47,0)
	X2:=X1+170
	Y2:=Y1+27

	Return { X: X1, Y: Y1, Right: X2, Bottom: Y2 }
}

Rect_Bnt_Trade_OK(x, y, winW, winH)
{
	X1:=Round((WinW/2)-97,0)
	Y1:=Round((WinH/2)+153,0)
	X2:=X1+210
	Y2:=Y1+27

	Return { X: X1, Y: Y1, Right: X2, Bottom: Y2 }
}

Rect_Bnt_GVG_Attack(x, y, winW, winH)
{
	X1:=Round((WinW/2)-133,0)
	Y1:=Round((WinH/2)+27,0)
	X2:=X1+87
	Y2:=Y1+87

	Return { X: X1, Y: Y1, Right: X2, Bottom: Y2 }
}

Rect_Bnt_Army_Auto(x, y, winW, winH)
{
	X1:=Round((WinW/2)-150,0)
	Y1:=Round((WinH/2)+287,0)
	X2:=X1+170
	Y2:=Y1+20

	Return { X: X1, Y: Y1, Right: X2, Bottom: Y2 }
}

Rect_Bnt_Army_Auto2(x, y, winW, winH)
{
	X1:=Round((WinW/2)-83,0)
	; Y1:=Round((WinH/2)+303,0)
	Y1:=Round((WinH/2)+287,0)
	; X2:=X1+170
	X2:=X1+70
	Y2:=Y1+20

	Return { X: X1, Y: Y1, Right: X2, Bottom: Y2 }
}

Rect_Bnt_Army_Reward_OK(x, y, winW, winH)
{
	X1:=Round((WinW/2)-75,0)
	Y1:=Round((WinH/2)+137,0)
	X2:=X1+130
	Y2:=Y1+20

	Return { X: X1, Y: Y1, Right: X2, Bottom: Y2 }
}

Rect_Bnt_Army_Result_OK(x, y, winW, winH)
{
	; X1:=Round((WinW/2)-83,0)
	; Y1:=Round((WinH/2)+311,0)
	; X2:=X1+170
	; Y2:=Y1+20

	; X1:=Round((WinW/2)-83,0)
	; Y1:=Round((WinH/2)+298,0)
	; X2:=X1+170
	; Y2:=Y1+20

	X1:=Round((WinW/2)-83,0)
	Y1:=Round((WinH/2)+245,0)
	;X2:=X1+170
	X2:=X1+40
	Y2:=Y1+20

	Return { X: X1, Y: Y1, Right: X2, Bottom: Y2 }
}

Rect_Bnt_Army_Result_GBG_OK(x, y, winW, winH)
{
	X1:=Round((WinW/2)-83,0)
	Y1:=Round((WinH/2)+298,0)
	;X2:=X1+170
	X2:=X1+40 ;due to delay on auto-attack and to avoid manual-attack size is reduced
	Y2:=Y1+20

	Return { X: X1, Y: Y1, Right: X2, Bottom: Y2 }
}


Rect_Bnt_Army_Result_PVPArena_OK(x, y, winW, winH)
{
	X1:=Round((WinW/2)-83,0)
	Y1:=Round((WinH/2)+260,0)
	X2:=X1+170
	Y2:=Y1+20

	Return { X: X1, Y: Y1, Right: X2, Bottom: Y2 }
}

Rect_ArmySelectedBox(x, y, winW, winH, boxID:=0) ;checked
{
	X1:=Round((WinW/2)-326,0)
	Y1:=Round((WinH/2)-91,0)

	boxX := Mod(boxID, 4)
	X1 += boxX * (12 + 55)

	if(boxID > 3)
		Y1+=69

	X2:=X1+55
	Y2:=Y1+61

	Return { X: X1, Y: Y1, Right: X2, Bottom: Y2 }
}

Rect_ArmySelectionTab(x, y, winW, winH, tabID:=0) ;checked
{
	/*  
		0 - Alle
		1 - Snelle
		2 - Zware
		3 - Lichte
		4 - Artillerie
		5 - Afstand
	*/

	X1:=Round((WinW/2)-259,0)
	Y1:=Round((WinH/2)+74,0)

	X1 += tabID * (7 + 37)
	
	X2:=X1+37
	Y2:=Y1+30

	Return { X: X1, Y: Y1, Right: X2, Bottom: Y2 }
}

Rect_ArmySelectionBox(x, y, winW, winH, boxID:=0) ;checked
{
	X1:=Round((WinW/2)-251,0)
	Y1:=Round((WinH/2)+120,0)

	boxX := Mod(boxID, 9)
	X1 += boxX * (15 + 55)

	if(boxID > 8)
		Y1+=70

	X2:=X1+55
	Y2:=Y1+61

	Return { X: X1, Y: Y1, Right: X2, Bottom: Y2 }
}

Rect_ArmySelectionScrollH(x, y, winW, winH, loc=0) 
{
	X1:=Round((WinW/2)-270,0)
	Y1:=Round((WinH/2)+267,0)
	X2:=X1+650
	Y2:=Y1+15
	bntWidth:=18
	;scrollBoxWidth:=38

	Return { X: X1+bntWidth, Y: Y1, Right: X2-bntWidth, Bottom: Y2 }
}