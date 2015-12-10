﻿(* File Sonogram
 * Просто помни, сука, что программу накодил Серенков Валерий,
 * E-Mail: <webmaster@anime.net.kg>
 * Сайт: http://anime.net.kg/
 *)
unit Unit1;

interface

uses
	Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
	Dialogs, StdCtrls, ExtCtrls, ComCtrls, Math, Buttons, Menus, Tabs, DockTabSet,
	ToolWin;

{#region Classes}
{$REGION}
	type TFrequency = array[0..255] of cardinal;
	type
	TForm1 = class(TForm)
		Image1: TImage;
    OpenDialog1: TOpenDialog;
    TrackBar1: TTrackBar;
    Label1: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Image2: TImage;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Open1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    View1: TMenuItem;
    Frequencyanalysis1: TMenuItem;
    Controls1: TMenuItem;
    SpeedButton3: TSpeedButton;
    TabControl1: TTabControl;
    ComboBox1: TComboBox;
    Timer1: TTimer;
    SpeedButton5: TSpeedButton;
    Panel3: TPanel;
    RadioGroup1: TRadioGroup;
    Label2: TLabel;
		Image3: TImage;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Bevel2: TBevel;
    procedure Image2MouseLeave(Sender: TObject);
    procedure Image2MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
		procedure CheckBox1Click(Sender: TObject);
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Image1MouseEnter(Sender: TObject);
    procedure Panel2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Panel2MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Panel2MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
		procedure Button1Click(Sender: TObject);
  private
		dragging: boolean;
		procedure OnWheel(var Msg: TMessage); message WM_MOUSEWHEEL;
	public
		procedure draw(zoomOut: real);
		procedure InvarDraw(zoomOutApr, zoomOutApost: real; center: integer);
		procedure BarPlot(slice, width, blockSize: integer); overload;
		procedure BarPlot(frequency: TFrequency; highlight: integer); overload;
		procedure drawMarker(var bitmap: TBitmap);
		procedure getSettings;
		procedure EnableBtn(Button: TSpeedButton; Enabled: Boolean);
		function  EnabledBtn(Button: TSpeedButton): boolean;
		procedure SetPanel2WL;
		var statistics : TFrequency;
	end;

type TMarker = record
	position: integer;
	left,right: integer;
	Fixed		:	Boolean;
end;

{$ENDREGION}

function  Frequency_analysis(const data: AnsiString; shift,count: integer):TFrequency;
function  load_file(Path:string; resultPTR: PAnsiString):boolean;

function getAbsolutePos(screenPos: integer): integer; inline;
function getBlockSize: integer; inline;
function booltoint(V: boolean): integer;

{#region variables/constants}
{$REGION}

const UpdateInterval = 50; //100 ms
			magicConstant	 = 256;
var
	Form1: TForm1;
	_File: TFileStream;
	binary_data: AnsiString;
	shift: cardinal;
	oldShift: cardinal = 0;
	dragStart: integer;
	marker			: TMarker;
	bitmap,bitmap2 :	TBitmap;
	ExBitmap2		: Array [0..255] of array [0..636] of TColor;

	showMax			:	boolean = false;
	antiAlias		:	boolean = true;
	trackbarPos	: integer = 0;
	trackbarMax	:	integer = 0;
	maxAntiAlias: integer = 16 * magicConstant;
	windowWidth	:	integer = 640;
	_OnWheel    :	integer = 0;
{$ENDREGION}

implementation

uses Threads;

{$R *.dfm}
{$R Resources.res}

{#region form events}
{$REGION}

procedure TForm1.OnWheel(var Msg: TMessage);
var shiftDelta, t0: cardinal;
tmp: boolean;
pos: integer;
begin
	getSettings;
	case _OnWheel of
	0: begin
		Trackbar1.OnChange := nil;
		pos := trackbar1.Position;
		if (msg.WParamHi = $FF88) then
			TrackBar1.Position := TrackBar1.Position + 1
		else
		if (msg.WParamHi = $0078) then
			TrackBar1.Position := TrackBar1.Position - 1;
		InvarDraw(pos, trackbar1.Position, mouse.CursorPos.X - left - 3);
		label1.Caption := 'Zoom out: 2^'+inttostr(trackbar1.Position)+'x';
		SetPanel2WL;
		Trackbar1.OnChange := TrackBar1Change;
	end;
	1: begin
	if trackbar1.Position < trackbar1.Max then begin
		shiftDelta := trunc(Math.power(2, trackbarPos)) shl 6;
		if trackbar1.Position < 0 then
			shiftDelta := trunc(Math.power(2, 8+trackbarPos));
			
	with panel2 do begin
		if (msg.WParamHi = $FF88) then
		 //	if ((shift+shiftDelta+math.Power(2, trackbar1.Position)*640)*256 < length(binary_data)) then
			inc(shift,shiftDelta) else
			 //	shift := trunc((length(binary_data) - math.power(2, trackbar1.Position)*256*(image1.Width+shiftDelta))/256);
		if (msg.WParamHi = $0078) then
			if (shift >= shiftDelta) then
				dec(shift,shiftDelta)
			else
				shift := 0;
		if shift>length(binary_data) div magicConstant-getblockSize/magicConstant*windowWidth then begin
			shift := trunc((length(binary_data) div magicConstant)-getblockSize/magicConstant*640);
			timer1.Enabled := false;
			panel2.Left := panel1.Width - panel2.Width;
		end;
		if trackbarPos = trackbarMax then
			shift := 0;
		t0 := gettickcount;
		{ TODO : Use Labels insthead of coolBar }
		Coolbar1.Bands[0].Text := 'Offset: ' +
		inttohex(unit1.shift*magicConstant,8) + ' - ' +
		inttohex(unit1.shift*magicConstant + getBlockSize*windowWidth,8);

		Coolbar1.Bands[2].Text := '';
		if oldShift<>shift then begin
			oldShift := shift;
			draw(trackbarPos);
		end;
		Label2.Caption := 'Elapsed: ' + inttostr(getTickCount - t0) + 'ms';
		SetPanel2WL;
	end;
		 {	form1.Caption := 	floattostr((unit1.shift)*magicConstant/length(binary_data))+' - '+
											floattostr((unit1.shift+trunc(Math.power(2,trackbar1.Position)*windowWidth))*magicConstant/length(binary_data))+
											' - '+inttostr(t0)+'ms';  }
	//BarPlot(0,getBlockSize);
	end;
	end;
	end;
	inherited;  //save descriptor
end;

procedure TForm1.Button1Click(Sender: TObject);
var width,zoomOut: integer;
t0: dword;
begin
if OpenDialog1.execute then begin
	load_file(OpenDialog1.FileName, @binary_data);
	marker.left:=0;
	marker.right := 0;
	zoomOut := 0; shift := 0;
	with bitmap.Canvas do begin
		Brush.Color := 0;
		FillRect(Rect(0,0,width,height));
	end;
	trackbar1.onchange := nil;
	while Math.Power(2, zoomOut)*magicConstant*image1.Width < length(binary_data) do
		inc(zoomOut);
	trackbar1.Max := zoomOut;
	trackbar1.Position := zoomOut;
	getSettings;
	trackbar1.onchange := TrackBar1Change;
	t0 := getTickCount;
	draw(trackbar1.Position);
  draw(trackbar1.Position);
	BarPlot(0,639, getBlockSize);
	label1.Caption := 'Zoom out: 2^'+inttostr(trackbar1.Position)+'x';
	Caption := 	ExtractFileName(OpenDialog1.FileName) + ' (' +
							ExtractFilePath(OpenDialog1.FileName)+
							') - FileSonogram';
	Coolbar1.Bands[0].Text := 'Offset: ' +
		inttohex(0,8) + ' - ' +
		inttohex(length(binary_data),8);
	Coolbar1.Bands[1].Text := 'Elapsed: ' + inttostr(getTickCount - t0) + 'ms';
	Coolbar1.Bands[2].Text := '';
end;

end;

procedure TForm1.Timer1Timer(Sender: TObject);
var msg: tmessage;
begin
 msg.WParamHi := $FF88;
 OnWheel(msg);
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
var msg: Tmessage;
begin
getSettings;
		if trackbarPos =	trackbarMax then begin
			shift := 0;
			EnableBtn(SpeedButton3, false);
		end
		else if not EnabledBtn(SpeedButton3) then
			EnableBtn(SpeedButton3, true);
SetPanel2Wl;
if shift>length(binary_data) div magicConstant-getblockSize/magicConstant*windowWidth then begin
	msg.WParamHi := $0078;
	OnWheel(msg);
	msg.WParamHi := $FF88;
	OnWheel(msg);
end;
if binary_data<>'' then
	draw(trackbarPos);
label1.Caption := 'Zoom out: 2^'+inttostr(trackbarPos)+'x';
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
//showMax :=  CheckBox1.Checked;
	getSettings;
	draw(trackbarPos);
end;

procedure TForm1.CheckBox2Click(Sender: TObject);
begin
//	antiAlias := checkBox2.Checked;
	ComboBox1.Enabled := checkbox2.Checked;
	getSettings;
	draw(trackbarPos);
end;

procedure TForm1.Exit1Click(Sender: TObject);
begin
Close;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//bitmap.free;
end;

procedure TForm1.FormCreate(Sender: TObject);
var Stream: TResourceStream;
i: integer;
bitmap1: TBitmap;
begin
binary_data := '';
bitmap := TBitmap.Create;
bitmap.SetSize(640, 256);
bitmap.Canvas.Brush.Color := 0;
bitmap.Canvas.FillRect(rect(0,0,640,256));
image1.Picture.Bitmap.Assign(bitmap);
image2.Canvas.Brush.Color := 0;
image2.Canvas.FillRect(Rect(0,0,image2.width,image2.height));
marker.position := 0;
marker.Fixed := true;
shift := 0;
//bitmap2 := TBitmap.Create;
dragging := false;
 {	DataThread 								:= 	Thread.Create(True);
	DataThread.FreeonTerminate:=	true;
	DataThread.drawQuery := false;
	DataThread.Resume; }
Stream := TResourceStream.Create(hInstance, 'glyph11', 'BMP');
SpeedButton1.Glyph.LoadFromStream(stream);
Stream := TResourceStream.Create(hInstance, 'glyph02', 'BMP');
SpeedButton2.Glyph.LoadFromStream(stream);
Stream := TResourceStream.Create(hInstance, 'glyph03', 'BMP');
SpeedButton3.Glyph.LoadFromStream(stream);
Stream := TResourceStream.Create(hInstance, 'glyph12', 'BMP');
SpeedButton5.Glyph.LoadFromStream(stream);
Stream.Free;

Bitmap1 := TBitmap.Create;
Bitmap1.SetSize(Image3.Width, Image3.Height);
with bitmap1.Canvas do begin
	brush.Color := $A36B5B;
	Font.Color := $FFFFFF;
	Font.Size := 6;
	FillRect(Rect(0,0,width,height));
	Pen.Color := $FFFFFF;
	i := 32;
	for I := 0 to 255 do begin
		MoveTo(0,i);
		if i mod 32 = 0 then
			LineTo(5,i)
		else
		if i mod 16 = 0 then
			LineTo(4,i)
		else
		if i mod 4 = 0 then
			LineTo(3,i)
	end;
	i := 0;
	while i < 256 do begin
		TextOut(7,i-5,inttostr(255-i));
		inc(i,32);
	end;
	i := 255;
	TextOut(7,i-8,'0');
	i := 0;
	TextOut(7,0,'255');
end;
Image3.Picture.Bitmap.Assign(bitmap1);
bitmap1.Free;
end;

procedure TForm1.Image1Click(Sender: TObject);
var test: integer;
begin
marker.Fixed := true;
test :=mouse.CursorPos.X - left - 3;
if abs(mouse.CursorPos.X - left - 3 - dragStart) < 3 then begin
	marker.left := getAbsolutePos(mouse.CursorPos.X - left - 2);
	marker.right := marker.left;
	dragging := false;
end;

//BarPlot(mouse.CursorPos.X - left - 3 ,trunc(Math.Power(2,trackbar1.Position)*256));
CoolBar1.Bands[3].Text := Format('Selection: %s - %s',[IntToHex(marker.left,8),IntToHex(marker.right,8)]);
BarPlot(mouse.CursorPos.X - left - 3, 1, getBlockSize);
drawMarker(bitmap);
image1.Picture.Bitmap.Assign(bitmap);
end;

procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
	Shift: TShiftState; X, Y: Integer);
begin
if button = mbLeft then begin
	marker.Fixed := false;
	marker.left := getAbsolutePos(x);
	dragging := true;
	dragStart := x
end else
if button = mbMiddle then
	radioGroup1.ItemIndex := 0;
end;

procedure TForm1.Image1MouseEnter(Sender: TObject);
begin
SetFocus;
end;

procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
	Y: Integer);
	var i: byte;
	ptr: pointer;
	begin
panel1.SetFocus;
if (binary_data = '') or
		marker.Fixed or
		not dragging or
		(x < 0) or
		(x > windowWidth) or
		(getAbsolutePos(x) > length(binary_data)) then
	EXIT;
marker.right := getAbsolutePos(x);
if abs(x - dragstart) * getBlockSize < 1 shl 22 then
	BarPlot(min(dragstart,x), max(dragstart,x) - min(dragstart,x), getBlockSize)
else
	for I := 0 to 255 do begin
		ptr := bitmap.ScanLine[i];
		Move(ExBitmap2[i],ptr^, 640*4);
	end;
drawMarker(bitmap);
image1.Picture.Bitmap.Assign(bitmap);
//SetFocus;
end;

procedure TForm1.Image1MouseUp(Sender: TObject; Button: TMouseButton;
	Shift: TShiftState; X, Y: Integer);
begin
if button = mbLeft then begin
	if dragging then begin
		marker.Fixed := true;
		if x < 0 then
			x := 0;
		if x > windowWidth then
			x := windowWidth;
		marker.right := getAbsolutePos(x);
		dragging := false;
		CoolBar1.Bands[3].Text := Format('Selection: %s - %s',[IntToHex(marker.left,8),IntToHex(marker.right,8)]);
		BarPlot(min(dragstart,x), max(dragstart,x) - min(dragstart,x), getBlockSize);
	end;
end else
if button = mbMiddle then
	RadioGroup1.ItemIndex := 1;
end;

procedure TForm1.Image2MouseLeave(Sender: TObject);
begin
if binary_data = '' then
	EXIT;
BarPlot(statistics, -1);
end;

procedure TForm1.Image2MouseMove(Sender: TObject; Shift: TShiftState; X,
	Y: Integer);
var i: byte;
sum: int64;
begin
if binary_data = '' then
	EXIT;
i := round(x/image2.Width * 255);
CoolBar1.Bands[2].Text := inttohex(i,2)+'h - '+
	floattostrf( statistics[i]/length(binary_data)*100, fffixed, 6, 5)+'% - ' +
	inttostr(statistics[i]);
BarPlot(statistics, i);
end;

procedure TForm1.Panel2MouseUp(Sender: TObject; Button: TMouseButton;
	Shift: TShiftState; X, Y: Integer);
var zoomOut : integer;
begin
{	if (button = mbLeft) and (trackbar1.Position < trackbar1.Max) then begin
		dragging := false;
		if binary_data<>'' then begin
			unit1.shift := trunc(panel2.Left/panel1.Width*length(binary_data)/256);
			draw(trackbar1.Position);
		end;
	end;  }
	dragging := false;
	//BarPlot(x,getBlockSize);
	with panel2 do
	if left > panel1.Width - width  then
				left := panel1.Width - width
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
trackbar1.Position := trackbar1.Position - 1;
end;

procedure TForm1.SpeedButton2Click(Sender: TObject);
begin
trackbar1.Position := trackbar1.Position + 1;
end;

procedure TForm1.SpeedButton3Click(Sender: TObject);
begin
trackbar1.Position := trackbar1.Max;
end;

procedure TForm1.SpeedButton4Click(Sender: TObject);
begin
timer1.Enabled := not timer1.Enabled;
end;

procedure TForm1.Panel2MouseDown(Sender: TObject; Button: TMouseButton;
	Shift: TShiftState; X, Y: Integer);
begin
	if button = mbLeft then begin
		dragging := true;
		getSettings;
end;
end;

procedure TForm1.Panel2MouseMove(Sender: TObject; Shift: TShiftState; X,
	Y: Integer);
var
	_left: integer;
begin
 if dragging then begin
		with panel2 do begin
			_left := Mouse.CursorPos.X - Form1.left - 3 - width div 2;
			if _Left < 0 then
				Left := 0
			{else
			if _left > panel1.Width - width  then
				left := panel1.Width - width  }
			else
				left := _left;
			{if _left+width > panel1.Width then begin

				_left := panel1.Width - Width;
				left := _left;
			end;}
		end;
	if trackbarPos < trackbarMax then
		if binary_data<>'' then begin

			unit1.shift := trunc(panel2.Left/panel1.Width*length(binary_data)/magicConstant);
			draw(trackbarPos);
			//Threads.run(trackbar1.Position);
			//DataThread.drawQuery := true;

			//panel2.Left := trunc(panel1.Width*(shift*256/length(binary_data)));
			{form1.Caption := 	floattostr((unit1.shift)*256/length(binary_data))+' - '+
												floattostr((unit1.shift+trunc(Math.power(2,trackbar1.Position)*640))*256/length(binary_data))+
												' - '+intToStr(t0)+'ms'; }
	end;
 end;
end;

{$ENDREGION}

{#region form methods}
{$REGION}

procedure TForm1.EnableBtn(Button: TSpeedButton; Enabled: Boolean);
var stream: TResourceStream;
begin
if Button.Name = 'SpeedButton3' then begin
	if Enabled then
		stream := TResourceStream.Create(hInstance, 'glyph08', 'BMP')
	else
		stream := TResourceStream.Create(hInstance, 'glyph03', 'BMP');
	Button.Glyph.LoadFromStream(stream);
	Button.Tag := booltoint(Enabled);
end;

end;

function TForm1.EnabledBtn(Button: TSpeedButton): boolean;
begin
	if button.tag = 0 then result := false
	else                   result := true;
end;

procedure TForm1.getSettings;
begin
	showMax := CheckBox1.Checked;
	if trackbar1.Position < 0 then
		antiAlias := not checkBox2.Checked
	else
		antiAlias := checkBox2.Checked;
	trackbarPos := trackbar1.Position;
	trackbarMax := trackbar1.Max;
	maxAntiAlias := trunc(math.Power(2,combobox1.ItemIndex + 4))*magicConstant;
	windowWidth := image1.Width;
	_OnWheel := RadioGroup1.ItemIndex;
end;

procedure TForm1.SetPanel2WL;
begin
panel2.Left := trunc(panel1.Width*(shift*magicConstant/length(binary_data)));
panel2.Width := trunc(Math.Power(2,trackbar1.Position)*magicConstant*windowWidth/length(binary_data)*panel1.Width);
with panel2 do
	if left > panel1.Width - width  then
		left := panel1.Width - width;
end;

{$ENDREGION}

{#region functions}
{$REGION}
function  Frequency_analysis(const data: AnsiString; shift,count: integer):TFrequency;
var
	_length : integer;
	_addr		:	dword;
	i				: integer;
begin
	for I := 0 to 255 do
		result[i] := 0;
	{if shift > _length then
		EXIT;
	if shift + count > _length then
		EXIT; }
	inc(count, shift);
	inc(shift);
	if count > length(data) then
		count := length(data);
	if shift < 1 then
		shift := 1;
	for i := shift to count do
		inc(result[ord(data[i])]);
	 //	inc(result[byte(ptr(_addr))]);
		//inc(_addr);
end;

function getAbsolutePos(screenPos: integer): integer;
begin
	result := shift*256 + trunc(screenPos*getBlockSize);
end;

function getBlockSize: integer;
begin
	result := trunc(Math.Power(2,form1.trackbar1.Position)*magicConstant);
end;

function booltoint(V: boolean): integer;
begin
	if V then result := 1
	else      result := 0;
end;

function load_file(Path:string; resultPTR: PAnsiString):boolean;
var _file			:	file;
		I					:	integer;
		i2				:	integer;
		file_size	: integer;
		buf				: pointer;
		buf1				:	AnsiString;
		ptr				:	PAnsiChar;
		oneByte:	AnsiChar;
begin
			assignfile(_file,Path);
			FileMode := fmOpenRead;
			Buf := AllocMem(4096);
			try
			try
      	resultPTR^ := '';
				reset(_file,1);
				file_size := fileSize(_file);
				//setLength(resultPTR^, file_size);
				reset(_file,4096);
				SetLength(resultPTR^, file_size);
				for i:=0 to file_size shr 12 - 1 do begin
					blockRead(_file,buf^,1);
					ptr := @(resultPTR^[i*4096+1]);
					//resultPTR^ := resultPTR^ + Copy(AnsiString(buf), 0, 4096);
					Move(buf^, ptr^, 4096);
					//for I2 := 0 to 4095 do
					 //	resultPTR^[i * 4096 + i2 + 1] := chr(buf[i2]);
				end;
				reset(_file,1);
				seek(_file,trunc(file_size / 4096) * 4096);
				while not eof(_file) do begin
					blockread(_file,oneByte,1);
					resultPTR^[filePos(_file)] := oneByte;
				end;
				Result:=true;
				except
					setLength(resultPTR^,0);
					Result:=false;
					MessageBox(	form1.Handle,
											PChar('Недостаточно памяти.'),
											PChar('Error!'),
											MB_ICONSTOP+MB_OK);
				end;
      finally
				closefile(_file);
				Freemem(buf);
			end;
end;

{$ENDREGION}

{#region Draw group}
{$REGION}

procedure TForm1.draw(zoomOut: real);
var i2,i3,max		:	integer;
		i : real;
		buf					: AnsiString;
		frequency 	: TFrequency;
		scale				: extended;
		Tmp					: byte;
		_FileSize		: integer;
		blockCnt		: real;
		optVar1			:	integer;
		ptr					: pointer;
		shift,t0		:	cardinal;

begin
	if binary_data = '' then exit;
	shift := unit1.shift;
	t0 := getTickCount;
	zoomOut:= Math.power(2,zoomOut);
	_FileSize := length(binary_data);
	//shift := trunc(panel2.Left/panel1.Width*_FileSize/256);
	blockCnt :=  _Filesize div magicConstant;
	if zoomOut < 1 then
		blockCnt :=  _Filesize div trunc(magicConstant*zoomOut);
	//if zoomOut>=1 then

	if blockcnt > windowWidth*zoomOut then
		blockcnt := windowWidth*zoomOut;
	if shift>(_Filesize div magicConstant)-zoomOut*640 then
		shift := trunc((_Filesize div magicConstant)-zoomOut*640);
	for I3 := 0 to 255 do
		for I2 := 0 to 639 do
			Exbitmap2[i3][i2] := 0;
	if zoomOut*640*magicConstant > _FileSize then
	begin
		Shift := 0;
	end;
	I:=shift;
	while I-shift < blockCnt do begin
		buf:='';
		if (i*magicConstant > _FileSize) then
			break;
		//for I2 := 0 to 255 do
			//buf := buf + binary_data[(i)*256 + i2];
		if trunc(i*magicConstant) + trunc(magicConstant*zoomOut) < length(binary_data)  then
		
		if antiAlias and (trunc(magicConstant*zoomOut) > maxAntiAlias) then
			frequency := Frequency_Analysis(binary_data, trunc(i*magicConstant), maxAntiAlias)
		else
		if antiAlias then
			frequency := Frequency_Analysis(binary_data, trunc(i*magicConstant),trunc(magicConstant*zoomOut))
		else
			frequency := Frequency_Analysis(binary_data, trunc(i*magicConstant),magicConstant);
		max := 0;
		for I2 := 0 to 255 do
			if max<frequency[i2] then
				max:=frequency[i2];
		if max <= 0 then begin
			//showMessage('Error!');
			I := i + zoomOut;
			continue;
    end;
		scale:=1/max;
		optVar1 := trunc((I-shift)/zoomOut);
		if optVar1 > 639 then
			optVar1 := 639;
		for I2 := 0 to 255 do begin
			tmp := trunc(frequency[i2]*scale*$FF);
			if showMax and (frequency[i2] = max) then
				ExBitmap2[255-i2,optVar1] := tmp shl 16
			else
				ExBitmap2[255-i2,optVar1] := (tmp shl 16) + (tmp shl 8) + tmp;
			//bitmap.Canvas.Pixels[,255-i2] := (tmp shl 16) + (tmp shl 8) + tmp;
		end;
		I := i + zoomOut;
	end;

	for I3 := 0 to 255 do begin
		ptr := bitmap.ScanLine[i3];
		Move(ExBitmap2[i3],ptr^, 640*4);
	end;
	drawMarker(bitmap);
	image1.Picture.Bitmap.Assign(bitmap);
end;

procedure TForm1.InvarDraw(zoomOutApr, zoomOutApost: real; center: integer);
var distance: integer;
mult : real;
begin
	distance := getAbsolutePos(center) - getAbsolutePos(0);
	mult := math.Power(2, zoomOutApost - zoomOutApr);
	distance := trunc(mult * distance);
	shift := trunc(getAbsolutePos(center) - distance) shr 8;
	if (shift*magicConstant > length(binary_data)) then
		shift := 0;
	Draw(zoomOutApost);
end;

procedure TForm1.BarPlot(frequency: TFrequency; highlight: integer);
var _max: int64;
i	:	integer;
scale,rest: double;
left, right, top, bottom : integer;
shift: integer;
ptr:pointer;
begin
bitmap2 := TBitmap.Create;
_max := 0;
for i := 0 to 255 do
	if _max<frequency[i] then
		_max:=frequency[i];
if (_max <> 0) then //and (slice*blockSize+blockSize < length(binary_data)) then
	scale := 1 / _max
else for I := 0 to 255 do
			 frequency[i] := 0;

with bitmap2 do begin
	SetSize(image2.Width,image2.Height);
	Canvas.Brush.Color := 0;
	Canvas.FillRect(Rect(0,0,width,height));
	for I := 0 to 255 do begin
		left := trunc((i)/256*width);
		top		:= height - trunc(frequency[i]*scale*(height));
		right := trunc((i+1)/256*width);
		bottom := height-1;
		if i = highlight then begin
			Canvas.Brush.Color := $FFFFFF;
			Canvas.MoveTo(left,top - 1);
			canvas.LineTo(right,top - 1);
			Canvas.Brush.Color := $FF00FF;
			Canvas.FillRect(Rect(left, top, right, bottom));
		end
		else begin
			Canvas.Brush.Color := clBlue;
			Canvas.FillRect(Rect(left, top, right, bottom));
			rest := frequency[i]*scale*height;
			rest := rest - trunc(rest);
			canvas.Pen.Color := $FF7F7F;
			canvas.MoveTo( left,top-1);
			canvas.LineTo(right,top-1);
		end;
	end;
end;
Image2.Picture.Bitmap.Assign(bitmap2);
//if marker.position <> slice then begin
bitmap2.Free;
 {	if (marker.position > 0) then
	for I := 0 to 255 do
		bitmap.Canvas.Pixels[marker.position,i] := Column[i];}
	for I := 0 to 255 do begin
		ptr := bitmap.ScanLine[i];
		Move(ExBitmap2[i],ptr^, 640*4);
	end;
 //	marker.position := slice;

//end;
end;

procedure TForm1.BarPlot(slice, width, blockSize: integer);
var
frequency: TFrequency;
shift: integer;
begin
if (binary_data = '') or (slice < 0) or (blockSize < 1) then
	EXIT;
//if slice*blockSize+blockSize > length(binary_data) then begin
 //	EXIT;
shift := unit1.shift*256;
statistics := Frequency_Analysis(binary_data, shift + slice*blockSize,blockSize*width);
BarPlot(statistics, -1);
end;

procedure TForm1.drawMarker(var bitmap: TBitmap);
var blockSize		: integer;
		shift				:	integer;
		left, right	: integer;
		i, _max			:	integer;
begin
	blockSize := getBlockSize;
	shift := unit1.shift * magicConstant;
	left := trunc((marker.left-shift)/blockSize);
	right :=trunc((marker.right-shift)/blockSize);
	with bitmap do begin
		Canvas.Pen.Style := psdot;
		Canvas.Pen.Width := 1;
		Canvas.Pen.Mode := pmMerge;
		Canvas.Pen.Color := clYellow;
		Canvas.MoveTo(left,height);
		Canvas.LineTo(left,0);
		Canvas.MoveTo(right,height);
		Canvas.LineTo(right,0);
		Canvas.Pen.Color := $FF00FF;
		Canvas.Pen.Mode := pmmask;
		Canvas.Pen.Style := psSolid;
		I := min(left, right) + 1;
		_max := max(left, right);
		if i < 0 then
			i := 0;
		if _max > width then
			_max := width;
		while i < _max do begin
			Canvas.MoveTo(i,height);
			Canvas.LineTo(i,0);
			inc(i);
		end;
	end;
end;

{$ENDREGION}

end.
