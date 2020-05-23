library ieee;
use ieee.std_logic_1164.all;

entity aead is
    port(clk   : in std_logic;
         iclk  : in std_logic;
         reset : in std_logic;

         key          : in std_logic_vector(127 downto 0);
         nonce        : in std_logic_vector(127 downto 0);
         data         : in std_logic_vector(127 downto 0);

         last_block   : in std_logic;
         last_partial : in std_logic;

         empty_ad     : in std_logic;
         empty_msg    : in std_logic;

         ready_full : out std_logic;
         ciphertext : out std_logic_vector(127 downto 0);
         tag        : out std_logic_vector(127 downto 0));
end;

architecture behaviour of aead is

    signal domain    : std_logic_vector(7 downto 0);
    signal tweakkey  : std_logic_vector(383 downto 0);
    signal plaintext : std_logic_vector(127 downto 0);

    signal core       : std_logic_vector(127 downto 0);

    signal lfsr        : std_logic_vector(63 downto 0);
    signal lfsr_reset  : std_logic;
    signal lfsr_inner  : std_logic;

    signal auth       : std_logic_vector(127 downto 0);
    signal auth_reset : std_logic;
    signal auth_save  : std_logic;

    signal sigma       : std_logic_vector(127 downto 0);
    signal sigma_reset : std_logic;
    signal sigma_in    : std_logic;
    signal sigma_save  : std_logic;

    signal mode       : std_logic_vector(1 downto 0);

    signal aaa : std_logic_vector(127 downto 0);
    signal sss : std_logic_vector(127 downto 0);

    signal load_zero   : std_logic;
    signal load_sigma  : std_logic;
    signal out_partial : std_logic;
    signal done_full   : std_logic;

begin

    -- tweakkey   <= lfsr & X"00000000000000" & domain & nonce & key;
    -- plaintext  <= sigma         when mode = "11" else data;
    -- ciphertext <= auth xor core when mode = "11" else core;

    tweakkey   <= lfsr & X"00000000000000" & domain & nonce & key;
    plaintext  <= (others => '0') when load_zero = '1' else sigma when load_sigma = '1' else data;
    ciphertext <= data xor core when out_partial = '1' else core;
    tag        <= auth xor core;

    ready_full <= done_full;

    aaa <= core xor auth;
    sss <= data xor sigma;

    skinny_core : entity work.skinny
        generic map (true)
        port map (clk, iclk, tweakkey, plaintext, core);

    controller : entity work.controller
        port map (clk, reset, last_block, last_partial, empty_ad, empty_msg,
                  domain, auth_save, sigma_save, lfsr_reset, load_zero, load_sigma, out_partial, done_full);

    lfsr_reg : entity work.lfsr
        port map (clk, lfsr_reset, reset, lfsr);
    auth_reg : entity work.xreg
        port map (clk, reset, auth_save, aaa, auth);
    sigma_reg : entity work.xreg
        port map (clk, reset, sigma_save, sss, sigma);

end;
