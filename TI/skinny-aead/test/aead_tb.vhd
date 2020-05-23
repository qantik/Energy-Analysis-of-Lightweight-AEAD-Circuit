library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity aead_tb is

    function vector_equal(a, b : std_logic_vector) return boolean is
    begin
        for i in 0 to 127 loop
            if a(i) /= b(i) then
                return false;
            end if;
        end loop;
        return true;
    end;

end;

architecture test of aead_tb is

    -- Input signals.
    signal clk   : std_logic := '0';
    signal reset : std_logic;

    signal data1        : std_logic_vector(127 downto 0);
    signal data2        : std_logic_vector(127 downto 0);
    signal data3        : std_logic_vector(127 downto 0);
    
    signal last_block   : std_logic := '0';
    signal last_partial : std_logic := '0';
    signal empty_ad     : std_logic := '0';
    signal empty_msg    : std_logic := '0';

    signal ad    : std_logic_vector(127 downto 0);
    signal msg   : std_logic_vector(127 downto 0);
    signal key   : std_logic_vector(127 downto 0);
    signal nonce : std_logic_vector(127 downto 0);

    -- Output signals.
    signal ready_block : std_logic;
    signal ready_full  : std_logic;

    signal ciphertext1: std_logic_vector(127 downto 0);
    signal ciphertext2: std_logic_vector(127 downto 0);
    signal ciphertext3: std_logic_vector(127 downto 0);

    signal tag1       : std_logic_vector(127 downto 0);
    signal tag2       : std_logic_vector(127 downto 0);
    signal tag3       : std_logic_vector(127 downto 0);

    file in_vecs : text;
    file randomness_source : text;

    constant clk_period   : time := 100 ns;
    constant reset_period : time := 25 ns;

begin

    mut : entity work.aead
        port map (clk          => clk,
                  reset        => reset,
                  key          => key,
                  nonce        => nonce,
                  data1        => data1,
                  data2        => data2,
                  data3        => data3,
                  last_block   => last_block,
                  last_partial => last_partial,
                  empty_ad     => empty_ad,
                  empty_msg    => empty_msg,
                  ready_block  => ready_block,
                  ready_full   => ready_full,
                  ciphertext1  => ciphertext1,
                  ciphertext2  => ciphertext2,
                  ciphertext3  => ciphertext3,
                  tag1         => tag1,
                  tag2         => tag2,
                  tag3         => tag3
                  );

    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    test : process
        variable vec_line  : line;
        variable randomness_line  : line;
        variable vec_space : character;

        variable vec_in_id, vec_out_id     : integer;
        variable vec_num_ad, vec_num_msg   : integer;
        variable vec_ad_part, vec_msg_part : std_logic;
        variable ad_iters                  : integer;
        variable vec_key, vec_nonce        : std_logic_vector(127 downto 0);
        variable vec_ad                    : std_logic_vector(127 downto 0);
        variable vec_msg                   : std_logic_vector(127 downto 0);
        variable pt1                       : std_logic_vector(127 downto 0);
        variable pt2                       : std_logic_vector(127 downto 0);
        variable tag_xored                 : std_logic_vector(127 downto 0);
        variable ad1                       : std_logic_vector(127 downto 0);
        variable ad2                       : std_logic_vector(127 downto 0);
        variable ad3                       : std_logic_vector(127 downto 0);
        variable vec_cipher, vec_tag       : std_logic_vector(127 downto 0);

        variable round : integer := 1;

        procedure nodata(constant void : in integer := 0) is
        begin
            wait until rising_edge(clk);

            key   <= vec_key;
            nonce <= vec_nonce;

            empty_ad <= '1'; empty_msg <= '1';
            
            readline(randomness_source, randomness_line);        hread(randomness_line, pt1);
            readline(randomness_source, randomness_line);        hread(randomness_line, pt2);
            data1 <= pt1;
            data2 <= pt2;
            data3     <= (127 downto 0 => '0') xor pt1 xor pt2;
            last_block <= '0'; last_partial <= '0';

            reset <= '0';
            wait for reset_period;
            reset <= '1';

            waiting_loop3: loop
                wait until rising_edge(clk);
                if ready_block = '1' then
                    exit waiting_loop3;
                end if;
            end loop;
            
            readline(in_vecs, vec_line);
            hread(vec_line, vec_tag);
            tag_xored := tag1 xor tag2 xor tag3;
            assert vector_equal(tag_xored, vec_tag) report "wrong tag" severity failure;
        end procedure;

        procedure noad(constant msg_blocks : in integer;
                       constant partial    : in std_logic) is
        begin
            wait until rising_edge(clk);

            key   <= vec_key;
            nonce <= vec_nonce;

            empty_ad <= '1'; empty_msg <= '0';
            
            readline(randomness_source, randomness_line);        hread(randomness_line, pt1);
            readline(randomness_source, randomness_line);        hread(randomness_line, pt2);
            data1 <= pt1;
            data2 <= pt2;
            data3     <= (127 downto 0 => '0') xor pt1 xor pt2;
            last_block <= '0'; last_partial <= '0';

            reset <= '0';
            wait for reset_period;
            reset <= '1';
            wait until rising_edge(clk);
            for i in 1 to msg_blocks loop
                

                readline(in_vecs, vec_line);
                hread(vec_line, vec_msg); read(vec_line, vec_space);
                hread(vec_line, vec_cipher);
                
                readline(randomness_source, randomness_line);        hread(randomness_line, pt1);
                readline(randomness_source, randomness_line);        hread(randomness_line, pt2);
                data1 <= pt1;
                data2 <= pt2;
                data3      <= vec_msg xor pt1 xor pt2;
                
                last_block   <= '0';
                last_partial <= '0';

                if i = msg_blocks then
                    last_block   <= '1';
                    last_partial <= partial;
                end if;

                waiting_loop4: loop
                wait until rising_edge(clk);
                if ready_block = '1' then
                    exit waiting_loop4;
                end if;
                end loop;
            end loop;

            waiting_loop5: loop
                wait until rising_edge(clk);
                if ready_block = '1' then
                    exit waiting_loop5;
                end if;
            end loop;
            readline(in_vecs, vec_line);
            hread(vec_line, vec_tag);
            tag_xored := tag1 xor tag2 xor tag3;
            assert vector_equal(tag_xored, vec_tag) report "wrong tag" severity failure;
        end procedure;

        procedure nomsg(constant ad_blocks : in integer;
                        constant partial   : in std_logic) is
        begin
            wait until rising_edge(clk);

            key   <= vec_key;
            nonce <= vec_nonce;

            empty_ad <= '0'; empty_msg <= '1';
            last_block <= '0'; last_partial <= '0';

            reset <= '0';
            wait for reset_period;
            reset <= '1';
            wait until rising_edge(clk);
            
            for i in 1 to ad_blocks loop
                

                readline(in_vecs, vec_line);
                hread(vec_line, vec_ad);

                readline(randomness_source, randomness_line);        hread(randomness_line, pt1);
                readline(randomness_source, randomness_line);        hread(randomness_line, pt2);
                data1 <= pt1;
                data2 <= pt2;
                data3              <= vec_ad xor pt1 xor pt2;
                last_block   <= '0';
                last_partial <= '0';

                if i = ad_blocks then
                    last_block   <= '1';
                    last_partial <= partial;
                end if;

                waiting_loop6: loop
                wait until rising_edge(clk);
                if ready_block = '1' then
                    exit waiting_loop6;
                end if;
                end loop;
            end loop;

            last_partial <= '0';

            waiting_loop7: loop
                wait until rising_edge(clk);
                if ready_block = '1' then
                    exit waiting_loop7;
                end if;
            end loop;
            readline(in_vecs, vec_line);
            hread(vec_line, vec_tag);
            tag_xored := tag1 xor tag2 xor tag3;
            assert vector_equal(tag_xored, vec_tag) report "wrong tag" severity failure;
            
        end procedure;

        procedure full(constant ad_blocks   : in integer;
                       constant msg_blocks  : in integer;
                       constant ad_partial  : in std_logic;
                       constant msg_partial : in std_logic) is
        begin
            wait until rising_edge(clk);

            key   <= vec_key;
            nonce <= vec_nonce;

            empty_ad <= '0'; empty_msg <= '0';
            last_block <= '0'; last_partial <= '0';

            reset <= '0';
            wait for reset_period;
            reset <= '1';
            wait until rising_edge(clk);
            
            for i in 1 to ad_blocks loop
                --wait until rising_edge(clk);

                readline(in_vecs, vec_line);
                hread(vec_line, vec_ad);

                readline(randomness_source, randomness_line);        hread(randomness_line, pt1);
                readline(randomness_source, randomness_line);        hread(randomness_line, pt2);
                data1 <= pt1;
                data2 <= pt2;
                data3         <= vec_ad xor pt1 xor pt2;
                
                last_block   <= '0';
                last_partial <= '0';

                if i = ad_blocks then
                    last_block   <= '1';
                    last_partial <= ad_partial;
                end if;

                waiting_loop0: loop
                    wait until rising_edge(clk);
                    if ready_block = '1' then
                        exit waiting_loop0;
                    end if;
                end loop;
            
                --wait until ready_block = '1';
            end loop;
            wait until rising_edge(clk);
            for i in 1 to msg_blocks loop
                --wait until rising_edge(clk);

                readline(in_vecs, vec_line);
                hread(vec_line, vec_msg); read(vec_line, vec_space);
                hread(vec_line, vec_cipher);

                readline(randomness_source, randomness_line);        hread(randomness_line, pt1);
                readline(randomness_source, randomness_line);        hread(randomness_line, pt2);
                data1 <= pt1;
                data2 <= pt2;
                data3         <= vec_msg  xor pt1 xor pt2 ;
                last_block   <= '0';
                last_partial <= '0';

                if i = msg_blocks then
                    last_block   <= '1';
                    last_partial <= msg_partial;
                end if;

                waiting_loop1: loop
                    wait until rising_edge(clk);
                    if ready_block = '1' then
                        exit waiting_loop1;
                    end if;
                end loop;
                --wait until ready_block = '1';
            end loop;

            --wait until rising_edge(clk);
            ---wait until ready_block = '1';
            
            --wait for 0.5*clk_period;
            waiting_loop2: loop
                wait until rising_edge(clk);
                if ready_block = '1' then
                    exit waiting_loop2;
                end if;
            end loop;
            
            readline(in_vecs, vec_line);
            hread(vec_line, vec_tag);
            tag_xored := tag1 xor tag2 xor tag3;
            assert vector_equal(tag_xored, vec_tag) report "wrong tag" severity failure;
    end procedure;
    begin

        file_open(in_vecs, "./vec", read_mode);
        file_open(randomness_source, "./RANDOM_100000", read_mode);

        while not endfile(in_vecs) loop
            --for z in 1 to 10 loop
            report "round: " & integer'image(round); round := round + 1;

            readline(in_vecs, vec_line);
            read(vec_line, vec_in_id); read(vec_line, vec_space);
            read(vec_line, vec_num_ad); read(vec_line, vec_space);
            read(vec_line, vec_num_msg); read(vec_line, vec_space);
            read(vec_line, vec_ad_part); read(vec_line, vec_space);
            read(vec_line, vec_msg_part);

            readline(in_vecs, vec_line);
            hread(vec_line, vec_key);
            readline(in_vecs, vec_line);
            hread(vec_line, vec_nonce);

            if (vec_num_ad = 0) and (vec_num_msg = 0) then
                nodata(0);
            elsif (vec_num_ad = 0) and (vec_num_msg /= 0) then
                noad(vec_num_msg, vec_msg_part);
            elsif (vec_num_ad /= 0) and (vec_num_msg = 0) then
                nomsg(vec_num_ad, vec_ad_part);
            else
                full(vec_num_ad, vec_num_msg, vec_ad_part, vec_msg_part);
            end if;

        end loop;

        assert false report "test passed" severity failure;

    end process;

end;
