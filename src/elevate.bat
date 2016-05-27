<!-- : Begin batch script
@echo off
cscript //nologo "%~f0?.wsf" %*
exit /b

----- Begin wsf script --->
<job><script language="VBScript">' The MIT License
'
' Copyright (c) 2016 Juan Cruz Viotti. https://github.com/jviotti
'
' Permission is hereby granted, free of charge, to any person obtaining a copy
' of this software and associated documentation files (the "Software"), to deal
' in the Software without restriction, including without limitation the rights
' to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
' copies of the Software, and to permit persons to whom the Software is
' furnished to do so, subject to the following conditions:
'
' The above copyright notice and this permission notice shall be included in
' all copies or substantial portions of the Software.
'
' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
' IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
' FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
' AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
' LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
' OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
' THE SOFTWARE.

'-------------------------------------------------
' Usage: cscript //nologo elevate.vbs <command...>
'-------------------------------------------------

Set Shell = CreateObject("Shell.Application")
Set WScriptShell = CreateObject("WScript.Shell")
Set fs = CreateObject("Scripting.FileSystemObject")

' VBScript constants
FS_FLAGS_READ = 1
FS_ENCODING_ASCII = 0
FS_SPECIAL_FOLDER_TEMP = 2
SHELL_DISPLAY_HIDDEN = 0

'-------------------------------------------------
' @summary Get a temporary file path
' @function
' @returns {String} temporary file path
'-------------------------------------------------
Public Function GetTemporaryFile()
  Randomize()

  Dim returnValue
  Dim index
  returnValue = ""
  For index = 1 To 15
    returnValue = returnValue & Chr(Int(26 * Rnd + 97))
  Next

  Set tempFolder = fs.GetSpecialFolder(FS_SPECIAL_FOLDER_TEMP)
  GetTemporaryFile = tempFolder & "\win-elevate-" & returnValue & ".out"
End Function

DEFAULT_TIMEOUT = 500
TEMPORARY_FILE = GetTemporaryFile()
EOF_MARK = "Win-Elevate EOF"

' WshArgument objects are not arrays, therefore we
' can't use helper functions like `Join` on them.
' As a workaround, we manually convert it to an array.
' See http://stackoverflow.com/a/18010947/1641422
ReDim argv(WScript.Arguments.Count - 1)
For index = 0 To WScript.Arguments.Count - 1
  argv(index) = WScript.Arguments(index)
Next

' Make sure we always start fresh
If fs.FileExists(TEMPORARY_FILE) Then
  fs.DeleteFile(TEMPORARY_FILE)
End If

' Make sure the elevated command is ran from the same
' directory that this script is being run from, so
' relative paths are resolved correctly.
ShellCommand = "cd /d " & WScriptShell.CurrentDirectory

' We pipe both `stdout` and `stderr` from the command to a single
' file. This means we can't distinguish their procedence later on,
' but that's a fair trade for the sake of simplicity.
' See http://stackoverflow.com/a/1420981/1641422
ShellCommand = ShellCommand & " & " & Join(argv) & " > " & TEMPORARY_FILE & " 2>&1"

' In order to know when the command finished, we append an EOF mark
' to the temporary log file right after the command exitted.
ShellCommand = ShellCommand & " & echo " & EOF_MARK & " >> " & TEMPORARY_FILE

' We could have elevated the command directly rather than elevating
' `cmd.exe` and executing the original through it, however the
' latter approach is needed for file redirection to work.
Shell.ShellExecute "cmd.exe", "/s /c " & ShellCommand, "", "runas", SHELL_DISPLAY_HIDDEN

' Make sure the temporary log file already exists before opening it,
' otherwise we will be creating a new file, but when the original process
' replaces it in order to pipe to it, we'll be stuck with the older
' file handle, and therefore we'll not get any data back.
Do While fs.FileExists(TEMPORARY_FILE) <> True
  WScript.Sleep DEFAULT_TIMEOUT
Loop

Set FileObject = fs.GetFile(TEMPORARY_FILE)
Set FileStream = FileObject.OpenAsTextStream(FS_FLAGS_READ, FS_ENCODING_ASCII)

' Tail temporary file and output to `stdout`
Do While False <> True
  Do While FileStream.AtEndOfStream <> False
    WScript.Sleep DEFAULT_TIMEOUT
  Loop

  TextLine = FileStream.ReadLine

  If (TextLine = "^C") Or (InStr(TextLine, EOF_MARK) = 1) Then
    FileStream.Close

    ' Cleanup no longer needed temporary file
    If fs.FileExists(TEMPORARY_FILE) Then
      fs.DeleteFile(TEMPORARY_FILE)
    End If

    Wscript.Quit 0
  End If

  Wscript.Echo TextLine
Loop
</script></job>