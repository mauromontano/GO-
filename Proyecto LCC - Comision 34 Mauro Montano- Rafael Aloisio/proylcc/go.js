// Reference to object provided by pengines.js library which interfaces with Pengines server (Prolog-engine)
// by making query requests and receiving answers.
var pengine;
// Bidimensional array representing board configuration.
var gridData;
// Bidimensional array with board cell elements (HTML elements).
var cellElems;
// States if it's black player turn.
var turnBlack = false;
var bodyElem;
var latestStone;
var passTurn = false;
//variable bandera para ver si ya pasaron una vez
var flag = "";



/**
* Initialization function. Requests to server, through pengines.js library, 
* the creation of a Pengine instance, which will run Prolog code server-side.
*/

function init() {
    document.getElementById("passBtn").addEventListener('click', () => pasarTurno());
    bodyElem = document.getElementsByTagName('body')[0];
    createBoard();
    // Creación de un conector (interface) para comunicarse con el servidor de Prolog.
    pengine = new Pengine({
        server: "http://localhost:3030/pengine",
        application: "proylcc",
        oncreate: handleCreate,
        onsuccess: handleSuccess,
        onfailure: handleFailure,
        destroy: false
    });
}

/**
 * Create grid cells elements
 */

function createBoard() {
    const dimension = 19;
    const boardCellsElem = document.getElementById("boardCells");
    for (let row = 0; row < dimension - 1; row++) {
        for (let col = 0; col < dimension - 1; col++) {
            var cellElem = document.createElement("div");
            cellElem.className = "boardCell";
            boardCellsElem.appendChild(cellElem);
        }
    }
    const gridCellsElem = document.getElementById("gridCells");
    cellElems = [];
    for (let row = 0; row < dimension; row++) {
        cellElems[row] = [];
        for (let col = 0; col < dimension; col++) {
            var cellElem = document.createElement("div");
            cellElem.className = "gridCell";
            cellElem.addEventListener('click', () => handleClick(row, col));
            gridCellsElem.appendChild(cellElem);
            cellElems[row][col] = cellElem;
        }
    }
}

/**
 * Callback for Pengine server creation
 */

function handleCreate() {
    flag = "ficha"
    pengine.ask('emptyBoard(Board)');
	turnBlack = false;
}

/**
 * Callback for successful response received from Pengines server.
 */

function handleSuccess(response) {
   
   if(flag === "ficha"){
        gridData = response.data[0].Board;
        for (let row = 0; row < gridData.length; row++){
            for (let col = 0; col < gridData[row].length; col++) {
                cellElems[row][col].className = "gridCell" +
                    (gridData[row][col] === "w" ? " stoneWhite" : gridData[row][col] === "b" ? " stoneBlack" : "") + (latestStone && row === latestStone[0] && col === latestStone[1] ? " latest" : "");
            }
        }
        switchTurn();
    }
    if(flag === "gameover"){
        //aca actuo despues de haber consultado para ver al ganador
        var PuntajeW = response.data[0].PuntajeW;
        var PuntajeB = response.data[0].PuntajeB;
      
		if(PuntajeB > PuntajeW){
        alert("GANO JUGADOR NEGRO \nPuntaje Negro= "+PuntajeB +"\nPuntaje Blanco= "+ PuntajeW);
		}
		else{
			if(PuntajeW > PuntajeB){
				alert("GANO JUGADOR BLANCO \nPuntaje Blanco= "+ PuntajeW + "\nPuntaje Negro= "+ PuntajeB);
			}
				else{
					if(PuntajeW === PuntajeB)
						alert("EMPATE \nPuntaje Negro= "+ PuntajeB +"\nPuntaje Blanco= "+ PuntajeW);
				}
		}
	alert(" AHORA SE CARGARA UNA PARTIDA NUEVA ");
        handleCreate();
    } 
}

/**
 * Called when the pengine fails to find a solution.
 */

function handleFailure() {
    alert("Movimiento Invalido!");
}

/**
 * Handler for color click. Ask query to Pengines server.
 */

function handleClick(row, col) {
    flag = "ficha";
    const s = "goMove(" + Pengine.stringify(gridData) + "," + Pengine.stringify(turnBlack ? "b" : "w") + "," + "[" + row + "," + col + "]" + ",Board)";
    pengine.ask(s);
    latestStone = [row, col];
    passTurn = false;
}

function switchTurn() {
    turnBlack = !turnBlack;
    bodyElem.className = turnBlack ? "turnBlack" : "turnWhite";
}

function pasarTurno(){
    if(!passTurn){
        passTurn = true;
        switchTurn();
    }
    else{
        gameOver();
    }
}

function gameOver(){
	alert("GAME OVER");
    flag = "gameover";
	passTurn = false;
    const s = "score(" + Pengine.stringify(gridData) + ",PuntajeW,PuntajeB)";
    pengine.ask(s);
}

/**
* Call init function after window loaded to ensure all HTML was created before
* accessing and manipulating it.
*/

window.onload = init;