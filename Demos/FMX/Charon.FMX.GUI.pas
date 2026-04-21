unit Charon.FMX.GUI;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, FMX.Layouts,
  FMX.StdCtrls;

type
  TGUI = class(TForm)
    Memo: TMemo;
    RootLayout: TLayout;
    ClearMemoButton: TButton;
    BottomLayout: TLayout;
    procedure FormActivate(Sender: TObject);
    procedure ClearMemoButtonClick(Sender: TObject);
  private
    FHasShown: Boolean;
    procedure LogServerInfo;
    procedure LogMessage(const AMessage: string);
    {$IF CompilerVersion > 36}
    procedure FormSafeAreaChangedHandler(Sender: TObject; const AInsets: TRectF);
    {$ENDIF}
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  GUI: TGUI;

implementation

{$R *.fmx}

uses
  {$IF Defined(ANDROID)}
  Androidapi.Helpers, Androidapi.JNI.GraphicsContentViewText, Androidapi.JNI.App,
  {$ENDIF}
  Charon;

{ TGUI }

constructor TGUI.Create(AOwner: TComponent);
begin
  inherited;
  {$IF CompilerVersion > 36}
  OnSafeAreaChanged := FormSafeAreaChangedHandler;
  {$ENDIF}
  {$IF Defined(ANDROID) and Declared(RTLVersion131)}
  // Make the status bar contrast with the Delphi form
  TAndroidHelper.Activity.getWindow.getInsetsController.setSystemBarsAppearance(
    TJWindowInsetsController.JavaClass.APPEARANCE_LIGHT_STATUS_BARS, TJWindowInsetsController.JavaClass.APPEARANCE_LIGHT_STATUS_BARS
  );
  {$ENDIF}
  {$IF Defined(ANDROID)}
  Memo.StyledSettings := Memo.StyledSettings - [TStyledSetting.Family, TStyledSetting.Size];
  Memo.TextSettings.Font.Family := 'Roboto Mono';
  // Dial down the font size so messages can still fit in when in portrait mode
  Memo.TextSettings.Font.Size := 12;
  {$ENDIF}
  {$IF Defined(MACOS)}
  Memo.StyledSettings := Memo.StyledSettings - [TStyledSetting.Family];
  Memo.TextSettings.Font.Family := 'Menlo';
  {$IF Defined(IOS)}
  Memo.StyledSettings := Memo.StyledSettings - [TStyledSetting.Size];
  Memo.TextSettings.Font.Size := 10;
  {$ENDIF}
  {$ENDIF}
end;

procedure TGUI.FormActivate(Sender: TObject);
begin
  if not FHasShown then
    LogServerInfo;
  FHasShown := True;
end;

{$IF CompilerVersion > 36}
procedure TGUI.FormSafeAreaChangedHandler(Sender: TObject; const AInsets: TRectF);
begin
  {$IF Defined(ANDROID) and Declared(RTLVersion131)}
  RootLayout.Padding.Rect := AInsets;
  {$ENDIF}
end;
{$ENDIF}

procedure TGUI.LogMessage(const AMessage: string);
begin
  // Take the timestamp out if you do not really care to include it
  Memo.Lines.Add(Format('%s %s', [FormatDateTime('hh:nn:ss.zzz', Now), AMessage]));
end;

procedure TGUI.LogServerInfo;
var
  LAddresses: TArray<string>;
  LAddress: string;
begin
  if WebApplication.Server.IsActive then
  begin
    LogMessage(Format('Server active on port: %d', [WebApplication.Server.Port]));
    LAddresses := WebApplication.Server.GetBoundAddresses;
    if Length(LAddresses) > 0 then
    begin
      LogMessage('Listening on:');
      for LAddress in LAddresses do
        LogMessage(LAddress);
    end;
  end
  else
    LogMessage(Format('Server could not be started on port: %d', [WebApplication.Server.Port]));
end;

procedure TGUI.ClearMemoButtonClick(Sender: TObject);
begin
  Memo.Lines.Clear;
end;

end.
