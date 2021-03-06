Rem
Copyright (c) 2010, Noel R. Cower
All rights reserved.

Redistribution and use in source and binary forms, with or without 
modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this 
   list of conditions and the following disclaimer.

 * Redistributions in binary form must reproduce the above copyright notice, 
   this list of conditions and the following disclaimer in the documentation 
   and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE 
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
EndRem

SuperStrict

Import "GUI.bmx"
Import "Ninepatch.bmx"

'32,25
Type NScrollbar Extends NView
	Field _min!=0, _max!=100, _value!=100
	Field _step!=20
	
	Field _dragging:Int=False
	Field _dragoff%
	
	Method Value!()
		Return _value
	End Method
	
	Method Percentage!()
		Return (_value-_min)/(_max-_min)
	End Method
	
	Method SetPercentage(per!)
		SetValue(_min+(per*(_max-_min)))
	End Method
	
	Method SetValue(value!)
		_value = Min(Max(_min, value), _max)
	End Method
	
	Method Minimum!()
		Return _min
	End Method
	
	Method Maximum!()
		Return _max
	End Method
	
	Method SetMinimum(nmin!)
		_min = Min(nmin, _max)
		SetValue(_value)
		SetScrollStep(_step)
	End Method
	
	Method SetMaximum(nmax!)
		_max = Max(nmax, _min)
		SetValue(_value)
		SetScrollStep(_step)
	End Method
	
	Method SetScrollStep(nstep!)
		_step = Min(Abs(nstep), _max-_min)
	End Method
	
	Method ScrollStep!()
		Return _step
	End Method
	
	Method OnScroll:Int(value!, prev!)
	End Method
	
	' Returns the complete length of the scrollbar (height in the case of vertical scrolling, width for horizontal)
	Method _ScrollLength#() Abstract
	
	Method _BarSize#()
		Return Floor(Max(24, (_step/(_max-_min))*(_ScrollLength()-BAR_PAD*2)))
	End Method
	
	Method _BarPos#()
		Return Floor(((_value-_min)/(_max-_min))*(_ScrollLength()-_BarSize()-BAR_PAD*2))
	End Method
	
	Method _SetValueForOffset(off!)
		Local sz#=_BarSize()
		Local prev! = _value
		SetValue((((off-_dragoff)-Double(sz*.5))/(_ScrollLength()-sz-BAR_PAD*2))*(_max-_min)+_min)
		OnScroll(_value, prev)
	End Method
End Type

Private

Const BAR_WIDTH!=16
Const BAR_PAD!=0

Public

Type NVScrollbar Extends NScrollbar
	Global NVScrollbarDrawable:NDrawable = New NNinePatchDrawable.InitWithImageAndBorders(LoadAnimImage("res/vscroll.png", 16, 64, 0, 2), 0, 0, 9, 9, 1)
	
	Method InitWithFrame:NVScrollbar(frame:NRect)
		Super.InitWithFrame(frame)
		Return Self
	End Method
	
	Method SetFrame(frame:NRect)
		_temp_rect.CopyValues(frame)
		_temp_rect.size.width = BAR_WIDTH
		Super.SetFrame(_temp_rect)
	End Method
	
	Method MousePressed(button%, x%, y%)
		If _max-_min <= _step Then
			Super.MousePressed(button, x, y)
			Return
		EndIf
		
		If button = 1 Then
			Local sz# = _BarSize()
			Local pos# = _BarPos()
		
			y :- BAR_PAD
		
			_temp_rect.Set(0, pos, BAR_WIDTH, sz)
			If Not _temp_rect.Contains(x, y) Then
				_dragoff=0
				_SetValueForOffset(y)
			Else
				_dragoff = y-(pos+sz*.5)
			EndIf
			_dragging = true
		
			Return
		EndIf
		
		Super.MousePressed(button, x, y)
	End Method
	
	Method MouseMoved(x%, y%, dx%, dy%)
		If _dragging Then
			_SetValueForOffset(y-BAR_PAD)
			Return
		EndIf
		
		Super.MouseMoved(x, y, dx, dy)
	End Method
	
	Method MouseReleased:Int(button%, x%, y%)
		If button = 1 And _dragging Then
			_SetValueForOffset(y-BAR_PAD)
			_dragging = False
		EndIf
	End Method
	
	Method Draw()
		Local bounds:NRect = Bounds(_temp_rect)
		NVScrollbarDrawable.DrawRect(0, 0, BAR_WIDTH, bounds.size.height, 0)
		If _step < _max-_min Then
			Local barsize# = _BarSize()
			Local barpos# = _BarPos()+BAR_PAD
			NVScrollbarDrawable.DrawRect(0, barpos, BAR_WIDTH, barsize, 1)
		EndIf
	End Method
	
	Method _ScrollLength#()
		Return Bounds(_temp_rect).size.height
	End Method
End Type

Type NHScrollbar Extends NScrollbar
	Global NHScrollbarDrawable:NDrawable = New NNinePatchDrawable.InitWithImageAndBorders(LoadAnimImage("res/hscroll.png", 64, 16, 0, 2), 9, 9, 0, 0, 1)
	
	Method InitWithFrame:NHScrollbar(frame:NRect)
		Super.InitWithFrame(frame)
		Return Self
	End Method
	
	Method SetFrame(frame:NRect)
		_temp_rect.CopyValues(frame)
		_temp_rect.size.height = BAR_WIDTH
		Super.SetFrame(_temp_rect)
	End Method
	
	Method MousePressed(button%, x%, y%)
		If _max-_min <= _step Then
			MousePressed(button, x, y)
			Return
		EndIf
		
		If button = 1 Then
			Local sz# = _BarSize()
			Local pos# = _BarPos()
		
			x :- BAR_PAD
		
			_temp_rect.Set(pos, 0, sz, BAR_WIDTH)
			If Not _temp_rect.Contains(x, y) Then
				_dragoff=0
				_SetValueForOffset(x)
			Else
				_dragoff = x-(pos+sz*.5)
			EndIf
			_dragging = true
		
			Return
		EndIf
	End Method
	
	Method MouseMoved(x%, y%, dx%, dy%)
		If _dragging Then
			_SetValueForOffset(x-BAR_PAD)
			Return
		EndIf
		
		Super.MouseMoved(x, y, dx, dy)
	End Method
	
	Method MouseReleased:Int(button%, x%, y%)
		If button = 1 And _dragging Then
			_SetValueForOffset(x-BAR_PAD)
			_dragging = False
		EndIf
	End Method
	
	Method Draw()
		Local bounds:NRect = Bounds(_temp_rect)
		NHScrollbarDrawable.DrawRect(0, 0, bounds.size.width, BAR_WIDTH, 0)
		If _step < _max-_min Then
			Local barsize# = _BarSize()
			Local barpos# = _BarPos()+BAR_PAD
			NHScrollbarDrawable.DrawRect(barpos, 0, barsize, BAR_WIDTH, 1)
		EndIf
	End Method
	
	Method _ScrollLength#()
		Return Bounds(_temp_rect).size.width
	End Method
End Type
