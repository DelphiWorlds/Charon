unit Charon.Demo;

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
  Charon, Charon.Types, Charon.WebServer.Indy, Charon.WebController.HelloWorld;

type
  TCharonDemo = class(TInterfacedObject, ICharonDemo)
  public
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

procedure TCharonDemo.Run(const APort: Integer);
begin
  WebApplication.UseServer(TIndyWebServer.Create)
    // Plain/API routes
    .AddController(THelloWorldController.Create)
    .Run(APort);
end;

initialization
  CharonDemo := TCharonDemo.Create;

end.
