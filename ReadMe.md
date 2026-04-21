# Charon

A cross-platform web server library for Delphi that provides a modern, fluent API for building web applications. Charon leverages Delphi's WebBroker architecture to create both plain HTTP API servers and template-based web applications **and combine both**, with ease.

## Description

Charon is designed to simplify web development in Delphi by providing:

- **Controller-based Architecture**: Organize your web application logic into reusable controllers
- **Flexible Routing**: Define routes with support for different HTTP methods
- **Middleware Support**: Add cross-cutting concerns like logging, authentication, and CORS
- **Multiple Server Backends**: Choose from Indy (standalone), IndyWebDispatch (WebBroker), or ISAPI (IIS)
- **WebStencils Integration**: Built-in support for HTML templating using Delphi's Web.Stencils engine
- **Cross-platform**: Works on Windows, macOS, Linux, iOS, and Android
- **Console and GUI Applications**: Perfect for both command-line tools and GUI applications

### Key Benefits for Delphi Developers

**For Plain HTTP APIs:**
- Rapid development of RESTful services and microservices
- Clean, maintainable code structure with controllers and routes
- Easy deployment as standalone executables or Windows services

**For WebStencils Applications:**
- Server-side HTML rendering with template inheritance
- Separation of concerns between business logic and presentation
- Static file serving capabilities
- Session management and form handling

## Features

- **Routing System**: Define routes with HTTP method support (GET, POST, PUT, DELETE, etc.)
- **Middleware Pipeline**: Chain middleware for request/response processing
- **Controller Framework**: Base classes for organizing application logic
- **WebStencils Templating**: HTML template rendering with variable substitution
- **Multiple Server Options**: Indy, IndyWebDispatch, and ISAPI backends, or roll your own
- **Cross-platform Support**: Windows, macOS, Linux, iOS, Android
- **SSL Support**: Support for TaurusTLS "out of the box"

## Getting Started

### Requirements

- Delphi 10.4 or later (recommended). Delphi 12.2 or later is required for WebStencils

### Installation

1. Clone or download the Charon repository
2. Include the path to Charon in your Delphi project search path
3. Include the necessary units in your uses clauses

### Basic Usage

See also the [demos](./Demos/) for examples.

Construct a webserver application as per the [usual process in Delphi](https://docwiki.embarcadero.com/RADStudio/Florence/en/Creating_Web_Server_Applications_with_Web_Broker), then:

#### Plain HTTP API Server

```delphi
uses
  Charon.Types, Charon.WebController;

type
  TUserController = class(TWebController)
  private
    procedure GetUsersHandler(const ARequest: TWebRequest; const AResponse: TWebResponse);
    procedure CreateUserHandler(const ARequest: TWebRequest; const AResponse: TWebResponse);
  public
    constructor Create;
  end;

constructor TUserController.Create;
begin
  inherited;
  AddRoute(TMethodType.mtGet, '/api/users', GetUsersHandler);
  AddRoute(TMethodType.mtPost, '/api/users', CreateUserHandler);
end;

procedure TUserController.GetUsersHandler(const ARequest: TWebRequest; const AResponse: TWebResponse);
begin
  AResponse.ContentType := 'application/json';
  AResponse.Content := '[{"id": 1, "name": "John Doe"}]';
end;

procedure TUserController.CreateUserHandler(const ARequest: TWebRequest; const AResponse: TWebResponse);
begin
  AResponse.StatusCode := 201;
  AResponse.ContentType := 'application/json';
  AResponse.Content := '{"message": "User created"}';
end;

// In your main application
uses
  Charon, Charon.WebServer.Indy;

procedure RunServer;
begin
  WebApplication.UseServer(TIndyWebServer.Create)
    .UseController(TUserController.Create)
    .Run(8080);
end;
```

#### WebStencils Application

In the webmodule of your application:

Add the necessary [components for a WebStencils application](https://docwiki.embarcadero.com/RADStudio/Florence/en/WebStencils#WebStencils_Components). For Charon, you will need to add as a minimum: 
- `TWebStencilsEngine`
- `TWebFileDispatcher`
- `TWebStencilsProcessor`

Add `Charon.WebModule.Helper` to the implementation uses clause

Use the `OnCreate` event handler or override the `Create` method, and at the end, add this line of code:

```delphi
  WebModuleCreated;
```

This allows Charon to link the `TWebStencilsController` instances to the webmodule

Example controller:

```delphi
uses
  Charon.WebStencils.Controller;

type
  TExampleController = class(TWebStencilsController)
  private
    procedure HomeHandler(const ARequest: TWebRequest; const AResponse: TWebResponse);
  public
    constructor Create;
  end;

constructor TExampleController.Create;
begin
  inherited;
  TemplatePath := 'templates';
  AddRoute(TMethodType.mtGet, '/', HomeHandler);
end;

procedure TExampleController.HomeHandler(const ARequest: TWebRequest; const AResponse: TWebResponse);
var
  LData: TMyDataObject;
begin
  LData := TMyDataObject.Create;
  LData.Title := 'Welcome to Charon';
  LData.Message := 'Hello, World!';
  AResponse.Content := RenderTemplate('home', LData);
end;
```

## Project Configuration

For **iOS ONLY**:

In Project Options > Building > Delphi compiler, for the Search path value for the **iOS Device 64-bit platform**, please include:

```
$(BDS)\source\Indy10\protocols;$(BDS)\source\Internet
```

This is required as Delphi does not ship a compiled `IdHTTPWebBrokerBridge` unit (required by Charon) for iOS.

## Server Backends

Charon supports multiple server implementations depending on your deployment needs:

### Indy Web Server (Standalone)
- **Use Case**: Console applications, Windows services, cross-platform deployment
- **Class**: `TIndyWebServer`
- **Pros**: Self-contained, no external dependencies, cross-platform
- **Cons**: No WebBroker integration

### Indy Web Dispatch Server
- **Use Case**: Applications needing WebBroker components (WebStencils, sessions, etc.)
- **Class**: `TIndyWebDispatchServer`
- **Pros**: Full WebBroker feature support, template rendering
- **Cons**: Requires WebModule setup

### ISAPI Server
- **Use Case**: IIS deployment, enterprise environments
- **Class**: `TISAPIServer`
- **Pros**: IIS integration, enterprise features
- **Cons**: Windows/IIS only

## SSL Support

SSL support "out of the box" is via [TaurusTLS](https://github.com/TaurusTLS-Developers/TaurusTLS). To enable this in your application:

1. Include `Charon.TaurusTLS` in the uses clause of the source where you configure `WebApplication`
2. Include a path to the TaurusTLS source in your project Search path
3. Declare a variable of type: `TTLSOptions`, and set the relevant properties
4. Add a call to the `UseSSL` method, e.g:

```delphi
var
  LTLSOptions: TTLSOptions;
begin
  LTLSOptions.PrivateKey := 'C:\Certs\PrivateKey.pem';
  LTLSOptions.PublicKey := 'C:\Certs\PublicKey.pem';
  LTLSOptions.RootKey := 'C:\Certs\RootKey.pem';
  LTLSOptions.MinTLSVersion := TTaurusTLSSSLVersion.TLSv1_3;
  LTLSOptions.PassPhrase := 'secret'; // Set this only if applicable
  WebApplication.UseSSL(TCharonTaurusTLS.Create(LTLSOptions));
end;
```

Replace filenames/paths for the keys with your own. Note that Posix (e.g. Linux and macOS) file paths will not have drive letters, and be separated by: `/`

Note that Charon is structured so that other kinds of SSL could be used - you would need to implement a class that supports `IWebSSL`, as per how `TCharonTaurusTLS` implements it.

## Contributing

Charon is an open-source project hosted on GitHub. Contributions are welcome!

- Report issues and request features on [GitHub Issues](https://github.com/DelphiWorlds/Charon/issues)
- Submit pull requests for enhancements
- Check the [demo applications](./Demos/) for usage examples

## License

MIT License - see [LICENSE](LICENSE) file for details.

