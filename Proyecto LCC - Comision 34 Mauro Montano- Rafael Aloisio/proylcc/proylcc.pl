:- module(proylcc,
	[  
		emptyBoard/1,
		goMove/4,
		score/3
	]).


emptyBoard([
		 ["-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"],
		 ["-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"],
		 ["-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"],
		 ["-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"],
		 ["-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"],
		 ["-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"],
		 ["-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"],
		 ["-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"],
		 ["-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"],
		 ["-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"],
		 ["-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"],
		 ["-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"],
		 ["-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"],
		 ["-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"],
		 ["-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"],
		 ["-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"],
		 ["-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"],
		 ["-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"],
		 ["-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"]
		 ]).

% goMove(+Board, +Player, +Pos, -RBoard)
% RBoard es la configuración resultante de reflejar la movida del jugador Player
% en la posición Pos a partir de la configuración Board.
% X es la fila e Y es la columna

goMove(Board, Color, [X,Y], RRBoard):-
	replaceBoard("-", Board, X, Y, Color, RBoard),
    capturadas(RBoard, X, Y, Color, RRBoard),
    not(haySuicidio(RRBoard,X,Y,Color)).

% replaceBoard(+Actual ,+Board, +X, +Y, +Color, -RBoard)
replaceBoard(Actual ,Board, X, Y, Color, RBoard):-
	replace(Fila, X, NFila, Board, RBoard),
    replace(Actual, Y, Color, Fila, NFila).

% replace(?X, +XIndex, +Y, +Xs, -XsY)
replace(X, 0, Y, [X|Xs], [Y|Xs]).
replace(X, XIndex, Y, [Xi|Xs], [Xi|XsY]):-
    XIndex > 0,
    XIndexS is XIndex - 1,
    replace(X, XIndexS, Y, Xs, XsY).
	
% capturadas(+Board, +X, +Y, +Color, -RBoard)
capturadas(Board, X, Y, Color, RBoard):-
	X1 is X-1,
	X2 is X+1,
	Y1 is Y-1,
	Y2 is Y+1,
	colorOpuesto(Color,ColorOp),
	rodeado(Board, X1, Y, Color, ColorOp, Board1),
	rodeado(Board1, X, Y1, Color, ColorOp, Board2),	
	rodeado(Board2, X2, Y, Color, ColorOp, Board3),
	rodeado(Board3, X, Y2, Color, ColorOp, RBoard).

% rodeado(+Board, +X, +Y, +ColorAtrap, +ColorAdy, -RBoard)
% si no esta Atrapada devuelvo el mismo tablero sino limpio las atrapadas, "v" son las visitadas
rodeado(Board, X, Y, ColorAtrap, ColorAdy, Board):- not(estaAtrapada(Board, X, Y, ColorAtrap, ColorAdy, "v", _RBoard)).
rodeado(Board, X, Y, ColorAtrap, ColorAdy, RRBoard):- estaAtrapada(Board, X, Y, ColorAtrap, ColorAdy, "v", RBoard), estaAtrapada(RBoard, X, Y, ColorAtrap, "v", "-", RRBoard).
	
% haySuicidio (+Board, +X, +Y, Color)
haySuicidio(Board, X, Y, Color):-
	colorOpuesto(Color,ColorOp),
	estaAtrapada(Board, X, Y, ColorOp,Color,"v", RBoard),
	Board \== RBoard.

% estaAtrapada(Board, X, Y, ColorAdy, ColorAtrap, ColorRemp, RBoard)
% El color ady es el color que rodea al color ColorAtrap, y el ColorRemp es el color de reemplazo
% 1) Caso donde la posicion no es valida. 
% 2) Caso donde la ficha es del color opuesto.
% 3) Caso donde la ficha ya esta visitada.
% 4) Caso general donde visito la primera y luego las adyacentes a esta

estaAtrapada(Board, X, Y, _ColorAdy, _ColorAtrap, _ColorRemp, Board):- posNoValida(X,Y),!.
estaAtrapada(Board, X, Y, ColorAdy, _ColorAtrap, _ColorRemp, Board):- replaceBoard(ColorAdy, Board, X, Y, ColorAdy, Board),!.
estaAtrapada(Board, X, Y, _ColorAdy, _ColorAtrap, ColorRemp, Board):- replaceBoard(ColorRemp, Board, X, Y, ColorRemp, Board),!.
estaAtrapada(Board, X, Y, ColorAdy, ColorAtrap, ColorRemp, RBoard):- !, replaceBoard(ColorAtrap, Board, X, Y, ColorRemp, Board0), 
	X1 is X-1,
	X2 is X+1,
	Y1 is Y-1,
	Y2 is Y+1,
	estaAtrapada(Board0, X1, Y,  ColorAdy, ColorAtrap, ColorRemp, Board1),
	estaAtrapada(Board1, X, Y1,  ColorAdy, ColorAtrap, ColorRemp, Board2),	
	estaAtrapada(Board2, X2, Y,  ColorAdy, ColorAtrap, ColorRemp, Board3),
	estaAtrapada(Board3, X, Y2,  ColorAdy, ColorAtrap, ColorRemp, RBoard).
	
% posNoValida(+X,+Y)
posNoValida(X,_Y):- X<1.
posNoValida(X,_Y):- X>19.
posNoValida(_X,Y):- Y<1.
posNoValida(_X,Y):- Y>19.
	
% colorOpuesto(+Color, -ColorOp)
colorOpuesto("b","w").
colorOpuesto("w","b").

% score(+Board, -PuntajeW, -PuntajeB)
% cuento la cantidad de fichas negras y blancas
score(Board, PuntajeW, PuntajeB):-
	llenarY(Board, 18, 18, "w", RBoardB),
	countC(RBoardB, "w", PuntajeW),
	llenarY(Board, 18, 18, "b", RBoardN),
	countC(RBoardN, "b", PuntajeB).

% countC(+Board, +Color, -Puntaje)
% contar en columnas
countC([], _Color, 0).
countC([X|Xs], Color, Resu):-
	countR(X, Color, Rta),
	countC(Xs, Color, Rtab),
	Resu is Rta + Rtab.
	
% countC(+Board, +Color, -Puntaje)	
% contar en filas
countR([], _Color, 0).
countR([Color|Ls], Color, Resu):-
	countR(Ls, Color, Rta),
	Resu is Rta +1.
countR([X|Ls], Color, Resu):-
	X \= Color,
	countR(Ls, Color, Resu).	

% llenarY(+Board, +X, +Y, +Color, -RBoard)	
% rellenar las columnas
llenarY(Board, _X, -1, _Color, Board).
llenarY(Board, X, Y, Color, RBoard):-
	YN is Y - 1,
	llenarX(Board, X, Y, Color, RRBoard),
	llenarY(RRBoard, X, YN, Color, RBoard).
	
% llenarX(+Board, +X, +Y, +Color, -RBoard)	
% rellenar las filas
llenarX(Board, -1, _Y, _Color, Board).
llenarX(Board, X, Y, Color, RBoard):-
	XN is X - 1,
	llenarAux(Board, X, Y, Color, RRBoard),
	llenarX(RRBoard, XN, Y, Color, RBoard).
	
% llenarAux(+Board, +X, +Y, +Color, -RBoard)
% llenar los espacios vacios de fichas atrapdas con fichas de ese mismo color 
llenarAux(Board, X, Y, Color, Board):-
	not(estaAtrapada(Board, X, Y, Color, "-", Color, _RBoard)).
llenarAux(Board, X, Y, Color, RBoard):-
	estaAtrapada(Board, X, Y, Color, "-", Color, RBoard).
	





