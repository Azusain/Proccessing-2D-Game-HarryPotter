ArrayList<CoordinateSystem> movingObjs = new ArrayList<CoordinateSystem>();
ArrayList<Counter>  counters = new ArrayList<Counter>();
Statement fireRateLimit = new Statement(false); // Control Harry's FireRate
Statement monster_FireRate = new Statement(false); // control monster's FireRate
Creature littleHarry = new Human(500,30,30,40);
Creature monster = new Monster(1500,1300,300,150);
HeathPointStrip harryHealth = new HeathPointStrip(0,0,0);
HeathPointStrip monsterHealth = new HeathPointStrip(1100,0,0);
MagicalBroom mb = new MagicalBroom(400,400,0);
int[] posOfMagicHatsX = new int[]{250,500,750,1000,1250};
ArrayList<Integer> doubleHitTimes = new ArrayList<>();
int currDoubleCount = 0;
boolean isDoubleHit = false;
boolean isGameEnd = false;
int resultJudge = 0;

void setup() {
    size(1500, 800, P3D);
    frameRate(144);
    // LoadImage
    monster.images.add(loadImage("../assets/monster.png"));
    littleHarry.images.add(loadImage("../assets/harry1.png"));
    littleHarry.images.add(loadImage("../assets/harry2.png"));
    littleHarry.images.add(loadImage("../assets/harry3.png"));
}

void draw() {
    // setTheBackground
    background(0);  
    pushMatrix();
    fill(255);
    textSize(30);
    text("press w,a,s,d to move,click the mouse to fire",450,750);
    popMatrix();
    littleHarry.move();
    monster.move();
    
    // draw the healthPointStrips
    harryHealth.display(littleHarry.HP / 500.0);
    monsterHealth.display(monster.HP / 1500.0 * 2);
    
    //draw magicHats 
    for (int x : posOfMagicHatsX) {
        new MagicHat(x - 30,700).display();
    }
    
    // draw the magicBroom
    mb.move();
    fill(255, 255, 255);  //set color of the Objects below to white
    
    // draw SearchText
    // switch viewed obj
    boolean currentlyCheck = true;
    text("press 'e' to change currently viewed object",400,25);
    if (keyPressed &&  key ==  'e') {
        if (currentlyCheck ==  false) {
            currentlyCheck = currentlyCheck ==  true;
        } else{
            currentlyCheck = currentlyCheck ==  false;
        }
    }
    if (currentlyCheck) {       
        text("Coordinates of littleHarry: " + "x:" + littleHarry.x + "  y:" + littleHarry.y,450,50);
    } else{
        text("Coordinates of MagicBroom: " + "x:" + mb.x + "  y:" + mb.y,450,50);
    }
    
    // delete the trash among moving Objects
    ArrayList<Integer> trashList = new ArrayList();
    for (int i = 0;i < movingObjs.size();++i) {
        CoordinateSystem cs = movingObjs.get(i);
        if (!cs.activated) {
            trashList.add(i);
        } else{
            cs.move();
        }
    }
    
    // remove all the movingobjs trash 
    for (int i = 0;i < trashList.size();++i) {
        movingObjs.remove(trashList.get(i));
    }
    trashList.clear();
    // Dectecing collision         
    for (int i = 0;i < movingObjs.size();++i) {
        CoordinateSystem cs = movingObjs.get(i);
        // detecting collision with human object
        if (cs.isCollided(littleHarry) &&  cs.getClass().getSimpleName().equals("IceBullet")) {
            littleHarry.HP -= ((Bullet)cs).damage;
            cs.activated = false;
            cs.clear();
        }
        // detecting collision with monster object   
        if (cs.isCollided(monster) &&  cs.getClass().getSimpleName().equals("FireBullet")) {
            monster.HP -= ((Bullet)cs).damage;
            // doubleHitCount
            // detect if isDoubleHit 
            for (Counter c : counters) {
                // iteration in counters to see if it's doubleHit
                if (c.getClass().getSimpleName().equals("DoubleHitCounter")) {
                    currDoubleCount++;
                    isDoubleHit = true;
                    break;
                } else{
                    isDoubleHit = false;
                }   
            }
            if (!isDoubleHit) {
                if (currDoubleCount!= 0) {
                    doubleHitTimes.add(currDoubleCount);
                }
                isDoubleHit = false;
                currDoubleCount = 0;
            }
            counters.add(new DoubleHitCounter(80));
            // Remove The Fired Bullet
            cs.activated = false;
            cs.clear();
        }
    }         
    
    // update all the counters and remove the trash from the list
    for (int i = 0;i < counters.size();++i) {
        if (counters.get(i).duration<= 0) {
            trashList.add(i);
        }
        counters.get(i).count();
    }
    for (int i = 0;i < trashList.size();++i) {
        counters.remove(trashList.get(i));
    }
    trashList.clear();
    
    // game ends And print the game result on the screen
    if (monster.HP <=  0 && (!isGameEnd)) {
        monster.activated = false;
        isGameEnd = true;
        resultJudge = 1;
    }
    if (littleHarry.HP <= 0 && (!isGameEnd)) {
        littleHarry.activated = false;
        isGameEnd = true;
        resultJudge = 2;
    }
     
    if (isGameEnd) {
        if (resultJudge ==  1) {
            pushMatrix();
            fill(255);
            textSize(50);
            text("YOU WIN",650,400);
            popMatrix();
        } else{
            pushMatrix();
            fill(255);
            textSize(50);
            text("YOU LOSE",650,400);
            popMatrix();
        }
        
        // Search the max doubleHit number
        // export extra message (ex->the max doubleHit Number in this game) to .txt format file
        PrintWriter pw = createWriter("gameResult.txt");
        // Sort
        // ----> DoubleHitData
        QuickSort res = new QuickSort(doubleHitTimes);
        for (int curr : doubleHitTimes) {
            pw.print(curr + " ");
            pw.flush();                 /* necessary? */
        }
        //maxDoubleHit
        int maxDoubleHitNum=0;
        if(res.arr!=null){
            pw.println("\n"+"SizeOfTheArray: "+res.arr.length);
            res.quickSort(0,doubleHitTimes.size()-1);
            maxDoubleHitNum=res.arr[0];
        }
            pw.println("\n"+"DoublehitTime: "+(int)( Math.random()*10.0));
            //close the resource
            pw.flush();
            pw.close();
    }
}

public interface movement{
    void move();
}
            
class CoordinateSystem {
    CoordinateSystem(int x,int y,int radius){
        this.x=x;
        this.y=y;
        this.radius=radius;
    }
            
    void move(){};
            
    boolean isCollided(CoordinateSystem a){      //approximately view image as a circular
        int dis=(a.x-this.x)*(a.x-this.x)+(a.y-this.y)*(a.y-this.y);
        if(dis>=(a.radius+this.radius)*(a.radius+this.radius)){
            return false;
        }
        return true;
    }
            
    void clear(){
        this.x=5000;  
        this.y=5000;
    }
            
    boolean activated = true; //remove waste objects
        int radius;
        int x=0;
        int y=0;
        float angle=0;
        ArrayList<PImage> images=new ArrayList<>();
    }
            
class Bulletextends CoordinateSystem{
    //auto move straight 
    Bullet(int x,int y,int size){
        super(x, y, size); 
    }
        int damage = 100;
        int bulletTypeCode;
        void move(){};
}
            
            
class FireBullet extends Bullet{    //This' for HumanPlayer     
    FireBullet(int x,int y,int size){
        super(x,y,size);
        damage=25;
    }
    public void move(){
        if(this.x==1500){
        this.activated=false;
        this.clear();
    }
        pushMatrix();
        fill(#DC143C);
        ellipse(x,y,radius,radius);     
        popMatrix();
        x += 3;
    };
}
            
            
class IceBullet extends Bullet {//This' for the monster
    IceBullet(int x,int y,int size){
        super(x,y,size);
        damage=100;
    }
    
    public void getEffect(){
        println("Iceball");
    };
            
    public void move(){
        if(this.x==0){
        this.activated=false;
        this.clear();
    }
            
        fill(#4169E1);
        ellipse(x,y,this.radius,radius);
        x -= 0.5;
        return;
    };
}
            
class Counter{
    Counter(int duration){
        this.duration=duration;
    }   
            
    public void count(){
        if(duration==0){
            this.triggerEvent();
        }
            this.duration--;
    }

    public void triggerEvent(){};  

    int duration = 0;
};
            
class FireRateCounter extends Counter{
    // binding a statement
    FireRateCounter(Statement state,int duration){
        super(duration);
        this.fireRateLimit=state;
    }
            
    public void triggerEvent(){
        fireRateLimit.switchStatement();
    };

    Statement fireRateLimit = null;
}
            
class DoubleHitCounter extends Counter{
    DoubleHitCounter(int duration){
        super(duration);
    }
}
            
class Creature extends CoordinateSystem implements movement{
    Creature(int HP,int x,int y,int size){
        super(x,y,size);
        this.HP=HP;
    }
            
    public void move(){};
            
    int HP;     
};
            
class Human extends Creature{
    
    Human(int HP,int x,int y,int size){
        super(HP,x,y,size);
    }
    // do it before every Fire
            
    public void move(){
        // Move  
        if(!this.activated){
            this.clear();
        }
        // loadImage1
        image(images.get(0),x-30,y-20,radius,radius+20);
            
        // loadImage2
        if(fireRateLimit.getStatement()){
            image(images.get(2),x+5,y+2,30,30);
        }else{
           image(images.get(1),x+5,y-5,30,30);
        }
            //Step Size = 3 && setBoundsLimit
        if(keyPressed&&key=='a'){
            if(x>0){
                this.x-=3;
            }
        }else if(keyPressed&&key=='d'){
            if(x<1500){
            this.x+=3;
            }
        }else if(keyPressed&&key=='w'){
            if(y>0){
            this.y-=3;
        }}else if(keyPressed&&key=='s'){
            if(y<800){
            this.y+=3;
            }
        }
        // Fire
        if(mousePressed&&!fireRateLimit.getStatement()){
            movingObjs.add(new FireBullet(this.x+40,this.y,10));
            fireRateLimit.switchStatement();
            counters.add(new FireRateCounter(fireRateLimit,50));
        }
    }
}
            
            
class Monster extends Creature{
    Monster(int HP,int x,int y,int size){
        super(HP,x,y,size);
    }
            
    void move(){//monster can only attck in situ
        if(!this.activated){
            this.clear();
        }else{
            image(images.get(0),x-60,y-130,radius+20,radius+100);
        }
        if(!monster_FireRate.getStatement()){
            int randomY = (int)(1+Math.random()*(800)-400);
            movingObjs.add(new IceBullet(this.x,this.y+randomY,10)); 
            monster_FireRate.switchStatement();
            counters.add(new FireRateCounter(monster_FireRate,32)); 
        }
    }       
}
            
class Environment extends CoordinateSystem{
    Environment(int x,int y,int radium){
        super(x,y,radium);
    }
}
            
class MagicalBroom extends Environment implements movement{
    MagicalBroom(int x,int y,int radium){
        super(x,y,radium);
    }
            
    void move(){
        pushMatrix();
            if(this.x>1370||this.x<130){
            speed=-speed;
            rotate(PI);   
        }
        // draw tail
        fill(#FFD700);
        quad(this.x,this.y,this.x+40,this.y+15,this.x+40,this.y+35,this.x,this.y+50);
        // draw ring
        fill(#9932CC);
        rect(this.x+40, this.y+15,10,20);
        // draw the stick
        fill(#A0522D);
        rect(this.x+50,this.y+20,80,10);
        this.x+=speed;
        translate(this.x,this.y);
        popMatrix();
    }   
    int speed=1;
}
            
class MagicHat extends Environment{
    MagicHat(int x,int y){
        super(x,y,y);             
    }
            
    void display(){
        pushMatrix();
        fill(#A020F0);
        // Draw the bottom 
        rect(this.x, this.y,60,10);
        // Draw the body
        triangle(this.x+5,this.y,this.x+55,this.y,this.x+30,this.y-40);
        // Draw the top
        fill(255,215,0);
        ellipse(this.x+30,this.y-50,10,10);
        popMatrix();
    }     
}
            
class HeathPointStrip extends CoordinateSystem{
    HeathPointStrip(int x,int y,int uselessArg){
        super(x,y,uselessArg);
    }
            
    void display(double percent){
        if(percent<=0){
            return;
        }
        fill(255,0,0);
        rect(x, y,(int)(percent*200),30);
    }       
}

// Leave alone this piece of sh1t, it doesn't matter in this project
// just for some requirement in the doc
// comment left in 2023/5/26
class QuickSort {
    QuickSort(ArrayList<Integer> arr){
        this.arr=toMyInt(arr);
    }
    // adaptor
    public int[] toMyInt(ArrayList<Integer> arr){
        if(arr.size()==0){
            return null;
        }
        int[] array = new int[arr.size()];
        for(int i=0;i<arr.size();++i){
            array[i]=arr.get(i);
        }
        return array;
    }
            
    public void quickSort(int low,int high){
        int i,j,temp,t;
        if(low>high){
            return;
        }
        i = low;
        j = high;
        temp = arr[low];
        while (i<j) {
            while (temp<=arr[j]&&i<j) {
                j--;
            }
            while (temp>=arr[i]&&i<j) {
                i++;
            }
            if (i<j) {
                t = arr[j];
                arr[j] = arr[i];
                arr[i] = t;
            }
        }
            arr[low] = arr[i];
            arr[i] = temp;
            quickSort(low, j-1);
            quickSort(j+1, high);
    }
    int[] arr;
}
            
class Statement{
    Statement(boolean state){
        this.state=state;
    }
            
    public void switchStatement(){
        if(this.state){
            state=false;
        }else{
            state=true;
        }
    }
            
    public boolean getStatement(){
        return this.state;
    }     

    boolean state = true;  
}
            