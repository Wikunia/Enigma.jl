class Enigma {
    constructor(step_size) {
        this.step_size = step_size;
        this.plugboard = new Plugboard(this, step_size);
        this.rotors = [];
        this.rotors.push(new Rotor(this, 1,1, step_size));
        this.rotors.push(new Rotor(this, 2,2, step_size));
        this.rotors.push(new Rotor(this, 3,3, step_size));
        this.ukw = new UKW(this, 1, step_size*2);
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
        this.ukw.update(step, t);
        step += 2*this.step_size;
        for (let r=1; r <= 3; r++) {
            this.rotors[r-1].update(step, t, true);
            step += this.step_size;
        }
        this.plugboard.update(step, t, true);
    }

    set_letter_idx(letter_idx) {
        this.plugboard.letter = letter_idx;
        let next_idx = this.plugboard.get_result();
        for (let r=3; r >= 1; r--) {
            this.rotors[r-1].letter = next_idx;
            next_idx = this.rotors[r-1].get_result(false);
        }
        this.ukw.letter = next_idx;
        next_idx = this.ukw.get_result();
        for (let r=1; r <= 3; r++) {
            this.rotors[r-1].letter_bw = next_idx;
            next_idx = this.rotors[r-1].get_result(true);
        }
        this.plugboard.letter_bw = next_idx;
        next_idx = this.plugboard.get_result();
    }


    // plotting functions for children
    plot_box_and_letter_left(left, bottom, letter_box_size, i, rotation, mark) {
        if (mark) {
            fill(255,200,0);
        } else {
            fill(100);
        }
        stroke(0);
        strokeWeight(1);
        rect(left-letter_box_size, bottom-letter_box_size*(i+1), letter_box_size, letter_box_size);
        fill(0);
        textSize(15);
        text(String.fromCharCode(65+i), left-letter_box_size+7, bottom-letter_box_size*i-5);
    }

    plot_box_and_letter_right(left, c_width, bottom, letter_box_size, i, rotation, mark) {
        if (mark) {
            fill(255,200,0);
        } else {
            fill(100);
        }
        stroke(0);
        strokeWeight(1);
        rect(left+c_width, bottom-letter_box_size*(i+1), letter_box_size, letter_box_size);
        fill(0);
        textSize(15);
        text(String.fromCharCode(65+i), left+c_width+7, bottom-letter_box_size*i-5);
    }

    plot_right_minus(left, width, bottom, letter_box_size, i, shifted, rotation, mark) {
        if (mark) {
            stroke(255,200,0);
        } else {
            stroke(0);
        }
        line(left+width-5, bottom-letter_box_size*i-letter_box_size/2+shifted, left+width, bottom-letter_box_size*i-letter_box_size/2+shifted);
    }

    plot_left_minus(left, bottom, letter_box_size, i, shifted, rotation, mark) {
        if (mark) {
            stroke(255,200,0);
        } else {
            stroke(0);
        }
        line(left, bottom-letter_box_size*i-letter_box_size/2+shifted, left+5, bottom-letter_box_size*i-letter_box_size/2+shifted);
    }
}