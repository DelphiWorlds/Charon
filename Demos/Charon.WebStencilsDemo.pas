unit Charon.WebStencilsDemo;

interface

type
  ICharonDemo = interface
    ['{CF3266FC-2BA3-44CE-B7F6-17275C9270EB}']
    function GetDataPath: string;
    procedure Run(const APort: Integer);
  end;

var
  CharonDemo: ICharonDemo;

implementation

uses
  System.SysUtils, System.IOUtils, System.Classes, System.Types, System.Zip,
  Charon, Charon.Types, Charon.Console,
  {$IF Defined(USESSL)}
  Charon.TaurusTLS,
  {$ENDIF}
  Charon.WebServer.IndyWebDispatch, Charon.WebServer.ISAPI, Charon.Demo.WebStencilsModule,
  Charon.WebController.HelloWorld;

type
  TCharonDemo = class(TInterfacedObject, ICharonDemo)
  private
    procedure ExtractResources;
    function GetWebServer: IWebServer;
  public
    { ICharonDemo }
    function GetDataPath: string;
    procedure Run(const APort: Integer);
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TCharonIndyWebDispatchServer = class(TIndyWebDispatchServer)
  protected
    procedure HandleResourceNotFound(const ARequest: TWebRequest; const AResponse: TWebResponse); override;
  end;

{ TCharonIndyWebDispatchServer }

// Demo of a custom way of handling 404's
procedure TCharonIndyWebDispatchServer.HandleResourceNotFound(const ARequest: TWebRequest; const AResponse: TWebResponse);
const
  cMessages: array[0..11] of string = (
    'Your physical address has been obtained from your IP and a SWAT team has been dispatched',
    'What did you think you would find here?',
    'I''m not in right now... please leave a message and I''ll get back to you',
    'Gone on vacation',
    'Seriously: do not try looking here again',
    'Perhaps try reading the documentation, first?',
    'Great.. now you''ve destroyed the web server.. bravo (slow hand clap)',
    'Is this the real life? Is this just fantasy?',
    'In webspace, no-one can hear you access the wrong URL',
    'Look.. I am just going to have to admit: there is nothing here. Honestly',
    'Wrong URLs are like onions.. actually, they are probably more like Shrek, as in: not here',
    'Congratulations, you are the lucky winner of a 404. Hope this has made your day!'
  );
begin
  AResponse.StatusCode := 404;
  AResponse.Content := cMessages[Random(Length(cMessages))];
  AResponse.ContentType := 'text/html; charset=utf-8';
end;

{ TCharonDemo }

constructor TCharonDemo.Create;
begin
  inherited;
  ExtractResources;
end;

destructor TCharonDemo.Destroy;
begin
  WebApplication.Stop;
  inherited;
end;

procedure TCharonDemo.ExtractResources;
const
  cResourcesName = 'Resources';
var
  LResStream: TResourceStream;
  LDataPath, LZipFileName: string;
begin
  LDataPath := GetDataPath;
  if not LDataPath.IsEmpty and (TDirectory.Exists(LDataPath) or ForceDirectories(LDataPath)) then
  begin
    if FindResource(HInstance, PChar(cResourcesName), RT_RCDATA) > 0 then
    begin
      LResStream := TResourceStream.Create(HInstance, cResourcesName, RT_RCDATA);
      try
        LZipFileName := TPath.Combine(LDataPath, 'resources.zip');
        LResStream.SaveToFile(LZipFileName);
        try
          TZipFile.ExtractZipFile(LZipFileName, LDataPath);
        finally
          TFile.Delete(LZipFileName);
        end;
      finally
        LResStream.Free;
      end;
    end;
  end;
end;

function TCharonDemo.GetDataPath: string;
begin
  Result := '';
  {$IF Defined(IOS) or Defined(ANDROID)}
  Result := TPath.GetDocumentsPath;
  {$ENDIF}
  {$IF Defined(MSWINDOWS) or Defined(OSX)}
  Result := TPath.Combine(TPath.GetPublicPath, TPath.GetFileNameWithoutExtension(TPath.GetFileName(ParamStr(0))));
  {$ENDIF}
end;

function TCharonDemo.GetWebServer: IWebServer;
begin
  if IsLibrary then
    Result := TISAPIServer.Create(TDemoWebStencilsModule)
  else
    Result := TCharonIndyWebDispatchServer.Create(TDemoWebStencilsModule);
end;

procedure TCharonDemo.Run(const APort: Integer);
{$IF Defined(USESSL)}
var
  LTLSOptions: TTLSOptions;
{$ENDIF}
begin
  ConsoleRunner.WelcomeText := 'Welcome to the Charon WebStencils Demo!';
  // LTLSOptions.

  WebApplication.UseServer(GetWebServer)
    {$IF Defined(USESSL)}
    .UseSSL(TCharonTaurusTLS.Create(LTLSOptions))
    {$ENDIF}
    .AddController(THelloWorldController.Create)
    .Run(8082);
end;

initialization
  CharonDemo := TCharonDemo.Create;

end.
