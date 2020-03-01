@Echo OFF
REM Author MrT, Version 0.3
:: Just a "Wrapper" around MWC Node and Wallet to make interaction a bit more Userfriendly
:: Replace the Variables if Needed I assume the following: 
:: This File, MWC-Wallet.exe and MWC.exe are all in the same Folder!
:: Hint: You will need to type your password for some interactions, please stay safe out there!
REM Never share customized scripts that might contain passwords! (Hence this Script doesnt ask for a password or gives a way to include it)

	
REM TO EDIT!  Fixxed Variables (Replace if necessary!)
REM Define Folders of our executables (by default our execution directory)
	set NodeLocation=%cd%
	set WalletLocation=%cd%
	set TransactionFilename=transaction.tx 
	set Responsefilename=tx.response
	set NgrokLocation=%cd% REM This Component is optional!

REM End of Editable part, doing some simple Logic down there 	

REM Setup
	REM Make sure everything is as we assume 
	REM Sanity Check time <3
		IF EXIST "%NodeLocation%\mwc.exe" (
			Echo [INFO:] Located Node
		) ELSE (
			Echo [ERROR:] Cannot locate Node! Please make sure your mwc.exe is actually saved under %NodeLocation% or edit the variable NodeLocation
			goto Quit
		)
		IF EXIST "%NgrokLocation%\ngrok.exe" (
			Echo [INFO:] Located Ngrok
		) ELSE (
			Echo [WARN:] Cannot locate Ngrok! Please make sure your ngrok.exe is actually saved under %NgrokLocation% or edit the variable NgrokLocation
			)
			
		IF EXIST "%WalletLocation%\Backups\" (
			Echo [INFO:] Located Backup Folder for Slatefiles
		) ELSE (
		mkdir %WalletLocation%\Backups\
			Echo [INFO:] Created Backup Folder for processed Slatefiles in %WalletLocation%\Backups\
			)
			
		IF EXIST "%WalletLocation%\mwc-wallet.exe" (
			Echo [INFO:] Located Wallet
		) ELSE (
			Echo [ERROR:] Cannot locate Wallet! 
			Echo Please make sure your mwc.exe is actually saved under:
			Echo %WalletLocation% or edit the variable WalletLocation
			goto Quit
		)
			
REM Setup Node as needed for everything
	cd %NodeLocation%\
	start /min mwc.exe
	Echo [WARN:] MWC-Node starting please give it a Moment to synchronize!
	Echo.
		
REM Define Interactive modes (Ask for startup vars?)
	Echo "What do you want to do? (Type letter and press Enter)"
	Echo.
	set /p mode=(S)end, (F)inalize, (L)isten, (I)nfo, (C)ommandprompt
	Echo.
		GOTO %mode%

REM ####Modes####
	
:S
:s	

	REM Go in Wallet Dir
	cd %WalletLocation%\
	REM Send a transaction, ask which mode 
	Echo.
	Echo (Hint: Type "File" or "HTTP" completely!)
	set /p method=Send by (File) or (HTTP) 
	set /p Amount=What Amount to send?
	
	REM Move old Slatefile in Backupfolder
	IF EXIST "%WalletLocation%\%TransactionFilename%" (
		Echo [INFO:]Moved old Slatefile to Backups before creating new one
		move %WalletLocation%\%TransactionFilename% %WalletLocation%\Backups\%TransactionFilename%
	) ELSE (
	REM not needed but here cuz im lazy, find the egg, keep it =) 
	)
	
	goto %method%
		
		:File
		:file
			mwc-wallet.exe send -m file -d %TransactionFilename% %Amount%
			Echo [INFO:]Your payment File will be located in %WalletLocation%\%TransactionFilename%
			Echo.
				goto Redo
		:HTTP
		:http
			mwc-wallet.exe send -d %URL% %Amount%
			Echo.
				goto Redo
				
:F
:f
	REM Check if we can find the file to process, if not warn user!
	IF EXIST "%WalletLocation%\%Responsefilename%" (
		Echo [INFO:] Located a Responsefile matching variable
	) ELSE (
		Echo [WARN:] Cannot locate Responsefilename! Might not exist yet
		Echo Please make sure your Responsefile is actually saved under: 
		Echo %WalletLocation% and is named %Responsefilename% or edit the variable Responsefilename
	)
	
	REM Finalize a transaction
	mwc-wallet.exe finalize -i %Responsefilename%
	Echo.
	goto Redo
	
:L
:l
	REM Wallet listen mode
	start cmd.exe /k "Echo Enter your password to start listening!&&Echo Then return the the Launcher!&& mwc-wallet.exe listen"
	rem Echo Enter your password in the newly entered windows and your Wallet will be listening!
	set /p UsingNgrok=Should we start Ngrok? (Y)es or (N)o
	IF "%UsingNgrok%" == "Y" (
	goto ng
	) 
	IF "%UsingNgrok%" == "y" (
	goto ng
	) 
	Echo.
		goto Redo
	
:I
:i
	mwc-wallet.exe info
	Echo.

:Redo
	REM Define Interactive modes (Ask for startup vars?)
	Echo "Anything else - or do you want to Quit?"
	set /p mode=(S)end, (F)inalize, (L)isten, (I)nfo,(C)ommandprompt, (Q)uit
		GOTO %mode%

	
:Q
:Quit
	Echo This Window will close itself, the MWC-Wallet and the MWC-Node as soon as you press [Enter]
	Echo [WARN:] This will close all of your command prompts!
	Echo Stay safe out there! 
	pause
	taskkill /IM mwc.exe /F
	taskkill /IM mwc-wallet.exe  /F
	taskkill /IM cmd.exe  /F
	quit
REM Interactive Shell/Commandprompt overtakes this current session, give control back to uer 	
:C
:c
cmd /k Echo type mwc-wallet.exe help to get a list of commands!
