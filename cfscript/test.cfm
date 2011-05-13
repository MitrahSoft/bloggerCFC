<cfscript>
/*
Name: Test.cfm
Author: CF Mitrah (http://cfmitrah.com/blog/)
Date: 13 May 2011
*/
	blogger = CreateObject( "component", "blogger" ) ; 
	
	// Authenticating 
	
	bloggerUserName = "YourGoogleID";
	bloggerPassword = "YourGooglePwd";
	bloggerAuth = blogger.authenticate(bloggerUserName,bloggerPassword);
	
	// Retrieving - Blogs, Posts and Comments		
	myBlogs = blogger.getBlogList();
	writeDump(var='#myBlogs#',label='Blogs');
	
	getPost = blogger.getPostList('YourBlogID');
	writeDump(var='#getPost#',label='Posts - CFMitrah Group');
	
	getComment = blogger.getComment('YourBlogID','YourPostID');
	writeDump(var='#getComment#',label='Comments - Sample');
	
	//Creating - Posts and Comments
	sendPost = blogger.publishPost('YourBlogID','Post Title','Post Content','Author Name','noreply@blogger.com');
	sendComment = blogger.publishComment('YourBlogID','YourPostID','Comment','Comment Desc','Author Name','noreply@blogger.com');
	
	
	//Drafting a Post
	sendDraftPost = blogger.DraftPost('YourBlogID','Post Title','Post Content','Author Name','noreply@blogger.com');


	//Updating a Post	
	updatePost = blogger.updatePost('YourBlogID','YourPostID','Updated Post Title','Updated Post Content','Author Name','noreply@blogger.com');

	
	// Deleting - Posts and Comments 
	deletePost = blogger.deletePost('YourBlogID','YourPostID');
	deleteComment = blogger.deleteComment('YourBlogID','YourPostID','YourCommentID');
	
</cfscript>