library std;
use std.textio.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
--use work.aes_pack.all;
entity forkskinny_tb is
end forkskinny_tb;


architecture tb of forkskinny_tb is   

	constant clkphase: time:= 50 ns;    
	constant resetactivetime:         time:= 25 ns;
	
	file testinput, testoutput : TEXT;	
	 
	signal PTxD, KeyxD, CTxD : std_logic_vector (127 downto 0);
	signal TxD      : std_logic_vector (159 downto 0);
	signal InsxS : std_logic_vector(1 downto 0);
	signal CTrdyxS    : std_logic;
	signal ClkxC : std_logic;                    -- driving clock
	signal ResetxRB, ModexS, DonexS: std_logic;          -- reset
	signal tweakey : std_logic_vector(287 downto 0);
	
    constant rinit : integer := 25;
    constant r0    : integer := 31;
    constant r1    : integer := 31;
  
	component FORKSKINNY
	port (CLK       : in std_logic;
          RESET     : in std_logic;
          MODE      : in std_logic;
          TWEAKEY : in std_logic_vector (287 downto 0);
          PLAINTEXT : in std_logic_vector (127 downto 0);          
          
          DONE       : out std_logic;
          CIPHERTEXT : out std_logic_vector (127 downto 0));
	end component;
	

begin

  -- Instantiate the module under test (MUT)
  mut: FORKSKINNY
    port map (
      CLK     => ClkxC,
      RESET    => ResetxRB, 
      MODE    => ModexS,
      TWEAKEY    => tweakey,
      PLAINTEXT	=> PTxD,
      DONE => DonexS,
      CIPHERTEXT    => CTxD
  );

	process
	begin
		ClkxC <= '1'; wait for clkphase;
		ClkxC <= '0'; wait for clkphase;
	end process;

  -- obtain stimulus and apply it to MUT
  ----------------------------------------------------------------------------
  	a : process
		variable INLine   : line;
		variable tmp128   : std_logic_vector(127 downto 0);    
		variable tmp2     : std_logic_vector(3 downto 0);
		variable tmp160  : std_logic_vector(159 downto 0);  
		variable waitcycles : Integer;
		variable waitphase : time;
	begin
		file_open(testinput, "in_both", read_mode);
		file_open(testoutput, "res", write_mode);

		wait for clkphase;
		

		appli_loop : while not (endfile(testinput)) loop
			
			
            ResetxRB      <= '0';
            wait until rising_edge(ClkxC);
            ResetxRB      <= '1';
            wait until falling_edge(ClkxC);

-- the structure of TB file should be: PT (hex) \n Key (hex) \n T(hex) \n Ins (bits)
			readline(testinput, INLine);	hread(INLine, tmp128);	PTxD <= tmp128;
			readline(testinput, INLine);	hread(INLine, tmp128);	KeyxD <= tmp128;
			readline(testinput, INLine);	hread(INLine, tmp160);	TxD <= tmp160;
			readline(testinput, INLine);	hread(INLine, tmp2);	ModexS <= tmp2(0);
            tweakey <= tmp128 & tmp160;

            wait until DonexS = '1';
            wait until falling_edge(ClkxC);

            hwrite(INLine,  CTxD); writeline(testoutput, INLine);

            if tmp2(0) = '0' then 
                wait until DonexS = '1';
                wait until falling_edge(ClkxC);
                hwrite(INLine,  CTxD); writeline(testoutput, INLine);
            end if;

            wait until falling_edge(ClkxC);

		end loop appli_loop;
		
        assert false report "DONE" severity failure;
		wait until ClkxC'event and ClkxC = '1';
		wait;
	end process a;
end tb;
