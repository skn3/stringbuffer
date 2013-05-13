Strict

'version 1
' - copied from xml module version 10

Class StringBuffer
	'this is a duplicate of the XMLStringBuffer code so make sure to keep updated
	Field data:int[]
	Field chunk:Int = 128
	Field count:Int
	Field dirty:Int = False
	Field cache:String
	
	'constructor/destructor
	Method New(chunk:Int = 128)
		Self.chunk = chunk
	End
	
	'properties
	Method value:String() Property
		' --- get the property ---
		'rebuild cache
		If dirty
			dirty = False
			If count = 0
				cache = ""
			Else
				cache = String.FromChars(data[0 .. count])
			EndIf
		EndIf
		
		'return cache
		Return cache
	End
	
	'api
	Method Add:Void(asc:Int)
		' --- add single asc to buffer ---
		'resize
		If count = data.Length data = data.Resize(data.Length + chunk)
		
		'fill data
		data[count] = asc
		
		'move pointer
		count += 1
		
		'flag dirty
		dirty = True
	End
	
	Method Add:Void(text:String)
		' --- add text to buffer ---
		If text.Length = 0 Return
		
		'resize
		If count + text.Length >= data.Length data = data.Resize(data.Length + (chunk * Ceil(Float(text.Length) / chunk)))
		
		'fill data
		For Local textIndex:= 0 Until text.Length
			data[count] = text[textIndex]
			
			'move pointer
			count += 1
		Next
		
		'flag dirty
		dirty = True
	End
	
	Method Add:Void(text:String, offset:Int, suggestedLength:Int = 0)
		' --- add text clipping to buffer ---
		'figure out real length of the import
		Local realLength:= text.Length - offset
		If suggestedLength > 0 And suggestedLength < realLength realLength = suggestedLength
		
		'skip
		If realLength = 0 Return
		
		'resize
		If count + realLength >= data.Length data = data.Resize(data.Length + (chunk * Ceil(Float(realLength) / chunk)))
		
		'fill data
		For Local textIndex:= offset Until offset + realLength
			data[count] = text[textIndex]
			
			'move pointer
			count += 1
		Next
		
		'flag dirty
		dirty = True
	End
	
	Method Clear:Void()
		' --- clear the buffer ---
		count = 0
		cache = ""
		dirty = False
	End
	
	Method Shrink:Void()
		' --- shrink the data ---
		Local newSize:Int
		
		'get new size
		If count = 0
			newSize = chunk
		Else
			newSize = Ceil(float(count) / chunk)
		EndIf
		
		'only bother resizing if its changed
		If newSize <> data.Length data = data.Resize(newSize)
	End
	
	Method Trim:Bool()
		' --- this will trim whitespace from the start and end ---
		'skip
		If count = 0 Return False
		
		'quick trim
		If (count = 1 and (data[0] = 32 or data[0] = 9)) or (count = 2 And (data[0] = 32 or data[0] = 9) And (data[1] = 32 or data[1] = 9))
			Clear()
			Return True
		EndIf
		
		'full trim
		'get start trim
		Local startIndex:Int
		For startIndex = 0 Until count
			If data[startIndex] <> 32 And data[startIndex] <> 9 Exit
		Next
		
		'check if there was only whitespace
		If startIndex = count
			Clear()
			Return True
		EndIf
		
		'get end trim
		Local endIndex:Int
		For endIndex = count - 1 To 0 Step - 1
			If data[endIndex] <> 32 And data[endIndex] <> 9 Exit
		Next

		'check for no trim
		If startIndex = 0 And endIndex = count - 1 Return False
		
		'we have to trim so set new length (count)
		count = endIndex - startIndex + 1
		
		'do we need to shift data left?
		If startIndex > 0
			For Local trimIndex:= 0 Until count
				data[trimIndex] = data[trimIndex + startIndex]
			Next
		EndIf
		
		'return that we trimmed
		Return True
	End
	
	Method Length:Int() Property
		' --- return length ---
		Return count
	End
	
	Method Last:Int(defaultValue:Int = -1)
		' --- return the last asc ---
		'skip
		If count = 0 Return defaultValue
		
		'return
		Return data[count - 1]
	End
End