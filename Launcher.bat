@Echo OFF
REM IMPORTANT: DONT SHARE YOUR BATCHFILES
REM TAKE SECURITY SERIOUS! STAY SAFE
	
REM TO EDIT!  
	set mypassword=NEVERSHAREYOURBATCHFILESORPASSWORD!



REM Only replace if necessary
REM Define Folders of our executables (by default our execution directory)
	set NodeLocation=%cd%
	set WalletLocation=%cd%
REM Ngrok is optional but heavilly recommended!
	set NgrokLocation=%cd%
REM Names of Slate Files 
	set TransactionFilename=transaction.tx 
	set Responsefilename=tx.response
REM Set to "TRUE" for detailed messaged, to "FALSE" if not
	set Debugmode=FALSE
REM Set to "TRUE" if Launcher should Quit instantly when choosing "quit"
	set CloseFast=FALSE
	
REM End of Editable part, doing some simple Logic down there 	


REM Setup
	REM Make sure everything is as we assume 
	REM Sanity Check time <3
		
		REM Check if User edited Password =) 
		IF "%mypassword%" == "NEVERSHAREYOURBATCHFILESORPASSWORD!" Echo [ERROR:] You didn't change the password, please make sure to edit "mypassword" of the File "Launcher.bat" in %cd% (Rightclick and choose edit) && goto Quit
		REM Check if Node exists where we expect it 
		IF EXIST "%NodeLocation%\mwc.exe" (
			Echo [INFO:] Located Node
		) ELSE (
			Echo [ERROR:] Cannot locate Node! Please make sure your mwc.exe is actually saved under %NodeLocation% or edit the variable NodeLocation
			goto Quit
		)
		REM Check if CLI Wallet exists where we expect it 		
		IF EXIST "%WalletLocation%\mwc-wallet.exe" (
			Echo [INFO:] Located Wallet
		) ELSE (
			Echo [ERROR:] Cannot locate Wallet! 
			Echo Please make sure your mwc.exe is actually saved under:
			Echo %WalletLocation% or edit the variable WalletLocation
			goto Quit
		)	
		REM Check if Ngrok exists where we expect it 
		IF EXIST "%NgrokLocation%\ngrok.exe" (
			Echo [INFO:] Located Ngrok
		) ELSE (
			Echo [WARN:] Cannot locate Ngrok! (Optional Component) && ECHO Please make sure your ngrok.exe is actually saved under %NgrokLocation% or edit the variable NgrokLocation && Echo You can Download it from https://ngrok.com/download
		)
		REM Just "Log" our Slatefiles just in case, Code shouldn't delete stuff ;) 	
		IF EXIST "%WalletLocation%\Backups\" (
			If "%Debugmode%" == "TRUE" Echo [INFO:] Located Backup Folder for processed Slatefiles
			
		) ELSE (
			mkdir %WalletLocation%\Backups\
			If "%Debugmode%" == "TRUE" Echo [INFO:] Created Backup Folder for processed Slatefiles in %WalletLocation%\Backups\
		)
			
		
			
REM Setup Node as needed for everything
	cd %NodeLocation%\
	start /min mwc.exe
	Echo [WARN:] MWC-Node starting please give it a Moment to synchronize!
	Echo.
		
REM Define Interactive modes (Ask for startup vars?)
	Echo.
	Echo "What do you want to do? (Type letter and press Enter)"
	Echo.
	set /p mode=(S)end, (F)inalize, (L)isten, (I)nfo, (C)ommandprompt, (Q)uit 
	Echo.
		GOTO %mode%

REM ####Modes####
	
:S
:s	

	REM Go in Wallet Dir
	cd %WalletLocation%\
	REM Send a transaction, ask which mode 
	Echo (Hint: Type "File" or "HTTP" completely!)
	Echo.
	set /p method=Send by (File) or (HTTP) 
	Echo.
	set /p Amount=What Amount to send? (Enter how many MWC you want to send as a number and press Enter)   
	Echo.
			
	goto %method%
		
		:File
		:file
		
		REM Move old Slatefile in Backupfolder
		IF EXIST "%WalletLocation%\%TransactionFilename%" (
			Echo [INFO:] Located a TransactionFile in Walletfolder, Moving to Backupfolder so we can create a new one
			If "%Debugmode%" == "TRUE" Echo [INFO:]Moved old Slatefile to Backups before creating new one
			move "%WalletLocation%\%TransactionFilename%" "%WalletLocation%\Backups\%DATE%_%TIME%__%TransactionFilename%" >NULL
		) ELSE (
		REM not needed but here cuz im lazy, find the egg, keep it =) 
		)
		
			mwc-wallet.exe -p %mypassword% send -m file -d %TransactionFilename% %Amount%
			Echo [INFO:]Your payment File will be located in %WalletLocation%\%TransactionFilename%
			Echo.
				goto Redo
		:HTTP
		:http
			mwc-wallet.exe -p %mypassword% send -d %URL% %Amount%
			Echo.
				goto Redo
				
:F
:f
	REM Check if we can find the file to process, if not search or inform user!
	IF EXIST "%WalletLocation%\%Responsefilename%" (
		Echo [INFO:] Located a Responsefile in Walletfolder
		IF EXIST "%WalletLocation%\%Responsefilename%" goto finishFinalize
	) ELSE (
		If "%Debugmode%" == "TRUE" ECHO Searching a Responsefile in Downloads, Walletfolder was empty
	)
		IF EXIST "c:\users\%username%\Downloads\%Responsefilename%" move "c:\users\%username%\Downloads\%Responsefilename%" "%WalletLocation%\%Responsefilename%" >NULL
		REM Found it and moved it, no need to inform so bail 
		IF EXIST "%WalletLocation%\%Responsefilename%" goto finishFinalize
		Echo [WARN:] Cannot locate Responsefilename! (Not in Downloads nor in WalletFolder) 
		Echo Please make sure your Responsefile is actually named  %Responsefilename% 
		
		
	:finishFinalize
	REM Finalize a transaction
	Echo.
	Echo.
	Echo.
	mwc-wallet.exe -p %mypassword% finalize -i %Responsefilename%
	REM Wait for Slatefile to be accessible again to move it when done (just to make sure it isnt locked)
	timeout 5 >NULL
	If "%Debugmode%" == "TRUE" ECHO Moving processed Slate File into Backup Folder
	move "%WalletLocation%\%Responsefilename%" "%Backupfolder%\%DATE%_%TIME%__%Responsefilename%" >NULL
	Echo.
	goto Redo
	
:L
:l
	REM Wallet listen mode
	start cmd.exe /c "mwc-wallet.exe -p %mypassword% listen"
	Echo.
	Echo.
	Echo.
	Echo.
	Echo Wallet is listening now =) 
	rem Echo Enter your password in the newly entered windows and your Wallet will be listening!
	set /p UsingNgrok=Should we start Ngrok? (Y)es or (N)o (Enter Letter in parenthesis and press Enter)   
	Echo.
	IF "%UsingNgrok%" == "Y" (
	goto ng
	) 
	IF "%UsingNgrok%" == "y" (
	goto ng
	) 
	IF "%UsingNgrok%" == "yes" (
	goto ng
	)
	IF "%UsingNgrok%" == "Yes" (
	goto ng
	)
	Echo.
	goto Redo
:ng
	cd %NgrokLocation%\
	start cmd.exe /c ngrok.exe http 3415
	ECHO Use The HTTP Forwarding Addres displayed by Ngrok for Withdrawals (Only valid for 8 Hours!)
	Echo.
	goto Redo
:I
:i
	mwc-wallet.exe -p %mypassword% info
	Echo.

:Redo
	Echo.
	Echo.
	Echo.
	REM Define Interactive modes (Ask for startup vars?)
	Echo "Anything else you want to do? (Type letter and press Enter)"
	Echo.
	set /p mode=(S)end, (F)inalize, (L)isten, (I)nfo, (C)ommandprompt, (Q)uit   
	Echo.
		GOTO %mode%
		
:Q
:Quit
	Echo.
	Echo This Window will close itself, the MWC-Wallet and the MWC-Node as soon as you press [Enter]
	Echo [WARN:] This will close all of your command prompts!
	ECHO.
	Echo Stay safe out there! NEVER SHARE YOUR BATCHFILES!!!
	If "%CloseFast%" == "FALSE" pause
	taskkill /IM mwc.exe /F
	taskkill /IM mwc-wallet.exe  /F
	taskkill /IM ngrok.exe  /F
	taskkill /IM cmd.exe  /F
	quit
REM Interactive Shell/Commandprompt overtakes this current session, give control back to uer 	
:C
:c
cmd /k Echo type mwc-wallet.exe help to get a list of commands!




REM Author MrT, Version 0.4
:: Just a "Wrapper" around MWC Node and Wallet to make interaction a bit more Userfriendly
:: Replace the Variables if Needed I assume the following: 
:: This File, MWC-Wallet.exe and MWC.exe are all in the same Folder!
:: Hint: You will need to type your password for some interactions, please stay safe out there!
REM Never share customized scripts that might contain passwords! (Hence this Script doesnt ask for a password or gives a way to include it)

