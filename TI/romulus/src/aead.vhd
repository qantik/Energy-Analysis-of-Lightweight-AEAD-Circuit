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

    signal domain     : std_logic_vector(4 downto 0);
    signal tweakkey   : std_logic_vector(383 downto 0);
    signal lfsr       : std_logic_vector(55 downto 0);

    signal core1       : std_logic_vector(127 downto 0);
    signal core2       : std_logic_vector(127 downto 0);
    signal core3       : std_logic_vector(127 downto 0);
    
    signal core_reset : std_logic;
    signal core_done  : std_logic;
    
    signal tag_in1     : std_logic_vector(127 downto 0);
    signal tag_in2     : std_logic_vector(127 downto 0);
    signal tag_in3     : std_logic_vector(127 downto 0);
    
    signal running_state1: std_logic_vector(127 downto 0);
    signal running_state2: std_logic_vector(127 downto 0);
    signal running_state3: std_logic_vector(127 downto 0);
    
    signal rho_input1  : std_logic_vector(127 downto 0);
    signal rho_input2  : std_logic_vector(127 downto 0);
    signal rho_input3  : std_logic_vector(127 downto 0);
    
    signal rho_s1      : std_logic_vector(127 downto 0);
    signal rho_s2      : std_logic_vector(127 downto 0);
    signal rho_s3      : std_logic_vector(127 downto 0);
    
    signal rho_cipher1 : std_logic_vector(127 downto 0);
    signal rho_cipher2 : std_logic_vector(127 downto 0);
    signal rho_cipher3 : std_logic_vector(127 downto 0);
    

    signal tag_out1    : std_logic_vector(127 downto 0);
    signal tag_out2    : std_logic_vector(127 downto 0);
    signal tag_out3    : std_logic_vector(127 downto 0);
    
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
    
    tweak <= nonce when tweak_sel = '0' else data1;
    
    running_state1 <= (others => '0') when state_sel = '0' else tag_out1;
    running_state2 <= (others => '0') when state_sel = '0' else tag_out2;
    running_state3 <= (others => '0') when state_sel =  '0' else tag_out3;
    
    rho_input1 <= data1 when rho_sel = '0' else  (others => '0');
    rho_input2 <= data2 when rho_sel = '0' else  (others => '0');
    rho_input3 <= data3 when rho_sel = '0' else  (others => '0');
    
    tag_in1 <= rho_s1 when tag_sel ='0' else core1;
    tag_in2 <= rho_s2 when tag_sel ='0' else core2;
    tag_in3 <= rho_s3 when tag_sel ='0' else core3;

    skinny_core_th : entity WORK.SKINNY_TH port map (clk, core_reset, tweakkey, running_state1, running_state2, running_state3, core_done, core1, core2, core3);

    controller : entity WORK.aead_controller port map (clk, reset, core_done, last_block, empty_ad, empty_msg, last_partial,
    domain, core_reset, lfsr, tag_sel, rho_sel, tweak_sel, state_sel, clk_tag_en,
    ready_block, cipher_ready, tag_ready, ready_full);

    rho_computation1: entity WORK.rho port map(running_state1, rho_input1, rho_s1, rho_cipher1);
    rho_computation2: entity WORK.rho port map(running_state2, rho_input2, rho_s2, rho_cipher2);
    rho_computation3: entity WORK.rho port map(running_state3, rho_input3, rho_s3, rho_cipher3);

    --tag_register: entity WORK.treg generic map (CLOCK_GATED => false) port map (clk, clk_tag_en, tag_in, tag_out);
    tag_register1: entity WORK.FF generic map (SIZE => 128) port map (clk, tag_in1, tag_out1);
    tag_register2: entity WORK.FF generic map (SIZE => 128) port map (clk, tag_in2, tag_out2);
    tag_register3: entity WORK.FF generic map (SIZE => 128) port map (clk, tag_in3, tag_out3);

    ciphertext1 <= rho_cipher1;
    ciphertext2 <= rho_cipher2;
    ciphertext3 <= rho_cipher3;
    
    tag1 <= rho_cipher1;
    tag2 <= rho_cipher2;
    tag3 <= rho_cipher3;

end;
