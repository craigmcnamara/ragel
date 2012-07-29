%%{
    machine scanner;

    # Warning: changing the patterns or the input string will affect the
    # coverage of the scanner action types.
    main := |*
        'a' => { 
            io::print("on last     ");
            if p + 1 == te {
                on_last = cnt;
                cnt += 1;
                io::print("yes");
            }
            io::print("\n");
        };

        'b'+ => {
            io::print("on next     ");
            if p + 1 == te {
                on_next = cnt;
                cnt += 1;
                io::print("yes");
            }
            io::print("\n");
        };

        'c1' 'dxxx'? => {
            io::print("on lag      ");
            if p + 1 == te {
                on_lag = cnt;
                cnt += 1;
                io::print("yes"); 
            }
            io::print("\n");
        };

        'd1' => {
            io::print("lm switch1  ");
            if p + 1 == te {
                sw1 = cnt;
                cnt += 1;
                io::print("yes");
            }
            io::print("\n");
        };
        'd2' => {
            io::print("lm switch2  ");
            if p + 1 == te {
                sw2 = cnt;
                cnt += 1;
                io::print("yes");
            }
            io::print("\n");
        };

        [d0-9]+ '.';

        '\n';
    *|;

  write data;
}%%

fn main() {
    let mut ts = 0;
    let mut te = 0;
    let mut act = 0;

    let data = "abbc1d1d2\n";
    let mut cs = 0;
    let mut p = 0;
    let mut pe = data.len();
    let mut eof = pe;

    %% write init;

    let mut on_last = 0;
    let mut on_next = 0;
    let mut on_lag = 0;

    let mut sw1 = 0;
    let mut sw2 = 0;
    let mut cnt = 1;

    %% write exec;

    assert on_last == 1;
    assert on_next == 2;
    assert on_lag == 3;
    assert sw1 == 4;
    assert sw2 == 5;
    assert cnt == 6;
}

/*
on last     yes
on next     yes
on lag      yes
lm switch1  yes
lm switch2  yes
*/
