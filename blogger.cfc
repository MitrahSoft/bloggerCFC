<!---
Name: blogger.cfc
Author: CF Mitrah (http://cfmitrah.com/blog/)
Date: 04 May 2011
--->
<cfcomponent output="false" extends="google">

<cfset variables.bloggerservice = "blogger">

<!--- TO DO : Error handling for all http responses --->
	
<cffunction name="authenticate" access="public" returnType="boolean" output="false" hint="I authenticate a user for a service. If login fails, I throw an error.">
	<cfargument name="username" type="string" required="true">
	<cfargument name="password" type="string" required="true">
	
	<cfset super.authenticate(arguments.username,arguments.password,variables.bloggerservice)>
	
	<cfreturn true />
</cffunction>

<cffunction name="getBlogList" access="public" returnType="any" output="false">
	
	<cfreturn getList('blog')>
</cffunction>

<cffunction name="getPostList" access="public" returnType="any" output="false">
	<cfargument name="blogid" type="string" required="false" >
	
	<cfreturn getList('post',arguments.blogID)>
</cffunction>

<cffunction name="getComment" access="public" returnType="any" output="false">
	<cfargument name="blogid" type="string" required="false" >
	<cfargument name="postid" type="string" required="false" >
	
	<cfreturn getList('comment',arguments.blogID,arguments.postid)>
</cffunction>

<cffunction name="publishPost" access="public" returnType="any" output="false">
	<cfargument name="blogid" type="string" required="false" >
	<cfargument name="title" type="string" required="true">
	<cfargument name="description" type="string" required="true">
  	<cfargument name="authorname" type="string" required="false">
  	<cfargument name="authoremail" type="string" required="false">
	
	<cfreturn publishItem('post',arguments.blogID,'',arguments.title,arguments.description,arguments.authorname,arguments.authoremail)>
</cffunction>

<cffunction name="updatePost" access="public" returnType="any" output="false">
	<cfargument name="blogid" type="string" required="false" >
	<cfargument name="postid" type="string" required="false" >
	<cfargument name="title" type="string" required="true">
	<cfargument name="description" type="string" required="true">
  	<cfargument name="authorname" type="string" required="false">
  	<cfargument name="authoremail" type="string" required="false">
	
	<cfreturn updateItem('updatePost',arguments.blogID,arguments.postid,arguments.title,arguments.description,arguments.authorname,arguments.authoremail)>
</cffunction>

<cffunction name="DraftPost" access="public" returnType="any" output="false">
	<cfargument name="blogid" type="string" required="false" >
	<cfargument name="title" type="string" required="true">
	<cfargument name="description" type="string" required="true">
  	<cfargument name="authorname" type="string" required="false">
  	<cfargument name="authoremail" type="string" required="false">
	
	<cfreturn publishItem('post',arguments.blogID,'',arguments.title,arguments.description,arguments.authorname,arguments.authoremail,1)>
</cffunction>

<cffunction name="deletePost" access="public" returnType="any" output="false">
	<cfargument name="blogid" type="string" required="false" >
	<cfargument name="postid" type="string" required="false" >
	
	<cfreturn deleteItem('deletePost',arguments.blogID,arguments.postid)>
</cffunction>

<cffunction name="publishComment" access="public" returnType="any" output="false">
	<cfargument name="blogid" type="string" required="false" >
	<cfargument name="postid" type="string" required="false" >
	<cfargument name="title" type="string" required="true">
	<cfargument name="description" type="string" required="true">
  	<cfargument name="authorname" type="string" required="false">
  	<cfargument name="authoremail" type="string" required="false">
	
	<cfreturn publishItem('comment',arguments.blogID,arguments.postid,arguments.title,arguments.description,arguments.authorname,arguments.authoremail)>
</cffunction>

<cffunction name="deleteComment" access="public" returnType="any" output="false">
	<cfargument name="blogid" type="string" required="false" >
	<cfargument name="postid" type="string" required="false" >
	<cfargument name="commentID" type="string" required="false" >
	
	<cfreturn deleteItem('deleteComment',arguments.blogID,arguments.postid,arguments.commentID)>
</cffunction>


<cffunction name="getList" access="public" returnType="any" output="false" hint="I return a query of blogs/posts/comments. ToDo: More Filtering.">
	<cfargument name="listItem" type="string" required="false" default="blog" >
	<cfargument name="blogid" type="string" required="false" >
	<cfargument name="postid" type="string" required="false" >
	
	<cfswitch expression="#arguments.listItem#">
		<cfcase value="blog">
			<cfset var mainurl = 'http://www.blogger.com/feeds/default/blogs'>
		</cfcase>	
		<cfcase value="post">
			<cfset var mainurl = 'http://www.blogger.com/feeds/'&arguments.blogid&'/posts/default'>
		</cfcase>
		<cfcase value="comment">	
			<cfset var mainurl = "http://www.blogger.com/feeds/" &arguments.blogid& "/" &arguments.postid& "/comments/default">
		</cfcase>	
		<cfdefaultcase>
			<cfthrow message="Bad request">
		</cfdefaultcase>	
	</cfswitch>
	
	<cfset var blogs = queryNew("id,title,updated,author,authoremail")>
	
	<cfhttp url="#mainurl#" method="get" result="result" charset="utf-8">
		<cfhttpparam type="header" name="Authorization" value="GoogleLogin auth=#getAuth(variables.bloggerservice)#">
		<cfhttpparam type="header" name="GData-Version" value="2.0">
	</cfhttp>
	
	<cfif not isXml(result.filecontent)>
		<cfthrow message="#result.filecontent#">
	</cfif>
	
	<cfset packet = xmlParse(result.filecontent)>
	<cfif not structKeyExists(packet, "feed")>
		<cfthrow message="Bad Response">
	</cfif>	

	<cfif not structKeyExists(packet.feed, "entry")>
		<cfreturn blogs>
	</cfif>
	
	<cfloop index="x" from="1" to ="#arrayLen(packet.feed.entry)#">
		<cfset entry = packet.feed.entry[x]>
		<cfset updated = entry.updated.xmltext>
		<cfset queryAddRow(blogs)>
		<cfset querySetCell(blogs, "title", entry.title.xmltext)>
		<cfset parts = entry.id.xmltext.split("-")>
		<cfset querySetCell(blogs, "id", parts[arrayLen(parts)])>
		<cfset querySetCell(blogs, "updated", updated)>
		<cfset querySetCell(blogs, "author", entry.author.name.xmlText)>
		<cfset querySetCell(blogs, "authoremail", entry.author.email.xmlText)>
	</cfloop>
	
	<cfreturn blogs>

</cffunction>	


<cffunction name="publishItem" access="public" returnType="any" output="false" hint="I return a query of blogs.">
	<cfargument name="item" type="string" required="true" default="post" >
	<cfargument name="blogid" type="string" required="true" >
	<cfargument name="postID" type="string" required="false" >
  	<cfargument name="title" type="string" required="true">
	<cfargument name="description" type="string" required="true">
  	<cfargument name="authorname" type="string" required="false">
  	<cfargument name="authoremail" type="string" required="false">
  	<cfargument name="isDraft" type="string" required="false">
  	
  	<cfswitch expression="#arguments.item#">
		<cfcase value="post">
			<cfset var mainurl = 'http://www.blogger.com/feeds/'&arguments.blogid&'/posts/default'>
		</cfcase>
		<cfcase value="comment">	
			<cfset var mainurl = "http://www.blogger.com/feeds/" &arguments.blogid& "/" &arguments.postid& "/comments/default">
		</cfcase>
		<cfdefaultcase>
			<cfthrow message="Bad request">
		</cfdefaultcase>	
	</cfswitch>
		
	<cfsavecontent variable="myxml">
		<cfoutput>
      		<entry xmlns='http://www.w3.org/2005/Atom' xmlns:gd='http://schemas.google.com/g/2005'>
      			<title type='text'>#arguments.title#</title>
        		<content type='html'>#xmlFormat(arguments.description)#</content>
				<cfif structKeyExists(arguments, "IsDraft")>
					<IsDraft>true</IsDraft>
				</cfif> 
				<cfif structKeyExists(arguments, "authorname") and structKeyExists(arguments, "authoremail")>
			          <author>
			            <name>#arguments.authorName#</name>
			            <email>#arguments.authorEmail#</email>
			          </author>
			    </cfif>
			</entry>
    	</cfoutput>
	</cfsavecontent>
	
	<cfhttp url="#mainurl#" method="post" result="result" charset="utf-8">
		<cfhttpparam type="header" name="Content-Type" value="application/atom+xml">
		<cfhttpparam type="header" name="Authorization" value="GoogleLogin auth=#getAuth(variables.bloggerservice)#">
    	<cfhttpparam type="body" value="#myxml#">
  	</cfhttp>
	
</cffunction>	
	
	
<cffunction name="updateItem" access="public" returnType="any" output="false">
	<cfargument name="item" type="string" required="true" default="post" >
	<cfargument name="blogid" type="string" required="true" >
	<cfargument name="postID" type="string" required="false" >
  	<cfargument name="title" type="string" required="true">
	<cfargument name="description" type="string" required="true">
  	<cfargument name="authorname" type="string" required="false">
  	<cfargument name="authoremail" type="string" required="false">
  	
  	<cfswitch expression="#arguments.item#">
		<cfcase value="updatePost">
			<cfset var mainurl = 'http://www.blogger.com/feeds/'&arguments.blogid&'/posts/default/'&arguments.postID>
		</cfcase>
		<cfdefaultcase>
			<cfthrow message="Bad request">
		</cfdefaultcase>	
	</cfswitch>	
	
	<cfsavecontent variable="myxml">
		<cfoutput>
			<entry xmlns='http://www.w3.org/2005/Atom'>
  				<id>tag:blogger.com,1999:blog-#arguments.blogid#.post-#arguments.postID#</id>
				<title type='text'>#arguments.title#</title>
        		<content type='html'>#xmlFormat(arguments.description)#</content>
				<cfif structKeyExists(arguments, "authorname") and structKeyExists(arguments, "authoremail")>
					<author>
			           <name>#arguments.authorName#</name>
			           <email>#arguments.authorEmail#</email>
			        </author>
				</cfif>
			</entry>
    	</cfoutput>
	</cfsavecontent>
	
	<cfhttp url="#mainurl#" method="put" result="result" charset="utf-8">
		<cfhttpparam type="header" name="Content-Type" value="application/atom+xml">
		<cfhttpparam type="header" name="Authorization" value="GoogleLogin auth=#getAuth(variables.bloggerservice)#">
    	<cfhttpparam type="body" value="#myxml#">
  	</cfhttp>
	
</cffunction>

<cffunction name="deleteItem" access="public" returnType="any" output="false">
	<cfargument name="item" type="string" required="true" default="post" >
	<cfargument name="blogid" type="string" required="true" >
	<cfargument name="postID" type="string" required="false" >
	<cfargument name="commentID" type="string" required="false" >
  	
  	<cfswitch expression="#arguments.item#">
		<cfcase value="deletePost">	
			<cfset var mainurl = "http://www.blogger.com/feeds/" &arguments.blogid& "/posts/default/" &arguments.postid>
		</cfcase>	
		<cfcase value="deleteComment">	
			<cfset var mainurl = "http://www.blogger.com/feeds/" &arguments.blogid& "/" &arguments.postid& "/comments/default/" &arguments.commentID>
		</cfcase>
		<cfdefaultcase>
			<cfthrow message="Bad request">
		</cfdefaultcase>	
	</cfswitch>	
	
	<cfhttp url="#mainurl#" method="delete" result="result" charset="utf-8">
		<cfhttpparam type="header" name="Content-Type" value="application/atom+xml">
		<cfhttpparam type="header" name="Authorization" value="GoogleLogin auth=#getAuth(variables.bloggerservice)#">
  	</cfhttp>
	
</cffunction>

<!---http://www.blogger.com/feeds/' . $blogID . '/posts/default--->
</cfcomponent>