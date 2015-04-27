	Post By Email is a plugin for Mango Blog (www.mangoblog.org) that allows you to post 
	blog articles via email.
	
	There are some things you need to be aware of! It is CRITICAL that you read this entire 
	document before installing Post By Email.

	1.	PostByEmail uses a core java component to handle SSL POP3 for servers like 
		GMail. If you are on a shared host it is highly likely this won't work for 
		you. If you cannot instantiate Java classes on your server using createObject 
		then you should NOT enable SSL. Also, SSL POP3 does not work with 
		Railo. If the Railo team implements SSL for POP3 then I will make modifications
		as necessary to handle compatibility.
	
	2. 	PostByEmail contains a bit of a hack for authenticating the user via email. 
		My goal was to ensure spam did not make it onto the blog. I enforced an 
		email authentication key and username to be sent in the contents of the message. 
		Username is the user's Mango blog logon username. The username and authentication 
		key MUST be on the FIRST line of the email. There must be NOTHING else on the 
		first line. Username must come before authentication key and they must be 
		separated by a space. Ya, I know, it's pretty hack-ish, but it does serve the 
		purpose. 
		
		I am open to other methods if you have suggestions. People have recommended 
		whitelists to me but that seems to be too restrictive, at least for my clients. 
		Others have suggested an auth response system, which seems to be too much of a 
		time investment for this plugin. If you have any better ideas let me know!
		
		The authentication key is server-wide. It can be changed in the settings after
		installation.
		
		Here is an example of the message format:
		
		myUsername myAuthKey
		This is my message that will be posted to the blog!
		
	3.	Email in general is a horrible protocol for this type of messaging. I really do
		not recommend using this plugin unless you are aware that there is a possibility 
		your blog will get hacked using this method, or that an email could potentially
		slip by the filters and make it onto your blog. Email messages are sent as unencrypted
		text and therefore it is possible that someone could gain access to post to
		your blog. This is also the reason I chose to use an authentication key rather than the
		user's password. If the authentication key is compromised it will be impossible for the
		someone to log into the Mango Blog and cause further damage.
		
	4.	I recommend a dedicated email address for this purpose. Do not use the email address in
		any communications and it will reduce the chance that spam may make it onto your blog.
		By the way, I don't do email support. If this plugin isn't working for you or you can't
		figure out how to connect to your mail server I am not likely to have time to help 
		troubleshoot your issue.
		
	5.	This plugin will DELETE messages as it receives them, regardless if they are valid posts
		or not. This prevents duplicate email addresses as well as eliminate any bad messages 
		automatically, theoretically eliminating the need to maintain the mailbox. You must 
		also be certain that your POP3 server settings are set to allow these messages to be
		deleted or marked as deleted so they will not be duplicated each time the server checks
		the mailbox.
	6. The Interval setting in the Post By Email settings determines how often the POP schedule runs. 
		It defaults to 10 minutes and can not be set lower than 2 minutes.