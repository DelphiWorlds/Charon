unit Charon.WebStencils.Controller;

interface

uses
  System.Classes,
  Web.HTTPApp, Web.Stencils,
  Charon.Types, Charon.WebDispatcherController;

type
  TWebRequest = Web.HTTPApp.TWebRequest;
  TWebResponse = Web.HTTPApp.TWebResponse;
  TMethodType = Web.HTTPApp.TMethodType;

  IWebStencilsController = interface
    ['{ABB9395E-D07C-4606-B5AE-C180246FD018}']
  end;

  TWebStencilsController = class(TWebDispatcherController, IWebStencilsController)
  private
    FTemplatePath: string;
    FWebStencilsEngine: TWebStencilsEngine;
    FWebStencilsProcessor: TWebStencilsProcessor;
    procedure FindWebStencilComponents;
    function GetAbsoluteTemplatePath: string;
  protected
    procedure AddVar(const AVar: TObject; const AOwnsObject: Boolean; const AVarName: string = ''); overload;
    procedure AddVar(const AVar: TObject; const AVarName: string = ''); overload;
    function RenderTemplate(const ATemplate: string): string; overload;
    function RenderTemplate(const ATemplate: string; const AVar: TObject; const AOwnsObject: Boolean; const AVarName: string = ''): string; overload;
    function RenderTemplate(const ATemplate: string; const AVar: TObject; const AVarName: string = ''): string; overload;
    procedure ScaffoldingHandler(Sender: TObject; const AQualifClassName: string; var AValue: string); virtual;
    property TemplatePath: string read FTemplatePath write FTemplatePath;
  end;

implementation

uses
  System.SysUtils, System.IOUtils, System.Rtti;

{ TWebStencilsController }

procedure TWebStencilsController.FindWebStencilComponents;
var
  I: Integer;
begin
  for I := 0 to WebDispatcher.ComponentCount - 1 do
  begin
    if WebDispatcher.Components[I] is TWebStencilsEngine then
      FWebStencilsEngine := TWebStencilsEngine(WebDispatcher.Components[I]);
    if WebDispatcher.Components[I] is TWebStencilsProcessor then
      FWebStencilsProcessor := TWebStencilsProcessor(WebDispatcher.Components[I]);
  end;
end;

function TWebStencilsController.GetAbsoluteTemplatePath: string;
begin
  if FWebStencilsEngine <> nil then
    Result := TPath.Combine(FWebStencilsEngine.RootDirectory, FTemplatePath)
  else
    Result := FTemplatePath;
end;

procedure TWebStencilsController.ScaffoldingHandler(Sender: TObject; const AQualifClassName: string; var AValue: string);
begin
  //
end;

procedure TWebStencilsController.AddVar(const AVar: TObject; const AOwnsObject: Boolean; const AVarName: string = '');
begin
  FindWebStencilComponents;
  if FWebStencilsProcessor <> nil then
  begin
    if AVarName.IsEmpty then
      FWebStencilsProcessor.AddVar(AVar.ClassName.Substring(1), AVar, AOwnsObject)
    else
      FWebStencilsProcessor.AddVar(AVarName, AVar, AOwnsObject);
  end;
end;

procedure TWebStencilsController.AddVar(const AVar: TObject; const AVarName: string = '');
begin
  AddVar(AVar, True, AVarName);
end;

function TWebStencilsController.RenderTemplate(const ATemplate: string; const AVar: TObject; const AOwnsObject: Boolean;
  const AVarName: string = ''): string;
begin
  FindWebStencilComponents;
  if FWebStencilsProcessor <> nil then
  begin
    FWebStencilsProcessor.OnScaffolding := ScaffoldingHandler;
    FWebStencilsProcessor.InputFileName := TPath.Combine(GetAbsoluteTemplatePath, ATemplate + '.html');
    if AVarName.IsEmpty then
      FWebStencilsProcessor.AddVar(AVar.ClassName.Substring(1), AVar, AOwnsObject)
    else
      FWebStencilsProcessor.AddVar(AVarName, AVar, AOwnsObject);
    Result := FWebStencilsProcessor.Content;
    if AVar <> nil then
      FWebStencilsProcessor.DataVars.Remove(AVar.ClassName.Substring(1));
  end;
end;

function TWebStencilsController.RenderTemplate(const ATemplate: string): string;
begin
  Result := RenderTemplate(ATemplate, nil, False);
end;

function TWebStencilsController.RenderTemplate(const ATemplate: string; const AVar: TObject; const AVarName: string = ''): string;
begin
  Result := RenderTemplate(ATemplate, AVar, True, AVarName);
end;

end.
