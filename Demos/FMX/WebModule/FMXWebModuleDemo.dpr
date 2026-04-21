program FMXWebModuleDemo;

uses
  System.StartUpCopy,
  FMX.Forms,
  Charon.WebModuleDemo,
  Charon.FMX.GUI in '..\Charon.FMX.GUI.pas' {GUI};

{$R *.res}

begin
  CharonDemo.Run(8082);
  Application.Initialize;
  Application.CreateForm(TGUI, GUI);
  Application.Run;
end.
