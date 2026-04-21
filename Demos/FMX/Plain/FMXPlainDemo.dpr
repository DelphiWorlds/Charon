program FMXPlainDemo;

uses
  System.StartUpCopy,
  FMX.Forms,
  Charon,
  Charon.WebServer.Indy,
  Charon.Middleware.Example,
  Charon.WebController.HelloWorld,
  Charon.FMX.GUI in '..\Charon.FMX.GUI.pas' {GUI};

{$R *.res}

begin
  WebApplication.UseServer(TIndyWebServer.Create)
    .AddMiddleware(TExampleMiddleware.Create)
    .AddController(THelloWorldController.Create)
    .Run(8082);
  Application.Initialize;
  Application.CreateForm(TGUI, GUI);
  Application.Run;
end.
