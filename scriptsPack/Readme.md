Readme _ScriptsPack.pkg

If you have some scripts needed to be put together into one package, this is one choice. 

This is a modification of Greg Neagle's Payload-free package, the package can be found at  
https://managingosx.wordpress.com/2010/02/18/payload-free-package-template/

the postflight scripts load all the scripts in the ./Scripts subfolder in alphabetical 
order, even if the script file is hidden by leading ".".

put your data files in Scripts/Data subfolder, postflight passes ./Data as first parameter
to each of scripts.



