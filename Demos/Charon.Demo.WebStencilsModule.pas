unit Charon.Demo.WebStencilsModule;

interface

uses
  System.Classes, System.Masks,
  Web.HTTPApp, Web.Stencils;

type
  TDemoWebStencilsModule = class(TWebModule)
    WebStencilsEngine: TWebStencilsEngine;
    WebFileDispatcher: TWebFileDispatcher;
    WebStencilsProcessor: TWebStencilsProcessor;
    WebSessionManager: TWebSessionManager;
    procedure WebStencilsEngineValue(Sender: TObject; const AObjectName, APropName: string; var AReplaceText: string; var AHandled: Boolean);
    procedure WebStencilsEngineError(Sender: TObject; const AMessage: string);
    procedure WebStencilsEngineFileNotFound(Sender: TObject; const ARequest: TWebPostProcessorRequest; var ANotFoundPagePath: string);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  WebModuleClass: TComponentClass = TDemoWebStencilsModule;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

uses
  System.SysUtils, System.IOUtils,
  Charon.WebStencilsDemo, Charon.WebStencils.Environment, Charon.WebModule.Helper;

type
  TCharonDemoEnvironment = class(TEnvironment)
  public
    constructor Create(const AResourcesPath: string);
  end;

{ TCharonDemoEnvironment }

constructor TCharonDemoEnvironment.Create(const AResourcesPath: string);
begin
  inherited Create;
  FAppName := 'CharonWebStencilsDemo v0.0.1';
  FCompanyName := 'Delphi Worlds';
  FHTMLPath := TPath.Combine(AResourcesPath, 'html');
  // FResources :=
end;

{ TDemoWebModule }

constructor TDemoWebStencilsModule.Create(AOwner: TComponent);
var
  LEnvironment: TCharonDemoEnvironment;
begin
  inherited;
  LEnvironment := TCharonDemoEnvironment.Create(TPath.Combine(CharonDemo.GetDataPath, 'resources'));
  WebStencilsEngine.RootDirectory := LEnvironment.HTMLPath;
  WebFileDispatcher.RootDirectory := LEnvironment.HTMLPath;
  WebStencilsEngine.AddVar('env', LEnvironment);
  WebModuleCreated;
end;

destructor TDemoWebStencilsModule.Destroy;
begin
  //
  inherited;
end;

procedure TDemoWebStencilsModule.WebStencilsEngineError(Sender: TObject; const AMessage: string);
begin
  // Log.e('WebStencilsEngineError: %s', [AMessage]);
end;

procedure TDemoWebStencilsModule.WebStencilsEngineFileNotFound(Sender: TObject; const ARequest: TWebPostProcessorRequest; var ANotFoundPagePath: string);
begin
  // Log.e('WebStencilsEngineFileNotFound: %s', [ANotFoundPagePath]);
end;

procedure TDemoWebStencilsModule.WebStencilsEngineValue(Sender: TObject; const AObjectName, APropName: string; var AReplaceText: string;
  var AHandled: Boolean);
begin
  if SameText(AObjectName, 'system') then
  begin
    if SameText(APropName, 'timestamp') then
      AReplaceText := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now)
    else if SameText(APropName, 'year') then
      AReplaceText := FormatDateTime('yyyy', Now)
    else
      AReplaceText := Format('SYSTEM_%s_NOT_FOUND', [APropName.ToUpper]);
    AHandled := True;
  end;
end;

end.
