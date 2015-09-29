/*****************************************************************/
/* Construction of date of death file
/* this program creates a master file for date of death, including 
/* and prioritizing data in this order 
/* 1) NDI data (dod2010), 
/* 2) medicare care (dn_2000_2012 and BISF_1998_2012), and
/* 3) the exit interview (exit_02_to_12_dt).  
/* If the DOD from the NDI differs from medicare date and there are claims 
/* after the NDI date then DOD is changed to the medicare date. If NDI and 
/* medicare DOD are missing and there are claims after the exit DOD
/* then use the last discharge date as the DOD.
/*****************************************************************/
libname medi 'E:\data\cms_DUA_24548_2012';
libname medi_raw 'E:\data\cms_DUA_24548_2012\received_20150327';
libname hrs_cln 'E:\data\hrs_cleaned';
libname hrs_pub "E:\data\hrs_public_2012";
libname hrs_res "E:\data\hrs_restricted_2012";
libname ref "E:\data\Dartmouth_misc";


*restricted data;
proc contents data = hrs_res.dod2010_2; run;
proc contents data = hrs_res.ndi2010i9_r_3; run;
*proc contents data = hrs_res.ndi_2010_r_3; run;
*proc contents data = hrs_res.ndi2010i9_r_2; run;
proc contents data = hrs_res.xdod2012_2; run;
proc contents data = hrs_res.restricted_v2012; run;

* claims;
proc contents data = medi.dn_2000_2012; run;
proc contents data = medi_raw.BISF_1998_2012; run;
*proc contents data = medi_raw.BASF_1998_2012; run;
*proc contents data = medi_raw.BAQSF_1998_2012; run;

* exit interview - does not included dod;
proc contents data = hrs_cln.exit_02_to_12_dt; run;



proc freq data = dod_clm_dn ; tables dod_dn12 /missing ; run;


* prepare data and create a source indicator for each incoming dataset;
* do not include cases from each source that are missing the DOD;
data dod_ndi ; * sorted by id;
set hrs_res.dod2010_2 (rename=(death_date=dod_ndi10)); 
death_ndi=1;
where dod_ndi10 ne .;
run;
proc sort data=medi.dn_2000_2012; by BID_HRS_21 death_date ; run;
data dod_clm_dn ; * BID_HRS_21;
set  medi.dn_2000_2012(rename=(death_date=dod_dn12 sex=sex_dn));  
death_dn=1;
by BID_HRS_21 ;
if last.BID_HRS_21 then last_obs=dod_dn12;
if last_obs~=. then output;
run;
proc sort data=dod_clm_dn nodupkey; by BID_HRS_21 dod_dn12; run;
proc sort data=medi_raw.BISF_1998_2012; by BID_HRS_21 BENE_DOD  ; run;
data dod_clm_bene ; * BID_HRS_21;
set  medi_raw.BISF_1998_2012 (rename=(BENE_DOD=dod_bene12 sex=sex_bene bene_dob=dob_bene12));  
death_bene=1;
by BID_HRS_21 ;
if last.BID_HRS_21 then last_obs=dod_bene12;
if last_obs~=. then output;
run;
proc sort data=dod_clm_bene nodupkey; by BID_HRS_21 dod_bene12; run;
data dod_exit ; *ID;
set hrs_res.xdod2012_2 (rename=(death_date=dod_exit12 dod_imp=dod_imp_exit12)); 
death_exit=1;
where dod_exit12 ne . ;
format dod_exit12 MMDDYY10.;
run;
data cmsref12;
set medi.cmsxref2012 (rename=(hhidpn=id));
run;
proc sort data=cmsref12 nodupkey; by id; run;


** combine 2010 ndi & 2012 claims data ** ;
data dod0 ;
merge  dod_ndi (drop= hhid pn in=ndi) cmsref12 (in=xcms);
by id ;
run;
proc sort data=dod0 ; by BID_HRS_21; run;
** add in claims **;
data dod1;
merge dod0 dod_clm_dn (in=dn)dod_clm_bene (in=bene);
by BID_HRS_21 ;
run;
proc sort data=dod1 ; by id; run;
proc sort data=dod_exit ; by id; run;
** add exit interview;
data dod2 ;
merge  dod1 dod_exit (in=exit);
by id ;
run;

** check for duplicate ids;
** there are 1414 cases missing claims (BID_HRS_21) and no cases missing HRS (ID);
proc freq data=dod2; tables BID_HRS_21 /noprint out=keylist; run;
proc print; where count ge 2; run;
proc freq data=dod2; tables id /noprint out=keylist; run;
proc print; where count ge 2; run;


/**************************************************************************************
combine death data - 
track source of death data
**************************************************************************************/
data dod3  
  (keep = BID_HRS_21 ID age bene_dob birth_date birth_day birth_month birth_year dob_bene12
   death_bene death_day death_dn death_exit death_month death_ndi death_year dod_bene12  
   dod_dn12 dod_exit12 dod_imp dod_imp_exit12 dod_ndi10 death_all death_source death_imp_all
   death_any  V_DOD_SW );
set dod2;
death_all=. ;
death_source=. ;
array death (4) dod_ndi10 dod_dn12 dod_bene12 dod_exit12;
array source (4) death_ndi death_dn death_bene death_exit;
do i=1 to 4;
   if death_all = . then death_all=death(i);
   if death_source = . and death(i) ne . then death_source= i;
   if death(i) ne . then death_any=1;
end;
if death_source= 4 & dod_imp_exit12=1 then death_imp_all= 1;
run;


*** check discharge dates after DOD for each medicare file;
proc sort data=dod3; by bid_hrs_21; run;
proc sort data=medi.mp_2000_2012; by bid_hrs_21 disch_date; run;
data disch_mp ; *( keep=BID_HRS_21 disch_date_mp dif_mp admit_date_mp) ;
merge dod3 medi.mp_2000_2012 (rename=(disch_date=disch_date_mp admit_date=admit_date_mp));
by BID_HRS_21;
if disch_date_mp>death_all then dif_mp=disch_date_mp-death_all;
if last.BID_HRS_21 then last_obs=death_any;
if last_obs~=. AND dif_mp>0 then output;
run;
proc sort data=medi.ip_2000_2012; by bid_hrs_21 disch_date; run;
data disch_ip ( keep=BID_HRS_21 disch_date_ip admit_date_ip dif_ip) ;
merge dod3 medi.ip_2000_2012 (rename=(disch_date=disch_date_ip admit_date=admit_date_ip));
by BID_HRS_21;
if disch_date_ip>death_all then dif_ip=disch_date_ip-death_all;
if last.BID_HRS_21 then last_obs=death_any;
if last_obs~=. AND dif_ip>0 then output;
run;
proc sort data=medi.op_2000_2012; by bid_hrs_21 disch_date; run;
data disch_op ( keep=BID_HRS_21 disch_date_op admit_date_op dif_op) ;
merge dod3 medi.op_2000_2012 (rename=(disch_date=disch_date_op admit_date=admit_date_op));
by BID_HRS_21;
if disch_date_op>death_all then dif_op=disch_date_op-death_all;
if last.BID_HRS_21 then last_obs=death_any;
if last_obs~=. AND dif_op>0 then output;
run;
proc sort data=medi.pb_2000_2012; by bid_hrs_21 disch_date; run;
data disch_pb ( keep=BID_HRS_21 admit_date_pb disch_date_pb dif_pb) ;
merge dod3 medi.pb_2000_2012 (rename=(disch_date=disch_date_pb admit_date=admit_date_pb));
by BID_HRS_21;
if disch_date_pb>death_all then dif_pb=disch_date_pb-death_all;
if last.BID_HRS_21 then last_obs=death_any;
if last_obs~=. AND dif_pb>0 then output;
run;
proc sort data=medi.hh_2000_2012; by bid_hrs_21 disch_date; run;
data disch_hh ( keep=BID_HRS_21 admit_date_hh disch_date_hh dif_hh) ;
merge dod3 medi.hh_2000_2012 (rename=(disch_date=disch_date_hh admit_date=admit_date_hh));
by BID_HRS_21;
if disch_date_hh>death_all then dif_hh=disch_date_hh-death_all;
if last.BID_HRS_21 then last_obs=death_any;
if last_obs~=. AND dif_hh>0 then output;
run;
proc sort data=medi.hs_2000_2012; by bid_hrs_21 disch_date; run;
data disch_hs ( keep=BID_HRS_21 admit_date_hs disch_date_hs dif_hs) ;
merge dod3 medi.hs_2000_2012 (rename=(disch_date=disch_date_hs admit_date=admit_date_hs));
by BID_HRS_21;
if disch_date_hs>death_all then dif_hs=disch_date_hs-death_all;
if last.BID_HRS_21 then last_obs=death_any;
if last_obs~=. AND dif_hs>0 then output;
run;
proc sort data=medi.sn_2000_2012; by bid_hrs_21 disch_date; run;
data disch_sn ( keep=BID_HRS_21 admit_date_sn disch_date_sn dif_sn) ;
merge dod3 medi.sn_2000_2012 (rename=(disch_date=disch_date_sn admit_date=admit_date_sn));
by BID_HRS_21;
if disch_date_sn>death_all then dif_sn=disch_date_sn-death_all;
if last.BID_HRS_21 then last_obs=death_any;
if last_obs~=. AND dif_sn>0 then output;
run;
proc sort data=medi.dm_2000_2012; by bid_hrs_21 disch_date; run;
data disch_dm ( keep=BID_HRS_21 admit_date_dm disch_date_dm dif_dm) ;
merge dod3 medi.dm_2000_2012 (rename=(disch_date=disch_date_dm admit_date=admit_date_dm));
by BID_HRS_21;
if disch_date_dm>death_all then dif_dm=disch_date_dm-death_all;
if last.BID_HRS_21 then last_obs=death_any;
if last_obs~=. AND dif_dm>0 then output;
run;

/* because of the large number of discrepant cases with the carrier (pb) and dme data
/* discharge dates for these files were not included in determining the last discharge
/* date */
data disch_all;
merge dod3 disch_mp disch_ip disch_op disch_hh disch_hs disch_sn disch_pb disch_dm;
by BID_HRS_21 ;
admit_last=admit_date_mp;
disch_last=disch_date_mp;
array adate (6) admit_date_mp admit_date_ip admit_date_op admit_date_hh admit_date_hs admit_date_sn ;
array ddate (6) disch_date_mp disch_date_ip disch_date_op disch_date_hh disch_date_hs disch_date_sn ;
array cate (6) dif_mp dif_ip dif_op  dif_hh dif_hs dif_sn ; *dif_pb dif_dm;
array cate_gp (6) dif_mp_gp dif_ip_gp dif_op_gp dif_hh_gp dif_hs_gp dif_sn_gp ; *dif_pb_gp dif_dm_gp;
   do i=1 to 6;
      if cate(i)>0 AND cate(i)<32 then cate_gp(i)=1;
	  else if cate(i)>31 AND cate(i)<376 then cate_gp(i)=2;
	  *else if cate(i)>359 AND cate(i)<371 then cate_gp(i)=3;
	  else if cate(i)>375 then cate_gp(i)=4;
      if adate(i)> admit_last then admit_last=adate(i);
	  if ddate(i)> disch_last then disch_last=ddate(i);
	  end;
dif_all=max(dif_mp, dif_ip, dif_op, dif_hh, dif_hs, dif_sn ); *dif_pb, dif_dm);
dif_all_gp=max(dif_mp_gp, dif_ip_gp, dif_op_gp, dif_hh_gp, dif_hs_gp, dif_sn_gp); *dif_pb_gp, dif_dm_gp);
run;
proc freq data=disch_all; tables BID_HRS_21 /noprint out=keylist; run;
proc print; where count ge 2; run;


/* revised DOD based on discharge dates. If NDI differs from 
/* medicare and there are claims after the NDI date then DOD is 
/* changed to the medicare date. if NDI and medicare DOD are missing 
/* and claims after the exit date then use the last discharge date.*/
data hrs_cln.death_date_2012 
  (keep = bid_hrs_21 id death_all death_any death_source death_source_r1 dod_ndi10 dod_dn12 dod_bene12
   dod_exit12 death_all death_ndi death_bene death_dn death_exit death_imp_all 
   death_day death_month death_year discrep admit_last disch_last disch_date_mp 
   disch_date_ip disch_date_op disch_date_hh disch_date_hs disch_date_sn disch_date_sn
   disch_date_dm dif_all dif_all_gp dif_mp dif_ip dif_op  dif_hh dif_hs dif_sn dif_pb dif_dm
   dif_all_r  dif_mp_r dif_ip_r dif_op_r dif_hh_r dif_hs_r dif_sn_r dif_pb dif_dm
   dod_bene12 dod_ndi10 dod_exit12 dod_dn12  dod_imp dod_imp_exit12 
   ndi_cms_gp ndi_exit_gp cms_exit_gp dif_all_rgp cms_verified V_DOD_SW DEATHCD DEATHDT 
   discrep_pattern1 discrep_pattern2 input_pattern NDI_CMS_DAYS NDI_exit_DAYS CMS_exit_DAYS
   dif_ndi_r dif_cms_r dif_exit_r dif_NDI_DAYS dif_CMS_DAYS dif_exit_DAYS 
   dif_ndi_gp dif_cms_gp dif_exit_gp);
set disch_all ;
*revised by medicare dod & claim after ndi dod OR exit dod only and claim after;
death_source_r1=death_source;
if (dod_dn12>dod_ndi10 and disch_last>dod_ndi10) then death_all=dod_dn12;
   else if (dod_bene12>dod_ndi10 and disch_last>dod_ndi10) then death_all=dod_bene12;
if (dod_dn12>dod_ndi10 and disch_last>dod_ndi10) then death_source_r1=2;
   else if (dod_bene12>dod_ndi10 and disch_last>dod_ndi10) then death_source_r1=3;
if death_source=4 and disch_last>dod_exit12 then death_all=disch_last;
if death_source=4 and disch_last>dod_exit12 then death_source_r1=5;
*revised difference between discharge and dod;
if disch_date_mp>death_all then dif_mp_r=disch_date_mp-death_all;
if disch_date_ip>death_all then dif_ip_r=disch_date_ip-death_all;
if disch_date_op>death_all then dif_op_r=disch_date_op-death_all;
if disch_date_hh>death_all then dif_hh_r=disch_date_hh-death_all;
if disch_date_hs>death_all then dif_hs_r=disch_date_hs-death_all;
if disch_date_sn>death_all then dif_sn_r=disch_date_sn-death_all;
if disch_date_pb>death_all then dif_pb_r=disch_date_pb-death_all;
if disch_date_dm>death_all then dif_dm_r=disch_date_dm-death_all;
dif_all_r=max(dif_mp_r, dif_ip_r, dif_op_r, dif_hh_r, dif_hs_r, dif_sn_r ); *dif_pb, dif_dm);
* remaining discrepant cases;
*admit date after date of death;
if admit_last>death_all then discrep=1;
* discharge after date of death;
if disch_last>death_all then discrep=2;
if (disch_last-death_all)>7 then discrep=3;
*verified;
CMS_verified=. ;
if DEATHCD='V' or V_DOD_SW='V' then CMS_verified =1;
*no discrepant DOD between dn and bene files so combine;
if death_dn=1 and death_bene=1 and dod_dn12 ne dod_bene12 then dn_bene=1;
if death_dn=1 or death_bene=1 then death_cms=1;
if death_dn=1 then dod_cms12=dod_dn12;
else if death_bene=1 then dod_cms12=dod_bene12;
* inpute pattern;
input_pattern=CAT(death_ndi, death_cms, death_exit);
* identify discrepancies between final DOD & data sources and calc days discrepant;
dif_ndi_r=0;
dif_cms_r=0;
dif_exit_r=0;
if death_ndi=1 and dod_ndi10 ne death_all then dif_ndi_r=1;
if death_cms=1 and dod_cms12 ne death_all then dif_cms_r=1;
if death_exit=1 and dod_exit12 ne death_all then dif_exit_r=1;
discrep_pattern1=CAT(dif_ndi_r,dif_cms_r,dif_exit_r);
if death_ndi=1 and dod_ndi10 ne death_all then dif_ndi_d =(dod_ndi10 - death_all);
if death_cms=1 and dod_cms12 ne death_all then dif_cms_d=(dod_cms12 - death_all);
if death_exit=1 and dod_exit12 ne death_all then dif_exit_d=(dod_exit12 - death_all);
dif_ndi_days=abs(dif_ndi_d);
dif_cms_days=abs(dif_cms_d);
dif_exit_days=abs(dif_exit_d);
* identify discrepancies between DOD from data sources and calc days discrepant;
ndi_cms=0;
ndi_exit=0;
cms_exit=0;
if death_ndi=1 and death_cms=1 and dod_ndi10 ne dod_cms12 then ndi_cms=1;
if death_ndi=1 and death_exit=1 and dod_ndi10 ne dod_exit12 then ndi_exit=1;
if death_cms=1 and death_exit=1 and dod_cms12 ne dod_exit12 then cms_exit=1;
discrep_pattern2=CAT(ndi_cms,ndi_exit,cms_exit);
if death_ndi=1 and death_cms=1 and dod_ndi10 ne dod_cms12 then ndi_cms_d =(dod_ndi10 - dod_cms12);
if death_ndi=1 and death_exit=1 and dod_ndi10 ne dod_exit12 then ndi_exit_d =(dod_ndi10 - dod_exit12);
if death_cms=1 and death_exit=1 and dod_cms12 ne dod_exit12 then cms_exit_d =(dod_cms12 - dod_exit12);
ndi_cms_days=abs(ndi_cms_d);
ndi_exit_days=abs(ndi_exit_d);
cms_exit_days=abs(cms_exit_d);
* create categorical measures for discrepancy variables - source & CMS claims;
array grp1(7) ndi_cms_days ndi_exit_days cms_exit_days dif_all_r dif_ndi_days dif_cms_days dif_exit_days;
array grp2(7) ndi_cms_gp ndi_exit_gp cms_exit_gp dif_all_rgp dif_ndi_gp dif_cms_gp dif_exit_gp;
do q=1 to 7;
   if grp1(q) =1 then grp2(q)=1;
   else if grp1(q) >1 and grp1(q) <11 then grp2(q)=2;
   else if grp1(q) >10 and grp1(q) <101 then grp2(q)=3;
   else if grp1(q) >100 and grp1(q) <401 then grp2(q)=4;
   else if grp1(q) >400 and grp1(q) <1001 then grp2(q)=5;
   else if grp1(q) >1000 then grp2(q)=6;
   end;
* calculate day, month, year from combined DOD;
death_day=day(death_all);
death_month=month(death_all);
death_year=year(death_all);

label death_all='Date of death combined from ndi, claims, exit';
label death_source='Source of dod: 1=ndi, 2=dn, 3=bene, 4=exit, 5=discharge';
label death_imp_all='Dod imputed - exit interview';
label dod_ndi10='Date of death reported in the NDI data'; 
label dod_dn12='Date of death reported in the mc den file';  
label dod_bene12='Date of death reported in the mc bene sum file';  
label dod_exit12='Date of death reported in the HRS exit invw';  
label death_ndi ='Respondent located in the NDI data '; 
label death_dn ='Respondent located in the mc den file'; 
label death_bene ='Respondent located in the mc bene file'; 
label death_exit='Respondent located in the exit ivw file'; 
label death_any='Date of death reported from any source'; 
label admit_last='Last admit date in CMS claims';
label disch_last='Last discharge date in CMS claims';
label dif_all='Max discrepancy betw DOD and CMS claims discharge dates';
label dif_all_r='Max discrep betw DOD and CMS claims discharge AFTER revision';
label dif_all_gp='Max discrep betw DOD and CMS claims: 1=1-31, 2=32-375, 4=376+';
label death_source_r1='Death source rev: CMS DOD & claim > NDI or disch > exit: 1=ndi, 2=dn, 3=bene, 4=exit, 5=disch';
label discrep= 'CMS claims discrp 1=admit after dod 2=disch after dod 3=disch 8+ days after dod';
label CMS_verified='CMS date verified';
label dn_bene='DOD discrepancy betw dn and bene file';
label dod_cms12='Combined CMS DOD'; 
label input_pattern='Pattern of DOD data sources: NDI, CMS,Exit';
label discrep_pattern1='Pattern of discrepancy: final DOD and NDI, CMS,Exit';
label discrep_pattern2='Pattern of discrepancy betw data sources: NDI, CMS,Exit';
label ndi_cms='DOD NDI & CMS discrepant';
label ndi_exit='DOD NDI & exit discrepant';
label cms_exit='DOD CMS & exit discrepant';
label dif_ndi_days='Days betw final DOD & NDI';
label dif_cms_exit_days='Days betw final DOD & CMS';
label dif_exit_days='Days betw final DOD & exit';
label dif_ndi_gp='Days betw final DOD & NDI: 1=1,2=2-10,3=11-100,4=101-400,5=401-1000,6=>1000'; 
label dif_cms_gp='Days betw final DOD & CMS: 1=1,2=2-10,3=11-100,4=101-400,5=401-1000,6=>1000'; 
label dif_exit_gp='Days betw final DOD & exit: 1=1,2=2-10,3=11-100,4=101-400,5=401-1000,6=>1000'; 
label ndi_cms_days='Days betw NDI & CMS DOD';
label ndi_exit_days='Days betw NDI & exit DOD';
label cms_exit_days='Days betw CMS & exit DOD';
label ndi_cms_gp='Days betw NDI & CMS DOD: 1=1,2=2-10,3=11-100,4=101-400,5=401-1000,6=>1000'; 
label ndi_exit_gp='Days betw NDI & exit DOD: 1=1,2=2-10,3=11-100,4=101-400,5=401-1000,6=>1000';
label cms_exit_gp='Days betw CMS & exit DOD: 1=1,2=2-10,3=11-100,4=101-400,5=401-1000,6=>1000';
label dif_all_rgp='Days betw DOD & last disch: 1=1,2=2-10,3=11-100,4=101-400,5=401-1000,6=>1000';
label death_day='Day of death';
label death_month='Month of death';
label death_year='Year of death';
format dod_ndi10 dod_dn12 dod_bene12 dod_exit12 death_all
       admit_last disch_last disch_date_mp disch_date_ip disch_date_op disch_date_pb 
       disch_date_hh disch_date_hs disch_date_sn disch_date_dm dod_cms12 MMDDYY10.;
where death_any=1;
run;


*proc contents data=hrs_cln.death_date_2012 ; run;
*proc freq data=temp ; table ndi_cms_days ndi_exit_days cms_exit_days dif_all_r; run;_



ods rtf file="C:\Users\mckenk04\Death_discharge_08252015.rtf";
title 'DOD source & number of cases from each source - Total ';
proc freq data=hrs_cln.death_date_2012 ; 
tables death_source_r1 death_ndi death_dn death_bene death_exit ; 
run;
title 'Investigate verfied DOD & imputed DOD';
proc freq data=hrs_cln.death_date_2012 ; 
tables CMS_verified * death_source_r1 ;
tables V_DOD_SW  * death_dn /missing ;
tables DEATHCD * death_bene /missing  ;
tables death_imp_all * death_source_r1 ;
tables death_imp_all * death_exit ;
tables death_day * death_source_r1 ; 
tables death_day * (death_ndi death_dn death_bene death_exit) ; 
run;
title 'DOD input and discrp pattern by source';
proc freq data=hrs_cln.death_date_2012 ; 
tables dif_ndi_gp dif_cms_gp dif_exit_gp dif_all_rgp ndi_cms_gp ndi_exit_gp cms_exit_gp;
tables discrep_pattern1 * input_pattern /norow nocol nopercent ;
tables discrep_pattern2 * input_pattern /norow nocol nopercent ;
run;
proc sort data=hrs_cln.death_date_2012 ;  by input_pattern discrep_pattern1   ; run;
proc means data=hrs_cln.death_date_2012  n nmiss mean stddev median min max;
var dif_ndi_days dif_cms_days dif_exit_days ndi_cms_days ndi_exit_days cms_exit_days ;
by input_pattern discrep_pattern1  ;
run;
proc freq data=hrs_cln.death_date_2012 ; 
tables dif_ndi_gp dif_cms_gp dif_exit_gp ndi_cms_gp ndi_exit_gp cms_exit_gp ;
by  input_pattern discrep_pattern1   ;
run;
title 'DOD input & source discrep by death year';
proc freq data=hrs_cln.death_date_2012 ; 
tables input_pattern * death_year /norow nocol nopercent ;
tables death_source_r1 * death_year /norow nocol nopercent ;
tables discrep_pattern1 * death_year /norow nocol nopercent ;
tables discrep_pattern2 * death_year /norow nocol nopercent ;
run;
title 'DOD input & source discrep by death year for cases with claims discrep';
proc freq data=hrs_cln.death_date_2012 ;  ;
tables input_pattern * death_year /norow nocol nopercent ;
tables death_source_r1 * death_year /norow nocol nopercent ;
tables discrep_pattern1 * death_year /norow nocol nopercent ;
where dif_all_r>0 ;
run;
title 'DOD input & source discrep by death year for cases with claims discrep 7+';
proc freq data=hrs_cln.death_date_2012 ;  ;
tables input_pattern * death_year /norow nocol nopercent ;
tables death_source_r1 * death_year /norow nocol nopercent ;
tables discrep_pattern1 * death_year /norow nocol nopercent ;
where dif_all_r>7 ;
run;


title 'Days DOD discrep betw sources';
proc means data=hrs_cln.death_date_2012  n nmiss mean stddev median min max p5 p25 p75 p95; 
var ndi_cms_days ; where ndi_cms_days>0; run;
proc means data=hrs_cln.death_date_2012  n nmiss mean stddev median min max p5 p25 p75 p95; 
var  ndi_exit_days ; where ndi_exit_days>0; run;
proc means data=hrs_cln.death_date_2012  n nmiss mean stddev median min max p5 p25 p75 p95;  
var  cms_exit_days; where cms_exit_days>0; run;

title 'Days disrep betw DOD and last CMS discharge';
proc means data=hrs_cln.death_date_2012 n nmiss mean stddev median min max p5 p25 p75 p95;  
var dif_all_r  ; where dif_all_r>0 ; run;


title 'DOD source & number of cases from each source- Cases w discrepancies based on CMS claims';
proc freq data=hrs_cln.death_date_2012 ; 
tables death_source_r1 death_ndi death_dn death_bene death_exit ; 
where dif_all_r>0;
run;
title 'DOD source & number of cases from each source- Cases w discrepancies >7 days based on CMS claims';
proc freq data=hrs_cln.death_date_2012 ; 
tables death_source_r1 death_ndi death_dn death_bene death_exit ; 
where  dif_all_r>7;
run;

title 'CMS claims discrepancies BEF revision w discharge dates-Total sample';
proc means data=hrs_cln.death_date_2012  mean median min max n;
var dif_all dif_mp dif_ip dif_op  dif_hh dif_hs dif_sn dif_pb dif_dm; run;
title 'CMS claims discrepancies BEF revision w discharge dates- Cases w 7+ days discrepancy';
proc means data=hrs_cln.death_date_2012  mean median min max n;
var dif_all dif_mp dif_ip dif_op  dif_hh dif_hs dif_sn dif_pb dif_dm; 
where  dif_all >7;run;

title 'CMS claims discrepancies AFTER revision w discharge dates-Total sample';
proc means data=hrs_cln.death_date_2012 mean median min max n;
title 'CMS claims discrepancies AFTER revision w discharge dates- Cases w 7+ days discrepancy';
var dif_all_r dif_mp_r dif_ip_r dif_op_r dif_hh_r dif_hs_r dif_sn_r dif_pb dif_dm; run;

title 'CMS claims discrepancies BEF revision w discharge dates- by CMS file';
proc means data=hrs_cln.death_date_2012 mean median min max n;
var dif_all_r dif_mp_r dif_ip_r dif_op_r dif_hh_r dif_hs_r dif_sn_r dif_pb dif_dm;
where dif_all_r >7; run;
proc freq data=hrs_cln.death_date_2012 ; 
table discrep dif_all_r ; run;


title 'Document cases with >1000 days discrep source or CMS claims';
proc print data=hrs_cln.death_date_2012 ;  ; 
var death_source_r1 death_year death_all dod_ndi10 dod_dn12 dod_bene12 dod_exit12 disch_last;
where ndi_cms_days >1000 or ndi_exit_days>1000 or cms_exit_days >1000 or dif_all_r>1000;
run;

ods rtf close;




