unit Charon.Demo.WebModule;

interface

uses
  System.Classes,
  Web.HTTPApp;

type
  TDemoWebModule = class(TWebModule)
    procedure DemoWebModuleHelloWebActionItemAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  WebModuleClass: TComponentClass = TDemoWebModule;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

{ TDemoWebModule }

constructor TDemoWebModule.Create(AOwner: TComponent);
begin
  inherited;
  //
end;

procedure TDemoWebModule.DemoWebModuleHelloWebActionItemAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  Response.Content := 'Hello, WebModule World!';
end;

destructor TDemoWebModule.Destroy;
begin
  //
  inherited;
end;

end.
