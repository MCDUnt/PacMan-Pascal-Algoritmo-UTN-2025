unit GameState;
interface
uses Types, crt;

type
  TGameState = record
    mapa: array[1..10,1..16] of boolean;   // [fila=y, columna=x]
    bolitas: array[1..16,1..10] of boolean; // [x,y]
    camino: array[1..16,1..10] of byte;     
    fantasmas: array[1..5] of Posicion;
    direccionFantasma: array[1..5] of byte;
    jugador, vida: Posicion;
    puntaje, paso: word;
    cantidadBolitas, cantidadFantasmas, tiempo: byte;
    superpastilla, juegoActivo: boolean;
  end;

procedure InicializarJuego(var s: TGameState);
procedure CrearMapa(var s: TGameState);
procedure DibujarMapa(const s: TGameState);
procedure RandomVida(var s: TGameState);
procedure RestaurarCelda(const s: TGameState; cx, cy: Integer);

implementation


function PosValida(x, y: Integer): Boolean;
begin
  PosValida := (x >= 1) and (x <= 16) and (y >= 1) and (y <= 10);
end;

procedure InicializarJuego(var s: TGameState);
begin
  s.puntaje := 0;
  s.superpastilla := false;
  fillchar(s.bolitas, sizeof(s.bolitas), true);
  s.cantidadBolitas := 80;
  // posiciones iniciales de fantasmas
  s.fantasmas[1].x := 2;  s.fantasmas[1].y := 2;
  s.fantasmas[2].x := 9;  s.fantasmas[2].y := 2;
  s.fantasmas[3].x := 15; s.fantasmas[3].y := 2;
  s.fantasmas[4].x := 15; s.fantasmas[4].y := 6;
  s.fantasmas[5].x := 2;  s.fantasmas[5].y := 7;
  s.fantasmas[5].x := 2;  s.fantasmas[5].y := 9;
  s.fantasmas[5].x := 2;  s.fantasmas[5].y := 6;
  s.fantasmas[5].x := 2;  s.fantasmas[5].y := 1;
  s.jugador.x := 8; s.jugador.y := 9;
  if PosValida(s.jugador.x, s.jugador.y) then s.bolitas[s.jugador.x, s.jugador.y] := false;
  fillchar(s.direccionFantasma, sizeof(s.direccionFantasma), 0);
  s.vida.x := 0; s.vida.y := 0;
  s.paso := 0;
  s.juegoActivo := true;
  //s.cantidadFantasmas y s.tiempo se inicializan en el programa principal.
end;

procedure RestaurarCelda(const s: TGameState; cx, cy: Integer);
begin
  if (cx < 1) or (cx > 16) or (cy < 1) or (cy > 10) then
  begin

  end
  else
  begin
    gotoxy(cx*2-1, cy);
    if not s.mapa[cy, cx] then
    begin
      textbackground(black);
      write('  ');
    end
    else
    begin
      textbackground(white);
      if s.bolitas[cx, cy] then write('. ') else write('  ');
    end;
  end;
end;

procedure CrearMapa(var s: TGameState);
var x,y: byte;
begin

  for y := 1 to 10 do
    for x := 1 to 16 do
    begin
      s.mapa[y,x] := true;
      s.bolitas[x,y] := true;
    end;

  // bordes (paredes)
  for x := 1 to 16 do
  begin
    s.mapa[1, x] := false;
    s.mapa[10, x] := false;
  end;
  for y := 2 to 9 do
  begin
    s.mapa[y, 1] := false;
    s.mapa[y, 16] := false;
  end;

  // paredes internas
  s.mapa[2,1] := true;  s.mapa[6,1] := true;  s.mapa[2,16] := true;
  s.mapa[6,16] := true;  s.mapa[2,3] := false;  s.mapa[2,7] := false;
  s.mapa[2,10] := false;  s.mapa[2,14] := false;  s.mapa[3,3] := false;
  s.mapa[3,5] := false;  s.mapa[3,7] := false;  s.mapa[3,8] := false;
  s.mapa[3,10] := false;  s.mapa[3,12] := false;  s.mapa[3,14] := false;
  s.mapa[5,3] := false;   s.mapa[5,4] := false;   s.mapa[5,6] := false;
  s.mapa[5,8] := false;  s.mapa[5,9] := false;  s.mapa[5,11] := false;
  s.mapa[5,12] := false;  s.mapa[5,14] := false;  s.mapa[6,8] := false;
  s.mapa[6,9] := false;   s.mapa[7,3] := false;   s.mapa[7,4] := false;
  s.mapa[7,6] := false;   s.mapa[7,11] := false;   s.mapa[7,13] := false;
  s.mapa[7,14] := false;   s.mapa[8,3] := false;   s.mapa[8,4] := false;
  s.mapa[8,8] := false;    s.mapa[8,9] := false;   s.mapa[8,13] := false;
  s.mapa[8,14] := false;   s.mapa[9,6] := false;   s.mapa[9,11] := false;

  // For para que no aparezcan bolitas dentro de las paredes
  for x := 1 to 16 do
    for y := 1 to 10 do
      if not s.mapa[y,x] then s.bolitas[x,y] := false;
end;

procedure DibujarMapa(const s: TGameState);
var x,y,i: byte;
begin
  textbackground(white);
  textcolor(yellow);
  clrscr;
  for y := 1 to 10 do
  begin
    for x := 1 to 16 do
    begin
      if not s.mapa[y,x] then
      begin
        textbackground(black);
        write('  ');
      end
      else
      begin
        textbackground(white);
        if s.bolitas[x,y] then write('. ')
        else write('  ');
      end;
    end;
    writeln;
  end;

  // fantasmas
  textbackground(white);
  textcolor(red);
  for i := 1 to s.cantidadFantasmas do
  begin
    if PosValida(s.fantasmas[i].x, s.fantasmas[i].y) then
    begin
      gotoxy(s.fantasmas[i].x*2-1, s.fantasmas[i].y);
      write('*');
    end;
  end;

  //Superpastilla 
  if (s.vida.x>0) and (s.vida.y>0) then
  begin
    gotoxy(s.vida.x*2-1, s.vida.y);
    textcolor(blue);
    write('*');
  end;

  // score que va de 10 en 10 hasta 800 si no se mato a ningun fantasma
  gotoxy(24,11);
  textcolor(black);
  write('Score: ', s.puntaje * 10);

  // jugador
  if PosValida(s.jugador.x, s.jugador.y) then
  begin
    gotoxy(s.jugador.x*2-1, s.jugador.y);
    textcolor(green);
    write('*');
    gotoxy(s.jugador.x*2-1, s.jugador.y);
  end;
end;

procedure RandomVida(var s: TGameState);
var ok: boolean; tx, ty: Integer;
begin
  ok := false;
  while not ok do
  begin
    tx := random(16) + 1;
    ty := random(10) + 1;
    if PosValida(tx, ty) and s.mapa[ty, tx] and s.bolitas[tx, ty] then
    begin
      s.vida.x := tx;
      s.vida.y := ty;
      ok := true;
    end;
  end;
end;

end.
