**free

ctl-opt dftactgrp(*no) actgrp(*caller);

dcl-pr OpenFile pointer extproc('_C_IFS_fopen');
  *n pointer value;  //File name
  *n pointer value;  //File mode
end-pr;

dcl-pr ReadFile pointer extproc('_C_IFS_fgets');
  *n pointer value;  //Retrieved data
  *n int(10) value;  //Data size
  *n pointer value;  //Misc pointer
end-pr;

dcl-pr CloseFile extproc('_C_IFS_fclose');
  *n pointer value;  //Misc pointer
end-pr;
// ** fopen, fgets, fclose are C functions that are used here to read the .txt file from the ifs,
// ** because i was too dumb to remember that sqlrpgle existed. Worth it tho, it looks cool.
dcl-s PathFile char(50);
dcl-s OpenMode char(5);
dcl-s FilePtr pointer inz;
dcl-s RtvData char(32767);

dcl-s i int(10) inz(1);
dcl-s j int(10) inz(1);
dcl-s left_table int(10) dim(1200);
dcl-s right_table int(10) dim(1200);
dcl-s diff int(10) inz(0);
dcl-s result int(20) inz(0);
dcl-s occurences int(10) inz(0);

PathFile = '/home/[USER]/day1.txt' + x'00';
OpenMode = 'r' + x'00';
FilePtr = OpenFile(%addr(PathFile):%addr(OpenMode));

if (FilePtr = *null);
  dsply ('fopen unable to open file');
  return;
endif;

dow  (ReadFile(%addr(RtvData):32767:FilePtr) <> *null);
  RtvData = %xlate(x'00':' ':RtvData);  //End of record null
  RtvData = %xlate(x'25':' ':RtvData);  //Line feed (LF)
  RtvData = %xlate(x'0D':' ':RtvData);  //Carriage return (CR)

  left_table(i) = %int(%subst(%subst(RtvData:1:52):1:6));
  right_table(i) = %int(%subst(RtvData:9:12));
  i += 1;
  RtvData = ' ';
enddo;

sorta left_table;
sorta right_table;

//PART 1
for i = 1 to %elem(left_table);
  diff = left_table(i) - right_table(i);
  if diff < 0;
    diff = diff * (-1);
  ENDIF;
  result += diff;

ENDFOR;

dsply result;
result = 0;

// PART 2

for i = 1 to %elem(left_table);
  for j = 1 to %elem(right_table);
    if left_table(i) = right_table(j);
      occurences += 1;
    ENDIF;
  ENDFOR;
  result = result + occurences * left_table(i);
  occurences = 0;
ENDFOR;
dsply result;

CloseFile(%addr(PathFile));
return;

*inlr = *on;
