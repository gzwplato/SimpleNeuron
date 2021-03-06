unit Unit1; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Spin;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    cbBinary: TCheckBox;
    cbActivationFunction: TComboBox;
    lbTheta: TEdit;
    lbOutput: TEdit;
    GParameter: TEdit;
    AParameter: TEdit;
    GroupBox1: TGroupBox;
    InputFunctionOut: TEdit;
    InputFunction: TComboBox;
    InputFuncLabel: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    lbGParameter: TLabel;
    lbAParameter: TLabel;
    lbNrInputs: TLabel;
    seNr: TSpinEdit;
    procedure cbBinaryChange(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure Edit6Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GroupBox1Click(Sender: TObject);
    procedure Input1Change(Sender: TObject);
  private
    { private declarations }
    DinamicInputs: array[0..50] of TEdit;
    DinamicWeights: array[0..50] of TEdit;
    DinamicInputsLabels : array[0..50] of TLabel;
    DinamicWeightsLabels : array[0..50] of TLabel;
  public
    { public declarations }
    function linearCombine(w,x : array of double):double;
    function treshold(v:double):double;
    function sigmoid (v, g: double):double;
    function tanh(v:double):double;
    function linear(a,v:double):double;
    function piecewiseLinear(v:double):double;
    function signum(v:double):double;
    function rampa(v:double):double;
  end; 

var
  Form1: TForm1;
  w,x : array[0..50] of double;
  binary : boolean;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Edit6Change(Sender: TObject);
begin
end;

procedure TForm1.Edit1Change(Sender: TObject);
var i : integer;
begin

  for i:=0 to 50 do
   if i<=StrToInt(seNr.Text)-1 then
      begin
           DinamicInputs[i].Show;
           DinamicInputsLabels[i].Show;
           DinamicWeights[i].Show;
           DinamicWeightsLabels[i].Show;
      end
   else
       begin
         DinamicInputs[i].Hide;
         DinamicInputsLabels[i].Hide;
         DinamicWeights[i].Hide;
         DinamicWeightsLabels[i].Hide;

       end;

end;

procedure TForm1.cbBinaryChange(Sender: TObject);
begin
 binary := cbBinary.Checked;
end;

procedure TForm1.FormCreate(Sender: TObject);
var i : integer;
begin
  for i:=0 to 50 do
   begin
     DinamicInputs[i]:=TEdit.Create(self);
     DinamicInputs[i].Text := '0';
     DinamicInputs[i].Left := 71;
     DinamicInputs[i].Top := 80 +30*i;
     DinamicInputs[i].Height:= 27;
     DinamicInputs[i].Visible:= false;
     DinamicInputs[i].Parent := Form1;
     DinamicInputs[i].OnEditingDone:= @Input1Change;

     DinamicInputsLabels[i]:=TLabel.Create(self);
     DinamicInputsLabels[i].Caption := 'Input '+IntToStr(i+1);
     DinamicInputsLabels[i].Left := 20;
     DinamicInputsLabels[i].Top := 80 +30*i;
     DinamicInputsLabels[i].Height:= 27;
     DinamicInputsLabels[i].Visible:= false;
     DinamicInputsLabels[i].Parent := Form1;

     DinamicWeights[i]:=TEdit.Create(self);
     DinamicWeights[i].Text := '0';
     DinamicWeights[i].Left := 230;
     DinamicWeights[i].Top := 80 +30*i;
     DinamicWeights[i].Height:= 27;
     DinamicWeights[i].Visible:= false;
     DinamicWeights[i].Parent := Form1;


     DinamicWeightsLabels[i]:=TLabel.Create(self);
     DinamicWeightsLabels[i].Caption := '*Weight '+IntToStr(i+1);
     DinamicWeightsLabels[i].Left := 150;
     DinamicWeightsLabels[i].Top := 80 +30*i;
     DinamicWeightsLabels[i].Height:= 27;
     DinamicWeightsLabels[i].Visible:= false;
     DinamicWeightsLabels[i].Parent := Form1;
  end;

end;



procedure TForm1.GroupBox1Click(Sender: TObject);
begin

end;

procedure TForm1.Input1Change(Sender: TObject);
var u,y,v : double;
var temp_edit : String;
var m ,j : integer;
var g ,a , theta: double;
begin
    theta := StrToFloat(lbTheta.Text);
    g := StrToFloat(GParameter.Text);
    a := StrToFloat(AParameter.Text);;
    m:= 50;
    for j:=0 to m do
         begin
         temp_edit := DinamicInputs[j].Text;
         x[j] := StrToFloat(temp_edit);
         w[j] := StrToFloat(DinamicWeights[j].Text);

         end;
    u := linearCombine(w,x);
    InputFunctionOut.Caption:= FloatToStr(u);
    v := u - theta;
    if cbActivationFunction.ItemIndex = 0 then  y := treshold (v);
    if cbActivationFunction.ItemIndex = 1 then  y := piecewiseLinear (v);
    if cbActivationFunction.ItemIndex = 2 then
                                          begin
                                          y := sigmoid (v,g);
                                          if binary then
                                            if y < 0.5 then y := 0
                                                     else y := 1;
                                          end;
    if cbActivationFunction.ItemIndex = 3 then
                                          begin
                                          y := tanh (v);
                                          if binary then
                                            if y < 0 then y := -1
                                                     else y := 1;
                                          end ;

    if cbActivationFunction.ItemIndex = 4 then  y := Linear(a,v);
    if cbActivationFunction.ItemIndex = 5 then
                                          begin
                                          y := Rampa(v);
                                          if binary then
                                            if y < 0 then y := -1
                                                     else y := 1;

                                          end;
    if cbActivationFunction.ItemIndex = 6 then  y := signum (v);

    lbOutput.Text := FloatToStr(y)
end;

function TForm1.linearCombine(w,x : array of double):double;
  var j,m:integer;
  begin
  m:= StrToInt(seNr.Text)-1;
  if  InputFunction.ItemIndex =0 then
      begin
      result := 0;
      for j:=0 to m do
      begin
          result:= result + w[j] * x[j];  //Sum
       end;
      end;
  if  InputFunction.ItemIndex =1  then   //Product
      begin
      result := 1;
      for j:=0 to m do
      begin
          result:= result * w[j] * x[j];
       end;
      end;

      if  InputFunction.ItemIndex =3  then   //Max
      begin
      result := 0;
      for j:=0 to m do
      begin
           if    w[j] * x[j] > result then   result:=  w[j] * x[j];
       end;
      end;

       if  InputFunction.ItemIndex =2  then   //Min
      begin
      result := w[j] * x[j];
      for j:=0 to m do
      begin
           if    w[j] * x[j] < result then   result:=  w[j] * x[j];
       end;
      end;


end;

function TForm1.treshold(v:double):double;
begin
  if v >= 0 then
     result :=1
  else
     result :=0;

end;
function TForm1.sigmoid (v, g: double):double;
begin
     result := 1 / (1 + exp(0 - (g*v)));
end;

function TForm1.piecewiseLinear(v:double):double;
begin
  if v >= 0.5 then
     result :=1
  else if v > -0.5 then
     result :=v
  else
     result :=0;
end;
function TForm1.Linear(a,v:double):double;
begin
  result := v*a;

end;

function TForm1.tanh(v:double):double;
begin
   result := (exp(v)- exp(0-v))/(exp(v)+exp(0-v))
end;

function TForm1.signum(v:double):double;
begin
  if v >= 0 then
     result :=1
  else
     result :=-1;
end;


function TForm1.rampa(v:double):double;
begin
  if v >= 1 then
     result :=1
  else
     if v < -1 then
     result :=-1
     else
     result := v;
end;


end.

