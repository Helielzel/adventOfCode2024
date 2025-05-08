**free
ctl-opt dftactgrp(*no) actgrp(*caller) option(*srcstmt:*nodebugio);

dcl-s line char(25);
dcl-s splitted_line varchar(10) dim(20);
dcl-s i int(10) inz(1);
dcl-s j int(10) inz(1);
dcl-s tabsize int(10);
dcl-s temp int(10) inz(0);
dcl-s result int(10) inz(0);
dcl-s nope int(3) inz(0);
dcl-s isAscending ind inz(*off);
dcl-s isDescending ind inz(*off);

EXEC SQL SET OPTION COMMIT =*NONE;
exec sql DECLARE C1 CURSOR for
   SELECT line FROM TABLE(QSYS2.IFS_READ(
     PATH_NAME =>'/home/[USER]/day2h.txt'));

exec sql open c1;
exec sql fetch c1 into :line;

dow sqlcod = 0;
  tabsize = 0;
  //clear splitted_lines before everything
  clear splitted_line;
  splitted_line = %split(line: ' ');
  for i = 1 to %elem(splitted_line);
    if splitted_line(i) <> *blanks;
      tabsize +=1;
    ENDIF;
  ENDFOR;
  //check if the values are in descending order
  isDescending = *on;
  for i = 1 to tabsize - 1;
    if %int(splitted_line(i)) <= %int(splitted_line(i + 1));
      isDescending = *off;
      leave;
    endif;
  endfor;
  //check if the values are in descending order
  isAscending = *on;
  for i = 1 to tabsize - 1;
    if %int(splitted_line(i)) >= %int(splitted_line(i + 1));
      isAscending = *off;
      leave;
    endif;
  endfor;

  if not isAscending and not isDescending;
    nope = 1;
    //if nope = 1, then the line is bad (still we keep going tho, i have to fix that)
  endif;

  for i = 1 to tabsize - 1;
    temp = %Int(splitted_line(i)) - %Int(splitted_line(i + 1));
    if temp < 0;
      temp = temp * (-1);
    //just so that temp is always positive for an easier if condition
    ENDIF;
    if temp < 1 or temp > 3;
      nope = 1;
      leave;
    ENDIF;
    temp = 0;
  ENDFOR;
  if nope = 0;
    result += 1;
  ENDIF;
  nope = 0;
  exec sql fetch c1 into :line;
enddo;

exec sql close c1;
dsply result;
*inlr = *on; 
