unit Charon.WebController.HelloWorld;

interface

uses
  Charon.Types,
  Charon.WebController;

type
  THelloWorldController = class(TWebController)
  private
    procedure HelloHandler(const ARequest: TWebRequest; const AResponse: TWebResponse);
    procedure JSONHandler(const ARequest: TWebRequest; const AResponse: TWebResponse);
  public
    constructor Create;
  end;

implementation

{ THelloWorldController }

constructor THelloWorldController.Create;
begin
  inherited;
  AddRoute(TMethodType.mtAny, '/hello', HelloHandler);
  AddRoute(TMethodType.mtAny, '/hellojson', JSONHandler);
end;

procedure THelloWorldController.HelloHandler(const ARequest: TWebRequest; const AResponse: TWebResponse);
begin
  AResponse.Content := 'Hello, World!';
end;

procedure THelloWorldController.JSONHandler(const ARequest: TWebRequest; const AResponse: TWebResponse);
begin
  AResponse.ContentType := 'application/json';
  AResponse.Content := '{ "Result": "Hello, JSON World!" }';
end;

end.
