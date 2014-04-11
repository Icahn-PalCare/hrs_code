/*surgery project analysis

Created 1/15/2014 to run preliminary logit regressions of age on mortality

Need to run surgery_proj_analysis_20140108_for_abstract_2010_clms.do and 
analysis_20140108_tables_2010_clms.do files to get cleaned dataset with all
required variables prior to running this analysis file

Have to manually add in variable labels to word document, varlables
not working with categorical variables for some reason*/

capture log close

clear all
set mem 500m
set matsize 800
set more off

local texpath E:\data\surgery\logs\tex\
local logpath E:\data\surgery\logs\
local datapath E:\data\surgery\final_2010clms\

log using `logpath'9_Surgery_code_analysis1.txt, text replace

use `datapath'surgery_final_n12m_sample_2.dta

numlabel, add

tab died_30d_full died_180d_full, missing

******************************************************************
******************************************************************
//Run regression - effect of age on mortality
******************************************************************
******************************************************************
/*
//base categories are age=65-73, srh=very good/excellent 
//adl = independent, disch destination = home
//no disch destination rehab (b/c no obs)
local xvars_30d ib1.age_cat i.comorb_1_0_n12m i.comorb_32_0_n12m ///
	i.comorb_31_0_n12m i.comorb_13_0_n12m ///
	ib1.srh_cat_core ib0.adl_cat_core i.nhres_n1 i.admit_ind_6m_pre ///
	ib1.stay_dstn_cat i2.stay_dstn_cat i4.stay_dstn_cat ///
	i5.stay_dstn_cat i6.stay_dstn_cat i.comp_any

//base categories are age=65-73, srh=very good/excellent 
//adl = independent, disch destination = home
//no disch destination expired (b/c no obs)
local xvars_180d ib1.age_cat i.comorb_1_0_n12m i.comorb_32_0_n12m ///
	i.comorb_31_0_n12m i.comorb_13_0_n12m ///
	ib1.srh_cat_core ib0.adl_cat_core i.nhres_n1 i.admit_ind_6m_pre ///
	ib1.stay_dstn_cat i2.stay_dstn_cat i3.stay_dstn_cat ///
	i4.stay_dstn_cat i5.stay_dstn_cat i.comp_any
	
logit died_30d_full `xvars_30d', vce(r) or baselevels

outreg, ///
	stats(e_b e_ci) dbldiv(,) ctitles("","30-Day") ///
	title("Effect of age on mortality") ///
	note("Odds ratios, 95% confidence intervals reported" \ ///
	"Base categories are Age: 65-74, Self-reported health: Excellent or very good," \ ///
	"ADL: Independent, and Discharged to Home.") ///
	varlabels store(table1) starlevels(10 5 1)

logit died_180d_full `xvars_180d', vce(r) or
outreg, ///
	stats(e_b e_ci) dbldiv(,) ctitles("","180-Day") ///
	varlabels merge(table1) starlevels(10 5 1)

logit died_365d_full `xvars_180d', vce(r) or
outreg using `logpath'logit_age, ///
	stats(e_b e_ci) dbldiv(,) ctitles("","365-Day") ///
	varlabels merge(table1) starlevels(10 5 1) replace


******************************************************************
******************************************************************
//Run regression - effect of age on mortality
//Exclude the discharge location variables
******************************************************************
******************************************************************
//base categories are age=65-73, srh=very good/excellent 
//adl = independent, disch destination = home
//no disch destination rehab (b/c no obs)
local xvars_no_disch ib1.age_cat i.comorb_1_0_n12m i.comorb_32_0_n12m ///
	i.comorb_31_0_n12m i.comorb_13_0_n12m ///
	ib1.srh_cat_core ib0.adl_cat_core i.nhres_n1 i.admit_ind_6m_pre ///
	/*ib1.stay_dstn_cat i2.stay_dstn_cat i4.stay_dstn_cat ///
	i5.stay_dstn_cat i6.stay_dstn_cat*/ i.comp_any

logit died_30d_full `xvars_no_disch', vce(r) or
outreg, ///
	stats(e_b e_ci) dbldiv(,) ctitles("","30-Day") ///
	title("Effect of age on mortality - No disch destination code as covariate") ///
	note("Odds ratios, 95% confidence intervals reported" \ ///
	"Base categories are Age: 65-74, Self-reported health: Excellent or very good," \ ///
	"and ADL: Independent.") ///
	varlabels store(table2) starlevels(10 5 1)

logit died_180d_full `xvars_no_disch', vce(r) or
outreg, ///
	stats(e_b e_ci) dbldiv(,) ctitles("","180-Day") ///
	varlabels merge(table2) starlevels(10 5 1)

logit died_365d_full `xvars_no_disch', vce(r) or
outreg using `logpath'logit_age, ///
	stats(e_b e_ci) dbldiv(,) ctitles("","365-Day") ///
	varlabels merge(table2) starlevels(10 5 1) addtable	
*/	
	
******************************************************************
******************************************************************
//Run regression - effect of age on mortality
//Exclude the discharge location variables, include diabetes
******************************************************************
******************************************************************
//base categories are age=65-73, srh=very good/excellent 
//adl = independent, disch destination = home
//no disch destination rehab (b/c no obs)
local xvars_no_disch ib1.age_cat i.comorb_1_0_n12m i.comorb_32_0_n12m ///
	i.comorb_31_0_n12m i.comorb_13_0_n12m i.el_diab ///
	ib1.srh_cat_core ib0.adl_cat_core i.nhres_n1 i.admit_ind_6m_pre ///
	/*ib1.stay_dstn_cat i2.stay_dstn_cat i4.stay_dstn_cat ///
	i5.stay_dstn_cat i6.stay_dstn_cat*/ i.comp_any

******************************************************************	
//Version 1 - not mutually exclusive mortality categories	
******************************************************************
logit died_30d_full `xvars_no_disch', /*vce(r)*/ or
outreg, ///
	stats(e_b e_ci) dbldiv(,) ctitles("","30-Day") ///
	title("Effect of age on mortality - No disch destination code as covariate" \ ///
	"Not mutually exclusive mortality categories") ///
	note("Odds ratios, 95% confidence intervals reported" \ ///
	"Base categories are Age: 65-74, Self-reported health: Excellent or very good," \ ///
	"and ADL: Independent.") ///
	varlabels store(table3) starlevels(10 5 1)

logit died_180d_full `xvars_no_disch', /*vce(r)*/ or
outreg, ///
	stats(e_b e_ci) dbldiv(,) ctitles("","180-Day") ///
	varlabels merge(table3) starlevels(10 5 1)

/*logit died_365d_full `xvars_no_disch', vce(r) or
outreg using `logpath'logit_age, ///
	stats(e_b e_ci) dbldiv(,) ctitles("","365-Day") ///
	varlabels merge(table3) starlevels(10 5 1) addtable		*/
	
logit died_365d_full `xvars_no_disch', /*vce(r)*/ or
outreg using `logpath'logit_age2, ///
	stats(e_b e_ci) dbldiv(,) ctitles("","365-Day") ///
	varlabels merge(table3) starlevels(10 5 1) replace		

	
******************************************************************	
//Version 2 - mutually exclusive mortality categories	
******************************************************************	
logit died_30d_full2 `xvars_no_disch', /*vce(r)*/ or
outreg, ///
	stats(e_b e_ci) dbldiv(,) ctitles("","30-Day") ///
	title("Effect of age on mortality - No disch destination code as covariate" \ ///
	"Mutually exclusive mortality categories") ///
	note("Odds ratios, 95% confidence intervals reported" \ ///
	"Base categories are Age: 65-74, Self-reported health: Excellent or very good" \ ///
	"for 30- and 180-day and Good for 365-day mortality, and ADL: Independent.") ///
	varlabels store(table4) starlevels(10 5 1)

logit died_180d_full2 `xvars_no_disch', /*vce(r)*/ or
outreg, ///
	stats(e_b e_ci) dbldiv(,) ctitles("","180-Day") ///
	varlabels merge(table4) starlevels(10 5 1)

/*logit died_365d_full `xvars_no_disch', vce(r) or
outreg using `logpath'logit_age, ///
	stats(e_b e_ci) dbldiv(,) ctitles("","365-Day") ///
	varlabels merge(table3) starlevels(10 5 1) addtable		*/

local xvars_3652_me ib1.age_cat i.comorb_1_0_n12m i.comorb_32_0_n12m ///
	i.comorb_31_0_n12m /*i.comorb_13_0_n12m*/ i.el_diab ///
	ib2.srh_cat_core i3.srh_cat_core ib0.adl_cat_core i2.adl_cat_core /*i.nhres_n1*/ i.admit_ind_6m_pre ///
	/*ib1.stay_dstn_cat i2.stay_dstn_cat i4.stay_dstn_cat ///
	i5.stay_dstn_cat i6.stay_dstn_cat*/ i.comp_any	
	
logit died_365d_full2 `xvars_3652_me', /*vce(r)*/ or
outreg using `logpath'logit_age2, ///
	stats(e_b e_ci) dbldiv(,) ctitles("","365-Day") ///
	varlabels merge(table4) starlevels(10 5 1) addtable		
	
******************************************************************
******************************************************************
//Run regression - effect of age on mortality
//All controls
******************************************************************
******************************************************************
//base categories are age=65-73, race=white, tics=normal srh=very good/excellent 
//adl = independent, disch destination = home
//variables omitted b/c no obs: race=other, tics=demented, disch=rehab
local xvars_30d_all ib1.age_cat i.female i1.re_cat i2.re_cat ib3.re_cat ///
	i1b.tics_cat_miss i2.tics_cat_miss i4.tics_cat_miss ///
	i.el_cancer i.comorb_1_0_n12m i.comorb_32_0_n12m i.comorb_31_0_n12m ///
	i.comorb_13_0_n12m i.el_diab ib1.srh_cat_core ib0.adl_cat_core ///
	i.nhres_n1 i.admit_ind_6m_pre ///
	ib1.stay_dstn_cat i2.stay_dstn_cat i4.stay_dstn_cat ///
	i5.stay_dstn_cat i6.stay_dstn_cat i.comp_any
/*
//For 180 day mortality regression
//variables omitted b/c no obs: tics=demented, disch=expired 
local xvars_180d_all ib1.age_cat i.female ib3.re_cat ///
	i1b.tics_cat_miss i2.tics_cat_miss i4.tics_cat_miss ///
	i.el_cancer i.comorb_1_0_n12m i.comorb_32_0_n12m i.comorb_31_0_n12m ///
	i.comorb_13_0_n12m i.el_diab ib1.srh_cat_core ib0.adl_cat_core ///
	i.nhres_n1 i.admit_ind_6m_pre ///
	ib1.stay_dstn_cat i2.stay_dstn_cat i3.stay_dstn_cat ///
	i4.stay_dstn_cat i5.stay_dstn_cat i.comp_any	

//For 365 day mortality regression
//variables omitted b/c perfect correlation: disch=expired
local xvars_365d_all ib1.age_cat i.female ib3.re_cat ib1.tics_cat_miss ///
	i.el_cancer i.comorb_1_0_n12m i.comorb_32_0_n12m i.comorb_31_0_n12m ///
	i.comorb_13_0_n12m i.el_diab ib1.srh_cat_core ib0.adl_cat_core ///
	i.nhres_n1 i.admit_ind_6m_pre ///
	ib1.stay_dstn_cat i2.stay_dstn_cat i3.stay_dstn_cat ///
	i4.stay_dstn_cat i5.stay_dstn_cat i.comp_any	
	
logit died_30d_full `xvars_30d_all', vce(r) or
outreg, ///
	stats(e_b e_ci) dbldiv(,) ctitles("","30-Day") ///
	title("Effect of age on mortality - All covariates") ///
	note("Odds ratios, 95% confidence intervals reported" \ ///
	"Base categories are Age: 65-74, Race: White, TICS: Normal," \ ///
	"Self-reported health: Excellent or very good," \ ///
	"ADL: Independent, and Discharged to Home.") ///
	varlabels store(table4) starlevels(10 5 1)

logit died_180d_full `xvars_180d_all', vce(r) or
outreg, ///
	stats(e_b e_ci) dbldiv(,) ctitles("","180-Day") ///
	varlabels merge(table4) starlevels(10 5 1)

logit died_365d_full `xvars_365d_all', vce(r) or
outreg using `logpath'logit_age, ///
	stats(e_b e_ci) dbldiv(,) ctitles("","365-Day") ///
	varlabels merge(table4) starlevels(10 5 1) addtable		
*/
	
//Cox regression
//first assign a new date, end_date either death date or p1 interview date
format death_date_e %td
tab death_date_e

gen end_date = death_date_e
replace end_date= c_ivw_date_p1 if death_date_e == .
format end_date %td
tab end_date,missing
//lose the who have no death date or no post-surgery interview
//one obs has an exit interview but no death date

//save dataset to bring into sas and try cox regression
save `datapath'surgery_final_n12m_sample_for_sas.dta, replace

tempvar end_dt_miss
gen `end_dt_miss' = 0
replace `end_dt_miss' = 1 if end_date==.

tab `end_dt_miss' post_surg_ivw,missing

//2 observations die on date of surgery
tab stay_dstn_cd index_los if(death_date_e<=procedure_date )
tab procedure_date death_date_e if(death_date_e<procedure_date)
tab procedure_date end_date if(death_date_e<procedure_date)
tab id  if(death_date_e<procedure_date)

//set for 365 day mortality only by specifying exit time
stset end_date, failure(died_ind) origin(procedure_date) //exit(time procedure_date + 365)
stdes

//KM Estimate
sts list
sts graph

//all covariates
//stcox  `xvars_30d_all' /*, vce(robust)*/
//preferred model from means table / logit
stcox  `xvars_no_disch' /*, vce(robust)*/

//generate interaction terms to do them manually


local cox_xvars 
gen age65_30d =  age_at_surg_65_74*died_30d_full2
gen age75_30d =  age_at_surg_75_79*died_30d_full2
gen age80_30d =  age_at_surg_80_84*died_30d_full2
gen age85_30d =  age_at_surg_gt84*died_30d_full2 

gen age65_180d =  age_at_surg_65_74*died_180d_full2
gen age75_180d =  age_at_surg_75_79*died_180d_full2
gen age80_180d =  age_at_surg_80_84*died_180d_full2
gen age85_180d =  age_at_surg_gt84*died_180d_full2 

gen age65_365d =  age_at_surg_65_74*died_365d_full2
gen age75_365d =  age_at_surg_75_79*died_365d_full2
gen age80_365d =  age_at_surg_80_84*died_365d_full2
gen age85_365d =  age_at_surg_gt84*died_365d_full2 

gen age75_a = age_at_surg_75_79*alive_365d_full
gen age80_a = age_at_surg_80_84*alive_365d_full
gen age85_a = age_at_surg_gt84*alive_365d_full 

//comorbidities
gen chf_30d = comorb_1_0_n12m*died_30d_full2
gen cad_30d = comorb_32_0_n12m*died_30d_full2
gen dem_30d = comorb_31_0_n12m*died_30d_full2
gen esrd_30d = comorb_13_0_n12m*died_30d_full2
gen diab_30d = el_diab*died_30d_full2

gen chf_180d = comorb_1_0_n12m*died_180d_full2
gen cad_180d = comorb_32_0_n12m*died_180d_full2
gen dem_180d = comorb_31_0_n12m*died_180d_full2
gen esrd_180d = comorb_13_0_n12m*died_180d_full2
gen diab_180d = el_diab*died_180d_full2

gen chf_365d = comorb_1_0_n12m*died_365d_full2
gen cad_365d = comorb_32_0_n12m*died_365d_full2
gen dem_365d = comorb_31_0_n12m*died_365d_full2
gen esrd_365d = comorb_13_0_n12m*died_365d_full2
gen diab_365d = el_diab*died_365d_full2

gen chf_a = comorb_1_0_n12m*alive_365d_full
gen cad_a = comorb_32_0_n12m*alive_365d_full
gen dem_a = comorb_31_0_n12m*alive_365d_full
gen esrd_a = comorb_13_0_n12m*alive_365d_full
gen diab_a = el_diab*alive_365d_full

//srh categories
gen srhve_30d = srh_ve_ncore*died_30d_full2
gen srhg_30d = srh_g_ncore*died_30d_full2
gen srhfp_30d = srh_fp_ncore*died_30d_full2

gen srhve_180d = srh_ve_ncore*died_180d_full2
gen srhg_180d = srh_g_ncore*died_180d_full2
gen srhfp_180d = srh_fp_ncore*died_180d_full2  

gen srhve_365d = srh_ve_ncore*died_365d_full2
gen srhg_365d = srh_g_ncore*died_365d_full2
gen srhfp_365d = srh_fp_ncore*died_365d_full2  
  
gen srhve_a = srh_ve_ncore*alive_365d_full
gen srhg_a = srh_g_ncore*alive_365d_full
gen srhfp_a = srh_fp_ncore*alive_365d_full 

//ADL categories
gen adlind_30d = adl_ind_ncore*died_30d_full2
gen adlpart_30d = adl_pd_ncore*died_30d_full2
gen adlsev_30d = adl_sd_ncore*died_30d_full2
  
gen adlind_180d = adl_ind_ncore*died_180d_full2
gen adlpart_180d = adl_pd_ncore*died_180d_full2
gen adlsev_180d = adl_sd_ncore*died_180d_full2
  
gen adlind_365d = adl_ind_ncore*died_365d_full2
gen adlpart_365d = adl_pd_ncore*died_365d_full2
gen adlsev_365d = adl_sd_ncore*died_365d_full2
  
gen adlind_a = adl_ind_ncore*alive_365d_full
gen adlpart_a = adl_pd_ncore*alive_365d_full
gen adlsev_a = adl_sd_ncore*alive_365d_full
 
gen nh_30d = nhres_n1*died_30d_full2
gen nh_180d = nhres_n1*died_180d_full2
gen nh_365d = nhres_n1*died_365d_full2
gen nh_a = nhres_n1*alive_365d_full

gen adm_30d = admit_ind_6m_pre*died_30d_full2
gen adm_180d = admit_ind_6m_pre*died_180d_full2
gen adm_365d = admit_ind_6m_pre*died_365d_full2
gen adm_a = admit_ind_6m_pre*alive_365d_full

gen comp_30d = comp_any*died_30d_full2
gen comp_180d = comp_any*died_180d_full2
gen comp_365d = comp_any*died_365d_full2
gen comp_a = comp_any*alive_365d_full
 
local xvars_cox_man age75_30d age75_180d age75_365d age75_a age80_30d age80_180d age80_365d age80_a ///
age85_30d age85_180d age85_365d age85_a chf_30d chf_180d chf_365d chf_a cad_30d cad_180d cad_365d cad_a ///
dem_30d dem_180d dem_365d dem_a esrd_30d esrd_180d esrd_365d esrd_a diab_30d diab_180d diab_365d diab_a ///
srhg_30d srhg_180d srhg_365d srhg_a srhfp_30d srhfp_180d srhfp_365d srhfp_a ///
adlpart_30d adlpart_180d adlpart_365d adlpart_a adlsev_30d adlsev_180d adlsev_365d adlsev_a ///
nh_30d nh_180d nh_365d nh_a adm_30d adm_180d adm_365d adm_a comp_30d comp_180d comp_365d comp_a

stcox `xvars_cox_man'

local keep30d age75_30d age80_30d age85_30d chf_30d cad_30d ///
dem_30d esrd_30d diab_30d srhg_30d srhfp_30d adlpart_30d adlsev_30d ///
nh_30d adm_30d comp_30d 

outreg using `logpath'cox_age, ///
	stats(e_b e_ci) dbldiv(,) ctitles("","30-Day") ///
	keep(`keep30d') store(table1) starlevels(10 5 1) replace		 
  
  
/*
//local with interaction terms on mortality categories to allow
//different hazard ratios for different mortality categories
//base categories changed here, update in logit tables to match!!
local xvars_cox ib1.age_cat##i.died_30d_full2 i.comorb_1_0_n12m##i.died_30d_full2 ///
 i.comorb_32_0_n12m##i.died_30d_full2 i.comorb_31_0_n12m##i.died_30d_full2 ///
 i.comorb_13_0_n12m##i.died_30d_full2 i.el_diab##i.died_30d_full2 ///
 ib2.srh_cat_core##i.died_30d_full2 ib0.adl_cat_core##i.died_30d_full2 ///
 i.nhres_n1##i.died_30d_full2 i.admit_ind_6m_pre##i.died_30d_full2 ///
 i.comp_any##i.died_30d_full2 /// //end of 30 day inter terms
	ib1.age_cat##i.died_180d_full2 i.comorb_1_0_n12m##i.died_180d_full2 ///
	i.comorb_32_0_n12m##i.died_180d_full2 i.comorb_31_0_n12m##i.died_180d_full2 ///
	i.comorb_13_0_n12m##i.died_180d_full2 i.el_diab##i.died_180d_full2 ///
	ib2.srh_cat_core##i.died_180d_full2 ib0.adl_cat_core##i.died_180d_full2 ///
	i.nhres_n1##i.died_180d_full2 i.admit_ind_6m_pre##i.died_180d_full2 ///
	i.comp_any##i.died_180d_full2 /// //end of 180 day inter terms
 ib1.age_cat##i.died_365d_full2 i.comorb_1_0_n12m##i.died_365d_full2 ///
 i.comorb_32_0_n12m##i.died_365d_full2 i.comorb_31_0_n12m##i.died_365d_full2 ///
 i.el_diab##i.died_365d_full2 ib2.srh_cat_core##i.died_365d_full2 ///
 i3.srh_cat_core##i.died_365d_full2 ib0.adl_cat_core##i.died_365d_full2 ///
 i2.adl_cat_core##i.died_365d_full2  i.admit_ind_6m_pre##i.died_365d_full2 ///
	 i.comp_any##i.died_365d_full2 //end of 365 day inter terms
//	ib1.age_cat##i.alive_365d_full i.comorb_1_0_n12m##i.alive_365d_full ///
//	i.comorb_32_0_n12m##i.alive_365d_full i.comorb_31_0_n12m##i.alive_365d_full ///
//	i.comorb_13_0_n12m##i.alive_365d_full i.el_diab##i.alive_365d_full ///
//	ib1.srh_cat_core##i.alive_365d_full ib0.adl_cat_core##i.alive_365d_full ///
//	i.nhres_n1##i.alive_365d_full i.admit_ind_6m_pre##i.alive_365d_full ///
//	i.comp_any##i.alive_365d_full /// //end of alive at 365d inter terms	
*/

gen byte died_31_365d = 0
replace died_31_365d = 1 if died_180d_full2==1 | died_365d_full2==1
tab died_31_365d

/*local xvars_cox ib1.age_cat#i1.died_30d_full2 i.comorb_1_0_n12m#i1.died_30d_full2 ///
 i.comorb_32_0_n12m#i1.died_30d_full2 i.comorb_31_0_n12m#i1.died_30d_full2 ///
 i.comorb_13_0_n12m#i1.died_30d_full2 i.el_diab#i1.died_30d_full2 ///
 ib1.srh_cat_core#i1.died_30d_full2 ib0.adl_cat_core#i1.died_30d_full2 ///
 i.nhres_n1#i1.died_30d_full2 i.admit_ind_6m_pre#i1.died_30d_full2 ///
 i.comp_any#i1.died_30d_full2 /// //end of 30 day inter terms
	ib1.age_cat#i1.died_31_365d i.comorb_1_0_n12m#i1.died_31_365d ///
	i.comorb_32_0_n12m#i1.died_31_365d i.comorb_31_0_n12m#i1.died_31_365d ///
	i.comorb_13_0_n12m#i1.died_31_365d i.el_diab#i1.died_31_365d ///
	ib1.srh_cat_core#i1.died_31_365d ib0.adl_cat_core#i1.died_31_365d ///
	i.nhres_n1#i1.died_31_365d i.admit_ind_6m_pre#i1.died_31_365d ///
	i.comp_any#i1.died_31_365d /// //end of 180 day inter terms


//manually create interaction terms to try it...
//age categories
gen age65_30d =  age_at_surg_65_74*died_30d_full2
gen age75_30d =  age_at_surg_75_79*died_30d_full2
gen age80_30d =  age_at_surg_80_84*died_30d_full2
gen age85_30d =  age_at_surg_gt84*died_30d_full2 

gen age65_365d =  age_at_surg_65_74*died_31_365d
gen age75_365d =  age_at_surg_75_79*died_31_365d
gen age80_365d =  age_at_surg_80_84*died_31_365d
gen age85_365d =  age_at_surg_gt84*died_31_365d 

gen chf_30d = comorb_1_0_n12m*died_30d_full2
gen cad_30d = comorb_32_0_n12m*died_30d_full2
gen dem_30d = comorb_31_0_n12m*died_30d_full2
gen esrd_30d = comorb_13_0_n12m*died_30d_full2
gen diab_30d = el_diab*died_30d_full2

gen chf_365d = comorb_1_0_n12m*died_31_365d
gen cad_365d = comorb_32_0_n12m*died_31_365d
gen dem_365d = comorb_31_0_n12m*died_31_365d
gen esrd_365d = comorb_13_0_n12m*died_31_365d
gen diab_365d = el_diab*died_31_365d

gen srhve_30d = srh_ve_ncore*died_30d_full2
gen srhg_30d = srh_g_ncore*died_30d_full2
gen srhfp_30d = srh_fp_ncore*died_30d_full2

gen srhve_365d = srh_ve_ncore*died_31_365d
gen srhg_365d = srh_g_ncore*died_31_365d
gen srhfp_365d = srh_fp_ncore*died_31_365d   

gen adlind_30d = adl_ind_ncore*died_30d_full2
gen adlpart_30d = adl_pd_ncore*died_30d_full2
gen adlsev_30d = adl_sd_ncore*died_30d_full2
  
gen adlind_365d = adl_ind_ncore*died_31_365d
gen adlpart_365d = adl_pd_ncore*died_31_365d
gen adlsev_365d = adl_sd_ncore*died_31_365d
  
gen nh_30d = nhres_n1*died_30d_full2
gen nh_365d = nhres_n1*died_31_365d

gen adm_30d = admit_ind_6m_pre*died_30d_full2
gen adm_365d = admit_ind_6m_pre*died_31_365d

gen comp_30d = comp_any*died_30d_full2
gen comp_365d = comp_any*died_31_365d

local xvars_cox age65_30d age75_30d age80_30d age85_30d chf_30d cad_30d dem_30d esrd_30d diab_30d ///
srhve_30d srhg_30d /*srhfp_30d*/ adlind_30d adlpart_30d /*adlsev_30d*/ nh_30d adm_30d comp_30d ///
age65_365d age75_365d age80_365d age85_365d chf_365d cad_365d dem_365d esrd_365d diab_365d ///
srhve_365d srhg_365d /*srhfp_365d*/ adlind_365d adlpart_365d /*adlsev_365d*/ nh_365d adm_365d comp_365d
 
tab srhfp_30d
tab srhfp_365d
tab srh_fp_ncore alive_365d_full
 
//stcox `xvars_cox'

//try with died w/i 1 year indicator vs alive
tab died_365d_full, missing
local xvars_cox2 ib1.age_cat#i1.died_365d_full i.comorb_1_0_n12m#i1.died_365d_full ///
 i.comorb_32_0_n12m#i1.died_365d_full i.comorb_31_0_n12m#i1.died_365d_full ///
 i.comorb_13_0_n12m#i1.died_365d_full i.el_diab#i1.died_365d_full ///
 ib1.srh_cat_core#i1.died_365d_full ib0.adl_cat_core#i1.died_365d_full ///
 i.nhres_n1#i1.died_365d_full i.admit_ind_6m_pre#i1.died_365d_full ///
 i.comp_any#i1.died_365d_full /// //end of 30 day inter terms

stcox `xvars_cox2'

//try with fewer x var categories
gen any_comorb_30d = 0
replace any_comorb_30d=1 if (chf_30d==1 | cad_30d==1 | dem_30d==1 | esrd_30d==1 | diab_30d==1)
tab any_comorb_30d

gen any_comorb_365d = 0
replace any_comorb_365d=1 if chf_365d==1 | cad_365d==1 | dem_365d==1 | esrd_365d==1 | diab_365d==1
tab any_comorb_365d

gen adl_ps_30d = 0
replace adl_ps_30d = 1 if adlpart_30d==1 | adlsev_30d==1
tab adl_ps_30d

gen adl_ps_365d = 0
replace adl_ps_365d = 1 if adlpart_365d==1 | adlsev_365d==1
tab adl_ps_365d



gen any_comorb_a = 0
replace any_comorb_a=1 if chf_a==1 | cad_a==1 | dem_a==1 | esrd_a==1 | diab_a==1 

 
 gen adl_ps_a = 0
replace adl_ps_a = 1 if adlpart_a==1 | adlsev_a==1

local xvars_cox3 age75_30d age80_30d age85_30d any_comorb_30d ///
srhfp_30d adl_ps_30d nh_30d adm_30d comp_30d ///
age75_365d age80_365d age85_365d any_comorb_365d ///
srhfp_365d adl_ps_365d nh_365d adm_365d comp_365d age75_a age80_a age85_a ///
any_comorb_a srhfp_a adl_ps_a nh_a adm_a comp_a

stcox `xvars_cox3' */
	
log close
