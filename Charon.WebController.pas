unit Charon.WebController;

interface

uses
  Charon.Types;

type
  TWebController = class(TInterfacedObject, IWebController)
  protected
    procedure AddRoute(const AMethod: TMethodType; const APathInfo: string; const AHandler: TRouteProc); virtual;
  end;

implementation

uses
  Charon;

{ TWebController }

procedure TWebController.AddRoute(const AMethod: TMethodType; const APathInfo: string; const AHandler: TRouteProc);
begin
  WebApplication.AddRoute(AMethod, APathInfo, AHandler);
end;

end.
