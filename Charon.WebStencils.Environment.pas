unit Charon.WebStencils.Environment;

interface

type
  {$M+}
  TEnvironment = class
  private
    FDebugMode: Boolean;
  protected
    FAppName: string;
    FCompanyName: string;
    FHTMLPath: string;
    FResources: string;
    FRoot: string;
  public
    constructor Create;
  public
    property AppName: string read FAppName;
    property CompanyName: string read FCompanyName;
    property DebugMode: Boolean read FDebugMode;
    property HTMLPath: string read FHTMLPath;
    property Resources: string read FResources;
    property Root: string read FRoot;
  end;
  {$M-}

implementation

{ TEnvironment }

constructor TEnvironment.Create;
begin
  inherited;
  {$IF Defined(DEBUG)}
  FDebugMode := True;
  {$ELSE}
  FDebugMode := False;
  {$ENDIF}
end;

end.
