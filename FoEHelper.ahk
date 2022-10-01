#SingleInstance, Force
#Include FoE_Table.ahk ; Common foe settings

Escape::
ExitApp
return

Visit_Worlds(onlyFriends:=false)
{
	friends_A:=144
	friends_B:=144
	friends_C:=144
	friends_D:=144
	friends_E:=144
	friends_F:=144
	friends_G:=144


	if(onlyFriends)
	{
		Run_MO_Full(1, 0, 0, friends_A)
		Run_MO_Full(2, 0, 0, friends_B)
		Run_MO_Full(3, 0, 0, friends_C)
		Run_MO_Full(4, 0, 0, friends_D)
		Run_MO_Full(5, 0, 0, friends_E)
		Run_MO_Full(6, 0, 0, friends_F)
		Run_MO_Full(7, 0, 0, friends_G)
	}
	else
	{
		Run_MO_Full(1,,, friends_A)
		Run_MO_Full(2,,, friends_B)
		Run_MO_Full(3,,, friends_C)
		Run_MO_Full(4,,, friends_D)
		Run_MO_Full(5,,, friends_E)
		Run_MO_Full(6,,, friends_F)
		Run_MO_Full(7,,, friends_G)
	}
}

Recuring_Stories()
{
	alreadyOpen := Open_Story(1)
	Process_Story(alreadyOpen)

	Send, q
	Sleep, 2000
}

^f::
	Visit_Worlds(true)
return

^m::
	Visit_Worlds(false)
return

^s::
	Recuring_Stories()
return

^t::
{
	inputbox, n, Box #2,,,20,100
	Run_Trade(n)
	return
}

^o::
{
	worldID:=1
	while(worldID < 8)
	{
		Chrome_OpenFoE(worldID)
		Sleep, 3800

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

		worldID:=worldID+1
	}

	return
}


; Tools

!Numpad1::
	DisplayMouseLocation()
Return

^!z:: ; Control+Alt+Z hotkey.
	DisplayColor()
return




/*
  Story Helpers
*/
Open_Story(id)
{
	id-=1
	alreadOpen:=true

	; Open Story view
	if(IsPixel(73, 242, 0X74A0C2))
	{
		Send, q
		Sleep, 1350
		alreadOpen := false
	}

	X1 := 690
	Y1 := 210 + id*90 + 3

	if(!IsPixel(X1, Y1, 0X7AA7C3))
	{
		MouseClick, Left, X1+50, Y1+40, 1, 5
		Sleep, 750
		alreadOpen := false
	}

	return alreadOpen
}

Story_BoxY(id, scroll:=0) ; checked 1,2,3
{
	id-=1
	box_1Quest_Height:=243
	box_2Quest_Height:=250

	Y1:=165 + id*box_1Quest_Height

	if(scroll > 0)
	{
		if(scroll < 4)
			Y1-=scroll*60
		else
		{
			if(IsPixel(508, Y1-200, 0X0D477B))
				return Y1-200 ;/single
			else
				return Y1-221 ;/double
		}
	}

	if(IsPixel(508, Y1, 0X0D477B))
		return Y1
	else
		return Y1+(box_2Quest_Height-box_1Quest_Height)
}

Story_City_OT(boxY)
{
	PixelSearch, PixelX, PixelY, 83, boxY+180, 87, boxY+185, 0XE2D1DA, 6
	return ErrorLevel = 0
}

Story_Icon_Single_CubeReward(boxY)
{
	return IsPixel(571, boxY+76, 0X121D22) && IsPixel(579,boxY+72, 0XBAD3DA)
}

Story_Icon_Single_FP(boxY)
{
	if(IsPixel(139, boxY+125, 0X97B2C6) && IsPixel(152,boxY+129, 0X44647C) && IsPixel(149,boxY+119, 0X6C92AF))
		return IsPixel(176, boxY+113, 0X102440) ; buy fp's: return false

	return false
}

Story_Icon_Single_Supplies(boxY)
{
	if(IsPixel(150, boxY+129, 0X229D67) && IsPixel(144,boxY+122, 0X0052AA) && IsPixel(143,boxY+116, 0XF1F1F1))
	{
		If (Story_City_OT(boxY))
			 return !IsPixel(28, boxY+9, 0X7D88A1) ; skip 'Vink' for an story with less supplies (return false)
		Else
			return true
	}

	return false
}

Story_Skip(id, scroll:=0)
{
	Y:=Story_BoxY(id, scroll)

	if(Story_Icon_Single_CubeReward(Y))
		return !Story_Icon_Single_FP(Y) && !Story_Icon_Single_Supplies(Y)
	
	return false
}

Story_Collect(id, scroll:=0, delay:=2500)
{
	Y:=Story_BoxY(id, scroll)
	bntHeight:=20

	; Finished story
	offset:={ xOffset:1, yOffset:1 }
	if(ClickFind_Bnt({ X: 525, Y: Y+130, Right: 630, Bottom: Y+130+bntHeight+40 }, FoE_cGreen, offset,delay,,,true))
		return true

	; Abord
	if(Story_Skip(id, scroll) && ClickFind_Bnt({ X: 227, Y: Y+157, Right: 397, Bottom: Y+157+bntHeight+60 }, FoE_cRed,offset,delay,,,true))
		return true

	return false
}

Process_Story(gotoFirst:=false)
{
	WinGetPos, X, Y, WinW, WinH, A
	aScroll:=true
	beginList:

	if(gotoFirst)
	{
		gotoFirst := false
		MouseClick, Left, 665, 185
	}
	
	if(Story_Collect(1, 0, 250))
	{
		ClickFind_Bnt(Rect_Bnt_BP(X, Y, WinW, WinH), FoE_cRed,, 750)

		X1 := 690
		Y1 := 210 + 90 + 3
		MouseClick, Left, X1+50, Y1+40, 1, 5
		Sleep, 250

		Y1 := 210 + 3
		MouseClick, Left, X1+50, Y1+40, 1, 5
		Sleep, 750
		Goto, beginList
	}

	if(Story_Collect(2, 0)) 
	{
		ClickFind_Bnt(Rect_Bnt_BP(X, Y, WinW, WinH), FoE_cRed,, 750)

		gotoFirst:= true
		Goto, beginList
	}
	
	if(aScroll)
	{
		aScroll := false
		MouseMove, 665, 420 ;on scroll control
		loop, 5
		{
			Send {WheelDown}
			Sleep, 75
		}

		Sleep, 1500
	}

	if(Story_Collect(3, 5, 1200)) 
	{
		ClickFind_Bnt(Rect_Bnt_BP(X, Y, WinW, WinH), FoE_cRed,, 750)
		Goto, beginList
	}
}

MyTest(id)
{
	Test_Bnt(id)
}

^Numpad1::
	MyTest(1)
Return

^Numpad2::
	MyTest(2)
Return

^Numpad3::
	MyTest(3)
Return

^Numpad4::
	MyTest(4)
Return

^Numpad5::
	MyTest(5)
Return

Reload()
{
	mouseSpeed:=0
	WinGetPos, X, Y, WinW, WinH, A
	offset_Bnt := { xOffset:25, yOffset:30 } ;Offset_Click()
	speed := 0

	Click_Speed(Rect_ArmySelectedBox(X, Y, WinW, WinH, 0), mouseSpeed, offset_Bnt, speed)
	Click_Speed(Rect_ArmySelectedBox(X, Y, WinW, WinH, 0), mouseSpeed, offset_Bnt, speed)
	Click_Speed(Rect_ArmySelectedBox(X, Y, WinW, WinH, 0), mouseSpeed, offset_Bnt, speed)
	Click_Speed(Rect_ArmySelectedBox(X, Y, WinW, WinH, 0), mouseSpeed, offset_Bnt, speed)
	Click_Speed(Rect_ArmySelectedBox(X, Y, WinW, WinH, 0), mouseSpeed, offset_Bnt, speed)
	Click_Speed(Rect_ArmySelectedBox(X, Y, WinW, WinH, 0), mouseSpeed, offset_Bnt, speed)
	Click_Speed(Rect_ArmySelectedBox(X, Y, WinW, WinH, 0), mouseSpeed, offset_Bnt, speed)
	Click_Speed(Rect_ArmySelectedBox(X, Y, WinW, WinH, 0), mouseSpeed, offset_Bnt, 0)

	; Select 3 hovers
	Click_Speed(Rect_ArmySelectionTab(X, Y, WinW, WinH, 2), mouseSpeed, offset_Bnt, 0)
	Click_Speed(Rect_ArmySelectionBox(X, Y, WinW, WinH, 2), mouseSpeed, offset_Bnt, speed)
	Click_Speed(Rect_ArmySelectionBox(X, Y, WinW, WinH, 2), mouseSpeed, offset_Bnt, speed)
	Click_Speed(Rect_ArmySelectionBox(X, Y, WinW, WinH, 2), mouseSpeed, offset_Bnt, speed)

	; Select 5 agents
	Click_Speed(Rect_ArmySelectionTab(X, Y, WinW, WinH, 3), mouseSpeed, offset_Bnt, 0)
	; scrollLoc:=20 ; B-wereld
	scrollLoc:=33 ; F-wereld
	Click_Speed(Rect_ArmySelectionScrollH(X, Y, WinW, WinH, 0), mouseSpeed, { xOffset:576-(576/100*scrollLoc)+18, yOffset:7 }, 0)
	Click_Speed(Rect_ArmySelectionBox(X, Y, WinW, WinH, 2), mouseSpeed, offset_Bnt, speed)
	Click_Speed(Rect_ArmySelectionBox(X, Y, WinW, WinH, 2), mouseSpeed, offset_Bnt, speed)
	Click_Speed(Rect_ArmySelectionBox(X, Y, WinW, WinH, 2), mouseSpeed, offset_Bnt, speed)
	Click_Speed(Rect_ArmySelectionBox(X, Y, WinW, WinH, 2), mouseSpeed, offset_Bnt, speed)
	Click_Speed(Rect_ArmySelectionBox(X, Y, WinW, WinH, 2), mouseSpeed, offset_Bnt, speed)
}

Reload2()
{
	mouseSpeed:=0
	WinGetPos, X, Y, WinW, WinH, A
	offset_Bnt := { xOffset:25, yOffset:30 } ;Offset_Click()
	speed := 0

	Click_Speed(Rect_ArmySelectedBox(X, Y, WinW, WinH, 0), mouseSpeed, offset_Bnt, speed)
	Click_Speed(Rect_ArmySelectedBox(X, Y, WinW, WinH, 0), mouseSpeed, offset_Bnt, speed)
	Click_Speed(Rect_ArmySelectedBox(X, Y, WinW, WinH, 0), mouseSpeed, offset_Bnt, speed)
	Click_Speed(Rect_ArmySelectedBox(X, Y, WinW, WinH, 0), mouseSpeed, offset_Bnt, speed)
	Click_Speed(Rect_ArmySelectedBox(X, Y, WinW, WinH, 0), mouseSpeed, offset_Bnt, speed)
	Click_Speed(Rect_ArmySelectedBox(X, Y, WinW, WinH, 0), mouseSpeed, offset_Bnt, speed)
	Click_Speed(Rect_ArmySelectedBox(X, Y, WinW, WinH, 0), mouseSpeed, offset_Bnt, speed)
	Click_Speed(Rect_ArmySelectedBox(X, Y, WinW, WinH, 0), mouseSpeed, offset_Bnt, 0)

	; Select 3 hovers
	Click_Speed(Rect_ArmySelectionTab(X, Y, WinW, WinH, 5), mouseSpeed, offset_Bnt, 0)
	Click_Speed(Rect_ArmySelectionBox(X, Y, WinW, WinH, 2), mouseSpeed, offset_Bnt, speed)
	Click_Speed(Rect_ArmySelectionBox(X, Y, WinW, WinH, 2), mouseSpeed, offset_Bnt, speed)
	Click_Speed(Rect_ArmySelectionBox(X, Y, WinW, WinH, 2), mouseSpeed, offset_Bnt, speed)

	; Select 5 agents
	Click_Speed(Rect_ArmySelectionTab(X, Y, WinW, WinH, 3), mouseSpeed, offset_Bnt, 0)
	; scrollLoc:=20 ; B-wereld
	scrollLoc:=33 ; F-wereld
	Click_Speed(Rect_ArmySelectionScrollH(X, Y, WinW, WinH, 0), mouseSpeed, { xOffset:576-(576/100*scrollLoc)+18, yOffset:7 }, 0)
	Click_Speed(Rect_ArmySelectionBox(X, Y, WinW, WinH, 2), mouseSpeed, offset_Bnt, speed)
	Click_Speed(Rect_ArmySelectionBox(X, Y, WinW, WinH, 2), mouseSpeed, offset_Bnt, speed)
	Click_Speed(Rect_ArmySelectionBox(X, Y, WinW, WinH, 2), mouseSpeed, offset_Bnt, speed)
	Click_Speed(Rect_ArmySelectionBox(X, Y, WinW, WinH, 2), mouseSpeed, offset_Bnt, speed)
	Click_Speed(Rect_ArmySelectionBox(X, Y, WinW, WinH, 2), mouseSpeed, offset_Bnt, speed)
}

Attack()
{
	mouseSpeed:=0
	WinGetPos, X, Y, WinW, WinH, A
	offset_Bnt := { xOffset:10, yOffset:10 } ;Offset_Click()

	rect_Bnt := Rect_Bnt_GVG_Attack(X, Y, WinW, WinH)
	if(ClickFind_Speed_Bnt(rect_Bnt, FoE_cYellow3, mouseSpeed, offset_Bnt, 0) || ClickFind_Speed_Bnt(rect_Bnt, FoE_cYellow3_Sel, mouseSpeed, offset_Bnt, 0))
		Return

	rect_Bnt := Rect_Bnt_Army_Auto(X, Y, WinW, WinH)
	if(ClickFind_Speed_Bnt(rect_Bnt, FoE_cYellow, mouseSpeed, offset_Bnt, 0) || ClickFind_Speed_Bnt(rect_Bnt, FoE_cYellow_Sel, mouseSpeed, offset_Bnt, 0))
		Return

	rect_Bnt := Rect_Bnt_Army_Auto2(X, Y, WinW, WinH)
	if(ClickFind_Speed_Bnt(rect_Bnt, FoE_cYellow, mouseSpeed, offset_Bnt, 0) || ClickFind_Speed_Bnt(rect_Bnt, FoE_cYellow_Sel, mouseSpeed, offset_Bnt, 0))
		Return

	rect_Bnt := Rect_Bnt_Army_Result_GBG_OK(X, Y, WinW, WinH)
	if(ClickFind_Speed_Bnt(rect_Bnt, FoE_cGreen, mouseSpeed, offset_Bnt, 0) || ClickFind_Speed_Bnt(rect_Bnt, FoE_cGreen_Sel, mouseSpeed, offset_Bnt, 0))
	 	Return

	rect_Bnt := Rect_Bnt_Army_Result_PVPArena_OK(X, Y, WinW, WinH)
	if(ClickFind_Speed_Bnt(rect_Bnt, FoE_cGreen, mouseSpeed, offset_Bnt, 0) || ClickFind_Speed_Bnt(rect_Bnt, FoE_cGreen_Sel, mouseSpeed, offset_Bnt, 0))
		Return

	rect_Bnt := Rect_Bnt_Army_Result_OK(X, Y, WinW, WinH)
	if(ClickFind_Speed_Bnt(rect_Bnt, FoE_cGreen, mouseSpeed, offset_Bnt, 0) || ClickFind_Speed_Bnt(rect_Bnt, FoE_cGreen_Sel, mouseSpeed, offset_Bnt, 0))
		Return

	rect_Bnt := Rect_Bnt_Army_Reward_OK(X, Y, WinW, WinH)
	if(ClickFind_Speed_Bnt(rect_Bnt, FoE_cYellow, mouseSpeed, offset_Bnt, 0) || ClickFind_Speed_Bnt(rect_Bnt, FoE_cYellow_Sel, mouseSpeed, offset_Bnt, 0))
		Return

	
	

	;SplashText("Army_AttackBnt not found", 800)
}

XButton1::
	Reload()
return

XButton2::
	Attack()
return