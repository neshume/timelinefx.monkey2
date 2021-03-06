#Rem
	Copyright (c) 2017 Peter J Rigby
	
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

#End

Namespace timelinefx

Using timelinefx..

#Rem monkeydoc @hidden
#End
Const tlCAPTURE_SELF:Int = 0
#Rem monkeydoc @hidden
#End
Const tlCAPTURE_ALL:Int = 1
#Rem monkeydoc @hidden
#End
Const tlCAPTURE_NONE:Int = 2

#Rem monkeydoc The base class for all particle objects, can also be used for general game entities
	This is the main type for storing entity information such as coordinates, colour and other information. This type is designed to be a base
	type that you can use to extend and create other classes, for example Player or Bullet. 

	Entities can be parented to other entities and maintain and update a list of children. These children can be relative to their parents therefore
	minimising the work needed to calculate where entities should be drawn to the screen. If a parent rotates, then it's children will rotate with it and
	likewise, if the parent moves then its children will move with it as well. Children don't have to be relative however, set realative to false using [[Relative]]
	to make the children move independantly, however they will still be updated by their parent

	If you have an entity with children, and those children in turn have children, in order to update all of those entities only one call to the parent
	[[Update]] method is required to see all of the children updated too. This also applies to rendering the entities on screen - by calling [[Render]] on the parent entity
	all children entities will also be rendered. See the code below for an example

	Entities draw to the screen using [[tlShape]], a class that allows you to easily draw single or animated images. To set the image use [[Image]]
	and [[LoadShape]]. You can adjust the appearence of the entity such as colour and scale using commands such as [[Red]], [[Green]], [[Blue]], [[Alpha]],
	[[SetScale]] and [[Angle]].

	When entities are rendered they can be tweened so that their animation and movement on the screen is smoothed out using fixed rate timing. You pass the tween value when you call [[Render]] but it's
	only optional.

	tlGameObject os component based, meaning it uses [[tlComponent]]s to add functionality. [[tlComponent]] is an abstract class you can extend and override the update method to add whatever functionality you
	need to the object, be it a control system or movement. You can create as many components as you need for an object and they can be re-used as much as you need. See [[tlComponent]] for more info.

	@example
	Namespace myapp

	#Import "<std>"
	#Import "<mojo>"
	#Import "<timelinefx>"
	#Import "assets/smoke.png"

	Using std..
	Using mojo..
	Using timelinefx..

	Class MyWindow Extends Window

		Field GameObject:tlGameObject
		Field ChildObject:tlGameObject

		Method New( title:String="tlGameObject example",width:Int=640,height:Int=480,flags:WindowFlags=Null )

			Super.New( title,width,height,flags )
			
			'Create a couple of new game objects
			GameObject = New tlGameObject
			ChildObject = New tlGameObject
			
			'Assign images using LoadShape
			GameObject.Image = LoadShape("asset::smoke.png")
			ChildObject.Image = LoadShape("asset::smoke.png")
			
			'Position the child object. This will be relative to the parent object.
			ChildObject.SetPosition(0, 200)
			'Scale it down a bit
			ChildObject.SetScale(0.5)
			
			'Add the child object to the parent object
			GameObject.AddChild(ChildObject)
			'Set the parent position 
			GameObject.SetPosition(width/2, height/2)
			'Update the gameobject to make sure everything is initialised in the correct positions
			GameObject.Update()
		End

		Method OnRender( canvas:Canvas ) Override
		
			App.RequestRender()
			
			canvas.Clear( New Color(0,0,0,1) )
			
			'Rotate the parent object to show that the child stays relative
			GameObject.Rotate(0.05)
			'Update the game object
			GameObject.Update()
			'Render the game object
			GameObject.Render(canvas)
		End
		
	End

	Function Main()

		New AppInstance
		
		New MyWindow
		
		App.Run()
	End

	@end
#End
Class tlGameObject Virtual
	
	Private
	
	Field name:string
	
	'vectors
	Field local_vec:tlVector2
	Field world_vec:tlVector2
	Field tiedvector:tlVector2
	
	Field scale_vec:tlVector2
	Field world_scale_vec:tlVector2
	
	Field zoom:Float = 1
	
	'matrices
	Field matrix:tlMatrix2				'A matrix to calculate entity rotation relative to the parent
	Field scale_matrix:tlMatrix2
	
	'colour
	Field red:Float = 1
	Field green:Float = 1
	Field blue:Float = 1
	Field alpha:Float = 1
	
	'image
	Field image:tlShape
	Field currentframe:Float
	
	'Field currentanimseq:tlAnimationSequence
	Field framerate:Float
	Field animating:Int
	Field handle_vec:tlVector2
	Field autocenter:Int = True
	Field local_rotation:Float
	Field world_rotation:Float
	Field frames:Int
	Field iterations:Int
	Field iterationcount:Int
	Field blendmode:BlendMode
	Field donotrender:Int

	'hierarchy
	Field parent:tlGameObject
	Field rootparent:tlGameObject
	Field children:Stack<tlGameObject>
	Field childcount:Int
	Field runchildren:Int
	Field relative:Int = True
	Field attached:Int
	Field rotate_vec:tlVector2 			'Vector formed between the parent and the children
	
	'tween values
	Field oldworld_vec:tlVector2
	Field oldworldscale_vec:tlVector2
	Field oldlocal_rotation:Float
	Field oldworld_rotation:Float
	Field oldcurrentframe:Float
	Field updatetime:Float = 30
	Field oldzoom:Float
	Field capturemode:Float
	
	'collision
	Field imagebox:tlBox
	Field imageboxtype:Int = tlBOX_COLLISION
	Field collisionbox:tlBox
	Field collisionboxtype:Int = tlBOX_COLLISION
	Field containingbox:tlBox
	Field rendercollisionbox:Int = False
	Field listenlayers:Int[]
	Field isstatic:Int
	Field maxtlx:Float = $7fffffff
	Field maxtly:Float = $7fffffff
	Field maxbrx:Float = -$7fffffff
	Field maxbry:Float = -$7fffffff
	Field updatecontainingbox:Int
	Field collisionhandler:void(ReturnedObject:Object, Data:Object)
	
	'Age and status flags
	Field dob:Float
	Field age:Float
	Field dead:Int
	Field dying:Int
	Field destroyed:Int
	field removed:int
	
	'components
	Field components:Stack<tlComponent> = New Stack<tlComponent>
	Field components_map:StringMap<tlComponent>
	
	Public

	#Rem monkeydoc Has [[Destory]] been called on the gameobject?
		@return Int True or False
	#End
	Property IsDestroyed:Int() 
		Return destroyed
	End

	#Rem monkeydoc @hidden
	#End
	Property Dying:Int() 
		Return dying
	Setter (v:Int)
		dying = v
	End

	#Rem monkeydoc @hidden
	#End
	Property Dead:Int() 
		Return dead
	Setter(v:Int)
		dead = v
	End

	#Rem monkeydoc This flag tells you if the child has been removed from the parent's child list.
		Mainly used internally to manage the child list.
		@return Int True or False
	#End
	Property Removed:Int() 
		Return removed
	Setter(v:Int)
		removed = v
	End

	#Rem monkeydoc @hidden
	#End
	Property DoB:Int() 
		Return dob
	Setter(v:Int)
		dob = v
	End
	
	#Rem monkeydoc Get or set the destroyed flag
		Mainly used internally
	#End
	Property Destroyed:Int() 
		Return destroyed
	Setter(v:Int)
		destroyed = v
	End
	
	#Rem monkeydoc Set to true to render the collision box of the object for debugging and testing purposes
	#End
	Property RenderCollisionBox:Bool() 
		Return rendercollisionbox
	Setter(v:Bool)
		rendercollisionbox = v
	End
	
	#Rem monkeydoc Get/Set the name of the object
		@param String Name of the object
		@return String Name of the object
	#End
	Property Name:String() 
		Return name
	Setter(v:String)
		name = v
	End

	#Rem monkeydoc Get/Set the Zoom level of the object. This helps with features where you can zoom in and out of the game world
		@param float the zoom level
		@return float the zoom level
	#End
	Property Zoom:Float() 
		Return zoom
	Setter(v:float)
		zoom = v
	End
	
	#Rem monkeydoc @hidden
	#End
	Property OldZoom:Float() 
		Return oldzoom
	Setter(v:float)
		oldzoom = v
	End
	
	#Rem monkeydoc @hidden
	#End
	Property Matrix:tlMatrix2() 
		Return matrix
	Setter(v:tlMatrix2)
		matrix = v
	End
	
	#Rem monkeydoc @hidden
	#End
	Property ScaleMatrix:tlMatrix2() 
		Return scale_matrix
	End
	
	#Rem monkeydoc Get/Set the local vector of the object
		If the object is a child of another object then the local vector will the coordinates relative to the parent
		@param [[tlVector2]]
		@return [[tlVector2]]
	#End
	Property LocalVector:tlVector2() 
		Return local_vec
	Setter(v:tlVector2)
		local_vec = v
	End
	
	#Rem monkeydoc Get/Set the World Vector of the object. 
		The world vector is the coordinates of the object relative to the origin of the game world
		@param [[tlVector2]]
		@return [[tlVector2]]
	#End
	Property WorldVector:tlVector2() 
		Return world_vec
	Setter (v:tlVector2)
		world_vec = v
	End

	#Rem monkeydoc @hidden
	#End
	Property OldWorldVector:tlVector2() 
		Return oldworld_vec
	Setter (v:tlVector2)
		oldworld_vec = v
	End
	
	#Rem monkeydoc Get/Set the scale vector of the object reltive to the parent
		@param [[tlVector2]]
		@return [[tlVector2]]
	#End
	Property ScaleVector:tlVector2() 
		Return scale_vec
	Setter (v:tlVector2)
		scale_vec = v
	End
	
	#Rem monkeydoc Get/Set the scale vector of the object reltive to the world
		@param [[tlVector2]]
		@return [[tlVector2]]
	#End
	Property WorldScaleVector:tlVector2() 
		Return world_scale_vec
	Setter (v:tlVector2)
		world_scale_vec = v
	End
	
	#Rem monkeydoc @hidden
	#End
	Property OldWorldScaleVector:tlVector2() 
		Return oldworldscale_vec
	Setter (v:tlVector2)
		oldworldscale_vec = v
	End
	
	#Rem monkeydoc Get/Set the handle of the object. Handle is the origin of the object.
		This can be used to dictate where the object is drawn from and also the point at which it is rotated around. By default the handle is set to the center of the object.
		@param [[tlVector2]]
		@return [[tlVector2]]
	#End
	Property HandleVector:tlVector2() 
		Return handle_vec
	Setter(v:tlVector2)
		handle_vec = v
	End
	
	#Rem monkeydoc Get/Set the local rotation of the object. See [[Angle]]
		@param [[tlVector2]]
		@return [[tlVector2]]
	#End
	Property LocalRotation:Float() 
		Return local_rotation
	Setter(v:Float)
		local_rotation = v
	End
	
	#Rem monkeydoc Get/Set the local rotation of the object.
		@param [[tlVector2]]
		@return [[tlVector2]]
	#End
	Property Angle:Float() 
		Return local_rotation
	Setter(v:Float)
		local_rotation = v
	End
	
	#Rem monkeydoc Get/Set the world rotation of the object.
		@param float
		@return float
	#End
	Property WorldRotation:Float() 
		Return world_rotation
	Setter(v:Float)
		world_rotation = v
	End
	
	#Rem monkeydoc @hidden
	#End
	Property OldLocalRotation:Float() 
		Return oldlocal_rotation
	Setter(v:Float)
		oldlocal_rotation = v
	End
	
	#Rem monkeydoc @hidden
	#End
	Property OldWorldRotation:Float() 
		Return oldworld_rotation
	Setter(v:Float)
		oldworld_rotation = v
	End
	
	#Rem monkeydoc @hidden
	#End
	Property RotateVector:tlVector2() 
		Return rotate_vec
	Setter(v:tlVector2)
		rotate_vec = v
	End
	
	#Rem monkeydoc Set this to true if you don't want the object to be rendered.
		@param int
		@return int
	#End
	Property DoNotRender:Int() 
		Return donotrender
	Setter(v:Int)
		donotrender = v
	End
	
	#Rem monkeydoc Set to true if you don't want the container box to be updated.
		The container box is the box that encloses the whole object including any children and is used for of screen culling amongst other things.
		@param int
		@return int
	#End
	Property UpdateContainerBox:Int() 
		Return updatecontainingbox
	Setter(v:Int)
		updatecontainingbox = v
	End
	
	#Rem monkeydoc Get the components of the object.
		@param Stack<tlComponent>
	#End
	Property Components:Stack<tlComponent>() 
		Return components
	End
	
	#Rem monkeydoc Get/Set the imagebox of the object.
		The image box is the [[tlBox]] that represents the image size of the object. It is used for adding to a [[tlQuadtree]] so you can make use of off screen culling (can also use [[ContainingBox]])
		@param [[tlBox]]
		@return [[tlBox]]
	#End
	Property ImageBox:tlBox() 
		Return imagebox
	Setter(v:tlBox)
		imagebox = v
	End

	#Rem monkeydoc Get/Set the containingbox of the object.
		The image box is the [[tlBox]] that represents the box that envelops the object object including children. 
		It is used for adding to a [[tlQuadtree]] so you can make use of off screen culling.
		@param [[tlBox]]
		@return [[tlBox]]
	#End
	Property ContainingBox:tlBox() 
		Return containingbox
	Setter(v:tlBox)
		containingbox = v
	End
	
	#Rem monkeydoc Get/Set the collisionbox of the object.
		The collisionbox is the [[tlBox]] that represents a more accurate collision of the object for more precise collision checks. for this reason it could be [[tlPolygon]] or tlCircle as well.
		It is used for adding to a [[tlQuadtree]] so you can make use of off screen culling.
		@param [[tlBox]]
		@return [[tlBox]]
	#End
	Property CollisionBox:tlBox() 
		Return collisionbox
	Setter(v:tlBox)
		collisionbox = v
	End
	
	#Rem monkeydoc Get/Set the listen layers of the object.
		When using a [[tlQuadTree]] to manage all your game objects, you can define which layers of the quad tree the object should listen for collisions.
		You then define a callback using [[SetCollisionHandler]] where you can use a function to process the collisions.
		@param [[tlBox]]
		@return [[tlBox]]
	#End
	Property ListenLayers:Int[]() 
		Return listenlayers
	Setter(v:Int[])
		listenlayers = v
	End
	
	#Rem monkeydoc @hidden
	#End
	Property Age:Int() 
		Return age
	Setter (v:Int)
		age = v
	End
	
	#Rem monkeydoc Get/Set the whether the objects handle is set to auto center
		@param Int
		@return Int
	#End
	Property AutoCenter:Int() 
		Return autocenter
	Setter(v:Int)
		autocenter = v
	End
	
	#Rem monkeydoc Get/Set the Blendmode of the object for rendering
		@param [[mojo.BlendMode]]
		@return [[mojo.BlendMode]]
	#End
	Property BlendMode:BlendMode()
		Return blendmode
	Setter(v:BlendMode)
		blendmode = v
	End
	
	#Rem monkeydoc Get/Set the Red value of the object
		@param Float Between 0 and 1
		@return Float Between 0 and 1
	#End
	Property Red:Float() 
		Return red
	Setter(v:Float)
		red = v
	End
	
	#Rem monkeydoc Get/Set the Green value of the object
		@param Float Between 0 and 1
		@return Float Between 0 and 1
	#End
	Property Green:Float() 
		Return green
	Setter(v:Float)
		green = v
	End
	
	#Rem monkeydoc Get/Set the Blue value of the object
		@param Float Between 0 and 1
		@return Float Between 0 and 1
	#End
	Property Blue:Float() 
		Return blue
	Setter(v:Float)
		blue = v
	End
	
	#Rem monkeydoc Get/Set the Alpha value of the object. Alpha is the opacity of the object when rendered
		@param Float Between 0 and 1
		@return Float Between 0 and 1
	#End
	Property Alpha:Float() 
		Return alpha
	Setter (v:Float)
		alpha = v
	End
	
	#Rem monkeydoc Get/Set the [[tlShape]] of the object.
		This is the image that is drawn when the object is rendered to screen. Use [[timelinefx.LoadShape]] to set this value.
		@param [[tlShape]] 
		@return [[tlShape]] 
	#End
	Property Image:tlShape() 
		Return image
	Setter(v:tlShape)
		image = v
	End
	
	#Rem monkeydoc Get/Set the number of animation frames.
		@param Int 
		@return Int 
	#End
	Property Frames:Int() 
		Return frames
	Setter(v:Int)
		frames = v
	End
	
	#Rem monkeydoc Get/Set the framerate of the image.
		This allows you to set how fast the image animates when rendering.
		@param Float
		@return Float 
	#End
	Property FrameRate:Float() 
		Return framerate
	Setter(v:Float)
		framerate = v
	End
	
	#Rem monkeydoc Get/Set the the updatetime of the object.
		This lets you sync the object with how fast your app is updating so that the framerate can be accurate.
		@param Int 
		@return Int 
	#End
	Property UpdateTime:Float() 
		Return updatetime
	Setter(v:Float)
		updatetime = v
	End
	
	#Rem monkeydoc Get/Set whether the object is animating or not.
		@param Int 
		@return Int 
	#End
	Property Animating:Int() 
		Return animating
	Setter(v:Int)
		animating = v
	End
	
	#Rem monkeydoc Get/Set current animation frame of the object
		@param float 
		@return float
	#End
	Property CurrentFrame:Float() 
		Return currentframe
	Setter(v:Float)
		currentframe = v
	End

	#Rem monkeydoc @hidden
	#End
	Property OldCurrentFrame:Float() 
		Return oldcurrentframe
	Setter(v:Float)
		oldcurrentframe = v
	End

	#Rem monkeydoc Get/Set whether the object is relative to it's parent.
		If an object is relative then it will move and rotate with it's parent. Otherwise it will be independent. However, note that if it's not relative it will still 
		be updated when the parent object is updated.
		@param Int 
		@return Int 
	#End
	Property Relative:Int() 
		Return relative
	Setter(v:Int)
		relative = v
	End
	
	#Rem monkeydoc Get/Set the parent of the object.
		This will be set automatically when you call [[AddChild]]/[[RemoveChild]]
		@param Int 
		@return Int 
	#End
	Property Parent:tlGameObject() 
		Return parent
	Setter(v:tlGameObject)
		parent = v
	End
	
	#Rem monkeydoc Get/Set the root parent at the top of the hierarchy
		This will be set automatically when you call [[AddChild]]/[[RemoveChild]]
		@param Int 
		@return Int 
	#End
	Property RootParent:tlGameObject() 
		Return rootparent
	Setter(v:tlGameObject)
		rootparent = v
	End
	
	#Rem monkeydoc Get the number of children in the object.
		This will be set automatically when you call [[AddChild]]/[[RemoveChild]]
		@param Int 
		@return Int 
	#End
	Property ChildCount:Int() 
		Return childcount
	Setter(v:Int)
		childcount = v
	End
	
	#Rem monkeydoc New construct for creating a [[tlGameObject]] and setting defaults 
		@return [[tlGameObject]] 
	#End
	Method New()
		local_vec = New tlVector2(0, 0)
		world_vec = New tlVector2(0, 0)
		
		oldworld_vec = New tlVector2(0, 0)
		oldworldscale_vec = New tlVector2(0, 0)
		
		scale_vec = New tlVector2(1, 1)
		world_scale_vec = New tlVector2(1, 1)
		
		handle_vec = New tlVector2(0, 0)
		
		children = New Stack<tlGameObject>

		tiedvector = New tlVector2(0, 0, true)
		
		'matrices
		matrix = New tlMatrix2
		scale_matrix = New tlMatrix2
		
		'compoents
		'components = New List<tlComponent>
		
		Capture()
		
	End
	
	'setters
	#Rem monkeydoc Set the position of the #tlGameObject for static objects
		use this instead of SetPostion if the object is static, otherwise the objects collision box will not be updated as well.
	#End
	Method SetStaticPosition(x:Float, y:Float)
		LocalVector = New tlVector2(x, y)
		SetStatic()
		Update()
		CaptureAll()
		UpdateStaticCollisionBox()
	End Method
	
	#Rem
	monkeydoc Set the current state of the object, whether it's static or not.
	If an object is static then its collision box's position is not updated every update. This means that it won't bother syncing itself with
	the gameobject or checking every update whether or not it should move within the quadtree. If you set an object as static then you must 
	ensure you call [[UpdateStaticCollisionBox]] after using [[SetPosition]] to ensure it's put in the right place to initialise it.
	@return True or False
	#End
	Method SetStatic(_isstatic:Int = True)
		isstatic = _isstatic
	End Method
	
	#Rem monkeydoc Is the object a static object? See [[SetStatic]]
		@param Int 
		@return Int 
	#End
	Property IsStatic:Int()
		Return isstatic
	Setter (s:Int)
		isstatic = s
	End
	
	#Rem monkeydoc Set the handle of the object. See [[HandleVector]]
		@param x Int 
		@param y Int 
	#End
	Method SetHandle(x:Int, y:Int)
		handle_vec = New tlVector2(x, y)
	End
	
	#Rem monkeydoc Set the current frame on the game object image
		@param frame
	#End
	Method SetCurrentFrame(frame:Int)
		currentframe = frame
		oldcurrentframe = frame
	End Method
	
	#Rem monkeydoc Set the layer that the object's image box resides on. 
		All of your game objects' image boxes should ideally be kept on the same layer, or atleast on a different layer to the one that you use to test for collisions.
	#End
	Method SetImageLayer(layer:Int)
		imagebox.CollisionLayer = layer
	End Method
	
	#Rem monkeydoc Set the image of the object.
		This will also define a [[tlBox]] that you can use for adding to a quad tree and for doing of screen culling and such.
		@param image [[tlShape]]
		@param collisiontype Int or either [[tlBOX_COLLISION]], [[tlPOLY_COLLISION]] or [[tlCIRCLE_COLLISION]]
		@param layer Int of the collision layer the Image box should go on (for use with [[tlQuadTree]])
	#End
	Method SetImage(image:tlShape, collisiontype:Int = tlBOX_COLLISION, layer:Int = 0)
		Self.image = image
		frames = Self.image.Frames
		Select collisiontype
			case -1
				'no collision
			Case tlPOLY_COLLISION
				SetImagePoly(GetWorldX(), GetWorldX(),New Float[](Float(-Self.image.Width) / 2, Float(-Self.image.Height) / 2,
					Float(-Self.image.Width) / 2, Float(Self.image.Height) / 2,
					Float(Self.image.Width) / 2, Float(Self.image.Height) / 2,
					Float(Self.image.Width) / 2, Float(-Self.image.Height) / 2), layer)
			Case tlCIRCLE_COLLISION
				SetImageCircle(GetWorldX(), GetWorldX(), Max(Self.image.Width / 2, Self.image.Height / 2), layer)
			Default
				SetImageBox(GetWorldX(), GetWorldX(), Self.image.Width, Self.image.Height, layer)
		End Select
	End
	
	#Rem monkeydoc Set the collision box of the object to the imagebox
		You can use the collision box for checking collisions and quadtree queries.
		@param layer Int of the collision layer the collision box should go on (for use with [[tlQuadTree]])
	#End
	Method SetCollisionBoxtoImage(layer:Int)
		Local qtree:tlQuadTree
		If collisionbox
			If collisionbox.quadtree
				qtree = collisionbox.quadtree
				collisionbox.RemoveFromQuadTree()
			End If
		End If
		Select imageboxtype
			Case tlBOX_COLLISION
				SetCollisionBox(0, 0, imagebox.Width, imagebox.Height, layer)
			Case tlCIRCLE_COLLISION
				SetCollisionCircle(imagebox.WorldX(), imagebox.WorldY(), Cast<tlCircle>(imagebox).Radius, layer)
			Case tlPOLY_COLLISION
				Local verts:=New Float[imagebox.Vertices.Length * 2]
				For Local v:Int = 0 To verts.Length - 1 Step 2
					verts[v] = imagebox.Vertices[v / 2].x
					verts[v + 1] = imagebox.Vertices[v / 2].y
				Next
				SetCollisionPoly(imagebox.WorldX(), imagebox.WorldY(), verts, layer)
		End Select
		If qtree qtree.AddBox(collisionbox)
	End Method
	
	#Rem monkeydoc Set the dimensions of the objects collision box
		This will create a new box with the given dimensions and set the collision type of the object to tlBOX_COLLISION,
		removing the current one from the world quadtree if it's in there. Set the layer to put the object on a specific collision layer.
		@param x Float
		@param y Float
		@param w Float
		@param h Float
		@param layer Int
	#End
	Method SetCollisionBox(x:Float, y:Float, w:Float, h:Float, layer:Int = 0)
		Local qtree:tlQuadTree
		If collisionbox
			If collisionbox.quadtree
				qtree = collisionbox.quadtree
				collisionbox.RemoveFromQuadTree()
			End If
		End If
		collisionbox = CreateBox(x, y, w, h, layer)
		collisionbox.handle = New tlVector2(x, y)
		collisionbox.Data = Self
		collisionboxtype = tlBOX_COLLISION
		If qtree qtree.AddBox(collisionbox)
	End Method
	
	#Rem monkeydoc Set the dimensions of the objects collision circle
		This will create a new circle collision with the given radius and set the collision type of the object to tlCIRCLE_COLLISION,
		removing the current one from the world quadtree if it's in there. Set the layer to put the object on a specific collision layer.
		@param x
		@param y
		@param r
		@param layer
	#End
	Method SetCollisionCircle(x:Float, y:Float, r:Float, layer:Int = 0)
		Local qtree:tlQuadTree
		If collisionbox
			If collisionbox.quadtree
				qtree = collisionbox.quadtree
				collisionbox.RemoveFromQuadTree()
			End If
		End If
		collisionbox = CreateCircle(x, y, r, layer)
		collisionbox.handle = New tlVector2(x, y)
		collisionbox.Data = Self
		collisionboxtype = tlCIRCLE_COLLISION
		If qtree qtree.AddBox(collisionbox)
	End Method
	
	#Rem monkeydoc Set the dimensions of the objects collisionbox
		This will create a new poly collision with the given verts[] and set the collision type of the object to tlPOLY_COLLISION,
		removing the current one from the world quadtree if it's in there. Set the layer to put the object on a specific collision layer.
		@param x
		@param y
		@param verts
		@param layer
	#End
	Method SetCollisionPoly(x:Float, y:Float, verts:Float[], layer:Int = 0)
		Local qtree:tlQuadTree
		If collisionbox
			If collisionbox.quadtree
				qtree = collisionbox.quadtree
				collisionbox.RemoveFromQuadTree()
			End If
		End If
		collisionbox = CreatePolygon(x, y, verts, layer)
		collisionbox.Data = Self
		collisionboxtype = tlPOLY_COLLISION
		If qtree qtree.AddBox(collisionbox)
	End Method
	
	#Rem monkeydoc @hidden
	#End
	Method SetImageBox(x:Float, y:Float, w:Float, h:Float, layer:Int = 0)
		imagebox = CreateBox(x, y, w, h, layer)
		imagebox.Data = Self
		imageboxtype = tlBOX_COLLISION
	End

	#Rem monkeydoc @hidden
	#End
	Method SetImageCircle(x:Float, y:Float, r:Float, layer:Int = 0)
		imagebox = CreateCircle(x, y, r, layer)
		imagebox.Data = Self
		imageboxtype = tlCIRCLE_COLLISION
	End

	#Rem monkeydoc @hidden
	#End
	Method SetImagePoly(x:Float, y:Float, verts:Float[], layer:Int = 0)
		imagebox = CreatePolygon(x, y, verts, layer)
		imagebox.Data = Self
		imageboxtype = tlPOLY_COLLISION
	End
	
	#Rem monkeydoc Set the position of the object
		@param x Float
		@param y Float
	#End
	Method SetPosition(x:Float, y:Float)
		local_vec = New tlVector2(x, y)
	End

	#Rem monkeydoc Set the position of the object using a [[tlVector2]]
		@param position [[tlVector2]]
	#End
	Method SetPositionVector(position:tlVector2)
		local_vec = New tlVector2(position.x, position.y)
	End
	
	#Rem monkeydoc move the object relative to it's current position
		@param x Float
		@param y Float
	#End
	Method Move(x:Float, y:Float)
		local_vec = local_vec.Move(x, y)
	End
	
	#Rem monkeydoc move the object relative to it's current position using a [[tlVector2]]
		@param v [[tlVector]]
	#End
	Method MoveVector(v:tlVector2)
		local_vec = local_vec.Move(v.x, v.y)
	End
	
	#Rem monkeydoc Tie the object to a vector so that whatever the position of the vector, will be the position of the object.
		@param vector [[tlVector]]
	#End
	Method TieToVector(vector:tlVector2)
		tiedvector = vector
	End
	
	#Rem monkeydoc Untie the object from the vector that it's tied to.
	#End
	Method UnTie()
		tiedvector.Invalid = True
	End
	
	#Rem monkeydoc Set the scale of the object
		@param x Float
		@param x Float
	#End
	Method SetScale( x:Float, y:Float )
		scale_vec = New tlVector2(x, y)
	End

	#Rem monkeydoc Set the scale of the object
		@param vector [[tlVector]]
	#End
	Method SetScale( v:Float )
		scale_vec = New tlVector2(v, v)
	End

	#Rem monkeydoc Rotate the object relative to it's current rotation
		@param v Float (radians)
	#End
	Method Rotate(v:float)
		local_rotation += v
	End

	'getters
	#Rem monkeydoc Get the world x coordinate of the object
		@return Float
	#End
	Method GetWorldX:Float()
		Return world_vec.x
	End

	#Rem monkeydoc Get the world y coordinate of the object
		@return Float
	#End
	Method GetWorldY:Float()
		Return world_vec.y
	End
	
	#Rem monkeydoc Capture the transformation values of the object
		This is used for tweening and is called in the [[Update]] Method, might might be useful if you need to call it manually.
	#End
	Method Capture()
		oldworld_vec.x = world_vec.x
		oldworld_vec.y = world_vec.y
		oldworldscale_vec.x = world_scale_vec.x
		oldworldscale_vec.y = world_scale_vec.y
		oldworld_rotation = world_rotation
		oldlocal_rotation = local_rotation
		oldcurrentframe = currentframe
		oldzoom = zoom
	End
	
	#Rem monkeydoc Capture all including children
	#End
	Method CaptureAll()
		Capture()
		For Local o:tlGameObject = EachIn children
			o.CaptureAll()
		Next
	End
	
	#Rem monkeydoc Add a child object to this object.
		Children are [[Relative]] to the parent by default.
		@param o [[tlGameObject]]
	#End
	Method AddChild(o:tlGameObject)
		If o.parent
			o.parent.RemoveChild(o)
		End If
		children.Add(o)
		o.parent = Self
		o.AssignRootParent(o)
		o.attached = False
'		If Not _containingbox
'			_containingbox = CreateBox(0, 0, 1, 1)
'			_containingbox._data = Self
'			AssignMainBox()
'		End If
		childcount += 1
	End
	
	#Rem monkeydoc Add a child object to this object but don't make it relative.
		@param o [[tlGameObject]]
	#End
	Method AttachChild(o:tlGameObject)
		If o.parent
			o.parent.RemoveChild(o)
		End If
		children.Add(o)
		o.parent = Self
		o.AssignRootParent(o)
		o.attached = True
		childcount += 1
	End

	#Rem monkeydoc Remove a child object from this object.
		@param o [[tlGameObject]]
	#End
	Method RemoveChild(o:tlGameObject)
		o.removed = true
		o.parent = Null
		o.rootparent = Null
		o.attached = False
		childcount -= 1
'		If Not childcount
'			containingbox = Null
'			AssignMainBox()
'		End If
	End
	
	#Rem monkeydoc Detatch a child object to this object. Same as [[RemoveChild]]
		@param o [[tlGameObject]]
	#End
	Method Detatch()
		If parent parent.RemoveChild(Self)
	End
	
	#Rem monkeydoc Remove all children from this object
	#End
	Method ClearChildren()
		For Local o:tlGameObject = EachIn children
			o.Destroy()
		Next
		children.Clear()
		childcount = 0
	End
	
	#Rem monkeydoc Get the number of children in this object
		@return Int
	#End
	Method GetChildCount:Int()
		Return childcount
	End

	#Rem monkeydoc Get the [[Stack]] of children for this object.
		@return Int
	#End
	Method GetChildren:Stack<tlGameObject>()
		Return children
	End
	
	#Rem monkeydoc Set all children to "dead" so they are marked for removal.
	#End
	Method KillChildren()
		For Local o:tlGameObject = EachIn children
			o.KillChildren()
			o.dead = True
		Next
	End
	
	#Rem monkeydoc Destroy the object.
	#End
	Method Destroy()
		parent = Null
		image = Null
		rootparent = Null
		If imagebox
			imagebox.AddForRemoval()
			imagebox.Data = Null
			imagebox = Null
		End If
		If collisionbox
			collisionbox.AddForRemoval()
			collisionbox.Data = Null
			collisionbox = Null
		End If
		If containingbox
			containingbox.AddForRemoval()
			containingbox.Data = Null
			containingbox = Null
		End If
		For Local o:tlGameObject = EachIn children
			o.Destroy()
		Next
		If components
			For Local component:tlComponent = EachIn components
				component.Destroy()
			Next
		End If
		destroyed = True
	End
	
	#Rem monkeydoc Add a [[tlComponent]] to the object
		[[tlCompoents]] are usd to add functionality to [[tlGameObjects]]
		@param component [[tlComponent]] to add
		@param last Default true, add at the end or the beginning of the component list.
	#End
	Method AddComponent(component:tlComponent, last:Int = True)
		component.parent = Self
		If Not components components = New Stack<tlComponent>
		If Not components_map components_map = New StringMap<tlComponent>
		If last
			components.Add(component)
		Else
			components.Insert(0, component)
		End If
		components_map.Add(component.name.ToUpper(), component)
		component.Init()
	End
	
	#Rem monkeydoc Get a [[tlComponent]] from the object
		@param name String 
	#End
	Method GetComponent:tlComponent(name:String)
		Return Cast<tlComponent>(components_map.Get(name.ToUpper()))
	End
	
	#Rem monkeydoc Use the collisionbox to prevent an overlap with another object.
		Call this after [[PreventOverlap]] so that that coordinates of the gameobject will match the collision box.
	#End
	Method SyncWithCollisionBox()
		If parent And relative
			parent.TranslateParent(collisionbox.World.x - GetWorldX(), collisionbox.World.y - GetWorldY())
			If childcount TranslateChildren(collisionbox.World.x - GetWorldX() , collisionbox.World.y - GetWorldY())
		Else
			SetPositionVector(collisionbox.World)
			TForm()
			If childcount TranslateChildren(collisionbox.World.x - GetWorldX() , collisionbox.World.y - GetWorldY())
		End If
	End Method
	
	#Rem monkeydoc Set the layers you want this object to listen for collisions on
		Use this function to determine which collision layers you want this object to check for collisions on. Pass an array of the layers
		you want to listen on.
	#End
	Method ListenOnTheseLayers(layers:Int[])
		listenlayers = layers
	End Method
	
	#Rem monkeydoc @hidden
	#End
	Method TranslateParent(x:Float, y:Float)
		'called if a child prevents an overlap, and needs to push it's parent back too if it's relative
		If parent And relative
			parent.TranslateParent(x, y)
		Else
			Move(x, y)
			TForm()
		End If
	End Method
	
	#Rem monkeydoc @hidden
	#End
	Method TranslateChildren(x:Float, y:Float)
		For Local child:tlGameObject = EachIn children
			child.Move(x, y)
			child.TForm()
			child.TranslateChildren(x, y)
		Next
	End Method
	
	#Rem monkeydoc Update the object
		Updates its coordinates and collision boxes, and updates all children as well. Also runs all [[tlComponents]] in the object.
	#End
	Method Update()
		If destroyed Return
	
		Select capturemode
			Case tlCAPTURE_SELF
				Capture()
			Case tlCAPTURE_ALL
				'capture all including children
				CaptureAll()
		End Select
						
		'update components
		UpdateComponents()
		
		If Not tiedvector.Invalid
			local_vec = local_vec.SetPositionByVector(tiedvector)
		EndIf
		
		'transform the object
		TForm()

		'update the children		
		UpdateChildren()
		
		'update the collision boxes
		If collisionbox UpdateCollisionBox()
		
		UpdateImageBox()
		
		If parent
			If containingbox
				parent.UpdateContainingBox(containingbox.tl_corner.x, containingbox.tl_corner.y, containingbox.br_corner.x, containingbox.br_corner.y)
			Elseif imagebox
				parent.UpdateContainingBox(imagebox.tl_corner.x, imagebox.tl_corner.y, imagebox.br_corner.x, imagebox.br_corner.y)
			End If
		End If
		If UpdateContainerBox ReSizeContainingBox()
		
		'animate the image
		Animate()
		
	End
	
	#Rem monkeydoc Render the entity
		This will Draw the entity onto the screen using the tween value you pass to it to interpolate between old and new positions when
		using fixed rate timing.
		@param canvas Canvas to draw to
		@param tween the tween value to smooth out the rendering (optional)
		@param origin [[tlVector2]] use this to offset the rendering if you have a game world you can scroll about.
		@param renderchildren True/False if you want to render the children of the object (default true)
		@param screenbox [[tlBox]] you can pass a tlBox that is used to cull anything outside of the box (optional) 
	#End
	Method Render(canvas:Canvas, tween:Float = 0, origin:tlVector2 = New tlVector2, renderchildren:Int = True, screenbox:tlBox = Null)
		If image And Not donotrender
			If screenbox And imagebox
				If containingbox
					If Not screenbox.BoundingBoxOverlap(containingbox) Return
					Else
						If Not screenbox.BoundingBoxOverlap(imagebox) Return
				End If
			End If
			If autocenter
				Image.GetImage(currentframe).Handle = New Vec2f( 0.5, 0.5)
			Else
				Image.GetImage(currentframe).Handle = New Vec2f(handle_vec.x, handle_vec.y)
			End If
			canvas.BlendMode = blendmode
			Local ta:Float
			If Abs( oldworld_rotation - world_rotation) > 3.14159
				If oldworld_rotation < world_rotation
					ta = -TweenValues(oldworld_rotation + 6.28319, world_rotation, tween)
				Else
					ta = -TweenValues(oldworld_rotation - 6.28319, world_rotation, tween)
				End if
			Else
				ta = -TweenValues(oldworld_rotation, world_rotation, tween)
			End If
			Local tx:Float = oldworldscale_vec.x + (world_scale_vec.x - oldworldscale_vec.x) * tween
			Local ty:Float = oldworldscale_vec.y + (world_scale_vec.y - oldworldscale_vec.y) * tween
			Local tv:= oldzoom + (zoom - oldzoom) * tween
			If tv <> 1
				tx *= tv
				ty *= tv
			End If
			canvas.Color = New Color(red, green, blue, alpha)
			tv = currentframe
			Local px:=(oldworld_vec.x + (world_vec.x - oldworld_vec.x) * tween) - origin.x
			Local py:=(oldworld_vec.y + (world_vec.y - oldworld_vec.y) * tween) - origin.y
			'canvas.DrawImage (Image.GetImage(tv), (oldworld_vec.x + (world_vec.x - oldworld_vec.x) * tween) - origin.x, (oldworld_vec.y + (world_vec.y - oldworld_vec.y) * tween) - origin.y, rv, tx, ty)
			canvas.DrawImage (image.image[tv], px, py, ta, tx, ty)
			If rendercollisionbox
				canvas.Scale (1, 1)
				canvas.Rotate (0)
				canvas.Color = New Color(1, 0, 1, 0.5)
				If collisionbox collisionbox.Draw(canvas, origin.x, origin.y, False)
				If containingbox
					containingbox.Draw(canvas, origin.x, origin.y, False)
				End If
			End If
		End If
		If renderchildren
			For Local o:tlGameObject = EachIn children
				o.Render(canvas, tween, origin,, screenbox)
			Next
		End If
	End

	#Rem monkeydoc @hidden
	#End
	Method Animate()
		'update animation frame
'		If currentanimseq And _animating
		if image
			currentframe += framerate / updatetime
			if currentframe >= image.Frames
				currentframe = 0
			End if
		End If
	End
	
	#Rem monkeydoc @hidden
	#End
	Method UpdateImageBox()
		If Not isstatic And imagebox
			imagebox.Position(world_vec.x, world_vec.y)
			If oldworldscale_vec.x <> world_scale_vec.x Or oldworldscale_vec.y <> world_scale_vec.y Or oldzoom <> zoom
				If zoom = 1
					imagebox.SetScale(world_scale_vec.x, world_scale_vec.y)
				Else
					imagebox.SetScale(world_scale_vec.x * zoom, world_scale_vec.y * zoom)
				End If
			End If
			If imageboxtype = tlPOLY_COLLISION
				Cast<tlPolygon>(imagebox).SetAngle(world_rotation)
			End If
			'imagebox.UpdateWithinQuadtree()
		End If
	End
	
	#Rem
	monkeydoc For objects that are static, you must call this atleast once after you use #SetPosition to ensure the collision box is positioned correctly.
	#End
	Method UpdateStaticCollisionBox()
		TForm()
		If imagebox
			imagebox.Position(world_vec.x, world_vec.y)
			imagebox.SetScale(world_scale_vec.x, world_scale_vec.y)
			If imageboxtype = tlPOLY_COLLISION
				Cast<tlPolygon>(imagebox).SetAngle(world_rotation)
			End If
		End If 
		If collisionbox
			collisionbox.Position(world_vec.x, world_vec.y)
			collisionbox.SetScale(world_scale_vec.x, world_scale_vec.y)
			If collisionboxtype = tlPOLY_COLLISION
				Cast<tlPolygon>(collisionbox).SetAngle(world_rotation)
			End If
		End If
	End Method
	
	#Rem monkeydoc @hidden
	#End
	Method UpdateCollisionBox()
		If Not isstatic
			collisionbox.Position(world_vec.x, world_vec.y)
			If oldworldscale_vec.x <> world_scale_vec.x Or oldworldscale_vec.y <> world_scale_vec.y Or oldzoom <> zoom
				If zoom = 1
					collisionbox.SetScale(world_scale_vec.x, world_scale_vec.y)
				Else
					collisionbox.SetScale(world_scale_vec.x * zoom, world_scale_vec.y * zoom)
				End If
			End If
			If collisionboxtype = tlPOLY_COLLISION
				Cast<tlPolygon>(collisionbox).SetAngle(world_rotation)
			End If
			'collisionbox.UpdateWithinQuadtree()
		End If
	End
	
	#Rem monkeydoc @hidden
	#End
	Method UpdateContainingBox(MaxTLX:Float, MaxTLY:Float, MaxBRX:Float, MaxBRY:Float)
		If containingbox
			maxtlx = Min(maxtlx, MaxTLX)
			maxtly = Min(maxtly, MaxTLY)
			maxbrx = Max(maxbrx, MaxBRX)
			maxbry = Max(maxbry, MaxBRY)
			updatecontainingbox = True
		End If
	End

	#Rem monkeydoc The the function callback used for processing collisions on the [[tlQuadTree]]
		The callback function you use must have 2 object parameters
		@param callback Function pointer
	#End
	Method SetCollisionHandler(callback:void(ReturnedObject:Object, Data:Object))
		collisionhandler =  callback
	End
	
	#Rem monkeydoc @hidden
	#End
	Method UpdateCollisions(Quadtree:tlQuadTree)
		If collisionbox
			Select collisionboxtype
				Case tlCIRCLE_COLLISION
					Quadtree.ForEachObjectInCircle(Cast<tlCircle>(collisionbox), Self, collisionhandler, listenlayers)
				Default
					Quadtree.ForEachObjectInBox(collisionbox, Self, collisionhandler, listenlayers)
			End Select
		Elseif imagebox
			Select imageboxtype
				Case tlCIRCLE_COLLISION
					Quadtree.ForEachObjectInCircle(Cast<tlCircle>(imagebox), Self, collisionhandler, listenlayers)
				Default
					Quadtree.ForEachObjectInBox(imagebox, Self, collisionhandler, listenlayers)
			End Select
		End If
	End Method
	
	#Rem monkeydoc @hidden
	#End
	Method ReSizeContainingBox()
		If Not containingbox Return
		
		If imagebox
			maxtlx = Min(maxtlx, imagebox.tl_corner.x)
			maxtly = Min(maxtly, imagebox.tl_corner.y)
			maxbrx = Max(maxbrx, imagebox.br_corner.x)
			maxbry = Max(maxbry, imagebox.br_corner.y)
		End If
		
		Local width:Float = maxbrx - maxtlx
		Local height:Float = maxbry - maxtly
		
		containingbox.ReDimension(maxbrx - width, maxbry - height, width, height)
		containingbox.UpdateWithinQuadtree()
		updatecontainingbox = False
		
		maxtlx = $7fffffff
		maxtly = $7fffffff
		maxbrx = -$7fffffff
		maxbry = -$7fffffff
	End
	
	#Rem monkeydoc @hidden
	#End
	Method AssignRootParent(o:tlGameObject)
		If parent
			parent.AssignRootParent(o)
		Else
			o.rootparent = Self
		End If
	End
	
	#Rem monkeydoc @hidden
	#End
	Method TForm()
		'set the matrix if it is relative to the parent
		If relative
			matrix = New tlMatrix2( Cos(local_rotation), Sin(local_rotation), -Sin(local_rotation), Cos(local_rotation) )
		End If
		
		'calculate where the entity is in the world
		If parent And relative And Not attached
			zoom = parent.zoom
			matrix = matrix.Transform(parent.matrix)
			rotate_vec = parent.matrix.TransformVector(local_vec.Multiply(parent.world_scale_vec))
			If zoom = 1
				world_vec = world_vec.SetPositionByVector(parent.world_vec.AddVector(rotate_vec))
			Else
				world_vec = world_vec.SetPositionByVector(parent.world_vec.AddVector(rotate_vec.Scale(zoom)))
			End If
			world_rotation = parent.world_rotation + local_rotation
			world_scale_vec = world_scale_vec.SetPositionByVector(scale_vec.Multiply(parent.world_scale_vec))
		ElseIf parent And attached
			world_rotation = local_rotation
			world_scale_vec = world_scale_vec.SetPositionByVector(scale_vec)
			world_vec = world_vec.SetPositionByVector(parent.world_vec)
		Else
			world_rotation = local_rotation
			world_scale_vec = world_scale_vec.SetPositionByVector(scale_vec)
			world_vec = world_vec.SetPositionByVector(local_vec)
		End If
	End
	
	#Rem monkeydoc @hidden
	#End
	Method UpdateChildren()
		Local c:=children.All()
		Local o:tlGameObject
		While Not c.AtEnd
			local o:=c.Current
			If Not o.destroyed o.Update()
			if o.removed or o.destroyed
				c.Erase()
			Else
				c.Bump()
			End if
		Wend
	End
	
	#Rem monkeydoc @hidden
	#End
	Method UpdateComponents()
		For Local c:tlComponent = EachIn components
			c.Update()
			If destroyed Return
		Next
	End

End
#Rem monkeydoc Abstract component class you can use to add functionality to your game objects
	Extend this class with your own to add any kind of functionality, from physics or keep an objects health up to date. The update method
	of the component will be run eveytime the [[tlGameObject.Update]] method is called.

	@example
	Namespace myapp

	#Import "<std>"
	#Import "<mojo>"
	#Import "<timelinefx>"
	#Import "assets/smoke.png"

	Using std..
	Using mojo..
	Using timelinefx..

	Class MyWindow Extends Window

		Field GameObject:tlGameObject
		Field ChildObject:tlGameObject

		Method New( title:String="tlGameObject example",width:Int=640,height:Int=480,flags:WindowFlags=Null )

			Super.New( title,width,height,flags )
			
			'Create a couple of new game objects
			GameObject = New tlGameObject
			ChildObject = New tlGameObject
			
			'Assign images using LoadShape
			GameObject.Image = LoadShape("asset::smoke.png")
			ChildObject.Image = LoadShape("asset::smoke.png")
			
			'Position the child object. This will be relative to the parent object.
			ChildObject.SetPosition(0, 200)
			'Scale it down a bit
			ChildObject.SetScale(0.5)
			
			'Add the child object to the parent object
			GameObject.AddChild(ChildObject)
			'Set the parent position 
			GameObject.SetPosition(width/2, height/2)
			
			'Add the example component to the gameobject
			GameObject.AddComponent(New ComponentExample("Test Component"))
			
			'Update the gameobject to make sure everything is initialised in the correct positions
			GameObject.Update()
			
		End

		Method OnRender( canvas:Canvas ) Override
		
			App.RequestRender()
			
			canvas.Clear( New Color(0,0,0,1) )
			
			'Update the game object
			GameObject.Update()
			'Render the game object
			GameObject.Render(canvas)
		End
		
	End

	'Example component. Components can contain anything you want to update your game objects
	Class ComponentExample Extends tlComponent
		Field counter:float
		'We need to add the default constructors
		Method New()
		End
		
		Method New(name:String)
			Self.name = name
		End
		
		'You can put whatever you need to in the init method, it will be called when the component is
		'added to the game object
		Method Init() Override
			Print "Component initiliased"
		End
		
		'This will be called everytime the object is updated with tlGameObject.Update()
		Method Update() Override
			Parent.Rotate(0.05)
			Parent.Move(Sin(counter)*10, Cos(counter)*10)
			counter+=0.1
		End
	End

	Function Main()

		New AppInstance
		
		New MyWindow
		
		App.Run()
	End
	@end
#End
Class tlComponent Abstract
	'Private
	
	Field parent:tlGameObject
	Field name:String
	
	'Public

	Method New()
	End
	
	Method New(name:String)
		Self.name = name
	End
	
	#Rem monkeydoc Get/Set the Name of the component
		@param name String
		@return name String
	#End 
	Property Name:String()
		Return name
	Setter(name:String) 
		Self.name = name
	End
	
	#rem monkeydoc Abstract update method. Override with your own.
		The update method is called everytime [[tlGameObject.Update]] is run
	#end
	Method Update() Abstract
	
	#Rem monkeydoc Insert your Init code here. This is run when the component is added to a #tlGameObject
	#End 	
	Method Init() Virtual
		
	End
	
	Method Destroy() Virtual
		parent = Null
	End
	
	#Rem monkeydoc Get the parent of the component
		returns: #tlGameObject
	#End
	Method GetParent:tlGameObject()
		Return parent
	End
	
	Property Parent:tlGameObject() 
		Return parent
	Setter(v:tlGameObject)
		parent = v
	End
End