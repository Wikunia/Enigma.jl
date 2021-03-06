class Enigma {
    constructor(step_size) {
        this.step_size = step_size;
        this.plugboard = new Plugboard(this, step_size);
        this.rotors = [];
        this.rotors.push(new Rotor(this, 1,1, 1, step_size));
        this.rotors.push(new Rotor(this, 2,2, 1, step_size));
        this.rotors.push(new Rotor(this, 3,3, 1, step_size));
        this.ukw = new UKW(this, 1, step_size);
    }
    show() {
        this.plugboard.show();
        for (let i=0; i < 3; i++) {
            this.rotors[i].show();
        }
        this.ukw.show();
    }

    set_rotors(a,b,c) {
        this.rotors[0].set_type(a);
        this.rotors[1].set_type(b);
        this.rotors[2].set_type(c);
    }

    set_rotor_positions(a,b,c, based=0) {
        this.rotors[0].set_position(a, based);
        this.rotors[1].set_position(b, based);
        this.rotors[2].set_position(c, based);
    }

    set_ukw(ukw) {
        this.ukw.set_type(ukw);
    }

    set_plugboard(str) {
        this.plugboard.set(str);
    }

    change_step_size(val) {
        this.step_size = val;
        this.plugboard.step_size = val;
        for (let r = 0; r < 3; r++) {
            this.rotors[r].step_size = val;
        }
        this.ukw.step_size = val*2;
    }

    update(t, stop=false) {
        let step = 0
        for (let r=0; r <= 2; r++) {
            this.rotors[r].rotate(step, t);
        }
        step += this.step_size+10;
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
        if (!stop) {
            this.plugboard.update(step, t, true);
        } 
        if (stop && t >= step) {
            return false;
        }
        return true;
    }

    step_rotors() {
        //  right most rotor
        for (let r=0; r <= 2; r++) {
            this.rotors[r].last_position = this.rotors[r].position;
        }

        this.rotors[2].position += 1
        this.rotors[2].position == 26 && (this.rotors[2].position = 0)
        if (this.rotors[2].position == this.rotors[2].rotation_point) {
            this.rotors[1].position += 1
            this.rotors[1].position == 26 && (this.rotors[1].position = 0)
            if (this.rotors[1].position == this.rotors[1].rotation_point) {
                this.rotors[0].position += 1
                this.rotors[0].position == 26 && (this.rotors[0].position = 1)
            }
        } else if (this.rotors[1].position+1 == this.rotors[1].rotation_point) {
            this.rotors[1].position += 1
            this.rotors[1].position == 26 && (this.rotors[1].position = 0)
            this.rotors[0].position += 1
            this.rotors[0].position == 26 && (this.rotors[0].position = 0)
        }
    }

    step_rotors_bw() {
        //  right most rotor
        for (let r=0; r <= 2; r++) {
            this.rotors[r].last_position = this.rotors[r].position;
        }

        if (this.rotors[2].position == this.rotors[2].rotation_point) {
            if (this.rotors[1].position == this.rotors[1].rotation_point) {
                this.rotors[0].position -= 1
                this.rotors[0].position == -1 && (this.rotors[0].position = 25)
            }
            this.rotors[1].position -= 1
            this.rotors[1].position == -1 && (this.rotors[1].position = 25)   
        } else if (this.rotors[1].position+1 == this.rotors[1].rotation_point) { // probably wrong (untested!)
            this.rotors[1].position -= 1
            this.rotors[1].position == -1 && (this.rotors[1].position = 25)
            this.rotors[0].position -= 1
            this.rotors[0].position == -1 && (this.rotors[0].position = 25)
        }
        this.rotors[2].position -= 1
        this.rotors[2].position == -1 && (this.rotors[2].position = 25)
    }

    set_letter_idx(letter_idx) {
        this.step_rotors();
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
    }


    // plotting functions for children
    plot_box_and_letter_left(left, bottom, letter_box_size, i, rotation, mark, shifted=0) {
        if (mark) {
            fill(255,200,0);
        } else {
            fill(100);
        }
        stroke(0);
        strokeWeight(1);
        rect(left-letter_box_size, bottom-letter_box_size*(i+1)+shifted, letter_box_size, letter_box_size);
        fill(0);
        textSize(15);
        let letter_idx = i+rotation;
        letter_idx %= 26;
        let letter = String.fromCharCode(65+letter_idx);
        text(letter, left-letter_box_size+10, bottom-letter_box_size*i-10+shifted);
    }

    plot_box_and_letter_right(left, c_width, bottom, letter_box_size, i, rotation, mark, shifted=0) {
        if (mark) {
            fill(255,200,0);
        } else {
            fill(100);
        }
        stroke(0);
        strokeWeight(1);
        rect(left+c_width, bottom-letter_box_size*(i+1)+shifted, letter_box_size, letter_box_size);
        fill(0);
        textSize(15);
        let letter_idx = i+rotation;
        letter_idx %= 26;
        let letter = String.fromCharCode(65+letter_idx);
        text(letter, left+c_width+10, bottom-letter_box_size*i-10+shifted);
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