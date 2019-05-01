*making dataset

*1: adding death dates to core file
use "E:\data\hrs_cleaned\core_00_to_14.dta" 

merge m:1 id using "E:\data\hrs_cleaned\death_date_2015.dta", keepusing (death_all)
keep if _merge==3

gen days_ivw_death= death_all-c_ivw_date
gen mnths_ivw_death= ceil(days_ivw_death/30)
replace mnths_ivw_death=. if mnths_ivw_death<0

*make a variable for least months to death for each person
egen minttd=min(mnths_ivw_death), by(id)
keep if minttd==mnths_ivw_death
tab mnths_ivw_death
replace mnths_ivw_death=1 if mnths_ivw_death==0

*CESD by months
tabstat cesd_tot if mnths_ivw_death<13, by(mnths_ivw_death) stat (mean sd)
regress cesd_tot i.mnths_ivw_death if mnths_ivw_death<25
margins mnths_ivw_death
marginsplot


*depressed in last week by months
regress cesd1 i.mnths_ivw_death if mnths_ivw_death<25
margins mnths_ivw_death
marginsplot

*was not happy in last week by months
regress cesd4 i.mnths_ivw_death if mnths_ivw_death<25
margins mnths_ivw_death
marginsplot

*was lonely in last week by months
regress cesd5 i.mnths_ivw_death if mnths_ivw_death<25
margins mnths_ivw_death
marginsplot

*did not enjoy life in last week by months
regress cesd6 i.mnths_ivw_death if mnths_ivw_death<25
margins mnths_ivw_death
marginsplot

*sad in last week by months
regress cesd7 i.mnths_ivw_death if mnths_ivw_death<25
margins mnths_ivw_death
marginsplot
