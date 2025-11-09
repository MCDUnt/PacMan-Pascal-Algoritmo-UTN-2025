unit Mapa;
interface
uses Types, GameState;

procedure MenuPrincipal(var s: TGameState);
procedure PauseMenu(var s: TGameState);
procedure GameControl(var s: TGameState);

implementation
uses crt, IAFantasma;

const
  { Constantes locales para direcciones (mantienen el mismo orden que antes) }
  DIRX: array[1..4] of shortint = (0, 1, 0, -1);
  DIRY: array[1..4] of shortint = (1, 0, -1, 0);

procedure MenuPrincipal(var s: TGameState);
var keyChar: char; continuar: boolean;
begin
  repeat
      textbackground(white);
  clrscr;
  textbackground(black);
  textcolor(white);
  writeln('------- PACMAN -------');
  writeln('');
  writeln('Presione ENTER para iniciar, ESC para salir.');

  continuar := True;
  s.juegoActivo := False;
  while continuar do
  begin
    while not keypressed do;
    keyChar := readkey;
    case ord(keyChar) of
      13: // Enter
        begin
          s.juegoActivo := True;
          continuar := False;
        end;
      27: // ESC
        begin
          s.juegoActivo := False;
          continuar := False;
        end;
    end;
  end;
  until keyChar <> #27 //código ASCII de la tecla ESC

end;

procedure PauseMenu(var s: TGameState);
var menuOption: byte; keyChar: char; continuarMenu: boolean;
begin
  s.juegoActivo := True;
  window(7,1,25,10);
  textbackground(black);
  clrscr;
  textcolor(white);
  gotoxy(7,1); write('Paused');
  gotoxy(7,3); write('Back');
  gotoxy(7,5); write('Menu');
  gotoxy(7,7); write('Quit');
  menuOption := 1;
  gotoxy(5, menuOption*2+1); write('>');

  continuarMenu := True;
  while continuarMenu do
  begin
    while not keypressed do;
    keyChar := readkey;
    if ord(keyChar) = 0 then
    begin
      keyChar := readkey;
      case ord(keyChar) of
        72: // up
          if menuOption>1 then dec(menuOption) else menuOption := 4;
        80: // down
          if menuOption<4 then inc(menuOption) else menuOption := 1;
      end;
      clrscr;
      gotoxy(7,1); write('Paused');
      gotoxy(7,3); write('Back');
      gotoxy(7,5); write('Menu');
      gotoxy(7,7); write('Quit');
      gotoxy(5, menuOption*2+1); write('>');
    end
    else if ord(keyChar)=13 then
    begin
      case menuOption of
        1: // Back -> Reanuda el juego
          begin
            window(1,1,80,25);
            DibujarMapa(s);
            continuarMenu := False;
            // s.juegoActivo permanece true
          end;
        2: // Reanudar
          begin
            continuarMenu := False;
          end;
        3: // Menu
          begin
            window(1,1,80,25);
            s.juegoActivo := False;
            continuarMenu := False;
          end;
        4: // Quit
          begin
            s.juegoActivo := False;
            continuarMenu := False;
          end;
      end;
    end;
  end;
end;

procedure GameControl(var s: TGameState);
var keyChar: char;
    dirIndex: byte;
    ghostIdx, otherIdx: byte;
    nextX, nextY: Integer;
    gameRunning: boolean;
    columnas, filas: Integer;
    pasoModulo: Integer;
    collisionDetected: Boolean;
    prevX, prevY: Integer;
begin
  gameRunning := True;
  columnas := 16; filas := 10;

  while gameRunning and (s.cantidadBolitas > 0) do
  begin
    delay(10);
    inc(s.paso);

if keypressed then
  begin
    keyChar := readkey;
    if ord(keyChar)=0 then
    begin
      keyChar := readkey;

      // guardo la celda anterior para poder restaurarla sin el iniciador de puntos
      prevX := s.jugador.x;
      prevY := s.jugador.y;

      case ord(keyChar) of
        80: // down
          begin
            nextX := s.jugador.x; nextY := s.jugador.y+1;
            if (nextY<=filas) and s.mapa[nextY,nextX] then
              s.jugador.y := nextY;
          end;
        72: // up
          begin
            nextX := s.jugador.x; nextY := s.jugador.y-1;
            if (nextY>=1) and s.mapa[nextY,nextX] then
              s.jugador.y := nextY;
          end;
        75: // left
          begin
            nextX := s.jugador.x-1; nextY := s.jugador.y;
            if (nextX>=1) and s.mapa[nextY,nextX] then
              s.jugador.x := nextX
            else if (s.jugador.x=1) and ((s.jugador.y=2) or (s.jugador.y=6)) then
              s.jugador.x := columnas;
          end;
        77: // right
          begin
            nextX := s.jugador.x+1; nextY := s.jugador.y;
            if (nextX<=columnas) and s.mapa[nextY,nextX] then
              s.jugador.x := nextX
            else if (s.jugador.x=columnas) and ((s.jugador.y=2) or (s.jugador.y=6)) then
              s.jugador.x := 1;
          end;
      end;

      //Verificacion para cuando la posición cambió, restaurar la anterior
      if (prevX <> s.jugador.x) or (prevY <> s.jugador.y) then
      begin
        RestaurarCelda(s, prevX, prevY);
      end;

      if s.bolitas[s.jugador.x, s.jugador.y] then
      begin
        dec(s.cantidadBolitas);
        inc(s.puntaje);
        gotoxy(30,11);
        textcolor(black);
        write(s.puntaje * 10);
        s.bolitas[s.jugador.x, s.jugador.y] := false;
      end;

      //se dibuja el jugador en la nueva posición de spawn 
      gotoxy(s.jugador.x*2-1, s.jugador.y);
      textcolor(green);
      write('*');
      gotoxy(s.jugador.x*2-1, s.jugador.y);
    end
    else if ord(keyChar)=27 then
      begin
        PauseMenu(s);
        if not s.juegoActivo then
        begin
          gameRunning := False;
        end;
      end;
    end;

    pasoModulo := 0;
    if s.tiempo > 0 then pasoModulo := s.paso mod s.tiempo;
    if (s.tiempo>0) and (pasoModulo = 0) then
    begin
      ghostIdx := 1;
      while ghostIdx <= s.cantidadFantasmas do
      begin
        // restaurar lo que habia bajo el fantasma
        if (s.fantasmas[ghostIdx].x>=1) and (s.fantasmas[ghostIdx].x<=columnas) and (s.fantasmas[ghostIdx].y>=1) and (s.fantasmas[ghostIdx].y<=filas) then
        begin
          gotoxy(s.fantasmas[ghostIdx].x*2-1, s.fantasmas[ghostIdx].y);
          if not s.bolitas[s.fantasmas[ghostIdx].x, s.fantasmas[ghostIdx].y] then write(' ')
          else begin textcolor(yellow); write('.'); end;
        end;

        if (s.fantasmas[ghostIdx].x = s.vida.x) and (s.fantasmas[ghostIdx].y = s.vida.y) then
        begin
          gotoxy(s.fantasmas[ghostIdx].x*2-1, s.fantasmas[ghostIdx].y);
          textcolor(blue);
          write('*');
        end;

        dirIndex := IAFantasma.IA(s, s.fantasmas[ghostIdx], s.jugador, ghostIdx);

        nextX := s.fantasmas[ghostIdx].x + DIRX[dirIndex];
        nextY := s.fantasmas[ghostIdx].y + DIRY[dirIndex];

        if (nextX>=1) and (nextX<=columnas) and (nextY>=1) and (nextY<=filas) and s.mapa[nextY,nextX] then
        begin
          s.fantasmas[ghostIdx].x := nextX;
          s.fantasmas[ghostIdx].y := nextY;
        end
        else
        begin
          // pasillos laterales (teletransporte)
          if (s.fantasmas[ghostIdx].x = 1) and ((s.fantasmas[ghostIdx].y = 2) or (s.fantasmas[ghostIdx].y = 6)) then
            s.fantasmas[ghostIdx].x := columnas
          else if (s.fantasmas[ghostIdx].x = columnas) and ((s.fantasmas[ghostIdx].y = 2) or (s.fantasmas[ghostIdx].y = 6)) then
            s.fantasmas[ghostIdx].x := 1;
        end;

        // Evitar superposición entre fantasmas
        collisionDetected := False;
        otherIdx := 1;
        while (otherIdx <= s.cantidadFantasmas) and (not collisionDetected) do
        begin
          if otherIdx = ghostIdx then
          begin
            inc(otherIdx);
          end
          else
          begin
            if (s.fantasmas[otherIdx].x = s.fantasmas[ghostIdx].x) and (s.fantasmas[otherIdx].y = s.fantasmas[ghostIdx].y) then
            begin
              s.fantasmas[ghostIdx].x := s.fantasmas[ghostIdx].x - DIRX[dirIndex];
              s.fantasmas[ghostIdx].y := s.fantasmas[ghostIdx].y - DIRY[dirIndex];
              collisionDetected := True;
            end;
            inc(otherIdx);
          end;
        end;

        if (s.fantasmas[ghostIdx].x>=1) and (s.fantasmas[ghostIdx].x<=columnas) and (s.fantasmas[ghostIdx].y>=1) and (s.fantasmas[ghostIdx].y<=filas) then
        begin
          gotoxy(s.fantasmas[ghostIdx].x*2-1, s.fantasmas[ghostIdx].y);
          textcolor(red);
          write('*');
        end;

        inc(ghostIdx);
      end; // Del while de ghosts
      gotoxy(s.jugador.x*2-1, s.jugador.y);
    end;

    // Aparecen superpastillas
    if ((s.jugador.x = s.vida.x) and (s.jugador.y = s.vida.y)) or (s.paso = 2000) then
    begin
      if s.tiempo > 0 then
        s.paso := s.paso mod s.tiempo + 1
      else
        s.paso := 0;
      if (s.jugador.x = s.vida.x) and (s.jugador.y = s.vida.y) then
      begin
        gotoxy(s.vida.x*2-1, s.vida.y);
        textcolor(green);
        write('*');
        s.superpastilla := True;
      end
      else if (s.vida.x>0) and (s.vida.y>0) and (not s.bolitas[s.vida.x, s.vida.y]) then
        write(' ')
      else if (s.vida.x>0) and (s.vida.y>0) then
      begin
        textcolor(yellow);
        write('.');
      end;
      s.vida.x := 0;
      s.vida.y := 0;
      gotoxy(s.jugador.x*2-1, s.jugador.y);
    end;

    if s.paso = 1000 then
    begin
      if not s.superpastilla then
      begin
        RandomVida(s);
        gotoxy(s.vida.x*2-1, s.vida.y);
        textcolor(blue);
        write('*');
        gotoxy(s.jugador.x*2-1, s.jugador.y);
      end
      else
      begin
        if s.tiempo > 0 then s.paso := s.paso mod s.tiempo + 1
        else s.paso := 0;
        s.superpastilla := False;
      end;
    end;

    // Colision player-Fantasma
    ghostIdx := 1;
    while (ghostIdx <= s.cantidadFantasmas) and gameRunning do
    begin
      if (s.jugador.x = s.fantasmas[ghostIdx].x) and (s.jugador.y = s.fantasmas[ghostIdx].y) then
      begin
        if not s.superpastilla then
        begin
          clrscr;
          gotoxy(12,5);
          textcolor(black);
          write('GAME OVER');
          gotoxy(8,6);
          write('Your score is ', s.puntaje * 10);
          gotoxy(6,7);
          write('Press Enter to continue...');
          readln;
          gameRunning := False;
          s.juegoActivo := False;
        end
        else
        begin
          // reset de fantasma muerto a posiciones iniciales
          case ghostIdx of
            1: begin s.fantasmas[1].x := 2; s.fantasmas[1].y := 2; end;
            2: begin s.fantasmas[2].x := 9; s.fantasmas[2].y := 2; end;
            3: begin s.fantasmas[3].x := 15; s.fantasmas[3].y := 2; end;
            4: begin s.fantasmas[4].x := 15; s.fantasmas[4].y := 6; end;
            5: begin s.fantasmas[5].x := 2; s.fantasmas[5].y := 6; end;
          end;
          gotoxy(s.jugador.x*2-1, s.jugador.y);
          textcolor(green);
          write('*');
          gotoxy(s.fantasmas[ghostIdx].x*2-1, s.fantasmas[ghostIdx].y);
          textcolor(red);
          write('*');
          inc(s.puntaje,20);
          gotoxy(30,11);
          textcolor(black);
          write(s.puntaje * 10);
          gotoxy(s.jugador.x*2-1, s.jugador.y);
        end;
      end;
      inc(ghostIdx);
    end;

  end; // Del while de gameRunning y bolitas > 0

  if s.cantidadBolitas = 0 then
  begin
    clrscr;
    gotoxy(12,5);
    textcolor(black);
    write('YOU WIN!');
    gotoxy(8,6);
    write('Your score is ', s.puntaje * 10);
    gotoxy(6,7);
    write('Press Enter to continue...');
    readln;
    s.juegoActivo := False;
  end;
end;

end.

