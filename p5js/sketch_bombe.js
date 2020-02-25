let i = -1;
let running = false;
let enigma;
let letter;
let secret = "";
let guess = "";
let step_size = 10;
function setup() {
    createCanvas(1900, 1060);
    
    enigma = new Enigma(step_size);
    enigma.set_plugboard("WE AS QR ML PT VB XJ UG IO ZK");
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
      // typed += String.fromCharCode(letter+65)
    }

    if (i >= 0) {
      enigma.update(i);
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
    text("Secret: ", 10, 50)
    text("Guess: ", 10, 140)
    
    textSize(20);
    text(secret, 10, 80)
    text(guess, 10, 170)

    // console.log("Fps: ", fps.toFixed(2))
    // noLoop();
}