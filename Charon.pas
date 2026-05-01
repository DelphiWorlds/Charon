unit Charon;

interface

uses
  Charon.Types;

var
  WebApplication: IWebApplication;

implementation

uses
  System.SysUtils,
  {$IF Defined(CONSOLE)}
  Charon.Console,
  {$ENDIF}
  Charon.Router;

type
  TWebApplication = class(TInterfacedObject, IWebApplication)
  private
    FControllers: TArray<IWebController>;
    FServer: IWebServer;
    FSSL: IWebSSL;
  public
    { IWebApplication }
    procedure AddRoute(const AMethodKind: TMethodType; const APath: string; const AHandler: TRouteProc);
    function GetController(const AIndex: Integer): IWebController;
    function GetControllerCount: Integer;
    function GetWebServer: IWebServer;
    procedure Run(const APort: Integer = 80);
    procedure Stop;
    function AddController(const AController: IWebController): IWebApplication;
    function AddMiddleware(const AMiddleware: IMiddleware): IWebApplication;
    function UseServer(const AServer: IWebServer): IWebApplication;
    function UseSSL(const ASSL: IWebSSL): IWebApplication;
  public
    destructor Destroy; override;
  end;

{ TWebApplication }

destructor TWebApplication.Destroy;
begin
  Stop;
  inherited;
end;

function TWebApplication.GetController(const AIndex: Integer): IWebController;
begin
  if (AIndex >= 0) and (AIndex < GetControllerCount) then
    Result := FControllers[AIndex]
  else
    Result := nil;
end;

function TWebApplication.GetControllerCount: Integer;
begin
  Result := Length(FControllers);
end;

function TWebApplication.GetWebServer: IWebServer;
begin
  Result := FServer;
end;

procedure TWebApplication.Run(const APort: Integer);
begin
  FServer.Run(APort);
  {$IF Defined(CONSOLE)}
  ConsoleRunner.Start(FServer);
  {$ENDIF}
end;

procedure TWebApplication.Stop;
begin
  if FServer <> nil then
    FServer.Stop;
end;

function TWebApplication.AddController(const AController: IWebController): IWebApplication;
begin
  FControllers := FControllers + [AController];
  Result := Self;
end;

function TWebApplication.AddMiddleware(const AMiddleware: IMiddleware): IWebApplication;
begin
  if FServer <> nil then
    FServer.GetDispatcher.AddMiddleware(AMiddleware);
  Result := Self;
end;

procedure TWebApplication.AddRoute(const AMethodKind: TMethodType; const APath: string; const AHandler: TRouteProc);
begin
  if FServer <> nil then
    FServer.GetRouter.AddRoute(AMethodKind, APath, AHandler);
end;

function TWebApplication.UseServer(const AServer: IWebServer): IWebApplication;
begin
  FServer := AServer;
  if FSSL <> nil then
    FServer.SetSSL(FSSL);
  Result := Self;
end;

function TWebApplication.UseSSL(const ASSL: IWebSSL): IWebApplication;
begin
  FSSL := ASSL;
  if FServer <> nil then
    FServer.SetSSL(FSSL);
  Result := Self;
end;

initialization
  WebApplication := TWebApplication.Create;

end.
