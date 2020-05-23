library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use work.all;

entity pyjamask_aead_tb is

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

architecture test of pyjamask_aead_tb is

    -- Input signals.
    signal clk   : std_logic := '0';
    signal reset : std_logic;

    signal data1         : std_logic_vector(127 downto 0);
    signal data2         : std_logic_vector(127 downto 0);
    signal data3         : std_logic_vector(127 downto 0);
    signal data4         : std_logic_vector(127 downto 0);

    signal r1         : std_logic_vector(127 downto 0);
    signal r2         : std_logic_vector(127 downto 0);
    signal r3         : std_logic_vector(127 downto 0);
    signal r4         : std_logic_vector(127 downto 0);



    signal last_block   : std_logic := '0';
    signal last_partial : std_logic := '0';
    signal empty_ad     : std_logic := '0';
    signal empty_msg    : std_logic := '0';

    signal ad    : std_logic_vector(127 downto 0);
    signal key   : std_logic_vector(127 downto 0);
    signal nonce1 : std_logic_vector(95 downto 0);
    signal nonce2 : std_logic_vector(95 downto 0);
    signal nonce3 : std_logic_vector(95 downto 0);
    signal nonce4 : std_logic_vector(95 downto 0);

    -- Output signals.
    signal ready_block       : std_logic;
    signal ready_full        : std_logic;
    signal cipher_ready      : std_logic;
    signal tag_ready         : std_logic;

    signal ciphertext1 : std_logic_vector(127 downto 0);
    signal ciphertext2 : std_logic_vector(127 downto 0);
    signal ciphertext3 : std_logic_vector(127 downto 0);
    signal ciphertext4 : std_logic_vector(127 downto 0);

    signal tag1        : std_logic_vector(127 downto 0);
    signal tag2        : std_logic_vector(127 downto 0);
    signal tag3        : std_logic_vector(127 downto 0);
    signal tag4        : std_logic_vector(127 downto 0);
    signal sc,st        : std_logic_vector(127 downto 0);
    file in_vecs : text;

    constant clk_period   : time := 100 ns;
    constant reset_period : time := 25 ns;

 
begin
    sc<= ciphertext4 xor ciphertext1 xor ciphertext2 xor ciphertext3;
    st<= tag4 xor tag1 xor tag2 xor tag3;
    mut : entity work.pyjamask_aead  
        port map (clk          => clk,
                  reset        => reset,
                  key          => key,
                  nonce1       => nonce1,
                  nonce2       => nonce2,
                  nonce3       => nonce3,
                  nonce4       => nonce4,
                  data1        => data1,
                  data2        => data2,
                  data3        => data3,
                  data4        => data4,
                  r1           => r1,
                  r2           => r2,
                  r3           => r3,
                  r4           => r4,
                  last_block   => last_block,
                  last_partial => last_partial,
                  empty_ad     => empty_ad,
                  empty_msg    => empty_msg,
                  ready_block  => ready_block,
                  ready_full   => ready_full,
		  cipher_ready => cipher_ready,
		  tag_ready    => tag_ready,
                  ciphertext1  => ciphertext1,
                  ciphertext2  => ciphertext2,
                  ciphertext3  => ciphertext3,
                  ciphertext4  => ciphertext4,
                  tag1         => tag1,
                  tag2         => tag2,
                  tag3         => tag3,
                  tag4         => tag4);

    clk_process : process
    begin
        clk <= '1';
        wait for clk_period/2;
        clk <= '0';
        wait for clk_period/2;
    end process;
    
    test : process
        variable vec_line  : line;
        variable vec_space : character;

        variable vec_in_id, vec_out_id     : integer;
        variable vec_num_ad, vec_num_msg   : integer;
        variable vec_ad_part, vec_msg_part : std_logic;
        variable ad_iters                  : integer;
        variable vec_key                   : std_logic_vector(127 downto 0);
        variable vec_ad1, vec_msg1           : std_logic_vector(127 downto 0);
        variable vec_ad2, vec_msg2           : std_logic_vector(127 downto 0);
        variable vec_ad3, vec_msg3           : std_logic_vector(127 downto 0);
        variable vec_ad4, vec_msg4           : std_logic_vector(127 downto 0);
        variable vec_r1, vec_r2, vec_r3      : std_logic_vector(127 downto 0);

        variable vec_cipher, vec_tag       : std_logic_vector(127 downto 0);
        variable vec_nonce1,vec_nonce2     : std_logic_vector(95 downto 0);
        variable vec_nonce3,vec_nonce4     : std_logic_vector(95 downto 0);
        variable round : integer := 1;

	procedure nodata(constant void : in integer := 0) is
	begin
	   -- wait until rising_edge(clk);
	 
	    key   <= vec_key;
	    nonce1 <= vec_nonce1 xor vec_nonce2 xor vec_nonce3 xor vec_nonce4;
	    nonce2 <= vec_nonce2; 
	    nonce3 <= vec_nonce3; 
  	    nonce4 <= vec_nonce4; 
            r1 <= vec_r1 xor vec_r2 xor vec_r3;
            r2 <= vec_r1;
            r3 <= vec_r2;
            r4 <= vec_r3;
	    empty_ad   <= '1'; empty_msg <= '1'; 
	    data1       <= (others => '0');
	    data2       <= (others => '0');
	    data3       <= (others => '0');
	    data4       <= (others => '0');

	    reset <= '0';
            wait for reset_period;
            reset <= '1';

            -- nonce
	    -- wait until rising_edge(clk);
            wait until ready_full = '1';
 
            wait for clk_period;
            --readline(in_vecs, vec_line);
            --hread(vec_line, vec_tag);
            --assert vector_equal(tag, vec_tag) report "wrong tag" severity failure;
	end procedure;
	
        procedure noad(constant msg_blocks : in integer;
                       constant partial    : in std_logic) is
	begin
	    --wait until rising_edge(clk);
            
	    key   <= vec_key;
	    nonce1 <= vec_nonce1 xor vec_nonce2 xor vec_nonce3 xor vec_nonce4;
	    nonce2 <= vec_nonce2; 
	    nonce3 <= vec_nonce3; 
  	    nonce4 <= vec_nonce4; 
            r1 <= vec_r1 xor vec_r2 xor vec_r3;
            r2 <= vec_r1;
            r3 <= vec_r2;
            r4 <= vec_r3;	
    
            empty_ad <= '1'; empty_msg <= '0'; 
	    data1       <= (others => '0');
	    data2       <= (others => '0');
	    data3       <= (others => '0');
	    data4       <= (others => '0');

	    reset <= '0';
            wait for reset_period;
            reset <= '1';

            -- zero
            wait for clk_period-reset_period;
	    wait for 14*clk_period;
            -- ktop
 
	    wait until ready_block = '1'; 
            wait for clk_period;
	    for i in 1 to msg_blocks loop
 
 
            	readline(in_vecs, vec_line);
		hread(vec_line, vec_msg1);
		readline(in_vecs, vec_line);
		hread(vec_line, vec_msg2);
		readline(in_vecs, vec_line);
		hread(vec_line, vec_msg3);
		readline(in_vecs, vec_line);
		hread(vec_line, vec_msg4);
		
		data1         <= vec_msg1 xor vec_msg2 xor vec_msg3 xor vec_msg4;
		data2         <= vec_msg2;
		data3         <= vec_msg3;
		data4         <= vec_msg4;

		last_block   <= '0';
                last_partial <= '0';

		if i = msg_blocks then
		    last_block   <= '1';
		    last_partial <= partial;
		end if;
	        if i /= msg_blocks then
                	wait until ready_block = '1'; 
                	wait for clk_period;
                end if;
            end loop;
	    wait until ready_full = '1';
            

            wait for clk_period;
 
	end procedure;
        
        procedure nomsg(constant ad_blocks : in integer;
                        constant partial   : in std_logic) is
	begin
	    --wait until rising_edge(clk);
            
	    key   <= vec_key;
	    nonce1 <= vec_nonce1 xor vec_nonce2 xor vec_nonce3 xor vec_nonce4;
	    nonce2 <= vec_nonce2; 
	    nonce3 <= vec_nonce3; 
  	    nonce4 <= vec_nonce4; 
            r1 <= vec_r1 xor vec_r2 xor vec_r3;
            r2 <= vec_r1;
            r3 <= vec_r2;
            r4 <= vec_r3;
    
            empty_ad <= '0'; empty_msg <= '1'; 
	    data1       <= (others => '0');
	    data2       <= (others => '0');
	    data3       <= (others => '0');
	    data4       <= (others => '0');

	    reset <= '0';
            wait for reset_period;
            reset <= '1';
          
            -- zero
	    wait for clk_period-reset_period;
	    wait for 14*clk_period;

	    for i in 1 to ad_blocks loop
 
	    
            	readline(in_vecs, vec_line);
		hread(vec_line, vec_ad1);
		readline(in_vecs, vec_line);
		hread(vec_line, vec_ad2);
		readline(in_vecs, vec_line);
		hread(vec_line, vec_ad3);
		readline(in_vecs, vec_line);
		hread(vec_line, vec_ad4);
		
		data1         <= vec_ad1 xor vec_ad2 xor vec_ad3 xor vec_ad4;
		data2         <= vec_ad2;
		data3         <= vec_ad3;
		data4         <= vec_ad4;

		last_block   <= '0';
                last_partial <= '0';

		if i = ad_blocks then
		    last_block   <= '1';
		    last_partial <= partial;
		end if;
		if i /= ad_blocks then
                	wait until ready_block = '1'; 
                	wait for clk_period;
                end if;
 
            end loop;
	    wait until ready_full = '1';
            wait for clk_period;
	end procedure;
        
        procedure full(constant ad_blocks   : in integer;
		       constant msg_blocks  : in integer;
                       constant ad_partial  : in std_logic;
                       constant msg_partial : in std_logic) is
	begin
	    wait until rising_edge(clk);
            
	    key   <= vec_key;
	    nonce1 <= vec_nonce1 xor vec_nonce2 xor vec_nonce3 xor vec_nonce4;
	    nonce2 <= vec_nonce2; 
	    nonce3 <= vec_nonce3; 
  	    nonce4 <= vec_nonce4; 
            r1 <= vec_r1 xor vec_r2 xor vec_r3;
            r2 <= vec_r1;
            r3 <= vec_r2;
            r4 <= vec_r3;
	    
            empty_ad <= '0'; empty_msg <= '0'; 
	    data1       <= (others => '0');
	    data2       <= (others => '0');
	    data3       <= (others => '0');
	    data4       <= (others => '0');

	    reset <= '0';
            wait for reset_period;
            reset <= '1';

            -- zero
            wait for clk_period-reset_period;
	    wait for 14*clk_period;

 
	    
	    for i in 1 to ad_blocks loop

		
            	readline(in_vecs, vec_line);
		hread(vec_line, vec_ad1);
		readline(in_vecs, vec_line);
		hread(vec_line, vec_ad2);
		readline(in_vecs, vec_line);
		hread(vec_line, vec_ad3);
		readline(in_vecs, vec_line);
		hread(vec_line, vec_ad4);
		
		data1         <= vec_ad1 xor vec_ad2 xor vec_ad3 xor vec_ad4;
		data2         <= vec_ad2;
		data3         <= vec_ad3;
		data4         <= vec_ad4;
		last_block   <= '0';
                last_partial <= '0';

		if i = ad_blocks then
		    last_block   <= '1';
		    last_partial <= ad_partial;
		end if;
	        if i /= ad_blocks then
                	wait until ready_block = '1'; 
                	wait for clk_period;
                end if;
 
 
            end loop;
            wait until ready_block = '1'; 
            wait for clk_period;

	 
	    
            for i in 1 to msg_blocks loop
		readline(in_vecs, vec_line);
		hread(vec_line, vec_msg1);
		readline(in_vecs, vec_line);
		hread(vec_line, vec_msg2);
		readline(in_vecs, vec_line);
		hread(vec_line, vec_msg3);
		readline(in_vecs, vec_line);
		hread(vec_line, vec_msg4);
		
		data1         <= vec_msg1 xor vec_msg2 xor vec_msg3 xor vec_msg4;
		data2         <= vec_msg2;
		data3         <= vec_msg3;
		data4         <= vec_msg4;
		last_block   <= '0';
                last_partial <= '0';

		if i = msg_blocks then
		    last_block   <= '1';
		    last_partial <= msg_partial;
		end if;
		if i /= msg_blocks then
                	wait until ready_block = '1'; 
                	wait for clk_period;
                end if;
            end loop;
            wait until ready_full = '1';
            wait for clk_period;
	end procedure;

    begin

        file_open(in_vecs, "./vectors/IN4s_1000", read_mode);

        while not endfile(in_vecs) loop
        --for z in 1 to 1 loop
	    --report "round: " & integer'image(round); round := round + 1;
            
	    readline(in_vecs, vec_line);
            read(vec_line, vec_in_id); read(vec_line, vec_space);
            read(vec_line, vec_num_ad); read(vec_line, vec_space);
            read(vec_line, vec_num_msg); read(vec_line, vec_space);
            read(vec_line, vec_ad_part); read(vec_line, vec_space);
            read(vec_line, vec_msg_part);

            readline(in_vecs, vec_line);
            hread(vec_line, vec_key);
            readline(in_vecs, vec_line);
            hread(vec_line, vec_nonce1);
            readline(in_vecs, vec_line);
            hread(vec_line, vec_nonce2);
            readline(in_vecs, vec_line);
            hread(vec_line, vec_nonce3);
            readline(in_vecs, vec_line);
            hread(vec_line, vec_nonce4);

            readline(in_vecs, vec_line);
            hread(vec_line, vec_r1);
            readline(in_vecs, vec_line);
            hread(vec_line, vec_r2);
            readline(in_vecs, vec_line);
            hread(vec_line, vec_r3);


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

        --assert false report "test passed" severity failure;

    end process;

end;
