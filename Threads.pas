(* File Sonogram
 * Просто помни, сука, что программу накодил Серенков Валерий,
 * E-Mail: <webmaster@anime.net.kg>
 * Сайт: http://anime.net.kg/
 *)
unit Threads;

interface

uses
	Windows, Classes, Math, Dialogs,SysUtils, Graphics;

type
	Thread = class(TThread)
  private
		procedure AssignBitmap;
		var bitmap: TBitmap;
				slice,width,blockSize : integer;
  protected
		procedure Execute; override;
	public
		procedure DrawBarPlot(slice,width,blockSize: integer);
		var
			drawQuery: boolean;
	end;

var DataThread	:	Thread;
implementation

uses Unit1;

{ Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure Thread.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ Thread }
procedure Thread.AssignBitmap;
begin
	form1.image2.Picture.Bitmap.Assign(bitmap);
end;

procedure Thread.DrawBarPlot(slice,width,blockSize: integer);
begin
 self.slice := slice;
 self.width := width;
 self.blockSize := blockSize;
 bitmap := TBitmap.Create;
 bitmap.SetSize(form1.image2.Width,form1.image2.Height);
 self.drawQuery := true;
end;

procedure Thread.Execute;
var i,k	:	integer;
j: byte;
frequency,frequency1: TFrequency;
_max: int64;
scale,rest: double;
left, right, top, bottom : integer;
shift: integer;
ptr:pointer;
begin
while true do begin
if drawQuery then begin

if (binary_data = '') or (slice < 0) or (blockSize < 1) or terminated then
	EXIT;
//if slice*blockSize+blockSize > length(binary_data) then begin
 //	EXIT;
shift := unit1.shift*256;
for k := 0 to width - 1 do begin
frequency1 := Frequency_Analysis(binary_data, shift + slice*blockSize + k*blocksize,blockSize);
for j := 0 to 255 do
	inc(frequency[j], frequency1[j]);
if k mod 4 = 0 then begin

_max := 0;
for i := 0 to 255 do
	if _max<frequency[i] then
		_max:=frequency[i];
if (_max <> 0) and (slice*blockSize+blockSize < length(binary_data)) then
	scale := 1 / _max
else for I := 0 to 255 do
			 frequency[i] := 0;

with bitmap do begin
	Canvas.Brush.Color := 0;
	Canvas.FillRect(Rect(0,0,width,height));
	Canvas.Brush.Color := clBlue;
	for I := 0 to 255 do begin
		left := trunc((i)/256*width);
		top		:= height - trunc(frequency[i]*scale*(height));
		right := trunc((i+1)/256*width);
		bottom := height-1;
		Canvas.FillRect(Rect(left, top, right, bottom));
		rest := frequency[i]*scale*height;
		rest := rest - trunc(rest);
		canvas.Pen.Color := $FF7F7F;
		canvas.MoveTo( left,top-1);
		canvas.LineTo(right,top-1);
	end;
end;
Synchronize(AssignBitmap);
end;
end;
	for I := 0 to 255 do begin
		ptr := Unit1.bitmap.ScanLine[i];
		Move(ExBitmap2[i],ptr^, 640*4);
	end;
	DrawQuery := false;
	bitmap.Free;
end;
sleep(UpdateInterval);
end;
end;

end.
