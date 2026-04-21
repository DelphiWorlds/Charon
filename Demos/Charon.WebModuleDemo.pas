unit Charon.WebModuleDemo;

interface

type
  ICharonDemo = interface
    ['{CF3266FC-2BA3-44CE-B7F6-17275C9270EB}']
    procedure Run(const APort: Integer);
  end;

var
  CharonDemo: ICharonDemo;

implementation

uses
  Charon, Charon.Types,
  Charon.WebServer.IndyWebDispatch,
  {$IF Defined(MSWINDOWS)}
  Charon.WebServer.ISAPI,
  {$ENDIF}
  Charon.Demo.WebModule,
  Charon.WebController.HelloWorld;

type
  TCharonDemo = class(TInterfacedObject, ICharonDemo)
  private
    function GetWebServer: IWebServer;
  public
    { ICharonDemo }
    procedure Run(const APort: Integer);
  public
    destructor Destroy; override;
  end;

{ TCharonDemo }

destructor TCharonDemo.Destroy;
begin
  WebApplication.Stop;
  inherited;
end;

function TCharonDemo.GetWebServer: IWebServer;
begin
  {$IF Defined(MSWINDOWS)}
  if IsLibrary then
    Result := TISAPIServer.Create(TDemoWebModule)
  else
  {$ENDIF}
    Result := TIndyWebDispatchServer.Create(TDemoWebModule);
end;

procedure TCharonDemo.Run(const APort: Integer);
begin
  WebApplication.UseServer(GetWebServer)
    .AddController(THelloWorldController.Create)
    .Run(8082);
end;

initialization
  CharonDemo := TCharonDemo.Create;

end.
