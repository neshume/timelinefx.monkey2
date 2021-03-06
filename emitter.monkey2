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

#Rem monkeydoc Emitter Class.
	More docs to come soon as this is still missing some methods to build effects within code (you can still use the editor though)
#end
Class tlEmitter Extends tlFXObject
	'lists
	Private
	
	Field effects:List<tlEffect>
	
	'emitter settings
	Field particlerelative:Int
	Field randomcolor:Int
	Field layer:Int
	Field singleparticle:Int
	Field animate:Int
	Field animateonce:Int
	Field frame:Int
	Field randomstartframe:Int
	Field animationdirection:Int
	Field uniform:Int
	Field angletype:Int
	Field angleoffset:Float
	Field lockangle:Int
	Field anglerelative:Int
	Field useeffectemission:Int
	Field colorrepeat:Int
	Field alpharepeat:Int
	Field oneshot:Int
	Field groupparticles:Int
	
	'The particle sprite
	Field sprite:tlShape
	
	Field run_uniform:Int
	Field run_scalex:Int
	Field run_scaley:Int
	Field run_velocity:Int
	Field run_stretch:Int
	Field run_globalvelocity:Int
	Field run_alpha:Int
	Field run_colour:Int
	Field run_direction:Int
	Field run_dvovertime:Int
	Field run_spin:Int
	Field run_weight:Int
	Field run_framerate:Int
	
	'Components that setup a particle when it spawns
	Field spawncomponents:List<tlSpawnComponent>
	
	'editor settings
	Field visible:Int = True
	
	'Other Settings
	Field tweenspawns:Int
	
	'Hierarchy
	Field parenteffect:tlEffect
	
	Public
	
	'Temp variables
	#Rem monkeydoc @hidden
	#End
	Field currentbasespeed:Float
	#Rem monkeydoc @hidden
	#End
	Field currentbaseweight:Float
	#Rem monkeydoc @hidden
	#End
	Field currentbasesizex:Float
	#Rem monkeydoc @hidden
	#End
	Field currentbasesizey:Float
	#Rem monkeydoc @hidden
	#End
	Field currentbasespin:Float
	#Rem monkeydoc @hidden
	#End
	Field currentsplatter:Float
	#Rem monkeydoc @hidden
	#End
	Field currentlifevariation:Float
	#Rem monkeydoc @hidden
	#End
	Field currentamountvariation:Float
	#Rem monkeydoc @hidden
	#End
	Field currentvelocityvariation:Float
	#Rem monkeydoc @hidden
	#End
	Field currentweightvariation:Float
	#Rem monkeydoc @hidden
	#End
	Field currentsizexvariation:Float
	#Rem monkeydoc @hidden
	#End
	Field currentsizeyvariation:Float
	#Rem monkeydoc @hidden
	#End
	Field currentspinvariation:Float
	#Rem monkeydoc @hidden
	#End
	Field currentdirectionvariation:Float
	#Rem monkeydoc @hidden
	#End
	Field currentalphaovertime:Float
	#Rem monkeydoc @hidden
	#End
	Field currentvelocityovertime:Float
	#Rem monkeydoc @hidden
	#End
	Field currentweightovertime:Float
	#Rem monkeydoc @hidden
	#End
	Field currentscalexovertime:Float
	#Rem monkeydoc @hidden
	#End
	Field currentscaleyovertime:Float
	#Rem monkeydoc @hidden
	#End
	Field currentspinovertime:Float
	#Rem monkeydoc @hidden
	#End
	Field currentdirection:Float
	#Rem monkeydoc @hidden
	#End
	Field currentdirectionvariationot:Float
	#Rem monkeydoc @hidden
	#End
	Field currentframerateovertime:Float
	#Rem monkeydoc @hidden
	#End
	Field currentstretchovertime:Float
	#Rem monkeydoc @hidden
	#End
	Field currentredovertime:Float
	#Rem monkeydoc @hidden
	#End
	Field currentgreenovertime:Float
	#Rem monkeydoc @hidden
	#End
	Field currentblueovertime:Float
	#Rem monkeydoc @hidden
	#End
	Field currentglobalvelocity:Float
	#Rem monkeydoc @hidden
	#End
	Field currentemissionangle:Float
	#Rem monkeydoc @hidden
	#End
	Field currentemissionrange:Float
	#Rem monkeydoc @hidden
	#End
	
	'Quick acccess variables to graph components
	Field scalex_component:tlEC_ScaleXOvertime
	#Rem monkeydoc @hidden
	#End
	Field scaley_component:tlEC_ScaleYOvertime
	#Rem monkeydoc @hidden
	#End
	Field uscale_component:tlEC_UniformScale
	#Rem monkeydoc @hidden
	#End
	Field velocity_component:tlEC_VelocityOvertime
	#Rem monkeydoc @hidden
	#End
	Field stretch_component:tlEC_StretchOvertime
	#Rem monkeydoc @hidden
	#End
	Field globalvelocity_component:tlEC_GlobalVelocity
	#Rem monkeydoc @hidden
	#End
	Field alpha_component:tlEC_AlphaOvertime
	#Rem monkeydoc @hidden
	#End
	Field red_component:tlEC_RedOvertime
	#Rem monkeydoc @hidden
	#End
	Field green_component:tlEC_GreenOvertime
	#Rem monkeydoc @hidden
	#End
	Field blue_component:tlEC_BlueOvertime
	#Rem monkeydoc @hidden
	#End
	Field direction_component:tlEC_DirectionOvertime
	#Rem monkeydoc @hidden
	#End
	Field dvovertime_component:tlEC_DirectionVariationOvertime
	#Rem monkeydoc @hidden
	#End
	Field spin_component:tlEC_SpinOvertime
	#Rem monkeydoc @hidden
	#End
	Field weight_component:tlEC_WeightOvertime
	#Rem monkeydoc @hidden
	#End
	Field framerate_component:tlEC_FramerateOvertime

	'properties		
	#Rem monkeydoc Get the current parent effect
	#End
	Property ParentEffect:tlEffect()
		Return parenteffect
	Setter(v:tlEffect)
		parenteffect = v
	End
	#Rem monkeydoc @hidden
	#End
	Property RunVelocity:Int()
		Return run_velocity
	Setter(v:Int)
		run_velocity = v
	End
	#Rem monkeydoc Get the List of sub effects within this emitter.
	#End
	Property Effects:List<tlEffect>()
		Return effects
	End
	#Rem monkeydoc Get/Set the [[tlShape]] assigned to this emitter
	#End
	Property Sprite:tlShape()
		Return sprite
	Setter(v:tlShape)
		sprite = v
	End
	#Rem monkeydoc Get whether particles are being spawned from the old effect coordinates to the new.
		@return Either TRUE or FALSE
	#End
	Property TweenSpawns:Int()
		Return tweenspawns
	Setter(v:Int)
		tweenspawns = v
	End
	#Rem monkeydoc Get/Set the visibility status of the emitter
	#End
	Property Visible:Int()
		Return visible
	Setter(v:Int)
		visible = v
	End
	#Rem monkeydoc @hidden
	#End
	Property SpawnComponents:List<tlSpawnComponent>()
		Return spawncomponents
	Setter(v:List<tlSpawnComponent>)
		spawncomponents = v
	End

	#Rem monkeydoc [[tlEmitter]] Constructor
	#End
	Method New()
		AddComponent(New tlEmitterCoreComponent("Core"))
		spawncomponents = New List<tlSpawnComponent>
		effects = New List<tlEffect>
		DoNotRender = True
	End
	#Rem monkeydoc Destroy the emitter and safely ceanup objects
	#End
	Method Destroy()
		parenteffect = Null
		Image = Null
		Sprite = Null
		If effects
			For Local e:tlEffect = EachIn effects
				e.Destroy()
			Next
		End If
		effects = Null
		If spawncomponents
			For Local c:tlSpawnComponent = EachIn spawncomponents
				c.Destroy()
			Next
		End If
		spawncomponents = Null
		scalex_component.Destroy()
		scaley_component.Destroy()
		If uscale_component uscale_component.Destroy()
		stretch_component.Destroy()
		velocity_component.Destroy()
		globalvelocity_component.Destroy()
		alpha_component.Destroy()
		red_component.Destroy()
		green_component.Destroy()
		blue_component.Destroy()
		direction_component.Destroy()
		dvovertime_component.Destroy()
		spin_component.Destroy()
		weight_component.Destroy()
		framerate_component.Destroy()
		Super.Destroy()
	End
	
	'Emitter Settings Getters
	#Rem monkeydoc Get/Set whether the particles spawned by this emitter remain relative to the containg effect.
	#End	
	Property ParticleRelative:Int()
		Return particlerelative
	Setter (v:Int)
		particlerelative = v
	End
	#Rem monkeydoc Sets whether the particle chooses a random colour from the colour attributes.
	#End	
	Property RandomColor:Int()
		Return randomcolor
	Setter (v:Int)
		randomcolor = v
	End
	#Rem monkeydoc Set the z layer.
		Emitters can be set to draw on different layers depending on what kind of effect you need. By default everything is drawn on layer 0, higher layers
		makes those particles spawned by that emitter drawn on top of emitters below them in layers. The layer value can range from 0-8 giving a total of 9 layers.
	#End	
	Property Layer:Int()
		Return layer
	Setter (v:Int)
		layer = v
	End
	#Rem monkeydoc Get/Set Single Particle.
		You can have particles that do not age and will only be spawned once for point emitters, or just for one frame with area, line and ellipse emitters.
		Single particles will remain until they are destroyed and will one behave according the values stored in the first temmiterchange nodes - in otherwords they
		will not change at all over time.
	#End	
	Property SingleParticle:Int()
		Return singleparticle
	Setter (v:Int)
		singleparticle = v
	End
	#Rem monkeydoc Get/Set whether the particle should animate.
		Only applies if the particle's image has more then one frame of animation.
	#End	
	Property Animating:Int()
		Return animate
	Setter (v:Int)
		animate = v
	End
	#Rem monkeydoc Get/Set whether the particle should run through the animation sequence once only.
		Only applies if the particle's image has more then one frame of animation.
	#End	
	Property AnimateOnce:Int()
		Return animateonce
	Setter (v:Int)
		animateonce = v
	End
	#Rem monkeydoc Get/Set the image frame.
		If the image has more then one frame then setting this can determine which frame the particle uses to draw itself.
	#End	
	Property Frame:Int()
		Return frame
	Setter (v:Int)
		frame = v
	End
	#Rem monkeydoc Get/Set the particles to spawn with a random frame.
		Only applies if the particle has more then one frame of animation
	#End	
	Property RandomStartFrame:Int()
		Return randomstartframe
	Setter (v:Int)
		randomstartframe = v
	End
	#Rem monkeydoc Set the direction the animation plays in.
		Set to 1 for forwards playback and set to -1 for reverse playback of the image animation
	#End	
	Property AnimationDirection:Int()
		Return animationdirection
	Setter (v:Int)
		animationdirection = v
	End
	#Rem monkeydoc Get/Set Uniform.
		Dictates whether the particles size scales uniformally. Set to either TRUE or FALSE.
	#End	
	Property Uniform:Int()
		Return uniform
	Setter (v:Int)
		uniform = v
	End
	#Rem monkeydoc Set the angle type.
		Angle type tells the particle how it show orientate itself when spawning. Either tlANGLE_ALIGN, tlANGLE_RANDOM or tlANGLE_SPECIFY.
		*tlANGLE_ALIGN: Force the particle to align itself with the direction that it's travelling in.
		*tlANGLE_RANDOM: Choose a random angle.
		*tlANGLE_SPECIFY: Specify the angle that the particle spawns with.
		Use [[AngleOffset]] to control the either both the specific angle, random range of angles and an offset if aligning.
	#End	
	Property AngleType:Int()
		Return angletype
	Setter (v:Int)
		angletype = v
	End
	#Rem monkeydoc Set the angle offset or variation.
		Depending on the value of [[AngleType]] (tlANGLE_ALIGN, tlANGLE_RANDOM or tlANGLE_SPECIFY), this will either set the angle offset of the particle in the 
		case of tlANGLE_ALIGN and tlANGLE_SPECIFY, or act as the range of degrees for tlANGLE_RANDOM.
	#End	
	Property AngleOffset:Float()
		Return angleoffset
	Setter (v:Float)
		angleoffset = v
	End
	#Rem monkeydoc Get/Set to TRUE to make the particles spawned have their angle of rotation locked to direction.
	#End	
	Property LockAngle:Int()
		Return lockangle
	Setter (v:Int)
		lockangle = v
	End
	#Rem monkeydoc Set to TRUE to make th particles spawned have their angle of rotation relative to the parent effect.
	#End	
	Property AngleRelative:Int()
		Return anglerelative
	Setter (v:Int)
		anglerelative = v
	End
	#Rem monkeydoc Set Use effect emission.
		Set to TRUE by default, this tells the emitter to take the emission range and emission angle attributes from the parent effect, otherwise if set to FALSE it
		will take the values from the emitters own emission attributes.
	#End	
	Property UseEffectEmission:Int()
		Return useeffectemission
	Setter (v:Int)
		useeffectemission = v
	End
	#Rem monkeydoc Set to the number of times the colour should cycle within the particle lifetime.
		Timeline Particles editor allows values from 1 to 10. 1 is the default.
	#End	
	Property ColorRepeat:Int()
		Return colorrepeat
	Setter (v:Int)
		colorrepeat = v
	End
	#Rem monkeydoc Set to the number of times the alpha of the particle should cycle within the particle lifetime.
		Timeline Particles editor allows values from 1 to 10. 1 is the default.
	#End	
	Property AlphaRepeat:Int()
		Return alpharepeat
	Setter (v:Int)
		alpharepeat = v
	End
	#Rem monkeydoc Make a particle a one shot particle or not.
		Emitters that have this set to true will only spawn one particle and that particle will just play out once and die. This is only relevant if
		[[SingleParticle]] is also set to true.
	#End	
	Property OneShot:Int()
		Return oneshot
	Setter (v:Int)
		oneshot = v
	End
	#Rem monkeydoc Sets the current state of whether spawned particles are added to the particle managers pool, or the emitters own pool.
		True means that	they're grouped together under each emitter
	#End	
	Property GroupParticles:Int()
		Return groupparticles
	Setter (v:Int)
		groupparticles = v
	End
	
	'Base attribute setters
	#Rem monkeydoc Set the base width of the particle
	#End	
	Method SetBaseWidth(v:Float)
		currentbasesizex = v
	End
	#Rem monkeydoc Set the base height of the particle
	#End	
	Method SetBaseHeight(v:Float)
		currentbasesizey = v
	End
	#Rem monkeydoc Set the base width and height of the particle
	#End	
	Method SetBaseSize(v:Float)
		currentbasesizex = v
		currentbasesizey = v
	End
	#Rem monkeydoc Set the base width variation of the particle
	#End	
	Method SetBaseWidthVariation(v:Float)
		currentsizexvariation = v
	End
	#Rem monkeydoc Set the base height variation of the particle
	#End	
	Method SetBaseHeightVariation(v:Float)
		currentsizeyvariation = v
	End
	#Rem monkeydoc Set the base width and height variation of the particle
	#End	
	Method SetBaseSizeVariation(v:Float)
		currentsizexvariation = v
		currentsizeyvariation = v
	End
	
	#Rem monkeydoc Add an effect to the emitters list of effects.
		about: Effects that are in the effects list are basically sub effects that are added to any particles that this emitter spawns which in turn should
		contain their own emitters that spawn more particles and so on.</p>
	#END
	Method AddEffect(e:tlEffect)
		effects.AddLast(e)
	End
	#Rem monkeydoc Get the parenteffect value in this [[tlEmitter]].
	#END
	Method GetParentEffect:tlEffect()
		Return parenteffect
	End
	#Rem monkeydoc Set the parenteffect value for this [[tlEmitter]].
	#END
	Method SetParentEffect(v:tlEffect)
		parenteffect = v
	End
	#Rem monkeydoc Update the Emitter
	#END
	Method Update()
		Capture()
		
		'transform the object
		TForm()
			
		'update the children		
		UpdateChildren()
					
		'update components
		UpdateComponents()
		
		If Parent
			If ContainingBox
				Parent.UpdateContainingBox(ContainingBox.tl_corner.x, ContainingBox.tl_corner.y, ContainingBox.br_corner.x, ContainingBox.br_corner.y)
			Else
				Parent.UpdateContainingBox(WorldVector.x, WorldVector.y, WorldVector.x, WorldVector.y)
			End If
		End If
		
		If UpdateContainerBox ReSizeContainingBox()

		UpdateImageBox()
	End

	'Compilers
	#Rem monkeydoc @hidden
	#End
	Method CompileAll()
		For Local graph:tlComponent = EachIn Components
			If Cast<tlGraphComponent>(graph)
				Select  Cast<tlGraphComponent>(graph).GraphType
					Case tlNORMAL_GRAPH
						 Cast<tlGraphComponent>(graph).Compile()
					Case tlOVERTIME_GRAPH
						 Cast<tlGraphComponent>(graph).Compile_Overtime()
				End Select
			End If
		Next
		
		scalex_component.Compile_Overtime()
		scaley_component.Compile_Overtime()
		stretch_component.Compile_Overtime()
		velocity_component.Compile_Overtime()
		globalvelocity_component.Compile()
		alpha_component.Compile_Overtime()
		red_component.Compile_Overtime()
		green_component.Compile_Overtime()
		blue_component.Compile_Overtime()
		direction_component.Compile_Overtime()
		dvovertime_component.Compile_Overtime()
		spin_component.Compile_Overtime()
		weight_component.Compile_Overtime()
		framerate_component.Compile_Overtime()
		
		'add the overtime graphs to the particle compenents as necessary, depending on whether there's more then one node on the graph
		If spin_component.c_nodes.lastframe And Not (lockangle And angletype = tlANGLE_ALIGN)
			run_spin = True
		End If
		If scalex_component.c_nodes.lastframe
			If uniform
				uscale_component = New tlEC_UniformScale()
				scalex_component.CopyToClone(uscale_component, parenteffect, Self)
				uscale_component.Name = "UniformScale"
				run_uniform = True
			Else
				run_scalex = True
			End If
		End If
		If scaley_component.c_nodes.lastframe And Not uniform
			run_scaley = True
		End If
		currentdirection = direction_component.c_nodes.changes[0]
		If direction_component.c_nodes.lastframe Or parenteffect.TraverseEdge And parenteffect.EffectClass = tlLINE_EFFECT
			run_direction = True
		End If
		Local isvelocitycomponent:Int
		If velocity_component.c_nodes.lastframe Or globalvelocity_component.c_nodes.lastframe Or globalvelocity_component.c_nodes.changes[0] <> 1
			isvelocitycomponent = True
			run_velocity = True
		End If
		If globalvelocity_component.c_nodes.lastframe Or globalvelocity_component.c_nodes.changes[0] <> 1
			run_globalvelocity = True
			run_velocity = True
		End If
		If GetComponent("DirectionVariation") Or currentdirectionvariation
			If dvovertime_component.c_nodes.lastframe Or dvovertime_component.c_nodes.changes[0]
				If Not direction_component.c_nodes.lastframe
					run_direction = True
				End If
				run_dvovertime = True
			End If
		End If
		If alpha_component.c_nodes.lastframe Or parenteffect.GetComponent("Alpha") Or parenteffect.ParentHasGraph("Alpha")
			run_alpha = True
		End If
		If red_component.c_nodes.lastframe And Not randomcolor
			run_colour = True
		End If
		If weight_component.c_nodes.lastframe
			run_weight = True
		End If
		If stretch_component.c_nodes.changes[0] Or stretch_component.c_nodes.lastframe
			run_stretch = True
		End If
		
		If framerate_component.c_nodes.lastframe
			run_framerate = True
		End If
		InitSpawnComponents()
		For Local e:tlEffect = EachIn effects
			e.CompileAll()
		Next
	End
	#Rem monkeydoc @hidden
	#End
	Method InitSpawnComponents()
		'life
		If GetComponent("LifeVariation") Or currentlifevariation
			spawncomponents.AddLast(New tlSpawnComponent_LifeVariation("LifeVariation", parenteffect, Self))
		Else
			spawncomponents.AddLast(New tlSpawnComponent_Life("Life", parenteffect, Self))
		End If
		'speed
		If GetComponent("VelocityVariation") Or currentvelocityvariation Or GetComponent("BaseSpeed") Or currentbasespeed
			spawncomponents.AddLast(New tlSpawnComponent_Speed("Speed", parenteffect, Self))
		End If
		'size
		If GetComponent("SizeXVariation") Or currentsizexvariation Or (Not uniform And GetComponent("SizeYVariation") Or currentsizeyvariation)
			spawncomponents.AddLast(New tlSpawnComponent_SizeVariation("SizeVariation", parenteffect, Self))
		Else
			spawncomponents.AddLast(New tlSpawnComponent_Size("Size", parenteffect, Self))
		End If
		'Splatter
		If GetComponent("Splatter") Or currentsplatter
			spawncomponents.AddLast(New tlSpawnComponent_Splatter("Splatter", parenteffect, Self))
		End If
		'Tform
		spawncomponents.AddLast(New tlSpawnComponent_TForm("TForm", parenteffect, Self))
		'emission
		If Not (parenteffect.TraverseEdge And parenteffect.EffectClass = tlLINE_EFFECT)
			spawncomponents.AddLast(New tlSpawnComponent_Emission("Emission", parenteffect, Self))
			If GetComponent("EmissionRange") Or parenteffect.GetComponent("EmissionRange") Or currentemissionrange Or parenteffect.currentemissionrange
				spawncomponents.AddLast(New tlSpawnComponent_EmissionRange("EmissionRange", parenteffect, Self))
			End If
		End If
		'direction
		If GetComponent("DirectionVariation") Or currentdirectionvariation And (dvovertime_component.c_nodes.changes[0] Or dvovertime_component.c_nodes.lastframe)
			If Not parenteffect.TraverseEdge Or Not parenteffect.EffectClass = tlLINE_EFFECT
				spawncomponents.AddLast(New tlSpawnComponent_DirectionVariation("DirectionVariation", parenteffect, Self))
			End If
		End If
		'locked angle
		If lockangle
			spawncomponents.AddLast(New tlSpawnComponent_LockedAngle("LockedAngle", parenteffect, Self))
		Else
			spawncomponents.AddLast(New tlSpawnComponent_Angle("Angle", parenteffect, Self))
		End If
		'weight
		If GetComponent("WeightVariation") Or currentweightvariation Or GetComponent("BaseWeight") Or currentbaseweight
			If weight_component.c_nodes.changes[0] Or weight_component.c_nodes.lastframe
				spawncomponents.AddLast(New tlSpawnComponent_Weight("Weight", parenteffect, Self))
			End If
		End If
		'spin
		If GetComponent("SpinVariation") Or currentspinvariation Or GetComponent("BaseSpin") Or currentbasespin
			spawncomponents.AddLast(New tlSpawnComponent_Spin("Spin", parenteffect, Self))
		End If
	End
	#Rem monkeydoc @hidden
	#End
	Method ControlParticle(p:tlParticle)
		If run_uniform
			uscale_component.ControlParticle(p)
		Else
			If run_scalex scalex_component.ControlParticle(p)
			If run_scaley scaley_component.ControlParticle(p)
		End If
		If run_velocity velocity_component.ControlParticle(p)
		If run_globalvelocity globalvelocity_component.ControlParticle(p)
		If run_alpha alpha_component.ControlParticle(p)
		If run_colour
			 red_component.ControlParticle(p)
			 green_component.ControlParticle(p)
			 blue_component.ControlParticle(p)
		End If
		If run_direction direction_component.ControlParticle(p)
		If run_dvovertime dvovertime_component.ControlParticle(p)
		If run_spin spin_component.ControlParticle(p)
		If run_weight weight_component.ControlParticle(p)
		If run_stretch stretch_component.ControlParticle(p)
		If run_framerate framerate_component.ControlParticle(p)
	End
End

#Rem monkeydoc Makes a copy of the emitter passed to it
	Generally you will want to copy an effect, which will in turn copy all emitters within it recursively
	@return A new clone of the emitter
#End
Function CopyEmitter:tlEmitter(e:tlEmitter, ParentEffect:tlEffect, ParticleManager:tlParticleManager)
	Local clone:tlEmitter = New tlEmitter
	clone.DoB = ParticleManager.CurrentTime
	clone.UseEffectEmission = e.UseEffectEmission
	clone.Sprite = e.Sprite
	clone.AngleType = e.AngleType
	clone.AngleOffset = e.AngleOffset
	clone.LocalRotation = e.LocalRotation
	clone.BlendMode = e.BlendMode
	clone.ParticleRelative = e.ParticleRelative
	clone.Uniform = e.Uniform
	clone.LockAngle = e.LockAngle
	clone.AngleRelative = e.AngleRelative
	clone.HandleVector = e.HandleVector.Clone()
	clone.Name = e.Name
	clone.SingleParticle = e.SingleParticle
	clone.Visible = e.Visible
	clone.RandomColor = e.RandomColor
	clone.Layer = e.Layer
	clone.Animating = e.Animating
	clone.RandomStartFrame = e.RandomStartFrame
	clone.AnimationDirection = e.AnimationDirection
	clone.Frame = e.Frame
	clone.ColorRepeat = e.ColorRepeat
	clone.AlphaRepeat = e.AlphaRepeat
	clone.OneShot = e.OneShot
	clone.HandleCenter = e.HandleCenter
	clone.AnimateOnce = e.AnimateOnce
	clone.Path = e.Path
	'temps
	clone.currentamount = e.currentamount
	clone.currentlife = e.currentlife
	clone.currentbasespeed = e.currentbasespeed
	clone.currentbaseweight = e.currentbaseweight
	clone.currentbasesizex = e.currentbasesizex
	clone.currentbasesizey = e.currentbasesizey
	clone.currentbasespin = e.currentbasespin
	clone.currentsplatter = e.currentsplatter
	clone.currentlifevariation = e.currentlifevariation
	clone.currentamountvariation = e.currentamountvariation
	clone.currentvelocityvariation = e.currentvelocityvariation
	clone.currentweightvariation = e.currentweightvariation
	clone.currentsizexvariation = e.currentsizexvariation
	clone.currentsizeyvariation = e.currentsizeyvariation
	clone.currentspinvariation = e.currentspinvariation
	clone.currentdirectionvariation = e.currentdirectionvariation
	clone.currentalphaovertime = e.currentalphaovertime
	clone.currentvelocityovertime = e.currentvelocityovertime
	clone.currentweightovertime = e.currentweightovertime
	clone.currentscalexovertime = e.currentscalexovertime
	clone.currentscaleyovertime = e.currentscaleyovertime
	clone.currentspinovertime = e.currentspinovertime
	clone.currentdirection = e.currentdirection
	clone.currentdirectionvariationot = e.currentdirectionvariationot
	clone.currentframerateovertime = e.currentframerateovertime
	clone.currentstretchovertime = e.currentstretchovertime
	clone.currentredovertime = e.currentredovertime
	clone.currentgreenovertime = e.currentgreenovertime
	clone.currentblueovertime = e.currentblueovertime
	clone.currentglobalvelocity = e.currentglobalvelocity
	clone.currentemissionangle = e.currentemissionangle
	clone.currentemissionrange = e.currentemissionrange

	'Quick access components
	clone.scalex_component = Cast<tlEC_ScaleXOvertime>(e.scalex_component.Clone(ParentEffect, clone))
	clone.scaley_component = Cast<tlEC_ScaleYOvertime>(e.scaley_component.Clone(ParentEffect, clone))
	If e.uscale_component clone.uscale_component = Cast<tlEC_UniformScale>(e.uscale_component.Clone(ParentEffect, clone))
	clone.stretch_component = Cast<tlEC_StretchOvertime>(e.stretch_component.Clone(ParentEffect, clone))
	clone.velocity_component = Cast<tlEC_VelocityOvertime>(e.velocity_component.Clone(ParentEffect, clone))
	clone.globalvelocity_component = Cast<tlEC_GlobalVelocity>(e.globalvelocity_component.Clone(ParentEffect, clone))
	clone.alpha_component = Cast<tlEC_AlphaOvertime>(e.alpha_component.Clone(ParentEffect, clone))
	clone.red_component = Cast<tlEC_RedOvertime>(e.red_component.Clone(ParentEffect, clone))
	clone.green_component = Cast<tlEC_GreenOvertime>(e.green_component.Clone(ParentEffect, clone))
	clone.blue_component = Cast<tlEC_BlueOvertime>(e.blue_component.Clone(ParentEffect, clone))
	clone.direction_component = Cast<tlEC_DirectionOvertime>(e.direction_component.Clone(ParentEffect, clone))
	clone.dvovertime_component = Cast<tlEC_DirectionVariationOvertime>(e.dvovertime_component.Clone(ParentEffect, clone))
	clone.spin_component = Cast<tlEC_SpinOvertime>(e.spin_component.Clone(ParentEffect, clone))
	clone.weight_component = Cast<tlEC_WeightOvertime>(e.weight_component.Clone(ParentEffect, clone))
	clone.framerate_component = Cast<tlEC_FramerateOvertime>(e.framerate_component.Clone(ParentEffect, clone))
	
	clone.run_uniform = e.run_uniform
	clone.run_scalex = e.run_scalex
	clone.run_scaley = e.run_scaley
	clone.run_velocity = e.run_velocity
	clone.run_stretch = e.run_stretch
	clone.run_globalvelocity = e.run_globalvelocity
	clone.run_alpha = e.run_alpha
	clone.run_colour = e.run_colour
	clone.run_direction = e.run_direction
	clone.run_dvovertime = e.run_dvovertime
	clone.run_spin = e.run_spin
	clone.run_weight = e.run_weight
	clone.run_framerate = e.run_framerate
	
	For Local component:tlComponent = EachIn e.Components
		If Cast<tlGraphComponent>(component)
			clone.AddComponent(Cast<tlGraphComponent>(component).Clone(ParentEffect, clone), False)
		EndIf
	Next
	For Local component:tlSpawnComponent = EachIn e.SpawnComponents
		clone.SpawnComponents.AddLast(component.Clone(ParentEffect, clone))
	Next
	For Local effect:tlEffect = EachIn e.Effects
		clone.AddEffect(CopyEffect(effect, ParticleManager))
	Next
	Return clone
End Function
