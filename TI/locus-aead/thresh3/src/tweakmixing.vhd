library ieee;
use ieee.std_logic_1164.all;

entity tweakmixing is
    port (state_in  : in std_logic_vector(63 downto 0);
          round_cst : in std_logic_vector(5 downto 0);
          tweak     : in std_logic_vector(3 downto 0);
          state_out : out std_logic_vector(63 downto 0));
end entity tweakmixing;

architecture parallel of tweakmixing is
    signal tx        : std_logic;
    signal t         : std_logic_vector(15 downto 0);
    signal state_tmp : std_logic_vector(63 downto 0);
begin
    tx <= tweak(0) xor tweak(1) xor tweak(2) xor tweak(3);

    t(0) <= tweak(0);
    t(1) <= tweak(1);
    t(2) <= tweak(2);
    t(3) <= tweak(3);

    t(4) <= tweak(0) xor tx;
    t(5) <= tweak(1) xor tx;
    t(6) <= tweak(2) xor tx;
    t(7) <= tweak(3) xor tx;

    f1 : for i in 0 to 7 generate
        t(i+8) <= t(i);
    end generate;

    -- f2 : for i in 0 to 15 generate
    --     state_tmp(4*i+2) <= state_in(4*i+2) xor t(i);
    -- end generate;
    f2 : for i in 0 to 63 generate
        f21 : if (i-2) mod 4 = 0 generate
            state_tmp(i) <= state_in(i) xor t(i/4);
        end generate;
        f22 : if (i-2) mod 4 /= 0 generate
            state_tmp(i) <= state_in(i);
        end generate;
    end generate;

    output : process(state_in, round_cst, state_tmp)
    begin
        case round_cst is
            when "001111" => state_out <= state_tmp;
            when "111011" => state_out <= state_tmp;
            when "111100" => state_out <= state_tmp;
            when "001110" => state_out <= state_tmp;
            when "101011" => state_out <= state_tmp;
            when "110000" => state_out <= state_tmp;
            when others => state_out <= state_in;
        end case;
    end process output;
    
end architecture parallel;

