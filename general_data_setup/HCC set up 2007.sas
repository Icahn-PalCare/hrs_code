/*******************************************************************************/
/* STEP 1: Create a PERSON and DIAG file for calculating CMS-HCC risk adjustment scores
           (Step 1 portion of this code)
/* STEP 2: Run the format file E:\hrs_code\general_data_setup\HCCsoftware07\format.sas
/* STEP 3: Run the HCC software E:\hrs_code\general_data_setup\HCCsoftware07\V1206D4P
/* STEP 4: Create file combining new, HCC risk, and calculate benefit
           (Step 4 portion of this code)
/*******************************************************************************/

/* Before the HCC files could be used all txt files were converted to SAS 
***** convert SAS transport files to SAS format;
filename in1 "E:\hrs_code\general_data_setup\HCCsoftware07\C1206D4Y";
libname out "E:\hrs_code\general_data_setup";
proc cimport library=out infile=in1;
run;

filename in1 "E:\hrs_code\general_data_setup\HCCsoftware07\F1206D4Y";
libname out "E:\hrs_code\general_data_setup\HCCsoftware07";
proc cimport library=out infile=in1;
run;
*/



/*******************************************/
* STEP 1
/*******************************************/;

libname medi 'E:\data\cms_DUA_24548_2012';
libname cms 'E:\data\cms_DUA_24548_2012\received_20150327';
libname hcc 'E:\data\cms_DUA_24548_2012\HCC 2008';



/*******************************************/
/* PERSON FILE
/*******************************************/
* Use 2007 DN file to determine if subject is a new enrollee
  HMO included to see determine if new enrollees should include subjects 
  moving from HMO to FFS;
data yr2007; keep bid_hrs_21 ref07 HMO_MO_07;
set cms.DN_2007; 
ref07=1;
HMO_MO_07=HMO_MO;
run;

data person ; 
merge yr2007 cms.DN_2008; 
by bid_hrs_21;
HICNO=bid_hrs_21;
DOB= input(bene_dob, yymmdd8.) ;
   format DOB date10.;
if age<65 then age65=0;
   if age ge 64 and age le 66then age65=1;
     if age ge 66 then age65=2;
if age<60 then agecat=59;
   if age ge 60 and age <70 then agecat=60;
   if age ge 70 and age <780 then agecat=70;
   if age ge 80 then agecat=80;
* determine if R is a new enrollee;
if ref07=1 and rfrnc_yr = 8 then new=0;
   if ref07 = . and rfrnc_yr = 8 then new=1;
* create HCC variables; 
if buyin_mo >0 then MCAID=1; else MCAID=0; * if num of part b buy in mos >0;
if new=1 and MCAID=1 then NEMCAID=1; else NEMCAID=0; * if new enrollee & num of part b buy in mos >0;
run;

/*proc freq data=person;
tables new ;
tables rfrnc_yr * ref07 / missing nocol norow nopercent;
tables age65 * new / missing nocol norow nopercent;
tables agecat * new / missing nocol norow nopercent;
tables HMO_MO * HMO_MO_07 / missing nocol norow nopercent;
run;
* this tables indicates that only 36 subjects would be added if 
  not continous FFS- HMO in 2007 and NO HMO in 2008;
proc freq data=person;
tables HMO_MO * HMO_MO_07  / missing nocol norow nopercent;
where new=0 and age ge 64 ; 
run;
*/
data hcc.person ; keep HICNO SEX DOB MCAID NEMCAID OREC;
set person;
where age ge 64;
run;



/*******************************************/
/* DIAG FILE
/*******************************************/
* create wide file of diagnoses from all the claim files;
data diag0; keep HICNO AD_DGNS PDGNS_CD DGNSCD01-DGNSCD25;
set
cms.ip_2008 (rename=(BID_HRS_21=HICNO) keep= BID_HRS_21 AD_DGNS PDGNS_CD DGNSCD01-DGNSCD25)
cms.pb_2008 (rename=(BID_HRS_21=HICNO) keep= BID_HRS_21 PDGNS_CD DGNSCD01-DGNSCD12)
cms.op_2008 (rename=(BID_HRS_21=HICNO) keep= BID_HRS_21 PDGNS_CD DGNSCD01-DGNSCD25)
cms.dm_2008 (rename=(BID_HRS_21=HICNO) keep= BID_HRS_21 PDGNS_CD DGNSCD01-DGNSCD12)
cms.hh_2008 (rename=(BID_HRS_21=HICNO) keep= BID_HRS_21 PDGNS_CD DGNSCD01-DGNSCD25)
cms.hs_2008 (rename=(BID_HRS_21=HICNO) keep= BID_HRS_21 PDGNS_CD DGNSCD01-DGNSCD25)
cms.mp_2008 (rename=(BID_HRS_21=HICNO DGNS_CD01-DGNS_CD25 = DGNSCD01-DGNSCD25 ) 
             keep= BID_HRS_21 AD_DGNS DGNS_CD01-DGNS_CD25);
by HICNO;
run;

* transpose to long file;
data hcc.diag (keep = HICNO diag x);
set diag0;
*by  HICNO;
array dx(27) DGNSCD01-DGNSCD25 AD_DGNS PDGNS_CD ;
do x=1 to 27;
   if dx(x) ne '' then diag=dx(x);
   if x=1 and dx(x) ne '' then output;
   else if x>1 and (dx(x) ne dx(x-1)) then output;
end;
run;


proc contents data=medi.person; run;
/*******************************************/
* STEP 4
/*******************************************/;
/*prepare xwalk id file to merge*/
data crosswalk_1;
set medi.cmsxref2012;
keep bid_hrs_21 hhid pn;
run;

/*get 2 variables bid_hrs = claims id, id=HRS id*/
data crosswalk_2;
set crosswalk_1;
bid_hrs=bid_hrs_21;
id=trim(hhid)||trim(pn);
drop hhid pn;
HICNO=bid_hrs_21;
*drop bid_hrs_21;
run;
proc sort data=crosswalk_2; by HICNO; run;
proc sort data=person; by HICNO; run;
proc sort data=medi.person; by HICNO; run;

data temp; drop HICNO;
merge 
crosswalk_2
person (keep=HICNO new)
medi.person (keep=HICNO SCORE_COMMUNITY SCORE_INSTITUTIONAL SCORE_NEW_ENROLLEE);
by HICNO;
HCC_sp_2008=9418;
HCC_sp_2008_adj2012=10043.13;
run;

data medi.HCC2008; set temp;
where SCORE_COMMUNITY ne . or SCORE_INSTITUTIONAL ne . or SCORE_NEW_ENROLLEE ne .;
run;

proc sort data= medi.HCC2008;
by id;
run;

proc export data=medi.HCC2008
outfile ="E:\data\cms_DUA_24548_2012\HCC2008.dta" replace;
run;
