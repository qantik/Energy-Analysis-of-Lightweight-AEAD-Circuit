library std;
use std.textio.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

--use work.aes_pack.all;
entity stat_aead is
end stat_aead;


architecture tb of stat_aead is   

function to_string ( a: std_logic_vector) return string is
    variable b : string (1 to a'length) := (others => NUL);
    variable stri : integer := 1; 
    begin
        for i in a'range loop
            b(stri) := std_logic'image(a((i)))(2);
        stri := stri+1;
        end loop;
    return b;
end function;


    constant clkphase: time:= 100 ns;    
    constant resetactivetime:    time:= 25 ns;
    
    file testinput, testoutput, correct_v : TEXT;   
     

    signal clk              : std_logic;
    signal iclk             : std_logic;
    signal reset            : std_logic;
    signal key              : std_logic_vector(127 downto 0);
    signal nonce            : std_logic_vector(127 downto 0);
    signal data             : std_logic_vector(127 downto 0);
    
    signal last_block       : std_logic;
    signal last_partial     : std_logic;

    signal empty_ad         : std_logic;
    signal empty_msg        : std_logic;

    signal ready_block      : std_logic;
    signal ready_full       : std_logic;
    
    signal cipher_ready     : std_logic;
    signal tag_ready        : std_logic;

    signal ciphertext       : std_logic_vector(127 downto 0);
    signal tag              : std_logic_vector(127 downto 0);
    

begin

    mut : entity work.aead
        port map (clk        => clk,
                  iclk       => iclk,
                  reset      => reset,
                  key        => key,
                  nonce      => nonce,
                  data       => data,
                  last_block => last_block,
                  last_partial => last_partial,

                  empty_ad   => empty_ad,
                  empty_msg  => empty_msg,

                  ready_block => ready_block,
                  ready_full => ready_full,

                  cipher_ready => cipher_ready,
                  tag_ready => tag_ready,

                  ciphertext => ciphertext,
                  tag => tag);

    process
    begin
        clk <= '1'; wait for clkphase;
        clk <= '0'; wait for clkphase;
    end process;
    
    process
    begin
        iclk <= '0'; wait for clkphase;
        iclk <= '1'; wait for clkphase;
    end process;
  -- obtain stimulus and apply it to MUT
  ----------------------------------------------------------------------------
    a : process
        variable INLine         : line;
        variable tmp128         : std_logic_vector(127 downto 0);
        variable tmp2           : std_logic_vector(3 downto 0);
        variable ad_count       : integer range 0 to 100;

        variable msg_count      : integer range 0 to 100;
        variable ctr            : integer range 0 to 1000;
        variable read_ctr       : integer range 0 to 1000;
        variable processing_ad  : std_logic;
        variable initial        : std_logic;
        variable last_partial_ad  : std_logic;
        variable last_partial_msg : std_logic;
    begin
    
        file_open(testinput, "../../test_generator/test_vectors/IN_50", read_mode);
        file_open(testoutput, "./res", write_mode);
        --file_open(correct_v, "../../test_generator/test_vectors/out_aead", read_mode);
        appli_loop : while not (endfile(testinput)) loop
        
            reset      <= '0';
            wait for resetactivetime;
            reset      <= '1';
            
            wait until falling_edge(clk);
                
            readline(testinput, INLine);    read(INLine, ad_count);
            readline(testinput, INLine);    read(INLine, msg_count);
            readline(testinput, INLine);    hread(INLine, tmp2);       last_partial_ad := tmp2(0);
            readline(testinput, INLine);    hread(INLine, tmp2);       last_partial_msg := tmp2(0);
            readline(testinput, INLine);    hread(INLine, tmp128);       nonce <= tmp128;
            readline(testinput, INLine);    hread(INLine, tmp128);       key <= tmp128;

            empty_ad <= '0';
            empty_msg <= '0';
            if ad_count = 0 then empty_ad <= '1'; end if;
            if msg_count = 0 then  empty_msg <= '1'; end if;
            ctr := 1;
            read_ctr := 1;
            last_block <= '0';
            if ctr = ad_count or ctr = msg_count + ad_count then last_block <= '1'; end if;
            inner_loop : loop
            
                    
                
                wait until rising_edge(clk);

                if cipher_ready = '1' then
                    hwrite(INLine,  ciphertext); writeline(testoutput, INLine);
                    -- in order to spot the testbench on fail
                    --readline(correct_v, INLine); hread(INLine, tmp128);
                    --if read_ctr = msg_count  then
                    --    assert tmp128(127 downto 64)  = ciphertext (127 downto 64) report "ciphertext does not match" severity failure;
                    --else
                    --    assert tmp128  = ciphertext report "ciphertext does not match" severity failure;
                    --end if;
                    read_ctr := read_ctr + 1;
                end if;
                if tag_ready = '1' then
                    hwrite(INLine,  tag); writeline(testoutput, INLine);
                    -- in order to spot the testbench on fail
                    --readline(correct_v, INLine); hread(INLine, tmp128);
                    --assert tmp128  = tag  report "the tag does not match" severity failure;
                end if;


                if ready_full = '1' then exit inner_loop; end if;

                if ready_block = '1' then
                    readline(testinput, INLine);    hread(INLine, tmp128);       data <= tmp128;
                    
                    last_block <= '0';
                    last_partial <= '0';
                    if ctr = ad_count then
                        last_block <= '1';
                        last_partial <= last_partial_ad;
                    elsif ctr = msg_count + ad_count then
                        last_block <= '1';
                        last_partial <= last_partial_msg;
                    end if;
                    
                    ctr := ctr + 1;
                end if;

                
            end loop inner_loop;
            

        end loop appli_loop;
        
        assert false report "DONE" severity failure;
        wait until clk'event and clk = '1';
        wait;
    end process a;
end tb;
