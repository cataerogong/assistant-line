#SingleInstance Ignore
CoordMode, Mouse, Screen  ; 鼠标坐标采用屏幕定位
CoordMode, ToolTip, Screen

AppName := "屏幕十字辅助线"
AppVer  := "v1.2"
AppCopyRight := "Copyright (c) 2023 C.G."

IniFile := A_ScriptDir . "\" . A_ScriptName . ".ini"
IcoFile := A_ScriptDir . "\" . A_ScriptName . ".ico"

IniRead, Modifier, %IniFile%, 屏幕十字辅助线, 热键修饰符, ^!  ; 从配置文件读取修饰符，读不到的话就用默认（Ctrl+Alt）
ModifierStr := ""
Loop, Parse, Modifier
{
	Switch A_LoopField
	{
		Case "#":
			ModifierStr .= "<Win>+"
		Case "^":
			ModifierStr .= "<Ctrl>+"
		Case "!":
			ModifierStr .= "<Alt>+"
		Case "+":
			ModifierStr .= "<Shift>+"
		Default:
			MsgBox, 配置文件中的热键修饰符无效，使用默认修饰符：Ctrl+Alt
			Modifier := "^!"
			ModifierStr := "<Ctrl>+<Alt>+"
			Break
	}
}

If ((Not A_IsCompiled) And FileExist(IcoFile))
{
    Menu, Tray, Icon, %IcoFile%
}
Menu, Tray, NoStandard
Menu, Tray, Add, %AppName% %AppVer%, DummySub
Menu, Tray, Disable, 1&
Menu, Tray, Add, 
Menu, Tray, Add, 打开/关闭 辅助线, SwitchBar
Menu, Tray, Add, 退出, AppExit
Menu, Tray, Default, 3&
TrayTip, %AppName%, 打开/关闭: 双击托盘图标`n快捷键: %ModifierStr%<=>, , 0x1

GoSub, InitBarEnv

Return


InitBarEnv:
	BarWinTitle := "屏幕十字辅助线MainWin@" A_ScriptName
    BarXWidth := 20  ; 水平辅助线宽度
    BarYWidth := 60  ; 垂直辅助线宽度
    BarWidthMax := 500
    BarWidthMin := 10
    WinColor := "999999"  ; 遮盖窗口背景色
    WinTrans := 150  ; 透明度(0-255)
    BarColor := "99FFCC"  ; 辅助线控件背景色
    TransColor := BarColor
	HelpWinTitle := "屏幕十字辅助线HelpWin@" A_ScriptName
    BarHelpMsg := "
(
" AppName " " AppVer "
" AppCopyRight "
---------------------------------
快捷键: " ModifierStr "
    = : 开/关 辅助线
    - : 开/关 水平辅助线
    0 : 增宽水平辅助线
    9 : 缩窄水平辅助线
    \ : 开/关 垂直辅助线
    ] : 增宽垂直辅助线
    [ : 缩窄垂直辅助线
    Backspace : 交换透明区域
    鼠标滚轮 : 改变透明度
    h : 开/关 帮助信息
)"

	HotKey, %Modifier%=, SwitchBar  ; 开/关 辅助线
	HotKey, IfWinExist, %BarWinTitle%
	HotKey, %Modifier%h, SwitchHelp  ; 开/关 帮助信息
	HotKey, %Modifier%-, SwitchBarX  ; 开/关 水平辅助线
	HotKey, %Modifier%0, WidenBarX  ; 增宽水平辅助线
	HotKey, %Modifier%9, NarrowBarX  ; 缩窄水平辅助线
	HotKey, %Modifier%\, SwitchBarY  ; 开/关 垂直辅助线
	HotKey, %Modifier%], WidenBarY  ; 增宽垂直辅助线
	HotKey, %Modifier%[, NarrowBarY  ; 缩窄垂直辅助线
	HotKey, %Modifier%Backspace, SwitchTrans  ; 交换透明区域
	HotKey, %Modifier%WheelDown, IncTrans  ; 增加遮盖层透明度
	HotKey, %Modifier%WheelUp, DecTrans  ; 降低遮盖层透明度
	HotKey, IfWinExist
Return

DummySub:
Return

AppExit:
	ExitApp
Return

ShowHelp:
	If WinExist(HelpWinTitle)
		Return
	Gui, HelpWin:+AlwaysOnTop -Caption +ToolWindow -DPIScale
	Gui, HelpWin:Color, 99FFCC
	Gui, HelpWin:Add, Text, , %BarHelpMsg%
	Gui, HelpWin:+LastFound
	WinSet, Transparent, 0
	Gui, HelpWin:Show, NoActivate, %HelpWinTitle%
	Gui, HelpWin:+LastFound
	WinGetPos, , , HelpWinW, HelpWinH
	WinMove, % CurMonR-HelpWinW, %CurMonT%
	WinSet, Transparent, 255
Return

HideHelp:
	Gui, HelpWin:Destroy
Return

SwitchHelp:  ; 开/关 帮助信息
	If WinExist(HelpWinTitle)
		GoSub, HideHelp
	Else
		GoSub, ShowHelp
Return

MoveHelp:
	If !WinExist(HelpWinTitle)
		Return
	Gui, HelpWin:+LastFound
	WinGetPos, xx, yy
	WinMove, % CurMonR-HelpWinW-xx+CurMonL, % CurMonB-HelpWinH-yy+CurMonT
Return

ClearTip:
	ToolTip
Return

GetCurMon:
	MouseGetPos, MouseX, MouseY
	SysGet, MonCnt, 80
	CurMon := 0
	Loop, %MonCnt%
	{
		SysGet, Mon%A_Index%, Monitor, %A_Index%
		CurMonL := Mon%A_Index%Left
		CurMonR := Mon%A_Index%Right
		CurMonT := Mon%A_Index%Top
		CurMonB := Mon%A_Index%Bottom
		If MouseX Between %CurMonL% And % CurMonR-1
			if MouseY Between %CurMonT% And % CurMonB-1
			{
				CurMon := A_Index
				Break
			}
	}
	If (CurMon == 0)
	{
		SysGet, PM, MonitorPrimary  ; 获取主屏幕
		SysGet, MonPM, Monitor, %PM%  ; 获取主屏幕大小
		CurMonL := MonPMLeft
		CurMonR := MonPMRight
		CurMonT := MonPMTop
		CurMonB := MonPMBottom
	}
	CurMonW := CurMonR - CurMonL
	CurMonH := CurMonB - CurMonT
Return

CreateBarWin:
	GoSub, GetCurMon

	Gui, BarWin:+LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale ; +ToolWindow 避免显示任务栏按钮和 alt-tab 菜单项
	Gui, BarWin:Color, %WinColor%
	Gui, BarWin:Add, Progress, x0 y0 w%BarYWidth% h%CurMonH% Background%BarColor% vBarY  ; 垂直辅助线
	Gui, BarWin:Add, Progress, x0 y0 w%CurMonW% h%BarXWidth% Background%BarColor% vBarX  ; 水平辅助线
	Gui, BarWin:+LastFound
	WinSet, TransColor, %TransColor% %WinTrans%  ; 让此颜色的所有像素透明且让其他颜色显示为半透明
	WinSet, ExStyle, +0x20  ; 窗口可穿透（必须是半透明）
Return

SwitchBar:  ; 开/关 辅助线
    If (!WinExist(BarWinTitle))
	{
		GoSub, CreateBarWin
		GoSub, UpdateBar
		Gui, BarWin:Show, x%CurMonL% y%CurMonT% w%CurMonW% h%CurMonH% NA, %BarWinTitle%  ; NoActivate 让当前活动窗口继续保持活动状态
		SetTimer, UpdateBar, 100  ; 刷新辅助线的定时器
		GoSub, ShowHelp
	}
	Else
	{
		SetTimer, UpdateBar, Off
		Gui, BarWin:Destroy
		GoSub, HideHelp
	}
Return

UpdateBar:  ; 刷新辅助线
	MouseGetPos, MouseX, MouseY, PtrWinID
	GuiControl, BarWin:Move, BarX, % "y" MouseY-BarXWidth/2-CurMonT "h" BarXWidth
	GuiControl, BarWin:Move, BarY, % "x" MouseX-BarYWidth/2-CurMonL "w" BarYWidth
	WinGet, HelpWinID, ID, %HelpWinTitle%
	If (PtrWinID == HelpWinID)
	{
		GoSub, MoveHelp
	}
Return

SwitchBarX:  ; 开/关 水平辅助线
	GuiControlGet, vis, BarWin:Visible, BarX
	If (vis == 0)
	{
		GuiControl, BarWin:Show, BarX
	}
	Else
	{
		GuiControl, BarWin:Hide, BarX
	}
Return

SwitchBarY:  ; 开/关 垂直辅助线
	GuiControlGet, vis, BarWin:Visible, BarY
	If (vis == 0)
	{
		GuiControl, BarWin:Show, BarY
	}
	Else
	{
		GuiControl, BarWin:Hide, BarY
	}
Return

UpdateWidth:
	GoSub, UpdateBar
	ToolTip, 水平线宽：%BarXWidth%`n垂直线宽：%BarYWidth%
	SetTimer, ClearTip, -1000
Return

WidenBarY:  ; 增宽垂直辅助线
	If (BarYWidth < BarWidthMax)
	{
		BarYWidth := BarYWidth + 10
		GoSub, UpdateWidth
	}
Return

NarrowBarY:  ; 缩窄垂直辅助线
	If (BarYWidth > BarWidthMin)
	{
		BarYWidth := BarYWidth - 10
		GoSub, UpdateWidth
	}
Return

WidenBarX:  ; 增宽水平辅助线
	If (BarXWidth < BarWidthMax)
	{
		BarXWidth := BarXWidth + 10
		GoSub, UpdateWidth
	}
Return

NarrowBarX:  ; 缩窄水平辅助线
	If (BarXWidth > BarWidthMin)
	{
		BarXWidth := BarXWidth - 10
		GoSub, UpdateWidth
	}
Return

UpdateTrans:
	Gui, BarWin:+LastFound
	WinSet, TransColor, %TransColor% %WinTrans%  ; 让此颜色的所有像素透明且让其他颜色显示为半透明
	ToolTip, 透明度：%WinTrans%
	SetTimer, ClearTip, -1000
Return

IncTrans:  ; 增加遮盖层透明度
	If (WinTrans > 20)
	{
		WinTrans := WinTrans - 10
		GoSub, UpdateTrans
	}
Return

DecTrans:  ; 降低遮盖层透明度
	If (WinTrans < 240)
	{
		WinTrans := WinTrans + 10
		GoSub, UpdateTrans
	}
Return

SwitchTrans:
	If (TransColor == BarColor)
	{
		TransColor := WinColor
	}
	Else
	{
		TransColor := BarColor
	}
	GoSub, UpdateTrans
Return
