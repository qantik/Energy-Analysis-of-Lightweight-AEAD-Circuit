library std;
use std.textio.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

--use work.aes_pack.all;
entity forkae_tb_th is
end forkae_tb_th;


architecture tb of forkae_tb_th is   

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


    constant clkphase: time:= 50 ns;    
    constant resetactivetime:    time:= 25 ns;
    
    file testinput, testoutput, random_in : TEXT;   
     

    signal clk              : std_logic;
    signal reset            : std_logic;
    signal key              : std_logic_vector(127 downto 0);
    signal nonce            : std_logic_vector(103 downto 0);
    signal data1            : std_logic_vector(127 downto 0);
    signal data2            : std_logic_vector(127 downto 0);
    signal data3            : std_logic_vector(127 downto 0);
    
    signal last_block       : std_logic;
    signal last_partial     : std_logic;

    signal empty_ad         : std_logic;
    signal empty_msg        : std_logic;

    signal ready_block      : std_logic;
    signal ready_full       : std_logic;
    
    signal cipher_ready     : std_logic;
    signal tag_ready        : std_logic;

    signal ciphertext1      : std_logic_vector(127 downto 0);
    signal ciphertext2      : std_logic_vector(127 downto 0);
    signal ciphertext3      : std_logic_vector(127 downto 0);
    signal tag1             : std_logic_vector(127 downto 0);
    signal tag2             : std_logic_vector(127 downto 0);
    signal tag3             : std_logic_vector(127 downto 0);
    

begin

    mut : entity work.aead
        port map (clk        => clk,
                  reset      => reset,
                  key        => key,
                  nonce      => nonce,
                  data1       => data1,
                  data2       => data2,
                  data3       => data3,
                  last_block => last_block,
                  last_partial => last_partial,

                  empty_ad   => empty_ad,
                  empty_msg  => empty_msg,

                  ready_block => ready_block,
                  ready_full => ready_full,

                  cipher_ready => cipher_ready,
                  tag_ready => tag_ready,

                  ciphertext1 => ciphertext1,
                  ciphertext2 => ciphertext2,
                  ciphertext3 => ciphertext3,
                  tag1 => tag1,
                  tag2 => tag2,
                  tag3 => tag3
                  );

    process
    begin
        clk <= '1'; wait for clkphase;
        clk <= '0'; wait for clkphase;
    end process;
  -- obtain stimulus and apply it to MUT
  ----------------------------------------------------------------------------
    a : process
        variable INLine         : line;
        variable tmp128         : std_logic_vector(127 downto 0);
        variable tmp2           : std_logic_vector(3 downto 0);
        variable ad_count       : integer range 0 to 100;

        variable pt1,pt2,pt3,pt : std_logic_vector(127 downto 0);
        variable msg_count      : integer range 0 to 100;
        variable ctr            : integer range 0 to 1000;
        variable read_ctr       : integer range 0 to 1000;
        variable processing_ad  : std_logic;
        variable initial        : std_logic;
        variable last_partial_ad  : std_logic;
        variable last_partial_msg : std_logic;
    begin
        file_open(testinput, "./IN_1000", read_mode);
        file_open(random_in, "./RANDOM_100000", read_mode);
        appli_loop : while not (endfile(testinput)) loop
        
            reset      <= '0';
            wait for resetactivetime;
            reset      <= '1';
            
            wait until falling_edge(clk);
                
            readline(testinput, INLine);    read(INLine, ad_count);
            readline(testinput, INLine);    read(INLine, msg_count);
            readline(testinput, INLine);    hread(INLine, tmp2);       last_partial_ad := tmp2(0);
            readline(testinput, INLine);    hread(INLine, tmp2);       last_partial_msg := tmp2(0);
            readline(testinput, INLine);    hread(INLine, tmp128);       nonce <= tmp128(127 downto 24);
            readline(testinput, INLine);    hread(INLine, tmp128);       key <= tmp128;

            initial := '1';
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


                if ready_full = '1' then exit inner_loop; end if;

                if ready_block = '1' or initial ='1' then
                    --readline(testinput, INLine);    hread(INLine, tmp128);       data <= tmp128;
                    initial := '0';
                    readline(testinput, INLine); hread(INLine, pt);
                    readline(random_in, INLine); hread(INLine, pt1);       data1 <= pt1;
                    readline(random_in, INLine); hread(INLine, pt2);       data2 <= pt2;
                    data3 <= pt1 xor pt2 xor pt;
                    
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
