unit Charon.WebServer.ISAPI;

interface

uses
  System.Classes,
  Charon.Types, Charon.WebServer;

type
  TISAPIServer = class(TWebServer, IWebServer)
  public
    { IWebServer }
    function GetBoundAddresses: TArray<string>;
    function GetIsActive: Boolean;
    function GetPort: Integer;
    procedure Run(const APort: Integer = 80);
    procedure SetSSL(const ASSL: IWebSSL);
    procedure Stop;
  public
    constructor Create(const AWebModuleClass: TComponentClass);
  end;

implementation

uses
  System.Win.ComObj,
  Winapi.ActiveX,
  Web.Win.ISAPIApp, Web.Win.ISAPIThreadPool, Web.WebBroker;

{ TISAPIServer }

constructor TISAPIServer.Create;
begin
  inherited Create;
  CoInitFlags := COINIT_MULTITHREADED;
  Application.Initialize;
  Application.WebModuleClass := AWebModuleClass;
end;

function TISAPIServer.GetBoundAddresses: TArray<string>;
begin
  Result := []; // Not applicable here, maybe
end;

function TISAPIServer.GetIsActive: Boolean;
begin
  Result := True; // Not applicable here
end;

function TISAPIServer.GetPort: Integer;
begin
  Result := 0; // Not applicable here
end;

procedure TISAPIServer.Run(const APort: Integer = 80);
begin
  Application.Run;
end;

procedure TISAPIServer.SetSSL(const ASSL: IWebSSL);
begin
  // Not applicable here
end;

procedure TISAPIServer.Stop;
begin
  //
end;

exports
  GetExtensionVersion,
  HttpExtensionProc,
  TerminateExtension;

end.
