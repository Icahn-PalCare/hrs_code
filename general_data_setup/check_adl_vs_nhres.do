//local logpath C:\HRS\hrs_cleaned\logs
clear all
set more off
set mem 500m

local logpath C:\HRS\hrs_cleaned\logs
local datapath C:\HRS\hrs_cleaned\working

cd `datapath'

use core_98_10_nw_tics.dta

tab adl_independent_core, missing
tab nhres, missing
tab core_year, missing

mat adl_nh=J(10,2,0)
tab nhres, missing matcell(nh1)
mat adl_nh[1,1]=nh1[2,1] //nh residents

tab adl_independent_core if nhres==1, missing matcell(m1)
mat adl_nh[2,1]=m1[1,1] //adl dependent (expect most to be adl dependent)
mat adl_nh[2,2]=m1[1,1]/adl_nh[1,1]*100
mat adl_nh[3,1]=m1[2,1] //adl independent
mat adl_nh[3,2]=m1[2,1]/adl_nh[1,1]*100
mat adl_nh[4,1]=m1[3,1] //adl status missing
mat adl_nh[4,2]=m1[3,1]/adl_nh[1,1]*100

//look at those nursing home resident that are adl independent, why?
tab adl_core_check if nhres==1 & adl_independent_core==1, matcell(m2)
mat adl_nh[5,1]=m2[1,1] //flag for high level function=0
mat adl_nh[5,2]=m2[1,1]/adl_nh[3,1]*100
tab adl_core_check adl_diff_dr  if nhres==1 & adl_independent_core==1, matcell(m3)
mat adl_nh[6,1]=m3[2,1] //flag for high level function=1 and no difficulty dressing
mat adl_nh[6,2]=m3[2,1]/adl_nh[3,1]*100

//rest answered all adl questions as do not receive help with the task
mat adl_nh[7,1]=adl_nh[3,1]-adl_nh[5,1]-adl_nh[6,1]
mat adl_nh[7,2]=adl_nh[7,1]/adl_nh[3,1]*100

tab adl_dr_core if nhres==1 & adl_core_check~=0
tab adl_wk_core if  nhres==1 & (adl_core_check~=0 | (adl_core_check==1 & adl_diff_dr~=1))
tab adl_bh_core if  nhres==1 & (adl_core_check~=0 | (adl_core_check==1 & adl_diff_dr~=1))
tab adl_e_core if  nhres==1 & (adl_core_check~=0 | (adl_core_check==1 & adl_diff_dr~=1))
tab adl_tx_core if  nhres==1 & (adl_core_check~=0 | (adl_core_check==1 & adl_diff_dr~=1))
tab adl_t_core if  nhres==1 & (adl_core_check~=0 | (adl_core_check==1 & adl_diff_dr~=1))

tab adl_index_core if nhres==1

tab iadl_independent_core if nhres==1, missing matcell(m4)
mat adl_nh[8,1]=m4[1,1] //iadl dependent
mat adl_nh[8,2]=m4[1,1]/adl_nh[1,1]*100
mat adl_nh[10,1]=m4[2,1] //iadl status missing
mat adl_nh[10,2]=m4[2,1]/adl_nh[1,1]*100


mat list adl_nh

mat rownames adl_nh="Nursing home res at time of ivw" "ADL Dependent" ///
"ADL Independent" "ADL status missing" "ADL screen count=0" ///
"ADL screen=1 & No diff dress" "Ans no help recieved all ADL ?s" ///
"IADL Dependent" "IADL Independent" "IADL Status missing"

frmttable using "`logpath'\adl_nhres", statmat(adl_nh) ///
title("ADL status for NH Residents") ///
ctitles("","n","percent") ///
sdec(0,2) replace


