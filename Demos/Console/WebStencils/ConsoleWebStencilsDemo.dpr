program ConsoleWebStencilsDemo;

{$APPTYPE CONSOLE}

{$R *.res}

{$R 'Data.res' '..\..\Data.rc'}

uses
  Charon.WebStencilsDemo;

begin
  CharonDemo.Run(8082);
end.
