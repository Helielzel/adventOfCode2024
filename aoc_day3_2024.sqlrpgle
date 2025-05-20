**free

ctl-opt dftactgrp(*no) actgrp(*caller) option(*srcstmt:*nodebugio);

dcl-s line varchar(10000);
dcl-s temp char(3);
dcl-s len_line int(5);
dcl-s i int(5) inz(1);
dcl-s j int(10);
dcl-s result int(20);

EXEC SQL SET OPTION COMMIT =*NONE;
exec sql DECLARE C1 CURSOR for
   SELECT line FROM TABLE(QSYS2.IFS_READ(
     PATH_NAME =>'/home/user/day3.txt'));   // replace user


exec sql open c1;
exec sql fetch c1 into :line;

dow sqlcode = 0;
  len_line = %len(line);
  j = 1;
  i = 1;
  for i to len_line;
    j = i;
    j = %scan('mul(':line:i);
    if j <> 0;
      if multip(line : j : result);
        i = j;
      ENDIF;
    ENDIF;
  ENDFOR;
  exec sql fetch c1 into :line;
ENDDO;
exec sql close c1;
dsply result;
*inlr = *on;
// ==========================

dcl-proc multip;
  dcl-pi *n ind;
    line varchar(10000);
    j int(10); // position après 'mul('
    result int(20);
  end-pi;

  dcl-s fact1 packed(3:0);
  dcl-s fact2 packed(3:0);
  dcl-s comma int(10);
  dcl-s close_parenthesis int(10);
  dcl-s temp varchar(10);

  //if not doOrDont(line : j);  ==> doesn't work.
    //return *off;
  //ENDIF;
  comma = %scan(',' : line : j);
  if comma = 0 or comma <= j;
    return *off;
  endif;
  j += 4;
  close_parenthesis = %scan(')' : line : comma);
  if close_parenthesis = 0 or close_parenthesis <= comma;
    return *off;
  endif;

  temp = %subst(line : j : comma - j);
  if %check('0123456789' : temp) = 0;
    fact1 = %int(temp);
  else;
    return *off;
  endif;
  fact1 = %int(temp);
  temp = '';
  temp = %subst(line : comma + 1 : close_parenthesis - comma - 1);

  if %check('0123456789' : temp) = 0;
    fact2 = %int(temp);
  else;
    return *off;
  endif;
  fact2 = %int(temp);
  temp = '';

  if %len(%char(fact1)) > 3 or %len(%char(fact2)) > 3;
    return *off;
  ENDIF;
  j = close_parenthesis;
  result += fact1 * fact2;
  return *on;
end-proc;

// ==========

//Part 2 (check for last do() or don't()
dcl-proc doOrDont;
  dcl-pi *n ind;
    line varchar(10000);
    j int(10); //le char sur lequel on est au moment du call (permet de couper la ligne)
  END-PI;
  dcl-s new_line varchar(10000);
  dcl-s pos int(10);
  dcl-s last_do int(3) inz(0);
  dcl-s last_dont int(3) inz(0);

  new_line = %subst(line : 1 : j);
  pos = 1;

  //look for don't()
  dow pos > 0;
    pos = %scan('don''t(' : new_line : pos);
    if pos > 0;
      last_dont = pos;
      pos += 1;
    endif;
  enddo;

  //look for do()
  pos = 1;
  dow pos > 0;
    pos = %scan('do(' : new_line : pos);
    if pos > 0;
      if pos < 3 or %subst(new_line : pos - 3 : 6) <> 'don''t(';
        last_do = pos;
      endif;
      pos += 1;
    endif;
  enddo;

  if last_do < last_dont;
    return *off;
  endif;
  return *on;

END-PROC;



 