class Rotor {
    constructor(enigma, order, rotor_nr, step_size) {
        this.enigma = enigma;
        this.step_size = step_size;
        this.width = 130;
        this.order = order;
        this.rev_order = [3,2,1][order-1];
        this.rotor_nr = rotor_nr;
        this.letter = -1;
        this.letter_bw = -1;
        let mappings = [
            [5, 11, 13, 6, 12, 7, 4, 17, 22, 26, 14, 20, 15, 23, 25, 8, 24, 21, 19, 16, 1, 9, 2, 18, 3, 10],
            [1, 10, 4, 11, 19, 9, 18, 21, 24, 2, 12, 8, 23, 20, 13, 3, 17, 7, 26, 14, 16, 25, 6, 22, 15, 5],
            [2, 4, 6, 8, 10, 12, 3, 16, 18, 20, 24, 22, 26, 14, 25, 5, 9, 23, 7, 1, 11, 13, 21, 19, 17, 15],
            [5, 19, 15, 22, 16, 26, 10, 1, 25, 17, 21, 9, 18, 8, 24, 12, 14, 6, 20, 7, 11, 4, 3, 13, 23, 2],
            [22, 26, 2, 18, 7, 9, 20, 25, 21, 16, 19, 4, 14, 8, 12, 24, 1, 23, 13, 10, 17, 15, 6, 5, 3, 11]
        ];
        this.mapping = mappings[this.rotor_nr-1];
        this.mapping_bw = this.get_backward_mapping();

        this.letter_box_size = 25;
        this.left = width-300-this.rev_order*(60+this.width);
        this.top = 60;
        this.bottom = this.top+this.letter_box_size*26;
    }

    get_backward_mapping() {
        let backward_mp = Array.from({ length: 26 });
        for (let i = 1; i <= 26; i++) {
            backward_mp[this.mapping[i-1]-1] = i;
        }
        return backward_mp
    }

    show() {
        fill(200);
        let letter_box_size = this.letter_box_size;
        let left = this.left;
        let top = this.top;
        let bottom = this.bottom;

        rect(left, top, this.width, letter_box_size*26);
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
            let j = this.mapping[i]-1;
            let j_y = bottom-letter_box_size*j-letter_box_size/2;
            line(left+this.width-5, i_y, left+5, j_y);
        }
    }

    get_result(backwards) {
        if (!backwards) {
            return this.mapping[this.letter-1];
        } else {
            return this.mapping_bw[this.letter_bw-1];
        }
    }

    update(min_t, t, backwards) {
        let letter_box_size = this.letter_box_size;
        let left = this.left;
        let bottom = this.bottom;
        let i = this.letter -1;
        let j = this.mapping[i]-1;
        if (backwards) {
            j = this.letter_bw - 1;
            i = this.mapping_bw[j]-1;
        }
        
        // right block + letter
        if ((!backwards && t >= min_t) || (backwards && t >= min_t+this.step_size)) {
            this.enigma.plot_box_and_letter_right(left, this.width, bottom, letter_box_size, i, 0, true);
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
        } else if(backwards && t >= min_t) {
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