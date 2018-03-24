Player humanPlayer;//the player which the user (you) controls
Population pop; 
int speed = 100;
float globalMutationRate = 0.1;
PFont font;
int nextConnectionNo = 1000;

boolean showBest = true;//true if only show the best of the previous generation
boolean runBest = false; //true if replaying the best ever game
boolean humanPlaying = false; //true if the user is playing


boolean runThroughSpecies = false;
int upToSpecies = 0;
Player speciesChamp;

boolean showBrain = false;

boolean showBestEachGen = false;
int upToGen = 0;
Player genPlayerTemp;

//----------------------------------------------------------------------------------------------------------------------------------------
void setup() {//on startup
  size(1200, 675);

  humanPlayer = new Player();
  pop = new Population(300);// create new population of size 200
  frameRate(speed);
  font = loadFont("AgencyFB-Reg-48.vlw");
}
//------------------------------------------------------------------------------------------------------------------------------------------

void draw() {
  background(0); //deep space background

  if (showBrain) {
    background(255);
    //show the brain of whatever genome is currently shoeing
    if (runThroughSpecies) {
      speciesChamp.brain.drawGenome();
    } else
      if (runBest) {
        pop.bestPlayer.brain.drawGenome();
      } else
        if (humanPlaying) {
          showBrain = false;
        } else {
          pop.pop.get(0).brain.drawGenome();
        }
  } else
    if (showBestEachGen) {//show the best of each gen
      if (!genPlayerTemp.dead) {//if current gen player is not dead then update it
        genPlayerTemp.look();
        genPlayerTemp.think();
        genPlayerTemp.update();
        genPlayerTemp.show();
      } else {//if dead move on to the next generation
        upToGen ++;
        if (upToGen >= pop.genPlayers.size()) {//if at the end then return to the start and stop doing it
          upToGen= 0;
          showBestEachGen = false;
        } else {//if not at the end then get the next generation
          genPlayerTemp = pop.genPlayers.get(upToGen).clone();
          println(genPlayerTemp.bestScore);
        }
      }
    } else
      if (runThroughSpecies ) {//show all the species 
        if (!speciesChamp.dead) {//if best player is not dead
          speciesChamp.look();
          speciesChamp.think();
          speciesChamp.update();
          speciesChamp.show();
        } else {//once dead
          upToSpecies++;
          if (upToSpecies >= pop.species.size()) { 
            runThroughSpecies = false;
          } else {
            speciesChamp = pop.species.get(upToSpecies).champ.cloneForReplay();
          }
        }
     } else {
        if (humanPlaying) {//if the user is controling the ship[
          if (!humanPlayer.dead) {//if the player isnt dead then move and show the player based on input
            humanPlayer.look();
            humanPlayer.update();
            humanPlayer.show();
            println(humanPlayer.vision[1]);
          } else {//once done return to ai
            humanPlaying = false;
          }
        } else 
        if (runBest) {// if replaying the best ever game
          if (!pop.bestPlayer.dead) {//if best player is not dead
            pop.bestPlayer.look();
            pop.bestPlayer.think();
            pop.bestPlayer.update();
            pop.bestPlayer.show();
          } else {//once dead
            runBest = false;//stop replaying it
            pop.bestPlayer = pop.bestPlayer.cloneForReplay();//reset the best player so it can play again
          }
        } else {//if just evolving normally
          if (!pop.done()) {//if any players are alive then update them
            pop.updateAlive();
          } else {//all dead
            //genetic algorithm 
            pop.naturalSelection();
          }
        }
      }
  showScore();//display the score
}
//------------------------------------------------------------------------------------------------------------------------------------------

void keyPressed() {
  switch(key) {
  case ' ':
    if (humanPlaying) {//if the user is controlling a ship shoot
      humanPlayer.shoot();
    } else {//if not toggle showBest
      showBest = !showBest;
    }
    break;
  case 'p'://play
    humanPlaying = !humanPlaying;
    humanPlayer = new Player();
    break;  
  case '+'://speed up frame rate
    speed += 10;
    frameRate(speed);
    println(speed);

    break;
  case '-'://slow down frame rate
    if (speed > 10) {
      speed -= 10;
      frameRate(speed);
      println(speed);
    }
    break;
  case 'h'://halve the mutation rate
    globalMutationRate /=2;
    println(globalMutationRate);
    break;
  case 'd'://double the mutation rate
    globalMutationRate *= 2;
    println(globalMutationRate);
    break;
  case 'b'://run the best
    runBest = true;
    break;
  case 's':
    runThroughSpecies = !runThroughSpecies;
    upToSpecies = 0;
    speciesChamp = pop.species.get(upToSpecies).champ.cloneForReplay();
    break;
  case 'g'://show genome
    showBestEachGen = !showBestEachGen;
    upToGen = 0;
    genPlayerTemp = pop.genPlayers.get(upToGen).clone();
    break;
  case 'n':
    showBrain = !showBrain;
    break;
  }

  //player controls
  if (key == CODED) {
    if (keyCode == UP) {
      humanPlayer.boosting = true;
    }
    if (keyCode == LEFT) {
      humanPlayer.spin = -0.08;
    } else if (keyCode == RIGHT) {
      if (runThroughSpecies) {
        upToSpecies++;
        if (upToSpecies >= pop.species.size()) {
          runThroughSpecies = false;
        } else {
          speciesChamp = pop.species.get(upToSpecies).champ.cloneForReplay();
        }
      } else 
      if (showBestEachGen) {
        upToGen++;
          if (upToGen >= pop.gen) {
          showBestEachGen = false;
        } else {
          genPlayerTemp = pop.genPlayers.get(upToGen).cloneForReplay();
        }
      } else {
        humanPlayer.spin = 0.08;
      }
    }
  }
}

//----------------------------------------------------------------------------------------------------------------------------------------
void keyReleased() {
  //once key released
  if (key == CODED) {
    if (keyCode == UP) {//stop boosting
      humanPlayer.boosting = false;
    }
    if (keyCode == LEFT) {// stop turning
      humanPlayer.spin = 0;
    } else if (keyCode == RIGHT) {
      humanPlayer.spin = 0;
    }
  }
}

//------------------------------------------------------------------------------------------------------------------------------------------
//function which returns whether a vector is out of the play area
boolean isOut(PVector pos) {
  if (pos.x < -50 || pos.y < -50 || pos.x > width+ 50 || pos.y > 50+height) {
    return true;
  }
  return false;
}

//------------------------------------------------------------------------------------------------------------------------------------------
//shows the score and the generation on the screen
void showScore() {
  if (showBestEachGen) {
    textFont(font);
    fill(255);
    textAlign(LEFT);
    text("Score: " + genPlayerTemp.score, 80, 60);
    text("Gen: " + (upToGen +1), width-250, 60);
  } else
    if (runThroughSpecies) {
      textFont(font);
      fill(255);
      textAlign(LEFT);
      text("Score: " + speciesChamp.score, 80, 60);
      text("Species: " + (upToSpecies +1), width-250, 60);
    } else
      if (humanPlaying) {
        textFont(font);
        fill(255);
        textAlign(LEFT);
        text("Score: " + humanPlayer.score, 80, 60);
      } else
        if (runBest) {
          textFont(font);
          fill(255);
          textAlign(LEFT);
          text("Score: " + pop.bestPlayer.score, 80, 60);
          text("Gen: " + pop.gen, width-200, 60);
        } else {
          if (showBest) {
            textFont(font);
            fill(255);
            textAlign(LEFT);
            text("Score: " + pop.pop.get(0).score, 80, 60);
            text("Gen: " + pop.gen, width-200, 60);
          }
        }
}