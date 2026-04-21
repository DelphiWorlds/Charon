program FMXWebStencilsDemo;

{$R 'Data.res' '..\..\Data.rc'}

uses
  System.StartUpCopy,
  FMX.Forms,
  Charon.WebStencilsDemo,
  Charon.FMX.GUI in '..\Charon.FMX.GUI.pas' {GUI};

{$R *.res}

begin
  CharonDemo.Run(8082);
  Application.Initialize;
  Application.CreateForm(TGUI, GUI);
  Application.Run;
end.
