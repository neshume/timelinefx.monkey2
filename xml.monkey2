Namespace timelinefx

#Import "<std>"

Using std..

#Rem monkeydoc @hidden
#End
Enum ReadStatus
	None = 0
	OpenTag = 1
	CloseTag = 2
	Waiting = 3
	Def = 4
	CloseNode = 5
	SingleTag = 6
	Skip = 7
End

#Rem monkeydoc @hidden
#End
Enum DataType
	Discard = 0
	Node = 1
	Attribute = 2
	Data = 3
	CloseNode = 4
End

#Rem monkeydoc @hidden
#End
Class XMLParser
	
	Private 
	
	Field _file:Stream
	Field _buffer:String
	Field _last:ReadStatus = ReadStatus.None
	Field _this:ReadStatus = ReadStatus.None
	Field _next:String
	Field _data:DataType
	Field _root:XMLElement
	Field _currentnode:XMLElement
	Field _parsestack:Stack<XMLElement>
	Field _readpair:Int
	
	Method New()
		_parsestack = New Stack<XMLElement>
	End
	
	Method Parse:XMLParser()
		If Not _file Return Null
		
		Local filestring:String = _file.ReadCString()
		Local i:Int 

		While i < filestring.Length
			Local cs:string
			If(_readpair)
				cs = String.FromChar(filestring[i - 1]) + String.FromChar(filestring[i])
			Else
				cs = String.FromChar(filestring[i])
			End If
			If _last = ReadStatus.None And cs <> "<" Return Null
			_readpair = 0
			
			Status(cs)
			
			Process(cs)
			
			i+=1
		Wend
		
		Return Self
	End
	
	Method Status(cs:String)
		_last = _this
		
		Select cs
			Case "<"
				If _last = ReadStatus.None
					_last = ReadStatus.OpenTag
				End if
				_this = ReadStatus.OpenTag
			Case ">"
				_this = ReadStatus.CloseTag
			Case "?"
				_this = ReadStatus.Def
			Case "/"
				If _last = ReadStatus.OpenTag
					_this = ReadStatus.CloseNode
				Else If _last = ReadStatus.Waiting
					_readpair = 1
				End If
			Case "/>"
				_this = ReadStatus.SingleTag
			Default
				If _last = ReadStatus.CloseTag
					_this = ReadStatus.Waiting
				End if
		End
	End
	
	Method Process(cs:String)

		If _last = ReadStatus.OpenTag And _this = ReadStatus.OpenTag
			_this = ReadStatus.Waiting
		End If 
		If _last = ReadStatus.Waiting And _this = ReadStatus.Def 
			_data = DataType.Discard
		End If
		If _last = ReadStatus.Waiting And _this = ReadStatus.Def 
		End If
		If _last = ReadStatus.Def And _this = ReadStatus.CloseTag 
			_buffer = ""
		End If
		If _last = ReadStatus.Waiting And _this = ReadStatus.CloseTag
			_data = DataType.Node
			Build()
		End If
		If _last = ReadStatus.Waiting And _this = ReadStatus.OpenTag
			_data = DataType.Data
			Build()
		End If
		If _this = ReadStatus.SingleTag
			_data = DataType.Node
			Build()
			_this = ReadStatus.Skip
		End If
		If _this = ReadStatus.CloseNode
			_data = DataType.CloseNode
			Build()
			_this = ReadStatus.Skip
		End If
		If _this = ReadStatus.Waiting
			_buffer += cs
		End If
	End
	
	Method Build()
		Select _data
			Case DataType.Node
				Local nodedata:= _buffer.Split(" ")
				Local node:= New XMLElement(nodedata[0].Trim(), _currentnode)
				If _currentnode
					_currentnode._children.Add(node)
				End If
				_buffer = _buffer.Replace(nodedata[0] + " ", "")
				If nodedata.Length > 1
					nodedata = _buffer.Split("~q ")
					For Local attr:=Eachin nodedata
						Local a:=attr.Split("=")
						node._attributes.Add(a[0], a[1].Split("~q")[1])
					Next
				End if
				If _this <> ReadStatus.SingleTag
					_parsestack.Add(node)
					_currentnode = node
				End If
				If Not _root Then _root = node
				_buffer = ""			
			Case DataType.Data
				If _currentnode
					_currentnode.Value = _buffer.Trim()
					_buffer = ""
				End If
			Case DataType.CloseNode
				_currentnode = _parsestack.Pop()
				Local stack:=_parsestack.ToArray()
				If _parsestack.Length
					_currentnode = _parsestack[_parsestack.Length-1]
				Else
					_currentnode = _root
				End If
			Case DataType.Discard
				_buffer = ""
		End
	End

	Public

	Function ParseFile:XMLParser(path:String)
		Print path
		Local parser:XMLParser = New XMLParser
		parser._file = Stream.Open(path, "r")


		Assert( parser._file, "Could not open the effect library" )
		parser.Parse()
		parser._file.Close()

		Return parser
	End
	
	Method ToString:String()
		Return "<?xml version=~q1.0~q encoding=~qISO-8859-1~q?>" + _root.ToString()
	End
	
	Property Root:XMLElement()
		Return _root
	End
	
End

#Rem monkeydoc @hidden
#End
Class XMLElement
	Field _name:String
	Field _data:String
	Field _parent:XMLElement
	Field _children:List<XMLElement>
	Field _attributes:StringMap<String>
	
	Method New(name:String, parent:XMLElement = Null)
		_name = name
		_parent = parent
		_attributes = New StringMap<String>
		_children = New List<XMLElement>
	End
	
	Property Value:String()
		Return _data
	Setter(v:String)
		_data = v
	End

	Property Name:String()
		Return _name
	End
	
	Method ToString:String()
		Local output:string = "<" + _name
		If _attributes.Count()
			For Local attr:=Eachin _attributes
				output += " "
				output += attr.Key + "=~q" + attr.Value + "~q"
			Next
		End If
		If _children.Count()
			output += ">~n"
			If Value
				output += "~n" + Value + "~n"
			End If
			For Local child:=Eachin _children
				output += child.ToString()
			Next
			output += "</" + _name + ">~n"
		Else
			If Value
				output += ">~n"
				output += Value + "~n"
				output += "</" + _name + ">~n"
			Else
				output += "/>~n"
			End If
		End If
		Return output
	End
	
	Property Children:List<XMLElement>()
		Return _children
	End
	
	Method GetAttribute:String(attr:String)
		Return _attributes.Get(attr)
	End
End