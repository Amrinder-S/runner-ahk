; Get the directory path and timeout from config.ini or prompt the user if not defined
IniFile := A_ScriptDir "\config.ini"
IfExist, %IniFile%
{
    IniRead, Directory, %IniFile%, Settings, Directory
    If (Directory = "")
        Directory := SelectDirectory("Please select the directory to check for AHK scripts:")

    IniRead, Timeout, %IniFile%, Settings, Timeout
    If (Timeout = "")
        Timeout := InputBox("Please enter the timeout value in seconds:", "Timeout")
}
Else
{
    Directory := SelectDirectory("Please select the directory to check for AHK scripts:")
    Timeout := InputBox("Please enter the timeout value in seconds:", "Timeout")
    
    ; Write directory and timeout to config.ini
    IniWrite, %Directory%, %IniFile%, Settings, Directory
    IniWrite, %Timeout%, %IniFile%, Settings, Timeout
}

; Check if the directory was selected
If Directory = ""
{
    MsgBox, 16, Error, No directory selected. Exiting the script.
    ExitApp
}

; Validate the directory path
IfNotExist, %Directory%
{
    MsgBox, 16, Error, The specified directory does not exist.
    ExitApp
}

Loop
{
    ; Loop through files in the directory
    Loop, Files, %Directory%\*.ahk
    {
        ; Get the path of the AHK script
        AHKScript := A_LoopFileLongPath

        ; Execute the AHK script
        Run, % AHKScript

        ; Check if the script launched successfully
        If ErrorLevel
        {
            MsgBox, 16, Error, Failed to execute the AHK script: %AHKScript%
            Continue
        }

        ; Wait for the script to finish running
        Sleep, 1000
        Process, WaitClose, % "ahk_exe " A_ScriptFullPath

        ; Check if the script process closed successfully
        If ErrorLevel
        {
            MsgBox, 16, Error, The AHK script process did not close properly: %AHKScript%
            Continue
        }

        ; Delete the AHK script file after executing it
        FileDelete, % AHKScript
        If ErrorLevel
        {
            MsgBox, 16, Error, Failed to delete the AHK script file: %AHKScript%
            Continue
        }
    }

    ; Wait for the specified timeout before checking again
    Sleep, % Timeout * 1000
}

SelectDirectory(prompt) {
    FileSelectFolder, SelectedFolder, %A_ScriptDir%, 3, %prompt%
    If ErrorLevel ; User canceled the dialog
        Return ""  ; Return an empty string
    Return SelectedFolder
}

InputBox(prompt, title) {
    InputBox, InputValue, %title%, %prompt%
    Return InputValue
}
