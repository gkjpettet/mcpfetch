#tag Class
Protected Class HTMLMarkdownConverter
	#tag Method, Flags = &h1, Description = 436C65616E73207570207468652067656E657261746564204D61726B646F776E2E
		Protected Shared Function CleanupMarkdown(markdown As String) As String
		  /// Cleans up the generated Markdown.
		  
		  // Remove excessive blank lines (more than 2 consecutive).
		  While markdown.Contains(EndOfLine + EndOfLine + EndOfLine + EndOfLine)
		    markdown = markdown.ReplaceAll(EndOfLine + EndOfLine + EndOfLine + EndOfLine, EndOfLine + EndOfLine + EndOfLine)
		  Wend
		  
		  // Trim leading/trailing whitespace.
		  markdown = markdown.Trim
		  
		  Return markdown
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1, Description = 457874726163747320746865206C616E67756167652066726F6D206120636C617373206174747269627574652E
		Protected Shared Function ExtractLanguageFromClass(classAttr As String) As String
		  /// Extracts the language from a class attribute.
		  ///
		  /// Handles formats like:
		  ///   "language-xojo"
		  ///   "lang-python"
		  ///   "language-javascript rainbow rainbow-show"
		  
		  If classAttr = "" Then Return ""
		  
		  Var classes() As String = classAttr.Split(" ")
		  For Each cls As String In classes
		    cls = cls.Trim.Lowercase
		    
		    // Check for "language-*" pattern.
		    If cls.Left(9) = "language-" Then
		      Return cls.Middle(9)
		    End If
		    
		    // Check for "lang-*" pattern.
		    If cls.Left(5) = "lang-" Then
		      Return cls.Middle(5)
		    End If
		  Next cls
		  
		  Return ""
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1, Description = 457874726163747320746865206C616E6775616765206964656E7469666965722066726F6D20603C7072653E60206F72206E657374656420603C636F64653E6020636C61737320617474726962757465732E
		Protected Shared Function ExtractLanguageFromPre(preNode As HTMLNode) As String
		  /// Extracts the language identifier from `<pre>` or nested `<code>` class attributes.
		  ///
		  /// Supports patterns like:
		  ///   <pre><code class="language-xojo">...</code></pre>
		  ///   <pre class="language-xojo">...</pre>
		  ///   <code class="language-xojo rainbow rainbow-show">...</code>
		  
		  Var language As String = ""
		  
		  // First check the <pre> tag itself.
		  language = ExtractLanguageFromClass(preNode.AttributeValue("class"))
		  If language <> "" Then Return language
		  
		  // Check for a <code> child.
		  For Each child As HTMLNode In preNode.Children
		    If child.TagName.Lowercase = "code" Then
		      language = ExtractLanguageFromClass(child.AttributeValue("class"))
		      If language <> "" Then Return language
		    End If
		  Next child
		  
		  Return ""
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1, Description = 466F726D6174732074657874206173206120626C6F636B71756F74652E
		Protected Shared Function FormatBlockquote(text As String) As String
		  /// Formats text as a blockquote.
		  
		  Var lines() As String = text.Split(EndOfLine)
		  Var result As String = ""
		  
		  For Each line As String In lines
		    If line.Trim <> "" Then
		      result = result + "> " + line.Trim + EndOfLine
		    End If
		  Next
		  
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 50617273657320612048544D4C20646F63756D656E7420746F204D61726B646F776E207573696E67206120637573746F6D2070726F63657373696E6720636F6E746578742E2052657475726E7320616E20656D70747920737472696E67206F6E206661696C7572652E
		Shared Function FromHTML(doc As HTMLDocument, context As MarkdownContext) As String
		  /// Parses a HTML document to Markdown using a custom processing context.
		  /// Returns an empty string on failure.
		  
		  If doc.Root = Nil Then Return ""
		  
		  Try
		    // Initialise context.
		    context = If(context = Nil, New MarkdownContext, context)
		    
		    // Process the node tree.
		    Var result As String = ProcessNode(doc.Root, context)
		    
		    // Clean up the output.
		    result = CleanupMarkdown(result)
		    
		    Return result
		    
		  Catch err As RuntimeException
		    If App.Verbose Then
		      System.DebugLog("HTMLMarkdownConverter.FromHTML() error: " + err.Message)
		    End If
		    Return ""
		  End Try
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 50617273657320612048544D4C20646F63756D656E7420746F204D61726B646F776E2E204F7074696F6E616C6C79206163636570747320746865206162736F6C7574652055524C20666F72207468652048544D4C20696E2074686520706173736564206E6F64652E204966206E6F7420737065636966696564207468656E2074686520706173736564206E6F646527732048544D4C20697320617373756D656420746F2062652066726F6D2074686520726F6F74206C6576656C2E204F7074696F6E616C6C79206163636570747320616E206172726179206F6620656C656D656E74206E616D657320746F20736B69702028652E672E2022736372697074222C20227374796C6522292052657475726E7320616E20656D70747920737472696E67206F6E206661696C7572652E
		Shared Function FromHTML(doc As HTMLDocument, baseURL As String = "", excludedElements() As String = nil) As String
		  /// Parses a HTML document to Markdown.
		  /// Optionally accepts the absolute URL for the HTML in the passed node. If not specified 
		  /// then the passed node's HTML is assumed to be from the root level.
		  /// Optionally accepts an array of element names to skip (e.g. "script", "style")
		  /// Returns an empty string on failure.
		  
		  If doc.Root = Nil Then Return ""
		  
		  Try
		    // Initialise context.
		    Var context As New MarkdownContext(baseURL)
		    If excludedElements <> Nil Then
		      For Each element As String In excludedElements
		        context.AddExcludedElement(element.Lowercase)
		      Next element
		    End If
		    
		    // Process the node tree.
		    Var result As String = ProcessNode(doc.Root, context)
		    
		    // Clean up the output.
		    result = CleanupMarkdown(result)
		    
		    Return result
		    
		  Catch err As RuntimeException
		    If App.Verbose Then
		      System.DebugLog("HTMLKitMarkdownConverter.FromHTML() error: " + err.Message)
		    End If
		    Return ""
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1, Description = 436865636B732069662074686520706173736564206E6F646520697320696E73696465206120603C7072653E6020656C656D656E742E
		Protected Shared Function IsInsidePre(node As HTMLNode) As Boolean
		  /// Checks if the passed node is inside a `<pre>` element.
		  
		  Var parent As HTMLNode = node.Parent
		  While parent <> Nil
		    If parent.TagName.Lowercase = "pre" Then
		      Return True
		    End If
		    parent = parent.Parent
		  Wend
		  
		  Return False
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1, Description = 4E6F726D616C69736573207768697465737061636520696E20746578742028636F6C6C6170736573206D756C7469706C65207370616365732C20657463292E
		Protected Shared Function NormaliseWhitespace(s As String) As String
		  /// Normalises whitespace in text (collapses multiple spaces, etc).
		  
		  // Replace tabs and newlines with spaces
		  s = s.ReplaceAll(Chr(9), " ")
		  s = s.ReplaceAll(Chr(10), " ")
		  s = s.ReplaceAll(Chr(13), " ")
		  
		  // Collapse multiple spaces
		  While s.Contains("  ")
		    s = s.ReplaceAll("  ", " ")
		  Wend
		  
		  Return s
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1, Description = 50726F6365737320616C6C206368696C64206E6F6465732E
		Protected Shared Function ProcessChildren(node As HTMLNode, context As MarkdownContext) As String
		  /// Process all child nodes.
		  
		  Var result As String = ""
		  
		  For Each child As HTMLNode In node.Children
		    If child <> Nil Then
		      result = result + ProcessNode(child, context)
		    End If
		  Next child
		  
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1, Description = 50726F63657373657320616E2048544D4C20656C656D656E74206E6F64652E
		Protected Shared Function ProcessElement(node As HTMLNode, context As MarkdownContext) As String
		  /// Processes an HTML element node.
		  
		  Var tagName As String = node.TagName.Lowercase
		  If tagName = "" Then Return ProcessChildren(node, context)
		  
		  // Check if this element should be excluded.
		  If context.ElementIsExcluded(tagName) Then Return ""
		  
		  Var result As String = ""
		  
		  // Handle different HTML elements.
		  Select Case tagName
		  Case "p", "div", "section", "article", "header", "footer", "main", "aside"
		    result = ProcessChildren(node, context) + EndOfLine + EndOfLine
		    
		  Case "br"
		    result = "  " + EndOfLine
		    
		  Case "h1"
		    result = "# " + ProcessChildren(node, context).Trim + EndOfLine + EndOfLine
		    
		  Case "h2"
		    result = "## " + ProcessChildren(node, context).Trim + EndOfLine + EndOfLine
		    
		  Case "h3"
		    result = "### " + ProcessChildren(node, context).Trim + EndOfLine + EndOfLine
		    
		  Case "h4"
		    result = "#### " + ProcessChildren(node, context).Trim + EndOfLine + EndOfLine
		    
		  Case "h5"
		    result = "##### " + ProcessChildren(node, context).Trim + EndOfLine + EndOfLine
		    
		  Case "h6"
		    result = "###### " + ProcessChildren(node, context).Trim + EndOfLine + EndOfLine
		    
		  Case "strong", "b"
		    result = "**" + ProcessChildren(node, context) + "**"
		    
		  Case "em", "i"
		    result = "*" + ProcessChildren(node, context) + "*"
		    
		  Case "code"
		    If IsInsidePre(node) Then
		      result = ProcessChildren(node, context)
		    Else
		      result = "`" + ProcessChildren(node, context) + "`"
		    End If
		    
		  Case "pre"
		    Var language As String = ExtractLanguageFromPre(node)
		    Var codeContent As String = ProcessChildren(node, context)
		    result = "```" + language + EndOfLine + codeContent.Trim + EndOfLine + "```" + EndOfLine + EndOfLine
		    
		  Case "blockquote"
		    Var quoteContent As String = ProcessChildren(node, context).Trim
		    result = FormatBlockquote(quoteContent) + EndOfLine + EndOfLine
		    
		  Case "a"
		    result = ProcessLink(node, context)
		    
		  Case "img"
		    result = ProcessImage(node, context)
		    
		  Case "ul", "ol"
		    result = ProcessList(node, context, tagName = "ol")
		    
		  Case "li"
		    // List items are handled by ProcessList
		    result = ProcessChildren(node, context)
		    
		  Case "hr"
		    result = EndOfLine + "---" + EndOfLine + EndOfLine
		    
		  Case "table"
		    result = ProcessTable(node, context)
		    
		  Case "del", "s", "strike"
		    result = "~~" + ProcessChildren(node, context) + "~~"
		    
		  Case "sup"
		    result = "^" + ProcessChildren(node, context) + "^"
		    
		  Case "sub"
		    result = "~" + ProcessChildren(node, context) + "~"
		    
		  Else
		    // Default - just process children.
		    result = ProcessChildren(node, context)
		    
		  End Select
		  
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1, Description = 50726F63657373657320696D61676520746167732E
		Protected Shared Function ProcessImage(node As HTMLNode, context As MarkdownContext) As String
		  /// Processes image tags.
		  
		  Var src As String = node.AttributeValue("src")
		  Var alt As String = node.AttributeValue("alt")
		  Var title As String = node.AttributeValue("title")
		  
		  If src = "" Then Return ""
		  
		  // Resolve relative image URLs against the base URL.
		  Var resolvedSrc As String = URL.ResolveRelativeURL(src, context.BaseURL)
		  
		  If title <> "" Then
		    Return "![" + alt + "](" + resolvedSrc + " """ + title + """)"
		  Else
		    Return "![" + alt + "](" + resolvedSrc + ")"
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1, Description = 50726F63657373657320616E63686F7220746167732E
		Protected Shared Function ProcessLink(node As HTMLNode, context As MarkdownContext) As String
		  /// Processes anchor tags.
		  
		  Var href As String = node.AttributeValue("href")
		  Var title As String = node.AttributeValue("title")
		  Var linkText As String = ProcessChildren(node, context)
		  
		  If href = "" Then Return linkText
		  
		  // Resolve relative link URLs against the base URL.
		  Var resolvedHref As String = URL.ResolveRelativeURL(href, context.BaseURL)
		  
		  If context.RemoveLinks Then
		    Return linkText
		  Else
		    If title <> "" Then
		      Return "[" + linkText + "](" + resolvedHref + " """ + title + """)"
		    Else
		      Return "[" + linkText + "](" + resolvedHref + ")"
		    End If
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1, Description = 50726F636573736573206F72646572656420616E6420756E6F726465726564206C697374732E
		Protected Shared Function ProcessList(node As HTMLNode, context As MarkdownContext, isOrdered As Boolean) As String
		  /// Processes ordered and unordered lists.
		  
		  Var result As String = ""
		  Var itemIndex As Integer = 1
		  
		  context.ListDepth = context.ListDepth + 1
		  Var indent As String = ""
		  For i As Integer = 1 To (context.ListDepth - 1) * 2
		    indent = indent + " "
		  Next i
		  
		  For Each child As HTMLNode In node.Children
		    If child <> Nil Then
		      If child.TagName.Lowercase = "li" Then
		        Var itemContent As String = ProcessChildren(child, context).Trim
		        
		        If isOrdered Then
		          result = result + indent + Str(itemIndex) + ". " + itemContent + EndOfLine
		          itemIndex = itemIndex + 1
		        Else
		          result = result + indent + "- " + itemContent + EndOfLine
		        End If
		      End If
		    End If
		  Next child
		  
		  context.ListDepth = context.ListDepth - 1
		  
		  If context.ListDepth = 0 Then
		    result = result + EndOfLine
		  End If
		  
		  Return result
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1, Description = 5265637572736976656C792070726F63657373657320612048544D4C206E6F646520616E6420697473206368696C6472656E2E
		Protected Shared Function ProcessNode(node As HTMLNode, context As MarkdownContext) As String
		  /// Recursively processes a HTML node and its children.
		  
		  If node = Nil Then Return ""
		  
		  // Should this node be excluded based on its ID, class name or role attribute?
		  If node.Attributes_.KeyCount > 0 Then
		    If context.IDIsExcluded(node.AttributeValue("id")) Then Return ""
		    If context.ClassIsExcluded(node.AttributeValue("class")) Then Return ""
		    If context.RoleIsExcluded(node.AttributeValue("role")) Then Return ""
		  End If
		  
		  Var result As String = ""
		  
		  Select Case node.Type
		  Case HTMLNode.Types.Root, HTMLNode.Types.DocType, HTMLNode.Types.Comment
		    // Process children only.
		    result = ProcessChildren(node, context)
		    
		  Case HTMLNode.Types.Text, HTMLNode.Types.CDATA
		    // Handle text content.
		    result = ProcessTextNode(node, context)
		    
		  Else
		    // Handle HTML elements.
		    result = ProcessElement(node, context)
		    
		  End Select
		  
		  Return result
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1, Description = 50726F63657373207461626C65732028626173696320737570706F7274206F6E6C79292E
		Protected Shared Function ProcessTable(node As HTMLNode, context As MarkdownContext) As String
		  /// Process tables (basic support only).
		  
		  Var result As String = ""
		  Var rows() As String
		  Var maxCols As Integer = 0
		  
		  // Find all rows.
		  For Each child As HTMLNode In node.Children
		    If child.TagName.Lowercase = "thead" Or child.TagName.Lowercase = "tbody" Or child.TagName.Lowercase = "tfoot" Then
		      For Each rowNode As HTMLNode In child.Children
		        If rowNode.TagName.Lowercase = "tr" Then
		          Var rowData As String = ProcessTableRow(rowNode, context, maxCols)
		          rows.Add(rowData)
		        End If
		      Next rowNode
		    ElseIf child.TagName.Lowercase = "tr" Then
		      Var rowData As String = ProcessTableRow(child, context, maxCols)
		      rows.Add(rowData)
		    End If
		  Next child
		  
		  If rows.Count = 0 Then Return ""
		  
		  // Build the table.
		  For i As Integer = 0 To rows.LastIndex
		    result = result + rows(i) + EndOfLine
		    If i = 0 Then
		      // Add a separator after first row.
		      result = result + "|"
		      For j As Integer = 1 To maxCols
		        result = result + " --- |"
		      Next
		      result = result + EndOfLine
		    End If
		  Next
		  
		  Return result + EndOfLine
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1, Description = 50726F6365737365732061207461626C6520726F772E
		Protected Shared Function ProcessTableRow(node As HTMLNode, context As MarkdownContext, ByRef maxCols As Integer) As String
		  /// Processes a table row.
		  
		  Var cells() As String
		  
		  For Each child As HTMLNode In node.Children
		    Var tagName As String = child.TagName.Lowercase
		    If tagName = "td" Or tagName = "th" Then
		      Var cellContent As String = ProcessChildren(child, context).Trim
		      cellContent = cellContent.ReplaceAll(EndOfLine, " ")
		      cells.Add(cellContent)
		    End If
		  Next child
		  
		  If cells.Count > maxCols Then maxCols = cells.Count
		  
		  Var result As String = "|"
		  For Each cell As String In cells
		    result = result + " " + cell + " |"
		  Next
		  
		  Return result
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1, Description = 50726F63657373207465787420636F6E74656E742E
		Protected Shared Function ProcessTextNode(node As HTMLNode, context As MarkdownContext) As String
		  /// Process text content.
		  
		  #Pragma Unused context
		  
		  Var t As String = node.Content
		  If t = "" Then Return ""
		  
		  // Check if we're inside a <pre> or <code> block.
		  If IsInsidePre(node) Then
		    Return t
		  End If
		  
		  // Normalise whitespace for regular text.
		  t = NormaliseWhitespace(t)
		  
		  Return t
		  
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
	#tag EndViewBehavior
End Class
#tag EndClass
