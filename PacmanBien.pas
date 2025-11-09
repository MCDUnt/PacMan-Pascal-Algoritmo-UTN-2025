program PacmanBien;
uses
  crt, Types, GameState, IAFantasma, Mapa;

var
  s: TGameState;
begin
  randomize;      // Se hace una sola vez para que spawnee todo en su lugar
  cursoroff;
  // configuración inicial
  s.tiempo := 100;          // tiempo entre paso y paso de los fantasmas
  s.cantidadFantasmas := 10; 
  MenuPrincipal(s);
  while true do
  begin
    InicializarJuego(s);
    CrearMapa(s);
    DibujarMapa(s);
    GameControl(s);
    MenuPrincipal(s);
  end;
end.

