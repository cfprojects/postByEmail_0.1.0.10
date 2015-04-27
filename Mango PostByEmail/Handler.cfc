<cfcomponent extends="BasePlugin">

	<cfset variables.name 		= "Post by Email">
	<cfset variables.id 		= "com.asfusion.mango.plugins.postByEmail">
	<cfset variables.package 	= "com/asfusion/mango/plugins/postByEmail"/>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="init" access="public" output="false" returntype="any">
		
		<cfargument name="mainManager" type="any" required="true" />
		<cfargument name="preferences" type="any" required="true" />
		
		<cfset setManager(arguments.mainManager) />
		<cfset setPreferencesManager(arguments.preferences) />
		
		<cfset initSettings(popserver='mail.mydomain.com', 
					username='myusername@mydomain.com',
					password='myPassword', 
					port='110', 
					authkey='',
					interval=600,
					usessl=0, 
					scheduleName='') />
		
		<cfreturn this/>
	</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setup" hint="This is run when a plugin is activated" access="public" output="false" returntype="any">
		<cfset var blogUrl = getManager().getBlog().getUrl() />
		
		<!--- set up scheduled task for digest mode subscriptions --->
		<cftry>
			<cfschedule action="update" task="checkEmailForPosts_#hash(blogUrl)#" 
					operation="HTTPRequest" startDate="#now()#"
					startTime="12:#randrange(0,60)# PM" url="#blogUrl#output.cfm?action=event&event=postByEmail-checkMail" 
					interval="#getSetting('interval')#" requestTimeOut="1000" />
			<cfcatch type="any">
				<cfreturn "Plugin activated, but scheduled task could not be created. 
						<br />You can create it manually (URL: #blogUrl#output.cfm?action=event&event=postByEmail-checkMail).<br />You can now <a href='generic_settings.cfm?event=showPostByEmailSettings&amp;owner=postByEmail&amp;selected=showPostByEmailSettings'>Configure Post By Email</a>">
			</cfcatch>
		</cftry>
			
		<cfreturn "Plugin Post by Email activated<br />You can now <a href='generic_settings.cfm?event=showPostByEmailSettings&amp;owner=postByEmail&amp;selected=showPostByEmailSettings'>Configure it</a>" />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="unsetup" hint="This is run when a plugin is de-activated" access="public" output="false" returntype="any">
		<cfset var blogUrl = getManager().getBlog().getUrl() />
		<cfschedule action="delete" task="checkEmailForPosts_#hash(blogUrl)#" />
		<cfreturn />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="handleEvent" hint="Asynchronous event handling" access="public" output="true" returntype="any">
		<cfargument name="event" type="any" required="true" />	
		
		<cfset var post = ""/>
				
		<cfif arguments.event.getName() EQ "postByEmail-checkMail">
			<!--- this is the call to the scheduled task,
			we need to check the email --->
			<cfset checkEmail() />
		
		</cfif>
		
		<cfreturn />

	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="processEvent" hint="Synchronous event handling" access="public" output="true" returntype="any">
		<cfargument name="event" type="any" required="true" />
		
		<cfset var data = ""/>
		<cfset var path = ""/>
		<cfset var link = "" />
		<cfset var sslSetting = 0/>
		<cfset var blogUrl = getManager().getBlog().getUrl() />
		
		<!--- admin nav event --->
		<cfif arguments.event.getName() EQ "settingsNav">
			<cfset link = structnew() />
			<cfset link.owner = "postByEmail">
			<cfset link.page = "settings" />
			<cfset link.title = "Post By Email" />
			<cfset link.eventName = "showPostByEmailSettings" />
			<cfset arguments.event.addLink(link)>
			
		<!--- admin event, make sure user is logged in --->
		<cfelseif arguments.event.getName() EQ "showPostByEmailSettings" AND getManager().isCurrentUserLoggedIn()>
			<cfset data = arguments.event.getData() />
			
			<cfif structkeyexists(data.externaldata,"apply")>
				
				<cfif NOT isNumeric(data.externaldata.interval) OR data.externaldata.interval lt 120>
					<cfset isError = true />
					<cfset data.externaldata.interval = 120 />
				</cfif>
				
				<!--- the user is saving the settings, let's save and persist them --->
				<cfif structKeyExists(data.externaldata, 'usessl')>
					<cfset sslSetting = 1 />
				<cfelse>
					<cfset sslSetting = 0 />
				</cfif>
				
				<cfset setSettings(
						popserver=data.externaldata.popserver, 
						username=data.externaldata.username,
                        password=data.externaldata.password, 
						port=data.externaldata.port,
                        authkey=data.externaldata.authkey, 
						interval=data.externaldata.interval,
                        usessl=sslSetting, 
						scheduleName=scheduleName) />
						
           		 <cfset persistSettings() /> 
				
				<!--- attempt to update the schedule --->
				<cftry>
				<cfschedule action="update" task="checkEmailForPosts_#hash(blogUrl)#" 
						operation="HTTPRequest" startDate="#now()#"
						startTime="12:#randrange(0,60)# PM" url="#blogUrl#output.cfm?action=event&event=postByEmail-checkMail" 
						interval="#getSetting('interval')#" requestTimeOut="1000" />
					<cfcatch type="any">
						<cfreturn "Plugin updated, but scheduled task could not be created. 
									<br />You can create it manually (URL: #blogUrl#output.cfm?action=event&event=postByEmail-checkMail)">
					</cfcatch>
				</cftry>
				
				<cfif isError>
					<cfset data.message.setstatus("error") />
					<cfset data.message.setType("settings") />
					<cfset data.message.settext("POP3 Interval must be greater than 119 seconds")/>
				<cfelse>
					<cfset data.message.setstatus("success") />
					<cfset data.message.setType("settings") />
					<cfset data.message.settext("Settings updated")/>
				</cfif>
			</cfif>
			
			<cfsavecontent variable="page">
				<cfinclude template="admin/settingsForm.cfm">
			</cfsavecontent>
				
			<!--- change message --->
			<cfset data.message.setTitle("Post By Email settings") />
			<cfset data.message.setData(page) />
			
		<cfelseif arguments.event.getName() EQ "runScheduledTask" AND getManager().isCurrentUserLoggedIn()>
			<cfset data = arguments.event.getData() />
			
			<cfif len(trim(getSetting('scheduleName')))>
			
				<cfschedule action="run" task="#getSetting('scheduleName')#" />
				<cfset data.message.setstatus("success") />
				<cfset data.message.setType("settings") />
				<cfset data.message.settext("Task executed")/>
			<cfelse>
				<cfset data.message.setstatus("error") />
				<cfset data.message.setType("settings") />
				<cfset data.message.settext("Task not executed. Schedule map not exist")/>
			</cfif>
			
			<cfsavecontent variable="page">
				<cfinclude template="admin/settingsForm.cfm">
			</cfsavecontent>
				
			<!--- change message --->
			<cfset data.message.setTitle("Post By Email settings") />
			<cfset data.message.setData(page) />
			
		</cfif>
		
		<cfreturn arguments.event />
		
	</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="checkEmail">
		
		<cfset var messages = "" />
		<cfset var adminUtil = getManager().getAdministrator() />
		<cfset var postResult = "" />
		<cfset var firstLine = "" />
		<cfset var authorizationKey = "" />
		<cfset var username = "" />
		<cfset var author = "" />
		<cfset var newBody = "" />
		<!--- create an instance of the java system libraries to we can enable or disable POP3 SSL as needed --->
		<!--- 
		
			IF YOUR HOST DOES NOT SUPPORT INSTANTIATING JAVA OBJECTS: you should comment out the following lines of code:
			
			<cfset var javaSystem = createObject("java", "java.lang.System") />
			<cfset var javaSystemProps = javaSystem.getProperties() />
		
			<cfif getSetting('usessl') EQ "true">
				<cfset javaSystemProps.setProperty("mail.pop3.socketFactory.class", "javax.net.ssl.SSLSocketFactory") />
			<cfelse>
				<cfset javaSystemProps.setProperty("mail.pop3.socketFactory.class", "javax.net.SocketFactory") />  
			</cfif>
			
			CFPOP does not natively support SSL. The java is the only hack we can use to enable it. Sorry, but if you 
			can't use this code you can't pop a gmail account or any account which requires an SSL connection. 
			This SSL POP3 also does not work with Railo
		--->
		<cfset var javaSystem = '' />
		<cfset var javaSystemProps = '' />
		
		<!--- turn ssl on as needed --->
		<cfif getSetting('usessl') EQ "true">
			<cfset javaSystem = createObject("java", "java.lang.System") />
			<cfset javaSystemProps = javaSystem.getProperties() />
			<cfset javaSystemProps.setProperty("mail.pop3.socketFactory.class", "javax.net.ssl.SSLSocketFactory") />
		</cfif>
		
		<cfpop action="getAll" server="#getSetting('popserver')#"
				username="#getSetting('username')#"
				password="#getSetting('password')#"
				port="#getSetting('port')#" name="messages" />
		
		<cfloop query="messages">
			<!--- check the email, if we have one to post, enter it in the database --->
			<!--- I don't have any function to get the author id from the 
			email address. If you know the username, then you would do:
			author = adminUtil.getAuthorByUsername(username), that will return 
			an author object --->
			
			<!--- the authorization key and username should exist in the first line of the message --->
			<cfset firstLine = trim(listFirst(messages.body, chr(10) & chr(13))) />
			
			<cfif listLen(trim(firstLine), " ") gt 1>
				<!--- the username should be the first element in the list, space delimited --->
				<cfset username = trim(listFirst(firstLine, " ")) />
				
				<!--- the authorization key should be the second element of the list, space delimited --->
				<cfset authorizationKey = trim(listLast(firstLine, " "))>
				
				<!--- if the auth key is the system's auth key and isnt blank and the username isnt blank we can proceed --->
				<cfif authorizationKey EQ getSetting('authkey') and len(trim(getSetting('authkey'))) and len(trim(username))>
					<!--- get the user's author id --->
					<cfset author = adminUtil.getAuthorByUsername(username)/>
					
					<cfif len(trim(author.getID()))>
						<!--- create the body by stripping off the key --->
						<cfset newBody = paragraphFormat(replace(messages.body, firstLine, '')) />
					
						<cfset postResult = adminUtil.newPost(messages.subject,
								newBody, <!--- body of the post --->
								'', <!---  post exceprt: can be empty --->
								'true',<!--- post or post as a draft :true/false (if false, it will be a draft) --->
								author.getID(), <!--- mango blog userID. --->
								'true',<!--- allow comments: true/false --->
								messages.date <!---  date and time (ie: now()) --->) />
								
						<!--- delete the message after its been "read" so we can ensure its not pulled in again --->
						<cfpop action="delete" server="#getSetting('popserver')#"
							username="#getSetting('username')#"
							password="#getSetting('password')#"
							port="#getSetting('port')#" messagenumber="#messages.messagenumber#" />
					
					</cfif>
				</cfif>
			</cfif>
		</cfloop>
		
		<!--- turn off SSL for pop3 --->
		<cfif getSetting('usessl') EQ "true">
			<cfset javaSystemProps.setProperty("mail.pop3.socketFactory.class", "javax.net.SocketFactory") />
		</cfif>
		
	</cffunction>

</cfcomponent>