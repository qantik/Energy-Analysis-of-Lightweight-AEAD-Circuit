
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- contains conversion functions

entity prmixk is
  
  port (
    InpxDI : in  std_logic_vector(31 downto 0);
    OupxDO : out std_logic_vector(31 downto 0)
    );

end prmixk;



architecture rm of prmixk is

  subtype Int4Type is integer range 0 to 31;
  type Int4Array is array (0 to 31) of Int4Type;
  constant A : Int4Array := (
   11, 1, 12, 24, 5, 28, 9, 8, 29, 26, 30, 3, 0, 27, 23, 20, 6, 25, 10, 15, 21, 14, 22, 17, 4, 31, 13, 2, 16, 7, 18, 19 );


  signal x : std_logic_vector(125 downto 0);
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
 


x(032) <= x(000)  xor x(013);
x(033) <= x(001)  xor x(023);
x(034) <= x(002)  xor x(005);
x(035) <= x(003)  xor x(007);
x(036) <= x(004)  xor x(020);
x(037) <= x(006)  xor x(017);
x(038) <= x(008)  xor x(026);
x(039) <= x(009)  xor x(018);
x(040) <= x(010)  xor x(021);
x(041) <= x(011)  xor x(031);
x(042) <= x(012)  xor x(028);
x(043) <= x(014)  xor x(029);
x(044) <= x(015)  xor x(024);
x(045) <= x(016)  xor x(022);
x(046) <= x(019)  xor x(025);
x(047) <= x(027)  xor x(030);
x(048) <= x(032)  xor x(034);
x(049) <= x(032)  xor x(037);
x(050) <= x(033)  xor x(036);
x(051) <= x(033)  xor x(042);
x(052) <= x(034)  xor x(035);
x(053) <= x(035)  xor x(043);
x(054) <= x(036)  xor x(044);
x(055) <= x(038)  xor x(040);
x(056) <= x(039)  xor x(040);
x(057) <= x(041)  xor x(046);
x(058) <= x(041)  xor x(047);
x(059) <= x(000)  xor x(047);
x(060) <= x(006)  xor x(042);
x(061) <= x(008)  xor x(044);
x(062) <= x(009)  xor x(045);
x(063) <= x(010)  xor x(039);
x(064) <= x(011)  xor x(046);
x(065) <= x(012)  xor x(043);
x(066) <= x(013)  xor x(047);
x(067) <= x(016)  xor x(038);
x(068) <= x(017)  xor x(042);
x(069) <= x(018)  xor x(045);
x(070) <= x(021)  xor x(039);
x(071) <= x(022)  xor x(038);
x(072) <= x(026)  xor x(044);
x(073) <= x(028)  xor x(043);
x(074) <= x(031)  xor x(046);
x(075) <= x(000)  xor x(073);
x(076) <= x(001)  xor x(005);
x(077) <= x(001)  xor x(067);
x(078) <= x(002)  xor x(023);
x(079) <= x(002)  xor x(029);
x(080) <= x(003)  xor x(061);
x(081) <= x(003)  xor x(074);
x(082) <= x(004)  xor x(012);
x(083) <= x(004)  xor x(018);
x(084) <= x(005)  xor x(014);
x(085) <= x(006)  xor x(021);
x(086) <= x(007)  xor x(064);
x(087) <= x(007)  xor x(072);
x(088) <= x(008)  xor x(027);
x(089) <= x(009)  xor x(020);
x(090) <= x(010)  xor x(017);
x(091) <= x(011)  xor x(063);
x(092) <= x(013)  xor x(065);
x(093) <= x(014)  xor x(030);
x(094) <= x(015)  xor x(019);
x(095) <= x(015)  xor x(068);
x(096) <= x(016)  xor x(059);
x(097) <= x(019)  xor x(069);
x(098) <= x(020)  xor x(028);
x(099) <= x(022)  xor x(066);
x(100) <= x(023)  xor x(071);
x(101) <= x(024)  xor x(025);
x(102) <= x(024)  xor x(060);
x(103) <= x(025)  xor x(062);
x(104) <= x(026)  xor x(030);
x(105) <= x(027)  xor x(029);
x(106) <= x(031)  xor x(070);
x(107) <= x(032)  xor x(051);
x(108) <= x(033)  xor x(037);
x(109) <= x(034)  xor x(051);
x(110) <= x(035)  xor x(054);
x(111) <= x(036)  xor x(049);
x(112) <= x(037)  xor x(050);
x(113) <= x(037)  xor x(052);
x(114) <= x(040)  xor x(058);
x(115) <= x(041)  xor x(049);
x(116) <= x(045)  xor x(048);
x(117) <= x(045)  xor x(053);
x(118) <= x(050)  xor x(058);
x(119) <= x(052)  xor x(055);
x(120) <= x(053)  xor x(115);
x(121) <= x(054)  xor x(057);
x(122) <= x(055)  xor x(108);
x(123) <= x(056)  xor x(116);
x(124) <= x(057)  xor x(107);

y(000) <= x(023)  xor x(102)  xor x(105)  xor x(119);
y(001) <= x(030)  xor x(083)  xor x(086)  xor x(122);
y(002) <= x(056)  xor x(074)  xor x(096)  xor x(102);
y(003) <= x(015)  xor x(079)  xor x(083)  xor x(124);
y(004) <= x(020)  xor x(087)  xor x(096)  xor x(109);
y(005) <= x(071)  xor x(079)  xor x(085)  xor x(118);
y(006) <= x(014)  xor x(087)  xor x(097)  xor x(114);
y(007) <= x(003)  xor x(075)  xor x(085)  xor x(121);
y(008) <= x(068)  xor x(078)  xor x(097)  xor x(110);
y(009) <= x(062)  xor x(075)  xor x(104)  xor x(112);
y(010) <= x(066)  xor x(078)  xor x(106)  xor x(117);
y(011) <= x(005)  xor x(094)  xor x(104)  xor x(120);
y(012) <= x(061)  xor x(098)  xor x(106)  xor x(113);
y(013) <= x(063)  xor x(094)  xor x(100)  xor x(111);
y(014) <= x(025)  xor x(093)  xor x(098)  xor x(123);
y(015) <= x(048)  xor x(065)  xor x(081)  xor x(100);
y(016) <= x(001)  xor x(093)  xor x(095)  xor x(119);
y(017) <= x(027)  xor x(081)  xor x(089)  xor x(122);
y(018) <= x(056)  xor x(064)  xor x(095)  xor x(099);
y(019) <= x(024)  xor x(084)  xor x(089)  xor x(124);
y(020) <= x(004)  xor x(080)  xor x(099)  xor x(109);
y(021) <= x(067)  xor x(084)  xor x(090)  xor x(118);
y(022) <= x(029)  xor x(080)  xor x(103)  xor x(114);
y(023) <= x(007)  xor x(090)  xor x(092)  xor x(121);
y(024) <= x(060)  xor x(076)  xor x(103)  xor x(110);
y(025) <= x(069)  xor x(088)  xor x(092)  xor x(112);
y(026) <= x(059)  xor x(076)  xor x(091)  xor x(117);
y(027) <= x(002)  xor x(088)  xor x(101)  xor x(120);
y(028) <= x(072)  xor x(082)  xor x(091)  xor x(113);
y(029) <= x(070)  xor x(077)  xor x(101)  xor x(111);
y(030) <= x(019)  xor x(082)  xor x(105)  xor x(123);
y(031) <= x(048)  xor x(073)  xor x(077)  xor x(086);


end architecture rm;
