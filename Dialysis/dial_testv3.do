
use "E:\data\hrs_cleaned\core_00_to_12.dta", clear

sort id core_year
by id: carryforward height_in, gen(height)


merge m:1 id using "E:\data\Dialysis\int_data\hrs_dial_claimsv2.dta"

keep if _merge==3
drop _m
*save "E:\data\Dialysis\final_data\hrs_dialysis.dta", replace

*merge m:1 id using "E:\data\Dialysis\int_data\dial_int_dataset.dta"
*keep if _merge==3
*drop _m
*save "E:\data\Dialysis\final_data\hrs_dialysis.dta", replace


*merge m:1 bid_hrs using "E:\data\Dialysis\hrs_dial_claims.dta", keepus(part_ab_1y hmo_d_6m hmo_d_1y ip_only ip_start esrd_ind periflag hemoflag stus_cd)
*merge m:1 bid_hrs using "E:\data\Dialysis\int_data\hrs_dial_claims.dta", keepus(part_ab_1y hmo_d_6m hmo_d_1y cptcodes)

*keep if _m==3
*cap drop _m

*merge 1:1 id core_year using "E:\data\hrs_public_2012\dementia\pdem_withvarnames_ebl.dta"
*drop if _merge==2
*drop _m
*save "E:\data\Dialysis\final_data\hrs_dialysis.dta", replace

gen year = core_year


*merge 1:1 hhid pn year using "E:\data\hrs_oop_2010\received_data\2012\helper_hours_2012.dta" 
*drop if _m==2
*replace n_hp = 0 if n_hp==.
*save "E:\data\Dialysis\final_data\hrs_dialysis.dta", replace
/* Get Demographics from tracker file */

*use "E:\data\Dialysis\hrs_dialysis.dta", clear
cap drop _m
merge m:1 hhid pn using "E:\data\hrs_cleaned\restricted_tracker_v2012.dta", keepus(hisp_eth white black gender degree birthmo birthday birthyr)  // keepus(white black other_na_api_race)
keep if _merge==3
drop _m


replace female = 1 if gender==2 & female==.
replace female = 0 if gender==1 & female==.


/*

gen likelydem = 0
replace likelydem = 1 if pdem >=0.5 & pdem!=.

gen likelycind = 0
replace likelycind = 1 if pdem2 >= 0.5 & pdem2!=.

gen likelynormal = 0
replace likelynormal = 1 if pdem3>=0.5 & pdem3!=.

// tics score

gen tics_cutoff = 0
replace tics_cutoff = 1 if tics_tot <= 8

save "E:\data\Dialysis\final_data\hrs_dialysis.dta", replace
*/

/* Create indicator for n1 interview */

rename admit_date index_date

replace admit_year = year(index_date)
format c_ivw_date %td
format index_date %td


gen pre = c_ivw_date <= index_date
gsort id -pre -core_year
by id: gen ind_n1_ivw=_n==1
gen no_core = 1 if ind_n1_ivw==1 & pre==0
gen id_flag= 1 if ind_n1_ivw==1
replace ind_n1_ivw=0 if pre==0
label var ind_n1_ivw "Indicator for n1 interview"
label var no_core "Does not have any n1 interview"
label var id_flag "Total # of people with Dialysis"

gen post = c_ivw_date > index_date
gsort id -post + core_year
by id: gen ind_p1_ivw=_n==1

replace ind_p1_ivw = 0 if post==0
label var ind_p1_ivw "Indicator for p1 interview"

/*merge with death date dataset*/
cap drop _m
merge m:1 id using "E:\data\hrs_cleaned\death_date_2012.dta", keepus(death_year death_month death_day dod_dn12 dod_ndi10 dod_exit12 death_all dod_bene12 death_any)
drop if _m==2

gen died = 0
replace died = 1 if _m==3
label var died "Died at some point during HRS"
*save "E:\data\Dialysis\final_data\hrs_dialysis.dta", replace
/* 1-2yr mortality */

gen mortality = death_all - index_date
gen died_1yr = 0
replace died_1yr = 1 if mortality <= 365
label var died_1yr "Died within one year of incident dialysis (%)"
gen died_2yr = 0
replace died_2yr = 1 if mortality <= 730
label var died_2yr "Died within two years of incident dialysis (%)"
label var mortality "Average # of Days from 1st Dialysis to Death"

gen died_30d = 0
replace died_30d = 1 if mortality <=30

gen died_6m = 0
replace died_6m = 1 if mortality <=180



cap drop _m
merge m:1 id using "E:\data\hrs_cleaned\exit_02_to_12_dt.dta", keepus(e_ivw_date exit_year adl_t adl_tx adl_wk adl_bh adl_dr adl_e)
drop if _m==2

gen index_2_exit = .
replace index_2_exit = 1 if e_ivw_date - index_date <=365


gen index_t2_exit = e_ivw_date - index_date

gen ind_exit = .
replace ind_exit = 1 if index_2_exit!=1 & (e_ivw_date - index_date)<=730

gen death_2_exit = e_ivw_date - death_all

gen died_1yr_w_exit = 0
replace died_1yr_w_exit = 1 if died_1yr==1 & exit_year!=.
label var died_1yr_w_exit "Died within 1 year of Dialysis w/Exit"

gen died_1yr_no_exit = 0
replace died_1yr_no_exit = 1 if died_1yr==1 & exit_year==.
label var died_1yr_no_exit "Died within 1 year of Dialysis no Exit"

gen died_2yr_w_exit = 0
replace died_2yr_w_exit = 1 if died_2yr==1 & exit_year!=.
label var died_2yr_w_exit "Died within 2 years of Dialysis w/Exit"

gen died_2yr_no_exit = 0
replace died_2yr_no_exit = 1 if died_2yr==1 & exit_year==.
label var died_2yr_no_exit "Died within 2 years of Dialysis no Exit"

gen race = 0
replace race = 1 if white==1
replace race = 2 if black==1
replace race = 3 if hisp_eth==1

/* Age at Dialysis */
replace birthmo = 3 if birthmo==. & ind_n1_ivw==1
gen birth_date = mdy(birthmo,birthday,birthyr)
gen age_index=(index_date-birth_date)/365.25
recast int age_index, force


/* Time between dialysis n1 & p1 */

gen n1_to_dial = index_date - c_ivw_date
*gen time = td%(index_date) - td%(c_ivw_date)
label var n1_to_dial "Average # of days between n1 interview & 1st dialysis"
gen dial_to_p1 = c_ivw_date - index_date
label var dial_to_p1 "Average # days between 1st dialysis & p1 interview"


gen timegap = 0
gen diff = index_date - c_ivw_date
replace timegap = 1 if diff <=1095 & ind_n1_ivw==1



levelsof id if timegap==1, local(keepid)
gen n1_ingap = 0

foreach x in `keepid' {

replace n1_ingap = 1 if id=="`x'"
}


gen timegap_p1 = 0
*replace timegap_p1 = 1 if died_1yr==0 & (c_ivw_date - index_date>365) & (c_ivw_date - index_date<=730) & ind_p1_ivw==1
replace timegap_p1 = 1 if (c_ivw_date - index_date<=365) & ind_p1_ivw==1
gen timegap_p2 = 0
replace timegap_p2 = 1 if (c_ivw_date - index_date>365) & (c_ivw_date - index_date<=730) & ind_p1_ivw==1


levelsof id if timegap_p1==1, local(keepp1)
gen p1_gap = 0
foreach x in `keepp1' {

replace p1_gap = 1 if id=="`x'"
}

gen p2_gap = 0
levelsof id if timegap_p2==1, local(keepp2)
foreach x in `keepp2' {
replace p2_gap = 1 if id=="`x'"
}

*replace timegap = 4 if diff>2 & diff<=4
*replace timegap = 5 if diff>4


*label var timegap "years between index & n1, 5 = 5+ yrs"

/*Getting P1 followup */


preserve

keep if ind_p1_ivw==1
rename ind_p1_ivw ind_p1_followup
save "E:\data\Dialysis\p1datav2.dta", replace
restore

cap drop _merge
merge m:1 bid_hrs using "E:\data\Dialysis\p1datav2.dta", keepus(ind_p1_followup n1_ingap p1_gap p2_gap)
*replace ind_p1_followup = . if ind_n1_ivw!=1
label var ind_p1_followup "Has both N1 and P1 Interview"




/*Caregiver hours */

gen ind_any_help = 0
replace ind_any_help = 1 if n_hp > 0 & n_hp!=.
label var ind_any_help "Receives any form of help"

gen ind_paid_help = 0
replace ind_paid_help = 1 if n_f > 0 & n_f!=.
label var ind_paid_help "Receives paid help"

replace hlphrs=0 if hlphrs==. //hlphrs = sum of caregiver hours 

label var hlphrs "Average Monthly Helper hours at N1 (#)"

replace part_ab_6m=0 if part_ab_6m==.
replace part_ab_1y=0 if part_ab_1y==.
replace hmo_d_6m=1 if hmo_d_6m==.
replace hmo_d_1y=1 if hmo_d_1y==.

/*
gen no_ffs_1m = 0
replace no_ffs_1m = 1 if part_ab_6m==0 | hmo_d_6m==1
label var no_ffs_1m "No fee for service 1 month prior to Incident Dialysis (%)"
label var underage "64 or younger one month prior to 1st OP dialysis"

gen excluded = 0
replace excluded = 1 if underage==1 | no_ffs_1m==1 | timegap==1 | no_core==1
label var excluded "No FFS or underage 1 month prior or >4yrs or no core prior to dialysis"
label var periflag "Peritoneal Dialysis (%)"
label var hemoflag "Hemodialysis (%)"

gen ffs_1m = 0
replace ffs_1m = 1 if part_ab_6m==1 & hmo_d_6m==0
label var ffs_1m "FFS 1 month prior to Incident Dialysis (%)"

gen con_ffs_1yr = 0
replace con_ffs_1yr = 1 if underage==1 & part_ab_1y==1 & hmo_d_1y==0
label var con_ffs_1yr "Con. FFS 1yr after Incident Dialysis (<65 only, %)"

*/
gen died_after_n1 = 0
replace died_after_n1 = 1 if ind_n1_ivw==1 & ind_p1_followup==.



gen ind_ip_admit_1yr = 0
forvalues i = 1/12 {
replace ind_ip_admit_1yr = 1 if n_ip_admit_m`i'p > 0 & n_ip_admit_m`i'p!=.
}


gen ind_ip_admit_2yr = 0
forvalues i = 1/24 {
replace ind_ip_admit_2yr = 1 if n_ip_admit_m`i'p > 0 & n_ip_admit_m`i'p!=.
}

gen ind_ed_visit_1yr = 0
forvalues i = 1/12 {
replace ind_ed_visit_1yr = 1 if n_ed_op_visits_m`i'p > 0 & n_ed_op_visits_m`i'p!=.
}


gen ind_ed_visit_2yr = 0
forvalues i = 1/24 {
replace ind_ed_visit_2yr = 1 if n_ed_op_visits_m`i'p > 0 & n_ed_op_visits_m`i'p!=.
}

gen nhres_n1 = 0
replace nhres_n1 = 1 if nhres==1 & ind_n1_ivw==1


gen age_n1 = age if ind_n1_ivw==1
label var age_n1 "Average age at N1 interview (#)"


label var ind_ip_admit_1yr "Inpatient admit within 1yr after Incident Dialysis (%)"
label var ind_ip_admit_2yr "Inpatient admit within 2yr after Incident Dialysis (%)"
label var ind_ed_visit_1yr "ED visit within 1yr after Incident Dialysis (%)"
label var ind_ed_visit_2yr "ED visit within 2yr after Incident Dialysis (%)"
*label var comorb_31_0d_n12m "Comorb - Dementia within 1yr prior to Incident Dialysis (%)"
*label var comorb_31_0d_p12m "Comorb - Dementia 1yr after Incident Dialysis (%)"
*label var comorb_6_0d_n12m "Comorb - Hypertension within 1yr prior to Incident Dialysis (%)"
*label var comorb_10_0d_n12m "Comorb - Diabetes, uncomplicated within 1yr prior to Incident Dialysis (%)"
*label var comorb_11_0d_n12m "Comorb - Diabetes, complicated within 1yr prior to Incident Dialysis (%)"
*label var comorb_13_0d_n12m "Comorb - Renal Failure within 1yr prior to Incident Dialysis (%)"
*label var nhres_n1 "Nursing Home Resident at time of N1 (%)"
*label var nhres_p1 "Nursing Home Resident at time of p1"

gen disch_dead = 0
replace disch_dead = 1 if stus_cd=="20"
label var disch_dead "Discharged as dead on incident IP Dialysis (%)"


gen height_sq = height*height
gen wgt_bmi = wgt_curr * 703

gen bmi_d = .
replace bmi_d = wgt_bmi / height_sq



/* comorb count */




/* Was hospitalized 6/12 months prior to Dialysis */


gen hosp_30d_bef = 0
replace hosp_30d_bef = 1 if n_ip_admit_m1>0 & n_ip_admit_m1!=.


gen hosp_6m_bef = 0
forvalues i = 1/6 {
replace hosp_6m_bef = 1 if (n_ip_admit_m`i'>0 & n_ip_admit_m`i'!=.)
}


gen hosp_12m_bef = 0
forvalues i = 1/12 {
replace hosp_12m_bef = 1 if (n_ip_admit_m`i'>0 & n_ip_admit_m`i'!=.)
}

/* Was hospitalized after dialysis */

gen hosp_30d_post = 0
replace hosp_30d_post = 1 if n_ip_admit_m1p>0 & n_ip_admit_m1p!=.

gen hosp_6m_post = 0
forvalues i = 1/6 {
replace hosp_6m_post = 1 if (n_ip_admit_m`i'p>0 & n_ip_admit_m`i'p!=.)
}

gen hosp_1yr_post = 0
forvalues i = 1/12 {
replace hosp_1yr_post = 1 if (n_ip_admit_m`i'p>0 & n_ip_admit_m`i'p!=.)
}

gen hosp_2yr_post = 0
forvalues i = 1/24 {
replace hosp_2yr_post = 1 if (n_ip_admit_m`i'p>0 & n_ip_admit_m`i'p!=.)
}

egen comorb_count = rowtotal(comorb_1_0d_n12m comorb_2_0d_n12m comorb_3_0d_n12m comorb_4_0d_n12m comorb_5_0d_n12m comorb_6_0d_n12m comorb_7_0d_n12m comorb_8_0d_n12m ///
comorb_9_0d_n12m comorb_10_0d_n12m comorb_11_0d_n12m comorb_12_0d_n12m comorb_13_0d_n12m comorb_14_0d_n12m comorb_15_0d_n12m comorb_16_0d_n12m comorb_17_0d_n12m)


recode medicaid (. = 0)
recode champus (. = 0)
/* Number of hospital admits 1/6/12 months prior to Dialysis */



egen n_admit_6m_bef = rowtotal(n_ip_admit_m1 n_ip_admit_m2 n_ip_admit_m3 n_ip_admit_m4 n_ip_admit_m5 n_ip_admit_m6)

egen n_admit_12m_bef = rowtotal(n_ip_admit_m1 n_ip_admit_m2 n_ip_admit_m3 n_ip_admit_m4 n_ip_admit_m5 n_ip_admit_m6 n_ip_admit_m7 n_ip_admit_m8 n_ip_admit_m9 n_ip_admit_m10 n_ip_admit_m11 n_ip_admit_m12)


/* Average # hospital days prior/after to 1st dialysis */

egen n_hospdays_6m_bef = rowtotal(n_hospd_m1 n_hospd_m2 n_hospd_m3 n_hospd_m4 n_hospd_m5 n_hospd_m6)
egen n_hospdays_12m_bef = rowtotal(n_hospd_m1 n_hospd_m2 n_hospd_m3 n_hospd_m4 n_hospd_m5 n_hospd_m6 n_hospd_m7 n_hospd_m8 n_hospd_m9 n_hospd_m10 n_hospd_m11 n_hospd_m12) 

egen n_hospdays_6m_post = rowtotal(n_hospd_m1p n_hospd_m2p n_hospd_m3p n_hospd_m4p n_hospd_m5p n_hospd_m6p)
egen n_hospdays_12m_post = rowtotal(n_hospd_m1p n_hospd_m2p n_hospd_m3p n_hospd_m4p n_hospd_m5p n_hospd_m6p n_hospd_m7p n_hospd_m8p n_hospd_m9p n_hospd_m10p n_hospd_m11p n_hospd_m12p) 


/*ED visit before/after dialysis */


gen ed_30d_pre = 0
replace ed_30d_pre = 1 if n_ed_ip_m1>0 & n_ed_ip_m1!=.
replace ed_30d_pre = 1 if n_ed_op_visits_m1>0 & n_ed_op_visits_m1!=.

gen ed_6m_pre = 0
forvalues i = 1/6 {
replace ed_6m_pre = 1 if (n_ed_ip_m`i'>0 & n_ed_ip_m`i'!=.)
replace ed_6m_pre = 1 if n_ed_op_visits_m`i'>0 & n_ed_op_visits_m`i'!=.
}

gen ed_1yr_pre = 0
forvalues i = 1/12 {
replace ed_1yr_pre = 1 if (n_ed_ip_m`i'>0 & n_ed_ip_m`i'!=.)
replace ed_1yr_pre = 1 if n_ed_op_visits_m`i'>0 & n_ed_op_visits_m`i'!=.
}

gen ed_30d_post = 0
replace ed_30d_post = 1 if n_ed_ip_m1p>0 & n_ed_ip_m1p!=.
replace ed_30d_post = 1 if n_ed_op_visits_m1p>0 & n_ed_op_visits_m1p!=.

gen ed_6m_post = 0
forvalues i = 1/6 {
replace ed_6m_post = 1 if (n_ed_ip_m`i'p>0 & n_ed_ip_m`i'p!=.)
replace ed_6m_post = 1 if n_ed_op_visits_m`i'p>0 & n_ed_op_visits_m`i'p!=.
}

gen ed_1yr_post = 0
forvalues i = 1/12 {
replace ed_1yr_post = 1 if (n_ed_ip_m`i'p>0 & n_ed_ip_m`i'p!=.)
replace ed_1yr_post = 1 if n_ed_op_visits_m`i'p>0 & n_ed_op_visits_m`i'p!=.
}

gen ed_2yr_post = 0
forvalues i = 1/24 {
replace ed_2yr_post = 1 if (n_ed_ip_m`i'p>0 & n_ed_ip_m`i'p!=.)
}


/* ICU Visits */

gen icu_30d_pre = 0
replace icu_30d_pre = 1 if icu_days_m1>0 & icu_days_m1!=.

gen icu_6m_pre = 0
forvalues i = 1/6 {
replace icu_6m_pre = 1 if (icu_days_m`i'>0 & icu_days_m`i'!=.)
}

gen icu_1yr_pre = 0
forvalues i = 1/12 {
replace icu_1yr_pre = 1 if (icu_days_m`i'>0 & icu_days_m`i'!=.)
}


gen icu_30d_post = 0
replace icu_30d_post = 1 if icu_days_m1p>0 & icu_days_m1p!=.

gen icu_6m_post = 0
forvalues i = 1/6 {
replace icu_6m_post = 1 if (icu_days_m`i'p>0 & icu_days_m`i'p!=.)
}

gen icu_1yr_post = 0
forvalues i = 1/12 {
replace icu_1yr_post = 1 if (icu_days_m`i'p>0 & icu_days_m`i'p!=.)
}

gen icu_2yr_post = 0
forvalues i = 1/24 {
replace icu_2yr_post = 1 if (icu_days_m`i'p>0 & icu_days_m`i'p!=.)
}



/* CMS chornoic conditions */

gen dm_flag = 0
replace dm_flag = 1 if comorb_10_0d_n12m==1 | comorb_11_0d_n12m==1

egen cms_chronic = anycount(comorb_5_0d_n12m comorb_6_0d_n12m dm_flag comorb_13_0d_n12m comorb_32_0d_n12m comorb_18_0d_n12m comorb_1_0d_n12m), values(1)

cap drop _m

merge m:1 id using "E:\data\Dialysis\hospice.dta", keepus(claim_id_hrs_21)

gen hosp_enroll = 0
replace hosp_enroll = 1 if _m==3
drop _m


/*
tab _m if ind_n1_ivw==1
tab _m if ind_n1_ivw==1 & true_op==1
tab _m if ind_n1_ivw==1 & ip_start==1
tab _m if ind_n1_ivw==1 & ip_start==1 & disch_dead==1
tab _m if ind_n1_ivw==1 & ip_start==1 & ip_only==0
tab _m if ind_n1_ivw==1 & ip_start==1 & ip_only==1 & disch_dead==0
*/


gen avg_hospd_1yr = 0
forvalues i = 1/12 {
replace avg_hospd_1yr = avg_hospd_1yr + n_hospd_m`i'p
}

replace avg_hospd_1yr = avg_hospd_1yr/12
label var avg_hospd_1yr "Average hospital days 1 year post Dialysis (#)"


gen avg_hospd_2yr = 0
forvalues i = 13/24 {
replace avg_hospd_2yr = avg_hospd_2yr + n_hospd_m`i'p
}

replace avg_hospd_2yr = avg_hospd_2yr/12
label var avg_hospd_2yr "Average hospital days 2 year post dialysis (#)"

/* Add flag for people with dialysis in the last quarter of 2012 */

replace hseduc = 0 if degree==0
replace hseduc = 1 if degree>=1


gen last_qrtr = 0
replace last_qrtr = 1 if index_year==2012 & index_month>=10
label var last_qrtr "1st Dialysis in last quarter 2012 (%)"



/*Creating p1 variables */

preserve 
keep if ind_p1_ivw==1

local p1vars proxy_core medicaid medigap srh_pf adl_diff_dr adl_diff_wk adl_diff_bh adl_diff_e adl_diff_t adl_diff_tx adl_independent_core ///
adl_wk_core adl_bh_core adl_e_core adl_tx_core adl_t_core adl_dr_core ///
likelydem likelycind likelynormal comorb_31_0d_p12m nhres ///
ind_any_help ind_paid_help dial_to_p1 hlphrs age champus

foreach x of local p1vars {
rename `x' `x'_p1

}


save "E:\data\Dialysis\p1data.dta", replace 
local p2vars srh_pf_p1 proxy_core_p1 medicaid_p1 medigap_p1 adl_diff_dr_p1 adl_diff_wk_p1 adl_diff_bh_p1 adl_diff_e_p1 adl_diff_t_p1 adl_diff_tx_p1 adl_independent_core_p1 ///
adl_wk_core_p1 adl_bh_core_p1 adl_e_core_p1 adl_tx_core_p1 adl_t_core_p1 adl_dr_core_p1 ///
likelydem_p1 likelycind_p1 likelynormal_p1 comorb_31_0d_p12m_p1 nhres_p1 ///
ind_any_help_p1 ind_paid_help_p1 dial_to_p1_p1 hlphrs_p1 age_p1 champus_p1
restore
cap drop _merge
merge m:1 bid_hrs using "E:\data\Dialysis\p1data.dta", keepus(`p2vars')

label var adl_diff_dr "Difficulty dressing at N1 (%)"
label var adl_diff_wk "Difficulty walking at N1 (%)"
label var adl_diff_bh "Difficulty bathing at N1 (%)"
label var adl_diff_e "Difficulty eating at N1 (%)"
label var adl_diff_t "Difficulty toileting at N1 (%)"
label var adl_diff_tx "Difficulty transfers to bed at N1 (%)"
label var adl_independent_core "Independent for ADLs at N1 (%)"
label var adl_wk_core "Help Walking at N1 (%)"
label var adl_bh_core "Help Bathing at N1 (%)"
label var adl_e_core "Help Eating at N1 (%)"
label var adl_tx_core "Help with Transfers to Bed at N1 (%)"
label var adl_t_core "Help with Toileting at N1 (%)" 
label var adl_dr_core "Help with Dressing at N1 (%)"
label var nhres_n1 "Nursing Home resident at time of N1 (%)"
label var ind_any_help "Receives some form of help at N1 (%)"
label var ind_paid_help "Receives paid help at N1 (%)"
label var hlphrs "Average Monthly Helper hours at N1 (#)"
label var srh_pf "Self Reported Health: Poor/Fair N1 (%)"
label var proxy_core "Proxy Respondent at N1 (%)"
label var medicaid "Medicaid at N1 (%)"
label var medigap "Medigap at N1 (%)"
label var age "Average age at N1 (#)"
label var champus "Has Veterans insurance at N1"




label var adl_diff_dr_p1 "Difficulty dressing at P1 (%)"
label var adl_diff_wk_p1 "Difficulty walking at P1 (%)"
label var adl_diff_bh_p1 "Difficulty bathing at P1 (%)"
label var adl_diff_e_p1 "Difficulty eating at P1 (%)"
label var adl_diff_t_p1 "Difficulty toileting at P1 (%)"
label var adl_diff_tx_p1 "Difficulty transfers to bed at P1(%)"
label var adl_independent_core_p1 "Independent for ADLs at P1 (%)"
label var adl_wk_core_p1 "Help Walking at P1 (%)"
label var adl_bh_core_p1 "Help Bathing at P1 (%)"
label var adl_e_core_p1 "Help Eating at P1 (%)"
label var adl_tx_core_p1 "Help with Transfers to Bed at P1 (%)"
label var adl_t_core_p1 "Help with Toileting at P1 (%)" 
label var adl_dr_core_p1 "Help with Dressing at P1 (%)"
label var nhres_p1 "Nursing Home resident at time of P1 (%)"
label var ind_any_help_p1 "Receives some form of help at P1 (%)"
label var ind_paid_help_p1 "Receives paid help at P1 (%)"
label var hlphrs_p1 "Average Monthly Helper hours at P1 (#)"
label var srh_pf_p1 "Self Reported Health: Poor/Fair P1 (%)"
label var proxy_core_p1 "Proxy Respondent at P1 (%)"
label var medicaid_p1 "Medicaid at P1 (%)"
label var medigap_p1 "Medigap at P1 (%)"
label var age_p1 "Average age at P1 (#)"
label var champus_p1 "Has Veterans insurance at P1"

replace esrd_ind = "1" if esrd_ind=="Y"
destring esrd_ind, replace
label var esrd_ind "ESRD indicator from DN file (%)"

label var likelydem "Likely Dementia at N1 (%)"
label var likelycind "Likely CIND at N1 (%)"
label var likelynormal "Likely Normal at N1 (%)"
label var likelydem_p1 "Likely Dementia at P1 (%)"
label var likelycind_p1 "Likely CIND at P1 (%)"
label var likelynormal_p1 "Likely Normal at P1 (%)"
*replace esrd_ind = "0" if esrd

*replace dx_flag = 0 if dx_flag==.
gen esrd_comorb = 0
replace esrd_comorb = 1 if comorb_13_0d_p12m==1 | comorb_13_0d_n12m==1

label var ip_only "No OP dialysis claim, only IP"
*label var dx_flag "Flag for Renal Failure Diagnosis Code"
*label var cptflag "Has Dialysis Procedure coode in Carrier/OP"

label var female "Female (%)"
label var white "Non-Hispanic White/Caucasian (%)"
label var black "Non-Hispanic black or African American (%)"
label var hisp_eth "Hispanic Ethnicity (%)"
label var hseduc "Eduction, High School (%)"

gen non_white = 1
replace non_white = 0 if white==1
****** key groups *********

/* id_flag==1 // unique id for total pop
cptflag==1 // only carrier/op procedure code
dx_flag==1 // diagnosis codes from mb & op
esrd_ind==1 // esrd_flag from denominator
ip_overlap==1 | ip_only==1// IP incident dialysis
*/

replace n1_to_dial = . if n1_to_dial <=0
replace dial_to_p1 = . if dial_to_p1 <=0

replace periflag = 1 if cptcodes==5498
replace hemoflag=1 if cptcodes==3995

replace periflag=0 if periflag==.
replace hemoflag=0 if hemoflag==.

gen true_op = 0
replace true_op = 1 if ip_start==0

gen ip_overlap = 0
replace ip_overlap = 1 if ip_start==1 & ip_only==0

egen adl_core_c = anycount(adl_dr_core adl_wk_core adl_bh_core adl_e_core adl_tx_core adl_t_core), values(1)
gen adl_indep_core = 0
replace adl_indep_core = 1 if adl_core_c==0
gen adl_mod_core = 0
replace adl_mod_core = 1 if adl_core_c>0 & adl_core_c<4
gen adl_sev_core = 0
replace adl_sev_core = 1 if adl_core_c>=4 & adl_core_c<=6

gen srh_gve = 0
replace srh_gve = 1 if srh_g==1 | srh_ve==1

gen adl_dep_core = 0
replace adl_dep_core = 1 if adl_indep_core==0 


gen tics_8p = 0 if tics_tot!=.
replace tics_8p = 1 if tics_tot>8 & tics_tot!=.

gen tics_8 = 0 if tics_tot!=.
replace tics_8 = 1 if tics_tot<=8

cap drop _m
merge m:1 bid_hrs_21 using "E:\data\Dialysis\int_data\npr_visit.dta"

drop if timegap==0 & ind_n1_ivw==1

/* ADL vs Time Graph */

/* N1 */
gen ivw_gap = 0
local q = -1
local r = 0
local s = 30

while `s' <=1080 {
replace ivw_gap=`q' if n1_to_dial>`r' & n1_to_dial<=`s' & ind_n1_ivw==1
local --q
local r = `r' + 30
local s = `s' + 30
}

/* P1 */
local q = 1
local r = 0
local s = 30

while `s' <=1300 {
replace ivw_gap=`q' if (dial_to_p1>`r' & dial_to_p1<=`s') & n1_ingap==1 & ind_p1_ivw==1
local ++q
local r = `r' + 30
local s = `s' + 30
}

/*Exit*/
expand = 2 if ind_n1_ivw==1 & exit_year!=., gen(ind_exit_ivw)
egen adl_exit_c = anycount(adl_dr adl_wk adl_bh adl_e adl_tx adl_t) if ind_exit_ivw==1, values(1)
gen adl_dep_exit = 0
replace adl_dep_exit = 1 if adl_exit_c>0 & ind_exit_ivw==1

gen report_date = death_all - 42 if ind_exit_ivw==1
format %td report_date

gen dial_to_report = report_date - index_date 


local q = 1
local r = 0
local s = 30

replace ivw_gap = 1 if dial_to_report<=0 & ind_exit_ivw==1
while `s' <= 3900 {

replace ivw_gap=`q' if ind_exit_ivw==1 & (dial_to_report>`r' & dial_to_report<=`s')
local ++q
local r = `r' + 30
local s = `s' + 30
}

/* Calculate ratio - N1 */
preserve
contract ivw_gap if ivw_gap<0
save "E:\data\Dialysis\int_data\ivwgap_freq.dta", replace
restore
cap drop _m
merge m:1 ivw_gap using "E:\data\Dialysis\int_data\ivwgap_freq.dta", keepus(_freq)
cap drop _m

gen percentage_n1 = _freq/283
preserve
keep if ind_n1_ivw==1 & adl_dep_core==1
egen adl_count = count(adl_dep_core), by(ivw_gap)
keep ivw_gap adl_count
duplicates drop
save "E:\data\Dialysis\int_data\adln1_freq.dta", replace
restore
cap drop _m
merge m:1 ivw_gap using "E:\data\Dialysis\int_data\adln1_freq.dta", keepus(adl_count)
cap drop _m

gen percentage_adl = adl_count/283
gen ratio = percentage_adl/percentage_n1

/*Calculate Ratio - P1 */

preserve
contract ivw_gap if ind_p1_ivw==1 & n1_ingap==1, freq(p1_freq)
save "E:\data\Dialysis\int_data\p1gap_freq.dta", replace
restore
cap drop _m
merge m:1 ivw_gap using "E:\data\Dialysis\int_data\p1gap_freq.dta", keepus(p1_freq)
cap drop _m

gen percentage_p1 = p1_freq/112
preserve
keep if ind_p1_ivw==1 & adl_dep_core==1 & n1_ingap==1
egen adl_count_p1 = count(adl_dep_core), by(ivw_gap)
keep ivw_gap adl_count_p1
duplicates drop
save "E:\data\Dialysis\int_data\adlp1_freq.dta", replace
restore
cap drop _m
merge m:1 ivw_gap using "E:\data\Dialysis\int_data\adlp1_freq.dta", keepus(adl_count_p1)
cap drop _m

replace percentage_adl = adl_count_p1/112 if ind_p1_ivw==1 & n1_ingap==1
replace ratio = percentage_adl/percentage_p1 if ind_p1_ivw==1 & n1_ingap==1



/* Calculate Ratio - Exit */
preserve
contract ivw_gap if ind_exit_ivw==1, freq(exit_freq)
gen ind_exit_ivw = 1
save "E:\data\Dialysis\int_data\exit_freq.dta", replace
restore
cap drop _m
merge m:1 ivw_gap ind_exit_ivw using "E:\data\Dialysis\int_data\exit_freq.dta", keepus(exit_freq)
cap drop _m

gen percentage_exit = exit_freq/236
preserve
keep if ind_exit_ivw==1 & adl_dep_exit==1
egen adl_count_exit = count(adl_dep_exit), by(ivw_gap)
keep ivw_gap adl_count_exit
duplicates drop
gen ind_exit_ivw = 1
save "E:\data\Dialysis\int_data\adlexit_freq.dta", replace
restore 
cap drop _m
merge m:1 ivw_gap ind_exit_ivw using "E:\data\Dialysis\int_data\adlexit_freq.dta", keepus(adl_count_exit)
cap drop _m

replace percentage_adl = adl_count_exit/236 if ind_exit_ivw==1
replace ratio = percentage_adl/percentage_exit if ind_exit_ivw==1

save "E:\data\Dialysis\final_data\hrs_dialysis.dta", replace

/* Scatter plot */
*scatter ratio ivw_gap if ivw_gap<50, xline(0)
graph twoway (scatter ratio ivw_gap if ind_n1_ivw==1) (scatter ratio ivw_gap if ind_p1_ivw==1 & n1_ingap==1) (scatter ratio ivw_gap if ind_exit_ivw==1) if ivw_gap<=36, ///
legend(label(1 N1) label(2 P1) label(3 Exit)) xline(0) ytitle("Relative ADL Dependence") xtitle("Months from Index Date") xlabel(-36(6)36)


keep if ivw_gap<0
keep ivw_gap p1_freq adl_count_p1 percentage_p1 percentage_adl 


/* Tables 4/13/17 */

local ivars female race hseduc esrd_ind comorb_31_0d_n12m comorb_6_0d_n12m comorb_10_0d_n12m comorb_11_0d_n12m ///
comorb_13_0d_n12m comorb_32_0d_n12m comorb_18_0d_n12m comorb_1_0d_n12m proxy_core medicaid ///
srh adl_core_c adl_dr_core adl_wk_core adl_bh_core adl_e_core adl_tx_core adl_t_core likely_dem likely_cind likely_normal ///
pdem tics_tot nhres

local cvars n1_to_dial dial_to_p1

foreach x of local ivars {

tab `x' if ind_n1_ivw==1, m 
}



/*Table 1B: N1 Sample Characteristics */

local ivars1 female white black hisp_eth hseduc died_1yr died_2yr periflag hemoflag esrd_ind disch_dead ///
comorb_31_0d_n12m comorb_31_0d_p12m comorb_6_0d_n12m comorb_10_0d_n12m comorb_11_0d_n12m comorb_13_0d_n12m ///
last_qrtr ind_ip_admit_1yr ind_ip_admit_2yr ind_ed_visit_1yr ind_ed_visit_2yr ffs_1m con_ffs_1yr

local ivars2 proxy_core medicaid medigap srh_pf /// 
adl_diff_dr adl_diff_wk adl_diff_bh adl_diff_e adl_diff_t adl_diff_tx adl_independent_core ///
adl_wk_core adl_bh_core adl_e_core adl_tx_core adl_t_core adl_dr_core ///
likelydem likelycind likelynormal nhres_n1 champus ///
ind_any_help ind_paid_help  ///

local cvars1 age_n1 hlphrs n1_to_dial dial_to_p1_p1 mortality age_p1 hlphrs_p1

local ivars3 srh_pf_p1 proxy_core_p1 medicaid_p1 medigap_p1 adl_diff_dr_p1 adl_diff_wk_p1 adl_diff_bh_p1 adl_diff_e_p1 adl_diff_t_p1 adl_diff_tx_p1 adl_independent_core_p1 ///
adl_wk_core_p1 adl_bh_core_p1 adl_e_core_p1 adl_tx_core_p1 adl_t_core_p1 adl_dr_core_p1 ///
likelydem_p1 likelycind_p1 likelynormal_p1 ind_any_help_p1 ind_paid_help_p1 nhres_p1 champus_p1 ///

local rd: word count `ivars1' `ivars2' `cvars1' `ivars3' 1 1 1
di `rd'

local rn : word count `ivars1' 
di `rn'

local rn : word count `ivars2' 
di `rn'

local rn : word count `cvars1' 
di `rn'


local rn : word count `ivars3' 
di `rn'




mat tab2=J(`rd',4,.)

/* True 1st OP Dialysis, 65+ */

local r = 1

foreach x of local ivars1 {
			qui sum `x' if id_flag==1 & true_op==1 & underage==0
			mat tab2[`r',1]=r(mean)*100
			local r=`r'+1

}

*local r = 25

foreach x of local ivars2 {
			qui sum `x' if ind_n1_ivw==1 & true_op==1 & underage==0
			mat tab2[`r',1]=r(mean)*100
			local r=`r'+1

}

*local r = 48

foreach x of local cvars1 {
		qui sum `x' if ind_n1_ivw==1 & true_op==1 & underage==0
		mat tab2[`r',1]=r(mean)
		local r=`r'+1
		}

*local r = 55

foreach x of local ivars3 {
			qui sum `x' if ind_n1_ivw==1 & true_op==1 & underage==0
			mat tab2[`r',1]=r(mean)*100
			local r=`r'+1

}

qui sum id_flag if true_op==1 & underage==0
mat tab2[`r',1]=r(N)

qui sum ind_n1_ivw if ind_n1_ivw==1 & true_op==1 & underage==0
mat tab2[`r'+1,1]=r(N)

qui sum ind_n1_ivw if ind_n1_ivw==1 & ind_p1_followup==1 & true_op==1 & underage==0
mat tab2[`r'+2,1]=r(N)


*mat rownames tab2=`ivars1' `ivars2' `cvars1' `ivars3' "Overall Sample Size" "Sample Size at N1" "Sample Size at P1"


/* True 1st OP Dialysis, 65+ , N */

local r = 1

foreach x of local ivars1 {
			qui sum `x' if id_flag==1 & true_op==1 & underage==0
			mat tab2[`r',2]=r(N)
			local r=`r'+1

}

*local r = 25

foreach x of local ivars2 {
			qui sum `x' if ind_n1_ivw==1 & true_op==1 & underage==0
			mat tab2[`r',2]=r(N)
			local r=`r'+1

}

*local r = 48

foreach x of local cvars1 {
		qui sum `x' if ind_n1_ivw==1 & true_op==1 & underage==0
		mat tab2[`r',2]=r(N)
		local r=`r'+1
		}

*local r = 55

foreach x of local ivars3 {
			qui sum `x' if ind_n1_ivw==1 & true_op==1 & underage==0
			mat tab2[`r',2]=r(N)
			local r=`r'+1

}

qui sum id_flag if true_op==1 & underage==0
mat tab2[`r',2]=r(N)

qui sum ind_n1_ivw if ind_n1_ivw==1 & true_op==1 & underage==0
mat tab2[`r'+1,2]=r(N)

qui sum ind_n1_ivw if ind_n1_ivw==1 & ind_p1_followup==1 & true_op==1 & underage==0
mat tab2[`r'+2,2]=r(N)




/* True 1st OP Dialysis, <65 */				


local r = 1

foreach x of local ivars1 {
			qui sum `x' if id_flag==1 & true_op==1 & underage==1
			mat tab2[`r',3]=r(mean)*100
			local r=`r'+1

}

*local r = 25

foreach x of local ivars2 {
			qui sum `x' if ind_n1_ivw==1 & true_op==1 & underage==1
			mat tab2[`r',3]=r(mean)*100
			local r=`r'+1

}

*local r = 48

foreach x of local cvars1 {
		qui sum `x' if ind_n1_ivw==1 & true_op==1 & underage==1
		mat tab2[`r',3]=r(mean)
		local r=`r'+1
		}

*local r = 55

foreach x of local ivars3 {
			qui sum `x' if ind_n1_ivw==1 & true_op==1 & underage==1
			mat tab2[`r',3]=r(mean)*100
			local r=`r'+1

}

qui sum id_flag if true_op==1 & underage==1
mat tab2[`r',3]=r(N)

qui sum ind_n1_ivw if ind_n1_ivw==1 & true_op==1 & underage==1
mat tab2[`r'+1,3]=r(N)

qui sum ind_n1_ivw if ind_n1_ivw==1 & ind_p1_followup==1 & true_op==1 & underage==1
mat tab2[`r'+2,3]=r(N)


/* True 1st OP Dialysis, <65, N */		


local r = 1

foreach x of local ivars1 {
			qui sum `x' if id_flag==1 & true_op==1 & underage==1
			mat tab2[`r',4]=r(N)
			local r=`r'+1

}

*local r = 25

foreach x of local ivars2 {
			qui sum `x' if ind_n1_ivw==1 & true_op==1 & underage==1
			mat tab2[`r',4]=r(N)
			local r=`r'+1

}

*local r = 48

foreach x of local cvars1 {
		qui sum `x' if ind_n1_ivw==1 & true_op==1 & underage==1
		mat tab2[`r',4]=r(N)
		local r=`r'+1
		}

*local r = 55

foreach x of local ivars3 {
			qui sum `x' if ind_n1_ivw==1 & true_op==1 & underage==1
			mat tab2[`r',4]=r(N)
			local r=`r'+1

}

qui sum id_flag if true_op==1 & underage==1
mat tab2[`r',4]=r(N)

qui sum ind_n1_ivw if ind_n1_ivw==1 & true_op==1 & underage==1
mat tab2[`r'+1,4]=r(N)

qui sum ind_n1_ivw if ind_n1_ivw==1 & ind_p1_followup==1 & true_op==1 & underage==1
mat tab2[`r'+2,4]=r(N)



	
mat rownames tab2=`ivars1' `ivars2' `cvars1' `ivars3' "Overall Sample Size (#)" "Sample Size at N1 (#)" "Sample Size at P1 (#)"
mat list tab2

frmttable using "E:\projects\Dialysis\archive_logs\trueop_characteristics.doc", replace statmat(tab2) ///
varlabels title("Incident Dialysis - OP: Sample Characteristics at N1 & P1 Core Interviews") ctitles("" ">65" "N" "<65" "N") sdec(1) ///
note()
                                                                                                                                                                                                                                                                                                                                                                                                                 

				
				
/* Table 1.1 */
				


mat tab3=J(`rd',4,.)

/* ip_overlap==1 , 65+ */

local r = 1

foreach x of local ivars1 {
			qui sum `x' if id_flag==1 & ip_overlap==1 & underage==0
			mat tab2[`r',1]=r(mean)*100
			local r=`r'+1

}

*local r = 25

foreach x of local ivars2 {
			qui sum `x' if ind_n1_ivw==1 & ip_overlap==1 & underage==0
			mat tab2[`r',1]=r(mean)*100
			local r=`r'+1

}

*local r = 48

foreach x of local cvars1 {
		qui sum `x' if ind_n1_ivw==1 & ip_overlap==1 & underage==0
		mat tab2[`r',1]=r(mean)
		local r=`r'+1
		}

*local r = 55

foreach x of local ivars3 {
			qui sum `x' if ind_n1_ivw==1 & ip_overlap==1 & underage==0
			mat tab2[`r',1]=r(mean)*100
			local r=`r'+1

}

qui sum id_flag if ip_overlap==1 & underage==0
mat tab2[`r',1]=r(N)

qui sum ind_n1_ivw if ind_n1_ivw==1 & ip_overlap==1 & underage==0
mat tab2[`r'+1,1]=r(N)

qui sum ind_n1_ivw if ind_n1_ivw==1 & ind_p1_followup==1 & ip_overlap==1 & underage==0
mat tab2[`r'+2,1]=r(N)

/* ip_overlap==1, 65+ , N */

local r = 1

foreach x of local ivars1 {
			qui sum `x' if id_flag==1 & ip_overlap==1 & underage==0
			mat tab2[`r',2]=r(N)
			local r=`r'+1

}

*local r = 25

foreach x of local ivars2 {
			qui sum `x' if ind_n1_ivw==1 & ip_overlap==1 & underage==0
			mat tab2[`r',2]=r(N)
			local r=`r'+1

}

*local r = 48

foreach x of local cvars1 {
		qui sum `x' if ind_n1_ivw==1 & ip_overlap==1 & underage==0
		mat tab2[`r',2]=r(N)
		local r=`r'+1
		}

*local r = 55

foreach x of local ivars3 {
			qui sum `x' if ind_n1_ivw==1 & ip_overlap==1 & underage==0
			mat tab2[`r',2]=r(N)
			local r=`r'+1

}

qui sum id_flag if ip_overlap==1 & underage==0
mat tab2[`r',2]=r(N)

qui sum ind_n1_ivw if ind_n1_ivw==1 & ip_overlap==1 & underage==0
mat tab2[`r'+1,2]=r(N)

qui sum ind_n1_ivw if ind_n1_ivw==1 & ind_p1_followup==1 & ip_overlap==1 & underage==0
mat tab2[`r'+2,2]=r(N)





/* ip_overlap==1, <65 */				

local r = 1

foreach x of local ivars1 {
			qui sum `x' if id_flag==1 & ip_overlap==1 & underage==1
			mat tab2[`r',3]=r(mean)*100
			local r=`r'+1

}

*local r = 25

foreach x of local ivars2 {
			qui sum `x' if ind_n1_ivw==1 & ip_overlap==1 & underage==1
			mat tab2[`r',3]=r(mean)*100
			local r=`r'+1

}

*local r = 48

foreach x of local cvars1 {
		qui sum `x' if ind_n1_ivw==1 & ip_overlap==1 & underage==1
		mat tab2[`r',3]=r(mean)
		local r=`r'+1
		}

*local r = 55

foreach x of local ivars3 {
			qui sum `x' if ind_n1_ivw==1 & ip_overlap==1 & underage==1
			mat tab2[`r',3]=r(mean)*100
			local r=`r'+1

}

qui sum id_flag if ip_overlap==1 & underage==1
mat tab2[`r',3]=r(N)

qui sum ind_n1_ivw if ind_n1_ivw==1 & ip_overlap==1 & underage==1
mat tab2[`r'+1,3]=r(N)

qui sum ind_n1_ivw if ind_n1_ivw==1 & ind_p1_followup==1 & ip_overlap==1 & underage==1
mat tab2[`r'+2,3]=r(N)

/* ip_overlap==1, <65, N */		

		

local r = 1

foreach x of local ivars1 {
			qui sum `x' if id_flag==1 & ip_overlap==1 & underage==1
			mat tab2[`r',4]=r(N)
			local r=`r'+1

}

*local r = 25

foreach x of local ivars2 {
			qui sum `x' if ind_n1_ivw==1 & ip_overlap==1 & underage==1
			mat tab2[`r',4]=r(N)
			local r=`r'+1

}

*local r = 48

foreach x of local cvars1 {
		qui sum `x' if ind_n1_ivw==1 & ip_overlap==1 & underage==1
		mat tab2[`r',4]=r(N)
		local r=`r'+1
		}

*local r = 55

foreach x of local ivars3 {
			qui sum `x' if ind_n1_ivw==1 & ip_overlap==1 & underage==1
			mat tab2[`r',4]=r(N)
			local r=`r'+1

}

qui sum id_flag if ip_overlap==1 & underage==1
mat tab2[`r',4]=r(N)

qui sum ind_n1_ivw if ind_n1_ivw==1 & ip_overlap==1 & underage==1
mat tab2[`r'+1,4]=r(N)

qui sum ind_n1_ivw if ind_n1_ivw==1 & ind_p1_followup==1 & ip_overlap==1 & underage==1
mat tab2[`r'+2,4]=r(N)


	
mat rownames tab2=`ivars1' `ivars2' `cvars1' `ivars3' "Overall Sample Size (#)" "Sample Size at N1 (#)" "Sample Size at P1 (#)"


frmttable using "E:\projects\Dialysis\archive_logs\overlap_characteristics.doc", replace statmat(tab2) ///
varlabels title("Incident Dialysis - IP, Subsequent OP: Sample Characteristics at N1 & P1 Core Interviews") ctitles("" ">65" "N" "<65" "N") sdec(1) ///
note()
          
				

/* Table 1.1 */
				


mat tab3=J(`rd',4,.)

/* ip_only==1 & ip_start==1 , 65+ */

local r = 1

foreach x of local ivars1 {
			qui sum `x' if id_flag==1 & ip_only==1 & ip_start==1 & underage==0
			mat tab2[`r',1]=r(mean)*100
			local r=`r'+1

}

*local r = 25

foreach x of local ivars2 {
			qui sum `x' if ind_n1_ivw==1 & ip_only==1 & ip_start==1 & underage==0
			mat tab2[`r',1]=r(mean)*100
			local r=`r'+1

}

*local r = 48

foreach x of local cvars1 {
		qui sum `x' if ind_n1_ivw==1 & ip_only==1 & ip_start==1 & underage==0
		mat tab2[`r',1]=r(mean)
		local r=`r'+1
		}

*local r = 55

foreach x of local ivars3 {
			qui sum `x' if ind_n1_ivw==1 & ip_only==1 & ip_start==1 & underage==0
			mat tab2[`r',1]=r(mean)*100
			local r=`r'+1

}

qui sum id_flag if ip_only==1 & ip_start==1 & underage==0
mat tab2[`r',1]=r(N)

qui sum ind_n1_ivw if ind_n1_ivw==1 & ip_only==1 & ip_start==1 & underage==0
mat tab2[`r'+1,1]=r(N)

qui sum ind_n1_ivw if ind_n1_ivw==1 & ind_p1_followup==1 & ip_only==1 & ip_start==1 & underage==0
mat tab2[`r'+2,1]=r(N)

/* ip_only==1 & ip_start==1, 65+ , N */

local r = 1

foreach x of local ivars1 {
			qui sum `x' if id_flag==1 & ip_only==1 & ip_start==1 & underage==0
			mat tab2[`r',2]=r(N)
			local r=`r'+1

}

*local r = 25

foreach x of local ivars2 {
			qui sum `x' if ind_n1_ivw==1 & ip_only==1 & ip_start==1 & underage==0
			mat tab2[`r',2]=r(N)
			local r=`r'+1

}

*local r = 48

foreach x of local cvars1 {
		qui sum `x' if ind_n1_ivw==1 & ip_only==1 & ip_start==1 & underage==0
		mat tab2[`r',2]=r(N)
		local r=`r'+1
		}

*local r = 55

foreach x of local ivars3 {
			qui sum `x' if ind_n1_ivw==1 & ip_only==1 & ip_start==1 & underage==0
			mat tab2[`r',2]=r(N)
			local r=`r'+1

}

qui sum id_flag if ip_only==1 & ip_start==1 & underage==0
mat tab2[`r',2]=r(N)

qui sum ind_n1_ivw if ind_n1_ivw==1 & ip_only==1 & ip_start==1 & underage==0
mat tab2[`r'+1,2]=r(N)

qui sum ind_n1_ivw if ind_n1_ivw==1 & ind_p1_followup==1 & ip_only==1 & ip_start==1 & underage==0
mat tab2[`r'+2,2]=r(N)





/* ip_only==1 & ip_start==1, <65 */				

local r = 1

foreach x of local ivars1 {
			qui sum `x' if id_flag==1 & ip_only==1 & ip_start==1 & underage==1
			mat tab2[`r',3]=r(mean)*100
			local r=`r'+1

}

*local r = 25

foreach x of local ivars2 {
			qui sum `x' if ind_n1_ivw==1 & ip_only==1 & ip_start==1 & underage==1
			mat tab2[`r',3]=r(mean)*100
			local r=`r'+1

}

*local r = 48

foreach x of local cvars1 {
		qui sum `x' if ind_n1_ivw==1 & ip_only==1 & ip_start==1 & underage==1
		mat tab2[`r',3]=r(mean)
		local r=`r'+1
		}

*local r = 55

foreach x of local ivars3 {
			qui sum `x' if ind_n1_ivw==1 & ip_only==1 & ip_start==1 & underage==1
			mat tab2[`r',3]=r(mean)*100
			local r=`r'+1

}

qui sum id_flag if ip_only==1 & ip_start==1 & underage==1
mat tab2[`r',3]=r(N)

qui sum ind_n1_ivw if ind_n1_ivw==1 & ip_only==1 & ip_start==1 & underage==1
mat tab2[`r'+1,3]=r(N)

qui sum ind_n1_ivw if ind_n1_ivw==1 & ind_p1_followup==1 & ip_only==1 & ip_start==1 & underage==1
mat tab2[`r'+2,3]=r(N)

/* ip_only==1 & ip_start==1, <65, N */		

		

local r = 1

foreach x of local ivars1 {
			qui sum `x' if id_flag==1 & ip_only==1 & ip_start==1 & underage==1
			mat tab2[`r',4]=r(N)
			local r=`r'+1

}

*local r = 25

foreach x of local ivars2 {
			qui sum `x' if ind_n1_ivw==1 & ip_only==1 & ip_start==1 & underage==1
			mat tab2[`r',4]=r(N)
			local r=`r'+1

}

*local r = 48

foreach x of local cvars1 {
		qui sum `x' if ind_n1_ivw==1 & ip_only==1 & ip_start==1 & underage==1
		mat tab2[`r',4]=r(N)
		local r=`r'+1
		}

*local r = 55

foreach x of local ivars3 {
			qui sum `x' if ind_n1_ivw==1 & ip_only==1 & ip_start==1 & underage==1
			mat tab2[`r',4]=r(N)
			local r=`r'+1

}

qui sum id_flag if ip_only==1 & ip_start==1 & underage==1
mat tab2[`r',4]=r(N)

qui sum ind_n1_ivw if ind_n1_ivw==1 & ip_only==1 & ip_start==1 & underage==1
mat tab2[`r'+1,4]=r(N)

qui sum ind_n1_ivw if ind_n1_ivw==1 & ind_p1_followup==1 & ip_only==1 & ip_start==1 & underage==1
mat tab2[`r'+2,4]=r(N)


	
mat rownames tab2=`ivars1' `ivars2' `cvars1' `ivars3' "Overall Sample Size (#)" "Sample Size at N1 (#)" "Sample Size at P1 (#)"


frmttable using "E:\projects\Dialysis\archive_logs\noop_characteristics.doc", replace statmat(tab2) ///
varlabels title("No Outpatient Dialysis: Sample Characteristics at N1 & P1 Core Interviews") ctitles("" ">65" "N" "<65" "N") sdec(1) ///
note()
       








