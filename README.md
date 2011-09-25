Description
-----------
This program monitors your Roku Soundbridge device for playing songs, then
scrobbles them to your account. All you need is to change your config file
to something like the following:

<b>config/config.rb</b>
<pre>
username = "MyLASTFMUsername"
password = "MyLASTFMPassword"
rokuaddress = "address/hostname of roku Soundbridge"
</pre>

Note: Some people(Me included) would rather not keep their password in plaintext,
so running this with your password in the text file will give a polite warning to
replace your
<pre>
password = "MyLASTFMPassword"
</pre>
line with:
<pre>
	authstring ="md5"
</pre>

After that just run it with ./l4r.rb