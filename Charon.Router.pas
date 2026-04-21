unit Charon.Router;

interface

uses
  Charon.Types;

type
  TRouteDefinition = record
    Handler: TRouteProc;
    Method: TMethodType;
    Path: string;
    constructor Create(const AMethod: TMethodType; const APath: string; const AHandler: TRouteProc);
  end;

  TRouter = class(TInterfacedObject, IRouter)
  private
    FRoutes: TArray<TRouteDefinition>;
  public
    { IRouter }
    procedure AddRoute(const AMethod: TMethodType; const APath: string; const AHandler: TRouteProc);
    function HandleRequest(const ARequest: TWebRequest; const AResponse: TWebResponse): Boolean;
  end;

implementation

uses
  System.SysUtils;

type
  TRouteDefinitionHelper = record helper for TRouteDefinition
    function IsMatch(const ARequest: TWebRequest): Boolean;
  end;

{ TRouteDefinitionHelper }

function TRouteDefinitionHelper.IsMatch(const ARequest: TWebRequest): Boolean;
const
  cMethodTypeValues: array[TMethodType] of string = ('ANY', 'GET', 'PUT', 'POST', 'HEAD', 'DELETE', 'PATCH');
begin
  Result := (SameText(Path, ARequest.PathInfo) or (Path = '*')) and
    ((Method = TMethodType.mtAny) or SameText(cMethodTypeValues[Method], ARequest.Method));
end;

{ TRouteDefinition }

constructor TRouteDefinition.Create(const AMethod: TMethodType; const APath: string; const AHandler: TRouteProc);
begin
  Method := AMethod;
  Path := APath;
  Handler := AHandler;
end;

{ TRouter }

procedure TRouter.AddRoute(const AMethod: TMethodType; const APath: string; const AHandler: TRouteProc);
begin
  FRoutes := FRoutes + [TRouteDefinition.Create(AMethod, APath, AHandler)];
end;

function TRouter.HandleRequest(const ARequest: TWebRequest; const AResponse: TWebResponse): Boolean;
var
  LDefinition: TRouteDefinition;
begin
  Result := False;
  for LDefinition in FRoutes do
  begin
    if LDefinition.IsMatch(ARequest) then
    begin
      Result := True; // This means that a valid route was found (i.e. not a 404), not that it succeeded in handling the request
      LDefinition.Handler(ARequest, AResponse);
      Break;
    end;
  end;
end;

end.
