/*surgery project summary statistics
For abstract submission on 12/2/2013
Reviewed with Zara and Amy on 11/27/13*/

capture log close

clear all
set mem 500m
set matsize 800
set more off

log using "E:\data\surgery\logs\7_Surgery_code_sum_stats_08ds.txt", text replace

cd "E:\data\surgery\final_data\"

//2 datasets, one with 12 month pre surgery comorbidities, one with 6 month
//pre surg comorbidities
use surgery_final_n12m.dta
//use surgery_final_n6m.dta

describe

la var r_year "Surgery year"
tab core_year_n1 r_year, missing

**********************************************************
**********************************************************
//create age at surgery variables
**********************************************************
**********************************************************

//check dob from restricted files vs dob from claims
/*restricted file has quite a few instances of missing dob
but claims does not so maybe use claims dob*/

format birth_date_e %td
//2 observations have missing birth date from restricted file
tab birth_date_e,missing

//rename dob variable from claims
rename claims_dob2 claims_dob

//check to see if there's a difference between claims dob and rest dob
//there is so don't just replace restricted dob with claims dob
gen dob_clm_rest = claims_dob - birth_date_e
tab dob_clm_rest, missing

//check claims dob for cases where restricted birth date is missing
//seem to check out, one was imputed, year is same for both
tab claims_dob if birth_date_e==.,missing
tab birthmo_e dob_imp if birth_date_e==.,missing
tab birthyr_e dob_imp if birth_date_e==.,missing
tab birthday_e  dob_imp  if birth_date_e==.,missing

//for 2 obs with missing dob, use claims dob
replace birth_date_e=claims_dob if birth_date_e==.

//create age at surgery variable
gen age_at_surg=.
replace age_at_surg  = (procedure_date-birth_date_e) / 365.25
la var age_at_surg "Age at time of index surgery"
sum age_at_surg, detail

//create category indicator age variables
gen age_at_surg_lt65=.
replace age_at_surg_lt65=1 if (age_at_surg<65 & age_at_surg~=.)
replace age_at_surg_lt65=0 if (age_at_surg>=65 & age_at_surg~=.)
la var age_at_surg_lt65 "Age at time of index surgery less than 65"

gen age_at_surg_65_74=.
replace age_at_surg_65_74=1 if (age_at_surg>=65 & age_at_surg<75)
replace age_at_surg_65_74=0 if (age_at_surg<65 | age_at_surg>=75)
la var age_at_surg_65_74 "Age at time of index surgery 65-74"

gen age_at_surg_75_79=.
replace age_at_surg_75_79=1 if (age_at_surg>=75 & age_at_surg<80)
replace age_at_surg_75_79=0 if (age_at_surg<75 | age_at_surg>=80)
la var age_at_surg_75_79 "Age at time of index surgery 75-79"

gen age_at_surg_80_84=.
replace age_at_surg_80_84=1 if (age_at_surg>=80 & age_at_surg<85)
replace age_at_surg_80_84=0 if (age_at_surg<80 | age_at_surg>=85)
la var age_at_surg_80_84 "Age at time of index surgery 80-84"

gen age_at_surg_gt84=.
replace age_at_surg_gt84=1 if (age_at_surg>=85 & age_at_surg~=.)
replace age_at_surg_gt84=0 if (age_at_surg<85 & age_at_surg~=.)
la var age_at_surg_gt84 "Age at time of index surgery 85+"

tab age_at_surg_lt65,missing
tab age_at_surg_65_74,missing
tab age_at_surg_75_79,missing
tab age_at_surg_80_84,missing
tab age_at_surg_gt84,missing

//create categorical age variable
gen age_cat=.
replace age_cat=1 if age_at_surg_65_74==1 | age_at_surg_lt==1
replace age_cat=2 if age_at_surg_75_79==1
replace age_cat=3 if age_at_surg_80_84==1
replace age_cat=4 if age_at_surg_gt84==1
la var age_cat "Age at Surgery"
la def age 1 "65-74" 2 "75-79" 3 "80-84" 4 "85+"
la val age_cat age
tab age_cat, missing


//check current reason for entitlement for those age<65
destring crec, replace
la var crec "current reason for mc entitlement"
la def crec 0 "age 65 and older" 1 "disability insurance benefits" ///
	2 "ESRD" 3 "DIB and ESRD"
la values crec crec	
tab crec if age_at_surg_lt65==1, missing

// percent of surgeries that were emergent/urgent
tab em_urgent_admit, missing

// drop observations to get to final sample
drop if age_at_surg_lt65==1 //drop if age less than 65
drop if part_ab_6m==. //surgery within 6 months of Jan. 2000
drop if part_ab_6m==0 //no mc a+b coverage 6 months prior to surgery
drop if hmo_d_6m==1 //HMO coverage 6 months prior to surgery
drop if ind_n1core==0 //no core interview pre-surgery

tab r_year, missing

tab em_urgent_admit, missing
drop if em_urgent_admit==0 | em_urgent_admit==.

/**************************************************************/
/**************************************************************/
// Now have final sample of 345 beneficiaries with urgent
// or emergent surgery, age 65 and over at surgery and
// fee for service medicare in the 6 months prior to surgery
/**************************************************************/
/**************************************************************/

// list of surgeries
tab procedure, missing

//age at time of surgery
sum age_at_surg, detail

//gender - from HRS
gen byte female = .
replace female=1 if (female_n1==1 | female_p1==1 | female_x==1)
replace female=0 if (female_n1==0 | female_p1==0 | female_x==0)
tab female, missing

//gender - from claims
tab claims_sex, missing
gen byte female_claims = .
replace female_claims = 1 if (claims_sex=="2")
replace female_claims = 0 if (claims_sex=="1")

// compare HRS and claims gender values
tab female female_claims, missing
//no conflicts and the 3 missing observations in HRS have gender
//assigned in the claims so use the claims gender variable

replace female=female_claims
tab female, missing

//race & ethnicity
tab white_e, missing
tab black_e, missing
tab hisp_eth_e, missing
tab native_amer_e, missing
tab asian_pi_e, missing
tab other_race_e, missing
tab other_na_api_race_e, missing

//nursing home resident - using n1 core interview
tab nhres_n1, missing

//HRQoL self reported health status
tab srh_pf_n1, missing //fair or poor self reported hs

//adl functional status - core interview prior to surgery
tab adl_independent_core_n1, missing //independent adl
tab adl_partial_core_n1, missing //partial dependence adl
tab adl_severe_core_n1, missing //severe dependence adl

//create variables for died at 30 days, 180 days, 1 year
gen surg_to_death_dt = death_date_e - procedure_date
tab surg_to_death_dt, missing

gen byte died_ind=.
replace died_ind=1 if death_date~=.
replace died_ind=0 if death_date==.
la var died_ind "indicator for death date present in HRS"


//died within 30 days of surgery (null if did not die)
gen byte died_30d = .
replace died_30d = 1 if (surg_to_death_dt<31)
replace died_30d = 0 if (surg_to_death_dt>30 & surg_to_death_dt~=.)
la var died_30d "died within 30 days post surgery"

//died within 180 days of surgery (null if did not die)
gen byte died_180d = .
replace died_180d = 1 if (surg_to_death_dt<181)
replace died_180d = 0 if (surg_to_death_dt>180 & surg_to_death_dt~=.)
la var died_180d "died within 180 days post surgery"

//died within 365 days of surgery (null if did not die)
gen byte died_365d = .
replace died_365d = 1 if (surg_to_death_dt<366)
replace died_365d = 0 if (surg_to_death_dt>365 & surg_to_death_dt~=.)
la var died_365d "died within 1 year post surgery"

tab died_ind, missing
tab died_30d, missing
tab died_180d, missing
tab died_365d, missing

//completed follow up core interview within 1 year
gen byte core_1yr_ps=.
replace core_1yr_ps=1 if (ind_p1core<366 & ind_p1core==1)
replace core_1yr_ps=0 if (ind_p1core>365 | ind_p1core==0)
la var core_1yr_ps "core interview within 1 year after surgery"

//look at outcomes at 1 year (note: all those that died w/i 1 year have exit interview recorded)
//4 paths 
// 1. died and exit interview w/i 1 year
// 2. died w/i 1 year but exit interview later than 1 yr
// 3. core / survived
// 4. no core / survived

gen days_x_int_ps = .
replace days_x_int_ps = ( e_ivw_date_x - procedure_date )
tab days_x_int_ps died_ind, missing

gen outcome_1yr=.
//died 1 year and exit int 1 yr
replace outcome_1yr=1 if died_365d==1 & ( e_ivw_date_x - procedure_date <=365 )
//died 1 year and exit int later than 1 yr
replace outcome_1yr=2 if died_365d==1 & ( (e_ivw_date_x - procedure_date > 365) & ind_exit==1)
//died 1 year, no exit int
replace outcome_1yr=3 if died_365d==1 & ( (e_ivw_date_x - procedure_date > 365) & ind_exit==0)
//survived and core
replace outcome_1yr=4 if core_1yr_ps==1 & (died_365d==0|died_365d==.)
//survived and no core
replace outcome_1yr=5 if core_1yr_ps==0 & (died_365d==0|died_365d==.)
la var outcome_1yr "Outcome category 1 yr post surgery"
la def outcome_1yr 1 "Died and exit interview" 2 "Died, exit later than 1 yr" ///
	3 "Died and no exit" 4 "Survived, completed core interview" ///
	5 "Survived, no core interview", replace
la val outcome_1yr outcome_1yr
tab outcome_1yr died_365d, missing

//sum stats from p1 core interview for patients who had interview
//independent functional status using adls
tab adl_independent_core_p1 if(core_1yr_ps==1), missing
//nursing home residence
tab nhres_p1 if(core_1yr_ps==1), missing
//surgery discharge destination codes - create new indicator variable
//62, 63, 3 code up to discharge to snf
tab dstntncd

//went from no nursing home before to nursing home after
gen nh_diff_1 = nhres_p1 - nhres_n1
tab nh_diff_1 if(core_1yr_ps==1), missing

gen byte nh_change_after = .
replace nh_change_after=1 if nh_diff_1>0 & nh_diff_1~=.
replace nh_change_after=0 if nh_diff_1<=0 & nh_diff_1~=.
tab nh_change_after if(core_1yr_ps==1), missing

//experienced functional decline post surgery
gen fx_diff_1 =  adl_index_core_p1 -  adl_index_core_n1
tab fx_diff_1 if(core_1yr_ps==1), missing

gen byte fx_decline=.
replace fx_decline=1 if fx_diff_1>0 & fx_diff_1~=.
replace fx_decline=0 if fx_diff_1<=0 & fx_diff_1~=.
tab fx_decline if(core_1yr_ps==1), missing

save surgery_final_n12m_sample.dta, replace

log close
