class Enigma {
    constructor(step_size) {
        this.step_size = step_size;
        this.plugboard = new Plugboard(this, step_size);
        this.rotors = [];
        this.rotors.push(new Rotor(this, 1,1));
        this.rotors.push(new Rotor(this, 2,2));
        this.rotors.push(new Rotor(this, 3,3));
        this.ukw = new UKW(1);
    }
    show() {
        this.plugboard.show();
        for (let i=0; i < 3; i++) {
            this.rotors[i].show();
        }
        this.ukw.show();
    }

    set_plugboard(str) {
        this.plugboard.set(str);
    }

    update(t) {
        let step = 0
        this.plugboard.update(step, t, false);
        step += this.step_size;
        for (let r=3; r >= 1; r--) {
            this.rotors[r-1].update(step, t, false);
            step += this.step_size;
        }
    }


    // plotting functions for children
    plot_box_and_letter_left(left, bottom, letter_box_size, i, rotation, mark) {
        if (mark) {
            fill(255,200,0);
        } else {
            fill(100);
        }
        // fill(100);
        rect(left-letter_box_size, bottom-letter_box_size*(i+1), letter_box_size, letter_box_size);
        fill(0);
        textSize(15);
        text(String.fromCharCode(65+i), left-letter_box_size+7, bottom-letter_box_size*i-5);
    }

    plot_box_and_letter_right(left, width, bottom, letter_box_size, i, rotation, mark) {
        if (mark) {
            fill(255,200,0);
        } else {
            fill(100);
        }
        rect(left+width, bottom-letter_box_size*(i+1), letter_box_size, letter_box_size);
        fill(0);
        textSize(15);
        text(String.fromCharCode(65+i), left+width+7, bottom-letter_box_size*i-5);
    }

    plot_right_minus(left, width, bottom, letter_box_size, i, rotation, mark) {
        if (mark) {
            stroke(255,200,0);
        } else {
            stroke(0);
        }
        line(left+width-5, bottom-letter_box_size*i-letter_box_size/2, left+width, bottom-letter_box_size*i-letter_box_size/2);
    }

    plot_left_minus(left, bottom, letter_box_size, i, rotation, mark) {
        if (mark) {
            stroke(255,200,0);
        } else {
            stroke(0);
        }
        line(left, bottom-letter_box_size*i-letter_box_size/2, left+5, bottom-letter_box_size*i-letter_box_size/2);
    }
}