#tag Class
Protected Class HTMLFetchTool
Inherits MCPKit.Tool
	#tag Method, Flags = &h0
		Sub Constructor()
		  // Pass the superclass this tool's name and description.
		  Super.Constructor("URLToHTML", "Retrieves the raw HTML from a URL. If a tool exists to retrieve the Markdown or plain text contents of a URL, " + _
		  "it is recommended that is used preferentially as the raw HTML will significantly increase token usage.")
		  
		  // The `url` parameter is a string.
		  Var url As New MCPKit.ToolParameter("url", MCPKit.ToolParameterTypes.String_, _
		  "The URL to fetch. If the URL is not HTML or the link cannot be retrieved, an empty string is returned", _
		  False, "", True)
		  
		  Parameters.Add(url)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 46657463686573207468652048544D4C2066726F6D207468652070726F76696465642055524C2E20496620616E206572726F72206F6363757273207468656E20616E20656D70747920737472696E672069732072657475726E65642E
		Function Run(args() As MCPKit.ToolArgument) As String
		  /// Fetches the HTML from the provided URL.
		  /// If an error occurs then an empty string is returned.
		  
		  // Get the arguments and their values.
		  // The MCP server application will have validated that the arguments passed are valid.
		  Var urlString As String
		  For Each arg As MCPKit.ToolArgument In args
		    Select Case arg.Name
		    Case "url"
		      urlString = arg.Value.StringValue
		    End Select
		  Next arg
		  
		  Var link As URL
		  
		  Try
		    link = New URL(urlString)
		  Catch e As RuntimeException
		    Return ""
		  End Try
		  
		  If link.ContentType.Contains("text/html") Or link.ContentType.Contains("text/plain") Then
		    Return link.Contents
		  Else
		    Return ""
		  End If
		  
		End Function
	#tag EndMethod


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Description"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
