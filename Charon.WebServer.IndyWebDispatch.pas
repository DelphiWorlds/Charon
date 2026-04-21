unit Charon.WebServer.IndyWebDispatch;

interface

uses
  System.Classes, System.Generics.Collections,
  Web.HTTPApp,
  IdContext, IdCustomHTTPServer,
  Charon.WebServer.Indy;

type
  TActionHandlers = TDictionary<TWebActionItem, THTTPMethodEvent>;

  TIndyWebDispatchServer = class(TIndyWebServer)
  private
    FActionHandlers: TActionHandlers;
    FWebModuleClass: TComponentClass;
    procedure ActionHandler(Sender: TObject; ARequest: TWebRequest; AResponse: TWebResponse; var Handled: Boolean);
  protected
    function HandleRequest(const ARequest: TWebRequest; const AResponse: TWebResponse): Boolean; override;
  public
    constructor Create(const AWebModuleClass: TComponentClass);
    destructor Destroy; override;
  end;

implementation

type
  TWebDispatcherAccess = class(TCustomWebDispatcher);

{ TIndyWebDispatchServer }

constructor TIndyWebDispatchServer.Create(const AWebModuleClass: TComponentClass);
begin
  inherited Create;
  FWebModuleClass := AWebModuleClass;
  FActionHandlers := TActionHandlers.Create;
end;

destructor TIndyWebDispatchServer.Destroy;
begin
  FActionHandlers.Free;
  inherited;
end;

function TIndyWebDispatchServer.HandleRequest(const ARequest: TWebRequest; const AResponse: TWebResponse): Boolean;
var
  LWebModule: TCustomWebDispatcher;
  LAction: TWebActionItem;
begin
  // Might need to rework the logic if FWebModuleClass can actually be NIL. RequestBegin, DispatchRequest and RequestEnd could still be callled
  Result := False;
  if FWebModuleClass <> nil then
  begin
    LWebModule := FWebModuleClass.Create(nil) as TCustomWebDispatcher;
    try
      for LAction in LWebModule.Actions do
      begin
        if Assigned(LAction.OnAction) then
        begin
          FActionHandlers.AddOrSetValue(LAction, LAction.OnAction);
          LAction.OnAction := ActionHandler;
        end;
      end;
      if Dispatcher.ExecuteMiddleware(ARequest, AResponse) then
      begin
        Result := TWebDispatcherAccess(LWebModule).DispatchAction(ARequest, AResponse);
        // Unfortunately, DispatchAction can return True even if no action actually handled the request, so StatusCode must be checked
        if not Result or (AResponse.StatusCode = 404) then
          Result := Dispatcher.DispatchRequest(ARequest, AResponse);
        if not Result then
          HandleResourceNotFound(ARequest, AResponse);
      end;
      if Result and not AResponse.Sent then
        AResponse.SendResponse;
    finally
      LWebModule.Free;
    end;
  end;
end;

procedure TIndyWebDispatchServer.ActionHandler(Sender: TObject; ARequest: TWebRequest; AResponse: TWebResponse; var Handled: Boolean);
var
  LActionHandler: THTTPMethodEvent;
begin
  if Dispatcher.ExecuteMiddleware(ARequest, AResponse) then
  begin
    if FActionHandlers.TryGetValue(TWebActionItem(Sender), LActionHandler) then
      LActionHandler(Sender, ARequest, AResponse, Handled);
  end;
end;

end.
