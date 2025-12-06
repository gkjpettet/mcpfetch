#tag Class
Protected Class MarkdownFetchTool
Inherits MCPKit.Tool
	#tag Method, Flags = &h0
		Sub Constructor()
		  // Pass the superclass this tool's name and description.
		  Super.Constructor("URLToMarkdown", "Retrieves the contents of a web page as Markdown from a URL. If the URL is not HTML content, " + _
		  "the link cannot be retrieved or no meaningful text content is found then an empty string is returned.")
		  
		  // The `url` parameter is a string.
		  Var url As New MCPKit.ToolParameter("url", MCPKit.ToolParameterTypes.String_, _
		  "The URL to fetch and convert to Markdown.", _
		  False, "", True)
		  
		  Parameters.Add(url)
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function CustomContext(baseURL As String) As MarkdownContext
		  /// Returns a custom Markdown processing context that strips out "noisy" content.
		  
		  Var context As New MarkdownContext(baseURL)
		  
		  context.RemoveLinks = True
		  
		  context.AddExcludedElement("hr", "img", "nav", "sup")
		  
		  context.AddExcludedRole("navigation")
		  
		  Return context
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 466574636865732074686520636F6E74656E7473206F66207468652070726F76696465642055524C20616E642069662069742069732048544D4C2C20636F6E766572747320697420746F204D61726B646F776E2E2049662074686520636F6E74656E747320697320706C61696E2074657874207468656E20746861742069732072657475726E65642E20416E79206F7468657220636F6E74656E742074797065206F7220696620616E206572726F72206F6363757273207468656E20616E20656D70747920737472696E672069732072657475726E65642E
		Function Run(args() As MCPKit.ToolArgument) As String
		  /// Fetches the contents of the provided URL and if it is HTML, converts it to Markdown.
		  /// If the contents is plain text then that is returned.
		  /// Any other content type or if an error occurs then an empty string is returned.
		  
		  // Get the arguments and their values.
		  // The MCP server application will have validated that the arguments passed are valid.
		  Var urlString As String
		  For Each arg As MCPKit.ToolArgument In args
		    If arg.Name = "url" Then
		      urlString = arg.Value.StringValue
		      Exit
		    End If
		  Next arg
		  
		  Var link As URL
		  Try
		    link = New URL(urlString)
		  Catch e As RuntimeException
		    Return ""
		  End Try
		  
		  Var result As String
		  If link.ContentType.Contains("text/html") Then
		    
		    Var doc As New HTMLDocument
		    doc.Parse(link.Contents)
		    result = HTMLMarkdownConverter.FromHTML(doc, CustomContext(link.ResolvedURL))
		    
		  ElseIf link.ContentType.Contains("text/plain") Then
		    
		    result = link.Contents
		    
		  Else
		    Return ""
		  End If
		  
		  Return result
		  
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
