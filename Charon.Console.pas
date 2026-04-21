unit Charon.Console;

interface

uses
  Charon.Types;

type
  IConsoleRunner = interface(IInterface)
    ['{74E4B783-347F-4E75-8D66-28B7BF2F3BFA}']
    function GetWelcomeText: string;
    procedure SetWelcomeText(const AValue: string);
    procedure Start(const AServer: IWebServer);
    procedure Stop;
    property WelcomeText: string read GetWelcomeText write SetWelcomeText;
  end;

var
  ConsoleRunner: IConsoleRunner;

implementation

uses
  System.SysUtils,
  {$IF Defined(MSWINDOWS)}
  Winapi.Windows;
  {$ENDIF}
  {$IF Defined(POSIX)}
  Posix.Signal;
  {$ENDIF}

const
  cPrompt = '➡  ';

type
  TConsoleRunner = class(TInterfacedObject, IConsoleRunner)
  private
    FShouldExit: Boolean;
    FWelcomeText: string;
    FServer: IWebServer;
    procedure ReadCommand;
    procedure SetSignalHandler;
    procedure WriteMessage(const AMessage: string; const AIncludePrompt: Boolean = False);
    procedure WritePrompt;
  public
    { IConsoleRunner }
    function GetWelcomeText: string;
    procedure SetWelcomeText(const AValue: string);
    procedure Start(const AServer: IWebServer);
    procedure Stop;
  end;

{$IFDEF LINUX}
procedure SignalHandler(ASigNum: Integer); cdecl;
begin
  if (ASigNum = SIGTERM) and (ConsoleRunner <> nil) then
    ConsoleRunner.Stop;
end;
{$ENDIF}

{$IFDEF MSWINDOWS}
function ConsoleHandler(CtrlType: DWORD): BOOL; stdcall;
begin
  Result := True;
  case CtrlType of
    CTRL_C_EVENT,
    CTRL_BREAK_EVENT,
    CTRL_CLOSE_EVENT,
    CTRL_SHUTDOWN_EVENT:
    begin
      ConsoleRunner.Stop;
      Result := False;
    end;
  end;
end;
{$ENDIF}

{ TConsoleRunner }

procedure TConsoleRunner.SetSignalHandler;
{$IFDEF LINUX}
var
  LAction: sigaction_t;
  LNewAction: sigaction_t;
{$ENDIF}
begin
  {$IFDEF LINUX}
  FillChar(LNewAction, SizeOf(LNewAction), 0);
  LNewAction._u.sa_handler := SignalHandler;
  LNewAction.sa_flags := 0;
  sigemptyset(LNewAction.sa_mask);
  if sigaction(SIGTERM, @LNewAction, @LAction) <> 0 then
    WriteMessage('Failed to install signal handler');
  {$ENDIF}
  {$IFDEF MSWINDOWS}
  SetConsoleCtrlHandler(@ConsoleHandler, True);
  {$ENDIF}
end;

procedure TConsoleRunner.SetWelcomeText(const AValue: string);
begin
  FWelcomeText := AValue;
end;

procedure TConsoleRunner.Start(const AServer: IWebServer);
var
  LAddresses: TArray<string>;
  LAddress: string;
begin
  FServer := AServer;
  try
    {$IFDEF MSWINDOWS}
    // Ensure UTF8 is shown correctly
    SetConsoleOutputCP(CP_UTF8);
    SetTextCodePage(Output, CP_UTF8);
    {$ENDIF}
    SetSignalHandler;
    if not FWelcomeText.IsEmpty then
    begin
      WriteMessage(FWelcomeText);
      Writeln;
    end;
    if FServer.IsActive then
    begin
      WriteMessage(Format('Server is running on port: %d', [FServer.Port]));
      LAddresses := FServer.GetBoundAddresses;
      if Length(LAddresses) > 0 then
      begin
        WriteMessage('Listening on:');
        for LAddress in LAddresses do
          WriteMessage(LAddress);
      end;
     end
    else
      WriteMessage(Format('Server was unable to start on port: %d', [FServer.Port]));
    Writeln;
    WriteMessage('Press Return or Ctrl-C to quit', True);
    while not FShouldExit and not EOF do
      ReadCommand;
  finally
    Stop;
  end;
end;

function TConsoleRunner.GetWelcomeText: string;
begin
  Result := FWelcomeText;
end;

procedure TConsoleRunner.ReadCommand;
var
  LResponse: string;
begin
  Readln(LResponse);
  // TODO: Possibly support "commands"
  FShouldExit := True;
end;

procedure TConsoleRunner.Stop;
begin
  FServer.Stop;
  FShouldExit := True;
end;

procedure TConsoleRunner.WriteMessage(const AMessage: string; const AIncludePrompt: Boolean = False);
begin
  Writeln(AMessage);
  if AIncludePrompt then
    WritePrompt;
end;

procedure TConsoleRunner.WritePrompt;
begin
  Write(cPrompt);
end;

initialization
  ConsoleRunner := TConsoleRunner.Create;

end.
