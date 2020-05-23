
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- contains conversion functions

entity prmix1 is
  
  port (
    InpxDI : in  std_logic_vector(31 downto 0);
    OupxDO : out std_logic_vector(31 downto 0)
    );

end prmix1;



architecture rm of prmix1 is

  subtype Int4Type is integer range 0 to 31;
  type Int4Array is array (0 to 31) of Int4Type;
  constant A : Int4Array := (
   22, 8, 14, 24, 2, 16, 3, 6, 10, 4, 1, 9, 25, 0, 29, 7, 20, 31, 27, 23, 21, 15, 30, 5, 28, 17, 11, 12, 18, 19, 26, 13);


  signal x : std_logic_vector(111 downto 0);
  signal y : std_logic_vector(31 downto 0);
begin  

----------------------------
a1: for i in 0 to 31 generate 
x(i)<= InpxDI(31-A(i));
end generate a1;


a2: for i in 0 to 31 generate 
OupxDO(i)<= y(31-i);
end generate a2;
----------------------------
 x(032) <= x(000) xor x(002);
x(033) <= x(001) xor x(003);
x(034) <= x(004) xor x(008);
x(035) <= x(005) xor x(013);
x(036) <= x(006) xor x(018);
x(037) <= x(007) xor x(022);
x(038) <= x(009) xor x(016);
x(039) <= x(010) xor x(011);
x(040) <= x(012) xor x(025);
x(041) <= x(014) xor x(020);
x(042) <= x(015) xor x(017);
x(043) <= x(019) xor x(021);
x(044) <= x(023) xor x(031);
x(045) <= x(024) xor x(027);
x(046) <= x(026) xor x(029);
x(047) <= x(028) xor x(030);
x(048) <= x(000) xor x(037);
x(049) <= x(001) xor x(035);
x(050) <= x(002) xor x(037);
x(051) <= x(003) xor x(035);
x(052) <= x(004) xor x(047);
x(053) <= x(005) xor x(033);
x(054) <= x(006) xor x(046);
x(055) <= x(007) xor x(032);
x(056) <= x(008) xor x(047);
x(057) <= x(009) xor x(045);
x(058) <= x(010) xor x(040);
x(059) <= x(011) xor x(040);
x(060) <= x(012) xor x(039);
x(061) <= x(013) xor x(033);
x(062) <= x(014) xor x(044);
x(063) <= x(015) xor x(043);
x(064) <= x(016) xor x(045);
x(065) <= x(017) xor x(043);
x(066) <= x(018) xor x(046);
x(067) <= x(019) xor x(042);
x(068) <= x(020) xor x(044);
x(069) <= x(021) xor x(042);
x(070) <= x(022) xor x(032);
x(071) <= x(023) xor x(041);
x(072) <= x(024) xor x(038);
x(073) <= x(025) xor x(039);
x(074) <= x(026) xor x(036);
x(075) <= x(027) xor x(038);
x(076) <= x(028) xor x(034);
x(077) <= x(029) xor x(036);
x(078) <= x(030) xor x(034);
x(079) <= x(031) xor x(041);
x(080) <= x(000) xor x(078);
x(081) <= x(001) xor x(064);
x(082) <= x(002) xor x(052);
x(083) <= x(003) xor x(057);
x(084) <= x(004) xor x(055);
x(085) <= x(005) xor x(072);
x(086) <= x(006) xor x(063);
x(087) <= x(007) xor x(056);
x(088) <= x(008) xor x(070);
x(089) <= x(009) xor x(053);
x(090) <= x(010) xor x(068);
x(091) <= x(011) xor x(079);
x(092) <= x(012) xor x(062);
x(093) <= x(013) xor x(075);
x(094) <= x(014) xor x(073);
x(095) <= x(015) xor x(066);
x(096) <= x(016) xor x(061);
x(097) <= x(017) xor x(054);
x(098) <= x(018) xor x(069);
x(099) <= x(019) xor x(074);
x(100) <= x(020) xor x(060);
x(101) <= x(021) xor x(077);
x(102) <= x(022) xor x(076);
x(103) <= x(023) xor x(059);
x(104) <= x(024) xor x(049);
x(105) <= x(025) xor x(071);
x(106) <= x(026) xor x(065);
x(107) <= x(027) xor x(051);
x(108) <= x(028) xor x(048);
x(109) <= x(029) xor x(067);
x(110) <= x(030) xor x(050);
x(111) <= x(031) xor x(058);

y(000) <= x(065) xor x(110) xor x(111);
y(001) <= x(051) xor x(082) xor x(098);
y(002) <= x(058) xor x(101) xor x(104);
y(003) <= x(052) xor x(085) xor x(094);
y(004) <= x(077) xor x(102) xor x(105);
y(005) <= x(072) xor x(097) xor x(108);
y(006) <= x(071) xor x(093) xor x(109);
y(007) <= x(048) xor x(090) xor x(096);
y(008) <= x(067) xor x(084) xor x(100);
y(009) <= x(061) xor x(080) xor x(086);
y(010) <= x(060) xor x(089) xor x(099);
y(011) <= x(078) xor x(083) xor x(103);
y(012) <= x(074) xor x(087) xor x(092);
y(013) <= x(057) xor x(095) xor x(110);
y(014) <= x(062) xor x(081) xor x(098);
y(015) <= x(050) xor x(091) xor x(104);
y(016) <= x(069) xor x(088) xor x(094);
y(017) <= x(049) xor x(102) xor x(106);
y(018) <= x(073) xor x(097) xor x(107);
y(019) <= x(076) xor x(093) xor x(111);
y(020) <= x(054) xor x(082) xor x(090);
y(021) <= x(075) xor x(084) xor x(101);
y(022) <= x(068) xor x(085) xor x(086);
y(023) <= x(055) xor x(089) xor x(105);
y(024) <= x(063) xor x(103) xor x(108);
y(025) <= x(053) xor x(087) xor x(109);
y(026) <= x(059) xor x(095) xor x(096);
y(027) <= x(056) xor x(081) xor x(100);
y(028) <= x(066) xor x(080) xor x(091);
y(029) <= x(064) xor x(088) xor x(099);
y(030) <= x(079) xor x(083) xor x(106);
y(031) <= x(070) xor x(092) xor x(107);



end architecture rm;
