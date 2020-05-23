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
    signal iclk   : std_logic := '1';
    signal reset : std_logic;

    signal data         : std_logic_vector(127 downto 0);
    signal last_block   : std_logic := '0';
    signal last_partial : std_logic := '0';
    signal empty_ad     : std_logic := '0';
    signal empty_msg    : std_logic := '0';

    signal ad    : std_logic_vector(127 downto 0);
    signal msg   : std_logic_vector(127 downto 0);
    signal key   : std_logic_vector(127 downto 0);
    signal nonce : std_logic_vector(127 downto 0);

    -- Output signals.
    signal ready_full : std_logic;
    signal ciphertext : std_logic_vector(127 downto 0);
    signal tag        : std_logic_vector(127 downto 0);

    file in_vecs  : text;

    constant clk_period   : time := 100 ns;
    constant reset_period : time := 25 ns;

begin

    aead : entity work.aead
        port map (clk          => clk,
                  iclk         => iclk,
                  reset        => reset,
                  key          => key,
                  nonce        => nonce,
                  data         => data,
                  last_block   => last_block,
                  last_partial => last_partial,
                  empty_ad     => empty_ad,
                  empty_msg    => empty_msg,
                  ready_full   => ready_full,
                  ciphertext   => ciphertext,
                  tag          => tag);

    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    iclk_process : process
    begin
        iclk <= '1';
        wait for clk_period/2;
        iclk <= '0';
        wait for clk_period/2;
    end process;

    test : process
        variable vec_line  : line;
        variable vec_space : character;

        variable vec_in_id, vec_out_id     : integer;
        variable vec_num_ad, vec_num_msg   : integer;
        variable vec_ad_part, vec_msg_part : std_logic;
        variable ad_iters                  : integer;
        variable vec_key, vec_nonce        : std_logic_vector(127 downto 0);
        variable vec_ad, vec_msg           : std_logic_vector(127 downto 0);
        variable vec_cipher, vec_tag       : std_logic_vector(127 downto 0);

        variable round : integer := 1;

        procedure nodata(constant void : in integer := 0) is
        begin
            wait until rising_edge(clk);

            key   <= vec_key;
            nonce <= vec_nonce;

            empty_ad <= '1'; empty_msg <= '1';
            data     <= (others => '0');
            last_block <= '0'; last_partial <= '0';

            reset <= '0';
            wait for reset_period;
            reset <= '1';

            wait until rising_edge(clk);  -- nonce

            wait for 0.95*clk_period;
            readline(in_vecs, vec_line);
            hread(vec_line, vec_tag);
            assert vector_equal(tag, vec_tag) report "wrong tag" severity failure;
        end procedure;

        procedure noad(constant msg_blocks : in integer;
                       constant partial    : in std_logic) is
        begin
            wait until rising_edge(clk);

            key   <= vec_key;
            nonce <= vec_nonce;

            empty_ad <= '1'; empty_msg <= '0';
            data     <= (others => '0');
            last_block <= '0'; last_partial <= '0';

            reset <= '0';
            wait for reset_period;
            reset <= '1';

            for i in 1 to msg_blocks loop
                wait until rising_edge(clk);

                readline(in_vecs, vec_line);
                hread(vec_line, vec_msg); read(vec_line, vec_space);
                hread(vec_line, vec_cipher);

                data         <= vec_msg;
                last_block   <= '0';
                last_partial <= '0';

                if i = msg_blocks then
                    last_block   <= '1';
                    last_partial <= partial;
                end if;

            end loop;

            wait until rising_edge(clk);

            wait for 0.95*clk_period;
            readline(in_vecs, vec_line);
            hread(vec_line, vec_tag);
            assert vector_equal(tag, vec_tag) report "wrong tag" severity failure;
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

            for i in 1 to ad_blocks loop
                wait until rising_edge(clk);

                readline(in_vecs, vec_line);
                hread(vec_line, vec_ad);

                data         <= vec_ad;
                last_block   <= '0';
                last_partial <= '0';

                if i = ad_blocks then
                    last_block   <= '1';
                    last_partial <= partial;
                end if;

            end loop;

            wait until rising_edge(clk);
            last_partial <= '0';

            wait for 0.95*clk_period;
            readline(in_vecs, vec_line);
            hread(vec_line, vec_tag);
            assert vector_equal(tag, vec_tag) report "wrong tag" severity failure;
            
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

            for i in 1 to ad_blocks loop
                wait until rising_edge(clk);

                readline(in_vecs, vec_line);
                hread(vec_line, vec_ad);

                data         <= vec_ad;
                last_block   <= '0';
                last_partial <= '0';

                if i = ad_blocks then
                    last_block   <= '1';
                    last_partial <= ad_partial;
                end if;

            end loop;

            for i in 1 to msg_blocks loop
                wait until rising_edge(clk);

                readline(in_vecs, vec_line);
                hread(vec_line, vec_msg); read(vec_line, vec_space);
                hread(vec_line, vec_cipher);

                data         <= vec_msg;
                last_block   <= '0';
                last_partial <= '0';

                if i = msg_blocks then
                    last_block   <= '1';
                    last_partial <= msg_partial;
                end if;

            end loop;

            wait until rising_edge(clk);
            
            wait for 0.95*clk_period;
            readline(in_vecs, vec_line);
            hread(vec_line, vec_tag);
            assert vector_equal(tag, vec_tag) report "wrong tag" severity failure;
        end procedure;

    begin

        file_open(in_vecs, "../test/vectors/vec-rand.txt", read_mode);

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

    -- test : process
    --     variable vec_line  : line;
    --     variable vec_space : character;

    --     variable vec_in_id, vec_out_id   : integer;
    --     variable vec_num_ad, vec_num_msg : integer;
    --     variable vec_key, vec_nonce      : std_logic_vector(127 downto 0);
    --     variable vec_ad, vec_msg         : std_logic_vector(127 downto 0);
    --     variable vec_cipher, vec_tag     : std_logic_vector(127 downto 0);

    -- begin

    --     file_open(in_vecs, "../test/vectors/vec-11-alt.txt", read_mode);

    --     --while not endfile(in_vecs) loop
    --     for l in 1 to 10 loop
    --         readline(in_vecs, vec_line);
    --         read(vec_line, vec_in_id);   read(vec_line, vec_space);
    --         read(vec_line, vec_num_ad);  read(vec_line, vec_space);
    --         read(vec_line, vec_num_msg);

    --         readline(in_vecs, vec_line);
    --         hread(vec_line, vec_key);
    --         readline(in_vecs, vec_line);
    --         hread(vec_line, vec_nonce);

    --         for i in 1 to vec_num_ad loop
    --             readline(in_vecs, vec_line);
    --             hread(vec_line, vec_ad);

    --             wait until rising_edge(clk);
    --             if vec_num_ad = 0 then empty_ad <= '1'; else empty_ad <= '0'; end if;
    --             if vec_num_msg = 0 then empty_msg <= '1'; else empty_msg <= '0'; end if;
    --             data  <= vec_ad;
    --             key   <= vec_key;
    --             nonce <= vec_nonce;
    --             if i = vec_num_ad then last_block <= '1'; else last_block <= '0'; end if;

    --             if i = 1 then
    --                 reset <= '0';
    --                 wait for reset_period;
    --                 reset <= '1';
    --             end if;
    --         end loop;

    --         for i in 1 to vec_num_msg loop
    --             readline(in_vecs, vec_line);
    --             hread(vec_line, vec_msg); read(vec_line, vec_space);
    --             hread(vec_line, vec_cipher);

    --             wait until rising_edge(clk);
    --             data  <= vec_msg;
    --             key   <= vec_key;
    --             nonce <= vec_nonce;
    --             if i = vec_num_msg then last_block <= '1'; else last_block <= '0'; end if;
    --             if vec_num_ad = 0 then empty_ad <= '1'; else empty_ad <= '0'; end if;
    --             if vec_num_msg = 0 then empty_msg <= '1'; else empty_msg <= '0'; end if;

    --             if vec_num_ad = 0 then
    --                 reset <= '0';
    --                 wait for reset_period;
    --                 reset <= '1';
    --             end if;

    --             wait for clk_period*0.9;
    --             assert vector_equal(output, vec_cipher) report "wrong ciphertext" severity failure;
    --         end loop;

    --         readline(in_vecs, vec_line);
    --         hread(vec_line, vec_tag);
    --         wait for clk_period*0.95;
    --         assert vector_equal(output, vec_tag) report "wrong tag" severity failure;
    --     end loop;

    --     assert false report "test passed" severity failure;
        
    -- end process;

end;
