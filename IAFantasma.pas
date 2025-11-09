unit IAFantasma;
interface
uses
  Types, GameState;

function IA(var s: TGameState; nowPos, wantPos: Posicion; fantasmaIndice: byte): byte;

implementation
uses
  crt;

const
  DIRX: array[1..4] of shortint = (0, 1, 0, -1);
  DIRY: array[1..4] of shortint = (1, 0, -1, 0);

function IA(var s: TGameState; nowPos, wantPos: Posicion; fantasmaIndice: byte): byte;
var
  qx, qy: array[1..160] of byte;
  head, tail: Integer;
  nx, ny: Integer;
  dirIdx, attempt: Integer;
  foundPath: Boolean;
  curx, cury: byte;
  i: Integer;
  validDir: Boolean;
  tryOffset: Integer;
begin
  IA := 1;
  
  if not s.superpastilla then
  begin
    fillchar(s.camino, sizeof(s.camino), 0);
    if (nowPos.x >= 1) and (nowPos.x <= 16) and (nowPos.y >= 1) and (nowPos.y <= 10) then
    begin
      s.camino[nowPos.x, nowPos.y] := 1;
      head := 1;
      tail := 1;
      qx[tail] := nowPos.x;
      qy[tail] := nowPos.y;
      foundPath := False;

      while (head <= tail) and (not foundPath) do
      begin
        dirIdx := 1;
        while dirIdx <= 4 do
        begin
          nx := qx[head] + DIRX[dirIdx];
          ny := qy[head] + DIRY[dirIdx];
          if (nx >= 1) and (nx <= 16) and (ny >= 1) and (ny <= 10) then
          begin
            if s.mapa[ny, nx] and (s.camino[nx, ny] = 0) then
            begin
              s.camino[nx, ny] := s.camino[qx[head], qy[head]] + 1;
              inc(tail);
              if tail <= 160 then
              begin
                qx[tail] := nx;
                qy[tail] := ny;
              end;
              if (nx = wantPos.x) and (ny = wantPos.y) then
              begin
                foundPath := True;
                dirIdx := 5;
              end;
            end;
          end;
          inc(dirIdx);
        end;
        inc(head);
      end;

      if not foundPath then
      begin
        IA := 1; 
      end
      else
      begin
        curx := wantPos.x;
        cury := wantPos.y;
        while (s.camino[curx, cury] > 2) do
        begin
          dirIdx := 1;
          while dirIdx <= 4 do
          begin
            nx := curx + DIRX[dirIdx];
            ny := cury + DIRY[dirIdx];
            if (nx >= 1) and (nx <= 16) and (ny >= 1) and (ny <= 10) then
            begin
              if s.camino[nx, ny] = (s.camino[curx, cury] - 1) then
              begin
                curx := nx;
                cury := ny;
                dirIdx := 5; 
              end
              else inc(dirIdx);
            end
            else inc(dirIdx);
          end;
        end;
        i := 1;
        validDir := False;
        while i <= 4 do
        begin
          if (nowPos.x + DIRX[i] = curx) and (nowPos.y + DIRY[i] = cury) then
          begin
            IA := i;
            validDir := True;
            i := 5; 
          end
          else inc(i);
        end;
        if not validDir then IA := 1;
      end;
    end;
  end
  else
  begin
 //Superpastillas Funsionamiento
    validDir := False;
    if (s.direccionFantasma[fantasmaIndice] <> 0) then
    begin
      dirIdx := s.direccionFantasma[fantasmaIndice];
      nx := nowPos.x + DIRX[dirIdx];
      ny := nowPos.y + DIRY[dirIdx];
      if (nx >= 1) and (nx <= 16) and (ny >= 1) and (ny <= 10) and s.mapa[ny, nx] then
        validDir := True;
    end;

    if validDir then
      IA := s.direccionFantasma[fantasmaIndice]
    else
    begin
      tryOffset := (random(4) + 1);
      attempt := 0;
      dirIdx := tryOffset;
      validDir := False;
      while (attempt < 4) and (not validDir) do
      begin
        nx := nowPos.x + DIRX[dirIdx];
        ny := nowPos.y + DIRY[dirIdx];
        if (nx >= 1) and (nx <= 16) and (ny >= 1) and (ny <= 10) and s.mapa[ny, nx] then
        begin
          s.direccionFantasma[fantasmaIndice] := dirIdx;
          IA := dirIdx;
          validDir := True;
        end
        else
        begin
          inc(dirIdx);
          if dirIdx > 4 then dirIdx := 1;
        end;
        inc(attempt);
      end;

      if not validDir then
      begin
        dirIdx := 1;
        while (dirIdx <= 4) and (not validDir) do
        begin
          nx := nowPos.x + DIRX[dirIdx];
          ny := nowPos.y + DIRY[dirIdx];
          if (nx >= 1) and (nx <= 16) and (ny >= 1) and (ny <= 10) and s.mapa[ny, nx] then
          begin
            s.direccionFantasma[fantasmaIndice] := dirIdx;
            IA := dirIdx;
            validDir := True;
          end;
          inc(dirIdx);
        end;
        if not validDir then IA := 1;
      end;
    end;
  end;
end;

end.
