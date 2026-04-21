unit Charon.WebDispatcherController;

interface

uses
  Web.HTTPApp,
  Charon.Types,
  Charon.WebController;

type
  TWebDispatcherController = class(TWebController, IWebDispatcherController)
  private
    FWebDispatcher: TCustomWebDispatcher;
  protected
    property WebDispatcher: TCustomWebDispatcher read FWebDispatcher;
  public
    { IWebDispatcherController }
    procedure SetWebDispatcher(const AWebDispatcher: TCustomWebDispatcher);
  end;

implementation

{ TWebDispatcherController }

procedure TWebDispatcherController.SetWebDispatcher(const AWebDispatcher: TCustomWebDispatcher);
begin
  FWebDispatcher := AWebDispatcher;
end;

end.
