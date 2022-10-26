; Esercizio Movimento Snake per necro_6502.exe da eseguire in Dummy6502

; Change direction: ->, <-, ecc....

; Compila il programma
; necro_6502.exe .\Dummy6502\Esercizi\MySnake.S .\Dummy6502\Esercizi\MySnake.bin 

.org $8000
; Directions (each using a separate bit)
.define moveUp        $01
.define moveRight     $08
.define moveDown      $02
.define moveLeft      $04
.define noMove        $00
.define quit          $71

.define keyAddress    $4000
.define mapStart      $0200

.define limitedRow    #$0F
.define limitedLeft   #$00
.define limitedRight  #$0F
.define limitedColumn #$F0
.define limitedUp     #$00
.define limitedDown   #$F0

.define positionMove  $0301

.define appleStart    #$77
.define positionApple $0300
.define appleColor    #$02

.define snakeStart     #$00
.define snakeLenStart  #$00
.define snakeTailLen   $0303
.define snakeHeadClr   #$01
.define snakeTailClr   #$04
.define directionSnake $0302
.define positionSnakeH $0304
.define noColor        #$00



;--------------------------------
start:
;--------------------------------
    JSR initMoveKey
    JSR initGame

loopKey:
    JSR checkMove
    JSR checkCollisionSnake
    JSR checkCollisionApple
    JSR clearSnake
    JSR moveTail
    JSR moveSnake
    JSR checkCollisionTail
    JSR drawSnakeTail
    JSR drawSnakeHead
    JSR drawApple
    JSR readKey
 
 
    JMP loopKey

;--------------------------------
initMoveKey:
;--------------------------------
    LDA #noMove ; Inizializzo  a nessun valore di direzione precedente
    STA positionMove
    RTS

;--------------------------------
initGame:
;--------------------------------
    LDA #moveRight
    STA directionSnake
    LDA appleStart
    STA positionApple
    LDA snakeStart
    STA positionSnakeH
    LDA snakeLenStart
    STA snakeTailLen
    RTS

;--------------------------------
readKey:
;--------------------------------
    LDA keyAddress ; read from the keyboard
    CMP noMove ; se è 0 riportiamo Y in A per mantenere il movimento con 1 sola pressione del tasto
    BEQ readKeyReturn
    STA directionSnake
readKeyReturn:
    RTS

;--------------------------------
drawSnakeHead:
;--------------------------------
    LDA snakeHeadClr
    LDX positionSnakeH
    STA mapStart, X
    RTS

;--------------------------------
drawSnakeTail:
;--------------------------------
    LDY snakeTailLen
    CPY snakeLenStart
    BEQ drawTailReturn

    LDA snakeTailClr
    LDY snakeLenStart
drawTailLoop:
    INY
    LDX positionSnakeH, Y
    STA mapStart, X
    CPY snakeTailLen
    BNE drawTailLoop
drawTailReturn:
    RTS


;--------------------------------
drawApple:
;--------------------------------
    LDA appleColor
    LDX positionApple
    STA mapStart, X
drawAppleReturn:   
    RTS

;--------------------------------
checkMove:
;--------------------------------  

    LDY positionMove

    LDA directionSnake
    CMP #noMove
    BEQ checkReturn
    CMP #moveUp
    BEQ checkMoveUp
    CMP #moveDown
    BEQ checkMoveDown
    CMP #moveLeft
    BEQ checkMoveLeft
    CMP #moveRight
    BEQ checkMoveRight
    BNE checkReturn

    ;CMP #quit  ;"Q"
    ;BEQ gameOver ;TODO: Sistemare il "Quit"

checkMoveUp:
    CPY #moveDown
    BEQ checkReturn
    BNE checkOk
checkMoveDown:
    CPY #moveUp
    BEQ checkReturn
    BNE checkOk
checkMoveLeft:
    CPY #moveRight
    BEQ checkReturn
    BNE checkOk
checkMoveRight:
    CPY #moveLeft
    BEQ checkReturn
    BNE checkOk
checkOk: 
    STA positionMove ;salvo il valore di Spostamento
checkReturn:
    LDA positionMove
    STA directionSnake
    RTS

;--------------------------------
moveTail:
;--------------------------------
    LDY snakeTailLen
    CPY snakeLenStart
    BEQ moveTailReturn

    LDX snakeTailLen
moveTailLoop:
    DEX
    LDA positionSnakeH, X
    STA positionSnakeH, Y
    DEY
    CPX snakeLenStart
    BNE moveTailLoop
moveTailReturn:
    RTS


;--------------------------------
moveSnake:
;--------------------------------
    LDA directionSnake
    CMP #moveUp
    BEQ up
    CMP #moveDown
    BEQ down
    CMP #moveLeft
    BEQ left
    CMP #moveRight
    BEQ right
    NOP
    NOP
    NOP
    ;CMP #quit  ;"Q"
    ;BNE moveSnakeReturn
    ;JMP gameOver ;TODO: Sistemare il "Quit"
    RTS
up:
    LDA positionSnakeH
    ADC #$eF
    STA positionSnakeH
    RTS
down:
    LDA positionSnakeH
    ADC #$0F
    STA positionSnakeH
    RTS
left:
    LDX positionSnakeH
    DEX
    STX positionSnakeH
    RTS
right:
    LDX positionSnakeH
    INX
    STX positionSnakeH
moveSnakeReturn:
    RTS

;--------------------------------
checkCollisionSnake:
;--------------------------------
    LDA positionSnakeH ; Metto la posizione della testa dello snake in A
    LDY directionSnake ; Metto la direzione dello snake in Y 
checkCollisionRight:
    CPY #moveRight
    BNE checkCollisionLeft
    AND limitedRow
    CMP limitedRight
    BEQ gameOver
    BNE checkCollisionReturn
checkCollisionLeft:
    CPY #moveLeft
    BNE checkCollisionDown
    AND limitedRow
    CMP limitedLeft
    BEQ gameOver
    BNE checkCollisionReturn
checkCollisionDown:
    CPY #moveDown
    BNE checkCollisionUp
    AND limitedColumn
    CMP limitedDown
    BEQ gameOver
    BNE checkCollisionReturn
checkCollisionUp:
    CPY #moveUp
    BNE checkCollisionReturn
    AND limitedColumn
    CMP limitedUp
    BEQ gameOver
checkCollisionReturn:
    RTS

;--------------------------------
checkCollisionTail:
;--------------------------------
    LDA positionSnakeH
    LDY snakeTailLen
    CPY snakeLenStart
    BEQ checkCollisionTailReturn
checkCollisionTailLoop:
    CMP positionSnakeH, Y
    BEQ gameOver
    DEY
    CPY snakeLenStart
    BNE checkCollisionTailLoop
checkCollisionTailReturn:
    RTS


;--------------------------------
clearSnake:
;--------------------------------
    LDA noColor
    LDY snakeTailLen
    LDX positionSnakeH, Y
    STA mapStart, X
    RTS

;--------------------------------
checkCollisionApple:
;--------------------------------
    LDX positionSnakeH ; Metto la posizione della testa dello snake in X
    CPX positionApple ; Se la posizione della testa dello snake è uguale a quella della mela
    BNE checkCollisionAppleReturn ; allora non faccio nulla 
    LDA positionApple ; altrimenti incremento la lunghezza dello snake
checkCollisionAppleReplay:
    ADC #$cc ; e sposto la mela in una posizione casuale
    ADC directionSnake ; disegno la mela
    
    LDY snakeTailLen ; controllo che la mela non sia stata spostata su una posizione dello snake
    CPY snakeLenStart ; se è così la sposto in una posizione casuale
    BEQ checkCollisionAppleOk 
checkCollisionAppleLoop:
    CMP positionSnakeH, Y
    BEQ checkCollisionAppleReplay
    DEY
    CPY snakeLenStart
    BNE checkCollisionAppleLoop

checkCollisionAppleOk:
    STA positionApple ; sulla mappa
    JSR incrementSnake ; e incremento la lunghezza dello snake

checkCollisionAppleReturn: 
    RTS

;--------------------------------
incrementSnake:
;--------------------------------
    INC snakeTailLen
    RTS

;--------------------------------
gameOver:
    NOP
    JMP gameOver
;--------------------------------

.goto $FFFA
.dw start
.dw start
.dw start