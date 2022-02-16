import java.util.*;

class Game {
  
  // treat as public
  Player player;
  
  // treat as private
  UIManager ui = new UIManager();
  SpriteManager sprites = new SpriteManager();
  DungeonCoordinator dungeon = new DungeonCoordinator();
  
  PImage BG;
  boolean paused = false;   
  
  void config() {
    BG = loadImage("assets/background.png");
    BG.resize(width, height);
    background(BG);
    noStroke();
    rectMode(CENTER);
    imageMode(CENTER);
  }
  
  // sprite proxy
  void destroy(AbstractSprite target) {
    this.sprites.pendDelete(target);
  }
  
  
  // sprite proxy
  void spawn(AbstractSprite target) {
    this.sprites.spawn(target);
  }
  
  // ui proxy
  void hud(UIComponent component) {
    this.ui.hud.add(component); 
  }
  
  // setup
  void load() {
    config();
    dungeon.addSymbols();
    player = new Player(width/2, height-100, 50, 50, color(#17c3b2));
    sprites.spawn(player); 
    cursor(CROSS);
  }
  
  // draw
  void play() {
    background(BG);


    dungeon.coordinate();
    sprites.manage();
    ui.manage();
  }
  
  // keyPressed
  void keyDown() {
    this.player.setMovement(key, keyCode, true);
    this.ui.checkPause(key);    
  }
   
  // keyReleased
  void keyUp() {
    this.player.setMovement(key, keyCode, false);
  }
}
