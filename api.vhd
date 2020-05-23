library ieee;
use ieee.std_logic_1164.all;

entity aead is
    generic (key_size   : integer;
             nonce_size : integer;
             block_size : integer);
        
    port (clk   : in std_logic;
          reset : in std_logic; -- active low

          key   : in std_logic_vector(key_size-1 downto 0);
          nonce : in std_logic_vector(nonce_size-1 downto 0);

          -- A data block is either associated data or plaintext.
          -- last_block indicates whether the current ad or plaintext
          -- block is the last one with last_partial indicating whether
          -- said block is only partially filled.
          data         : in std_logic_vector(block_size-1 downto 0);
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

          ciphertext   : out std_logic_vector(block_size-1 downto 0);
          tag          : out std_logic_vector(block_size-1 downto 0));

end architecture aead;
