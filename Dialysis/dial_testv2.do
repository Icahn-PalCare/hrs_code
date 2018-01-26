use "E:\data\Dialysis\Int_data\survival_283.dta", clear
cap drop admit_date age part_ab_1y hmo_d_1y
merge 1:1 bid_hrs using "E:\data\Dialysis\Int_data\index_datev2.dta"
keep if _m==3

format admit_date %td
drop mortality

gen mortality = death_all - admit_date

gen days = index_date - admit_date

gen ivdiff = days - n1_to_dial if days!=0

gen d1yr = 0
replace d1yr = 1 if mortality<=365
