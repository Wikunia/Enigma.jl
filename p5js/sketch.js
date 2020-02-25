let i = -1;
let running = false;
let rotate = false;
let enigma;
let letter;
let typed = "";
let secret = "";
let step_size_slider;
let last_step_size = 10;
function setup() {
    createCanvas(1900, 1060);
    step_size_slider = createSlider(5, 60, 30);
    step_size_slider.position(20, 240);
    step_size_slider.style('width', '180px');
    last_step_size = step_size_slider.value();
    
    enigma = new Enigma(step_size_slider.value());
    enigma.set_rotors(1, 3, 4);
    enigma.set_rotor_positions(10, 9, 8, based=1);
    enigma.set_ukw(3);
    enigma.set_plugboard("AL CX DP FU GO HI JN MY VQ RW");
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
        return
      }
    }
    if (mouseX >= step_size_slider.position().x+180) {
      rotate = true;
      running = true;
      i = 0;
    }
  }
  
  function draw() {
    background(220);
    fill(0);
    // Slider
    textSize(30)
    text("Step size: ", 10, 220)
    rect(10, 235, 190, 20);
    enigma.show();
    // enigma.plot_box_and_letter_left()
    if (i == 0) {
      last_step_size = step_size_slider.value();
      enigma.change_step_size(step_size_slider.value());
      if (!rotate){
        enigma.set_letter_idx(letter);
        typed += String.fromCharCode(letter+65)
     }
    }

    if (letter == -1 && rotate) {
      if (i == 0) {
        enigma.step_rotors();
      }
      for (let r=0; r <= 2; r++) {
        enigma.rotors[r].rotate(0, i);
      }
      if (i == last_step_size) {
        running = false;
        rotate = false;
      }
    }

    if (i >= 0 && letter != -1) {
      enigma.update(i);
    } 
    // console.log(i);
    if (running)
      i += 1;

    if (i == last_step_size*11+30) {
      running = false;
    }

    fps = frameRate();
    fill(0);
    textSize(30);
    text("Typed: ", 10, 50)
    text("Secret: ", 10, 140)
    
    textSize(20);
    text(typed, 10, 80)
    text(secret, 10, 170)


    // console.log("Fps: ", fps.toFixed(2))
    // noLoop();
}