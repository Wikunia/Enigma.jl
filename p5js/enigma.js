class Enigma {
    constructor(step_size) {
        this.step_size = step_size;
        this.plugboard = new Plugboard(this, step_size);
        this.rotors = [];
        this.rotors.push(new Rotor(this, 1,1, 10, step_size));
        this.rotors.push(new Rotor(this, 2,2, 15, step_size));
        this.rotors.push(new Rotor(this, 3,3,  9, step_size));
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
        this.plugboard.right_idx = letter_idx;
        let next_idx = this.plugboard.get_result();
        for (let r=3; r >= 1; r--) {
            this.rotors[r-1].right_idx = next_idx;
            next_idx = this.rotors[r-1].get_result(false);
        }
        this.ukw.right_idx = next_idx;
        next_idx = this.ukw.get_result();
        for (let r=1; r <= 3; r++) {
            this.rotors[r-1].left_idx_bw = next_idx;
            next_idx = this.rotors[r-1].get_result(true);
        }
        this.plugboard.left_idx_bw = next_idx;
        next_idx = this.plugboard.get_result();

        console.log("Plug board right_idx: ", this.plugboard.right_idx)
        console.log("Plug board after: ", this.plugboard.get_result())
        for (let r=2; r >= 0; r--) {
            console.log("Rotor "+(r+1)+" right_idx: ", this.rotors[r].right_idx)
            console.log("after: ", this.rotors[r].get_result())
        }
        console.log("ukw board right_idx: ", this.ukw.right_idx)
        console.log("ukw board after: ", this.ukw.get_result())
        for (let r=0; r <= 2; r++) {
            console.log("Rotor "+(r+1)+" left_idx: ", this.rotors[r].left_idx_bw)
            console.log("after: ", this.rotors[r].get_result(true))
        }
        console.log("Plug board right_idx: ", this.plugboard.left_idx_bw)
        console.log("Plug board after: ", this.plugboard.get_result(true))
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
        let letter_idx = i+rotation;
        letter_idx %= 26;
        let letter = String.fromCharCode(65+letter_idx);
        text(letter, left-letter_box_size+7, bottom-letter_box_size*i-5);
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
        let letter_idx = i+rotation;
        letter_idx %= 26;
        let letter = String.fromCharCode(65+letter_idx);
        text(letter, left+c_width+7, bottom-letter_box_size*i-5);
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