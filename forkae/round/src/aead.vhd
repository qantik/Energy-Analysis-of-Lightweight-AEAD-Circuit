library ieee;
use ieee.std_logic_1164.all;

entity aead is
	generic (CLOCK_GATED : boolean := true);
    port (clk   : in std_logic;
          reset : in std_logic; -- active low

          key   : in std_logic_vector(127 downto 0);
          nonce : in std_logic_vector(103 downto 0);

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

    signal domain     : std_logic_vector(2 downto 0);
    signal tweakkey   : std_logic_vector(287 downto 0);
    signal nonce_ctr  : std_logic_vector(7 downto 0); -- reduced to 64 blocks (hence len is 1 byte)

    signal core       : std_logic_vector(127 downto 0);
    signal core_reset : std_logic;
    signal core_done  : std_logic;
    
    signal tag_in     : std_logic_vector(127 downto 0);
    signal tag_out    : std_logic_vector(127 downto 0);
    
    signal sel_out    : std_logic_vector(1 downto 0);
    signal tag_sel    : std_logic;
    signal ct_sel     : std_logic;

    signal clk_tmp_en : std_logic;
    signal clk_tag_en : std_logic;
    signal mode       : std_logic;
    signal completed  : std_logic;
    
begin

    tweakkey   <= key & nonce & domain & (44 downto 0 => '0') & nonce_ctr;
    
    skinny_core : entity WORK.FORKSKINNY generic map (R => 3, CLOCK_GATED => CLOCK_GATED) port map (clk, core_reset, mode, tweakkey, data, core_done, core);

    controller : entity WORK.aead_controller port map (clk, reset, core_done, last_block, empty_ad, empty_msg, last_partial,
    domain, core_reset, nonce_ctr, mode, tag_sel, ct_sel, clk_tag_en,
    ready_block, cipher_ready, tag_ready, ready_full);

    tag_register: entity WORK.xreg generic map (CLOCK_GATED => CLOCK_GATED) port map (clk, reset, clk_tag_en, tag_in, tag_out);
    --tmp_register: entity WORK.treg generic map (CLOCK_GATED => CLOCK_GATED) port map (clk, clk_tmp_en, core, tmp_out);
    --tag_in <= core xor tag_out;

    tag_in <= (core xor tag_out) when tag_sel = '0' else core;
    ciphertext <= core when ct_sel = '0' else (core xor tag_out);
    tag <= tag_in;

    

end;
