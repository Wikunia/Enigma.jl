class UKW {
    constructor(enigma, ukw, step_size) {
        this.enigma = enigma;
        this.step_size = step_size*2;
        this.width = 170;
        this.right_idx = -1;
        this.mappings = [
            [5, 10, 13, 26, 1, 12, 25, 24, 22, 2, 23, 6, 3, 18, 17, 21, 15, 14, 20, 19, 16, 9, 11, 8, 7, 4],
            [25, 18, 21, 8, 17, 19, 12, 4, 16, 24, 14, 7, 15, 11, 13, 9, 5, 2, 6, 26, 3, 23, 22, 10, 1, 20],
            [6, 22, 16, 10, 9, 1, 15, 25, 5, 4, 18, 26, 24, 23, 7, 3, 20, 11, 21, 17, 19, 2, 14, 13, 8, 12]
        ];
        this.set_type(ukw);
        this.letter_box_size = 35;
        this.left = width-300-4*(80+this.width);
        this.top = 60;
        this.bottom = this.top+this.letter_box_size*26;
        let names = ["A", "B", "C"]
        this.name = "UKW "+names[ukw-1];
    }
    show() {
        let letter_box_size = this.letter_box_size;
        let left = this.left;
        let top = this.top;
        let bottom = this.bottom;
        let i = this.right_idx;
        let j = this.mapping[i];
        
        textSize(30);
        stroke(0);
        fill(0);
        text(this.name, left+30, top-10);

        fill(200);
        rect(left, top, this.width, letter_box_size*26);
        for (let i = 0; i < 26; i++) {
            this.enigma.plot_box_and_letter_right(left, this.width, bottom, letter_box_size, i, 0, false);
        }
        for (let i = 0; i < 26; i++) {
            this.enigma.plot_box_and_letter_left(left, bottom, letter_box_size, i, 0, false);
        }

        // right -
        for (let i = 0; i < 26; i++) {
            this.enigma.plot_right_minus(left, this.width, bottom, letter_box_size, i, letter_box_size/4, 0, false);
            this.enigma.plot_right_minus(left, this.width, bottom, letter_box_size, i, -letter_box_size/4, 0, false);
        }
        // left -
        for (let i = 0; i < 26; i++) {
            this.enigma.plot_left_minus(left, bottom, letter_box_size, i, letter_box_size/4, 0, false);
            this.enigma.plot_left_minus(left, bottom, letter_box_size, i, -letter_box_size/4, 0, false);
        }

        // connections
        for (let i = 0; i < 26; i++) {
            // right to left
            let i_y = bottom-letter_box_size*i-letter_box_size/2+letter_box_size/4;
            let j = this.mapping[i];
            let j_y = bottom-letter_box_size*j-letter_box_size/2+letter_box_size/4;
            stroke(0);
            line(left+this.width-5, i_y, left+5, j_y);

            // left to right
            i_y = bottom-letter_box_size*i-letter_box_size/2-letter_box_size/4;
            stroke(0);
            line(left+this.width-5, i_y, left+5, i_y);
        }
    }

    set_type(ukw) {
        this.mapping = this.mappings[ukw-1].map(i=>i-1);
    }

    get_result() {
        return this.mapping[this.right_idx];
    }

    update(min_t, t) {
        let letter_box_size = this.letter_box_size;
        let left = this.left;
        let bottom = this.bottom;
        let i = this.right_idx;
        let j = this.mapping[i];
        let half_step = this.step_size/2;
        
        // right block + letter under
        if (t >= min_t) {
            this.enigma.plot_box_and_letter_right(left, this.width, bottom, letter_box_size, i, 0, true);
        }

        if (t >= min_t+this.step_size) {
            this.enigma.plot_box_and_letter_right(left, this.width, bottom, letter_box_size, j, 0, true);
        }

        // left block + letter
        if (t >= min_t+half_step) {
            this.enigma.plot_box_and_letter_left(left, bottom, letter_box_size, j, 0, true);
        }
        // right -
        if ((t >= min_t+1)) {
            this.enigma.plot_right_minus(left, this.width, bottom, letter_box_size, i, letter_box_size/4, 0, true);
        }
        
        // left -
        if (t >= min_t+half_step-1) {
            this.enigma.plot_left_minus(left, bottom, letter_box_size, j, letter_box_size/4, 0, true);
        }
        
        // upper
        // right -
        if ((t >= min_t+this.step_size+1)) {
            this.enigma.plot_right_minus(left, this.width, bottom, letter_box_size, j, -letter_box_size/4, 0, true);
        }
        
        // left -
        if (t >= min_t+half_step+1) {
            this.enigma.plot_left_minus(left, bottom, letter_box_size, j, -letter_box_size/4, 0, true);
        }

        if (t >= min_t) {
            let i_y = bottom-letter_box_size*i-letter_box_size/2+letter_box_size/4;
            let j_y = bottom-letter_box_size*j-letter_box_size/2+letter_box_size/4;
            let i_x = left+this.width-5;
            let j_x = left+5;
            let c_x = i_x+(j_x-i_x)*min(1, (t-min_t)/(half_step-2));
            let c_y = i_y+(j_y-i_y)*min(1, (t-min_t)/(half_step-2));
            stroke(255, 200, 0);
            strokeWeight(2);
            line(i_x, i_y, c_x, c_y);
            stroke(0);
            strokeWeight(1);
        }

        if (t >= min_t+half_step) {
            let i_y = bottom-letter_box_size*j-letter_box_size/2-letter_box_size/4;
            let j_y = bottom-letter_box_size*j-letter_box_size/2-letter_box_size/4;
            let j_x = left+this.width-5;
            let i_x = left+5;
            let c_x = i_x+(j_x-i_x)*min(1, (t-min_t-half_step)/(half_step-2));
            let c_y = i_y+(j_y-i_y)*min(1, (t-min_t-half_step)/(half_step-2));
            stroke(255, 200, 0);
            strokeWeight(2);
            line(i_x, i_y, c_x, c_y);
            stroke(0);
            strokeWeight(1);
        }
    }
}