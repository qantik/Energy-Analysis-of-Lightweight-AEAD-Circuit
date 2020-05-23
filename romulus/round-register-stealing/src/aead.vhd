library ieee;
use ieee.std_logic_1164.all;

entity aead is
    port (clk   : in std_logic;
          reset : in std_logic; -- active low

          key   : in std_logic_vector(127 downto 0);
          nonce : in std_logic_vector(127 downto 0);

          -- A data block is either associated data or plaintext.
          -- last_block indicates whether the current ad or plaintext
          -- block is the last one with last_partial indicating whether
          -- said block is only partially filled.
          data         : in std_logic_vector(127 downto 0);
          last_block   : in std_logic;
          last_partial : in std_logic;

          empty_ad     : in std_logic; -- Constant, set at the beginning.
          empty_msg    : in std_logic; -- Constant, set at the beginning.

          ready_block  : out std_logic; -- Expecting new block at next rising edge.
          ready_full   : out std_logic; -- AEAD finished.

          -- Indication signals that tell whether current value on either
          -- the ciphertext or tag output pins is valid.
          cipher_ready : out std_logic;
          tag_ready    : out std_logic;

          ciphertext   : out std_logic_vector(127 downto 0);
          tag          : out std_logic_vector(127 downto 0));
end;

architecture behaviour of aead is

    signal domain     : std_logic_vector(4 downto 0);
    signal tweakkey   : std_logic_vector(383 downto 0);
    signal lfsr       : std_logic_vector(55 downto 0);

    signal core       : std_logic_vector(127 downto 0);
    signal core_reset : std_logic;
    signal core_done  : std_logic;
    
    signal tag_in     : std_logic_vector(127 downto 0);
    signal running_state: std_logic_vector(127 downto 0);
    signal rho_input  : std_logic_vector(127 downto 0);
    signal rho_s      : std_logic_vector(127 downto 0);
    signal rho_cipher : std_logic_vector(127 downto 0);

    signal tag_out    : std_logic_vector(127 downto 0);
    
    signal tweak_sel  : std_logic;
    signal tag_sel    : std_logic;
    signal rho_sel    : std_logic;
    signal state_sel  : std_logic;
    
    signal lfsr_little_endian : std_logic_vector(55 downto 0);

    signal tweak      : std_logic_vector(127 downto 0);
    signal clk_tag_en : std_logic;
    
begin

    endian_flip : entity WORK.endian_change generic map (BSIZE => 7) port map(lfsr, lfsr_little_endian);

    tweakkey   <= lfsr_little_endian & "000" & domain & (63 downto 0 => '0') & tweak & key;
    
    tweak <= nonce when tweak_sel = '0' else data;
    running_state <= (others => '0') when state_sel = '0' else tag_out;
    rho_input <= data when rho_sel = '0' else  (others => '0');
    tag_in <= rho_s when tag_sel ='0' else core;

    skinny_core : entity WORK.SKINNY generic map (R => 4) port map (clk, core_reset, tweakkey, running_state, core_done, core);

    controller : entity WORK.aead_controller port map (clk, reset, core_done, last_block, empty_ad, empty_msg, last_partial,
    domain, core_reset, lfsr, tag_sel, rho_sel, tweak_sel, state_sel, clk_tag_en,
    ready_block, cipher_ready, tag_ready, ready_full);

    rho_computation: entity WORK.rho port map(running_state, rho_input, rho_s, rho_cipher);

    --tag_register: entity WORK.treg generic map (CLOCK_GATED => false) port map (clk, clk_tag_en, tag_in, tag_out);
    tag_register: entity WORK.FF generic map (SIZE => 128) port map (clk, tag_in, tag_out);

    ciphertext <= rho_cipher;
    tag <= rho_cipher;

end;
