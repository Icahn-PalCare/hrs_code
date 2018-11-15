use "E:\data\solo_spouses\int_data\r_s_core_x_e.dta", clear 

gen spouse_hlp = 0 if n_s==0 & s_hhidpn_n1!=. // helper, no spouse
replace spouse_hlp = 1 if n_hp==1 & n_s==1 // spouse solo helper
replace spouse_hlp = 2 if n_hp>1 & n_hp!=. & n_s==1 // spouse non-solo hlp

la define spouselbl 0"helper, no spouse"1"Spouse solo helper"2"spouse non-solo"
la values spouse_hlp spouselbl

keep if s_hhidpn_n1!=.


/* Decedent Characterisitcs 

*get death year from exit to calculate decedent age

cap drop _m

merge 1:1 r_hhidpn_n1 r_bid_hrs using "E:\data\hrs_cleaned\death_date_2012.dta"

drop if _m==2
drop _m

merge 1:1 r_hhidpn_n1 using "E:\data\YN295\int_data\death_2014.dta" 

append using appendlater.dta

save , replace

list of vars for table 1:

* respondent 

age_death 

r_srh_pf_n1 r_nhres_n1 r_dexp_x r_location_x r_adl_dependence_core_n1
r_demalz_core_n1 r_female_n1 r_white_e r_networth_adj2012_n1

r_comor_in_hrs_n1


* spouse

s_age_death s_age_ivw_n1 
s_srh_pf_n1 s_female_n1 s_cesd_tot_n1 s_cesd_tot_ge3_n1
s_networth_adj2012_n1

s_comor_in_hrs_n1 s_time_exit_n1

local r_vars1 r_age_death r_networth_adj2012_n1 r_comor_in_hrs_n1
local r_vars2 r_srh_pf_n1 r_nhres_n1 r_dexp_x r_location_x r_adl_dependence_core_n1 //
r_demalz_core_n1 r_female_n1 r_white_e

local s_vars1 s_age_death s_age_ivw_n1 s_comor_in_hrs_n1 s_time_exit_n1 s_networth_adj2012_n1 s_cesd_tot_n1
local s_vars2 s_cesd_tot_ge3_n1 s_srh_pf_n1 s_female_n1
*/





gen r_age_death = (r_death_date_e - r_birth_date_e)/365.25

recast int r_age_death, force

label var r_age_death "R age at death"

gen r_adl_dependence_core_n1 = 0 if r_adl_independent_core_n1!=.
replace r_adl_dependence_core_n1 = 1 if r_adl_independent_core_n1==0

gen r_demalz_core_n1 = 0 if r_dem_hrs_n1!=. | r_alz_hrs_n1!=.
replace r_demalz_core_n1 = 1 if r_dem_hrs_n1==1 | r_alz_hrs_n1==1
label var r_demalz_core_n1 "Dementia/Alzheimer's at N1"
label var r_adl_dependence_core_n1 "ADL dependent at N1"

gen r_nonwhite_e = 0 if r_white_e!=.
replace r_nonwhite_e =1 if r_white_e==0

gen s_age_death = (r_death_date_e - s_birth_date_e)/365.25
recast int s_age_death, force
label var s_age_death "Spouse age at death"

gen s_age_ivw_n1 = (s_c_ivw_date_n1 - s_birth_date_e)/365.25
recast int s_age_ivw_n1, force
label var s_age_ivw_n1 "Spouse age at N1"

cap drop s_time_exit_n1
gen s_time_exit_n1 = (r_e_ivw_date_x - s_c_ivw_date_n1)/30.4
recast int s_time_exit_n1, force
label var s_time_exit_n1 "Months between Exit & N1, Spouse"



*preserve

replace spouse_hlp = 0 if spouse_hlp==.

gen spouse2 = 0 if spouse_hlp==1
replace spouse2 = 1 if spouse_hlp==2

keep if s_hhidpn_n1!=. & s_c_ivw_date_n1!=. //& r_nhres_n1==0
replace spouse_hlp = 0 if spouse_hlp==.

cap drop _m
merge 1:1 r_hhidpn_n1 r_core_year_n1 using "E:\data\solo_spouses\int_data\core_child.dta", keepus(child_10)
drop if _m==2

replace child_10 = 0 if child_10==.

gen r_anychild_n1 = 0
replace r_anychild_n1 = 1 if child_10==1 | r_reschil_d_n1


gen r_time_death_n1 = (r_death_date_e - r_c_ivw_date_n1)/30.4
label var r_time_death_n1 "Months between Death and N1, R"

gen s_time_death_n1 = (r_death_date_e - s_c_ivw_date_n1)/30.4
label var s_time_death_n1 "Months between Death and N1, Spouse"

gen death_yr = year(r_death_date_e)

gen r_loc_nh_x = 0
replace r_loc_nh_x = 1 if r_location_x==2

gen r_loc_home_x = 0
replace r_loc_home_x = 1 if r_location_x==3

gen r_loc_hospice_x = 0
replace r_loc_hospice_x = 1 if r_location_x==4

gen r_loc_assist_x = 0
replace r_loc_assist_x = 1 if  r_location_x==5

gen r_loc_other_x = 0
replace r_loc_other_x = 1 if r_location_x==6



*preserve
*keep if r_nhres_x==0
gen female = 0 if s_female_n1!=. | s_female_n2!=. | s_female_x!=.
replace female = 1 if s_female_n1==1 | s_female_n2==1 | s_female_x==1
*keep if female==0

label var r_loc_hosp_x "Respondent Died in Hospital"
label var s_cesd_tot_p1 "Total CESD Count at P1"
label var s_cesd_tot_ge3_p1 "CESD Count 3+ at P1" 
label var r_nhres_x "Nursing Home Resident at Exit"
label var r_iadl_ind_x "Number of R ADLs, Exit"
label var r_adl_index_core_n1 "Number of R ADLs, Core"
label var child_10 "Non-Resident Children living within 10 miles, R N1"
label var r_reschil_d_n1 "Living with Children, R N1"
label var r_anychild_n1 "Children within 10 miles Resident or non-Resident, R N1"
label var r_loc_nh_x "Respondent Died in Nursing Home"
label var r_loc_home_x "Respondent Died at Home"
label var r_loc_hospice_x "Respondent Died at Hospice"
label var r_loc_assist_x "Respondent Died in Assisted Living"
label var r_loc_other_x "Respondent Died in Other Location"

/********************************/

cd "E:\projects\solo_spouses\archive_logs"

foreach y of varlist r_cod_other r_cod_heart r_cod_dem r_cod_cancer {

preserve
keep if `y'==1


local r_vars1 r_age_death r_networth_adj2012_n1 r_comor_in_hrs_n1
local r_vars2 r_srh_pf_n1 r_nhres_n1 r_dexp_x r_hospice_x r_loc_hosp_x r_loc_nh_x r_loc_home_x r_loc_hospice_x r_loc_assist_x r_loc_other_x r_adl_dependence_core_n1 r_demalz_core_n1 r_female_n1 r_white_e child_10 r_reschil_d_n1 r_anychild_n1

local s_vars1 s_age_death s_age_ivw_n1 s_comor_in_hrs_n1 s_time_exit_n1 s_time_death_n1 s_networth_adj2012_n1 s_cesd_tot_n1 s_cesd_tot_p1
local s_vars2 s_cesd_tot_ge3_n1 s_cesd_tot_ge3_p1 s_srh_pf_n1 s_srh_pf_p1 s_female_n1


local rd: word count 1 `r_vars1' `r_vars2' 1 `s_vars1' `s_vars2' 1

mat tab1=J(`rd',3,.)
mat stars=J(`rd',3,0)

local r = 2

foreach x of local r_vars1 {

sum `x' if spouse_hlp==0
mat tab1[`r',1]=r(mean)

sum `x' if spouse_hlp==1
mat tab1[`r',2]=r(mean)

sum `x' if spouse_hlp==2
mat tab1[`r',3]=r(mean)

ttest `x', by(spouse2)
mat stars[`r',3]=(r(p)<.01) + (r(p)<.05)

local ++r
}

foreach x of local r_vars2 {

sum `x' if spouse_hlp==0
mat tab1[`r',1]=r(mean)*100

sum `x' if spouse_hlp==1
mat tab1[`r',2]=r(mean)*100

sum `x' if spouse_hlp==2
mat tab1[`r',3]=r(mean)*100

tab `x' spouse2, chi2
mat stars[`r',3]=(r(p)<.01) + (r(p)<.05)

local ++r
}

local ++r

foreach x of local s_vars1 {

sum `x' if spouse_hlp==0
mat tab1[`r',1]=r(mean)

sum `x' if spouse_hlp==1
mat tab1[`r',2]=r(mean)

sum `x' if spouse_hlp==2
mat tab1[`r',3]=r(mean)

ttest `x', by(spouse2)
mat stars[`r',3]=(r(p)<.01) + (r(p)<.05)

local ++r
}

foreach x of local s_vars2 {

sum `x' if spouse_hlp==0
mat tab1[`r',1]=r(mean)*100

sum `x' if spouse_hlp==1
mat tab1[`r',2]=r(mean)*100

sum `x' if spouse_hlp==2
mat tab1[`r',3]=r(mean)*100

tab `x' spouse2, chi2
mat stars[`r',3]=(r(p)<.01) + (r(p)<.05)

local ++r
}

sum spouse_hlp if spouse_hlp==0
mat tab1[`r',1]=r(N)

sum spouse_hlp if spouse_hlp==1
mat tab1[`r',2]=r(N)

sum spouse_hlp if spouse_hlp==2
mat tab1[`r',3]=r(N)

mat rownames tab1= "Decedent" `r_vars1' `r_vars2' "Spouse" `s_vars1' `s_vars2' "Sample Size"

mat list tab1

/*
frmttable using "E:\projects\solo_spouses\archive_logs\table1_fullsample.doc", replace statmat(tab1) ///
varlabels title("Summary Statistics: HRS couples with a Deceased Spouse as of Exit 2014") ctitles("Variables" "Non-Helping Spouse" "Spouse Helper, Solo" "Spouse Helper, Non-Solo") sdec(2) annotate(stars) asymbol(*,**) ///
note("Sig test is Solo Spouse vs Non-Solo Spouse: *p<0.05, **p<0.01")
*/

frmttable using table1_`y'.doc, replace statmat(tab1) ///
varlabels title("`y': HRS couples with a Deceased Spouse as of Exit 2014") ctitles("Variables" "Non-Helping Spouse" "Spouse Helper, Solo" "Spouse Helper, Non-Solo") sdec(2) annotate(stars) asymbol(*,**) ///
note("Sig test is Solo Spouse vs Non-Solo Spouse: *p<0.05, **p<0.01")
restore
}


/*
frmttable using "E:\projects\solo_spouses\archive_logs\table1_nonnursing.doc", replace statmat(tab1) ///
varlabels title("Summary Statistics: HRS couples with a Deceased Spouse as of Exit 2014") ctitles("Variables" "Non-Helping Spouse" "Spouse Helper, Solo" "Spouse Helper, Non-Solo") sdec(2) annotate(stars) asymbol(*,**) ///
note("Sig test is Solo Spouse vs Non-Solo Spouse: *p<0.05, **p<0.01")
*/
