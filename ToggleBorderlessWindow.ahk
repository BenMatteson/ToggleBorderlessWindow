#SingleInstance Force
#UseHook On ;Optional, requires more memory, but allows the hotkeys to function in more cases
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.

;adapted from:
;https://autohotkey.com/board/topic/114598-borderless-windowed-mode-forced-fullscreen-script-toggle/
^+PgUp:: ToggleBorderlessWindow()
!^+PgUp::
	MouseGetPos,,, window ; Use the ID of the window under the Mouse.
	ToggleBorderlessWindow(window)
return

;Accepts id of a specific window, or uses the active window if not specified
ToggleBorderlessWindow(id := 0)
{
	CoordMode Screen, Window
	static WINDOW_STYLE_UNDECORATED := -0xC40000
	static savedInfo := Object() ; Associative array
	if(!id) ;Not given id, so use active window
		WinGet, id, ID, A
	if (!savedInfo[id]) ;Has not been set yet, make borderless and full screen
	{
		savedInfo[id] := inf := Object()
		WinGet, tmpStyle, Style, ahk_id %id% ;Save style
		inf["style"] := tmpStyle
		
		WinGetPos, tmpX, tmpY, tmpWidth, tmpHeight, ahk_id %id% ;Save position
		inf["x"] := tmpX
		inf["y"] := tmpY
		inf["width"] := tmpWidth
		inf["height"] := tmpHeight
		
		WinSet, Style, %WINDOW_STYLE_UNDECORATED%, ahk_id %id% ;Remove titlebar and borders
		
		mon := GetMonitorAtPos(tmpX+tmpWidth/2, tmpY+tmpHeight/2) ;Get Monitor window(center) is on
		SysGet, mon, Monitor, %mon% ;Get size of selected monitor
		
		WinMove, ahk_id %id%,, %monLeft%, %monTop%, % monRight-monLeft, % monBottom-monTop ;Resize
	}
	else ;Already set, restore previous style, size, and position
	{
		inf := savedInfo[id]
		WinSet, Style, % inf["style"], ahk_id %id%
		WinMove, ahk_id %id%,, % inf["x"], % inf["y"], % inf["width"], % inf["height"]
		savedInfo[id] := ""
	}
}

GetMonitorAtPos(x,y)
{
	;; Monitor number at position x,y or -1 if x,y outside monitors.
	SysGet monitorCount, MonitorCount
	i := 1
	while(i <= monitorCount)
	{
		SysGet area, Monitor, %i%
		if ( x >= areaLeft && x <= areaRight && y >= areaTop && y <= areaBottom )
		{
			return i
		}
		i := i+1
	}
	return -1
}