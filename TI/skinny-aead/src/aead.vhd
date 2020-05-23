library ieee;
use ieee.std_logic_1164.all;

entity aead is
    port(clk   : in std_logic;
         reset : in std_logic;

         key          : in std_logic_vector(127 downto 0);
         nonce        : in std_logic_vector(127 downto 0);

         data1        : in std_logic_vector(127 downto 0);
         data2        : in std_logic_vector(127 downto 0);
         data3        : in std_logic_vector(127 downto 0);
         
         last_block   : in std_logic;
         last_partial : in std_logic;

         empty_ad     : in std_logic;
         empty_msg    : in std_logic;

         ready_block  : out std_logic;
         ready_full   : out std_logic;

         ciphertext1  : out std_logic_vector(127 downto 0);
         ciphertext2  : out std_logic_vector(127 downto 0);
         ciphertext3  : out std_logic_vector(127 downto 0);
         
         tag1         : out std_logic_vector(127 downto 0);
         tag2         : out std_logic_vector(127 downto 0);
         tag3         : out std_logic_vector(127 downto 0)
         );
end;

architecture behaviour of aead is

    signal domain    : std_logic_vector(7 downto 0);
    signal tweakkey  : std_logic_vector(383 downto 0);
    
    signal plaintext1: std_logic_vector(127 downto 0);
    signal plaintext2: std_logic_vector(127 downto 0);
    signal plaintext3: std_logic_vector(127 downto 0);

    signal core1       : std_logic_vector(127 downto 0);
    signal core2       : std_logic_vector(127 downto 0);
    signal core3       : std_logic_vector(127 downto 0);
    
    
    signal core_reset : std_logic;
    signal core_reset_inv : std_logic;
    signal core_done  : std_logic;

    signal lfsr        : std_logic_vector(63 downto 0);
    signal lfsr_reset : std_logic;
    signal lfsr_update : std_logic;

    signal auth1       : std_logic_vector(127 downto 0);
    signal auth2       : std_logic_vector(127 downto 0);
    signal auth3       : std_logic_vector(127 downto 0);
    
    signal auth_save : std_logic;

    signal sigma1       : std_logic_vector(127 downto 0);
    signal sigma2       : std_logic_vector(127 downto 0);
    signal sigma3       : std_logic_vector(127 downto 0);
    
    signal sigma_save : std_logic;

    signal aaa1       : std_logic_vector(127 downto 0);
    signal aaa2       : std_logic_vector(127 downto 0);
    signal aaa3       : std_logic_vector(127 downto 0);
    
    signal sss1       : std_logic_vector(127 downto 0);
    signal sss2       : std_logic_vector(127 downto 0);
    signal sss3       : std_logic_vector(127 downto 0);
    
    signal load_zero   : std_logic;
    signal load_sigma  : std_logic;
    signal out_partial : std_logic;
    signal done_full   : std_logic;
    
    signal r_in        : std_logic_vector(127 downto 0);
    signal r_out        : std_logic_vector(127 downto 0);

begin

    r_in <= plaintext1 xor plaintext2 xor plaintext3;
    r_out <= core1 xor core2 xor core3;
    
    tweakkey   <= lfsr & X"00000000000000" & domain & nonce & key;
    
    plaintext1  <= (others => '0') when load_zero = '1' else sigma1 when load_sigma = '1' else data1;
    plaintext2  <= (others => '0') when load_zero = '1' else sigma2 when load_sigma = '1' else data2;
    plaintext3  <= (others => '0') when load_zero = '1' else sigma3 when load_sigma = '1' else data3;
    
    ciphertext1 <= data1 xor core1 when out_partial = '1' else core1;
    ciphertext2 <= data2 xor core2 when out_partial = '1' else core2;
    ciphertext3 <= data3 xor core3 when out_partial = '1' else core3;
    
    tag1        <= auth1 xor core1;
    tag2        <= auth2 xor core2;
    tag3        <= auth3 xor core3;
    
    ready_block <= core_done;
    ready_full  <= core_done;

    aaa1 <= core1 xor auth1;
    aaa2 <= core2 xor auth2;
    aaa3 <= core3 xor auth3;
    
    sss1 <= data1 xor sigma1;
    sss2 <= data2 xor sigma2;
    sss3 <= data3 xor sigma3;
    
    core_reset_inv <= not core_reset;

    skinny_core : entity work.SKINNY_TH
        port map (clk, core_reset_inv, tweakkey, plaintext1,plaintext2,plaintext3, core_done, core1,core2,core3);

    controller : entity work.controller
        port map (clk, reset, core_done, last_block, last_partial, empty_ad, empty_msg, domain, core_reset,
	auth_save, sigma_save, lfsr_reset, lfsr_update, load_zero, load_sigma, out_partial, done_full);

    lfsr_reg : entity work.lfsr port map (clk, reset, lfsr_reset, lfsr_update, lfsr);

    auth_reg1 : entity work.gff generic map (CLOCK_GATED => true, SIZE => 128) port map (clk, reset, aaa1, auth_save, auth1);
    auth_reg2 : entity work.gff generic map (CLOCK_GATED => true, SIZE => 128) port map (clk, reset, aaa2, auth_save, auth2);
    auth_reg3 : entity work.gff generic map (CLOCK_GATED => true, SIZE => 128) port map (clk, reset, aaa3, auth_save, auth3);

    sigma_reg1 : entity work.gff generic map (CLOCK_GATED => true, SIZE => 128) port map (clk, reset, sss1, sigma_save, sigma1);
    sigma_reg2 : entity work.gff generic map (CLOCK_GATED => true, SIZE => 128) port map (clk, reset, sss2, sigma_save, sigma2);
    sigma_reg3 : entity work.gff generic map (CLOCK_GATED => true, SIZE => 128) port map (clk, reset, sss3, sigma_save, sigma3);

end;
