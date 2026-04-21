unit Charon.WebModule.Helper;

interface

uses
  Web.HTTPApp;

type
  TWebModuleHelper = class helper for TWebModule
    procedure WebModuleCreated;
  end;

implementation

uses
  System.SysUtils,
  Charon, Charon.Types;

{ TWebModuleHelper }

procedure TWebModuleHelper.WebModuleCreated;
var
  I: Integer;
  LController: IWebDispatcherController;
begin
  for I := 0 to WebApplication.GetControllerCount - 1 do
  begin
    if Supports(WebApplication.GetController(I), IWebDispatcherController, LController) then
      LController.SetWebDispatcher(Self);
  end;
end;

end.
