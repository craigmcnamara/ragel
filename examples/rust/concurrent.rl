/*
 * Show off concurrent abilities.
 */

%%{
    machine concurrent;

    action next_char {
        self.cur_char += 1;
    }

    action start_word {
        self.start_word = self.cur_char;
    }
    action end_word {
        io::println(#fmt("word: %i %i", self.start_word, self.cur_char - 1));
    }

    action start_comment {
        self.start_comment = self.cur_char;
    }
    action end_comment {
        io::println(#fmt("comment: %i %i", self.start_comment,
                         self.cur_char - 1));
    }

    action start_literal {
        self.start_literal = self.cur_char;
    }
    action end_literal {
        io::println(#fmt("literal: %i %i", self.start_literal,
                         self.cur_char - 1));
    }

    # Count characters.
    chars = ( any @next_char )*;

    # Words are non-whitespace. 
    word = ( any-space )+ >start_word %end_word;
    words = ( ( word | space ) $1 %0 )*;

    # Finds C style comments. 
    comment = ( '/*' any* :>> '*/' ) >start_comment %end_comment;
    comments = ( comment | any )**;

    # Finds single quoted strings. 
    literal_char = ( any - ['\\] ) | ( '\\' . any );
    literal = ('\'' literal_char* '\'' ) >start_literal %end_literal;
    literals = ( ( literal | (any-'\'') ) $1 %0 )*;

    main := chars | words | comments | literals;
}%%

%% write data;

const BUFSIZE: uint = 2048u;

class concurrent {
    let mut cur_char: int;
    let mut start_word: int;
    let mut start_comment: int;
    let mut start_literal: int;

    let mut cs: int;

    new() {
        let mut cs: int;
        %% write init;
        self.cs = cs;
        self.cur_char = 0;
        self.start_word = 0;
        self.start_comment = 0;
        self.start_literal = 0;
    }

    fn execute(data: ~[const u8], len: uint, is_eof: bool) -> int {
        let mut p = 0;
        let pe = len;
        let eof = if is_eof { pe } else { 0 };

        let mut cs = self.cs;

        %% write exec;

        self.cs = cs;

        self.finish()
    }

    fn finish() -> int {
        if self.cs == concurrent_error {
            -1
        } else if self.cs >= concurrent_first_final {
            1
        } else {
            0
        }
    }
}

fn main() {
    let mut buf = vec::to_mut(vec::from_elem(BUFSIZE, 0));

    let concurrent = concurrent();

    loop {
        let len = io::stdin().read(buf, BUFSIZE);
        concurrent.execute(buf, len, len != BUFSIZE);
        if len != BUFSIZE {
            break;
        }
    }

    if concurrent.finish() <= 0 {
        io::stderr().write_line("concurrent: error parsing input");
    }
}
