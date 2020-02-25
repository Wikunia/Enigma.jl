class Rotor {
    constructor(enigma, order, nr, position, step_size) {
        this.enigma = enigma;
        this.step_size = step_size;
        this.width = 170;
        this.order = order;
        this.rev_order = [3,2,1][order-1];
        this.right_idx = -1;
        this.left_idx_bw = -1;
        this.set_position(position);
        this.mappings = [
            [5, 11, 13, 6, 12, 7, 4, 17, 22, 26, 14, 20, 15, 23, 25, 8, 24, 21, 19, 16, 1, 9, 2, 18, 3, 10],
            [1, 10, 4, 11, 19, 9, 18, 21, 24, 2, 12, 8, 23, 20, 13, 3, 17, 7, 26, 14, 16, 25, 6, 22, 15, 5],
            [2, 4, 6, 8, 10, 12, 3, 16, 18, 20, 24, 22, 26, 14, 25, 5, 9, 23, 7, 1, 11, 13, 21, 19, 17, 15],
            [5, 19, 15, 22, 16, 26, 10, 1, 25, 17, 21, 9, 18, 8, 24, 12, 14, 6, 20, 7, 11, 4, 3, 13, 23, 2],
            [22, 26, 2, 18, 7, 9, 20, 25, 21, 16, 19, 4, 14, 8, 12, 24, 1, 23, 13, 10, 17, 15, 6, 5, 3, 11]
        ];
        let rotor_names = ["I","II","III","IV","V"]
        this.name = "Rotor "+rotor_names[nr-1];

        this.rotation_points = [18, 6, 23, 11, 1];
        this.set_type(nr);
    
        this.letter_box_size = 35;
        this.left = width-300-this.rev_order*(80+this.width);
        this.top = 60;
        this.bottom = this.top+this.letter_box_size*26;
    }

    set_type(nr) {
        console.log("nr: ", nr)
        this.nr = nr;
        this.rotation_point = this.rotation_points[nr-1]-1;
        this.mapping = this.mappings[nr-1].map(i=>i-1);
        this.mapping_bw = this.get_backward_mapping();
    }

    set_position(position, based) {
        if(typeof based == undefined) {
            based = 0;  
        }
        if (based != 0) {
            position -= based;
        }
        this.position = position;
        this.last_position = position;
    }

    get_backward_mapping() {
        let backward_mp = Array.from({ length: 26 });
        for (let i = 0; i < 26; i++) {
            backward_mp[this.mapping[i]] = i;
        }
        return backward_mp
    }

    show() {
        let letter_box_size = this.letter_box_size;
        let left = this.left;
        let top = this.top;
        let bottom = this.bottom;
        textSize(30);
        stroke(0);
        fill(0);
        text(this.name, left+30, top-10);
        
        fill(200);
        rect(left, top, this.width, letter_box_size*26);
        for (let i = 0; i < 26; i++) {
            this.enigma.plot_box_and_letter_right(left, this.width, bottom, letter_box_size, i, this.position, false);
        }
        for (let i = 0; i < 26; i++) {
            this.enigma.plot_box_and_letter_left(left, bottom, letter_box_size, i, this.position, false);
        }
        // right -
        for (let i = 0; i < 26; i++) {
            this.enigma.plot_right_minus(left, this.width, bottom, letter_box_size, i, 0, this.position, false);
        }
        // left -
        for (let i = 0; i < 26; i++) {
            this.enigma.plot_left_minus(left, bottom, letter_box_size, i, 0, this.position, false);
        }

        // connections
        for (let i = 0; i < 26; i++) {
            // right to left
            let i_y = bottom-letter_box_size*i-letter_box_size/2;
            let letter_idx = i+this.position;
            letter_idx %= 26;
            let j = this.mapping[letter_idx];
            j = j-this.position+26;
            j %= 26;
            let j_y = bottom-letter_box_size*j-letter_box_size/2;
            line(left+this.width-5, i_y, left+5, j_y);
        }
    }

    get_result(backwards) {
        if (!backwards) {
            let letter_idx = this.right_idx+this.position;
            letter_idx %= 26;
            let out_letter = this.mapping[letter_idx];
            let result = out_letter-this.position+26;
            result %= 26;
            return result;
        } else {
            let letter_idx = this.left_idx_bw+this.position;
            letter_idx %= 26;
            let out_letter = this.mapping_bw[letter_idx];
            let result = out_letter-this.position+26;
            result %= 26;
            return result;
        }
    }

    rotate(min_t, t) {
        if (this.position == this.last_position)
            return
        if (t >= min_t + this.step_size)
            return

        let letter_box_size = this.letter_box_size;
        let left = this.left;
        let top = this.top;
        let bottom = this.bottom;
        
        // need to overwrite middle gray
        fill(200);
        let shifted = Math.round(this.letter_box_size*(t-min_t)/this.step_size)
        rect(left, top, this.width, letter_box_size*26+shifted);

        for (let i = 0; i < 26; i++) {
            this.enigma.plot_box_and_letter_right(left, this.width, bottom, letter_box_size, i, this.last_position, false, shifted);
        }
        for (let i = 0; i < 26; i++) {
            this.enigma.plot_box_and_letter_left(left, bottom, letter_box_size, i, this.last_position, false, shifted);
        }

        // right -
        for (let i = 0; i < 26; i++) {
            this.enigma.plot_right_minus(left, this.width, bottom, letter_box_size, i, shifted, this.position, false);
        }
        // left -
        for (let i = 0; i < 26; i++) {
            this.enigma.plot_left_minus(left, bottom, letter_box_size, i, shifted, this.position, false);
        }
    

        // connections
        for (let i = 0; i < 26; i++) {
            // right to left
            let i_y = bottom-letter_box_size*i-letter_box_size/2;
            let letter_idx = i+this.last_position;
            letter_idx %= 26;
            let j = this.mapping[letter_idx];
            j = j-this.last_position+26;
            j %= 26;
            let j_y = bottom-letter_box_size*j-letter_box_size/2;
            line(left+this.width-5, i_y+shifted, left+5, j_y+shifted);
        }
        copy(left-letter_box_size-1, bottom, this.width+2*(letter_box_size+1), shifted-1,
             left-letter_box_size-1, top, this.width+2*(letter_box_size+1), shifted-1)
        stroke(0)
        strokeWeight(1)
        line(left, bottom, left+this.width, bottom)

        // background at the bottom such that moving the rotor down is not visible
        fill(220);
        strokeWeight(0)
        rect(left-letter_box_size-1, bottom, this.width+2*(letter_box_size+1), letter_box_size);
        strokeWeight(1)
    }

    update(min_t, t, backwards) {
        let letter_box_size = this.letter_box_size;
        let left = this.left;
        let bottom = this.bottom;
        let i = this.right_idx;
        let letter_idx = i+this.position;
        letter_idx %= 26;
        let j = this.mapping[letter_idx];
        j = j-this.position+26;
        j %= 26;
        if (backwards) {
            j = this.left_idx_bw;
            letter_idx = j+this.position;
            letter_idx %= 26;
            i = this.mapping_bw[letter_idx];
            i = i-this.position+26;
            i %= 26;
        }
        
        // right block + letter
        if ((!backwards && t >= min_t) || (backwards && t >= min_t+this.step_size)) {
            this.enigma.plot_box_and_letter_right(left, this.width, bottom, letter_box_size, i, this.position, true);
        }

        // left block + letter
        if ((!backwards && t >= min_t+this.step_size) || (backwards && t >= min_t)) {
            this.enigma.plot_box_and_letter_left(left, bottom, letter_box_size, j, this.position, true);
        }
        // right -
        if ((!backwards && t >= min_t+1) || (backwards && t >= min_t+this.step_size-1)) {
            this.enigma.plot_right_minus(left, this.width, bottom, letter_box_size, i, 0, this.position, true);
        }
        
        // left -
        if ((!backwards && t >= min_t+this.step_size-1) || (backwards && t >= min_t+1)) {
            this.enigma.plot_left_minus(left, bottom, letter_box_size, j, 0, this.position, true);
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