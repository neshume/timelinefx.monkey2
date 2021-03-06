#rem
	TimelineFX Module by Peter Rigby
	
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
#end
Class tlSpawnComponent Extends tlComponent
	
	Field emitter:tlEmitter
	Field parenteffect:tlEffect

	Method New()
		Super.New()
	End Method
	
	Method Update() Override
	End
	
	Method Destroy() Override
		emitter = Null
		parenteffect = Null
		Super.Destroy()
	End

	Method New(name:String, effect:tlEffect, emitter:tlEmitter)
		Self.emitter = emitter
		parenteffect = effect
		Self.Name = name
	End
	
	Method Setup(e:tlParticle) Virtual
	End
	
	Method CopyToClone(copy:tlSpawnComponent, Effect:tlEffect, Emitter:tlEmitter)
		copy.Name = Name
		copy.parenteffect = Effect
		copy.emitter = Emitter
	End
	
	Method Clone:tlSpawnComponent(Effect:tlEffect = Null, Emitter:tlEmitter = Null) Virtual
		Local copy:tlSpawnComponent = New tlSpawnComponent
		CopyToClone(copy, Effect, Emitter)
		Return copy
	End

End
#Rem monkeydoc @hidden
#end
Class tlSpawnComponent_Speed Extends tlSpawnComponent
	Method New()
		Super.New()
	End

	Method New(name:String, effect:tlEffect, emitter:tlEmitter)
		Super.New(name, effect, emitter)
	End
	
	Method Setup(e:tlParticle) Override
		e.speed_vec = New tlVector2
		e.speed = emitter.velocity_component.c_nodes.changes[0]
		e.velvariation = Rnd(-emitter.currentvelocityvariation, emitter.currentvelocityvariation)
		e.basespeed = (emitter.currentbasespeed + e.velvariation) * parenteffect.currentvelocity
		e.velseed = Rnd(0, 1.0)
		e.speed = emitter.velocity_component.c_nodes.changes[0] * e.basespeed * emitter.globalvelocity_component.c_nodes.changes[0]
	End
	
	Method Clone:tlSpawnComponent(Effect:tlEffect = Null, Emitter:tlEmitter = Null) Override
		Local copy:tlSpawnComponent_Speed = New tlSpawnComponent_Speed
		CopyToClone(copy, Effect, Emitter)
		Return copy
	End

End
#Rem monkeydoc @hidden
#end
Class tlSpawnComponent_Spin Extends tlSpawnComponent
	Method New()
		Super.New()
	End

	Method New(name:String, effect:tlEffect, emitter:tlEmitter)
		Super.New(name, effect, emitter)
	End
	
	Method Setup(e:tlParticle) Override
		e.spinvariation = Rnd(-emitter.currentspinvariation, emitter.currentspinvariation) + emitter.currentbasespin
		If Not (emitter.LockAngle And emitter.AngleType = tlANGLE_ALIGN)
			e.spin = (emitter.spin_component.c_nodes.changes[0] * e.spinvariation * parenteffect.currentspin) / tp_CURRENT_UPDATE_TIME
		End If
	End
	
	Method Clone:tlSpawnComponent(Effect:tlEffect = Null, Emitter:tlEmitter = Null) Override
		Local copy:tlSpawnComponent_Spin = New tlSpawnComponent_Spin
		CopyToClone(copy, Effect, Emitter)
		Return copy
	End

End
#Rem monkeydoc @hidden
#end
Class tlSpawnComponent_Weight Extends tlSpawnComponent
	Method New()
		Super.New()
	End

	Method New(name:String, effect:tlEffect, emitter:tlEmitter)
		Super.New(name, effect, emitter)
	End
	
	Method Setup(e:tlParticle) Override
		e.weightvariation = Rnd(-emitter.currentweightvariation, emitter.currentweightvariation)
		e.baseweight = (emitter.currentbaseweight + e.weightvariation) * parenteffect.currentweight
		e.weight = e.baseweight * emitter.weight_component.c_nodes.changes[0]
	End
	
	Method Clone:tlSpawnComponent(Effect:tlEffect = Null, Emitter:tlEmitter = Null) Override
		Local copy:tlSpawnComponent_Weight = New tlSpawnComponent_Weight
		CopyToClone(copy, Effect, Emitter)
		Return copy
	End

End
#Rem monkeydoc @hidden
#end
Class tlSpawnComponent_DirectionVariation Extends tlSpawnComponent
	Method New()
		Super.New()
	End

	Method New(name:String, effect:tlEffect, emitter:tlEmitter)
		Super.New(name, effect, emitter)
	End
	
	Method Setup(e:tlParticle) Override
		e.directionvariaion = emitter.currentdirectionvariation
		Local dv:Float = e.directionvariaion * emitter.dvovertime_component.c_nodes.changes[0]
		e.direction = e.emissionangle + emitter.direction_component.c_nodes.changes[0] + Rnd(-dv, dv)
	End
	
	Method Clone:tlSpawnComponent(Effect:tlEffect = Null, Emitter:tlEmitter = Null) Override
		Local copy:tlSpawnComponent_DirectionVariation = New tlSpawnComponent_DirectionVariation
		CopyToClone(copy, Effect, Emitter)
		Return copy
	End

End
#Rem monkeydoc @hidden
#end
Class tlSpawnComponent_Emission Extends tlSpawnComponent
	Method New()
		Super.New()
	End

	Method New(name:String, effect:tlEffect, emitter:tlEmitter)
		Super.New(name, effect, emitter)
	End

	Field diralternater:Int
	
	Method Setup(e:tlParticle) Override
		If parenteffect.EffectClass <> tlPOINT_EFFECT
			Select parenteffect.EmissionType
				Case tlEMISSION_INWARDS
					e.emissionangle = emitter.currentemissionangle 
					If e.Relative
						e.emissionangle += GetDirection(e.LocalVector.x, e.LocalVector.y, 0, 0)
					Else
						e.emissionangle += GetDirection(e.WorldVector.x, e.WorldVector.y, emitter.WorldVector.x, emitter.WorldVector.y)
					End If
				Case tlEMISSION_OUTWARDS
					e.emissionangle = emitter.currentemissionangle
					If e.Relative
						e.emissionangle += GetDirection(0, 0, e.LocalVector.x, e.LocalVector.y)
					Else
						e.emissionangle += GetDirection(emitter.WorldVector.x, emitter.WorldVector.y, e.WorldVector.x, e.WorldVector.y)
					End If
				Case tlEMISSION_IN_AND_OUT
					e.emissionangle = emitter.currentemissionangle
					If diralternater
						If e.Relative
							e.emissionangle+=GetDirection(0, 0, e.LocalVector.x, e.LocalVector.y)
						Else
							e.emissionangle+=GetDirection(emitter.WorldVector.x, emitter.WorldVector.y, e.WorldVector.x, e.WorldVector.y)
						End If
					Else
						If e.Relative
							e.emissionangle+=GetDirection(e.LocalVector.x, e.LocalVector.y, 0, 0)
						Else
							e.emissionangle+=GetDirection(e.WorldVector.x, e.WorldVector.y, emitter.WorldVector.x, emitter.WorldVector.y)
						End If
					End If
					diralternater = Not diralternater
				Case tlEMISSION_SPECIFIED
					e.emissionangle = emitter.currentemissionangle
			End Select
		Else
			e.emissionangle = emitter.currentemissionangle
		End If
	End
	
	Method Clone:tlSpawnComponent(Effect:tlEffect = Null, Emitter:tlEmitter = Null) Override
		Local copy:tlSpawnComponent_Emission = New tlSpawnComponent_Emission
		CopyToClone(copy, Effect, Emitter)
		Return copy
	End

End
#Rem monkeydoc @hidden
#end
Class tlSpawnComponent_EmissionRange Extends tlSpawnComponent
	Method New()
		Super.New()
	End

	Method New(name:String, effect:tlEffect, emitter:tlEmitter)
		Super.New(name, effect, emitter)
	End
	
	Method Setup(e:tlParticle) Override
		e.emissionangle += Rnd(-emitter.currentemissionrange, emitter.currentemissionrange)
	End
	
	Method Clone:tlSpawnComponent(Effect:tlEffect = Null, Emitter:tlEmitter = Null) Override
		Local copy:tlSpawnComponent_EmissionRange = New tlSpawnComponent_EmissionRange
		CopyToClone(copy, Effect, Emitter)
		Return copy
	End

End
#Rem monkeydoc @hidden
#end
Class tlSpawnComponent_Splatter Extends tlSpawnComponent
	Method New()
		Super.New()
	End

	Method New(name:String, effect:tlEffect, emitter:tlEmitter)
		Super.New(name, effect, emitter)
	End
	
	Method Setup(e:tlParticle) Override
		If emitter.currentsplatter
			Local splatx:Float = Rnd(-emitter.currentsplatter, emitter.currentsplatter)
			Local splaty:Float = Rnd(-emitter.currentsplatter, emitter.currentsplatter)
			While GetDistanceFast(0, 0, splatx, splaty) >= emitter.currentsplatter * emitter.currentsplatter
				splatx = Rnd(-emitter.currentsplatter, emitter.currentsplatter)
				splaty = Rnd(-emitter.currentsplatter, emitter.currentsplatter)
			Wend
			If emitter.Zoom = 1 Or e.Relative
				e.LocalVector = New tlVector2(splatx + e.LocalVector.x, splaty + e.LocalVector.y)
			Else
				e.LocalVector = New tlVector2(e.LocalVector.x + (splatx * emitter.Zoom), e.LocalVector.y + (splaty * emitter.Zoom))
			End If
		End If
	End
	
	Method Clone:tlSpawnComponent(Effect:tlEffect = Null, Emitter:tlEmitter = Null) Override
		Local copy:tlSpawnComponent_Splatter = New tlSpawnComponent_Splatter
		CopyToClone(copy, Effect, Emitter)
		Return copy
	End

End
#Rem monkeydoc @hidden
#end
Class tlSpawnComponent_TForm Extends tlSpawnComponent
	Method New()
		Super.New()
	End

	Method New(name:String, effect:tlEffect, emitter:tlEmitter)
		Super.New(name, effect, emitter)
	End
	
	Method Setup(e:tlParticle) Override
		e.TForm()
	End
	
	Method Clone:tlSpawnComponent(Effect:tlEffect = Null, Emitter:tlEmitter = Null) Override
		Local copy:tlSpawnComponent_TForm = New tlSpawnComponent_TForm
		CopyToClone(copy, Effect, Emitter)
		Return copy
	End

End
#Rem monkeydoc @hidden
#end
Class tlSpawnComponent_LockedAngle Extends tlSpawnComponent
	Method New()
		Super.New()
	End

	Method New(name:String, effect:tlEffect, emitter:tlEmitter)
		Super.New(name, effect, emitter)
	End
	
	Method Setup(e:tlParticle) Override
		e.direction = e.emissionangle + emitter.direction_component.c_nodes.changes[0]
		If parenteffect.TraverseEdge
			e.LocalRotation = parenteffect.WorldRotation + emitter.AngleOffset
		Else
			e.LocalRotation = -e.direction + emitter.WorldRotation + emitter.AngleOffset
		End If
	End
	
	Method Clone:tlSpawnComponent(Effect:tlEffect = Null, Emitter:tlEmitter = Null) Override
		Local copy:tlSpawnComponent_LockedAngle = New tlSpawnComponent_LockedAngle
		CopyToClone(copy, Effect, Emitter)
		Return copy
	End

End
#Rem monkeydoc @hidden
#end
Class tlSpawnComponent_Angle Extends tlSpawnComponent
	Method New()
		Super.New()
	End

	Method New(name:String, effect:tlEffect, emitter:tlEmitter)
		Super.New(name, effect, emitter)
	End
	
	Method Setup(e:tlParticle) Override
		e.direction = e.emissionangle + emitter.direction_component.c_nodes.changes[0]
		Select emitter.AngleType
			Case tlANGLE_ALIGN
				If parenteffect.TraverseEdge
					e.LocalRotation = parenteffect.WorldRotation + emitter.AngleOffset
				Else
					e.LocalRotation = -e.direction + emitter.AngleOffset
				End If
			Case tlANGLE_RANDOM
				e.LocalRotation = Rnd(emitter.AngleOffset)
			Case tlANGLE_SPECIFY
				e.LocalRotation = emitter.AngleOffset
		End Select
	End
	
	Method Clone:tlSpawnComponent(Effect:tlEffect = Null, Emitter:tlEmitter = Null) Override
		Local copy:tlSpawnComponent_Angle = New tlSpawnComponent_Angle
		CopyToClone(copy, Effect, Emitter)
		Return copy
	End

End
#Rem monkeydoc @hidden
#end
Class tlSpawnComponent_LifeVariation Extends tlSpawnComponent
	Method New()
		Super.New()
	End

	Method New(name:String, effect:tlEffect, emitter:tlEmitter)
		Super.New(name, effect, emitter)
	End
	
	Method Setup(e:tlParticle) Override
		e.lifetime = Max(Cast<Double>(0.0), (emitter.currentlife + Rnd(-emitter.currentlifevariation, emitter.currentlifevariation)) * parenteffect.currentlife)
	End
	
	Method Clone:tlSpawnComponent(Effect:tlEffect = Null, Emitter:tlEmitter = Null) Override
		Local copy:tlSpawnComponent_LifeVariation = New tlSpawnComponent_LifeVariation
		CopyToClone(copy, Effect, Emitter)
		Return copy
	End

End
#Rem monkeydoc @hidden
#end
Class tlSpawnComponent_Life Extends tlSpawnComponent
	Method New()
		Super.New()
	End

	Method New(name:String, effect:tlEffect, emitter:tlEmitter)
		Super.New(name, effect, emitter)
	End
	
	Method Setup(e:tlParticle) Override
		e.lifetime = emitter.currentlife * parenteffect.currentlife
	End
	
	Method Clone:tlSpawnComponent(Effect:tlEffect = Null, Emitter:tlEmitter = Null) Override
		Local copy:tlSpawnComponent_Life = New tlSpawnComponent_Life
		CopyToClone(copy, Effect, Emitter)
		Return copy
	End

End
#Rem monkeydoc @hidden
#end
Class tlSpawnComponent_SizeVariation Extends tlSpawnComponent
	Method New()
		Super.New()
	End

	Method New(name:String, effect:tlEffect, emitter:tlEmitter)
		Super.New(name, effect, emitter)
	End
	
	Method Setup(e:tlParticle) Override
		Local scaletemp:Float
		Local sizetempx:Float, sizetempy:Float
		If emitter.Uniform
			scaletemp = emitter.scalex_component.c_nodes.changes[0]
			e.scalevariationx = Rnd(emitter.currentsizexvariation)
			e.width = e.scalevariationx + emitter.currentbasesizex
			If scaletemp
				sizetempx = (e.width / e.sprite.Width) * scaletemp * e.gsizex
			Else
				sizetempx = 0
			End If
			e.SetScale(sizetempx, sizetempx)
			If e.speed And emitter.stretch_component.c_nodes.changes[0]
				e.ScaleVector = New tlVector2(e.ScaleVector.x, (emitter.scalex_component.c_nodes.changes[0] * e.gsizex * (e.width + (Abs(e.speed) * emitter.stretch_component.c_nodes.changes[0] * parenteffect.currentstretch))) / e.sprite.Width)
				If e.ScaleVector.y < e.ScaleVector.x e.ScaleVector = New tlVector2(e.ScaleVector.x, e.ScaleVector.x)
			End If
		Else
			'width
			scaletemp = emitter.scalex_component.c_nodes.changes[0]
			e.scalevariationx = Rnd(emitter.currentsizexvariation)
			e.width = e.scalevariationx + emitter.currentbasesizex
			If scaletemp
				sizetempx = (e.width / e.sprite.Width) * scaletemp * e.gsizex
			Else
				sizetempx = 0
			End If
			'height
			scaletemp = emitter.scaley_component.c_nodes.changes[0]
			e.scalevariationy = Rnd(emitter.currentsizeyvariation)
			e.height = e.scalevariationy + emitter.currentbasesizey
			If scaletemp
				sizetempy = (e.height / e.sprite.Height) * scaletemp * e.gsizey
			Else
				sizetempy = 0
			End If
			e.ScaleVector = New tlVector2(sizetempx, sizetempy)
			If e.speed And emitter.stretch_component.c_nodes.changes[0]
				e.ScaleVector = New tlVector2(e.ScaleVector.x, (emitter.scaley_component.c_nodes.changes[0] * e.gsizey * (e.height + (Abs(e.speed) * emitter.stretch_component.c_nodes.changes[0] * parenteffect.currentstretch))) / e.sprite.Height)
				If e.ScaleVector.y < e.ScaleVector.x e.ScaleVector = New tlVector2(e.ScaleVector.x, e.ScaleVector.x)
			End If
		End If
	End
	
	Method Clone:tlSpawnComponent(Effect:tlEffect = Null, Emitter:tlEmitter = Null) Override
		Local copy:tlSpawnComponent_SizeVariation = New tlSpawnComponent_SizeVariation
		CopyToClone(copy, Effect, Emitter)
		Return copy
	End

End
#Rem monkeydoc @hidden
#end
Class tlSpawnComponent_Size Extends tlSpawnComponent
	Method New()
		Super.New()
	End

	Method New(name:String, effect:tlEffect, emitter:tlEmitter)
		Super.New(name, effect, emitter)
	End
	
	Method Setup(e:tlParticle) Override
		Local scaletemp:Float
		Local sizetempx:Float, sizetempy:float
		If emitter.Uniform
			scaletemp = emitter.scalex_component.c_nodes.changes[0]
			e.scalevariationx = 0
			e.width = emitter.currentbasesizex
			If scaletemp
				sizetempx = (e.width / e.sprite.Width) * scaletemp * e.gsizex
			Else
				sizetempx = 0
			End If
			e.SetScale(sizetempx, sizetempx)
			If e.speed And emitter.stretch_component.c_nodes.changes[0]
				e.ScaleVector = New tlVector2(e.ScaleVector.x, (emitter.scalex_component.c_nodes.changes[0] * e.gsizex * (e.width + (Abs(e.speed) * emitter.stretch_component.c_nodes.changes[0] * parenteffect.currentstretch))) / e.sprite.Width)
				If e.ScaleVector.y < e.ScaleVector.x e.ScaleVector = New tlVector2(e.ScaleVector.x, e.ScaleVector.x)
			End If
		Else
			'width
			scaletemp = emitter.scalex_component.c_nodes.changes[0]
			e.scalevariationx = 0
			e.width = emitter.currentbasesizex
			If scaletemp
				sizetempx = (e.width / e.sprite.Width) * scaletemp * e.gsizex
			Else
				sizetempx = 0
			End If
			'height
			scaletemp = emitter.scaley_component.c_nodes.changes[0]
			e.scalevariationy = 0
			e.height = emitter.currentbasesizey
			If scaletemp
				sizetempy = (e.height / e.sprite.Height) * scaletemp * e.gsizey
			Else
				sizetempy = 0
			End If
			e.ScaleVector = New tlVector2(sizetempx, sizetempy)
			If e.speed And emitter.stretch_component.c_nodes.changes[0]
				e.ScaleVector = New tlVector2(e.ScaleVector.x, (emitter.scaley_component.c_nodes.changes[0] * e.gsizey * (e.height + (Abs(e.speed) * emitter.stretch_component.c_nodes.changes[0] * parenteffect.currentstretch))) / e.sprite.Height)
				If e.ScaleVector.y < e.ScaleVector.x e.ScaleVector = New tlVector2(e.ScaleVector.x, e.ScaleVector.x)
			End If
		End If
	End
	
	Method Clone:tlSpawnComponent(Effect:tlEffect = Null, Emitter:tlEmitter = Null) Override
		Local copy:tlSpawnComponent_Size = New tlSpawnComponent_Size
		CopyToClone(copy, Effect, Emitter)
		Return copy
	End

End