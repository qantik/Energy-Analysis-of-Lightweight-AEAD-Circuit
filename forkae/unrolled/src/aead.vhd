library ieee;
use ieee.std_logic_1164.all;

entity aead is
    generic (CLOCK_GATED : boolean := false; inverse_gated : boolean := false);
    port (clk   : in std_logic;
          iclk  : in std_logic;
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
    
    signal tag_in     : std_logic_vector(127 downto 0);
    signal tag_out    : std_logic_vector(127 downto 0);
    
    signal C0, C1     : std_logic_vector(127 downto 0);
    
    signal tag_sel    : std_logic;
    signal ct_sel     : std_logic;
    signal completed  : std_logic;
    signal tag_enable : std_logic;
    
begin

    tweakkey   <= key & nonce & domain & (44 downto 0 => '0') & nonce_ctr;
    skinny_core : entity WORK.FORKSKINNY generic map (inverse_gated => inverse_gated) port map (clk, iclk, tweakkey, data, C0, C1); -- clk is only for inverse_gating 

    controller : entity WORK.AEAD_CONTROLLER port map (clk, reset, last_block, empty_ad, empty_msg, last_partial, 
    domain, nonce_ctr, tag_sel, ct_sel, tag_enable,
    cipher_ready, tag_ready, ready_block, ready_full);

    tag_register: entity WORK.treg generic map (CLOCK_GATED => CLOCK_GATED) port map (clk, tag_enable, tag_in, tag_out);
    --tag_register: entity WORK.FF generic map (SIZE => 128) port map (clk, tag_in, tag_out);
    
    
    --tag_in <= C1 xor tag_out;
    tag_in <= (C1 xor tag_out) when tag_sel = '0' else C1;
    ciphertext <= C0 when ct_sel = '0' else (C0 xor tag_out);
    tag <= tag_in;

end;
