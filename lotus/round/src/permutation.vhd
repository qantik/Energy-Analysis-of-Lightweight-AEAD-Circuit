library ieee;
use ieee.std_logic_1164.all;

entity permutation is
    port (state_in  : in  std_logic_vector(63 downto 0);
          state_out : out std_logic_vector(63 downto 0));
end entity permutation;

architecture parallel of permutation is

    subtype int6type is integer range 0 to 63;
    type int6array is array (0 to 63) of int6type;
    constant table : int6array := (
        0, 17, 34, 51, 48, 1, 18, 35, 32, 49, 2, 19, 16, 33, 50, 3,
        4, 21, 38, 55, 52, 5, 22, 39, 36, 53, 6, 23, 20, 37, 54, 7,
        8, 25, 42, 59, 56, 9, 26, 43, 40, 57, 10, 27, 24, 41, 58, 11,
        12, 29, 46, 63, 60, 13, 30, 47, 44, 61, 14, 31, 28, 45, 62, 15
    );

   -- subtype int6type is integer range 0 to 127;
   -- type int6array is array (0 to 127) of int6type;
   -- constant table : int6array := (
   --     0, 33, 66, 99, 96, 1, 34, 67, 64, 97, 2, 35, 32, 65, 98, 3,
   --     4, 37, 70, 103, 100, 5, 38, 71, 68, 101, 6, 39, 36, 69, 102, 7,
   --     8, 41, 74, 107, 104, 9, 42, 75, 72, 105, 10, 43, 40, 73, 106, 11,
   --     12, 45, 78, 111, 108, 13, 46, 79, 76, 109, 14, 47, 44, 77, 110, 15,
   --     16, 49, 82, 115, 112, 17, 50, 83, 80, 113, 18, 51, 48, 81, 114, 19,
   --     20, 53, 86, 119, 116, 21, 54, 87, 84, 117, 22, 55, 52, 85, 118, 23,
   --     24, 57, 90, 123, 120, 25, 58, 91, 88, 121, 26, 59, 56, 89, 122, 27,
   --     28, 61, 94, 127, 124, 29, 62, 95, 92, 125, 30, 63, 60, 93, 126, 31);


    --subtype int6type is integer range 0 to 127;
    --type int6array is array (127 downto 0) of int6type;
    --constant table : int6array := (
    --    125, 121, 117, 113, 109, 105, 101, 97, 126, 122, 118, 114, 110, 106, 102, 98, 127, 123, 119, 115, 111, 107, 103, 99, 124, 120, 116, 112, 108, 104, 100, 96,  --0321
    --    94, 90, 86, 82, 78, 74, 70, 66, 95, 91, 87, 83, 79, 75, 71, 67, 92, 88, 84, 80, 76, 72, 68, 64, 93, 89, 85, 81, 77, 73, 69, 65,  --1032
    --    63, 59, 55, 51, 47, 43, 39, 35, 60, 56, 52, 48, 44, 40, 36, 32, 61, 57, 53, 49, 45, 41, 37, 33, 62, 58, 54, 50, 46, 42, 38, 34,  --2103
    --    28, 24, 20, 16, 12, 8, 4, 0, 29, 25, 21, 17, 13, 9, 5, 1, 30, 26, 22, 18, 14, 10, 6, 2, 31, 27, 23, 19, 15, 11, 7, 3  --3210
    --    );

begin

    gen : for i in 0 to 63 generate
        state_out(table(i)) <= state_in(i);
        --state_out(i) <= state_in(table(i));
    end generate;

end architecture parallel;
