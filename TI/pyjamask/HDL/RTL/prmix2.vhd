
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- contains conversion functions

entity prmix2 is
  
  port (
    InpxDI : in  std_logic_vector(31 downto 0);
    OupxDO : out std_logic_vector(31 downto 0)
    );

end prmix2;



architecture rm of prmix2 is

  subtype Int4Type is integer range 0 to 31;
  type Int4Array is array (0 to 31) of Int4Type;
  constant A : Int4Array := (
   19, 9, 21, 25, 23, 7, 28, 20, 5, 17, 3, 11, 6, 27, 14, 22, 30, 1, 10, 29, 2, 12, 15, 31, 18, 8, 4, 26, 16, 0, 24, 13);


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
 x(032) <= x(000) xor x(003);
x(033) <= x(001) xor x(010);
x(034) <= x(002) xor x(013);
x(035) <= x(004) xor x(009);
x(036) <= x(005) xor x(017);
x(037) <= x(006) xor x(015);
x(038) <= x(007) xor x(014);
x(039) <= x(008) xor x(011);
x(040) <= x(012) xor x(021);
x(041) <= x(016) xor x(026);
x(042) <= x(018) xor x(028);
x(043) <= x(020) xor x(025);
x(044) <= x(024) xor x(030);
x(045) <= x(027) xor x(029);
x(046) <= x(019) xor x(045);
x(047) <= x(031) xor x(042);
x(048) <= x(022) xor x(033);
x(049) <= x(022) xor x(034);
x(050) <= x(023) xor x(032);
x(051) <= x(023) xor x(039);
x(052) <= x(035) xor x(038);
x(053) <= x(036) xor x(041);
x(054) <= x(019) xor x(031);
x(055) <= x(037) xor x(050);
x(056) <= x(040) xor x(048);
x(057) <= x(043) xor x(051);
x(058) <= x(044) xor x(049);
x(059) <= x(004) xor x(044);
x(060) <= x(005) xor x(043);
x(061) <= x(011) xor x(040);
x(062) <= x(013) xor x(037);
x(063) <= x(000) xor x(010);
x(064) <= x(000) xor x(026);
x(065) <= x(001) xor x(014);
x(066) <= x(001) xor x(027);
x(067) <= x(002) xor x(008);
x(068) <= x(002) xor x(036);
x(069) <= x(003) xor x(007);
x(070) <= x(004) xor x(006);
x(071) <= x(005) xor x(021);
x(072) <= x(006) xor x(024);
x(073) <= x(007) xor x(010);
x(074) <= x(008) xor x(035);
x(075) <= x(009) xor x(017);
x(076) <= x(009) xor x(019);
x(077) <= x(011) xor x(028);
x(078) <= x(012) xor x(015);
x(079) <= x(012) xor x(028);
x(080) <= x(013) xor x(029);
x(081) <= x(014) xor x(057);
x(082) <= x(015) xor x(029);
x(083) <= x(016) xor x(025);
x(084) <= x(016) xor x(054);
x(085) <= x(017) xor x(031);
x(086) <= x(018) xor x(030);
x(087) <= x(020) xor x(021);
x(088) <= x(020) xor x(024);
x(089) <= x(022) xor x(023);
x(090) <= x(025) xor x(027);
x(091) <= x(030) xor x(060);
x(092) <= x(032) xor x(047);
x(093) <= x(033) xor x(046);
x(094) <= x(034) xor x(053);
x(095) <= x(038) xor x(055);
x(096) <= x(039) xor x(052);
x(097) <= x(041) xor x(056);
x(098) <= x(042) xor x(058);
x(099) <= x(046) xor x(052);
x(100) <= x(047) xor x(053);

y(000) <= x(022) xor x(047) xor x(083) xor x(095);
y(001) <= x(001) xor x(002) xor x(077) xor x(089) xor x(099);
y(002) <= x(016) xor x(021) xor x(075) xor x(082) xor x(098);
y(003) <= x(035) xor x(055) xor x(077) xor x(085) xor x(088);
y(004) <= x(044) xor x(063) xor x(087) xor x(099);
y(005) <= x(032) xor x(041) xor x(058) xor x(073) xor x(085);
y(006) <= x(020) xor x(026) xor x(027) xor x(028) xor x(067) xor x(095);
y(007) <= x(046) xor x(049) xor x(073) xor x(074) xor x(078);
y(008) <= x(037) xor x(059) xor x(079) xor x(094);
y(009) <= x(019) xor x(055) xor x(074) xor x(091);
y(010) <= x(012) xor x(059) xor x(069) xor x(083) xor x(093);
y(011) <= x(050) xor x(066) xor x(086) xor x(094);
y(012) <= x(018) xor x(045) xor x(057) xor x(062) xor x(069);
y(013) <= x(017) xor x(034) xor x(061) xor x(070) xor x(093);
y(014) <= x(053) xor x(054) xor x(062) xor x(086) xor x(087);
y(015) <= x(003) xor x(010) xor x(070) xor x(081) xor x(084);
y(016) <= x(014) xor x(023) xor x(030) xor x(046) xor x(097);
y(017) <= x(003) xor x(008) xor x(080) xor x(089) xor x(100);
y(018) <= x(006) xor x(045) xor x(075) xor x(079) xor x(081);
y(019) <= x(036) xor x(056) xor x(076) xor x(080) xor x(088);
y(020) <= x(043) xor x(063) xor x(072) xor x(100);
y(021) <= x(033) xor x(038) xor x(057) xor x(064) xor x(076);
y(022) <= x(007) xor x(018) xor x(024) xor x(029) xor x(067) xor x(097);
y(023) <= x(047) xor x(051) xor x(064) xor x(068) xor x(078);
y(024) <= x(040) xor x(060) xor x(082) xor x(096);
y(025) <= x(025) xor x(031) xor x(056) xor x(059) xor x(068);
y(026) <= x(015) xor x(026) xor x(065) xor x(091) xor x(092);
y(027) <= x(003) xor x(018) xor x(048) xor x(090) xor x(096);
y(028) <= x(026) xor x(061) xor x(066) xor x(098);
y(029) <= x(009) xor x(039) xor x(062) xor x(071) xor x(092);
y(030) <= x(052) xor x(054) xor x(061) xor x(072) xor x(090);
y(031) <= x(000) xor x(058) xor x(065) xor x(071) xor x(084);




end architecture rm;
