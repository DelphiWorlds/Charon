unit Charon.TaurusTLS;

interface

uses
  IdServerIOHandler,
  TaurusTLS,
  Charon.Types;

type
  TTaurusTLSSSLVersion = TaurusTLS.TTaurusTLSSSLVersion;

  TTLSOptions = record
    MinTLSVersion: TTaurusTLSSSLVersion;
    PassPhrase: string;
    PublicKey: string;
    PrivateKey: string;
    RootKey: string;
  end;

  TCharonTaurusTLS = class(TInterfacedObject, IWebSSL)
  private
    FIOHandler: TTaurusTLSServerIOHandler;
    FPassPhrase: string;
    procedure TLSHandlerGetPasswordHandler(Sender: TObject; var APassword: String; const AIsWrite: Boolean; var VOk: Boolean);
  public
    { IWebTLS }
    function GetIOHandler: TIdServerIOHandler;
  public
    constructor Create(const AOptions: TTLSOptions);
  end;

implementation

{ TCharonTaurusTLS }

constructor TCharonTaurusTLS.Create(const AOptions: TTLSOptions);
begin
  inherited Create;
  FIOHandler := TTaurusTLSServerIOHandler.Create(nil);
  FIOHandler.OnGetPassword := TLSHandlerGetPasswordHandler;
  FIOHandler.SSLOptions.MinTLSVersion := AOptions.MinTLSVersion;
  FIOHandler.DefaultCert.PublicKey := AOptions.PublicKey;
  FIOHandler.DefaultCert.PrivateKey := AOptions.PrivateKey;
  FIOHandler.DefaultCert.RootKey := AOptions.RootKey;
  FPassPhrase := AOptions.PassPhrase;
end;

function TCharonTaurusTLS.GetIOHandler: TIdServerIOHandler;
begin
  Result := FIOHandler;
end;

procedure TCharonTaurusTLS.TLSHandlerGetPasswordHandler(Sender: TObject; var APassword: String; const AIsWrite: Boolean; var VOk: Boolean);
begin
  APassword := FPassPhrase;
end;

end.
