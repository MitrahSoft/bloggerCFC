/*
Name: bloggerCFC
Author: CF Mitrah (http://cfmitrah.com/blog/)
Date: 13 May 2011
*/
component extends="google" hint="Contains Authenticate Service Functions" output="false"
{
	bloggerservice = "blogger";
	public boolean function authenticate(username,password)
	{
		super.authenticate(username,password,bloggerservice);
		return true;
	}
	public any function getBlogList()
	{
		return getList('blog');
	}
	
	public any function getPostList(blogID)
	{
		return getList('post',blogID);
	}
	
	public any function getComment(blogID,postID)
	{
		return getList('comment',blogID,postID);
	}
	
	public any function publishPost(blogID,title,description,authorname,authoremail)
	{
		return publishItem('post',blogID,'',title,description,authorname,authoremail);
	}
	
	public any function updatePost(blogID,postID,title,description,authorname,authoremail)
	{
		return updateItem('updatePost',blogID,postID,title,description,authorname,authoremail);
	}
	
	public any function DraftPost(blogID,title,description,authorname,authoremail)
	{
		return publishItem('post',blogID,'',title,description,authorname,authoremail,1);
	}
	
	public any function deletePost(blogID,postID)
	{
		return deleteItem('deletePost',blogID,postID);
	}
	
	public any function publishComment(blogID,postID,title,description,authorname,authoremail)
	{
		return publishItem('comment',blogID,postId,title,description,authorname,authoremail);
	}
	
	public any function deleteComment(blogID,postID,commentID)
	{
		return deleteItem('deleteComment',blogID,postID,commentID);
	}
	public any function getList(listItem='blog',blogID,postID)
	{
		switch(arguments.listItem)
		{
			case "blog":
			{
				var mainurl = 'http://www.blogger.com/feeds/default/blogs';
				break;
			}
			case "post":
			{
				var mainurl = 'http://www.blogger.com/feeds/' &arguments.blogID& '/posts/default';
				break;
			}
			case "comment":
			{
				var mainurl = "http://www.blogger.com/feeds/" &arguments.blogID& "/" &arguments.postID& "/comments/default";
				break;
			}
			default:
			{
				 Throw(message="Bad request"); 
			}
		}
		
		var blogs = queryNew("id,title,updated,author,authoremail");
		myHttp = new Http(url="#mainurl#", method="get", result="result", charset="utf-8");
		myHttp.addParam(type="header",name="Authorization",value="GoogleLogin auth=#getAuth(bloggerservice)#");
		myHttp.addParam(type="header",name="GData-Version",value="2.0");
		myHttpResult = myHttp.send().getPrefix();
		if(!isXml(myHttpResult.filecontent))
		{
			Throw(message=myHttpResult.filecontent); 
		}
		packet = xmlParse(myHttpResult.filecontent);
		if(!structKeyExists(packet, "feed"))
		{
			Throw(message="Bad Response");
		}	
	
		if(!structKeyExists(packet.feed, "entry"))
		{
			return blogs;
		}
		
		for(i=1;i<=arrayLen(packet.feed.entry);i++)
		{
			entry = packet.feed.entry[i];
			updated = entry.updated.xmltext;
			queryAddRow(blogs);
			querySetCell(blogs, "title", entry.title.xmltext);
			parts = entry.id.xmltext.split("-");
			querySetCell(blogs, "id", parts[arrayLen(parts)]);
			querySetCell(blogs, "updated", updated);
		    querySetCell(blogs, "author", entry.author.name.xmlText);
		    querySetCell(blogs, "authoremail", entry.author.email.xmlText);
		}
		return blogs;
	}
	
	public any function publishItem(item,blogID,postID,title,description,authorname,authoremail,isDraft)
	{
		switch(item)
		{
			case 'post':
			{
				var mainurl = 'http://www.blogger.com/feeds/'&arguments.blogid&'/posts/default';
				break;
			}
			case 'comment':
			{
				var mainurl = "http://www.blogger.com/feeds/" &arguments.blogid& "/" &arguments.postid& "/comments/default";
				break;
			}
			default:
			{
				 Throw(message="Bad request"); 
			}
		}
		savecontent variable="myxml" 
		{
			WriteOutput("<entry xmlns='http://www.w3.org/2005/Atom' xmlns:gd='http://schemas.google.com/g/2005'>
      			<title type='text'>" & title & "</title>
        		<content type='html'>" & xmlFormat(description) & "</content>");
				
				if(structKeyExists(arguments, "IsDraft"))
				{
					WriteOutput("<IsDraft>true</IsDraft>");
				}
				
				if(structKeyExists(arguments, "authorname") and structKeyExists(arguments, "authoremail"))
				{
			          WriteOutput("<author>
			            <name>#arguments.authorName#</name>
			            <email>#arguments.authorEmail#</email>
			          </author>");
			    }
			WriteOutput("</entry>");
		}
		
		myHttp = new Http(url=mainurl, method="post",result="result",charset="utf-8");
		myHttp.addParam(type="header",name="Content-Type",value="application/atom+xml");
		myHttp.addParam(type="header",name="Authorization",value="GoogleLogin auth=#getAuth(bloggerservice)#");
		myHttp.addParam(type="header",name="GData-Version",value="#myxml#");
		myHttpResult = myHttp.send().getPrefix();
	}
	
	public any function updateItem(item,blogID,postID,title,description,authorname,authoremail)
	{
		switch(item)
		{
			case 'updatePost':
			{
				var mainurl = 'http://www.blogger.com/feeds/'&blogID&'/posts/default/'&postID;
				break;
			}
			default:
			{
				 Throw(message="Bad request"); 
			}
		}
		
		savecontent variable="myxml" 
		{
			WriteOutput("<entry xmlns='http://www.w3.org/2005/Atom'>
			<title type='id'>tag:blogger.com,1999:blog-"&blogid&".post-"&postID&"</id>
      			<title type='text'>" & title & "</title>
        		<content type='html'>" & xmlFormat(description) & "</content>");
				if(structKeyExists(arguments, "authorname") and structKeyExists(arguments, "authoremail"))
				{
			          WriteOutput("<author>
			            <name>"&authorname&"</name>
			            <email>"&authoremail&"</email>
			          </author>");
			    }
			WriteOutput("</entry>");
		}
		
		myHttp = new Http(url=mainurl, method="put",result="result",charset="utf-8");
		myHttp.addParam(type="header",name="Content-Type",value="application/atom+xml");
		myHttp.addParam(type="header",name="Authorization",value="GoogleLogin auth=#getAuth(bloggerservice)#");
		myHttp.addParam(type="body",value="#myxml#");
		myHttpResult = myHttp.send().getPrefix();
	}
	
	function deleteItem(item,blogID,postID,commentID)
	{
		switch(item)
		{
			case 'deletePost':
			{
				var mainurl = "http://www.blogger.com/feeds/" &blogID& "/posts/default/" &arguments.postID;
				break;
			}
			case 'deleteComment':
			{
				var mainurl = "http://www.blogger.com/feeds/" &blogID& "/" &postID& "/comments/default/" &commentID;
				break;
			}
			default:
			{
				 Throw(message="Bad request"); 
			}
		}
		
		myHttp = new Http(url=mainurl, method="delete",result="result",charset="utf-8");
		myHttp.addParam(type="header",name="Content-Type",value="application/atom+xml");
		myHttp.addParam(type="header",name="Authorization",value="GoogleLogin auth=#getAuth(bloggerservice)#");
		myHttpResult = myHttp.send().getPrefix();
	}
}