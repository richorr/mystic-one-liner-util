Program MysticOLUtil;
{$mode objfpc}{$h+}

Uses StrUtils, SysUtils, Crt;

Const 
  OneLinerFileName = 'oneliner.dat';

Type 
(* ONELINERS.DAT found in the data directory.  This file contains all the
   one-liner data.  It can be any number of records in size. *)

  OneLineRec = Record
    Text : String[79];
    From : String[30];
  End;

function OpenFileForReadWrite(out F: File; AFileName: String; ATimeoutInMilliseconds: Integer): Boolean;
var
  I: Integer;
begin
  Result := false;

  if (FileExists(AFileName)) then
  begin
    for I := 1 to ATimeoutInMilliseconds div 100 do
    begin
      Assign(F, AFileName);
      {$I-}Reset(F, 1);{$I+}
      if (IOResult = 0) then
      begin
        Result := true;
        Exit;
      end;

      Sleep(100); // Wait 1/10th of a second before retrying
    end;
  end 
  else
  begin
    Assign(F, AFileName);
    {$I-}ReWrite(F, 1);{$I+}
    if (IOResult = 0) then
    begin
      Result := true;
      Exit;
    end;
  end;
end;

function GetAbsolutePath(AFileName: String): String;
begin
//  AFileName := StringReplace(AFileName, '`*', [rfReplaceAll, rfIgnoreCase]);
  Result := ExpandFileName(AFileName);
end;

procedure ListOneLiners;
var
  OneLinerFullPath: string;
  F: File Of OneLineRec;
  Rec: OneLineRec;
  idx: integer;
begin
  OneLinerFullPath := GetAbsolutePath(OneLinerFileName);

  if NOT (OpenFileForReadWrite(F, OneLinerFullPath, 2500)) then
  begin 
    Writeln('Unable to open ' + OneLinerFullPath + ' for append.');
    halt;
  end;

  try
    idx:=0;
    //Writeln('FileSize:' + IntToStr(FileSize(F)) + ' Rec Size:' + IntToStr(SizeOf(OneLineRec)));
    Writeln('Num Records:' + IntToStr(FileSize(F) div SizeOf(OneLineRec)));
    repeat
      Read(F, Rec);
      Writeln('[' + IntToStr(idx) + '] ' + '(' + Rec.From + ') : ' + Rec.Text);
      Inc(idx);
    until EOF(F);
  finally
    Close(F);  
  end;
end;

procedure DeleteOneLiner;
var
  OneLinerFullPath: string;
  F: File Of OneLineRec;
  Rec: OneLineRec;
  idx: integer;
  yn: char;
begin
  OneLinerFullPath := GetAbsolutePath(OneLinerFileName);

  if NOT (OpenFileForReadWrite(F, OneLinerFullPath, 2500)) then
  begin 
    Writeln('Unable to open ' + OneLinerFullPath + ' for append.');
    halt;
  end;

  Write('Enter the record to delete: (0-' + IntToStr(FileSize(F) div SizeOf(OneLineRec)) + ') -> ');
  Readln(idx);

  try
    //Writeln('FileSize:' + IntToStr(FileSize(F)) + ' Rec Size:' + IntToStr(SizeOf(OneLineRec)));
    Writeln('Num Records:' + IntToStr(FileSize(F) div SizeOf(OneLineRec)));
    if (idx <= FileSize(F) div SizeOf(OneLineRec)) then 
    begin 
      Seek(F, SizeOf(OneLineRec)*idx);
      Read(F, Rec);
      Writeln('Delete this entry:');
      Writeln('[' + IntToStr(idx) + '] ' + '(' + Rec.From + ') : ' + Rec.Text);
      Write('(Y/N) -> ');
      Readln(yn);
      if (UpCase(yn)='Y') then 
        Writeln('Going to delete it');
    end;
  finally
    Close(F);  
  end;
end;

procedure Help;
begin
  Writeln;
  Writeln('Options');
  Writeln('-------');
  Writeln('L)ist One-Liners');
  Writeln('D)elete One-Liner');
  Writeln('Q)uit');
  Writeln;
end;

{Here the main program block starts}
var
  selection: char;
begin
  repeat
    Help;
    selection:=UpCase(ReadKey);
    case selection of 
    '?': Help;
    'L': ListOneLiners;
    'D': DeleteOneLiner;
    end; 
  until (selection='Q');
end.