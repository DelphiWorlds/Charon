unit Charon.Middleware.Example;

interface

uses
  Charon.Types;

type
  TExampleMiddleware = class(TInterfacedObject, IMiddleware)
  private
    function IsValidAuthorization(const Value: string): Boolean;
  public
    { IMiddleware }
    function Execute(const ARequest: TWebRequest; const AResponse: TWebResponse): Boolean;
  end;

implementation

uses
  System.SysUtils;

{ TExampleMiddleware }

function TExampleMiddleware.IsValidAuthorization(const Value: string): Boolean;
var
  LParts: TArray<string>;
begin
  Result := False;
  LParts := Value.Split([':'], 2);
  if (Length(LParts) = 2) and SameText(LParts[0], 'Bearer') then
    Result := True; // Normally, LParts[1] would be checked for a valid token
end;

function TExampleMiddleware.Execute(const ARequest: TWebRequest; const AResponse: TWebResponse): Boolean;
begin
  Result := not ARequest.PathInfo.StartsWith('/api') or IsValidAuthorization(ARequest.AllHeaders.Values['Authorization']);
  if not Result then
    AResponse.StatusCode := 401;
end;

end.
