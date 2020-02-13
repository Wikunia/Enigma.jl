let i = 0;
let enigma;
function setup() {
    createCanvas(1500, 800);
    let step_size = 30;
    enigma = new Enigma(step_size);
    enigma.set_plugboard("AB CD");
  }
  
  function draw() {
    background(220);
    if (i == 0) {
      enigma.set_letter_idx(1);
    }
    
    enigma.show();
    if (i <= 600) {
      enigma.update(i);
    } 
    // console.log(i);
    i += 1;

    if (i == 1000) {
      i = 0;
    }

    fps = frameRate();
    fill(0);
    textSize(30);
    text("Fps: "+fps.toFixed(0)+" i: "+i, 20, height-10)
    // console.log("Fps: ", fps.toFixed(2))
    // noLoop();
}