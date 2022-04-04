Program MysticOLUtil;
{$mode objfpc}{$h+}

Uses Generics.Collections, StrUtils, SysUtils, Crt, FileUtils;

Const 
  OneLinerFileName = 'oneliner.dat';

Type 
(* ONELINERS.DAT found in the data directory.  This file contains all the
   one-liner data.  It can be any number of records in size. *)

  OneLineRec = Record
    Text : String[79];
    From : String[30];
  End;

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
  idxRecToDelete, idxRecsToMove, idxCurrRec: integer;
  yn: char;
  onelinerRecs: specialize TList<OneLineRec>;
begin
  OneLinerFullPath := GetAbsolutePath(OneLinerFileName);

  if NOT (OpenFileForReadWrite(F, OneLinerFullPath, 2500)) then
  begin 
    Writeln('Unable to open ' + OneLinerFullPath + ' for append.');
    halt;
  end;

  Write('Enter the record to delete: (0-' + IntToStr((FileSize(F) div SizeOf(OneLineRec))-1) + ') -> ');
  Readln(idxRecToDelete);

  try

    onelinerRecs:=specialize TList<OneLineRec>.Create();
    //Writeln('FileSize:' + IntToStr(FileSize(F)) + ' Rec Size:' + IntToStr(SizeOf(OneLineRec)));
    Writeln('Num Records:' + IntToStr(FileSize(F) div SizeOf(OneLineRec)));
    if (idxRecToDelete <= FileSize(F) div SizeOf(OneLineRec)) then 
    begin 
      Seek(F, SizeOf(OneLineRec)*idxRecToDelete);
      Read(F, Rec);
      Writeln('Delete this entry:');
      Writeln('[' + IntToStr(idxRecToDelete) + '] ' + '(' + Rec.From + ') : ' + Rec.Text);
      Write('(Y/N) -> ');
      Readln(yn);
      if (UpCase(yn)='Y') then 
      begin
        (* Read the remaining records *)
        Seek(F, 0);
        idxCurrRec := 0;
        repeat
          Read(F, Rec);
          if (idxCurrRec <> idxRecToDelete) then
            onelinerRecs.Add(Rec);
          Inc(idxCurrRec);
        until EOF(F);
        Close(F);

        (* Rewrite the file with the deleted record removed *)
        if NOT (OpenFileForOverwrite(F, OneLinerFullPath, 2500)) then
        begin 
          Writeln('Unable to open ' + OneLinerFullPath + ' for append.');
          halt;
        end;
 
        (* Move all of the files *)
        for idxRecsToMove := 0 to onelinerRecs.Count-1 do 
          Write(F, onelinerRecs[idxRecsToMove]);
      end;
    end;
  finally
    Close(F);  
    FreeAndNil(onelinerRecs);
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