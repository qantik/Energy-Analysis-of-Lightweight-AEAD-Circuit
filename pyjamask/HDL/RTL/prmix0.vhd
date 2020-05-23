
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- contains conversion functions

entity prmix0 is
  
  port (
    InpxDI : in  std_logic_vector(31 downto 0);
    OupxDO : out std_logic_vector(31 downto 0)
    );

end prmix0;



architecture rm of prmix0 is

  subtype Int4Type is integer range 0 to 31;
  type Int4Array is array (0 to 31) of Int4Type;
  constant A : Int4Array := (
  3, 15, 6, 16, 2, 9, 12, 21, 30, 5, 24, 25, 13, 17, 20, 4, 31, 26, 14, 7, 0, 11, 27, 1, 23, 28, 8, 29, 19, 22, 18, 10);


  signal x : std_logic_vector(96 downto 0);
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
 
x(032) <= x(000) xor x(008);
x(033) <= x(001) xor x(014);
x(034) <= x(002) xor x(021);
x(035) <= x(003) xor x(007);
x(036) <= x(004) xor x(019);
x(037) <= x(005) xor x(015);
x(038) <= x(006) xor x(013);
x(039) <= x(009) xor x(020);
x(040) <= x(010) xor x(027);
x(041) <= x(012) xor x(026);
x(042) <= x(016) xor x(017);
x(043) <= x(018) xor x(028);
x(044) <= x(022) xor x(029);
x(045) <= x(023) xor x(025);
x(046) <= x(024) xor x(030);
x(047) <= x(000) xor x(031);
x(048) <= x(011) xor x(031);
x(049) <= x(002) xor x(016);
x(050) <= x(003) xor x(005);
x(051) <= x(004) xor x(022);
x(052) <= x(006) xor x(009);
x(053) <= x(007) xor x(025);
x(054) <= x(008) xor x(024);
x(055) <= x(010) xor x(013);
x(056) <= x(011) xor x(020);
x(057) <= x(012) xor x(014);
x(058) <= x(015) xor x(027);
x(059) <= x(017) xor x(028);
x(060) <= x(018) xor x(019);
x(061) <= x(021) xor x(030);
x(062) <= x(023) xor x(026);
x(063) <= x(031) xor x(035);
x(064) <= x(032) xor x(041);
x(065) <= x(033) xor x(048);
x(066) <= x(034) xor x(035);
x(067) <= x(036) xor x(038);
x(068) <= x(037) xor x(042);
x(069) <= x(039) xor x(044);
x(070) <= x(040) xor x(043);
x(071) <= x(045) xor x(046);
x(072) <= x(001) xor x(036);
x(073) <= x(001) xor x(063);
x(074) <= x(002) xor x(060);
x(075) <= x(003) xor x(055);
x(076) <= x(004) xor x(047);
x(077) <= x(006) xor x(057);
x(078) <= x(008) xor x(049);
x(079) <= x(010) xor x(056);
x(080) <= x(011) xor x(014);
x(081) <= x(015) xor x(052);
x(082) <= x(017) xor x(051);
x(083) <= x(018) xor x(029);
x(084) <= x(020) xor x(062);
x(085) <= x(025) xor x(058);
x(086) <= x(026) xor x(050);
x(087) <= x(029) xor x(054);
x(088) <= x(030) xor x(059);
x(089) <= x(032) xor x(037);
x(090) <= x(033) xor x(053);
x(091) <= x(034) xor x(038);
x(092) <= x(039) xor x(042);
x(093) <= x(040) xor x(046);
x(094) <= x(041) xor x(072);
x(095) <= x(043) xor x(080);
x(096) <= x(044) xor x(045);

y(000) <= x(023) xor x(064) xor x(079) xor x(088);
y(001) <= x(023) xor x(051) xor x(068) xor x(095);
y(002) <= x(039) xor x(047) xor x(082) xor x(090);
y(003) <= x(000) xor x(058) xor x(066) xor x(096);
y(004) <= x(009) xor x(067) xor x(085) xor x(087);
y(005) <= x(009) xor x(049) xor x(064) xor x(093);
y(006) <= x(019) xor x(037) xor x(043) xor x(078) xor x(079);
y(007) <= x(019) xor x(062) xor x(065) xor x(092);
y(008) <= x(005) xor x(066) xor x(082) xor x(084);
y(009) <= x(005) xor x(047) xor x(067) xor x(096);
y(010) <= x(021) xor x(041) xor x(046) xor x(076) xor x(085);
y(011) <= x(021) xor x(052) xor x(070) xor x(089);
y(012) <= x(012) xor x(065) xor x(078) xor x(081);
y(013) <= x(012) xor x(060) xor x(066) xor x(092);
y(014) <= x(001) xor x(038) xor x(044) xor x(074) xor x(084);
y(015) <= x(050) xor x(071) xor x(094);
y(016) <= x(013) xor x(070) xor x(076) xor x(086);
y(017) <= x(013) xor x(061) xor x(065) xor x(089);
y(018) <= x(028) xor x(042) xor x(061) xor x(063) xor x(081);
y(019) <= x(028) xor x(057) xor x(069) xor x(091);
y(020) <= x(007) xor x(071) xor x(074) xor x(077);
y(021) <= x(007) xor x(029) xor x(070) xor x(094);
y(022) <= x(011) xor x(024) xor x(032) xor x(033) xor x(083) xor x(086);
y(023) <= x(024) xor x(055) xor x(068) xor x(073);
y(024) <= x(048) xor x(061) xor x(069) xor x(075);
y(025) <= x(011) xor x(059) xor x(071) xor x(091);
y(026) <= x(022) xor x(036) xor x(040) xor x(077) xor x(088);
y(027) <= x(022) xor x(053) xor x(064) xor x(095);
y(028) <= x(027) xor x(068) xor x(083) xor x(090);
y(029) <= x(027) xor x(054) xor x(069) xor x(073);
y(030) <= x(016) xor x(034) xor x(045) xor x(075) xor x(087);
y(031) <= x(016) xor x(056) xor x(067) xor x(093);


end architecture rm;
