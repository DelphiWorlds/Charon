unit Charon.WebServer;

interface

uses
  System.SysUtils,
  Charon.Types;

type
  TWebServer = class(TInterfacedObject)
  private
    FDispatcher: IRequestDispatcher;
    FRouter: IRouter;
  protected
    procedure HandleException(const AException: Exception; const AResponse: TWebResponse); virtual;
    procedure HandleResourceNotFound(const ARequest: TWebRequest; const AResponse: TWebResponse); virtual;
    property Dispatcher: IRequestDispatcher read FDispatcher;
  public
    { IWebServer }
    function GetDispatcher: IRequestDispatcher;
    function GetRouter: IRouter;
  public
    constructor Create;
  end;

implementation

uses
  Charon, Charon.RequestDispatcher, Charon.Router;

{ TWebServer }

constructor TWebServer.Create;
begin
  inherited;
  FRouter := TRouter.Create;
  FDispatcher := TRequestDispatcher.Create(FRouter);
end;

function TWebServer.GetDispatcher: IRequestDispatcher;
begin
  Result := FDispatcher;
end;

function TWebServer.GetRouter: IRouter;
begin
  Result := FRouter;
end;

procedure TWebServer.HandleException(const AException: Exception; const AResponse: TWebResponse);
begin
  AResponse.StatusCode := 500;
  AResponse.Content := 'Internal Server Error: ' + AException.Message;
  AResponse.ContentType := 'text/plain; charset=utf-8';
end;

procedure TWebServer.HandleResourceNotFound(const ARequest: TWebRequest; const AResponse: TWebResponse);
begin
  AResponse.StatusCode := 404;
  AResponse.Content := 'Not Found';
  AResponse.ContentType := 'text/html; charset=utf-8';
end;

end.
