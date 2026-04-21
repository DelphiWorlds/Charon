unit Charon.WebServer.Indy;

interface

uses
  IdHTTPServer, IdContext, IdCustomHTTPServer, IdServerIOHandler,
  Charon.Types, Charon.WebServer;

type
  TIndyWebServer = class(TWebServer, IWebServer)
  private
    FHTTPServer: TIdHTTPServer;
    FIOHandler: TIdServerIOHandler;
    procedure HandleParseAuthentication(AContext: TIdContext; const AAuthType, AAuthData: string; var VUsername, VPassword: string;
      var Handled: Boolean);
    function GetLocalAddresses: TArray<string>;
  protected
    procedure HandleCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo); virtual;
    function HandleRequest(const ARequest: TWebRequest; const AResponse: TWebResponse): Boolean; virtual;
  public
    { IWebServer }
    function GetBoundAddresses: TArray<string>;
    function GetIsActive: Boolean;
    function GetPort: Integer;
    procedure Run(const APort: Integer = 80);
    procedure SetSSL(const ASSL: IWebSSL);
    procedure Stop;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  System.SysUtils, System.Classes,
  {$IF Defined(ANDROID)}
  Androidapi.JNI.Java.Net, Androidapi.JNI.JavaTypes, Androidapi.Helpers,  Androidapi.JNIBridge,
  {$ENDIF}
  IdHTTPWebBrokerBridge, IdGlobal, IdStack,
  Charon;

{ TIndyWebServer }

constructor TIndyWebServer.Create;
begin
  inherited Create;
  FHTTPServer := TIdHTTPServer.Create(nil);
  FHTTPServer.OnCommandOther := HandleCommandGet;
  FHTTPServer.OnCommandGet := HandleCommandGet;
  FHTTPServer.OnParseAuthentication := HandleParseAuthentication;
  FHTTPServer.ParseParams := True;
  FHTTPServer.KeepAlive := True;
end;

procedure TIndyWebServer.HandleParseAuthentication(AContext: TIdContext;
  const AAuthType, AAuthData: string; var VUsername, VPassword: string; var Handled: Boolean);
begin
  Handled := True;
end;

destructor TIndyWebServer.Destroy;
begin
  Stop;
  FHTTPServer.Free;
  inherited Destroy;
end;

function TIndyWebServer.GetIsActive: Boolean;
begin
  Result := FHTTPServer.Active;
end;

function TIndyWebServer.GetPort: Integer;
begin
  Result := FHTTPServer.DefaultPort;
end;

procedure TIndyWebServer.HandleCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  LRequest: TIdHTTPAppRequest;
  LResponse: TIdHTTPAppResponse;
begin
  LRequest := TIdHTTPAppRequest.Create(AContext, ARequestInfo, AResponseInfo);
  try
    LResponse := TIdHTTPAppResponse.Create(LRequest, AContext, ARequestInfo, AResponseInfo);
    try
      AResponseInfo.FreeContentStream := False;
      try
        HandleRequest(LRequest, LResponse);
      except
        on E: Exception do
          HandleException(E, LResponse);
      end;
      if not LResponse.Sent then
        LResponse.SendResponse;
    finally
      LResponse.Free;
    end;
  finally
    LRequest.Free;
  end;
end;

function TIndyWebServer.HandleRequest(const ARequest: TWebRequest; const AResponse: TWebResponse): Boolean;
begin
  Result := False;
  if Dispatcher.ExecuteMiddleware(ARequest, AResponse) then
  begin
    Result := Dispatcher.DispatchRequest(ARequest, AResponse);
    if not Result then
      HandleResourceNotFound(ARequest, AResponse);
  end;
end;

procedure TIndyWebServer.Run(const APort: Integer = 80);
begin
  Stop;
  FHTTPServer.DefaultPort := APort;
  if FIOHandler <> nil then
    FHTTPServer.IOHandler := FIOHandler;
  try
    FHTTPServer.Active := True;
  except
    on E: Exception do
    begin
      // TODO: Needs a way of informing the exception
    end;
  end;
end;

procedure TIndyWebServer.SetSSL(const ASSL: IWebSSL);
begin
  FIOHandler := ASSL.GetIOHandler;
end;

procedure TIndyWebServer.Stop;
begin
  FHTTPServer.Active := False;
end;

function TIndyWebServer.GetBoundAddresses: TArray<string>;
var
  I: Integer;
  LAddress: string;
begin
  if FHTTPServer.Active then
  begin
    for I := 0 to FHTTPServer.Bindings.Count - 1 do
    begin
      // Just do IPv4 for now
      if FHTTPServer.Bindings[I].IPVersion = TIdIPVersion.Id_IPv4 then
      begin
        LAddress := FHTTPServer.Bindings[I].IP;
        if LAddress.Equals('0.0.0.0') then
          Result := Result + GetLocalAddresses
        else
          Result := Result + [LAddress];
      end;
    end;
  end;
end;

{$IF Defined(ANDROID)}
function TIndyWebServer.GetLocalAddresses: TArray<string>;
var
  LInterfaces, LAddresses: JEnumeration;
  LInterface: JNetworkInterface;
  LAddress: JInetAddress;
  LName, LHostAddress: string;
begin
  LInterfaces := TJNetworkInterface.JavaClass.getNetworkInterfaces;
  while LInterfaces.hasMoreElements do
  begin
    LInterface := TJNetworkInterface.Wrap(LInterfaces.nextElement);
    LAddresses := LInterface.getInetAddresses;
    while LAddresses.hasMoreElements do
    begin
      LAddress := TJInetAddress.Wrap(LAddresses.nextElement);
      if LAddress.isLoopbackAddress then
        Continue;
      LName := JStringToString(LAddress.getClass.getName);
      LHostAddress := JStringToString(LAddress.getHostAddress);
      // Trim excess stuff
      if LHostAddress.IndexOf('%') > -1 then
        LHostAddress := LHostAddress.Substring(0, LHostAddress.IndexOf('%'));
      if LName.Contains('Inet4Address') then
        Result := Result + [LHostAddress];
    end;
  end;
end;

{$ELSE}
function TIndyWebServer.GetLocalAddresses: TArray<string>;
var
  I: Integer;
  LAddresses: TIdStackLocalAddressList;
  LAddress: string;
begin
  LAddresses := TIdStackLocalAddressList.Create;
  try
    GStack.GetLocalAddressList(LAddresses);
    for I := 0 to LAddresses.Count - 1 do
    begin
      if LAddresses[I].IPVersion = TIdIPVersion.Id_IPv4 then
      begin
        LAddress := LAddresses[I].IPAddress;
        Result := Result + [LAddress];
      end;
    end;
  finally
    LAddresses.Free;
  end;
end;
{$ENDIF}

end.

