/*surgery project summary statistics
For tables from Zara Cooper requested 10/11/2013

Note: Need to run analysis_20131127 file first (this file calls it to be sure)*/

capture log close

clear all
set mem 500m
set matsize 800
set more off

//do "E:\projects\surgery\surgery_proj_analysis_20131127_for_abstract.do"

capture log close

clear all
set mem 500m
set matsize 800
set more off

local texpath E:\data\surgery\logs\tex\
local logpath E:\data\surgery\logs\

log using `logpath'8_Surgery_code_sum_stats.txt, text replace

cd "E:\data\surgery\final_data\"


//Use dataset with sample defined created in file 
//surgery_proj_analysis_20131127_for_abstract.do
use surgery_final_n12m_sample.dta

***************************************************
***************************************************
// Create categorical variables as needed
// Look at tabs before creating tables
***************************************************
***************************************************

***************************************************
// Patient characteristics variables from core int.
***************************************************

tab age_cat, missing

la def fem 0 "Male" 1 "Female"
la values female fem
tab female, missing
tab other_na_api_race_e, missing

//create race and ethnicity categorical variable
gen re_cat = .
replace re_cat = 1 if black_e==1
replace re_cat = 3 if white_e==1
replace re_cat = 2 if hisp_eth_e==1
replace re_cat = 4 if native_amer_e==1 | asian_pi_e==1 | other_race_e==1
la var re_cat "race & ethnicity"
la def re_cat 1 "African American" 3 "White" 2 "Hispanic" 4 "Other"
la val re_cat re_cat
tab re_cat, missing

/**************************************************/
// Elixhauser comorbidities
/**************************************************/

//create diabetes variable to cover both comorb variables
gen el_diab=.
replace el_diab=1 if comorb_10_0_n12m==1 | comorb_11_0_n12m==1 //diabetes, uncompl.+compl.
replace el_diab=0 if comorb_10_0_n12m==0 & comorb_11_0_n12m==0
tab el_diab, missing
la var el_diab "Diabetes"


//create cancer variable to cover different el comorb variables
gen el_cancer=.
replace el_cancer=1 if comorb_17_0_n12m==1 | comorb_18_0_n12m==1 | comorb_19_0_n12m==1
replace el_cancer=0 if comorb_17_0_n12m==0 & comorb_18_0_n12m==0 & comorb_19_0_n12m==0
la var el_cancer "Cancer"
tab el_cancer, missing 

//create combined AMI + ISCHMCHT variable as proxy for CAD
//?? This combined variable needs to be created from chronic conditions
// not elix comorbidities

local comorb el_cancer comorb_1_0_n12m comorb_32_0_n12m comorb_31_0_n12m comorb_13_0_n12m el_diab
la def el_ind  0 "No" 1 "Yes"
lab val `comorb' el_ind  



//create collapsed self reported health, pre-surgery core categorical variable
//one obs is missing n1 srh but has n2 srh so use n2 srh for categorical variable
la var srh_n2 "SRH Core n2"
tab srh_n1 srh_n2, missing

gen byte srh_n1_imp_n2=0
replace srh_n1_imp_n2=1 if (srh_n1==. & srh_n2!=.)
tab srh_n1_imp_n2, missing

gen srh_cat_core=.
replace srh_cat_core=1 if  srh_ve_n1==1 //very good and excellent
replace srh_cat_core=2 if  srh_g_n1==1 //good
replace srh_cat_core=3 if  srh_pf_n1==1 //fair and poor

//for the obs where n1 core is missing but n2 core reported, use n2 core value
replace srh_cat_core=1 if (srh_ve_n2==1 & srh_n1==.) //very good and excellent
replace srh_cat_core=2 if (srh_g_n2==1 & srh_n1==.) //good
replace srh_cat_core=3 if (srh_pf_n2==1 & srh_n1==.) //fair and poor

la var srh_cat_core "Self reported health"
la def srh_cat_core 1 "Very Good / Excellent" 2 "Good" 3 "Fair / Poor"
la val srh_cat_core srh_cat_core
tab srh_cat_core,missing

//adl categories - add labels, use n2 core adl for obs where n1 is missing
label define adl_cat_core_n1 0 "Independent" 1 "Partial Dependence" 2 "Severe Dependence", modify
label values adl_cat_core_n1 adl_cat_core_n1 
label var adl_cat_core_n2 "ADL Categ n2 core"
tab adl_cat_core_n1 adl_cat_core_n2, missing

gen byte adl_cat_n1_imp_n2=0
replace adl_cat_n1_imp_n2=1 if (adl_cat_core_n1==. & adl_cat_core_n2 !=.)
tab adl_cat_n1_imp_n2, missing

gen adl_cat_core=adl_cat_core_n1
replace adl_cat_core=adl_cat_core_n2 if (adl_cat_core_n1==. & adl_cat_core_n2 !=.)
la var adl_cat_core "ADL categorical from pre-surg core int"
la val adl_cat_core_n1 adl_cat_core_n2 adl_cat_core
tab adl_cat_core, missing

//nursing home resident - add labels
la def nhres_n1 1 "Yes" 0 "No"
la val nhres_n1 nhres_n1
tab nhres_n1, missing

//tics score n1 - categorical
gen tics_cat = .
replace tics_cat = 1 if (tics_tot_n1 > 8 & tics_tot_n1~=.)
replace tics_cat = 2 if (tics_tot_n1 >= 5 & tics_tot_n1 <= 8)
replace tics_cat = 3 if (tics_tot_n1 <= 4 & tics_tot_n1~=.)
la var tics_cat "TICS - categorical"
la def tics_cat 1 "9-35 Normal" 2 "5-8 MCI" 3 "0-4 Demented"
la val tics_cat tics_cat
tab tics_cat, missing

tab tics_cat comorb_31_0_n12m, missing

//tics score n2 - categorical
gen tics_cat_n2 = .
replace tics_cat_n2 = 1 if (tics_tot_n2 > 8 & tics_tot_n2~=.)
replace tics_cat_n2 = 2 if (tics_tot_n2 >= 5 & tics_tot_n2 <= 8)
replace tics_cat_n2 = 3 if (tics_tot_n2 <= 4 & tics_tot_n2~=.)
la var tics_cat_n2 "TICS - categorical n2 int"
la def tics_cat_n2 1 "9-35 Normal" 2 "5-8 MCI" 3 "0-4 Demented"
la val tics_cat_n2 tics_cat_n2
tab tics_cat_n2, missing

tab tics_cat_n2 comorb_31_0_n12m, missing

tab tics_cat tics_cat_n2, missing
//There are 7 obs where n1 tics is missing but n2 tics is not
//Create indicator for ticsn2 used and recode tics_cat variable
//to use n2 tics so we can keep those obs in the cohort
gen byte tics_n1_imp_n2=0
replace tics_n1_imp_n2=1 if tics_cat==. & tics_cat_n2!=.
tab tics_n1_imp_n2, missing

replace tics_cat = 1 if (tics_tot_n2 > 8 & tics_tot_n2~=. & tics_tot_n1==.)
replace tics_cat = 2 if (tics_tot_n2 >= 5 & tics_tot_n2 <= 8 & tics_tot_n1==.)
replace tics_cat = 3 if (tics_tot_n2 <= 4 & tics_tot_n2~=. & tics_tot_n1==.)

tab tics_cat, missing
//look at why tics is missing for 33 observations
//age at n1 core interview
//create age at surgery variable
gen age_at_n1=.
replace age_at_n1  = ( c_ivw_date_n1-birth_date_e) / 365.25
la var age_at_n1 "Age at time of core n1 interview"
sum age_at_n1, detail

//they are either <65 at the n1 core interview or the n1 core was by proxy
tab age_at_n1  proxy_core_n1 if tics_cat==.

***************************************************
// Hospital episode characteristics variables 
// from surgery claims
***************************************************
/*
****COMMENTED OUT - ZARA WILL POPULATE THIS PART OF THE TABLE HERSELF******
//categories of procedures
gen proc_cat=.
replace proc_cat=1 if inlist(procedure,5411,5412,5419,5459,5495)
replace proc_cat=2 if inlist(procedure,5209,5222,5299)
replace proc_cat=3 if inlist(procedure,4401,4441,4442,4492,4381,4391,4399,436,437,445)
replace proc_cat=4 if inlist(procedure,4502,4515,4551,1732,4572,4561,4562,4563,4601)
replace proc_cat=5 if inlist(procedure,4503,4522,4526,4570,4571,4572,4573,4574,4575,4576, ///
	4580,4581,4582,4583,4603)
replace proc_cat=6 if inlist(procedure,534,5351,5359,5361,5369)
replace proc_cat=7 if inlist(procedure,4700,4709)
replace proc_cat=8 if inlist(procedure,5120,5121,5122)
replace proc_cat=9 if proc_cat==.
lab var proc_cat "Procedure by Category"
la def proc_cat 1 "Laparotonomy, lysis of peritoneal adhesions, or incision peritoneum" ///
 2 "Pancreatic surgery" 3 "Gastric surgery" 4 "Small intestine" ///
 5 "Large Intestine" 6 "Hernia" 7 "Appendectomy" 8 "Open Cholecystectomy" ///
 9 "Other Surgery"
la val proc_cat proc_cat
tab proc_cat,missing
*/

tab index_los,missing

local compl comp_any comp_uti comp_pe comp_inf comp_rf comp_mi comp_del
la var comp_any "Any complication"
la var comp_uti "UTI"
la var comp_pe "PE"
la var comp_inf "Surgical site infection"
la var comp_rf "Respiratory failure"
la var comp_mi "MI"
la var comp_del "Delirium"
la def comp_ind 0 "No" 1 "Yes"
la val `compl' comp_ind

la var admit_ind_6m_pre "Indicator for Hospital admission 6 months pre-surgery"
la def admit_ind_6m_pre 0 "No" 1 "Yes"
la val  admit_ind_6m_pre admit_ind_6m_pre
tab admit_ind_6m_pre, missing

***************************************************
***************************************************
// Table 1 - Cohort characteristics
***************************************************
***************************************************

//First part - Patient Factors
tabout age_cat female re_cat tics_cat `comorb' srh_cat_core adl_cat_core nhres_n1 ///
	admit_ind_6m_pre using `logpath'table1a.txt, ///
c(freq col) oneway replace ///
style(tab) /*ptotal(none)*/ format(0c 1p)
//Note: this uses tabout, paste tab delimited file from text file into
//an excel spreadsheet for easy importing into a table

//Second part - hospital episode

//Table 1b Hospital Episode:
//tabout /*proc_cat*/ index_los `compl' using `logpath'table1b.txt, ///
//c(freq col) oneway replace ///
//style(tab) /*ptotal(none)*/ format(0c 1p)
mat tab_1b=J(14,2,.)
sum index_los, detail
mat tab_1b[1,1]=r(mean)
mat tab_1b[1,2]=r(p50)
mat list tab_1b

local j=2
foreach v in `compl' {
	tab `v' , missing  matcell(m_`v')
	sca s_`v'_n=r(N)
	mat m_`v'_p=m_`v'/s_`v'_n
	mat tab_1b[`j',1] = m_`v'[2,1]
	mat tab_1b[`j',2] = m_`v'_p[2,1]*100 //in percent
	local j=`j'+1
}
//discharge location code from surgery hospital stay

la def stay_dstn_cd 1 "Home" 2 "Short term general hosp for inpatient care" 3 "SNF" ///
  4 "Intermediate care facility" 5 "Another type of inst" 6"Home care hhs org." ///
  20"Expired" 50"Hospice - home" 51"Hospice - medical facility" ///
  61"Within same inst to hospital based swing bed" 62"Inpatient rehab facility" ///
  63"Long term care hosp"
la val  stay_dstn_cd stay_dstn_cd 
tab stay_dstn_cd, missing

//discharge location coded into groups
gen stay_dstn_cat=.
replace stay_dstn_cat=1 if inlist(stay_dstn_cd,1,6) //home
replace stay_dstn_cat=2 if inlist(stay_dstn_cd,3,4,63) //long term care
replace stay_dstn_cat=3 if inlist(stay_dstn_cd,62) //rehab
replace stay_dstn_cat=4 if inlist(stay_dstn_cd,50,51) //hospice
replace stay_dstn_cat=5 if inlist(stay_dstn_cd,2,5,61) //other
replace stay_dstn_cat=6 if inlist(stay_dstn_cd,20) //expired
la var stay_dstn_cat "Discharge location categorical"
la def stay_dstn_cat 1 "Home incl hha" 2"long term care incl snf" 3"IP rehab" ///
	4"Hospice" 5"Other location" 6"Expired"
la var stay_dstn_cat stay_dstn_cat
tab stay_dstn_cat stay_dstn_cd, missing

gen dis_home=.
replace dis_home=0 if inlist(stay_dstn_cat,2,3,4,5,6)
replace dis_home=1 if stay_dstn_cat==1
gen dis_ltc=.
replace dis_ltc=0 if inlist(stay_dstn_cat,1,3,4,5,6)
replace dis_ltc=1 if stay_dstn_cat==2
gen dis_rehab=.
replace dis_rehab=0 if inlist(stay_dstn_cat,1,2,4,5,6)
replace dis_rehab=1 if stay_dstn_cat==3
gen dis_hs=.
replace dis_hs=0 if inlist(stay_dstn_cat,1,2,3,5,6)
replace dis_hs=1 if stay_dstn_cat==4
gen dis_oth=.
replace dis_oth=0 if inlist(stay_dstn_cat,1,2,3,4,6)
replace dis_oth=1 if stay_dstn_cat==5
gen dis_died=.
replace dis_died=0 if inlist(stay_dstn_cat,1,2,3,4,5)
replace dis_died=1 if stay_dstn_cat==6

local disch dis_home dis_ltc dis_rehab dis_hs dis_oth dis_died

local j=9
foreach v in `disch' {
	tab `v' , missing  matcell(m_`v')
	sca s_`v'_n=r(N)
	mat m_`v'_p=m_`v'/s_`v'_n
	mat tab_1b[`j',1] = m_`v'[2,1]
	mat tab_1b[`j',2] = m_`v'_p[2,1]*100 //in percent
	local j=`j'+1
}
mat list tab_1b 

frmttable using `logpath'table1b , statmat(tab_1b) ///
	title("Table 1b - Hospital episode") ///
	ctitle("","n", "%") ///
	rtitle("LOS - mean, median" \ "Any complication"\"UTI" \ "PE" \ "Surgical site infection" ///
		\ "Respiratory failure" \ "MI" \ "Delirium" \"Home"\"Long term care facility"\"Rehab"\ ///
		"Hospice"\"Other"\"Expired") ///
	sdec(1,0 \ 0 , 2) replace

*******************************************************
*******************************************************
//Table 1c - timeline by 1 year outcome
*******************************************************
*******************************************************
//define new died variables for entire cohort
gen died_30d_full=died_30d
replace died_30d_full=0 if died_30d==.
gen died_180d_full=died_180d
replace died_180d_full=0 if died_180d==.
gen died_365d_full=died_365d
replace died_365d_full=0 if died_365d==.
//Timeline variables
tab ind_n1core, missing
tab ind_p1core, missing
la var surg_to_death_dt "Days from surgery to death"
tab died_ind, missing
la var days_surg_x "Days from surgery to exit int"
sum days_surg_x
tab ind_exit,missing

tab core_year_n1 exit_year_x, missing

tab outcome_1yr died_365d, missing

//create categorical variable for mortality timeline
gen mort_cat=.
replace mort_cat=3 if died_365d_full==1
replace mort_cat=2 if died_180d_full==1
replace mort_cat=1 if died_30d_full==1
replace mort_cat=4 if died_365d_full==0
la var mort_cat "Mortality - 30 day, 180 day and 1 year"
la def mort_cat 1 "30 day mortality" 2 "180 day mortality" 3 "365 day mortality" ///
	4 "Subject alive at 365 days", modify
la val mort_cat mort_cat
tab mort_cat, missing

//create matrix for output
mat tab_1c=J(21,4,.)
local timevars days_surg_n1core days_surg_p1core surg_to_death_dt days_surg_x

//N for each category of outcome at 1 year
tab outcome_1yr, missing matcell(samples)
sca sample_n4 = samples[3,1]
sca sample_n5 = samples[4,1]
sca sample_n1 = samples[1,1]
sca sample_n2 = samples[2,1]

mat tab_1c[1,1] =  sample_n4
mat tab_1c[6,1] =  sample_n5
mat tab_1c[11,1] =  sample_n1
mat tab_1c[16,1] =  sample_n2

local j=2	
foreach v in `timevars' {
	sum `v' if outcome_1yr==4, detail //alive and completed core w/i 1 year
	mat tab_1c[`j',1]=r(N)
	mat tab_1c[`j',2]=sample_n4 - r(N)
	mat tab_1c[`j',3]=r(p50) //median
	mat tab_1c[`j',4]=r(sd) //standard deviation
	local j=`j'+1
}
mat list tab_1c
local j=7	
foreach v in `timevars' {
	sum `v' if outcome_1yr==5, detail //alive but no core w/i 1 year
	mat tab_1c[`j',1]=r(N)
	mat tab_1c[`j',2]=sample_n5 - r(N)
	mat tab_1c[`j',3]=r(p50) //median
	mat tab_1c[`j',4]=r(sd) //standard deviation
	local j=`j'+1
}
mat list tab_1c
local j=12	
foreach v in `timevars' {
	sum `v' if outcome_1yr==1, detail //died, exit w/i 1 year
	mat tab_1c[`j',1]=r(N)
	mat tab_1c[`j',2]=sample_n1 - r(N)
	mat tab_1c[`j',3]=r(p50) //median
	mat tab_1c[`j',4]=r(sd) //standard deviation
	local j=`j'+1
}
mat list tab_1c
local j=17	
foreach v in `timevars' {
	sum `v' if outcome_1yr==2, detail //died, exit after 1 year
	mat tab_1c[`j',1]=r(N)
	mat tab_1c[`j',2]=sample_n2 - r(N)
	mat tab_1c[`j',3]=r(p50) //median
	mat tab_1c[`j',4]=r(sd) //standard deviation
	local j=`j'+1
}
mat list tab_1c

local 1clabel "Days from Baseline interview to surgery" \ "Days from Surgery to next core interview" \ ///
	"Days from Surgery to death" \ "Days from Surgery to exit interview"

frmttable using `logpath'table1b , statmat(tab_1c) ///
	title("Table 1c - Interview/Procedure Timeline") ///
	ctitle("","N","N - missing", "Median", "SD") ///
	rtitle("Alive & completed next core" \ "Days from Baseline interview to surgery" \ ///
	"Days from Surgery to next core interview" \ "Days from Surgery to death" \ ///
	"Days from Surgery to exit interview" \ ///
	"Alive, no next core" \ "Days from Baseline interview to surgery" \ ///
	"Days from Surgery to next core interview" \ "Days from Surgery to death" \ ///
	"Days from Surgery to exit interview" \ ///
	"Died, exit complete" \ "Days from Baseline interview to surgery" \ ///
	"Days from Surgery to next core interview" \ "Days from Surgery to death" \ ///
	"Days from Surgery to exit interview" \ ///
	"Died, no exit" \ "Days from Baseline interview to surgery" \ ///
	"Days from Surgery to next core interview" \ "Days from Surgery to death" \ ///
	"Days from Surgery to exit interview") ///
	sdec(0,0,1,1) addtable

*******************************************************
*******************************************************
//Frequency table for possible outcomes12 mos
*******************************************************
*******************************************************	
gen exit_1yr_ps=0
replace exit_1yr_ps=1 if (days_x_int_ps<=365 & days_x_int_ps!=.)
tab exit_1yr_ps

gen exit_2yr_ps=0
replace exit_2yr_ps=1 if (days_x_int_ps<=(2*365) & days_x_int_ps!=.)
tab exit_2yr_ps

tab core_1yr_ps	died_365d_full, missing 
tab exit_1yr_ps died_365d_full, missing 
tab exit_2yr_ps died_365d_full, missing 

gen outcome_12m_v2=.
replace outcome_12m_v2=1 if (core_1yr_ps==1 & ind_exit==0) //core w/i 1 year, no exit
replace outcome_12m_v2=2 if (core_1yr_ps==0 & ind_p1core==1 & ind_exit==0) //core after 1 yr, no exit
replace outcome_12m_v2=3 if (exit_1yr_ps==1 & ind_p1core==0 ) //exit w/i 1 year, no core
replace outcome_12m_v2=4 if (exit_1yr_ps==0 & ind_exit==1 & ind_p1core==0 ) // exit after 1 yr, no core
replace outcome_12m_v2=5 if (core_1yr_ps==1 & exit_1yr_ps==1) //core and exit w/i 12 m
replace outcome_12m_v2=6 if (core_1yr_ps==1 & ind_p1core==1 & exit_1yr_ps==0 & ind_exit==1) //core w/i 12 m, exit after 12m
replace outcome_12m_v2=7 if (core_1yr_ps==0 & ind_p1core==1 & exit_1yr_ps==0 & ind_exit==1) //core and exit after 12m
replace outcome_12m_v2=8 if (ind_p1core==0 & ind_exit==0) // no core or exit interview
la def outcome_12m_v2 1 "Core interview w/i 1 year, no exit int"  ///
	3 "Exit interview w/i 1 year, no core" 4 "Exit interview after 1 year, no core" ///
	6 "Core w/i 1 year, exit after 1 year" 8 "No post surgery interview", modify
la val outcome_12m_v2 outcome_12m_v2
la var outcome_12m_v2 "Interview timeline categories"

tab outcome_12m_v2 mort_cat, missing

la var died_365d_full "Died within 1 year"
la def ny 0 "No" 1 "Yes", modify
la val died_365d_full ny

//output to txt file
tabout outcome_12m_v2 mort_cat using `logpath'table1c_2.txt, ///
/*c(freq col freq col )*/ replace ///
style(tab) ptotal(none) format(0c)
//Note: this uses tabout, paste tab delimited file from text file into
//an excel spreadsheet for easy importing into a table

mat tab_1d=J(6,5,.)
tab outcome_12m_v2 died_30d_full if outcome_12m_v2==1
	
*******************************************************
*******************************************************
//Table 2 - unadjusted mortality rates
*******************************************************
*******************************************************
mat tab_2=J(37,7,.)

//first column - n for each subgroup
sum died_30d_full if age_cat==1 //age 65-74
mat tab_2[1,1]=r(N)
sum died_30d_full if age_cat==2 //age 75-79
mat tab_2[2,1]=r(N)
sum died_30d_full if age_cat==3 //age 80-84
mat tab_2[3,1]=r(N)
sum died_30d_full if age_cat==4 //age 85+
mat tab_2[4,1]=r(N)
sum died_30d_full if female==1 //female
mat tab_2[5,1]=r(N)
sum died_30d_full if female==0 //male
mat tab_2[6,1]=r(N)
sum died_30d_full if re_cat==1 //aa
mat tab_2[7,1]=r(N)
sum died_30d_full if re_cat==2 //hispanic
mat tab_2[8,1]=r(N)
sum died_30d_full if re_cat==3 //white
mat tab_2[9,1]=r(N)
sum died_30d_full if re_cat==4 //other
mat tab_2[10,1]=r(N)
sum died_30d_full if tics_cat==1 //tics normal
mat tab_2[11,1]=r(N)
sum died_30d_full if tics_cat==2 //tics mci
mat tab_2[12,1]=r(N)
sum died_30d_full if tics_cat==3 //tics demented
mat tab_2[13,1]=r(N)
	local k=14
	foreach w in `comorb' {  //comorbidities: cancer, chf, cad, dementia, esrd, dm
		sum died_30d_full if `w'==1
		mat tab_2[`k',1]=r(N)
		local k = `k' + 1  //populates rows 14 through 19
	}
sum died_30d_full if srh_cat_core==1 //srhs excel/vg
mat tab_2[20,1]=r(N)
sum died_30d_full if srh_cat_core==2 //srhs g
mat tab_2[21,1]=r(N)
sum died_30d_full if srh_cat_core==3 //srhs f/p
mat tab_2[22,1]=r(N)
sum died_30d_full if adl_cat_core==0 //adl ind
mat tab_2[23,1]=r(N)
sum died_30d_full if adl_cat_core==1 //adl partial dep
mat tab_2[24,1]=r(N)
sum died_30d_full if adl_cat_core==2 //adl severe dep
mat tab_2[25,1]=r(N)
sum died_30d_full if nhres_n1==1 //nh resident - yes
mat tab_2[26,1]=r(N)
sum died_30d_full if nhres_n1==0 //nh resident - no
mat tab_2[27,1]=r(N)
sum died_30d_full if admit_ind_6m_pre==1 //pre surg admit - yes
mat tab_2[28,1]=r(N)
sum died_30d_full if admit_ind_6m_pre==0 //pre surg admit - no
mat tab_2[29,1]=r(N)
	local k=30
	forvalues i=1/6 {					//discharge locations:
		sum died_30d_full if stay_dstn_cat==`i'	//home, ltc, rehab
			//hospice, other, expired
		mat tab_2[`k',1]=r(N)
		local k = `k'+1
	}
sum died_30d_full if comp_any==1 // any complication - yes
mat tab_2[36,1]=r(N)
sum died_30d_full if comp_any==0 // any complication - no
mat tab_2[37,1]=r(N)

tab died_30d_full if re_cat==4
tab died_30d_full if tics_cat==2
tab died_180d_full if tics_cat==2
tab died_30d_full if stay_dstn_cat==2
tab died_180d_full if stay_dstn_cat==2

//next columns
local j=2
foreach v in died_30d_full died_180d_full died_365d_full{
tab `v' if age_cat==1, matcell(`v'_`j') //age 65-74
mat tab_2[1,`j']=`v'_`j'[2,1]/r(N)*100
mat tab_2[1,`j'+1]=`v'_`j'[2,1]
tab `v' if age_cat==2, matcell(`v'_`j') //age 75-79
mat tab_2[2,`j']=`v'_`j'[2,1]/r(N)*100
mat tab_2[2,`j'+1]=`v'_`j'[2,1]
tab `v' if age_cat==3, matcell(`v'_`j') //age 80-84
mat tab_2[3,`j']=`v'_`j'[2,1]/r(N)*100
mat tab_2[3,`j'+1]=`v'_`j'[2,1]
tab `v' if age_cat==4, matcell(`v'_`j') //age 85+
mat tab_2[4,`j']=`v'_`j'[2,1]/r(N)*100
mat tab_2[4,`j'+1]=`v'_`j'[2,1]
tab `v' if female==1, matcell(`v'_`j') //female
mat tab_2[5,`j']=`v'_`j'[2,1]/r(N)*100
mat tab_2[5,`j'+1]=`v'_`j'[2,1]
tab `v' if female==0, matcell(`v'_`j') //male
mat tab_2[6,`j']=`v'_`j'[2,1]/r(N)*100
mat tab_2[6,`j'+1]=`v'_`j'[2,1]
tab `v' if re_cat==1, matcell(`v'_`j') //aa
mat tab_2[7,`j']=`v'_`j'[2,1]/r(N)*100
mat tab_2[7,`j'+1]=`v'_`j'[2,1]
tab `v' if re_cat==2, matcell(`v'_`j') //hispanic
mat tab_2[8,`j']=`v'_`j'[2,1]/r(N)*100
mat tab_2[8,`j'+1]=`v'_`j'[2,1]
tab `v' if re_cat==3, matcell(`v'_`j') //white
mat tab_2[9,`j']=`v'_`j'[2,1]/r(N)*100
mat tab_2[9,`j'+1]=`v'_`j'[2,1]
tab `v' if re_cat==4, matcell(`v'_`j') //other
mat tab_2[10,`j']=`v'_`j'[2,1]/r(N)*100
mat tab_2[10,`j'+1]=`v'_`j'[2,1]
tab `v' if tics_cat==1, matcell(`v'_`j') //tics normal
mat tab_2[11,`j']=`v'_`j'[2,1]/r(N)*100
mat tab_2[11,`j'+1]=`v'_`j'[2,1]
tab `v' if tics_cat==2, matcell(`v'_`j') //tics mci
mat tab_2[12,`j']=`v'_`j'[2,1]/r(N)*100
mat tab_2[12,`j'+1]=`v'_`j'[2,1]
tab `v' if tics_cat==3, matcell(`v'_`j') //tics demented
mat tab_2[13,`j']=`v'_`j'[2,1]/r(N)*100
mat tab_2[13,`j'+1]=`v'_`j'[2,1]
	local k=14
	foreach w in `comorb' {  //comorbidities: cancer, chf, cad, dementia, esrd, dm
		tab `v' if `w'==1, matcell(`v'_`j')
		mat tab_2[`k',`j']=`v'_`j'[2,1]/r(N)*100
		mat tab_2[`k',`j'+1]=`v'_`j'[2,1]
		local k = `k' + 1  //populates rows 14 through 19
	}
tab `v' if srh_cat_core==1, matcell(`v'_`j') //srhs excel/vg
mat tab_2[20,`j']=`v'_`j'[2,1]/r(N)*100
mat tab_2[20,`j'+1]=`v'_`j'[2,1]
tab `v' if srh_cat_core==2, matcell(`v'_`j') //srhs g
mat tab_2[21,`j']=`v'_`j'[2,1]/r(N)*100
mat tab_2[21,`j'+1]=`v'_`j'[2,1]
tab `v' if srh_cat_core==3, matcell(`v'_`j') //srhs f/p
mat tab_2[22,`j']=`v'_`j'[2,1]/r(N)*100
mat tab_2[22,`j'+1]=`v'_`j'[2,1]
tab `v' if adl_cat_core==0, matcell(`v'_`j') //adl ind
mat tab_2[23,`j']=`v'_`j'[2,1]/r(N)*100
mat tab_2[23,`j'+1]=`v'_`j'[2,1]
tab `v' if adl_cat_core==1, matcell(`v'_`j') //adl partial dep
mat tab_2[24,`j']=`v'_`j'[2,1]/r(N)*100
mat tab_2[24,`j'+1]=`v'_`j'[2,1]
tab `v' if adl_cat_core==2, matcell(`v'_`j') //adl severe dep
mat tab_2[25,`j']=`v'_`j'[2,1]/r(N)*100
mat tab_2[25,`j'+1]=`v'_`j'[2,1]
tab `v' if nhres_n1==1, matcell(`v'_`j') //nh resident - yes
mat tab_2[26,`j']=`v'_`j'[2,1]/r(N)*100
mat tab_2[26,`j'+1]=`v'_`j'[2,1]
tab `v' if nhres_n1==0, matcell(`v'_`j') //nh resident - no
mat tab_2[27,`j']=`v'_`j'[2,1]/r(N)*100
mat tab_2[27,`j'+1]=`v'_`j'[2,1]
tab `v' if admit_ind_6m_pre==1, matcell(`v'_`j') //pre surg admit - yes
mat tab_2[28,`j']=`v'_`j'[2,1]/r(N)*100
mat tab_2[28,`j'+1]=`v'_`j'[2,1]
tab `v' if admit_ind_6m_pre==0, matcell(`v'_`j') //pre surg admit - no
mat tab_2[29,`j']=`v'_`j'[2,1]/r(N)*100
mat tab_2[29,`j'+1]=`v'_`j'[2,1]
	local k=30
	forvalues i=1/6 {					//discharge locations:
		tab `v' if stay_dstn_cat==`i', matcell(`v'_`j')	//home, ltc, rehab
		mat tab_2[`k',`j']=`v'_`j'[2,1]/r(N)*100			//hospice, other, expired
		mat tab_2[`k',`j'+1]=`v'_`j'[2,1]
		local k = `k'+1
	}
tab `v' if comp_any==1, matcell(`v'_`j') // any complication - yes
mat tab_2[36,`j']=`v'_`j'[2,1]/r(N)*100
mat tab_2[36,`j'+1]=`v'_`j'[2,1]
tab `v' if comp_any==0, matcell(`v'_`j') // any complication - no
mat tab_2[37,`j']=`v'_`j'[2,1]/r(N)*100
mat tab_2[37,`j'+1]=`v'_`j'[2,1]
local j = `j' + 2
}
mat list tab_2
mat tab_2 = tab_2
frmttable using `logpath'table1b , statmat(tab_2) ///
	title("Table 2 - Unadjusted 30-, 180- and 365-Day Mortality") ///
	ctitle("","N","30-Day %","n","180-Day %","n", "365-Day %","n") ///
	rtitle("Age: 65-74" \ "75-79" \ "80-84" \ "85+" \ ///
	"Female" \ "Male"\ "AA" \ "Hispanic" \ "White" \"Other" \ ///
	"TICS >8 Normal" \"5-8 MCI" \"<5 Demented"\"Cancer" \"CHF" \ ///
	"CAD"\"Dementia"\"ESRD"\"Diabetes"\"Self reported health: Exc / VG" \ ///
	"Good" \ "Fair/Poor" \ "Baseline ADL: Independent" \ "Partial" \ "Severe" \  ///
	"Nursing home resident - Yes" \ "No" \ "Hospital admit in prior 6 mos: Yes" \ "No" \ ///
	"Discharge location: Home" \ "Long term care" \ "Inpatient rehab" \"Hospice" \  ///
	"Other" \ "Expired" \ "Any complication: Yes" \ "No") ///
	sdec(0,2,0,2,0,2,0) addtable

/*tabulate age_cat died_30d, chi2 matcell(m_age30)
mat list m_age30
//calculate individual contribution chisq
/*sca E_12 = 

tabi age_cat died_30, chi2
display r(p)

local pval=chi2tail(n,t) n = dof, t=test statistic
or chiprob
*/
*/

******************************************************************
******************************************************************
// Tables to compare comorbidity / chronic conditions measures
******************************************************************
******************************************************************
local hcc cc_1_ami_n12mn0 cc_2_alzh_n12mn0 cc_3_alzhdmta_n12mn0 ///
cc_4_atrialfb_n12mn0 cc_5_cataract_n12mn0 cc_6_chrnkidn_n12mn0 ///
cc_7_copd_n12mn0 cc_8_chf_n12mn0 cc_9_diabetes_n12mn0 cc_10_glaucoma_n12mn0 ///
cc_11_hipfrac_n12mn0 cc_12_ischmcht_n12mn0 cc_13_depressn_n12mn0 ///
cc_14_osteoprs_n12mn0 cc_15_ra_oa_n12mn0 cc_16_strketia_n12mn0 ///
cc_17_cncrbrst_n12mn0 cc_18_cncrclrc_n12mn0 cc_19_cncrprst_n12mn0 ///
cc_20_cncrlung_n12mn0 cc_21_cncrendm_n12mn0 cc_ami_isch_n12mn0 ///
cc_alzheim_n12mn0 cc_cncr_chronic_n12mn0

local elix comorb_1_0_n12m comorb_2_0_n12m comorb_3_0_n12m comorb_4_0_n12m ///
comorb_5_0_n12m comorb_6_0_n12m comorb_7_0_n12m comorb_8_0_n12m ///
comorb_9_0_n12m comorb_10_0_n12m comorb_11_0_n12m comorb_12_0_n12m ///
comorb_13_0_n12m comorb_14_0_n12m comorb_15_0_n12m comorb_16_0_n12m ///
comorb_17_0_n12m comorb_18_0_n12m comorb_19_0_n12m comorb_20_0_n12m ///
comorb_21_0_n12m comorb_22_0_n12m comorb_23_0_n12m comorb_24_0_n12m ///
comorb_25_0_n12m comorb_26_0_n12m comorb_27_0_n12m comorb_28_0_n12m ///
comorb_29_0_n12m comorb_30_0_n12m

mat hcc_mean=J(24,2,.)
local i=1
foreach v in `hcc'{
sum `v'
mat hcc_mean[`i',1]=r(mean)
mat hcc_mean[`i',2]=r(N)
local i=`i'+1
}

mat rownames hcc_mean ="AMI" "Alzheimer's" "Alzheimer's or Dementia" "Atrial Fibrillation" ///
"Cataract" "Chronic Kidney Disease" ///
"COPD" "CHF" "Diabetes" "Glaucoma" "Hip fracture" "Ischemic Heart Disease" "Depression" ///
"Osteoporosis" "Rheumatoid Arthritis" "Stroke" "Cancer - Breast" "Cancer - Colorectal" "Cancer - Prostate" ///
"Cancer - Lung" "Cancer - Endometrial" "AMI+ISCH" "Alzh + Dementia" "Cancer - any"


mat el_mean=J(30,2,.)
local i=1
foreach v in `elix'{
sum `v'
mat el_mean[`i',1]=r(mean)
mat el_mean[`i',2]=r(N)
local i=`i'+1
}

mat rownames el_mean = "Congestive Heart Failure" "Cariac Arrhythmias" "Valvular Disease" ///
"Pulmonary Circulation Disorders" "Peripheral Vascular Disorders" "Hypertension" ///
 "Paralysis" "Other Neurological Disorders" "Chronic Pulmonary Disease" "Diabetes, uncomplicated" ///
 "Diabetes, complicated" "Hypothyroidism" "Renal Failure" "Liver Disease" ///
 "Peptic Ulcer Disease" "AIDS" "Lymphoma" "Metastatic Cancer" ///
 "Solid Tumor without Metastisis" "Rheumatoid Arthritis" ///
 "Coagulopathy" "Obesity" "Weight Loss" "Fluid and Electrolyte Disorders" ///
 "Blood Loss Anemia" "Deficiency Anemias" "Alcohol Abuse" "Drug Abuse" "Psychoses" "Depression"

mat list hcc_mean
mat list el_mean

	
frmttable using `logpath'cc_elix, statmat(hcc_mean) ///
title("Chronic conditions") ctitle("","Mean","N") ///
sdec(2,0) replace
 
frmttable using `logpath'cc_elix, statmat(hcc_mean) ///
title("Elixhauser comorbidities") ctitle("","Mean","N") ///
sdec(2,0) addtable 
 
tab claims_esrd_ind comorb_13_0_n12m, missing
 
log close

//looking at date of death

//11 obs have exit interview but missing date of death
 tab died_ind ind_exit, missing
 
 gen dod_to_exit = (  e_ivw_date_x - death_date_e)
 tab dod_to_exit if(died_ind==1), missing //all exit interviews are at least after date of death
 //there are a few though with exit interviews more than 1000 days after death
