//look at regional medicare spending quintiles, atlas data 2010

clear all
set more off

local atlasdatapath H:\OOP\notes

insheet using "`atlasdatapath'\Atlas_Total Medicare Reimbursements per Enrollee, by Adjustment Type.csv"

rename data mc_spend_per_bene

//calculate quintiles
centile mc_spend_per_bene, centile(20(20)80)
sca qui_20=r(c_1)
sca qui_40=r(c_2)
sca qui_60=r(c_3)
sca qui_80=r(c_4) 

gen quintile_mc=.
replace quintile_mc=1 if mc_spend_per_bene<qui_20 & mc_spend_per_bene<.
replace quintile_mc=2 if mc_spend_per_bene>=qui_20 & mc_spend_per_bene<=qui_40
replace quintile_mc=3 if mc_spend_per_bene>qui_40 & mc_spend_per_bene<qui_60
replace quintile_mc=4 if mc_spend_per_bene>=qui_60 & mc_spend_per_bene<qui_80
replace quintile_mc=5 if mc_spend_per_bene>=qui_80 & mc_spend_per_bene<.
tab quintile_mc, missing
la var quintile_mc "Quintiles of HRR-level Medicare Spending (Atlas)"
la def quint 1 "Quintile 1 (Lowest)" 2 "2" 3 "3" 4 "4" 5 "5 (Highest)"
la val quintile_mc quint

sum mc_spend_per_bene if quintile_mc==1, detail
sum mc_spend_per_bene if quintile_mc==2, detail
sum mc_spend_per_bene if quintile_mc==3, detail
sum mc_spend_per_bene if quintile_mc==4, detail
sum mc_spend_per_bene if quintile_mc==5, detail
