Program MysticOLUtil;
{$mode objfpc}{$h+}

Uses Generics.Collections, StrUtils, SysUtils, Crt, FileUtils;

Const 
  OneLinerFileName = 'oneliner.dat';
  GreenText = #27 + '[1;[32m';
  MagentaText = #27 + '[1;[35m';
  WhiteText = #27 + '[1;[37m';
  CyanText = #27 + '[1;[36m';

Type 
(* ONELINERS.DAT found in the data directory.  This file contains all the
   one-liner data.  It can be any number of records in size. *)

  OneLineRec = Record
    Text : String[79];
    From : String[30];
  End;

procedure PhenomTitle;
begin
Writeln('                   $$sss  s$"                              5m  ');
Writeln('                   $$  $$ $$                                   ');
Writeln(CyanText + '                   $$"""" $$""$e $"//  $$""s  $$""$$ $$sssss   ' + WhiteText);
Writeln(GreenText + '                   $$     $$  $$ $SSSS $$  $$ $$$$$$ $$ $$ $$  ' + WhiteText);
Writeln; 
Writeln(MagentaText + '                         --- P R O D U C T I O N S ---         ' + WhiteText);
Writeln(MagentaText + '						           EST : 2018                               ' + WhiteText); 
Writeln;
Writeln;
Writeln('                   ' + GreenText + 'Mystic One-Liner Utility                    ');
Writeln('                   By: ' + GreenText + 'Hayes Zyxel (Baud Games)' + WhiteText);
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
  Writeln(GreenText + 'Options' + WhiteText);
  Writeln(GreenText + '-------' + WhiteText);
  Writeln(GreenText + 'L' + WhiteText + ')ist One-Liners');
  Writeln(GreenText + 'D' + WhiteText + ')elete One-Liner');
  Writeln(GreenText + 'Q' + WhiteText + ')uit');
  Writeln;
end;

{Here the main program block starts}
var
  selection: char;
begin
  ClrScr;
  PhenomTitle;
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