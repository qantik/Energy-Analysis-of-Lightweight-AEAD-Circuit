library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity SKINNY is
    generic (R : integer := 8);
    port (CLK       : in std_logic;
          RESET     : in std_logic;
          KEY       : in std_logic_vector (383 downto 0);
          PLAINTEXT : in std_logic_vector (127 downto 0);

          DONE       : out std_logic;
          CIPHERTEXT : out std_logic_vector (127 downto 0));
end SKINNY;

architecture STRUCTURAL of SKINNY is

    constant b : integer := 128;
    constant t : integer := 384;
    constant d : integer := 6;

    signal round_key   : std_logic_vector(383 downto 0);
    signal round_cst   : std_logic_vector(5 downto 0);
    signal round_state : std_logic_vector(127 downto 0);

    signal domains : std_logic_vector((R+1)*d-1 downto 0);
    signal keys    : std_logic_vector((R+1)*t-1 downto 0);
    signal states  : std_logic_vector((R+1)*b-1 downto 0);

begin

    DOM_REG : entity WORK.SCANFF
        generic map (SIZE => d)
        port map (CLK, domains((R+1)*d-1 downto R*d), domains(d-1 downto 0));
    KEY_REG : entity WORK.SCANFF
        generic map (SIZE => t)
        port map (CLK, keys((R+1)*t-1 downto R*t), keys(t-1 downto 0));
    STATE_REG : entity WORK.SCANFF
        generic map (SIZE => b)
        port map (CLK, states((R+1)*b-1 downto R*b), states(b-1 downto 0));

    -- Do not buffer data before the first round. This synchronoulsy resets the
    -- core on the rising clock edge. Also saves some gates since flipflops
    -- do not require a reset mechanism.
    round_cst   <= "000000"  when RESET = '1' else domains(d-1 downto 0);
    round_key   <= KEY       when RESET = '1' else keys(t-1 downto 0);
    round_state <= PLAINTEXT when RESET = '1' else states(b-1 downto 0);

    KE1 : entity work.KeyExpansion
        port map (round_key, keys(2*t-1 downto t));
    CL1 : entity work.ControlLogic
        port map (round_cst, domains(2*d-1 downto d));
    RF1 : entity work.RoundFunction
        port map (domains(2*d-1 downto d), round_key, round_state, states(2*b-1 downto b));

    ROUNDS: for i in 1 to R-1 generate
        KE : entity work.KeyExpansion
            port map (keys((i+1)*t-1 downto i*t), keys((i+2)*t-1 downto (i+1)*t));
        CL : entity work.ControlLogic
            port map (domains((i+1)*d-1 downto i*d), domains((i+2)*d-1 downto (i+1)*d));
        RF : entity work.RoundFunction
            port map (domains((i+2)*d-1 downto (i+1)*d), keys((i+1)*t-1 downto i*t), states((i+1)*b-1 downto i*b), states((i+2)*b-1 downto (i+1)*b));
    end generate;

    II : if (56 mod R) = 0 generate
      DONE       <= '1' when domains((R+1)*d-1 downto R*d) = "001010" else '0';
      CIPHERTEXT <= states((R+1)*b-1 downto R*b);
    end generate;
    IT : if (56 mod R) /= 0 generate
      DONE       <= '1' when domains(((56 mod R)+1)*d-1 downto (56 mod R)*d) = "001010" else '0';
      CIPHERTEXT <= states(((56 mod R)+1)*b-1 downto (56 mod R)*b);
    end generate;

end STRUCTURAL;
