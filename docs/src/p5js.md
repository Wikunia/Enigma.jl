# Visualization and Animation using p5js

I used [p5js](https://p5js.org/) in my videos explaining the Enigma and the Bombe.
If you want to play around with it as well please follow these instructions.

The `html` and `js` files are all in the `p5js` folder. 
I have two main `html` files namely `index.html` for the Enigma Video and `bombe.html` for visualizing how to crack the Enigma.

## Enigma

The main javascript file for the Enigma is `sketch.js`.
You should probably be able to use this out of the box if you watched the video.
[Enigma: Endless possibilities is not enough](https://youtu.be/4cf7dc_8u44)

- Click right off the slider area for making a rotor step.
- The slider decides the number of frames for each encoding step so left most setting is the fastest. 
- You can click on a letter (on the right side of the plugboard) to make an input

The settings itself are part of `sketch.js` where you can set the settings of the Enigma. 

## Bombe

The main javascript file for the Bombe is `sketch_bombe.js`. In the video you can't see all the keys I press to change the visualization:

- `s` move the guess to the right
- `a` move the guess to the left
- `r` switch off the yellow lights (to start a new input)
- ` ` If you click on a letter on the plugboard (right hand side)
  - it stops before it enters the plugboard in the reverse direction such that you can change the plugboard setting right before
  - With ` ` you continue the encoding
- `n` move the orange indicator to the left (make a backward rotor step)
- `m` move the orange indicator to the right (make a rotor step)
- `p` enter a plugboard setting. First press `p` and then two letters you want to connect
- `z` reset the whole Bombe

