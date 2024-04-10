/* @pjs preload="Beam.png,Bullet.png"; */
/* @pjs font="Electrolize.ttf"; */

/*
タイトル:
Protection

概要:
マウスで壁を操作して中央のコアを飛んでくる弾から防衛する。

クリア条件:
1分間コアを防衛する。

ゲームオーバー条件:
3回コアに被弾する。

難易度:
ゲームが苦手な人でも頑張れば全てクリアできる程度。

*/
final int FPS = 60;
float pZone = 50; //守備範囲の半径
float rot = PI/4;
Game game;

PFont electrolize;

/* scene 対応一覧
0: title (default)
1: inGame
2: gameOver
3: gameClear
*/
int scene = 0;

void setup(){
    size(600, 600);
    frameRate(FPS);
    noStroke();
    
    electrolize =createFont("Electrolize.ttf", 64);

    translate(width/2, height/2); //中心座標をウィンドウ中心に変更 マウス座標は影響を受けないことに注意
    game = new Game(1);
}

float mX;
float mY;

void draw(){
    // 背景描画
    background(15, 15, 15);
    
    
    //中心座標の変更
    translate(width/2, height/2);
    mX = mouseX - width/2;
    mY = mouseY - width/2;

    game.draw();

    //ポインターの描画
    // translate(-width/2, -height/2);
    // noStroke();
    // fill(0,0,255);
    // ellipse(mouseX, mouseY, 15, 15);
}


class Game{
    private int frame; //フレームカウント
    private final int gcFrame; //クリア判定用 sec * fps
    private int difficulty;
    private NoteManager notes;
    private Shield shield;
    private Core core;

    Game(int difficulty){
        frame = 0;
        gcFrame = 60 * FPS;
        this.difficulty = difficulty;
        notes = new NoteManager(difficulty);
        shield = new Shield(notes.getLaneNum());
        core = new Core();
    }

    void draw(){
        // 背景描画
        strokeWeight(1);
        stroke(50, 230, 50);
        line(-width/2, 0, width, 0);
        line(0, -height/2, 0, height);
        stroke(255);

        //回転
        rotate(rot);

        //描画処理
        println("scene: " + scene);
        switch (scene) {
            case 0:
                title();
            break;
            case 1:
                inGame();
            break;
            case 2:
                gameOver();
            break;
            case 3:
                gameClear();
            break;
        }
        
        //座標の回転を戻す
        rotate(-rot);
    }

    //// シーン実装 
    //0
    private void title(){
        rotate(-rot);

        fill(255,255,255,130);
        rect(-250, -250, 500, 500);
        textSize(64);
        textAlign(CENTER);
        textFont(electrolize);
        fill(255);
        text("Protection", 0, -45);

        //start button
        int bx = -70;
        int by = 53;
        fill(0,255,0);
        strokeWeight(3);
        rect(bx, by, -2*bx, 70, 10);
        textSize(32);
        fill(255);
        text("START", 0, 100);
        boolean isTouchingS = bx < mX && -bx > mX &&
                             by < mY && by+70 > mY;
        if(isTouchingS){
            if(mousePressed){
                scene = 1;
                game = new Game(difficulty);
            }
        }

        // dif button
        btn_difficulty();

        rotate(rot);
    }
    //1
    private void inGame(){
        notes.genNote();
        shield.setLane();
        notes.collision(shield, core);

        notes.draw();
        shield.draw();
        core.draw();

        if(core.isBroken())
            scene = 2;

        frame++;
        println(frame);
        if(frame > gcFrame)
            scene = 3;
    }
    //2
    private void gameOver(){
        rotate(-rot);

        fill(255,255,255,130);
        rect(-250, -250, 500, 500);
        textSize(64);
        textAlign(CENTER);
        textFont(electrolize);
        fill(255, 0, 0);
        text("ANNIHILATED", 0, -45);

        //rewind button
        int bx = -70;
        int by = 55;
        fill(0,255,0);
        strokeWeight(3);
        rect(bx, by, -2*bx, 50, 7);
        textSize(32);
        fill(255);
        text("REWIND", 0, 90);
        boolean isTouchingR = bx < mX && -bx > mX &&
                             by < mY && by+70 > mY;
        if(isTouchingR){
            if(mousePressed){
                btn_restart();
            }
        }

        //title button
        bx = -70;
        by = 121;
        fill(0,0,150);
        strokeWeight(3);
        rect(bx, by, -2*bx, 50, 7);
        textSize(32);
        fill(255);
        text("TITLE", 0, 156);
        boolean isTouchingT = bx < mX && -bx > mX &&
                             by < mY && by+70 > mY;
        if(isTouchingT){
            println("nu");
            if(mousePressed){
                btn_goTitle();
            }
        }

        rotate(rot);
    }
    //3
    private void gameClear(){
        rotate(-rot);
        shield.draw();
        core.draw();

        fill(255,255,255,130);
        rect(-250, -250, 500, 500);
        textSize(64);
        textAlign(CENTER);
        textFont(electrolize);
        fill(0, 255, 0);
        text("CONQUERED", 0, -45);

        //title button
        float bx = -70;
        float by = 121;
        fill(0,0,150);
        strokeWeight(3);
        rect(bx, by, -2*bx, 50, 7);
        textSize(32);
        fill(255);
        text("TITLE", 0, 156);
        boolean isTouchingT = bx < mX && -bx > mX &&
                             by < mY && by+70 > mY;
        if(isTouchingT){
            if(mousePressed){
                btn_goTitle();
            }
        }
        rotate(-rot);
    }

    //// ボタン機能
    private void btn_difficulty(){
        println(difficulty);
        textSize(28);
        fill(255);
        text("Difficulty", 150, 180);

        float bx = 110;
        float by = 200;
        float size = 20;
        float dx = 10 + size;

        boolean d1 = mX > bx && mX < bx+size &&
                     mY > by && mY < by+size;

        boolean d2 = mX > bx +dx && mX < bx+size +dx &&
                     mY > by && mY < by+size;
        
        boolean d3 = mX > bx +dx*2 && mX < bx+size +dx*2 &&
                     mY > by && mY < by+size;
        
        boolean d4 = mX > bx +dx*3 && mX < bx+size +dx*3 &&
                     mY > by && mY < by+size;

        fill(0, 255, 0, 255);
        rect(bx, by, size, size);
        if(d1 && mousePressed)
            difficulty = 1;

        fill(0, 255, 0, 255*(difficulty-1));
        rect(bx + dx, by, size, size);
        if(d2 && mousePressed)
            difficulty = 2;

        fill(0, 255, 0, 255*(difficulty-2));
        rect(bx + dx*2, by, size, size);
        if(d3 && mousePressed)
            difficulty = 3;
        
        fill(0, 255, 0, 255*(difficulty-3));
        rect(bx + dx*3, by, size, size);
        if(d4 && mousePressed)
            difficulty = 4;
    }

    private void btn_restart(){
        scene = 1;
        game = new Game(difficulty);
    }

    private void btn_goTitle(){
        println("Goooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo");
        scene = 0;
    }
}

// ノーツの管理を行う
class NoteManager{
    private int laneNum; //レーン数
    private float noteVelo; //ノーツ速度 正の数で扱う
    private ArrayList<Note> notes = new ArrayList<Note>(); //ノーツの格納
    private int difficulty;
    private int fCount = 0;

    NoteManager(int difficulty){
        this.difficulty = difficulty;
        laneNum = difficulty + 3;
        noteVelo = difficulty + 3;

        // debug
        Note note = new Note(laneNum, 0, false);
        notes.add(note);
    }

    void draw(){
        for(int i=0; i < notes.size(); i++){
            notes.get(i).draw(noteVelo);
        }
    }

    void genNote(){
        int lane = (int)random(0, laneNum-0.01); //レーン数から0.01を滅しできる限り均一にレーン配置を行う  

        float pivo = random(0, 1); //ノーツの設定用乱数

        //debug
        // println("gen");

        fCount++;
        if(fCount > 20){
            println("nu");
            if(pivo < 0.4){ // pivoの値でノーツを生成と種類を決定
                Note note = new Note(laneNum, lane, false);
                notes.add(note);
            } else if (pivo < 0.3) {
                // Note note = new Note(laneNum, lane, true);
                // notes.add(note);
            }
            fCount = 0;
        }
    }

    void rmvNote(){
        for(int i=0; i < notes.size(); i++){
            if(notes.get(i).isRemovable()){
                notes.remove(i);
                println("Removed!!!!!!!");
            }
        }
    }

    void collision(Shield shield, Core core){
        for(int i=0; i < notes.size(); i++){
            notes.get(i).collision(shield, core);
        }
    }

    int getLaneNum(){return laneNum;}
}

// ノーツ(弾) 単発とホールドの二種類
// 進行速度をdraw時に渡す
//   座標は極座標系で管理 渡された速度の値をrに作用させる
class Note{
    private int lane; //レーン 0-laneNum
    private float r; //中心との距離
    private float theta;
    private boolean hold; //ホールドノーツの判別 予約 未実装
    private boolean removable;
    // private PImage img;
    private int d = 10;
    

    Note(int laneNum, int lane, boolean hold){
        this.lane = lane;
        theta = lane * (2*PI / laneNum) -PI; //指定されたレーンに対応する角を格納
        r = width * sqrt(2); //初期位置を中心から画面端までの最大サイズに合わせる
        this.hold = hold;
        removable = false;
        // if(hold)
        //     img = loadImage("Beam.png");
        // else
        //     img = loadImage("Bullet.png");
    }

    void draw(float velo){
        if(r > pZone - 10){
            r -= velo;
            float x = r * cos(theta);
            float y = r * sin(theta);
            // image(img, x-20, y-20, 40, 40);
            fill(255);
            ellipse(x, y, d, d);
            println("x: " +x +" y: "+ y);
        }
    }

    void collision(Shield shield, Core core){
        boolean isAttacked = shield.getLane() != lane &&
                             r < pZone &&
                             !removable;
        if(isAttacked){
            core.atttack(1);
            removable = true;
        } else if(r < pZone){
            removable = true;
        }
    }

    boolean isRemovable(){return removable;}
}

class Shield{
    private int lane;
    private int laneNum;

    Shield(int laneNum){
        lane = 0;
        this.laneNum = laneNum;
    }

    void draw(){
        float x = pZone;
        float y = -50;
        float dx = 7;
        float dy = 2 * pZone * sin(2*PI / laneNum); //正弦定理から長さを算出
        float rot = lane * 2*PI / laneNum;
        rotate(rot);
        fill(255);
        rect(-x, y, dx, dy);
        rotate(-rot);
    }

    void setLane(){
        float theta = atan2(mY, mX) + PI; //引数のxとyを逆にして水平時計回りにする
        float dtheta = 2*PI / laneNum;
        
        //debug
        // println("x: " + x + "y: " + y);
        // println("theta:" + theta);

        for(int i=0; i < laneNum; i++){
            if(dtheta*i <= theta && dtheta*(i+1) >= theta){
                lane = i;
                
                //debug
                // println("-----------------------------------");
                // println("lane: " + lane + "  laneNum: "+ laneNum);
                // fill(255);
                // println("x: " + x + "y: " + y);
                // println("theta:" + theta);
                
                break;
            }
            
        }
    }

    int getLane(){return lane;}
}

class Core{
    private int durabillity;
    Core(){
        durabillity = 3;
    }

    void draw(){
        noStroke();
        fill(0,255,0,30);
        ellipse(0,0,pZone*2,pZone*2);
        switch (durabillity) {
            case 3:
                fill(255);
                rect(-15, -15, 30, 30);
                fill(0,255,0);
                ellipse(0, 0, 15, 15);
            break;	
            case 2:
                fill(255);
                triangle(-15, 0, 15, 0, 0, 15);
                fill(255,255,0);
                ellipse(0, 0, 15, 15);
            break;
            case 1:
                fill(255,0,0);
                ellipse(0, 0, 15, 15);
            break;
        }
    }

    void atttack(int num){
        durabillity -= num;
        println("!!!!!!!!!!Attacked!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    }

    boolean isBroken(){
        return durabillity == 0;
    }
}