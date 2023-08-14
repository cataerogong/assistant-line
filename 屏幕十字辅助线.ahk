#SingleInstance Ignore
CoordMode, Mouse, Screen  ; ������������Ļ��λ
CoordMode, ToolTip, Screen

AppName := "��Ļʮ�ָ�����"
AppVer  := "v1.2"
AppCopyRight := "Copyright (c) 2023 C.G."

IniFile := A_ScriptDir . "\" . A_ScriptName . ".ini"
IcoFile := A_ScriptDir . "\" . A_ScriptName . ".ico"

IniRead, Modifier, %IniFile%, ��Ļʮ�ָ�����, �ȼ����η�, ^!  ; �������ļ���ȡ���η����������Ļ�����Ĭ�ϣ�Ctrl+Alt��
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
			MsgBox, �����ļ��е��ȼ����η���Ч��ʹ��Ĭ�����η���Ctrl+Alt
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
Menu, Tray, Add, ��/�ر� ������, SwitchBar
Menu, Tray, Add, �˳�, AppExit
Menu, Tray, Default, 3&
TrayTip, %AppName%, ��/�ر�: ˫������ͼ��`n��ݼ�: %ModifierStr%<=>, , 0x1

GoSub, InitBarEnv

Return


InitBarEnv:
	BarWinTitle := "��Ļʮ�ָ�����MainWin@" A_ScriptName
    BarXWidth := 20  ; ˮƽ�����߿��
    BarYWidth := 60  ; ��ֱ�����߿��
    BarWidthMax := 500
    BarWidthMin := 10
    WinColor := "999999"  ; �ڸǴ��ڱ���ɫ
    WinTrans := 150  ; ͸����(0-255)
    BarColor := "99FFCC"  ; �����߿ؼ�����ɫ
    TransColor := BarColor
	HelpWinTitle := "��Ļʮ�ָ�����HelpWin@" A_ScriptName
    BarHelpMsg := "
(
" AppName " " AppVer "
" AppCopyRight "
---------------------------------
��ݼ�: " ModifierStr "
    = : ��/�� ������
    - : ��/�� ˮƽ������
    0 : ����ˮƽ������
    9 : ��խˮƽ������
    \ : ��/�� ��ֱ������
    ] : ����ֱ������
    [ : ��խ��ֱ������
    Backspace : ����͸������
    ������ : �ı�͸����
    h : ��/�� ������Ϣ
)"

	HotKey, %Modifier%=, SwitchBar  ; ��/�� ������
	HotKey, IfWinExist, %BarWinTitle%
	HotKey, %Modifier%h, SwitchHelp  ; ��/�� ������Ϣ
	HotKey, %Modifier%-, SwitchBarX  ; ��/�� ˮƽ������
	HotKey, %Modifier%0, WidenBarX  ; ����ˮƽ������
	HotKey, %Modifier%9, NarrowBarX  ; ��խˮƽ������
	HotKey, %Modifier%\, SwitchBarY  ; ��/�� ��ֱ������
	HotKey, %Modifier%], WidenBarY  ; ����ֱ������
	HotKey, %Modifier%[, NarrowBarY  ; ��խ��ֱ������
	HotKey, %Modifier%Backspace, SwitchTrans  ; ����͸������
	HotKey, %Modifier%WheelDown, IncTrans  ; �����ڸǲ�͸����
	HotKey, %Modifier%WheelUp, DecTrans  ; �����ڸǲ�͸����
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

SwitchHelp:  ; ��/�� ������Ϣ
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
		SysGet, PM, MonitorPrimary  ; ��ȡ����Ļ
		SysGet, MonPM, Monitor, %PM%  ; ��ȡ����Ļ��С
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

	Gui, BarWin:+LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale ; +ToolWindow ������ʾ��������ť�� alt-tab �˵���
	Gui, BarWin:Color, %WinColor%
	Gui, BarWin:Add, Progress, x0 y0 w%BarYWidth% h%CurMonH% Background%BarColor% vBarY  ; ��ֱ������
	Gui, BarWin:Add, Progress, x0 y0 w%CurMonW% h%BarXWidth% Background%BarColor% vBarX  ; ˮƽ������
	Gui, BarWin:+LastFound
	WinSet, TransColor, %TransColor% %WinTrans%  ; �ô���ɫ����������͸������������ɫ��ʾΪ��͸��
	WinSet, ExStyle, +0x20  ; ���ڿɴ�͸�������ǰ�͸����
Return

SwitchBar:  ; ��/�� ������
    If (!WinExist(BarWinTitle))
	{
		GoSub, CreateBarWin
		GoSub, UpdateBar
		Gui, BarWin:Show, x%CurMonL% y%CurMonT% w%CurMonW% h%CurMonH% NA, %BarWinTitle%  ; NoActivate �õ�ǰ����ڼ������ֻ״̬
		SetTimer, UpdateBar, 100  ; ˢ�¸����ߵĶ�ʱ��
		GoSub, ShowHelp
	}
	Else
	{
		SetTimer, UpdateBar, Off
		Gui, BarWin:Destroy
		GoSub, HideHelp
	}
Return

UpdateBar:  ; ˢ�¸�����
	MouseGetPos, MouseX, MouseY, PtrWinID
	GuiControl, BarWin:Move, BarX, % "y" MouseY-BarXWidth/2-CurMonT "h" BarXWidth
	GuiControl, BarWin:Move, BarY, % "x" MouseX-BarYWidth/2-CurMonL "w" BarYWidth
	WinGet, HelpWinID, ID, %HelpWinTitle%
	If (PtrWinID == HelpWinID)
	{
		GoSub, MoveHelp
	}
Return

SwitchBarX:  ; ��/�� ˮƽ������
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

SwitchBarY:  ; ��/�� ��ֱ������
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
	ToolTip, ˮƽ�߿�%BarXWidth%`n��ֱ�߿�%BarYWidth%
	SetTimer, ClearTip, -1000
Return

WidenBarY:  ; ����ֱ������
	If (BarYWidth < BarWidthMax)
	{
		BarYWidth := BarYWidth + 10
		GoSub, UpdateWidth
	}
Return

NarrowBarY:  ; ��խ��ֱ������
	If (BarYWidth > BarWidthMin)
	{
		BarYWidth := BarYWidth - 10
		GoSub, UpdateWidth
	}
Return

WidenBarX:  ; ����ˮƽ������
	If (BarXWidth < BarWidthMax)
	{
		BarXWidth := BarXWidth + 10
		GoSub, UpdateWidth
	}
Return

NarrowBarX:  ; ��խˮƽ������
	If (BarXWidth > BarWidthMin)
	{
		BarXWidth := BarXWidth - 10
		GoSub, UpdateWidth
	}
Return

UpdateTrans:
	Gui, BarWin:+LastFound
	WinSet, TransColor, %TransColor% %WinTrans%  ; �ô���ɫ����������͸������������ɫ��ʾΪ��͸��
	ToolTip, ͸���ȣ�%WinTrans%
	SetTimer, ClearTip, -1000
Return

IncTrans:  ; �����ڸǲ�͸����
	If (WinTrans > 20)
	{
		WinTrans := WinTrans - 10
		GoSub, UpdateTrans
	}
Return

DecTrans:  ; �����ڸǲ�͸����
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
