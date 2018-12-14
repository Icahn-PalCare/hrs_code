/*
This file creates summary tables for OOP Spending + Medicare Spending
in the last 5 years of life
Spending is adjusted for inflation to 2008 dollars as well as 
HRR medicare regional price adjustment, gender, age at death and race
*/

capture log close
clear all
set more off
use C:\data\oop\oop_resp_sp_restri_60m_mc.dta

log using "C:\code\logs\oop_60m_20131001.txt", text replace

describe
// 5368 records
keep if age_at_death>=70
// drops 1044 due to age<70
drop if total_oop_60m==.
// drops 158 due to incomplete total 60m oop
drop if tot_paid_by_mc_5yr==.
// drops 2399 due to incomplete total 60m mc
// sample is 1016 observations
sum age_at_death 

// Subject's HRR's Medicare EOL spending, including regional price adjustment
// Note this is the regional eol spending, not individual mc spending
sum tot_eol_spending, detail
gen tot_eol_spending_ad = tot_eol_spending*price_adjust_ratio
la var tot_eol_spending "HRR Medicare EOL spending"
la var tot_eol_spending_ad "HRR Medicare EOL spending, including regional price adjustment"
//1 missing HRR-zip match
sum tot_eol_spending, detail
sum tot_eol_spending_ad, detail

*************************************************************************
// Generate 60 month spending variables, adjusted for regional price index
*************************************************************************
//total out of pocket spending
gen total_oop_60m_ad = total_oop_60m*price_adjust_ratio
la var total_oop_60m_ad "Out of pocket spending 60m before death, including regional price adjustment"

//local of oop spending broken out by types
local ooptype doctor_oop_60m home_oop_60m patient_oop_60m dental_oop_60m hospice_oop_60m ///
	non_med_oop_60m helper_oop_60m rx_oop_60m nh_oop_60m hospital_oop_60m home_special_oop_60m ///
	homecare_oop_60m other_oop_60m

foreach v in `ooptype'{
gen `v'_ad=`v'*price_adjust_ratio
la var `v'_ad "Including regional price adjustment"
}	
	
//Total medicare spending
gen tot_paid_by_mc_5yr_ad = tot_paid_by_mc_5yr*price_adjust_ratio
la var tot_paid_by_mc_5yr_ad "Medicare spending 60m before death, including regional price adjustment"

//local of mc spending broken out by types
local mctype ip_paid_by_mc_5yr snf_paid_by_mc_5yr hh_paid_by_mc_5yr hs_paid_by_mc_5yr ///
	pb_paid_by_mc_5yr op_paid_by_mc_5yr dm_paid_by_mc_5yr

foreach v in `mctype'{
gen `v'_ad=`v'*price_adjust_ratio
la var `v'_ad "Including regional price adjustment"
}	

*************************************************************************
*************************************************************************

// Relationship between regional eol spending and oop spending?
reg total_oop_60m_ad tot_eol_spending_ad
glm total_oop_60m_ad tot_eol_spending_ad

sort tot_eol_spending_ad
*sample n=1016 with complete data, broken into quintiles as follows:

//calculate quintiles
centile tot_eol_spending_ad, centile(20(20)80)
sca qui_20=r(c_1)
sca qui_40=r(c_2)
sca qui_60=r(c_3)
sca qui_80=r(c_4)

gen quintile_eol=.
replace quintile_eol=1 if tot_eol_spending_ad<qui_20 & tot_eol_spending_ad<.
replace quintile_eol=2 if tot_eol_spending_ad>=qui_20 & tot_eol_spending_ad<=qui_40
replace quintile_eol=3 if tot_eol_spending_ad>qui_40 & tot_eol_spending_ad<qui_60
replace quintile_eol=4 if tot_eol_spending_ad>=qui_60 & tot_eol_spending_ad<qui_80
replace quintile_eol=5 if tot_eol_spending_ad>=qui_80 & tot_eol_spending_ad<.
tab quintile_eol, missing
la var quintile_eol "Quintiles of HRR-level EOL Medicare Spending (within this sample)"
la def quint 1 "Quintile 1 (Lowest)" 2 "2" 3 "3" 4 "4" 5 "5 (Highest)"
la val quintile_eol quint

sum tot_eol_spending_ad if quintile_eol==1, detail
sum tot_eol_spending_ad if quintile_eol==2, detail
sum tot_eol_spending_ad if quintile_eol==3, detail
sum tot_eol_spending_ad if quintile_eol==4, detail
sum tot_eol_spending_ad if quintile_eol==5, detail

// oop without price adjustment
sum total_oop_60m , detail
// with hospital referral region price adjustment
sum total_oop_60m_ad, detail
// mc without price adjustment
sum tot_paid_by_mc_5yr , detail
// mc with regional price adjustment
sum tot_paid_by_mc_5yr_ad, detail


//By quintile:
sort quintile_eol
// unadjusted oop spending
by quintile_eol: sum total_oop_60m, detail  
// regional price adjusted total oop spending
by quintile_eol: sum total_oop_60m_ad, detail  
// unadjusted mc spending
by quintile_eol: sum tot_paid_by_mc_5yr, detail  
// regional price adjusted total mc spending
by quintile_eol: sum tot_paid_by_mc_5yr_ad, detail  

//total medicare and out of pocket spending 5 years
gen mc_and_oop_60m=total_oop_60m+tot_paid_by_mc_5yr
gen mc_and_oop_60m_ad=mc_and_oop_60m*price_adjust_ratio
la var mc_and_oop_60m "Total out of pocket and medicare spending 60m before death"
la var mc_and_oop_60m_ad "Total oop and mc spending 60m before death, including regional price adjustement"
//ratio of oop spending to total oop+mc spending
gen r_oop_to_mc_oop_60m=total_oop_60m / mc_and_oop_60m
la var r_oop_to_mc_oop_60m "Ratio oop spending to total oop+mc spending 60m before death"


***********************************************************
//Create tables of unadjusted total oop and mc spending
***********************************************************

local chron ami_n24mn0 alzh_n24mn0 alzhdmta_n24mn0 atrialfb_n24mn0 ///
cataract_n24mn0 chrnkidn_n24mn0 copd_n24mn0 chf_n24mn0 diabetes_n24mn0 ///
glaucoma_n24mn0 hipfrac_n24mn0 ischmcht_n24mn0 depressn_n24mn0 ///
osteoprs_n24mn0 ra_oa_n24mn0 strketia_n24mn0 cncr_chronic_n24mn0

local adl adl_independent_core_n2  adl_partial_core_n2  adl_severe_core_n2

mat mean_unadj1 = J(6,5,.)
local j=1
foreach v in tot_paid_by_mc_5yr total_oop_60m mc_and_oop_60m {
	local i=1
	while `i' <=5 {
		qui sum(`v') if(quintile_eol==`i'), detail
		mat mean_unadj1[`j',`i'] = r(mean)
		mat mean_unadj1[(`j'+1),`i'] = r(p50)
		local i = `i' + 1
	}
	local j=`j'+2
}

mat list mean_unadj1

mat mean_unadj2 = J(1,5,.)
local i=1
while `i' <=5 {
		qui sum(r_oop_to_mc_oop_60m) if(quintile_eol==`i'), detail
		mat mean_unadj2[1,`i'] = r(mean)
		local i = `i' + 1
	}
	
mat list mean_unadj2

frmttable using "C:\projects\oop\report\sumstats2" , statmat(mean_unadj1) ///
	title("Quintiles of HRR-level EOL Medicare Spending (within this sample) (NOT adjusted for age, race, gender") ///
	ctitle("","Quintile 1 (lowest)", "2", "3", "4", "5 (highest)") ///
	rtitle("MC - mean, $" \ "     median, $" \ "OOP - mean, $" \ "     median, $" \ "MC+OOP - mean, $" \ "     median, $") ///
	sdec(0) replace
	
frmttable using "C:\projects\oop\report\sumstats2" , statmat(mean_unadj2) ///
	rtitle("OOP/MC+OOP - overall") ///
	sdec(3) append

mat mean_unadj3 = J(17,5,.)
local j=1
foreach v in `chron' {
	local i=1
	while `i' <=5 {
		qui sum(r_oop_to_mc_oop_60m) if(quintile_eol==`i' & `v'==1), detail
			mat mean_unadj3[`j',`i'] = r(mean)
			local i = `i' + 1
		}
		local j=`j'+1
	}
mat list mean_unadj3


frmttable using "C:\projects\oop\report\sumstats2" , statmat(mean_unadj3) ///
	rtitle("Acute Myocardial Infarction" \ "Alzheimer's" \ "Alzheimer's or Dementia" \ "Atrial Fibrillation" \ ///
	 "Cataract" \ "Chronic Kidney Disease" \ "COPD" \ "CHF" \ "Diabetes" \ "Glaucoma" \ ///
	 "Hip Fracture" \ "Ischemic Heart Disease" \ "Depression" \ "Osteoporosis" \ ///
	 "Rheumatoid Arthritis" \ "Stroke"  \ "Cancer" ) ///
	sdec(3) append

mat mean_unadj4 = J(3,5,.)
local j=1
foreach v in `adl' {
	local i=1
	while `i' <=5 {
		qui sum(r_oop_to_mc_oop_60m) if(quintile_eol==`i' & `v'==1), detail
			mat mean_unadj4[`j',`i'] = r(mean)
			local i = `i' + 1
		}
		local j=`j'+1
	}
mat list mean_unadj4
	
frmttable using "C:\projects\oop\report\sumstats2" , statmat(mean_unadj4) ///
	append sdec(3) ///
	rtitle("Independent" \ "Partial" \ "Severe")

***********************************************************
//Adjust total oop and mc spending by age, sex and race
***********************************************************

//adjust total oop spending
egen mean_oop_60m=mean(total_oop_60m_ad)
areg total_oop_60m_ad age_at_death female white, absorb(hrrnum)
predict resid_oop, d
//3 missing values generated, sample is 1014 adjusted
//1 missing age at death
//1 missing race
//1 missing HRR number
gen adj_oop_60m= mean_oop_60m +resid_oop
la var adj_oop_60m "OOP spending 60m, adjusted for HRR, age, sex and race"
sum adj_oop_60m
sum total_oop_60m_ad

reg adj_oop_60m tot_eol_spending_ad
glm adj_oop_60m tot_eol_spending_ad

//adjust total mc spending
egen mean_mc_60m=mean(tot_paid_by_mc_5yr_ad)
areg tot_paid_by_mc_5yr_ad age_at_death female white, absorb(hrrnum)
predict resid_mc, d
gen adj_mc_60m= mean_mc_60m +resid_mc
la var adj_mc_60m "MC spending 60m, adjusted for HRR, age, sex and race"
sum adj_mc_60m
sum tot_paid_by_mc_5yr_ad

reg adj_mc_60m tot_eol_spending_ad
glm adj_mc_60m tot_eol_spending_ad

//create total adjusted oop + mc spending
gen adj_mc_and_oop_60m=adj_oop_60m+adj_mc_60m
la var adj_mc_and_oop_60m "MC+OOP spending 60m, adjusted for HRR, age, sex and race"
//create ratio adjusted oop to total mc+oop spending
gen adj_r_oop_to_mc_oop_60m=adj_oop_60m / adj_mc_and_oop_60m
la var adj_r_oop_to_mc_oop_60m "Ratio oop to oop+mc, 60m before death, adjusted for HRR, age, sex and race"

sum adj_oop_60m, detail
sum adj_mc_60m, detail
sum adj_mc_and_oop_60m, detail
sum adj_r_oop_to_mc_oop_60m, detail

* Region, age, sex, race adjusted total oop and mc spending
sort quintile_eol
by quintile_eol: sum adj_oop_60m, detail
by quintile_eol: sum adj_mc_60m, detail

***********************************************************
//Adjust oop and mc spending subtotals by type of spednding
//by age, sex and race
***********************************************************

//local of oop and mc spending adjusted for regional spending broken out by types
local spend_ad doctor_oop_60m_ad home_oop_60m_ad patient_oop_60m_ad dental_oop_60m_ad ///
	hospice_oop_60m_ad non_med_oop_60m_ad helper_oop_60m_ad rx_oop_60m_ad nh_oop_60m_ad ///
	hospital_oop_60m_ad home_special_oop_60m_ad homecare_oop_60m other_oop_60m_ad ///
	ip_paid_by_mc_5yr_ad snf_paid_by_mc_5yr_ad hh_paid_by_mc_5yr_ad ///
	hs_paid_by_mc_5yr_ad pb_paid_by_mc_5yr_ad op_paid_by_mc_5yr_ad dm_paid_by_mc_5yr_ad

foreach v in `spend_ad'{
	egen mean_`v'=mean(`v')
	qui areg `v' age_at_death female white, absorb(hrrnum)
	predict resid_`v', d
	gen adj_`v'=mean_`v' + resid_`v'
	la var adj_`v' "Spending 60m, adjusted for HRR, age, sex and race"
	sum adj_`v'
}

***********************************************************
//Create tables of total oop and mc spending adjusted by age, sex and race
//by eol hrr quintile
***********************************************************

mat mean_med1 = J(6,5,.)
local j=1
foreach v in adj_mc_60m adj_oop_60m adj_mc_and_oop_60m {
	local i=1
	while `i' <=5 {
		qui sum(`v') if(quintile_eol==`i'), detail
		mat mean_med1[`j',`i'] = r(mean)
		mat mean_med1[(`j'+1),`i'] = r(p50)
		local i = `i' + 1
	}
	local j=`j'+2
}

mat list mean_med1

mat mean_med2 = J(1,5,.)
local i=1
while `i' <=5 {
		qui sum(adj_r_oop_to_mc_oop_60m) if(quintile_eol==`i'), detail
		mat mean_med2[1,`i'] = r(mean)
		local i = `i' + 1
	}
	
mat list mean_med2

frmttable using "C:\projects\oop\report\sumstats" , statmat(mean_med1) ///
	title("Quintiles of HRR-level EOL Medicare Spending (within this sample) adjusted for regional pricing, age, sex and race.") ///
	ctitle("","Quintile 1 (lowest)", "2", "3", "4", "5 (highest)") ///
	rtitle("MC - mean, $" \ "     median, $" \ "OOP - mean, $" \ "     median, $" \ "MC+OOP - mean, $" \ "     median, $") ///
	sdec(0) replace
	
frmttable using "C:\projects\oop\report\sumstats" , statmat(mean_med2) ///
	rtitle("OOP/MC+OOP - overall") ///
	sdec(3) append

mat mean_med3 = J(17,5,.)
local j=1
foreach v in `chron' {
	local i=1
	while `i' <=5 {
		qui sum(adj_r_oop_to_mc_oop_60m) if(quintile_eol==`i' & `v'==1), detail
			mat mean_med3[`j',`i'] = r(mean)
			local i = `i' + 1
		}
		local j=`j'+1
	}
mat list mean_med3


frmttable using "C:\projects\oop\report\sumstats" , statmat(mean_med3) ///
	rtitle("Acute Myocardial Infarction" \ "Alzheimer's" \ "Alzheimer's or Dementia" \ "Atrial Fibrillation" \ ///
	 "Cataract" \ "Chronic Kidney Disease" \ "COPD" \ "CHF" \ "Diabetes" \ "Glaucoma" \ ///
	 "Hip Fracture" \ "Ischemic Heart Disease" \ "Depression" \ "Osteoporosis" \ ///
	 "Rheumatoid Arthritis" \ "Stroke"  \ "Cancer" ) ///
	sdec(3) append

mat mean_med4 = J(3,5,.)
local j=1
foreach v in `adl' {
	local i=1
	while `i' <=5 {
		qui sum(adj_r_oop_to_mc_oop_60m) if(quintile_eol==`i' & `v'==1), detail
			mat mean_med4[`j',`i'] = r(mean)
			local i = `i' + 1
		}
		local j=`j'+1
	}
mat list mean_med4
	
frmttable using "C:\projects\oop\report\sumstats" , statmat(mean_med4) ///
	append sdec(3) ///
	rtitle("Independent" \ "Partial" \ "Severe")

***********************************************************
//Create tables of oop and mc spending by type
// adjusted by age, sex and race by eol hrr quintile
***********************************************************
//local of oop and mc spending by types

local adj_spend adj_oop_60m adj_doctor_oop_60m_ad adj_home_oop_60m_ad adj_patient_oop_60m_ad adj_dental_oop_60m_ad ///
	adj_hospice_oop_60m_ad adj_non_med_oop_60m_ad adj_helper_oop_60m_ad adj_rx_oop_60m_ad adj_nh_oop_60m_ad ///
	adj_hospital_oop_60m_ad adj_home_special_oop_60m_ad adj_homecare_oop_60m adj_other_oop_60m_ad ///
	adj_mc_60m adj_ip_paid_by_mc_5yr_ad adj_snf_paid_by_mc_5yr_ad adj_hh_paid_by_mc_5yr_ad ///
	adj_hs_paid_by_mc_5yr_ad adj_pb_paid_by_mc_5yr_ad adj_op_paid_by_mc_5yr_ad adj_dm_paid_by_mc_5yr_ad	

mat mean_med5 = J(44,5,.)
local j=1
foreach v in `adj_spend' {
	local i=1
	while `i' <=5 {
		qui sum(`v') if(quintile_eol==`i'), detail
		mat mean_med5[`j',`i'] = r(mean)
		mat mean_med5[(`j'+1),`i'] = r(p50)
		local i = `i' + 1
	}
	local j=`j'+2
}



mat rownames mean_med5= "Total OOP - Mean" "Median" "Doctor OOP - Mean" "Median" "Home OOP - Mean" "Median" "Patient OOP - Mean" "Median" ///
	"Dental OOP - Mean" "Median" "Hospice OOP - Mean" "Median" "NonMed OOP - Mean" "Median" "Helper OOP - Mean" "Median" ///
	"Rx OOP - Mean" "Median" "NH OOP - Mean" "Median" "Hospital OOP - Mean" "Median" "Home Special OOP - Mean" "Median" ///
	"Home Care OOP - Mean" "Median" "Other OOP - Mean" "Median" "Total Medicare - mean" "Median" "IP Medicare - Mean" "Median" ///
	"SNF Medicare - Mean" "Median" "HH Medicare - Mean" "Median" "Hospice Medicare - Mean" "Median" "Carrier Medicare - Mean" "Median" ///
	"OP Medicare - Mean" "Median" "DME Medicare - Mean" "Median"
mat colnames mean_med5=	"Quintile 1(lowest)" "Q2" "Q3" "Q4" "Q5 (Highest)"
mat list mean_med5	

frmttable using "C:\projects\oop\report\sumstats_byspendtype" , statmat(mean_med5) ///
	sdec(0) varlabels replace ///
	title("Quintiles of HRR-level EOL Medicare Spending (within this sample) adjusted for regional pricing, age, sex and race.")
	
***********************************************************
//Create tables of oop and mc spending by type
// adjusted by age, sex and race by eol hrr quintile
// version without the outlier with the oop/(oop+mc) ratio=75
***********************************************************
preserve

//identify outlier and drop it from the sample
//it removes that one observation from the 1st (lowest) quintile in the following table
sum adj_r_oop_to_mc_oop_60m if( adj_r_oop_to_mc_oop_60m>70 & adj_r_oop_to_mc_oop_60m~=.)
tab quintile_eol if( adj_r_oop_to_mc_oop_60m>70 & adj_r_oop_to_mc_oop_60m~=.)
drop if( adj_r_oop_to_mc_oop_60m>70 & adj_r_oop_to_mc_oop_60m~=.)	

mat mean_med6 = J(44,5,.)
local j=1
foreach v in `adj_spend' {
	local i=1
	while `i' <=5 {
		qui sum(`v') if(quintile_eol==`i'), detail
		mat mean_med6[`j',`i'] = r(mean)
		mat mean_med6[(`j'+1),`i'] = r(p50)
		local i = `i' + 1
	}
	local j=`j'+2
}

mat rownames mean_med6= "Total OOP - Mean" "Median" "Doctor OOP - Mean" "Median" "Home OOP - Mean" "Median" "Patient OOP - Mean" "Median" ///
	"Dental OOP - Mean" "Median" "Hospice OOP - Mean" "Median" "NonMed OOP - Mean" "Median" "Helper OOP - Mean" "Median" ///
	"Rx OOP - Mean" "Median" "NH OOP - Mean" "Median" "Hospital OOP - Mean" "Median" "Home Special OOP - Mean" "Median" ///
	"Home Care OOP - Mean" "Median" "Other OOP - Mean" "Median" "Total Medicare - mean" "Median" "IP Medicare - Mean" "Median" ///
	"SNF Medicare - Mean" "Median" "HH Medicare - Mean" "Median" "Hospice Medicare - Mean" "Median" "Carrier Medicare - Mean" "Median" ///
	"OP Medicare - Mean" "Median" "DME Medicare - Mean" "Median"
mat colnames mean_med6=	"Quintile 1(lowest)" "Q2" "Q3" "Q4" "Q5 (Highest)"

mat list mean_med6	

frmttable using "C:\projects\oop\report\sumstats_byspendtype_nooutlier" , statmat(mean_med6) ///
	sdec(0) varlabels replace ///
	title("Quintiles of HRR-level EOL Medicare Spending (within this sample)" \ ///
	"adjusted for regional pricing, age, sex and race." \ ///
	"OUTLIER OBSERVATION OOP/(MC+OOP)>70 REMOVED") ///
	
//restore dataset to include outlier observation	
restore	


***********************************************************
//Create tables of oop and mc spending by type

***********************************************************
//local of unadjusted oop and mc spending by types

local spend total_oop_60m doctor_oop_60m home_oop_60m patient_oop_60m dental_oop_60m hospice_oop_60m ///
	non_med_oop_60m helper_oop_60m rx_oop_60m nh_oop_60m hospital_oop_60m home_special_oop_60m ///
	homecare_oop_60m other_oop_60m ///
	tot_paid_by_mc_5yr ip_paid_by_mc_5yr snf_paid_by_mc_5yr hh_paid_by_mc_5yr hs_paid_by_mc_5yr ///
	pb_paid_by_mc_5yr op_paid_by_mc_5yr dm_paid_by_mc_5yr

mat mean_unadj5 = J(44,5,.)
local j=1
foreach v in `spend' {
	local i=1
	while `i' <=5 {
		qui sum(`v') if(quintile_eol==`i'), detail
		mat mean_unadj5[`j',`i'] = r(mean)
		mat mean_unadj5[(`j'+1),`i'] = r(p50)
		local i = `i' + 1
	}
	local j=`j'+2
}



mat rownames mean_unadj5= "Total OOP - Mean" "Median" "Doctor OOP - Mean" "Median" "Home OOP - Mean" "Median" "Patient OOP - Mean" "Median" ///
	"Dental OOP - Mean" "Median" "Hospice OOP - Mean" "Median" "NonMed OOP - Mean" "Median" "Helper OOP - Mean" "Median" ///
	"Rx OOP - Mean" "Median" "NH OOP - Mean" "Median" "Hospital OOP - Mean" "Median" "Home Special OOP - Mean" "Median" ///
	"Home Care OOP - Mean" "Median" "Other OOP - Mean" "Median" "Total Medicare - mean" "Median" "IP Medicare - Mean" "Median" ///
	"SNF Medicare - Mean" "Median" "HH Medicare - Mean" "Median" "Hospice Medicare - Mean" "Median" "Carrier Medicare - Mean" "Median" ///
	"OP Medicare - Mean" "Median" "DME Medicare - Mean" "Median"
mat colnames mean_unadj5=	"Quintile 1(lowest)" "Q2" "Q3" "Q4" "Q5 (Highest)"
mat list mean_unadj5	

frmttable using "C:\projects\oop\report\sumstats_byspendtype_unadj" , statmat(mean_unadj5) ///
	sdec(0) varlabels replace ///
	title("Quintiles of HRR-level EOL Medicare Spending (within this sample) - Unadjusted.")
	
***********************************************************
//Create tables of oop and mc spending by type
// version without the outlier with the oop/(oop+mc) ratio=75
***********************************************************
preserve

//identify outlier and drop it from the sample
//it removes that one observation from the 1st (lowest) quintile in the following table
sum adj_r_oop_to_mc_oop_60m if( adj_r_oop_to_mc_oop_60m>70 & adj_r_oop_to_mc_oop_60m~=.)
tab quintile_eol if( adj_r_oop_to_mc_oop_60m>70 & adj_r_oop_to_mc_oop_60m~=.)
drop if( adj_r_oop_to_mc_oop_60m>70 & adj_r_oop_to_mc_oop_60m~=.)	

mat mean_unadj6 = J(44,5,.)
local j=1
foreach v in `spend' {
	local i=1
	while `i' <=5 {
		qui sum(`v') if(quintile_eol==`i'), detail
		mat mean_unadj6[`j',`i'] = r(mean)
		mat mean_unadj6[(`j'+1),`i'] = r(p50)
		local i = `i' + 1
	}
	local j=`j'+2
}

mat rownames mean_unadj6 = "Total OOP - Mean" "Median" "Doctor OOP - Mean" "Median" "Home OOP - Mean" "Median" "Patient OOP - Mean" "Median" ///
	"Dental OOP - Mean" "Median" "Hospice OOP - Mean" "Median" "NonMed OOP - Mean" "Median" "Helper OOP - Mean" "Median" ///
	"Rx OOP - Mean" "Median" "NH OOP - Mean" "Median" "Hospital OOP - Mean" "Median" "Home Special OOP - Mean" "Median" ///
	"Home Care OOP - Mean" "Median" "Other OOP - Mean" "Median" "Total Medicare - mean" "Median" "IP Medicare - Mean" "Median" ///
	"SNF Medicare - Mean" "Median" "HH Medicare - Mean" "Median" "Hospice Medicare - Mean" "Median" "Carrier Medicare - Mean" "Median" ///
	"OP Medicare - Mean" "Median" "DME Medicare - Mean" "Median"
mat colnames mean_unadj6 =	"Quintile 1(lowest)" "Q2" "Q3" "Q4" "Q5 (Highest)"

mat list mean_unadj6 	

frmttable using "C:\projects\oop\report\sumstats_byspendtype_unadj_nooutlier" , statmat(mean_unadj6) ///
	sdec(0) varlabels replace ///
	title("Quintiles of HRR-level EOL Medicare Spending (within this sample)" \ ///
	"Unadjusted." \ ///
	"OUTLIER OBSERVATION OOP/(MC+OOP)>70 REMOVED") ///
	
//restore dataset to include outlier observation	
restore	


***********************************************************
//Create table of oop and mc spending adjusted by age, sex and race
//By cause of death
***********************************************************
/*
//create binary cause death variables
tab cause_death_12, missing generate(causedeath)
rename causedeath1 cause_death_missing
la var cause_death_missing "Cause of death - missing"
rename causedeath2 cause_death_accident
la var cause_death_accident "Cause of death - Accidents, Suicide, Homicide"
rename causedeath3 cause_death_alz
la var cause_death_alz "Cause of death - Alzheimer's Disease"
rename causedeath4 cause_death_cardio
la var cause_death_cardio "Cause of death - Cardiovascular Disease"
rename causedeath5 cause_death_chronresp
la var cause_death_chronresp "Cause of death - Chronic Lower Respiratory Disease"
rename causedeath6 cause_death_diab
la var cause_death_diab "Cause of death - Diabetes"
rename causedeath7 cause_death_infec
la var cause_death_infec "Cause of death - Infectious Disease (not HIV/AIDS/viral)"
rename causedeath8 cause_death_kidney
la var cause_death_kidney "Cause of death - Kidney Disease (not infectious)"
rename causedeath9 cause_death_liver
la var cause_death_liver "Cause of death - Liver, Gallbladder, Stomach and/or Intestinal Disease"
rename causedeath10 cause_death_neoplasms
la var cause_death_neoplasms "Cause of death - Neoplasms"
rename causedeath11 cause_death_other
la var cause_death_other "Cause of death - Other or Missing"
replace cause_death_other=1 if cause_death_missing==1
rename causedeath12 cause_death_otherresp
la var cause_death_otherresp "Cause of death - Other Respiratory Disease"

local causedeath cause_death_accident cause_death_alz cause_death_cardio cause_death_chronresp ///
	cause_death_diab cause_death_infec cause_death_kidney cause_death_liver cause_death_neoplasms ///
	cause_death_otherresp cause_death_other 

local spend adj_mc_60m adj_oop_60m adj_mc_and_oop_60m adj_r_oop_to_mc_oop_60m

mat mean_bycd	 = J(11,9,.)
local j = 1	
foreach v in `causedeath' {
	local i=1
	foreach w in `spend' {
		qui sum( `w') if(`v'==1), detail
		mat mean_bycd[`j',`i'] = r(mean)
		mat mean_bycd[(`j'),`i'+1] = r(p50)
		mat mean_bycd[(`j'),`i'+2] = r(p90)
		local i=`i'+3
	}
local j=`j'+1
}

mat list mean_bycd

frmttable using "C:\projects\oop\report\sumstats_by_cause_death2" , statmat(mean_bycd) ///
	replace sdec(0) ///
	title("Spending in Last Five Years of Life by Cause of Death") ///
	ctitles("Cause of Death" , "Total Medicare Spending" , "", "", "Total Out of Pocket Spending" , ///
	"", "" , "Total Medicare + OOP Spending" ,"", "",\ "" , "Mean" , "Median", "90%" , "Mean" , "Median", "90%" , ///
	 "Mean" , "Median", "90%" ) ///
	multicol(1,2,3;1,5,3;1,8,3) ///
	rtitle("Accidents, Suicide, Homicide" \ "Alzheimer's Disease" \ "Cardiovascular Disease" \ ///
		"Chronic Lower Respiratory Disease" \ "Diabetes" \ "Infectious Disease (not HIV/AIDS/viral)" \ ///
		"Kidney Disease (not infectious)" \ "Liver, Gallbladder, Stomach and/or Intestinal Disease" \ ///
		"Neoplasms" \ "Other Respiratory Disease" \ "Other or Missing")

		
/*Plots of the sample
cd "C:\projects\oop\report\"

twoway (scatter  adj_r_oop_to_mc_oop_60m tot_eol_spending_ad if(quintile_eol==1), msymbol(Oh)) ///
	(scatter  r_oop_to_mc_oop_60m tot_eol_spending_ad if(quintile_eol==1), msymbol(Dh)), ///
	ytitle("OOP / (OOP+MC)") legend(label(1 "Adjusted") label(2 "Not-Adjusted")) title("Ratio for 1st Quintile")
graph export ratio_oop_mc_1Q.tif, as(tif) replace 

twoway (scatter  adj_mc_60m tot_eol_spending_ad if(quintile_eol==1), msymbol(Oh)) ///
	(scatter  tot_paid_by_mc_5yr tot_eol_spending_ad if(quintile_eol==1), msymbol(Dh)), ///
	ytitle("MC Spending") legend(label(1 "Adjusted") label(2 "Not-Adjusted")) title("Medicare Spending for 1st Quintile") 
graph export mc_1Q.tif, as(tif) replace 

twoway (scatter  adj_oop_60m tot_eol_spending_ad if(quintile_eol==1), msymbol(Oh)) ///
	(scatter  total_oop_60m tot_eol_spending_ad if(quintile_eol==1), msymbol(Dh)), ///
	ytitle("OOP Spending") legend(label(1 "Adjusted") label(2 "Not-Adjusted")) title("OOP Spending for 1st Quintile")
graph export oop_1Q.tif, as(tif) replace 

twoway (scatter  adj_mc_and_oop_60m tot_eol_spending_ad if(quintile_eol==1), msymbol(Oh)) ///
	(scatter  mc_and_oop_60m tot_eol_spending_ad if(quintile_eol==1), msymbol(Dh)), ///
	ytitle("MC+OOP Spending") legend(label(1 "Adjusted") label(2 "Not-Adjusted")) title("Medicare+OOP for 1st Quintile")
graph export mc_and_oop_1Q.tif, as(tif) replace 


twoway (scatter adj_r_oop_to_mc_oop_60m tot_eol_spending_ad if(adj_r_oop_to_mc_oop_60m>=.75), msymbol(Oh)) ///
	(scatter r_oop_to_mc_oop_60m tot_eol_spending_ad if(adj_r_oop_to_mc_oop_60m>=.75), msymbol(Dh)), ///
	ytitle("OOP / (OOP+MC)") legend(label(1 "Adjusted") label(2 "Not-Adjusted")) title("Ratio for Ratio>.75")
graph export ratio_oop_mc_r_gt_75.tif, as(tif) replace 
	
twoway (scatter adj_mc_60m tot_eol_spending_ad if(adj_r_oop_to_mc_oop_60m>.75), msymbol(Oh)) ///
	(scatter  tot_paid_by_mc_5yr tot_eol_spending_ad if(adj_r_oop_to_mc_oop_60m>.75), msymbol(Dh)), ///
	ytitle("MC Spending") legend(label(1 "Adjusted") label(2 "Not-Adjusted")) title("Medicare Spending for Ratio>.75")
graph export mc_r_gt_75.tif, as(tif) replace 

twoway (scatter adj_oop_60m tot_eol_spending_ad if(adj_r_oop_to_mc_oop_60m>.75), msymbol(Oh)) ///
	(scatter  total_oop_60m tot_eol_spending_ad if(adj_r_oop_to_mc_oop_60m>.75), msymbol(Dh)), ///
	ytitle("OOP Spending") legend(label(1 "Adjusted") label(2 "Not-Adjusted")) title("OOP Spending for Ratio>.75")
graph export oop_r_gt_75.tif, as(tif) replace 

	
twoway (scatter adj_mc_and_oop_60m tot_eol_spending_ad if(adj_r_oop_to_mc_oop_60m>.75), msymbol(Oh)) ///
	(scatter  mc_and_oop_60m tot_eol_spending_ad if(adj_r_oop_to_mc_oop_60m>.75), msymbol(Dh)),	///
	ytitle("MC+OOP Spending") legend(label(1 "Adjusted") label(2 "Not-Adjusted")) title("MC+OOP Spending for Ratio>.75")
graph export mc_and_oop_r_gt_75.tif, as(tif) replace 
*/


***********************************************************
//Create tables of oop and mc spending adjusted by age, sex and race
//EXCLUDING THE OUTLIER RATIO>70
***********************************************************
sum adj_mc_and_oop_60m adj_oop_60m adj_mc_60m adj_r_oop_to_mc_oop_60m if( adj_r_oop_to_mc_oop_60m>.75)
sum adj_mc_and_oop_60m adj_oop_60m adj_mc_60m adj_r_oop_to_mc_oop_60m if( adj_r_oop_to_mc_oop_60m>70)
sum mc_and_oop_60m total_oop_60m tot_paid_by_mc_5yr r_oop_to_mc_oop_60m ///
	if( adj_r_oop_to_mc_oop_60m>70 & adj_r_oop_to_mc_oop_60m~=.)
sum resid_oop resid_mc if hrrnum==437

local outliercheck adj_mc_60m adj_oop_60m adj_mc_and_oop_60m adj_r_oop_to_mc_oop_60m mc_and_oop_60m ///
	total_oop_60m tot_paid_by_mc_5yr r_oop_to_mc_oop_60m white age_at_death female ///
	hrrnum resid_oop resid_mc price_adjust_ratio champus_n1 champus_n2 hmo_n1 hmo_n2 ///
	`chron' *_paid_by_mc_5yr
	

sum `outliercheck' if( adj_r_oop_to_mc_oop_60m>70 & adj_r_oop_to_mc_oop_60m~=.)
//outlier ratio=74
//white=1, age_at_death=76, female=0, hrrnum=437
/*drop if adj_r_oop_to_mc_oop_60m>70

mat mean_med70 = J(6,5,.)
local j=1
foreach v in adj_mc_60m adj_oop_60m adj_mc_and_oop_60m {
	local i=1
	while `i' <=5 {
		qui sum(`v') if(quintile_eol==`i'), detail
		mat mean_med70[`j',`i'] = r(mean)
		mat mean_med70[(`j'+1),`i'] = r(p50)
		local i = `i' + 1
	}
	local j=`j'+2
}

mat list mean_med70

mat mean_med2 = J(1,5,.)
local i=1
while `i' <=5 {
		qui sum(adj_r_oop_to_mc_oop_60m) if(quintile_eol==`i'), detail
		mat mean_med2[1,`i'] = r(mean)
		local i = `i' + 1
	}
	
mat list mean_med2

frmttable using "C:\projects\oop\report\sumstats3" , statmat(mean_med70) ///
	title("OUTLIER DROPPED: Quintiles of HRR-level EOL Medicare Spending (within this sample) adjusted for regional pricing, age, sex and race.") ///
	ctitle("","Quintile 1 (lowest)", "2", "3", "4", "5 (highest)") ///
	rtitle("MC - mean, $" \ "     median, $" \ "OOP - mean, $" \ "     median, $" \ "MC+OOP - mean, $" \ "     median, $") ///
	sdec(0) replace
	
frmttable using "C:\projects\oop\report\sumstats3" , statmat(mean_med2) ///
	rtitle("OOP/MC+OOP - overall") ///
	sdec(3) append

mat mean_med3 = J(17,5,.)
local j=1
foreach v in `chron' {
	local i=1
	while `i' <=5 {
		qui sum(adj_r_oop_to_mc_oop_60m) if(quintile_eol==`i' & `v'==1), detail
			mat mean_med3[`j',`i'] = r(mean)
			local i = `i' + 1
		}
		local j=`j'+1
	}
mat list mean_med3


frmttable using "C:\projects\oop\report\sumstats3" , statmat(mean_med3) ///
	rtitle("Acute Myocardial Infarction" \ "Alzheimer's" \ "Alzheimer's or Dementia" \ "Atrial Fibrillation" \ ///
	 "Cataract" \ "Chronic Kidney Disease" \ "COPD" \ "CHF" \ "Diabetes" \ "Glaucoma" \ ///
	 "Hip Fracture" \ "Ischemic Heart Disease" \ "Depression" \ "Osteoporosis" \ ///
	 "Rheumatoid Arthritis" \ "Stroke"  \ "Cancer" ) ///
	sdec(3) append

mat mean_med4 = J(3,5,.)
local j=1
foreach v in `adl' {
	local i=1
	while `i' <=5 {
		qui sum(adj_r_oop_to_mc_oop_60m) if(quintile_eol==`i' & `v'==1), detail
			mat mean_med4[`j',`i'] = r(mean)
			local i = `i' + 1
		}
		local j=`j'+1
	}
mat list mean_med4
	
frmttable using "C:\projects\oop\report\sumstats3" , statmat(mean_med4) ///
	append sdec(3) ///
	rtitle("Independent" \ "Partial" \ "Severe")
*/
	
/*
** Insurance
drop resid
egen mean_oop_insur=mean(insurance_costs_24m_ad)
areg insurance_costs_24m_ad age_at_death female white, absorb(hrrnum)
predict resid, d
gen adj_oop_insur= mean_oop_insur +resid
sum adj_oop_insur

* Region, age, sex, race adjusted total insurance spending
sort quintile_eol
by quintile_eol: sum adj_oop_insur, detail

** Hospital
drop resid
egen mean_oop_hosp=mean(hospital_oop_24m_ad)
areg hospital_oop_24m_ad age_at_death female white, absorb(hrrnum)
predict resid, d
gen adj_oop_hosp= mean_oop_hosp +resid
sum adj_oop_hosp

reg adj_oop_hosp tot_eol_spending_ad
glm adj_oop_hosp tot_eol_spending_ad

* Region, age, sex, race adjusted total hospital spending
sort quintile_eol
by quintile_eol: sum adj_oop_hosp, detail


** Home Care
drop resid
egen mean_oop_home=mean(homecare_oop_24m_ad)
areg homecare_oop_24m_ad age_at_death female white, absorb(hrrnum)
predict resid, d
gen adj_oop_home= mean_oop_home +resid
sum adj_oop_home

reg adj_oop_home tot_eol_spending_ad
glm adj_oop_home tot_eol_spending_ad

* Region, age, sex, race adjusted home care spending
sort quintile_eol
by quintile_eol: sum adj_oop_home, detail

** Nursing Home
drop resid
egen mean_oop_nh=mean( nh_oop_24m_ad)
areg  nh_oop_24m_ad age_at_death female white, absorb(hrrnum)
predict resid, d
gen adj_oop_nh= mean_oop_nh +resid
sum adj_oop_nh

reg adj_oop_nh tot_eol_spending_ad
glm adj_oop_nh tot_eol_spending_ad

* Region, age, sex, race adjusted nursing home spending
sort quintile_eol
by quintile_eol: sum adj_oop_nh, detail

** Drugs
drop resid
egen mean_oop_rx=mean( rx_oop_24m_ad)
areg  rx_oop_24m_ad age_at_death female white, absorb(hrrnum)
predict resid, d
gen adj_oop_rx= mean_oop_rx +resid
sum adj_oop_rx

* Region, age, sex, race adjusted drug spending
sort quintile_eol
by quintile_eol: sum adj_oop_rx, detail

** Hospice (part of 'Other')
drop resid
egen mean_oop_hospice=mean( hospice_oop_24m_ad)
areg  hospice_oop_24m_ad age_at_death female white, absorb(hrrnum)
predict resid, d
gen adj_oop_hospice= mean_oop_hospice +resid
sum adj_oop_hospice

reg adj_oop_hospice tot_eol_spending_ad
glm adj_oop_hospice tot_eol_spending_ad

* Region, age, sex, race adjusted hospice spending
sort quintile_eol
by quintile_eol: sum adj_oop_hospice, detail

log close 
*/

/*
* wage_index_2008

total_OOP_24m_ad

NH
Hospital
Home Care:
Drugs
Insurance
Other:

rx_OOP_24m_ad
insurance_costs_24m_ad
nh_oop_24m_ad
hospital_oop_24m_ad
homecare_oop_24m_ad
other_oop_24m_ad
*hospice_OOP_24m_ad
*/ 
log close 
