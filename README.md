# MWC Launcher
 A Script to Wrap around the MWC Wallet and MWC Node to make transactions easier using the CLI Wallet
 
 Simply Copy the Launcher into the same Directory as your mwc-wallet.exe and mwc.exe
 
## This script assumes the following:
 This File, MWC-Wallet.exe and MWC.exe are all in the same Folder!
 
 *Replace the following Variables if Needed:*
 - NodeLocation=PathofyourNodeDirectory
 - WalletLocation=PathofyourCLIWallet
 - TransactionFilename=Whatevernameyourtransactionfilesshouldhave
 - Responsefilename=thenameofyourreceivedresposefile
 - NgrokLocation=PathofyourNgrokDirectory
	
Remarks: 
I didn't include the password parameter intentionally. 
For Security concerns I think this should only be done by advanced users and can easily be implmeneted if you'd want to!

Ngrok's custom subdomains are sadly locked behind a payed plan. (And if implemented the Owner probably could inspect all the traffic which isn't really ethical. Therefore I cannot automate Ngrok to the point I wanted, you'll still need to manually get your Ngrok URL (which changes everytime)
