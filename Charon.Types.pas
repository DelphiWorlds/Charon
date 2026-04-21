unit Charon.Types;

interface

uses
  System.SysUtils,
  IdServerIOHandler,
  Web.HTTPApp;

type
  TWebRequest = Web.HTTPApp.TWebRequest;
  TWebResponse = Web.HTTPApp.TWebResponse;
  TMethodType = Web.HTTPApp.TMethodType;

  IMiddleware = interface
    ['{BC4DA556-8F4D-4D04-883A-78B5D1945942}']
    function Execute(const ARequest: TWebRequest; const AResponse: TWebResponse): Boolean;
  end;

  IRequestDispatcher = interface
    ['{19F5A1ED-7B59-4837-A227-1992A54011EE}']
    procedure AddMiddleware(const AMiddleware: IMiddleware);
    function DispatchRequest(const ARequest: TWebRequest; const AResponse: TWebResponse): Boolean;
    function ExecuteMiddleware(const ARequest: TWebRequest; const AResponse: TWebResponse): Boolean;
  end;

  TRouteProc = reference to procedure(const ARequest: TWebRequest; const AResponse: TWebResponse);

  IRouter = interface
    ['{E7BFF757-A4CA-461E-867A-37608269FB13}']
    procedure AddRoute(const AMethodKind: TMethodType; const APath: string; const AHandler: TRouteProc);
    function HandleRequest(const ARequest: TWebRequest; const AResponse: TWebResponse): Boolean;
  end;

  IWebSSL = interface
    ['{A6C03E24-FDAD-420E-BF55-0459BC9F3A1E}']
    function GetIOHandler: TIdServerIOHandler;
  end;

  IWebServer = interface
    ['{FC3A1214-EE92-40A8-BC03-863550CD8321}']
    function GetBoundAddresses: TArray<string>;
    function GetDispatcher: IRequestDispatcher;
    function GetIsActive: Boolean;
    function GetPort: Integer;
    function GetRouter: IRouter;
    procedure Run(const APort: Integer = 80);
    procedure SetSSL(const AWebSSL: IWebSSL);
    procedure Stop;
    property IsActive: Boolean read GetIsActive;
    property Port: Integer read GetPort;
  end;

  IWebController = interface
    ['{EADB3741-8496-4702-96A7-C62FE4A3C479}']
  end;

  IWebDispatcherController = interface(IWebController)
    ['{F082832D-856C-4BC5-84D1-4E182E31FF36}']
    procedure SetWebDispatcher(const AWebDispatcher: TCustomWebDispatcher);
  end;

  IWebApplication = interface
    ['{4AB57C55-34EE-4672-8A6C-4C075B898E00}']
    procedure AddRoute(const AMethodKind: TMethodType; const APath: string; const AHandler: TRouteProc);
    function GetController(const AIndex: Integer): IWebController;
    function GetControllerCount: Integer;
    function GetWebServer: IWebServer;
    procedure Run(const APort: Integer = 80);
    procedure Stop;
    function AddController(const AController: IWebController): IWebApplication;
    function AddMiddleware(const AMiddleware: IMiddleware): IWebApplication;
    function UseServer(const AServer: IWebServer): IWebApplication;
    function UseSSL(const AWebSSL: IWebSSL): IWebApplication;
    property Server: IWebServer read GetWebServer;
  end;

implementation

end.

