let i = -1;
let running = false;
let enigma;
let letter;
let secret = "ZVUGJCWRXVHQFQDGIBYKPDAWRKXDVL";
let guess = "WEATHERREPORT";
let step_size = 5;
let stop_before_plugboard = true;
let text_pos = 0;
let waiting_plugboard_input = false;
let plugboard_input_counter = 0;
let next_plugboard_input = "";

function setup() {
    createCanvas(1900, 1060);
    
    enigma = new Enigma(step_size);
    enigma.set_plugboard("");
    enigma.set_rotors(1, 3, 4);
    enigma.set_rotor_positions(10, 9, 8, based=1);
    enigma.set_ukw(3);
    letter = -1;
  }

  function mouseClicked() {
    if (running)
      return 
    let bottom = enigma.plugboard.bottom;
    let right = enigma.plugboard.left+enigma.plugboard.width;
    let diff_x = mouseX-right;
    let diff_y = bottom-mouseY;
    let letter_box_size = enigma.plugboard.letter_box_size
    if (diff_x >= 0 && diff_x <= letter_box_size) {
      if (diff_y >= 0 && diff_y <= 26*letter_box_size) {
        letter = Math.floor(diff_y / letter_box_size);
        stop_before_plugboard = true;
        running = true;
        i = 0;
      }
    }
  }
  
  function draw() {
    background(220);
    fill(0);

    enigma.show();
    if (letter != -1 && i == 0) {
      // last_step_size = step_size_slider.value();
      // enigma.change_step_size(step_size_slider.value());
      enigma.set_letter_idx(letter);
      text_pos += 1;
      // typed += String.fromCharCode(letter+65)
    }

    if (i >= 0) {
      running = enigma.update(i,stop=stop_before_plugboard);
    } 
    // console.log(i);
    if (running)
      i += 1;

    if (i == step_size*11+30) {
      running = false;
    }

    fps = frameRate();
    fill(0);
    textSize(30);
    text("Secret/Guess: ", 10, 30)
    
    textFont('monospace');
    textSize(28);
    text(secret, 10, 80);
    text(guess, 10, 110);
    if (checkWorkingGuess()) {
      mostUsedLetterBar();
    }

    stroke(255,100,0)
    strokeWeight(3)
    line(20+text_pos*16.8, 45, 20+text_pos*16.8, 55)
    strokeWeight(1)
    // console.log("Fps: ", fps.toFixed(2))
    //noLoop();

    fill(0)
    stroke(0)
    textSize(30);
    text("Plugboard: ", 10, 300)
    textSize(28);
    text(enigma.plugboard.setting_str.trim(), 10, 330);
}

function keyTyped() {
  if (waiting_plugboard_input) {
    key = key.toUpperCase();
    let idx = key.charCodeAt()-65;
    if (idx >= 0 && idx < 26) {
      plugboard_input_counter += 1;
      next_plugboard_input += key;
    }
  }
  if (waiting_plugboard_input && plugboard_input_counter == 2) {
    waiting_plugboard_input = false;
    enigma.set_plugboard(enigma.plugboard.setting_str + " " +next_plugboard_input);
    return
  }

  if (!waiting_plugboard_input) {
    if (key == 's') {
      guess = " "+guess;
    } else if (key == 'a') {
      guess = guess.replace(" ", "")
    } else if (key == 'r') { // reset lights
      i = -1;
      running = false;
    } else if (key == ' ') {
      stop_before_plugboard = false;
    } else if (key == 'n') {
      text_pos -= 1;
      enigma.step_rotors_bw();
    } else if (key == 'm') {
      text_pos += 1;
      enigma.step_rotors();
    } else if (key == 'p') {
      waiting_plugboard_input = true;
      next_plugboard_input = "";
      plugboard_input_counter = 0;
    } else if (key == 'z') { // total reset
      guess = guess.replace(/ /g, "")
      i = -1;
      running = false;
      letter = -1;
      if (text_pos > 0) {
        while (text_pos != 0) {
          enigma.step_rotors_bw();
          text_pos -= 1;
        }
      } else if (text_pos < 0) {
        while (text_pos != 0) {
          enigma.step_rotors();
          text_pos += 1;
        }
      }
      text_pos = 0;
      enigma.plugboard.set("");
    }
  }
}

function checkWorkingGuess() {
  let works = true;
  for (let i=0; i < guess.length; i++) {
    if (secret.charAt(i) != ' ' && guess.charAt(i) != ' ') {
      if (secret.charAt(i) == guess.charAt(i)) {
        works = false;
        // mark letters red
        noFill();
        strokeWeight(3);
        stroke(255, 0, 0);
        let letterWidth = 16.8;
        let letterHeight = 31;
        rect(10+letterWidth*i, 80-letterHeight+4, letterWidth, letterHeight);
        rect(10+letterWidth*i, 110-letterHeight+4, letterWidth, letterHeight);
      }
    }
  } 
  strokeWeight(1); 
  return works;
}

function mostUsedLetterBar() {
  let counter = Array(26).fill(0);
  for (let i=0; i < guess.length; i++) {
    if (secret.charAt(i) != ' ' && guess.charAt(i) != ' ') {
      let idx = secret.charCodeAt(i)-65;
      counter[idx] += 1;
      idx = guess.charCodeAt(i)-65;
      counter[idx] += 1;
    }
  }
  indexedCounter = counter.map(function(e,i){return {ind: i, val: e}});
  indexedCounter.sort(function(x, y){return x.val < y.val ? 1 : x.val == y.val ? 0 : -1});
  indices = indexedCounter.map(function(e){return e.ind});
  for (let i=0; i < 3; i++) {
    textFont('monospace');
    fill(0)
    textSize(25);
    text(String.fromCharCode(indices[i]+65), 10, 160+i*30);
    fill(0,200,0)
    rect(30, 160+i*30-25, 30*counter[indices[i]], 26)
    fill(0)
    textSize(20);
    text(str(counter[indices[i]]), 32, 160+i*30-3);
  }
}