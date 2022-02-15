import java.util.*;

class Game {
  
  ArrayList<Sprite> deleteQueue = new ArrayList<Sprite>();
  ArrayList<Sprite> sprites = new ArrayList<Sprite>();
  ArrayList<UIComponent> ui = new ArrayList<UIComponent>();
  //creates a delete queue for the UI
  ArrayList<UIComponent> deleteQueueUI = new ArrayList<UIComponent>();
  PImage BG;
  Player player;
  boolean paused = false; 
  
  //UI
  Hearts hearts;
  Ammo ammo; 
  
  //Stats
  Stats statistics; 
  
  
  LvlManager lvlManager = new LvlManager();
  
  void config() {
    BG = loadImage("assets/background.png");
    BG.resize(width, height);
    background(BG);
    noStroke();
    rectMode(CENTER);
    imageMode(CENTER);
  }
  
  void spawn(Sprite sprite){
    sprites.add(sprite);
  }
  
  void levelLoad(){
    //clears sprites to make room for new level sprites
    if(sprites.size() > 0){
     try{
       ArrayList<Sprite> sprites = new ArrayList<Sprite>(this.sprites);
       for(Sprite s: sprites){
         pendDelete(s);
       }
       this.sprites = sprites;
      } catch (NullPointerException e){
        e.printStackTrace();
      }      
    }

    config();
    
    lvlManager.addSymbols();
    
    player = new Player(width/2, height-100, 50, 50, color(#17c3b2));
    sprites.add(player); 
    
    //why is this here?
    ammo = new Ammo(10); 
    
    
    ui.add(ammo); 
    ui.add(hearts);
    
    //spawns in enemies based on currentlevel enemy count and arbitrary enemy positions
    if(lvlManager.currentLvl.enems.length > 0){
      try{
        for(int x = 0; x < lvlManager.currentLvl.enems.length; x++){
         Bob b = new Bob(lvlManager.currentLvl.enems[x].x, lvlManager.currentLvl.enems[x].y, lvlManager.currentLvl.enems[x].w, lvlManager.currentLvl.enems[x].h);
         spawn(b);

          
        }
      } catch (NullPointerException e) {
       e.printStackTrace();
      }    
    }
  }
  
  void load() {
    config();
    
    lvlManager.addSymbols();
    
    player = new Player(width/2, height-100, 50, 50, color(#17c3b2));
    sprites.add(player); 
    
    hearts = new Hearts(3);
 
    ui.add(hearts);
  }
  
  void play() {
    //bg.resize(width, height);
    background(BG);
    lvlManager.currentLvl.decorateLvl();

    for(Sprite s: sprites){
      s.move();
      s.render();
       //checks if bob collides with other bobs
      if(s instanceof Bob){
         for(Sprite b: sprites){
           if( b instanceof Bob && s!=b){
             if(s.collide(b)){
              s.collision(b);              
             }
           }
         }
       }
    }
      
    for(UIComponent c: ui){
      c.render();
    }
    removeProjectiles();
    killEnemies();
    delete();
    deleteUI();
  }
  
  //checks if game has been paused from keypress
  void checkPause(char c){
    if ( c == 'p' ) {
      paused = !paused;
      if (paused) {
        noLoop();
        game.pauseMenu(true);
      } else {
        loop();
        game.pauseMenu(false);
      }
    }
  }
  

  
  //creates pause menu whenever checkPause() is true
  void pauseMenu(boolean p){
    if(p){
      fill(225, 0, 0);
      textAlign(CENTER);
      fill(0, 0, 225);
      textSize(100);
      text("Game Paused", width/2, height/5);
      textSize(30);
      text("Shots Fired: " + Stats.shotsFired, width/5, height/3);
      text("Enemies Killed: " + Stats.enemiesKilled, 4*width/5, height/3);
    }
  }

  void killEnemies(){
    int i = 0;
    // loop through sprite array
    while(i < sprites.size()) {
      // if the sprite is a Projectile
      if(sprites.get(i) instanceof Projectile){
        // loop through the sprite array again
        for(int j = 0; j < game.sprites.size(); j++){
          // check if there's an enemy colliding with the projectile
          if(sprites.get(j) instanceof Bob && sprites.get(i).collide(sprites.get(j))){
            // updates enemies killed in current level
            lvlManager.currentLvl.iterateEnems(1);
            
            // add the sprite to the delete queue
            pendDelete(sprites.get(j));
            pendDelete(sprites.get(i));         

            game.ammo.addAmmo(3); 
            Stats.enemiesKilled++; 
          }
        }
      }
      if(sprites.get(i) instanceof Player){
        // loop through the sprite array again
        for(int j = 0; j < game.sprites.size(); j++){
          // check if there's an enemy colliding with the player
          if(sprites.get(j) instanceof Bob && sprites.get(i).collide(sprites.get(j))){
            // updates enemies killed in current level
            lvlManager.currentLvl.iterateEnems(1); 
            // add the sprite to the delete queue
            pendDelete(sprites.get(j));
            hearts.loseHeart();
          }
        }
      }
      i++;
    }
    
  }
  
  void removeProjectiles(){
    for(Sprite s: sprites) {
      if(s instanceof Projectile){
        //the second Y and X numbers are the size of the play window
        //will handle larger/smaller windows universal later
        if(s.getY() <= 0 || s.getY() >= height  || s.getX() <= 0 || s.getX() >= width){
          pendDelete(s);
        }
      }
    }
  }
  
  void pendDelete(Sprite s){
    deleteQueue.add(s);
  }
  //creates a pendDelete for the UI components
  void pendDeleteUI(UIComponent c){
    deleteQueueUI.add(c);
  }  
  
  void delete(){
    for(Sprite s: deleteQueue){
      sprites.remove(s);
    }
    deleteQueue.clear();
  }
  //allows the UI to be deleted
  void deleteUI(){
    for(UIComponent c: deleteQueueUI){
      ui.remove(c);
    }
    deleteQueueUI.clear();
  }
}
