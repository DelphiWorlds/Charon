unit Charon.RequestDispatcher;

interface

uses
  Charon.Types, Charon.Router;

type
  TRequestDispatcher = class(TInterfacedObject, IRequestDispatcher)
  private
    FMiddlewares: TArray<IMiddleware>;
    FRouter: IRouter;
  public
    { IRequestDispatcher }
    procedure AddMiddleware(const AMiddleware: IMiddleware);
    function DispatchRequest(const ARequest: TWebRequest; const AResponse: TWebResponse): Boolean;
    function ExecuteMiddleware(const ARequest: TWebRequest; const AResponse: TWebResponse): Boolean;
  public
    constructor Create(const ARouter: IRouter);
  end;

implementation

{ TRequestDispatcher }

constructor TRequestDispatcher.Create(const ARouter: IRouter);
begin
  inherited Create;
  FRouter := ARouter;
  FMiddlewares := [];
end;

procedure TRequestDispatcher.AddMiddleware(const AMiddleware: IMiddleware);
begin
  FMiddlewares := FMiddlewares + [AMiddleware];
end;

function TRequestDispatcher.DispatchRequest(const ARequest: TWebRequest; const AResponse: TWebResponse): Boolean;
begin
  Result := FRouter.HandleRequest(ARequest, AResponse);
end;

function TRequestDispatcher.ExecuteMiddleware(const ARequest: TWebRequest; const AResponse: TWebResponse): Boolean;
var
  LMiddleware: IMiddleware;
begin
  Result := True;
  for LMiddleware in FMiddlewares do
  begin
    if not LMiddleware.Execute(ARequest, AResponse) then
    begin
      Result := False;
      Break;
    end;
  end;
end;

end.
