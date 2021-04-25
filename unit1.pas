unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  PairSplitter, fphttpclient, fpjson, opensslsockets;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    cmb_method: TComboBox;
    cmb_post_type: TComboBox;
    cmb_auth: TComboBox;
    Label2: TLabel;
    mm_authkey: TMemo;
    mm_body: TMemo;
    mm_header: TMemo;
    mm_respon: TMemo;
    PageControl1: TPageControl;
    PairSplitter1: TPairSplitter;
    PairSplitterSide1: TPairSplitterSide;
    PairSplitterSide2: TPairSplitterSide;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    txt_url: TEdit;
    Label1: TLabel;

    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormShow(Sender: TObject);
begin

end;

procedure TForm1.Button1Click(Sender: TObject);
var
   M:String;
   S : String;
    Client: TFPHTTPClient;
    Params, PostType, authType : string;
    jHeader, jBody : TJSONData;
    i,j:integer;
begin

    try
      try
      Client := TFPHttpClient.Create(nil);
      M:=cmb_method.Items.Strings[cmb_method.ItemIndex];
      PostType:=cmb_post_type.Items.Strings[cmb_post_type.ItemIndex];
      authType:=cmb_auth.Items.Strings[cmb_auth.ItemIndex];
      //Client.AllowRedirect := true;
      if M='GET' then begin
          Client.Get(txt_url.Text, mm_respon.Lines);

      end else if M='POST' then begin
          //Authorization
          if authType='Bearer' then Client.AddHeader('Authorization','Bearer '+mm_authkey.Text) ;
          //header body
          if PostType='JSON' then Client.AddHeader('Content-Type','application/json')
          else if PostType='Text' then Client.AddHeader('Content-Type','text/plain')
          else if PostType='JavaScript' then Client.AddHeader('Content-Type','application/javascript')
          else if PostType='HTML' then Client.AddHeader('Content-Type','text/html')
          else if PostType='XML' then Client.AddHeader('Content-Type','application/xml');

          jHeader := GetJSON(mm_header.Text);
          jBody := GetJSON(mm_body.Text);
          if jHeader is TJSONData then begin
            for i := 0 to jHeader.Count - 1 do
            begin
              Client.AddHeader(TJSONObject(jHeader).Names[i],jHeader.FindPath(TJSONObject(jHeader).Names[i]).AsString);
            end;
          end;

          Params:=mm_body.Text;
          Client.RequestBody := TRawByteStringStream.Create(Params);
          Client.Post(txt_url.Text,mm_respon.Lines);


      end;
    except

      on E: EHttpClient  do
        mm_respon.Text := E.Message;
      on E:Exception do
        mm_respon.Text := E.Message ;
      else
        raise;
      end;
    finally
      Client.RequestBody.Free;
      Client.Free;
    end;
end;

end.

