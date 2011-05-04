<!--- Taken from http://cfgoogle.riaforge.org --->
<cfcomponent output="false">

<cfset variables.authdata = structNew()>
<cfset variables.source = "camden-googlemeister-9001">

<cffunction name="authenticate" access="public" returnType="void" output="false" hint="I authenticate a user for a service. If login fails, I throw an error.">
	<cfargument name="username" type="string" required="true">
	<cfargument name="password" type="string" required="true">
	<cfargument name="service" type="string" required="true">
	<cfset var result = "">
	<cfset var realerror = "">
	<cfset var line = "">
	<cfset var dtype = "">
	<cfset var value = "">
	
	<cfhttp url="https://www.google.com/accounts/ClientLogin" method="post" result="result" charset="utf-8">
		<cfhttpparam type="formfield" name="accountType" value="HOSTED_OR_GOOGLE">
		<cfhttpparam type="formfield" name="Email" value="#arguments.username#">
		<cfhttpparam type="formfield" name="Passwd" value="#arguments.password#">
		<cfhttpparam type="formfield" name="service" value="#arguments.service#">
		<cfhttpparam type="formfield" name="source" value="#variables.source#">
	</cfhttp>
	
	<cfif findNoCase("Error", result.filecontent)><cfdump var="#result#" label="#arguments.service#"><cfabort>
		<cfset realerror = listRest(result.filecontent,"=")>
		<cfthrow message="Google Authentication Error: #realerror#">
	</cfif>
	
	<cfloop index="line" list="#result.filecontent#" delimiters="#chr(10)#">
		<cfset dtype = listFirst(line, "=")>
		<cfset value = listRest(line, "=")>
		<cfset variables.authdata[service][dtype] = value>
	</cfloop>
	
</cffunction>

<cffunction name="getAuth" access="private" returnType="string" output="false">
	<cfargument name="service" type="string" required="true">
	<cfreturn variables.authdata[arguments.service].auth>
</cffunction>

</cfcomponent>