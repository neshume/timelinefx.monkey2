#Rem
	Copyright (c) 2012 Peter J Rigby
	
	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:
	
	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	THE SOFTWARE.

#END

Namespace timelinefx

Using timelinefx..

#Rem monkeydoc @hidden
#End
Class tlAttributeNode

	Private
	
	Field iscurve:Int
	
	Public
	
	Field frame:Float
	Field value:Float
	
	Field c0x:Float
	Field c0y:Float
	Field c1x:Float
	Field c1y:Float

	Method New()
	End
	
	Method New(frame:Float, value:Float)
		Self.frame = frame
		Self.value = value
	End Method
	
	Method Compare:Int(obj:Object)
		If Cast<tlAttributeNode>(obj)
			Return Sgn(frame - Cast<tlAttributeNode>(obj).frame)
		End If
		Return - 1
	End Method
	#Rem
	bbdoc: Set the curve points for the emitterchange
	about: x0 and y0 are the coordinates of the point to the left of the attribute node, x1 and y1 are the coordinates to the right of the attribute node. Setting
	these will create a bezier curve. The bezier curves are restricted so that they cannot be drawn so that they loop over or behind the frame of the attribute nodes.
	#END
	Method SetCurvePoints(x0:Float, y0:Float, x1:Float, y1:Float)
		c0x = x0
		c0y = y0
		c1x = x1
		c1y = y1
		isCurve = True
	End Method
	#Rem
	bbdoc: Toggle whether this attribute node is curved or linear
	#END
	Method ToggleCurve()
		iscurve = Not iscurve
	End Method
	
	Property isCurve:Int() 
		Return iscurve
	Setter(v:int)
		iscurve = v
	End
	
End

#Rem monkeydoc @hidden
#End
Class tlEmitterArray
	Field changes:Float[]
	Field lastframe:Int
	Field life:Int
	
	Method New(frames:Int)
		changes = New Float[frames]
		lastframe = frames - 1
	End Method
	
	Method GetLastFrame:Int()
		Return lastframe
	End Method
End
