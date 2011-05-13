/*

  Tag based version taken from http://cfgoogle.riaforge.org
 
Name: Google.cfc
Modified By: CF Mitrah (http://cfmitrah.com/blog/)
Date: 13 May 2011
*/
component hint="Contains Authenticate Service Functions" output="false"
{
	authdata = structNew();
	source = "camden-googlemeister-9001";
	public any function authenticate(username,password,service)
	{
		var result = "";
	    var realerror = "";
		var line = "";
		var dtype = "";
		var value = "";
		
		myHttp = new Http(url="https://www.google.com/accounts/ClientLogin", method="post",charset="utf-8");
		myHttp.addParam(type="formfield",name="accountType",value="HOSTED_OR_GOOGLE");
		myHttp.addParam(type="formfield",name="Email",value="#username#");
		myHttp.addParam(type="formfield",name="Passwd",value="#password#");
		myHttp.addParam(type="formfield",name="service",value="#service#");
		myHttp.addParam(type="formfield",name="source",value="#source#");
		myHttpResult = myHttp.send().getPrefix();
		
		if(findNoCase("Error", myHttpResult.filecontent))
		{
			realerror = listRest(myHttpResult.filecontent,"=");
			Throw(message="Google Authentication Error: #realerror#");
		}
		
		
		var a = listToArray(myHttpResult.filecontent,chr(10));
		var i = "";
		for (i = 1; i LTE arrayLen(a); i = i + 1)
		{
			
			dtype = listFirst(a[i], "=");
			value = listRest(a[i], "=");
			authdata[service][dtype] = value;
		}
	}
	private string function getAuth(service)
	{
		
		return authdata[arguments.service].auth;
	}
}