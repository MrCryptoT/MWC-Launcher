@Echo OFF
REM IMPORTANT: DONT SHARE YOUR BATCHFILES - TAKE SECURITY SERIOUS! STAY SAFE
	
REM Edit your password so you don't constantly need to confirm the password when interacting with the cli Wallet!  
	set mypassword=NEVERSHAREYOURBATCHFILESORPASSWORD!
	
	
REM Only replace the following Variables if necessary (not everything in 1 folder)

REM Define Folders of our executables (by default our execution directory)
REM Some examples provided below, if in Doubdt, Rightclick the folder in Windows Explorer and choose "Copy Path"
	set NodeLocation=%cd%
	set WalletLocation=%cd%
	set NgrokLocation=%cd%
	set RegexHelperLocation=%cd%
	set TransactionFilename=transaction.tx 
	set Responsefilenameending=tx.response
	REM Set to "TRUE" for detailed messaged, to "FALSE" if not
	set Debugmode=TRUE
	REM Set to "TRUE" if Launcher should Quit instantly when choosing "quit"
	set CloseFast=TRUE
	set Backupfolder=%cd%\Backups
	REM An Example if the Wallet is in a subfolder called "mwc-wallet" => 
		REM set WalletLocation=%cd%\mwc-wallet 
	REM An Example if the Wallet AND this Script Are in a subfolder and the Node is "above" us => 
		REM set NodeLocation=%cd%\..\
	REM An Example for a copied path => 
		REM set NodeLocation=C:\_Custom\Bitcoin_Wallets\mwc\CLI\mwc-wallet
	REM Define which folders to search for Slatefiles, supply more by adding &&"folderlocation"&&"folderpath2" and so on 
	set folderstocheckforslatefiles=c:\users\%username%\downloads\\%NodeLocation%\\%cd%\\c:\users\%username%\Desktop
REM No Further editing needed, Logic part down here

REM Pre-Setup
For /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set mytime=%%a%%b)
	REM Make sure everything is as we assume - Sanity Check time <3
		REM Check if User edited Password =) 
		IF "%mypassword%" == "NEVERSHAREYOURBATCHFILESORPASSWORD!" Echo [ERROR:] You didn't change the password, please make sure to edit "mypassword" of the File "Launcher.bat" in %cd% (Rightclick and choose edit) && goto Quit
		REM Check if Node exists where we expect it 
		IF EXIST "%NodeLocation%\mwc.exe" (
			Echo [INFO:] Located Node
		) ELSE (
			Echo [ERROR:] Cannot locate Node! && Echo Please make sure your mwc.exe is actually saved under: &&	Echo %NodeLocation% or edit the variable NodeLocation
			goto Quit
		)
		REM Check if CLI Wallet exists where we expect it 		
		IF EXIST "%WalletLocation%\mwc-wallet.exe" (
			Echo [INFO:] Located Wallet
		) ELSE (
			Echo [ERROR:] Cannot locate Wallet! && Echo Please make sure your mwc-wallet.exe is actually saved under: && Echo %WalletLocation% or edit the variable WalletLocation
			goto Quit
		)	
		REM Check if Ngrok exists where we expect it 
		IF EXIST "%NgrokLocation%\ngrok.exe" (
			Echo [INFO:] Located Ngrok
		) ELSE (
			Echo [WARN:] Cannot locate Ngrok! (Optional Component) && ECHO Please make sure your ngrok.exe is actually saved under %NgrokLocation% or edit the variable NgrokLocation && Echo You can Download it from https://ngrok.com/download
		)
		REM Just "Log" our Slatefiles just in case, Code shouldn't delete stuff ;) 	
		IF EXIST "%Backupfolder%" (
			If "%Debugmode%" == "TRUE" Echo [INFO:] Located Backup Folder for processed Slatefiles
		) ELSE (
			mkdir %Backupfolder%
			If "%Debugmode%" == "TRUE" Echo [INFO:] Created Backup Folder for processed Slatefiles in %WalletLocation%\Backups\
		)
	REM Setup Node as needed for everything
	cd %NodeLocation%\ && start /min mwc.exe
	Echo [WARN:] MWC-Node starting please give it a Moment to synchronize! && Echo. && Echo. && Echo "What do you want to do? (Type letter and press Enter)"
	REM Define Interactive modes (Ask for startup vars?)
	
	set /p mode=(S)end, (F)inalize, (L)isten, (I)nfo, (Scan), (C)ommandprompt, (Q)uit
	Echo.
		GOTO %mode%
REM ####Modes####
:S
:s	
REM Go in Wallet Dir
	cd %WalletLocation%\
REM Send a transaction, ask which mode 
	Echo (Hint: Type "File" or "HTTP" completely!) && Echo.
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
				move /Y "%WalletLocation%\%TransactionFilename%" "%WalletLocation%\Backups\%DATE%_%mytime%__%TransactionFilename%" > nul 2>&1
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
	REM Go in Wallet Dir
	cd %WalletLocation%\

	REM Check if we can find old transactionfile!
	IF EXIST "%WalletLocation%\%TransactionFilename%" If "%Debugmode%" == "TRUE" ECHO [INFO:] Located old Transactionfile in Walletfolder. Moving to Backupfolder
	IF EXIST "%WalletLocation%\%TransactionFilename%" move /Y "%WalletLocation%\%TransactionFilename%" "%Backupfolder%\%DATE%_%mytime%__%TransactionFilename%" > nul 2>&1
	) ELSE (
		
	)
	
	REM Check if we can find the file to process, if not search or inform user!
	IF EXIST "%WalletLocation%\%Responsefilenameending%" (
		Echo [INFO:] Located a Responsefile in Walletfolder. Going to assume it s the correct one and process
		IF EXIST "%WalletLocation%\%Responsefilenameending%" goto finishFinalize
	) ELSE (
		IF not EXIST %RegexHelperLocation%\RegExCHLPR.exe goto warnnoslatefilealgo
		If "%Debugmode%" == "TRUE" ECHO Searching a Responsefile in specified Folderss
	)
				REM Call Regex Helper to quickly grab most current Slatefile if found in different folders
		for /f "tokens=*" %%i in ('%RegexHelperLocation%\RegExCHLPR.exe %folderstocheckforslatefiles% .response') do set "foundSlateFile=%%i"
		timeout 1
				IF DEFINED foundSlateFile move /Y "%foundSlateFile%" "%WalletLocation%\%Responsefilenameending%" > nul 2>&1
				If "%Debugmode%" == "TRUE" echo Current Slatefile according to Algo: %foundSlateFile%
		timeout 1
		REM Found it and moved it, no need to inform so bail 
		IF EXIST "%WalletLocation%\%Responsefilenameending%" goto finishFinalize
		REM If we arrive here no Slatefile was found, let user know Fileending might be different
		Echo [WARN:] Cannot locate Responsefilename! (Not in Downloads nor in any of the specified Folders) 
		Echo Please make sure your Responsefiles Name ends with %Responsefilenameending% 
		goto finishFinalize
		:warnnoslatefilealgo
		Echo [WARN:] Cannot locate Responsefilename! (Not in %WalletLocation%) 
		Echo Didn't find RegexCHLPR.exe to search for it in specified folders, please place Slatefile in your Wallet Folder
	
	:finishFinalize
	REM Finalize a transaction
	Echo. && Echo. && Echo.
	mwc-wallet.exe -p %mypassword% finalize -i %Responsefilenameending%
	REM Wait for Slatefile to be accessible again to move it when done (just to make sure it isnt locked)
	timeout 3
	If "%Debugmode%" == "TRUE" ECHO Moving processed Slate File into Backup Folder
	echo "%WalletLocation%\%Responsefilenameending%" "%Backupfolder%\%DATE%_%mytime%__%Responsefilenameending%" 
	move /Y "%WalletLocation%\%Responsefilenameending%" "%Backupfolder%\%DATE%_%mytime%__%Responsefilenameending%" 
	Echo. 
		goto Redo
:L
:l
	REM Go in Wallet Dir and start Wallet listen mode
	cd %WalletLocation%\ && start /min cmd.exe /c "mwc-wallet.exe -p %mypassword% listen"
	Echo. && Echo. && Echo. && Echo Wallet is listening now =) 
	rem Echo Enter your password in the newly entered windows and your Wallet will be listening!
	If Exist %NgrokLocation%\ngrok.exe set /p UsingNgrok=Should we start Ngrok? (Y)es or (N)o (Enter Letter in parenthesis and press Enter)   
	IF "%UsingNgrok%" == "Y" IF "%UsingNgrok%" == "y" IF "%UsingNgrok%" == "yes" IF "%UsingNgrok%" == "Yes"	goto ng
	Echo. && Echo. 
		goto Redo
:ng
	cd %NgrokLocation%\
	start cmd.exe /c ngrok.exe http 3415
	ECHO Use The HTTP Forwarding Addres displayed by Ngrok for Withdrawals (Only valid for 8 Hours!)
	Echo.
		goto Redo
:I
:i
	REM Go in Wallet Dir
	cd %WalletLocation%\
	mwc-wallet.exe -p %mypassword% info
	Echo.
	goto Redo
:Scan
:scan
	REM Go in Wallet Dir
	cd %WalletLocation%\
	mwc-wallet.exe -p %mypassword% scan -d
	Echo.
	goto Redo
:Redo
	Echo. && Echo. && Echo.
	REM Define Interactive modes (Ask for startup vars?)
	Echo "Anything else you want to do? (Type letter and press Enter)"
	Echo.
	set /p mode=(S)end, (F)inalize, (L)isten, (I)nfo, (Scan), (C)ommandprompt, (Q)uit
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
:C
:c
REM Interactive Shell/Commandprompt 	
REM Go in Wallet Dir and give control back to user
cd %WalletLocation%\ && cmd /k Echo type mwc-wallet.exe help to get a list of commands or mwc-wallet.exe init to initialize a new wallet

REM Author MrT, Version 0.5
:: Just a "Wrapper" around MWC Node and Wallet to make interaction a bit more Userfriendly
:: Replace the Variables if Needed I assume the following: 
:: This File, MWC-Wallet.exe and MWC.exe are all in the same Folder!
:: Hint: You will need to type your password for some interactions, please stay safe out there!
:: Dev Notes: Tested: 
::					-Listen 
::					-Send (File) 
::					-Info
::					-CmdPrompt
::					-Quit
::					-Finalize

REM Never share customized scripts that might contain passwords! (Hence this Script doesnt ask for a password or gives a way to include it)