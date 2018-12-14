
capture log close

clear all
set mem 500m
set more off

local logpath E:\data\serious_ill\logs
local datapath E:\data\serious_ill\int_data

log using "`logpath'\4-sic_initial_outcomes_1_ak.txt", text replace

cd `datapath'

//use dataset with outcomes, just obs that meet interview sample inclusion criteria
use ivws_crit_1.dta if inlist(core_year,2000,2002,2004,2006,2008) & /// 
age_ge_65==1 & xwalk_yes==1 & part_ab_12m==1 & hmo_d_12m==0
*******************************************************************
//Table comparing outcomes for those with serious illness only, 
//adl impairment only, illness and adl impairment categories

//for n=47 observations where wage index is missing, it has been set to 1
//for the purposes of adjusting the medicare spending totals
sum core_year
sum core_year if wage_index_20102==.
tab wage_index_missing_yes, missing

//categorical variable for serious illness vs adl impairment
gen cat_smi_adl=.
replace cat_smi_adl=1 if ser_med_illness==0 & adl_impair_core==0
replace cat_smi_adl=2 if ser_med_illness==1 & adl_impair_core==0
replace cat_smi_adl=3 if ser_med_illness==0 & adl_impair_core==1
replace cat_smi_adl=4 if smi_and_adl==1
la var cat_smi_adl "Serious illness and/or adl impariment, categorical"
la def cat_smi_adl 1 "No serious illness or adl impairment" ///
2 "Serious medical illness but no adl impair" 3 "ADL impairment, no serious medical ill" ///
4 "Serious medical illness and adl impairment"
la val cat_smi_adl cat_smi_adl
tab cat_smi_adl core_year
tab cat_smi_adl ser_med_illness
tab cat_smi_adl adl_impair_core

*******************************************************************
//Outcomes for first interview where meet criteria
*******************************************************************
mat table2=J(34,3,.)
//first row, n for each category
tab ivw_meet_crit_a ,matcell(row1a)
mat table2[1,1]=row1a[2,1]
tab ivw_meet_crit_b ,matcell(row1b)
mat table2[1,2]=row1b[2,1]
tab ivw_meet_crit_c ,matcell(row1c)
mat table2[1,3]=row1c[2,1]

local c=1
foreach crit of varlist ivw_meet_crit_a ivw_meet_crit_b ivw_meet_crit_c {
local r=2
foreach v in `outcome1'{
	sum `v' if `crit'==1, detail
	mat table2[`r',`c']=r(mean)
	mat table2[`r'+1,`c']=r(sd)
	local r=`r'+2 //populates rows 2-7 for indicator variable outcomes
	}

local r=8
foreach v in `outcome2'{
	sum `v' if `crit'==1, detail
	mat table2[`r',`c']=r(mean)
	mat table2[`r'+1,`c']=r(p50)
	mat table2[`r'+2,`c']=r(sd)
	local r=`r'+3 //populates rows 8-34 for continuous variables
	}
local c=`c'+1	
}

mat rownames table2="N" "Died, mean" "SD" "Hospice enr, mean" "SD" "Emerg or urgent hosp admit, mean" "SD" ///
"IP Medicare payments, mean" "Median" "SD" "SNF Medicare payments, mean" "Median" "SD" ///
"HH Medicare payments, mean" "Median" "SD" "Hospice Medicare payments, mean" "Median" "SD" ///
"Carrier Medicare payments, mean" "Median" "SD" "OP Medicare payments, mean" "Median" "SD" ///
"DME Medicare payments, mean" "Median" "SD" "Total Medicare payments, mean" "Median" "SD" ///
"Hospital nights, mean" "Median" "SD"

frmttable using "`logpath'\sic_Table3_outcomes_ivw", statmat(table2) ///
title("Comparison of outcomes at 1 year, criteria a vs b" \ ///
"First interview when R meets criteria") ///
ctitle("" "Criteria A" "Criteria B" "Criteria C" \ "" "Serious med illness and/or" ///
"SMI and/or ADL impair and" "SMI and ADL impair and" ///
\ "" "ADL impairment" "SNF and/or Hospital use" "SNF and/or Hospital use") ///
note("Medicare spending values are adjusted to 2010$ and for the CMS wage index.") ///
sdec(0\2\2\2\2\2\2\0) replace 

*******************************************************************
//Select Outcomes for first interview where meet criteria
//Criteria comparison
*******************************************************************
//table of outcomes, interview where R first meets criteria
local outcome1 core_to_dod_1yr hs_admit_p12m ind_em_ur_adm_p12m ip_paid_by_mc_12m_wi ///
tot_paid_by_mc_12m_wi

local compvars ivw_meet_crit_smi ivw_meet_crit_adl ivw_meet_crit_smiadl ivw_meet_crit_a ///
ivw_meet_crit_smiadlnh ivw_meet_crit_smiadlho ivw_meet_crit_smiadlhonh ///
ivw_meet_crit_c ivw_meet_crit_aho ivw_meet_crit_b 

//overall sample, n interviews
sum core_year
local nsamp=r(N)

mat comp_N_c1=J(10,3,.)
mat comp=J(10,15,.)

//first column, get n for each subgroup
local r=1
foreach comp in `compvars'{
	sum core_year if `comp'==1, detail
	mat comp_N_c1[`r',1]=r(N)
	local r=`r'+1
}

local c=1
foreach var in `outcome1'{
	local r=1
	foreach comp in `compvars'{
		sum `var' if `comp'==1, detail
		mat comp[`r',`c']=r(mean)
		mat comp[`r',`c'+1]=r(sd)
		mat comp[`r',`c'+2]=r(p50)
		local r=`r'+1
	}
local c=`c'+3
}
mat rownames comp_N_c1="Serious med illness" "ADL Impairment"  ///
 "Illness + ADL Impair" "Criteria A" "Illness + ADL + NH(no hosp)" "Illness + ADL + Hospital(no NH)" ///
 "Illness + ADL + NH + Hospital" "Ill + ADL + (Hospital and/or NH)" "Ill and-or ADL + Hospital(no NH)" ///
 "Criteria B"

mat rownames comp="Serious med illness" "ADL Impairment"  ///
"Illness + ADL Impair" "Criteria A" "Illness + ADL + NH(no hosp)" "Illness + ADL + Hospital(no NH)" ///
 "Illness + ADL + NH + Hospital" "Ill + ADL + (Hospital and/or NH)" "Ill and-or ADL + Hospital(no NH)" ///
 "Criteria B"

frmttable , statmat(comp_N_c1) substat(2) ///
title("Comparison of serious medical conditions, outcomes at 1 year" \ ///
"First interview where R meets the criteria") ///
ctitles("","N" ) ///
sdec(0) store(table3)

frmttable using "`logpath'\sic_Table3_outcomes_ivw", statmat(comp)  substat(2) ///
ctitles("","Died","Hospice admit","Hospital admit","IP Medicare","Total Medicare" \ ///
"","mean","","","","" \ "","(SD)", "","","","", \ "","[Median]","","","","" ) ///
note("Medicare spending values are adjusted to 2010$ and for the CMS wage index.") ///
sdec(2) merge(table3) addtable
*************************************************************
//Response to JAMAIM Review
*************************************************************

// assess outcomes by age and dual eligible R1 #1

tab ivw_meet_crit_smi ivw_meet_crit_adl

//define age categorical variable 
//age at time of core

gen age_cat=.
replace age_cat=1 if (age_at_core>=65 & age_at_core<75)
replace age_cat=2 if (age_at_core>=75 & age_at_core<85)
replace age_cat=3 if (age_at_core>=85) 
la var age_cat "Age at Enrollment"
la def age 1 "65-74" 2 "75-84" 3 "85+"
la val age_cat age
tab age_cat, missing

// outcomes, interview where R first meets criteria
local outcome1 core_to_dod_1yr hs_admit_p12m ind_em_ur_adm_p12m ip_paid_by_mc_12m_wi ///
tot_paid_by_mc_12m_wi  ivw_meet_crit_smi

sort age_cat
by age_cat: sum core_to_dod_1yr  if ivw_meet_crit_smi==1, detail
by age_cat: sum core_to_dod_1yr  if ivw_meet_crit_a==1, detail
by age_cat: sum core_to_dod_1yr  if ivw_meet_crit_b==1, detail
by age_cat: sum core_to_dod_1yr  if ivw_meet_crit_c==1, detail

by age_cat: sum ind_em_ur_adm_p12m  if ivw_meet_crit_smi==1, detail
by age_cat: sum ind_em_ur_adm_p12m  if ivw_meet_crit_a==1, detail
by age_cat: sum ind_em_ur_adm_p12m  if ivw_meet_crit_b==1, detail
by age_cat: sum ind_em_ur_adm_p12m  if ivw_meet_crit_c==1, detail

by age_cat: sum tot_paid_by_mc_12m_wi  if ivw_meet_crit_smi==1, detail
by age_cat: sum tot_paid_by_mc_12m_wi  if ivw_meet_crit_a==1, detail
by age_cat: sum tot_paid_by_mc_12m_wi  if ivw_meet_crit_b==1, detail
by age_cat: sum tot_paid_by_mc_12m_wi  if ivw_meet_crit_c==1, detail

sort medicaid
by medicaid: sum core_to_dod_1yr  if ivw_meet_crit_smi==1, detail
by medicaid: sum core_to_dod_1yr  if ivw_meet_crit_a==1, detail
by medicaid: sum core_to_dod_1yr  if ivw_meet_crit_b==1, detail
by medicaid: sum core_to_dod_1yr  if ivw_meet_crit_c==1, detail

by medicaid: sum ind_em_ur_adm_p12m  if ivw_meet_crit_smi==1, detail
by medicaid: sum ind_em_ur_adm_p12m  if ivw_meet_crit_a==1, detail
by medicaid: sum ind_em_ur_adm_p12m  if ivw_meet_crit_b==1, detail
by medicaid: sum ind_em_ur_adm_p12m  if ivw_meet_crit_c==1, detail

by medicaid: sum tot_paid_by_mc_12m_wi  if ivw_meet_crit_smi==1, detail
by medicaid: sum tot_paid_by_mc_12m_wi  if ivw_meet_crit_a==1, detail
by medicaid: sum tot_paid_by_mc_12m_wi  if ivw_meet_crit_b==1, detail
by medicaid: sum tot_paid_by_mc_12m_wi  if ivw_meet_crit_c==1, detail

// assess multimorbidity R1 #3
tab smi_count if ivw_meet_crit_smi==1
tab smi_count if ivw_meet_crit_a==1
tab smi_count if ivw_meet_crit_b==1
tab smi_count if ivw_meet_crit_c==1

//hip fracture

tab hf_w_surgery hf_w_visit_2d, missing
gen ivw_meet_crit_hf=0
replace ivw_meet_crit_hf=1 if (hf_w_surgery==1 | hf_w_visit_2d==1)
tab ivw_meet_crit_hf, missing 

//compare hip fracture outcomes
sum core_to_dod_1yr  if ivw_meet_crit_hf==1, detail
sum ind_em_ur_adm_p12m  if ivw_meet_crit_hf==1, detail
sum tot_paid_by_mc_12m_wi  if ivw_meet_crit_hf==1, detail

	
**************************************************************

// quantify missingness
misstable summarize female educ marital medicaid nhres adl_index_core black hisp_eth 

tab female, missing
tab marital_missing, missing
tab medicaid, missing
tab nhres, missing
tab adl_index_core, missing
tab hisp_eth , missing
tab black, missing
tab adl_diff_dr adl_dr_core, missing
tab adl_core_check, missing

**************************************************************
// compare to top spenders
**************************************************************
sum tot_paid_by_mc_12m_wi, detail
sum tot_paid_by_mc_12m_wi  if ivw_meet_crit_smi==1, detail
sum tot_paid_by_mc_12m_wi  if ivw_meet_crit_a==1, detail
sum tot_paid_by_mc_12m_wi  if ivw_meet_crit_b==1, detail
sum tot_paid_by_mc_12m_wi  if ivw_meet_crit_c==1, detail


**************************************************************
// compare to top spenders in 2008 only
**************************************************************

clear all
set mem 500m
set more off

local logpath E:\data\serious_ill\logs
local datapath2 E:\data\serious_ill\int_data
local datapath E:\data\serious_ill\final_data


cd `datapath2'

use ivws_crit_1.dta if core_year==2008 & /// 
age_ge_65==1 & xwalk_yes==1 & part_ab_12m==1 & hmo_d_12m==0

//meet criteria variables
tab criteria_a, missing
tab criteria_b, missing
tab criteria_c, missing

gen no_crit = 0
replace no_crit=1 if criteria_a==0 & criteria_b==0 & criteria_c==0 
la var no_crit "Criteria not met, 1=yes"
tab no_crit, missing

sum tot_paid_by_mc_12m_wi
sum tot_paid_by_mc_12m_wi if criteria_a==1, detail
sum tot_paid_by_mc_12m_wi if criteria_b==1, detail
sum tot_paid_by_mc_12m_wi if criteria_c==1, detail
sum tot_paid_by_mc_12m_wi if no_crit==1, detail

log close
