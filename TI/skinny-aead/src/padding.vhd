--
-- SKINNY-AEAD Reference Hardware Implementation
-- 
-- Copyright 2019:
--     Amir Moradi & Pascal Sasdrich for the SKINNY Team
--     https://sites.google.com/site/skinnycipher/
-- 
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License as
-- published by the Free Software Foundation; either version 2 of the
-- License, or (at your option) any later version.
-- 
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
-- General Public License for more details.
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Padding is
	port(
		Input	  		: in  std_logic_vector(127 downto 0);
		Block_Size	: in  std_logic_vector(  3 downto 0);
		Output		: out std_logic_vector(127 downto 0));
end entity Padding;


architecture dfl of Padding is

	signal size	: unsigned(3 downto 0);

	constant v0	 : unsigned(3 downto 0) := "0000";
	constant v1	 : unsigned(3 downto 0) := "0001";
	constant v2	 : unsigned(3 downto 0) := "0010";
	constant v3	 : unsigned(3 downto 0) := "0011";
	constant v4	 : unsigned(3 downto 0) := "0100";
	constant v5	 : unsigned(3 downto 0) := "0101";
	constant v6	 : unsigned(3 downto 0) := "0110";
	constant v7	 : unsigned(3 downto 0) := "0111";
	constant v8	 : unsigned(3 downto 0) := "1000";
	constant v9	 : unsigned(3 downto 0) := "1001";
	constant v10 : unsigned(3 downto 0) := "1010";
	constant v11 : unsigned(3 downto 0) := "1011";
	constant v12 : unsigned(3 downto 0) := "1100";
	constant v13 : unsigned(3 downto 0) := "1101";
	constant v14 : unsigned(3 downto 0) := "1110";
	constant v15 : unsigned(3 downto 0) := "1111";
	
begin

	size	<= unsigned(Block_Size);

	Output(16*8-1 downto 15*8)	<= Input(16*8-1 downto 15*8);
	Output(15*8-1 downto 14*8)	<= Input(15*8-1 downto 14*8) when size > v0  else x"80";
	Output(14*8-1 downto 13*8)	<= Input(14*8-1 downto 13*8) when size > v1  else x"80" when size = v1  else x"00";
	Output(13*8-1 downto 12*8)	<= Input(13*8-1 downto 12*8) when size > v2  else x"80" when size = v2  else x"00";
	Output(12*8-1 downto 11*8)	<= Input(12*8-1 downto 11*8) when size > v3  else x"80" when size = v3  else x"00";
	Output(11*8-1 downto 10*8)	<= Input(11*8-1 downto 10*8) when size > v4  else x"80" when size = v4  else x"00";
	Output(10*8-1 downto  9*8)	<= Input(10*8-1 downto  9*8) when size > v5  else x"80" when size = v5  else x"00";
	Output( 9*8-1 downto  8*8)	<= Input( 9*8-1 downto  8*8) when size > v6  else x"80" when size = v6  else x"00";
	Output( 8*8-1 downto  7*8)	<= Input( 8*8-1 downto  7*8) when size > v7  else x"80" when size = v7  else x"00";
	Output( 7*8-1 downto  6*8)	<= Input( 7*8-1 downto  6*8) when size > v8  else x"80" when size = v8  else x"00";
	Output( 6*8-1 downto  5*8)	<= Input( 6*8-1 downto  5*8) when size > v9  else x"80" when size = v9  else x"00";
	Output( 5*8-1 downto  4*8)	<= Input( 5*8-1 downto  4*8) when size > v10 else x"80" when size = v10 else x"00";
	Output( 4*8-1 downto  3*8)	<= Input( 4*8-1 downto  3*8) when size > v11 else x"80" when size = v11 else x"00";
	Output( 3*8-1 downto  2*8)	<= Input( 3*8-1 downto  2*8) when size > v12 else x"80" when size = v12 else x"00";
	Output( 2*8-1 downto  1*8)	<= Input( 2*8-1 downto  1*8) when size > v13 else x"80" when size = v13 else x"00";
	Output( 1*8-1 downto  0*8)	<= Input( 1*8-1 downto  0*8) when size > v14 else x"80" when size = v14 else x"00";

end architecture;
