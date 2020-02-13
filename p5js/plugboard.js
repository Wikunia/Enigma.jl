class Plugboard {
    constructor(enigma, step_size) {
        this.width = 170;
        this.mapping = [...Array(26).keys()];
        this.right_idx = -1;
        this.left_idx_bw = -1;
        this.letter_box_size = 35;
        this.left = width-300;
        this.top = 60;
        this.bottom = this.top+this.letter_box_size*26;
        this.step_size = step_size;
        this.enigma = enigma;
    }
    show() {
        stroke(0);
        fill(200);
        let letter_box_size = this.letter_box_size;
        let left = this.left;
        let bottom = this.bottom;

        rect(left, this.top, this.width, letter_box_size*26);
        for (let i = 0; i < 26; i++) {
            this.enigma.plot_box_and_letter_right(left, this.width, bottom, letter_box_size, i, 0, false);
        }
        for (let i = 0; i < 26; i++) {
            this.enigma.plot_box_and_letter_left(left, bottom, letter_box_size, i, 0, false);
        }
        // right -
        for (let i = 0; i < 26; i++) {
            this.enigma.plot_right_minus(left, this.width, bottom, letter_box_size, i, 0, 0, false);
        }
        // left -
        for (let i = 0; i < 26; i++) {
            this.enigma.plot_left_minus(left, bottom, letter_box_size, i, 0, 0, false);
        }
        // connections
        for (let i = 0; i < 26; i++) {
            // right to left
            let i_y = bottom-letter_box_size*i-letter_box_size/2;
            let j = this.mapping[i];
            let j_y = bottom-letter_box_size*j-letter_box_size/2;
            line(left+this.width-5, i_y, left+5, j_y);
        }
    }

    set(str) {
        let parts = str.split(" ");
        for (let part of parts) {
            let i = part[0].charCodeAt(0)-65;
            let j = part[1].charCodeAt(0)-65;
            this.mapping[i] = j;
            this.mapping[j] = i;
        }
    }

    get_result(backwards) {
        if (!backwards) {
            return this.mapping[this.right_idx];
        } else {
            return this.mapping[this.left_idx_bw];
        }
    }

    update(min_t, t, backwards) {
        let letter_box_size = this.letter_box_size;
        let left = this.left;
        let bottom = this.bottom;
        let i = this.right_idx;
        let j = this.mapping[i];
        if (backwards) {
            j = this.left_idx_bw;
            i = this.mapping[j];
        }
        
        // right block + letter
        if ((!backwards && t >= min_t) || (backwards && t >= min_t+this.step_size)) {
            this.enigma.plot_box_and_letter_right(left, this.width, bottom, letter_box_size, i, 0, true);
            if (backwards && t == min_t+this.step_size) {
                console.log("output: "+this.get_result(true))
                secret += String.fromCharCode(this.get_result(true)+65);
            }
        }

        // left block + letter
        if ((!backwards && t >= min_t+this.step_size) || (backwards && t >= min_t)) {
            this.enigma.plot_box_and_letter_left(left, bottom, letter_box_size, j, 0, true);
        }
        // right -
        if ((!backwards && t >= min_t+1) || (backwards && t >= min_t+this.step_size-1)) {
            this.enigma.plot_right_minus(left, this.width, bottom, letter_box_size, i, 0, 0, true);
        }
        
        // left -
        if ((!backwards && t >= min_t+this.step_size-1) || (backwards && t >= min_t+1)) {
            this.enigma.plot_left_minus(left, bottom, letter_box_size, j, 0, 0, true);
        }
        

        // connection
        // right to left
        if (!backwards && t >= min_t) {
            let i_y = bottom-letter_box_size*i-letter_box_size/2;
            let j_y = bottom-letter_box_size*j-letter_box_size/2;
            let i_x = left+this.width-5;
            let j_x = left+5;
            let c_x = i_x+(j_x-i_x)*min(1, (t-min_t)/(this.step_size-2));
            let c_y = i_y+(j_y-i_y)*min(1, (t-min_t)/(this.step_size-2));
            stroke(255, 200, 0);
            strokeWeight(2);
            line(i_x, i_y, c_x, c_y);
            stroke(0);
            strokeWeight(1);
        } else if (t >= min_t + 1) {
            let j_y = bottom-letter_box_size*i-letter_box_size/2;
            let i_y = bottom-letter_box_size*j-letter_box_size/2;
            let j_x = left+this.width-5;
            let i_x = left+5;
            let c_x = i_x+(j_x-i_x)*min(1, (t-min_t)/(this.step_size-2));
            let c_y = i_y+(j_y-i_y)*min(1, (t-min_t)/(this.step_size-2));
            stroke(255, 200, 0);
            strokeWeight(2);
            line(i_x, i_y, c_x, c_y);
            stroke(0);
            strokeWeight(1);
        }
    }
}