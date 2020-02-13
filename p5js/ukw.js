class UKW {
    constructor(ukw) {
        this.width = 130;
        let mappings = [
            [5, 10, 13, 26, 1, 12, 25, 24, 22, 2, 23, 6, 3, 18, 17, 21, 15, 14, 20, 19, 16, 9, 11, 8, 7, 4],
            [25, 18, 21, 8, 17, 19, 12, 4, 16, 24, 14, 7, 15, 11, 13, 9, 5, 2, 6, 26, 3, 23, 22, 10, 1, 20],
            [6, 22, 16, 10, 9, 1, 15, 25, 5, 4, 18, 26, 24, 23, 7, 3, 20, 11, 21, 17, 19, 2, 14, 13, 8, 12]
        ];
        this.mapping = mappings[ukw-1];
    }
    show() {
        fill(200);
        let letter_box_size = 25;
        let left = width-300-4*(60+this.width);
        let top = 60;
        let bottom = top+letter_box_size*26;

        rect(left, top, this.width, letter_box_size*26);
        for (let i = 0; i < 26; i++) {
            fill(100);
            rect(left-letter_box_size, bottom-letter_box_size*(i+1), letter_box_size, letter_box_size);
            rect(left+this.width, bottom-letter_box_size*(i+1), letter_box_size, letter_box_size);
        }
        for (let i = 0; i < 26; i++) {
            textSize(15);
            fill(0);
            text(String.fromCharCode(65+i), left-letter_box_size+7, bottom-letter_box_size*i-5);
            text(String.fromCharCode(65+i), left+this.width+7, bottom-letter_box_size*i-5);
        }

        // right -
        for (let i = 0; i < 26; i++) {
            stroke(0);
            line(left+this.width-5, bottom-letter_box_size*i-letter_box_size/2+letter_box_size/4, left+this.width, bottom-letter_box_size*i-letter_box_size/2+letter_box_size/4);
            line(left+this.width-5, bottom-letter_box_size*i-letter_box_size/2-letter_box_size/4, left+this.width, bottom-letter_box_size*i-letter_box_size/2-letter_box_size/4);
        }
        // left -
        for (let i = 0; i < 26; i++) {
            stroke(0);
            line(left, bottom-letter_box_size*i-letter_box_size/2+letter_box_size/4, left+5, bottom-letter_box_size*i-letter_box_size/2+letter_box_size/4);
            line(left, bottom-letter_box_size*i-letter_box_size/2-letter_box_size/4, left+5, bottom-letter_box_size*i-letter_box_size/2-letter_box_size/4);
        }

        // connections
        for (let i = 0; i < 26; i++) {
            // right to left
            let i_y = bottom-letter_box_size*i-letter_box_size/2+letter_box_size/4;
            let j = this.mapping[i]-1;
            let j_y = bottom-letter_box_size*j-letter_box_size/2+letter_box_size/4;
            stroke(0);
            line(left+this.width-5, i_y, left+5, j_y);

            // left to right
            i_y = bottom-letter_box_size*i-letter_box_size/2-letter_box_size/4;
            stroke(0);
            line(left+this.width-5, i_y, left+5, i_y);
        }
    }
}