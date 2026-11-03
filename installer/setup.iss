; Script generated for CPRay Gaming Inno Setup Installer
#define MyAppName "CPRay Gaming"
#define MyAppVersion "0.3.5"
#define MyAppPublisher "CPRay Team"
#define MyAppURL "https://github.com/ESp3cter/CPRay-Gaming"
#define MyAppExeName "cpray_gaming.exe"

[Setup]
AppId={{D37E8492-5F10-4821-9872-4B27C175A209}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DisableProgramGroupPage=yes
OutputDir=..\build\installer
OutputBaseFilename=CPRay-Gaming-Setup
SetupIconFile=..\assets\app_icon.ico
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
CloseApplications=yes
CloseApplicationsFilter=*.exe
PrivilegesRequired=admin

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon; IconFilename: "{app}\{#MyAppExeName}"

[Registry]
Root: HKLM; Subkey: "Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"; ValueType: string; ValueName: "{app}\{#MyAppExeName}"; ValueData: "~ RUNASADMIN"; Flags: uninsdeletevalue
Root: HKCU; Subkey: "Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"; ValueType: string; ValueName: "{app}\{#MyAppExeName}"; ValueData: "~ RUNASADMIN"; Flags: uninsdeletevalue

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall shellexec

[Code]
// Helper function to locate the 32-bit uninstall string from WOW6432Node
function GetOld32BitUninstallString(): String;
var
  sUnInstPath: String;
  sUnInstallString: String;
begin
  sUnInstPath := 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{D37E8492-5F10-4821-9872-4B27C175A209}_is1';
  sUnInstallString := '';
  
  if not RegQueryStringValue(HKLM32, sUnInstPath, 'UninstallString', sUnInstallString) then
    RegQueryStringValue(HKCU32, sUnInstPath, 'UninstallString', sUnInstallString);
    
  Result := sUnInstallString;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  sUnInstallString: String;
  iResultCode: Integer;
begin
  if CurStep = ssInstall then
  begin
    // Check if previous 32-bit version was installed in WOW6432Node
    sUnInstallString := GetOld32BitUninstallString();
    if sUnInstallString <> '' then
    begin
      sUnInstallString := RemoveQuotes(sUnInstallString);
      Exec(sUnInstallString, '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART', '', SW_HIDE, ewWaitUntilTerminated, iResultCode);
    end;
    
    // Clean up legacy 32-bit folder if leftover
    if DirExists(ExpandConstant('{autopf32}\{#MyAppName}')) then
    begin
      DelTree(ExpandConstant('{autopf32}\{#MyAppName}'), True, True, True);
    end;
  end;
end;
