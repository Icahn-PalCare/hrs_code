libname hrs 'E:\data\hrs_cleaned';
libname claims 'E:\data\cms_DUA_24548_2012';

data core(keep = hhid pn id core_year c_ivw_month c_ivw_day c_ivw_year c_ivw_date);
set hrs.core_00_to_12;
run;

data core;
set core;
year = core_year;
year_n1 = core_year-1;
year_n2 = core_year-2;
run;

proc sql;
create table core_bid as select a.*, b.bid_hrs_21
from core a
inner join claims.cmsxref2012 b 
on a.id = b.hhidpn; 
quit;

data dn_2012;
set claims.dn_2000_2012;
hmo_n1 = hmoind12;
hmo_n2 = hmoind12;
buyin_n1 = buyin12;
buyin_n2 = buyin12;
run;


proc sort data=dn_2012 nouniquekeys uniqueout=test out=dups; by bid_hrs_21 year; run;

proc sql;
create table core_dn as select a.*, b.buyin12, b.hmoind12
from core_bid a
left join dn_2012 b
on a.bid_hrs_21 = b.bid_hrs_21 and a.year = b.year;
quit;

proc sort data=core_dn nodupkey; by bid_hrs_21 year; run; 

proc sql;
create table core_dn2 as select a.*, b.buyin_n1, b.hmo_n1
from core_dn a
left join dn_2012 b
on a.bid_hrs_21 = b.bid_hrs_21 and a.year_n1 = b.year;
quit;

proc sort data=core_dn2 nodupkey; by bid_hrs_21 year_n1; run;

proc sql;
create table core_dn3 as select a.*, b.buyin_n2, b.hmo_n2
from core_dn2 a
left join dn_2012 b
on a.bid_hrs_21 = b.bid_hrs_21 and a.year_n2=b.year;
quit;

proc sort data=core_dn3 nodupkey; by bid_hrs_21 year_n2; run;


data core_dn3;
set core_dn3;
buyin_sy = substr(trim(left(buyin12)),1,c_ivw_month);
hmo_sy = substr(trim(left(buyin12)),1,c_ivw_month);
run;

data core_dn3;
set core_dn3;
buyin_sy_r = reverse(trim(buyin_sy));
hmo_sy_r = reverse(trim(hmo_sy));
buyin_l = lengthn(buyin12);
hmo_l = lengthn(hmoind12);
buyin_n1_l = lengthn(buyin_n1);
buyin_n2_l = lengthn(buyin_n2);
hmo_n1_l = lengthn(hmo_n1);
hmo_n2_l = lengthn(hmo_n2);
run;

proc freq data=core_dn3; tables buyin_n1_l buyin_n2_l hmo_n1_l hmo_n2_l; run;

data core_dn3;
set core_dn3;
if buyin_l = 0 then buyin_sy_r = "GGGGGGGGGGGG";
if hmo_l = 0 then hmo_sy_r = "GGGGGGGGGGGG";
if buyin_n1_l = 0 then buyin_n1 = "GGGGGGGGGGGG";
if buyin_n2_l = 0 then buyin_n2 = "GGGGGGGGGGGG";
if hmo_n1_l = 0 then hmo_n1 = "GGGGGGGGGGGG";
if hmo_n2_l = 0 then hmo_n2 = "GGGGGGGGGGGG";
buy_n1_r = reverse(trim(buyin_n1));
buy_n2_r = reverse(trim(buyin_n2));
hmo_n1_r = reverse(trim(hmo_n1));
hmo_n2_r = reverse(trim(hmo_n2));
run;

data core_dn3;
set core_dn3;
buyin_24 = trim(left(buyin_sy_r))||trim(left(buy_n1_r))||trim(left(buy_n2_r));
hmo_24 = trim(left(hmo_sy_r))||trim(left(hmo_n1_r))||trim(left(hmo_n2_r));
run;

data core_dn3;
set core_dn3;
buyin_24_t = substr(trim(left(buyin_24)),1,24);
hmo_24_t = substr(trim(left(hmo_24)),1,24);
b_1 = length(buyin_24_t);
b_2 = length(hmo_24_t);
run;

data core_fi (keep = id core_year hmo_24_t buyin_24_t);
set core_dn3;
run;

data core_fi (rename=(hmo_24_t=hmo_24 buyin_24_t=buyin_24)) ;
set core_fi; 
run;

proc sql;
create table final as select a.*, b.hmo_24, b.buyin_24
from hrs.core_00_to_12 a
left join core_fi b
on a.id=b.id and a.core_year=b.core_year;
quit;

proc export data=final outfile='E:\data\hrs_cleaned\core_00_12_ffsind.dta' dbms=stata replace; run;
