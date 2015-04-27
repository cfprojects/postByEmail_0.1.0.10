<cfoutput>
<form method="post" action="#cgi.script_name#">

	<p>
		<label for="popserver">POP3 server:</label>
		<span class="hint">This is the DNS name of your POP3 email server</span>
		<span class="field"><input type="text" id="popserver" name="popserver" value="#getSetting('popserver')#" size="20" class="required" /></span>
	</p>
	<p>
		<label for="port">POP3 Port:</label>
		<span class="hint">This is the POP3 port. This is generally port 110</span>
		<span class="field"><input type="text" id="port" name="port" value="#getSetting('port')#" size="5" class="required" /></span>
	</p>
	<p>
		<label for="usessl">Use SSL:</label>
		<span class="hint">This determines if the POP3 server requires SSL. Please review the documentation before using this.</span>
		<span class="field"><input type="checkbox" id="usessl" name="usessl" value="true"<cfif getSetting('usessl')> checked</cfif> /></span>
	</p>
	<p>
		<label for="interval">Interval (in seconds!):</label>
		<span class="hint">How often, in seconds, the schedule is run. Recommended setting is 600 seconds (10 minutes).</span>
		<span class="field"><input type="text" id="interval" name="interval" value="#getSetting('interval')#" size="5" class="required digits" /></span>
	</p>
	<p>
		<label for="username">Username:</label>
		<span class="hint">This is the username used to check the POP3 account</span>
		<span class="field"><input type="text" id="username" name="username" value="#getSetting('username')#" size="20" class="required" /></span>
	</p>
	<p>
		<label for="password">Password:</label>
		<span class="hint">This is the password used to check the POP3 account</span>
		<span class="field"><input type="password" id="password" name="password" value="#getSetting('password')#" size="20" class="required" /></span>
	</p>
	<p>
		<label for="authkey">Email Authentication Key:</label>
		<span class="hint">This is the password you use in the first line of your email to authenticate</span>
		<span class="field"><input type="text" id="authkey" name="authkey" value="#getSetting('authkey')#" size="20" class="required" /></span>
	</p>
	
	<div class="actions">
		<input type="submit" class="primaryAction" value="Submit"/>
		<input type="hidden" value="event" name="action" />
		<input type="hidden" value="showPostByEmailSettings" name="event" />
		<input type="hidden" value="true" name="apply" />
		<input type="hidden" value="postByEmail" name="selected" />
	</div>
</form>
<form method="post" action="#cgi.script_name#">
<div class="actions">
		<input type="submit" class="primaryAction" value="Run scheduled task now"/>
		<input type="hidden" value="event" name="action" />
		<input type="hidden" value="runScheduledTask" name="event" />
		<input type="hidden" value="true" name="apply" />
		<input type="hidden" value="postByEmail" name="selected" />
	</div>
</form>
</cfoutput>