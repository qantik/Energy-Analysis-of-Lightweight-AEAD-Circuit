library ieee;
use ieee.std_logic_1164.all;

use ieee.numeric_std.all;
use std.textio.all;
use work.all;


entity deltaupdate is
  port (
         DinxDI  : in  std_logic_vector(63 downto 0);
         SelxSI  : in  std_logic_vector(3 downto 0); 
         DoutxDO : out std_logic_vector(63 downto 0)
       );
end deltaupdate;

--architecture parallel of deltaupdate is
--
--
--signal MSBxD , A1xD , A3xD, A4xD : std_logic;
--
--signal DAxD : std_logic_vector(63 downto 0);
--
--
--
--begin
--
--MSBxD <= DinxDI(63);
--
--A1xD <= MSBxD xor DinxDI(0);
--A3xD <= MSBxD xor DinxDI(2);
--A4xD <= MSBxD xor DinxDI(3);
--
--
--
--DAxD <= DinxDI(62 downto 4) & A4xD & A3xD & DinxDI(1) & A1xD & MSBxD;
--
--
--a: for i in 0 to 63 generate 
--   
--   DoutxDO (i) <= (SelxSI(1) nand DAxD(i))  xor (SelxSI(0) nand DinxDI(i));
--
--end generate a;
--
--
---- 11 = 1+b
---- 10 = b
---- 01 = I
---- 00 = res
--
--
--end architecture parallel;

    
architecture parallel of deltaupdate is


signal MSBxD , A1xD , A3xD, A4xD : std_logic_vector(3 downto 0);

signal DAxD : std_logic_vector(4*64-1 downto 0);
signal temp : std_logic_vector(4*64-1 downto 0);

begin

    l : for i in 0 to 3 generate
        ll0 : if i = 0 generate
            MSBxD(0) <= DinxDI(63);
            
            A1xD(0) <= MSBxD(0) xor DinxDI(0);
            A3xD(0) <= MSBxD(0) xor DinxDI(2);
            A4xD(0) <= MSBxD(0) xor DinxDI(3);
            
            DAxD(63 downto 0) <= DinxDI(62 downto 4) & A4xD(0) & A3xD(0) & DinxDI(1) & A1xD(0) & MSBxD(0);
            
            a: for j in 0 to 63 generate 
                temp(j) <= (SelxSI(1) nand DAxD(j)) xor (SelxSI(0) nand DinxDI(j));
            end generate a;
        end generate ll0;

        ll1 : if i /= 0 generate
            MSBxD(i) <= temp(i*64-1);
            
            A1xD(i) <= MSBxD(i) xor temp((i-1)*64);
            A3xD(i) <= MSBxD(i) xor temp((i-1)*64+2);
            A4xD(i) <= MSBxD(i) xor temp((i-1)*64+3);
            
            DAxD((i+1)*64-1 downto i*64) <=
                temp((i)*64-2 downto (i-1)*64+4) & A4xD(i) & A3xD(i) & temp((i-1)*64+1) & A1xD(i) & MSBxD(i);
            
            a: for j in 0 to 63 generate 
                --temp(i*64+j) <= (not DAxD(i*64+j)) xor (not temp((i-1)*64+j));
                temp(i*64+j) <= DAxD(i*64+j) xor temp((i-1)*64+j);
            end generate a;
        end generate ll1;
        
    end generate;

    --DoutxDO <= temp(4*64-1 downto 3*64);

    DoutxDO <= temp(63 downto 0)    when SelxSI(2) = '0' and SelxSI(3) = '0' else
               temp(127 downto 64)  when SelxSI(2) = '1' and SelxSI(3) = '0' else
               temp(191 downto 128) when SelxSI(2) = '0' and SelxSI(3) = '1' else
               temp(255 downto 192);

-- 11 = 1+b
-- 10 = b
-- 01 = I
-- 00 = res


 end architecture parallel;
