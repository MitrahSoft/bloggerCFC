<!---
Name: Test.cfm
Author: CF Mitrah (http://cfmitrah.com/blog/)
Date: 04 May 2011
--->
<cfset blogger = createObject("component", "blogger")>

<!--- Authenticating --->
<cfset bloggerUserName = "YourGoogleID">
<cfset bloggerPassword = "YourGooglePwd">
<cfset bloggerAuth = blogger.authenticate(bloggerUserName,bloggerPassword)>


<!--- Retrieving - Blogs, Posts and Comments --->
<cfset myBlogs = blogger.getBlogList()><cfdump var="#myBlogs#" label="Blogs"><br />
<cfset getPost = blogger.getPostList('YourBlogID')><!--- Blog Id can be get it from above myBlogs query ---><cfdump var="#getPost#" label="Posts - For your Blog"><br />
<cfset getComment = blogger.getComment('YourBlogID','YourPostID')><!--- Post Id can be get it from above getPost query ---><cfdump var="#getComment#" label="Comments - Your Blog post"><br />


<!--- Creating - Posts and Comments --->
<cfset sendPost = blogger.publishPost('YourBlogID','Post Title','Post Content','Author Name','noreply@blogger.com')>
<cfset sendComment = blogger.publishComment('YourBlogID','YourPostID','Comment','Comment Desc','Author Name','noreply@blogger.com')>


<!--- Drafting a Post --->
<cfset sendDraftPost = blogger.DraftPost('YourBlogID','Post Title','Post Content','Author Name','noreply@blogger.com')>


<!--- Updating a Post --->	
<cfset updatePost = blogger.updatePost('YourBlogID','YourPostID','Updated Post Title','Updated Post Content','Author Name','noreply@blogger.com')>



<!--- Deleting - Posts and Comments --->
<cfset deletePost = blogger.deletePost('YourBlogID','YourPostID')>
<cfset deleteComment = blogger.deleteComment('YourBlogID','YourPostID','YourCommentID')>
