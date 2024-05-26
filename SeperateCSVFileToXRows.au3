#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=zahnraeder.ico
#AutoIt3Wrapper_Outfile=SeperateCSVFileToXRows_i386.exe
#AutoIt3Wrapper_Outfile_x64=SeperateCSVFileToXRows_64Bit.exe
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_Res_Description=Split csv file to define row number wo GUI
#AutoIt3Wrapper_Res_Fileversion=1.0.0.0
#AutoIt3Wrapper_Res_ProductName=SeperateCSVFileToXRows
#AutoIt3Wrapper_Res_ProductVersion=1.00
#AutoIt3Wrapper_Res_CompanyName=LinkEng
#AutoIt3Wrapper_Res_LegalCopyright=LinkEng
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <File.au3>
#include <MsgBoxConstants.au3>

#cs
	Split big csv file to a defined row number csv-files
	Version 1.00 only File creation wo folders and some other extras
	#####################################################################################################################################
	## Version	Creator		Comments
	##-----------------------------------------------------------------------------------------------------------------------------------
	## 1.00		HV			Initial Version, without progress line, wo some extras - pure script
	##
	#####################################################################################################################################
#ce

; Read Function
ReadFileToArray()

Func ReadFileToArray()
		; Read ini File for defaults:
		$inifilename = "config.ini"
		$linecount = Number(IniRead($inifilename, "Config", "LineCount", "0"))
		$lineEndCount = Number(IniRead($inifilename, "Config", "LineEndCount", "0"))

		$linecount = $linecount + 1

		; Work with file dialog and define filename and path
		Local Const $sMessage = "Select a single file of CSV type."
		Dim $szDrive, $szDir, $szFName, $szExt
		Local $sFileOpenDialog = FileOpenDialog($sMessage, "C:\", "CSV (*.csv)", $FD_FILEMUSTEXIST)

        ; Replace instances of "|" with @CRLF in the string returned by FileOpenDialog.
        $sFileOpenDialog = StringReplace($sFileOpenDialog, "|", @CRLF)

		Local $iFileExists = FileExists($sFileOpenDialog)
		; File are exits then work starts
		If $iFileExists Then

			FileChangeDir($sFileOpenDialog)
			; Split Drive, path, filename, file extenion
			_PathSplit($sFileOpenDialog, $szDrive, $szDir, $szFName, $szExt)

			; Read full Fileinformation and open the source file
			$file = $sFileOpenDialog

			FileOpen($file, 0)
			$b = 0
			$c = 1
			$f = $linecount
			ProgressOn("Progress Bar", "Samples progress bar", "Working...")
			$d = 100 / Number(_FileCountLines($file))
			; Fileline reading line by line
			For $i = 1 to _FileCountLines($file)
				; First line are the headerline for all files
				If $i = 1 then $Headline = FileReadLine($file, $i)
				; If target file are not exists then create and insert the headerline in to
				If Not FileExists(@WorkingDir & "\" & $szFName & "_" & $c & ".csv") Then
					$sFilePath = @WorkingDir &  "\" & $szFName & "_" & $c & ".csv"
					$hFileOpen = FileOpen($sFilePath, $FO_APPEND)
					FileWriteLine($hFileOpen, $Headline)
				; Write Lines into the target file:
				ElseIf $i > 1 Then
					$line = FileReadLine($file, $i)
					FileWriteLine($hFileOpen, $line)
					$d = $d * 100
					ProgressSet($d)
					;Sleep(5)
				EndIf
				; check, if the linecounter lower than defined do nothing.
				; if reach the linecount then save the file and the next file will create upper code
 				If $i > $linecount - 1 Then
					$a = $i
					$b = Number($a)/$linecount
					$sum = StringInStr($b,".")
					If $sum = 0 Then
						FileClose($hFileOpen)
						$c = $c + 1
					; When LineEndCounter are defined the Script will stop when reach the number of loops
					If $lineEndCount > 0 Then
						If $i > $lineEndCount then ExitLoop
					EndIf
					EndIf
				EndIf
			Next
			; Inform the User Script are done all work
			FileClose(@WorkingDir &  "\" & $szFName & "_" & $c + 1 & "End.csv")
			ProgressSet(100, "Done!")
			Sleep(1750)
			MsgBox($MB_SYSTEMMODAL, "Finished", "Your Split files are all done !") ; & @CRLF & $sFileOpenDialog)
		Elseif $sFileOpenDialog <> "" Then
			; When the user select a file, this are not exists:
			MsgBox($MB_SYSTEMMODAL, "", "The file doesn't exist." & @CRLF & "FileExist returned: " & $iFileExists)
		EndIf

EndFunc   ;==>Example