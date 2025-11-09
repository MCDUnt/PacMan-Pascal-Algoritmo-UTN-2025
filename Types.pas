unit Types;
interface
uses crt;

const
  dx: array[1..4] of shortint = (0, 1, 0, -1); // Movementasao para Derecha y izquierda
  dy: array[1..4] of shortint = (1, 0, -1, 0);// a no ter movementasao para Arrivba y Abajo

type
  Posicion = record
    x, y: byte;
  end;

implementation
end.
