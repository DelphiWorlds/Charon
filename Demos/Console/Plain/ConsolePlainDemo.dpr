program ConsolePlainDemo;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Charon,
  Charon.WebServer.Indy,
  Charon.WebController.HelloWorld;

begin
  WebApplication.UseServer(TIndyWebServer.Create)
    .AddController(THelloWorldController.Create)
    .Run(8082);
end.
