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
	
	Method GetValue!()
		Return _value
	End Method
	
	Method SetValue(value!)
		_value = Min(Max(_min, value), _max)
	End Method
	
	Method GetMinimum!()
		Return _min
	End Method
	
	Method GetMaximum!()
		Return _max
	End Method
	
	Method SetMinimum(nmin!)
		_min = Min(nmin, _max)
		SetValue(_value)
		SetStep(.2 * (_min-_max))
	End Method
	
	Method SetMaximum(nmax!)
		_max = Max(nmax, _min)
		SetValue(_value)
		SetStep(.2 * (_min-_max))
	End Method
	
	Method SetStep(nstep!)
		_step = Min(Abs(nstep), _max-_min)
	End Method
	
	Method GetStep!()
		Return _step
	End Method
	
	Method OnScroll:Int(value!, prev!)
		'TODO
	End Method
End Type

Type NVScrollbar Extends NScrollbar
	Const BAR_WIDTH!=20
	Const VERTICAL_PAD!=4
	Global NVScrollbarDrawable:NDrawable = New NNinePatch.InitWithImageAndBorders(LoadAnimImage("res/vscroll.png", 64, 256, 0, 2), 0, 0, 46, 46, BAR_WIDTH/64)
	
	Field _dragging:Int=False
	Field _dragy%
	
	Method InitWithFrame:NVScrollbar(frame:NRect)
		Super.InitWithFrame(frame)
		Return Self
	End Method
	
	Method _BarSize#()
		Return Max(24, (_step/(_max-_min))*(Bounds(_temp_rect).size.height-VERTICAL_PAD*2))
	End Method
	
	Method _BarPos#()
		Return (_value/(_max-_min))*(Bounds(_temp_rect).size.height-_BarSize()-VERTICAL_PAD*2)
	End Method
	
	Method SetFrame(frame:NRect)
		_temp_rect.CopyValues(frame)
		_temp_rect.size.width = BAR_WIDTH
		Super.SetFrame(_temp_rect)
	End Method
	
	Method _setValueForY(y!)
		Local sz#=_BarSize()
		SetValue((((y-_dragy)-Double(sz*.5))/(Bounds(_temp_rect).size.height-sz-VERTICAL_PAD*2))*(_max-_min)+_min)
	End Method
	
	Method MousePressed:NView(x%, y%)
		Local sz# = _BarSize()
		Local pos# = _BarPos()
		
		y :- VERTICAL_PAD
		
		_temp_rect.Set(0, pos, BAR_WIDTH, sz)
		If Not _temp_rect.Contains(x, y) Then
			_dragy=0
			_setValueForY(y)
		Else
			_dragy = y-(pos+sz*.5)
		EndIf
		_dragging = true
		
		Return Self
	End Method
	
	Method MouseMoved:NView(x%, y%, dx%, dy%)
		If _dragging Then
			y :- VERTICAL_PAD
			_setValueForY(y)
		EndIf
	End Method
	
	Method MouseReleased:Int(x%, y%)
		_setValueForY(y-VERTICAL_PAD)
		_dragging = False
	End Method
	
	Method Draw()
		
		Local bounds:NRect = Bounds(_temp_rect)
		NVScrollbarDrawable.DrawRect(0, 0, BAR_WIDTH, bounds.size.height, 0)
		Local barsize# = _BarSize()
		Local barpos# = _BarPos()+VERTICAL_PAD
		NVScrollbarDrawable.DrawRect(0, barpos, BAR_WIDTH, barsize, 1)
		
		Super.Draw()
		
	End Method
End Type

Type NHScrollbar Extends NScrollbar
	Global NHScrollbarDrawable:NDrawable
	
	Method InitWithFrame:NHScrollbar(frame:NRect)
		Super.InitWithFrame(frame)
		Return Self
	End Method
End Type
