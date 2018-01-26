local insvars MC_HMO  MC_B  MC_D  private_medigap long_term_care

use `t1', clear
sum dif
keep if dif>5000 & inrange(year,2000,2010)
tab dif
gen id=HHID+PN
sum `insvars' if id=="014092040"
append using "E:\data\hrs_oop_2010\received_data\2012\oopme_final_2012.dta"
gen old=_n>48
append using $savedir\oopme_final.dta,
gen new=missing(old) if old
tab new
tab new
by HHID PN year, sort: keep if _N==3
sum `insvars' if id=="014092040" & old==1
sum `insvars' if id=="014092040" & new==1
sum `insvars'
tab old
tab id if id=="014092040"
tab new
tab oldoop if id=="014092040"
tab newoop if id=="014092040"
replace id=HHID+PN if missing(id)
sum `insvars' if id=="014092040" & old==1
sum `insvars' if id=="014092040" & new==1
sum dif
di 49991*20/12
sum `insvars' if  old==1
sum `insvars' if new==1
replace dif=floor(newoop-oldoop)
sum dif,d
sum `insvars' if old & dif<0
sum `insvars' if old==1 & dif<0
sort id year
by id: carryforward dif, replace
sort id year dif
by id: carryforward dif, replace
sum dif
sum `insvars' if old & dif<0
sum `insvars' if old==1 & dif<0
sum `insvars' if new==1 & dif<0
sum `insvars' if old==1 & dif<0
drop if old==0 & new==0
drop if old==0 & missing(new)
sum `insvars' if new==1 & dif>0
sum `insvars' if old==1 & dif>0
tab year
tab dif if year==2010
sum `insvars' if old & year=2010
sum `insvars' if old & year==2010
sum `insvars' if !old & year==2010
sum `insvars' if new==1 & year==2010
sum `insvars' if old==1 & year==2010
levelsof id if year==2010, local(levels)
