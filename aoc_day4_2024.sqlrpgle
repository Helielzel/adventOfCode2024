**free

ctl-opt dftactgrp(*no) actgrp(*caller) option(*srcstmt:*nodebugio);

dcl-s linetab char(150) dim(150);
dcl-s i int(10) inz(1);
dcl-s j int(10) inz(1);
dcl-s line char(150);
dcl-s result packed(10) inz(0);
dcl-s result2 packed(10) inz(0);
dcl-s nb_of_lines int(5) inz(0);

EXEC SQL SET OPTION COMMIT =*NONE;
exec sql DECLARE C1 CURSOR for
   SELECT line FROM TABLE(QSYS2.IFS_READ(
     PATH_NAME =>'/home/user/day4r.txt'));  // replace user

exec sql open c1;
exec sql fetch c1 into :line;

dow sqlcode = 0;
  linetab(i) = %trim(line);
  exec sql fetch c1 into :line;
  i += 1;
ENDDO;
exec sql close c1;

nb_of_lines = i;

for i = 1 to nb_of_lines;
  for j = 1 to nb_of_lines;
    if %subst(linetab(i): j : 1) = 'X';
      result += horizontal(linetab : i : j : nb_of_lines);
      result += vertical(linetab : i : j : nb_of_lines);
      result += diagonal(linetab : i : j : nb_of_lines);
    ENDIF;
    if %subst(linetab(i): j : 1) = 'A';
      result2 += part2(linetab : i : j : nb_of_lines);
    ENDIF;
  ENDFOR;
ENDFOR;

dsply result;
dsply result2;
*inlr = *on;

dcl-proc horizontal;
  dcl-pi *n packed(5);
    tb varchar(150) dim(150) const;
    i int(10) value;
    j int(10) value;
    nb_of_lines int(5) value;
  end-pi;

  dcl-s result packed(5) inz(0);

  if j + 3 <= nb_of_lines and %subst(tb(i): j : 4) = 'XMAS';
    result += 1;
  endif;

  // reversed XMAS
  if j - 3 >= 1 and
      %subst(tb(i): j : 1) = 'X' and
       %subst(tb(i): j - 1 : 1) = 'M' and
       %subst(tb(i): j - 2 : 1) = 'A' and
       %subst(tb(i): j - 3 : 1) = 'S';
    result += 1;
  endif;
  return result;
end-proc;

dcl-proc vertical;
  dcl-pi *n packed(5);
    tb varchar(150) dim(150) const;
    i int(10) value;
    j int(10) value;
    nb_of_lines int(5) value;
  end-pi;

  dcl-s result packed(5) inz(0);
  if i + 3 <= nb_of_lines and
    %subst(tb(i): j : 1) = 'X' and
    %subst(tb(i + 1): j : 1) = 'M' and
    %subst(tb(i + 2): j : 1) = 'A' and
    %subst(tb(i + 3): j : 1) = 'S';
    result += 1;
  endif;

  if i - 3 >= 1 and
    %subst(tb(i): j : 1) = 'X' and
    %subst(tb(i - 1): j : 1) = 'M' and
    %subst(tb(i - 2): j : 1) = 'A' and
    %subst(tb(i - 3): j : 1) = 'S';
    result += 1;
  endif;
  return result;
end-proc;

dcl-proc diagonal;
  dcl-pi *n packed(5);
    tb varchar(150) dim(150) const;
    i int(10) value;
    j int(10) value;
    nb_of_lines int(5) value;
  end-pi;

  dcl-s result packed(5) inz(0);

  //upper right
  if i + 3 <= nb_of_lines and j + 3 <= nb_of_lines and
    %subst(tb(i): j : 1) = 'X' and
    %subst(tb(i + 1): j + 1 : 1) = 'M' and
    %subst(tb(i + 2): j + 2 : 1) = 'A' and
    %subst(tb(i + 3): j + 3 : 1) = 'S';
    result += 1;
  endif;
  //upper left
  if i + 3 <= nb_of_lines and j - 3 >= 1 and
    %subst(tb(i): j : 1) = 'X' and
    %subst(tb(i + 1): j - 1 : 1) = 'M' and
    %subst(tb(i + 2): j - 2 : 1) = 'A' and
    %subst(tb(i + 3): j - 3 : 1) = 'S';
    result += 1;
  endif;
  //down right
  if i - 3 >= 1 and j + 3 <= nb_of_lines and
    %subst(tb(i): j : 1) = 'X' and
    %subst(tb(i - 1): j + 1 : 1) = 'M' and
    %subst(tb(i - 2): j + 2 : 1) = 'A' and
    %subst(tb(i - 3): j + 3 : 1) = 'S';
    result += 1;
  endif;
  //down left
  if i - 3 >= 1 and j - 3 >= 1 and
    %subst(tb(i): j : 1) = 'X' and
    %subst(tb(i - 1): j - 1 : 1) = 'M' and
    %subst(tb(i - 2): j - 2 : 1) = 'A' and
    %subst(tb(i - 3): j - 3 : 1) = 'S';
    result += 1;
  endif;
  return result;
end-proc;

dcl-proc part2;
  dcl-pi *n packed(5);
    tb varchar(150) dim(150) const;
    i int(10) value;
    j int(10) value;
    nb_of_lines int(5) value;
  end-pi;

  dcl-s result packed(5) inz(0);
  //créer un tableau, récupérer les char en diag (on sait déjà qu'au centre c'est un A)
  // mettre les chars en diag dans le tableau  : ex : M et S -> ça fait MAS -> c'est bon
  // ou le faire en dur comme un saligaud  (wink wink)
  //

  if i - 1 >= 1 and j + 1 <= nb_of_lines and
     i + 1 <= nb_of_lines and j - 1 >= 1 and
     %subst(linetab(i): j : 1) = 'A' and         //                    x
     %subst(linetab(i - 1): j - 1 : 1) = 'M' and //up left            M M   s s   s m    m s
     %subst(linetab(i - 1): j + 1: 1) = 'M'  and //up right            A     A     a      a
     %subst(linetab(i + 1): j - 1 : 1) = 'S' and //down left          S S   m m   s m    m s
     %subst(linetab(i + 1): j + 1: 1) = 'S';     //down right
     result += 1;
  ENDIF;

  if i - 1 >= 1 and j + 1 <= nb_of_lines and
     i + 1 <= nb_of_lines and j - 1 >= 1 and
     %subst(linetab(i): j : 1) = 'A' and         //                          x
     %subst(linetab(i - 1): j - 1 : 1) = 'S' and //up left            M M   s s   s m    m s
     %subst(linetab(i - 1): j + 1: 1) = 'S'  and //up right            A     A     a      a
     %subst(linetab(i + 1): j - 1 : 1) = 'M' and //down left          S S   m m   s m    m s
     %subst(linetab(i + 1): j + 1: 1) = 'M';     //down right
     result += 1;
  ENDIF;

  if i - 1 >= 1 and j + 1 <= nb_of_lines and
     i + 1 <= nb_of_lines and j - 1 >= 1 and
     %subst(linetab(i): j : 1) = 'A' and         //                                x
     %subst(linetab(i - 1): j - 1 : 1) = 'S' and //up left            M M   s s   s m    m s
     %subst(linetab(i - 1): j + 1: 1) = 'M'  and //up right            A     A     a      a
     %subst(linetab(i + 1): j - 1 : 1) = 'S' and //down left          S S   m m   s m    m s
     %subst(linetab(i + 1): j + 1: 1) = 'M';     //down right
     result += 1;
  ENDIF;

  if i - 1 >= 1 and j + 1 <= nb_of_lines and
     i + 1 <= nb_of_lines and j - 1 >= 1 and
     %subst(linetab(i): j : 1) = 'A' and         //                                       x
     %subst(linetab(i - 1): j - 1 : 1) = 'M' and //up left            M M   s s   s m    m s
     %subst(linetab(i - 1): j + 1: 1) = 'S'  and //up right            A     A     a      a
     %subst(linetab(i + 1): j - 1 : 1) = 'M' and //down left          S S   m m   s m    m s
     %subst(linetab(i + 1): j + 1: 1) = 'S';     //down right
     result += 1;
  ENDIF;
  return result;

END-PROC;