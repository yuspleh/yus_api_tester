unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  PairSplitter, fphttpclient, fpjson, opensslsockets, SQLite3Conn, SQLDB;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    cmb_method: TComboBox;
    cmb_post_type: TComboBox;
    cmb_auth: TComboBox;
    Label2: TLabel;
    LstReq: TListBox;
    mm_authkey: TMemo;
    mm_body: TMemo;
    mm_header: TMemo;
    mm_respon: TMemo;
    PageControl1: TPageControl;
    PairSplitter1: TPairSplitter;
    PairSplitterSide1: TPairSplitterSide;
    PairSplitterSide2: TPairSplitterSide;
    sqlite3conn: TSQLite3Connection;
    SQLQuery1: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    txt_url: TEdit;
    Label1: TLabel;

    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RefreshUrlList();
  private

  public

  end;

var
  Form1: TForm1;
  tbl:string;
implementation

{$R *.lfm}

{ TForm1 }
procedure TForm1.RefreshUrlList();
begin
  LstReq.Items.Clear;
  SQLQuery1.SQL.Text:='select * from '+tbl;
  SQLQuery1.Open;
   while not SQLQuery1.Eof do begin
     LstReq.Items.Add(SQLQuery1.FieldByName('url').AsString);
     SQLQuery1.Next;
   end;
   SQLQuery1.Close;
end;

procedure TForm1.FormShow(Sender: TObject);
var
  r:integer; CreateTable:string;
begin
  try

    tbl:='request';
    CreateTable:='CREATE TABLE IF NOT EXISTS '+tbl+' ('+
	'id INTEGER PRIMARY KEY AUTOINCREMENT,'+
   	'url VARCHAR(255),'+
	'method VARCHAR(255),'+
        'header VARCHAR(255),'+
        'body VARCHAR(255)'+
    ')';
    sqlite3conn.Connected:=true;
    SQLQuery1.SQL.Text:=CreateTable;
    SQLQuery1.ExecSQL;
    SQLTransaction1.Commit;
    RefreshUrlList;
  except
  on E: Exception do begin
       ShowMessage(e.Message);
       Application.Terminate;
     end;
  end;


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
      SQLQuery1.SQL.Text:='insert into '+tbl+' (url, method, header, body) values (:url, :method, :header, :body)';
      SQLQuery1.Params.paramByName('url').AsString := txt_url.Text;
      SQLQuery1.Params.paramByName('method').AsString := cmb_method.Items.Strings[cmb_method.ItemIndex];
      SQLQuery1.Params.paramByName('header').AsString := mm_header.Text;
      SQLQuery1.Params.paramByName('body').AsString := mm_body.Text;
      SQLQuery1.ExecSQL;
      SQLTransaction1.Commit;
      RefreshUrlList;

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

