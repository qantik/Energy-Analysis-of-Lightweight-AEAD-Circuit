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
          data1        : in std_logic_vector(127 downto 0);
          data2        : in std_logic_vector(127 downto 0);
          data3        : in std_logic_vector(127 downto 0);
          
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

          ciphertext1  : out std_logic_vector(127 downto 0);
          ciphertext2  : out std_logic_vector(127 downto 0);
          ciphertext3  : out std_logic_vector(127 downto 0);
          
          tag1         : out std_logic_vector(127 downto 0);
          tag2         : out std_logic_vector(127 downto 0);
          tag3         : out std_logic_vector(127 downto 0)
          
          );
end;

architecture behaviour of aead is

    signal domain     : std_logic_vector(2 downto 0);
    signal tweakkey   : std_logic_vector(287 downto 0);
    signal nonce_ctr  : std_logic_vector(7 downto 0); -- reduced to 64 blocks (hence len is 1 byte)

    signal core1      : std_logic_vector(127 downto 0);
    signal core2      : std_logic_vector(127 downto 0);
    signal core3      : std_logic_vector(127 downto 0);
    
    signal core_reset : std_logic;
    signal core_done  : std_logic;
    
    signal tag_in1    : std_logic_vector(127 downto 0);
    signal tag_in2    : std_logic_vector(127 downto 0);
    signal tag_in3    : std_logic_vector(127 downto 0);
    
    signal tag_out1   : std_logic_vector(127 downto 0);
    signal tag_out2   : std_logic_vector(127 downto 0);
    signal tag_out3   : std_logic_vector(127 downto 0);
    
    signal sel_out    : std_logic_vector(1 downto 0);
    signal tag_sel    : std_logic;
    signal ct_sel     : std_logic;

    signal clk_tmp_en : std_logic;
    signal clk_tag_en : std_logic;
    signal mode       : std_logic;
    signal completed  : std_logic;
    
    signal r_in: std_logic_vector(127 downto 0);
    signal r_out: std_logic_vector(127 downto 0);
    signal t_xor: std_logic_vector(127 downto 0);
    signal t2_xor: std_logic_vector(127 downto 0);
    
begin

    tweakkey   <= key & nonce & domain & (44 downto 0 => '0') & nonce_ctr;
    
    skinny_core : entity WORK.FORKSKINNY generic map (CLOCK_GATED => CLOCK_GATED) port map (clk, core_reset, mode, tweakkey, data1,data2,data3, core_done, core1,core2,core3);
    
    r_in <= data1 xor data2 xor data3;
    r_out <= core1 xor core2 xor core3;
    t_xor <= tag_out1 xor tag_out2 xor tag_out3;
    t2_xor <= tag_in1 xor tag_in2 xor tag_in3;

    controller : entity WORK.aead_controller port map (clk, reset, core_done, last_block, empty_ad, empty_msg, last_partial,
    domain, core_reset, nonce_ctr, mode, tag_sel, ct_sel, clk_tag_en,
    ready_block, cipher_ready, tag_ready, ready_full);

    tag_register1: entity WORK.xreg generic map (CLOCK_GATED => CLOCK_GATED) port map (clk, reset, clk_tag_en, tag_in1, tag_out1);
    tag_register2: entity WORK.xreg generic map (CLOCK_GATED => CLOCK_GATED) port map (clk, reset, clk_tag_en, tag_in2, tag_out2);
    tag_register3: entity WORK.xreg generic map (CLOCK_GATED => CLOCK_GATED) port map (clk, reset, clk_tag_en, tag_in3, tag_out3);
    --tmp_register: entity WORK.treg generic map (CLOCK_GATED => CLOCK_GATED) port map (clk, clk_tmp_en, core, tmp_out);
    --tag_in <= core xor tag_out;

    tag_in1 <= (core1 xor tag_out1) when tag_sel = '0' else core1;
    tag_in2 <= (core2 xor tag_out2) when tag_sel = '0' else core2;
    tag_in3 <= (core3 xor tag_out3) when tag_sel = '0' else core3;
    
    ciphertext1 <= core1 when ct_sel = '0' else (core1 xor tag_out1);
    ciphertext2 <= core2 when ct_sel = '0' else (core2 xor tag_out2);
    ciphertext3 <= core3 when ct_sel = '0' else (core3 xor tag_out3);
    
    tag1 <= tag_in1;
    tag2 <= tag_in2;
    tag3 <= tag_in3;


end;
