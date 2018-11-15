
scalar drop _all
do load_cpi

********************************************************************************

use $savedir/exit_all.dta, clear
drop if P==1 //appended private medigap data
merge 1:1 HHID PN year using $savedir/exit_use.dta, nogen keepusing(hospital_nights nh_nights dr_visits hospice_nights qtile_*)

*share variables used in imputing home/special and dr/dental/outpatient in 1996-2000

*using 2002-2010 data, where a respondent reports non-missing home and special spending, we compute the share accounted for by each.

gen home_shr    = home_all    / (home_all + special_all)
gen special_shr = special_all / (home_all + special_all)

qui summ home_shr
scalar home_shr = r(mean)
drop home_shr

qui summ special_shr
scalar special_shr = r(mean)
drop special_shr

est clear

gen hospital_per = hospital_all / hospital_nights
reg hospital_per i.qtile_hospital
est store hospital

gen nh_per = nursing_home_all / nh_nights
reg nh_per i.qtile_nh
est store NH

gen doctor_per = doctor_all / dr_visits
reg doctor_per i.qtile_doctor
est store doctor

//gen hospice_per = hospice_all / hospice_nights
//reg hospice_per i.qtile_hospice
//est store hospice

********************************************************************************

use $savedir/exit1995_oopi1.dta, clear
merge 1:1 HHID PN using $savedir/exit1995_use.dta, nogen keepusing(hospital_nights nh_nights dr_visits qtile_*)

scalar z = cpi1995 / cpiBASE

*if amount missing, expenses=YES:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (N5314 == 1)

*if amount missing, expenses=NO:
replace MC_HMO = 0 if (MC_HMO == .) & (N5314 == 5)

*if amount missing, expenses=DK/NA/RF:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (N5314 == 8 | N5314 == 9)

//No LTC premiums in this wave

qui summ private_medigap_1
replace private_medigap_1 = r(mean) if missing(private_medigap_1) & N5339==1 & (N5342!=2)	//if has insurance, premium not paid entirely by employer/union

replace private_medigap_1 = 0 if missing(private_medigap_1) & (N5339==5 | N5342==2)		//if no insurance, of premium entirely paid

qui summ private_medigap_2
replace private_medigap_2 = r(mean) if missing(private_medigap_2) & N5339==1 & N5340>=2 & N5363!=2	//if has insurance, #plans >=2, not fully paid

replace private_medigap_2 = 0 if missing(private_medigap_2) & (N5339==5 | N5340==1 | N5363==2)	//if no insurance, only 1 plan, or fully paid

egen private_medigap = rowtotal( private_medigap_1 ///
								 private_medigap_2 ) , missing

qui summ private_medigap
replace private_medigap = r(mean) if missing(private_medigap) & (N5339==8 | N5339==9)	//if unsure of whether has insurance

/*** hospital imputations ***/

gen hospital_OOP = .

*all reported spending is hospital spending IF:
*(1) R reports hospital utilization [ died in hospital (N226==1) OR patient overnight in hospital (N1664==1)] AND
*(2) Hospital expenses NOT fully covered [ (N1672!=1) ] AND either
*(3a) R reports no NH utilization [ did not die in NH (N226!=2) AND was not patient overnight in NH (N1681!=1) AND did not live in NH (N249!=1) ] OR
*(3b) NH expenses not fully covered by insurance [ (N1686==1) ]

replace hospital_OOP = hospital_NH_OOP if ((N226==1 | N1664==1) & N1672!=1) & ((N1681==5 & N249!=1 & N226!=2) | N1686==1)

*cap at 15000*z*months
replace hospital_OOP = min( 15000*z*months , hospital_OOP ) if !missing(hospital_OOP)

*impute with nights spent in NH where possible if expenses were not fully covered
est restore hospital
predict x, xb
tab x qtile_hospital
replace hospital_OOP = z * x * hospital_nights if hospital_OOP == . & (N226==1 | N1664==1) & (N1672!=1)
drop x

*if amount missing, and there are expenses that are known to be not fully covered, and nights not available:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if hospital_OOP == . & (N226==1 | N1664==1) & (N1672==3 | N1672==5)

*if amount missing, and expenses ARE fully covered:
replace hospital_OOP = 0 if (hospital_OOP==.) & (N1672==1)

*if expenses==YES, amount missing, and coverage of expenses is DK/RF/NA, 
*costs are unsettled (==7), or missing (interviewee should have been asked but was not):
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & (N226==1 | N1664==1) & (N1672==7 | N1672==8 | N1672==9 | N1672==.)

*if amount missing and did not spend night in hospital:
replace hospital_OOP = 0 if (hospital_OOP==.) & (N1664==5)

*if utilization is DK/NA/RF and amount missing:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & (N1664==8 | N1664==9)

/*** NH imputations ***/

gen NH_OOP = .

*all reported spending is NH spending IF:
*(1) R reports NH utilization [ died in NH (N226==2) OR was patient overnight in NH (N1681==1) OR lived in NH (N249==1) ] AND 
*(2) These expenses were not fully covered by insurance [ (N1686!=1) ] AND either
*(3a) No hospital utilization [ did not die in hospital (N226!=1) AND not a patient overnight in hospital (N1664!=1)] OR
*(3b) Hospital expenses fully covered [ (N1672==1) ]

replace NH_OOP = hospital_NH_OOP if ((N1681==1 | N249==1 | N226==2) & N1686!=1) & ((N1664==5 & N226!=1) | N1672==1)

*cap at 15000*z*months
replace NH_OOP = min( 15000*z*months , NH_OOP ) if !missing(NH_OOP)

*impute with nights spent in NH where possible if expenses were not fully covered
est restore NH
predict x, xb
tab x qtile_nh
replace NH_OOP = z * x * nh_nights if (NH_OOP==.) & (N1681==1 | N249==1 | N226==2) & (N1686!=1)
drop x

*if amount missing, and there are expenses that are not fully covered, and nights not available:
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & (N1681==1 | N249==1 | N226==2) & (N1686==3 | N1686==5)

*if amount missing, and expenses ARE fully covered:
replace NH_OOP = 0 if (NH_OOP==.) & (N1686==1)

*if expenses==YES, amount missing, and coverage of expenses is DK/RF/NA, 
*costs are unsettled (==7), or missing (interviewee should have been asked but was not):
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & (N1681==1 | N249==1 | N226==2) & (N1686==7 | N1686==8 | N1686==9 | N1686==.)

*if amount missing and did not spend night in NH (and didnt live in NH) or hospital:
replace NH_OOP = 0 if NH_OOP==. & (N1681==5 & N249!=1 & N226!=2)						

*if didn't live in NH, overnight stay is DK/NA/RF and amount missing:
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & (N249!=1 & N226!=2) & (N1681==8 | N1681==9)

/*** hospital plus NH ***/

*summing our independent imputations for hospital and NH:
egen hospital_NH_OOP_imputed = rowtotal( hospital_OOP NH_OOP ), missing

*re-scaling where an original sum is available in the data or where one has been imputed using brackets and our imputed sum is not equal to zero:
replace hospital_OOP = hospital_OOP * (hospital_NH_OOP / hospital_NH_OOP_imputed) if !missing(hospital_NH_OOP) & hospital_NH_OOP_imputed != 0
replace NH_OOP = NH_OOP * (hospital_NH_OOP / hospital_NH_OOP_imputed) if !missing(hospital_NH_OOP) & hospital_NH_OOP_imputed != 0

*fill in missing values of the original variable (where brackets were not available) with the sum of imputed hospital and NH spending.
replace hospital_NH_OOP = hospital_NH_OOP_imputed if missing(hospital_NH_OOP)
drop hospital_NH_OOP_imputed

*impose cap of $30000 (BASE YEAR dollars) per month (on average) for the sum and $15000 for each of the two components:
replace hospital_NH_OOP = min( 30000*z*months , hospital_NH_OOP) if !missing(hospital_NH_OOP)
replace hospital_OOP = min( 15000*z*months , hospital_OOP ) if !missing(hospital_OOP)
replace NH_OOP = min( 15000*z*months , NH_OOP ) if !missing(NH_OOP)

*impute using doctor visits if possible where expenses not fully covered
est restore doctor
predict x, xb
tab x qtile_doctor
replace doctor_OOP = z * x * dr_visits if doctor_OOP==. & (dr_visits > 0 & dr_visits < .) & N1712!=1
drop x

*if amount missing, insurance coverage known/incomplete:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(N1712 == 3 | N1712 == 5)

*if amount missing, insurance coverage is complete:
replace doctor_OOP = 0 if (doctor_OOP == .) & (N1712 == 1)

*if amount missing, extent of coverage unknown:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(N1712 == 7 | N1712 == 8 | N1712 == 9)

*if amount missing, # visits == 0:
replace doctor_OOP = 0 if (doctor_OOP == .) & (N1709 == 0)

*if amount missing, # visits unknown:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(N1709 == 998 | N1709 == 999)
								
*if amount missing, either died in hospice or was in hospice since last IW / in last
*2 years, and insurance coverage is known to be incomplete:
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (hospice_OOP == .) & ///
								 (N1702 == 3 | N1702 == 5)

*if amount missing and insurance coverage complete (==1):
replace hospice_OOP = 0 if (hospice_OOP == .) & (N1702 == 1)								 
					
*if amount missing, either died in hospice or was in hospice since last IW / in last
*2 years, and extent of insurance coverage unknown:							 
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (hospice_OOP == .) & ///
								 (N1702 == 7 | N1702 == 8 | N1702 == 9)

*if coverage not asked (though it should have been):
replace hospice_OOP = r(mean) if (hospice_OOP == .) & ///
								 (N226 == 4 | N1699 == 1) & ///
								 (N1702 == .)

*if amount missing and neither died in hospice or was hospice patient:
replace hospice_OOP = 0 if (hospice_OOP == .) & (N1699 == 5) & (N226 != 4)

*if amount missing, did not die in hospice, but unsure if hospice patient:
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (hospice_OOP == .) & ///
								 (N226 != 4) & (N1699 == 8 | N1699 == 9)
								 
*impute if missing, take drugs regularly, coverage is incomplete:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(N1748 == 3 | N1748 == 5)

*set to 0 if missing, coverage is complete:
replace RX_OOP = 0 if (RX_OOP == .) & (N1748 == 1)

*impute if missing, take drugs regularly, coverage unknown or not asked:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(N1748 == 7 | N1748 == 8 | N1748 == 9)

*if coverage not asked (though it should have been):
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(N1744 == 1) & ///
							(N1748 == .)
							
*set to 0 if don't take drugs regularly:							
replace RX_OOP = 0 if (RX_OOP == .) & (N1744 == 5)

*impute if unknown whether take drugs regularly:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & (N1744 == 8 | N1744 == 9)

gen home_OOP = .
gen special_OOP = .

//Home care: Use: (N1760==1); Not fully covered (N1762!=1 & N1762!=6)
//Home care: Don't Use: (N1760==5); Fully covered (N1762==1 | N1762==6)
//Special services: Use: (N1774==1)
//Special services: Don't Use: (N1774==5)

*home expenses only
replace home_OOP = home_special_OOP if (N1760==1 & N1762!=1 & N1762!=6) & (N1774==5)

*special expenses only
replace special_OOP = home_special_OOP if (N1760==5 | N1762==1 | N1762==6) & (N1774==1)

*if home and special both reported:
replace home_OOP = home_shr * home_special_OOP if (N1760==1 & N1762!=1 & N1762!=6) & (N1774==1)
replace special_OOP = special_shr * home_special_OOP if (N1760==1 & N1762!=1 & N1762!=6) & (N1774==1)

*Now the imputation proceeds as a typical imputation taking our imputed data as real data and filling in the rest using the
*utilization and coverage information, imputing with means or zeros wherever applicable:

*cap expenses at 15000 each (BASE YEAR dollars) per month (on average):
replace home_OOP = min( 15000*z* months , home_OOP ) if !missing(home_OOP)
replace special_OOP = min( 15000*z* months , special_OOP ) if !missing(special_OOP)

*impute if expenses=YES, coverage=INCOMPLETE:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
					        		  	   (N1762 == 3 | N1762 == 5)

*if we assume all special facility/service expenses are completely uncovered:
qui sum special_OOP
replace special_OOP = r(mean) if (home_OOP == .) & (N1774==1)

*set to 0 if coverage=COMPLETE (==1) or no charge (==6):
replace home_OOP = 0 if (home_OOP == .) & (N1762 == 1 | N1762==6)

*impute if expenses=YES, coverage=DK/NA/RF/unsettled/missing:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP==.) & ///
							  			   (N1760 == 1) & ///
							  (N1762 == 7 | N1762 == 8 | N1762 == 9 | N1762 == .)

*set to 0 if expenses=NO:
replace home_OOP = 0 if (home_OOP == .) & ///
							 (N1760 == 5)

replace special_OOP = 0 if (special_OOP == .) & ///
							 (N1774 == 5)

*impute if expenses=DK/NA/RF:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == . ) & ///
							  			   (N1760 == 8 | N1760 == 9)

qui summ special_OOP
replace special_OOP = r(mean) if (special_OOP == . ) & ///
										   (N1774 == 8 | N1774 == 9)

*caps
replace home_OOP = min( 15000*z* months , home_OOP ) if !missing(home_OOP)
replace special_OOP = min( 15000*z* months , special_OOP ) if !missing(special_OOP)

*summing:
egen home_special_OOP_imputed = rowtotal( home_OOP special_OOP ) , missing

*re-scaling where an original sum is available in the data or where one has been imputed using brackets and our imputed sum is not equal to zero:
replace home_OOP = home_OOP * (home_special_OOP / home_special_OOP_imputed) ///
						if !missing(home_special_OOP) & home_special_OOP_imputed != 0

replace special_OOP = special_OOP * (home_special_OOP / home_special_OOP_imputed) ///
						if !missing(home_special_OOP) & home_special_OOP_imputed != 0

*fill in missing values of the original variable (where brackets/original data were not available) with the sum of imputed spending
replace home_special_OOP = home_special_OOP_imputed if missing(home_special_OOP)
drop home_special_OOP_imputed							 								

*impute where expenses=YES:
qui sum other_OOP
replace other_OOP = r(mean) if (other_OOP == .) & (N1791 == 1)

*set to 0 where expenses=NO:							    
replace other_OOP = 0 if (other_OOP == .) & (N1791 == 5)

*impute where expenses=DK/NA/RF:
qui sum other_OOP
replace other_OOP = r(mean) if (other_OOP == .) & (N1791 == 8 | N1791 == 9)

*if amount missing, expenditures = YES:
qui sum non_med_OOP
replace non_med_OOP = r(mean) if (non_med_OOP == .) & (N1804 == 1)									

*if amount missing, expenditures = NO:						          
replace non_med_OOP = 0 if (non_med_OOP == .) & (N1804 == 5)

*if amount missing, expenditures = DK/NA/RF:
qui sum non_med_OOP
replace non_med_OOP = r(mean) if (non_med_OOP == .) & (N1804 == 8 | N1804 == 9)

save $savedir/exit1995_oopi2.dta, replace

********************************************************************************

use $savedir/exit1996_oopi1.dta, clear
merge 1:1 HHID PN using $savedir/exit1996_use.dta, nogen keepusing(hospital_nights nh_nights dr_visits qtile_*)

scalar z = cpi1996 / cpiBASE

*if amount missing, expenses=YES:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (P2206 == 1)

*if amount missing, expenses=NO:
replace MC_HMO = 0 if (MC_HMO == .) & (P2206 == 5)

*if amount missing, expenses=DK/NA/RF:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (P2206 == 8 | P2206 == 9)

//No LTC premiums in this wave

qui summ private_medigap_1
replace private_medigap_1 = r(mean) if missing(private_medigap_1) & P2231==1 & (P2234!=2)	//if has insurance, premium not paid entirely by employer/union

replace private_medigap_1 = 0 if missing(private_medigap_1) & (P2231==5 | P2234==2)		//if no insurance, of premium entirely paid

qui summ private_medigap_2
replace private_medigap_2 = r(mean) if missing(private_medigap_2) & P2231==1 & P2232>=2 & P2255!=2	//if has insurance, #plans >=2, not fully paid

replace private_medigap_2 = 0 if missing(private_medigap_2) & (P2231==5 | P2232==1 | P2255==2)	//if no insurance, only 1 plan, or fully paid

egen private_medigap = rowtotal( private_medigap_1 ///
								 private_medigap_2 ) , missing

qui summ private_medigap
replace private_medigap = r(mean) if missing(private_medigap) & (P2231==8 | P2231==9)	//if unsure of whether has insurance

/*** hospital imputations ***/

gen hospital_OOP = .

*all reported spending is hospital spending IF:
*(1) R reports hospital utilization [ died in hospital (P226==1) OR patient overnight in hospital (P1245==1)] AND
*(2) Hospital expenses NOT fully covered [ (P1253!=1) ] AND either
*(3a) R reports no NH utilization [ did not die in NH (P226!=2) AND was not patient overnight in NH (P1262!=1) AND did not live in NH (P249!=1) ] OR
*(3b) NH expenses not fully covered by insurance [ (P1267==1) ]

replace hospital_OOP = hospital_NH_OOP if ((P226==1 | P1245==1) & P1253!=1) & ((P1262==5 & P249!=1 & P226!=2) | P1267==1)

*cap at 15000*z*months
replace hospital_OOP = min( 15000*z*months , hospital_OOP ) if !missing(hospital_OOP)

*impute with nights spent in NH where possible if expenses were not fully covered
est restore hospital
predict x, xb
tab x qtile_hospital
replace hospital_OOP = z * x * hospital_nights if hospital_OOP == . & (P226==1 | P1245==1) & (P1253!=1)
drop x

*if amount missing, and there are expenses that are known to be not fully covered, and nights not available:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if hospital_OOP == . & (P226==1 | P1245==1) & (P1253==3 | P1253==5)

*if amount missing, and expenses ARE fully covered:
replace hospital_OOP = 0 if (hospital_OOP==.) & (P1253==1)

*if expenses==YES, amount missing, and coverage of expenses is DK/RF/NA, 
*costs are unsettled (==7), or missing (interviewee should have been asked but was not):
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & (P226==1 | P1245==1) & (P1253==7 | P1253==8 | P1253==9 | P1253==.)

*if amount missing and did not spend night in hospital:
replace hospital_OOP = 0 if (hospital_OOP==.) & (P1245==5)

*if utilization is DK/NA/RF and amount missing:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & (P1245==8 | P1245==9)

/*** NH imputations ***/

gen NH_OOP = .

*all reported spending is NH spending IF:
*(1) R reports NH utilization [ died in NH (P226==2) OR was patient overnight in NH (P1262==1) OR lived in NH (P249==1) ] AND 
*(2) These expenses were not fully covered by insurance [ (P1267!=1) ] AND either
*(3a) No hospital utilization [ did not die in hospital (P226!=1) AND not a patient overnight in hospital (P1245!=1)] OR
*(3b) Hospital expenses fully covered [ (P1253==1) ]

replace NH_OOP = hospital_NH_OOP if ((P1262==1 | P249==1 | P226==2) & P1267!=1) & ((P1245==5 & P226!=1) | P1253==1)

*cap at 15000*z*months
replace NH_OOP = min( 15000*z*months , NH_OOP ) if !missing(NH_OOP)

*impute with nights spent in NH where possible if expenses were not fully covered
est restore NH
predict x, xb
tab x qtile_nh
replace NH_OOP = z * x * nh_nights if (NH_OOP==.) & (P1262==1 | P249==1 | P226==2) & (P1267!=1)
drop x

*if amount missing, and there are expenses that are not fully covered, and nights not available:
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & (P1262==1 | P249==1 | P226==2) & (P1267==3 | P1267==5)

*if amount missing, and expenses ARE fully covered:
replace NH_OOP = 0 if (NH_OOP==.) & (P1267==1)

*if expenses==YES, amount missing, and coverage of expenses is DK/RF/NA, 
*costs are unsettled (==7), or missing (interviewee should have been asked but was not):
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & (P1262==1 | P249==1 | P226==2) & (P1267==7 | P1267==8 | P1267==9 | P1267==.)

*if amount missing and did not spend night in NH (and didnt live in NH) or hospital:
replace NH_OOP = 0 if NH_OOP==. & (P1262==5 & P249!=1 & P226!=2)						

*if didn't live in NH, overnight stay is DK/NA/RF and amount missing:
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & (P249!=1 & P226!=2) & (P1262==8 | P1262==9)

/*** hospital plus NH ***/

*summing our independent imputations for hospital and NH:
egen hospital_NH_OOP_imputed = rowtotal( hospital_OOP NH_OOP ), missing

*re-scaling where an original sum is available in the data or where one has been imputed using brackets and our imputed sum is not equal to zero:
replace hospital_OOP = hospital_OOP * (hospital_NH_OOP / hospital_NH_OOP_imputed) if !missing(hospital_NH_OOP) & hospital_NH_OOP_imputed != 0
replace NH_OOP = NH_OOP * (hospital_NH_OOP / hospital_NH_OOP_imputed) if !missing(hospital_NH_OOP) & hospital_NH_OOP_imputed != 0

*fill in missing values of the original variable (where brackets were not available) with the sum of imputed hospital and NH spending.
replace hospital_NH_OOP = hospital_NH_OOP_imputed if missing(hospital_NH_OOP)
drop hospital_NH_OOP_imputed

*impose cap of $30000 (BASE YEAR dollars) per month (on average) for the sum and $15000 for each of the two components:
replace hospital_NH_OOP = min( 30000*z*months , hospital_NH_OOP) if !missing(hospital_NH_OOP)
replace hospital_OOP = min( 15000*z*months , hospital_OOP ) if !missing(hospital_OOP)
replace NH_OOP = min( 15000*z*months , NH_OOP ) if !missing(NH_OOP)

*impute using doctor visits if possible where expenses not fully covered
est restore doctor
predict x, xb
tab x qtile_doctor
replace doctor_OOP = z * x * dr_visits if doctor_OOP==. & (dr_visits > 0 & dr_visits < .) & P1293!=1
drop x

*if amount missing, insurance coverage known/incomplete:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(P1293 == 3 | P1293 == 5)

*if amount missing, insurance coverage is complete:
replace doctor_OOP = 0 if (doctor_OOP == .) & (P1293 == 1)

*if amount missing, extent of coverage unknown:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(P1293 == 7 | P1293 == 8 | P1293 == 9)

*if amount missing, # visits == 0:
replace doctor_OOP = 0 if (doctor_OOP == .) & (P1290 == 0)

*if amount missing, # visits unknown:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(P1290 == 998 | P1290 == 999)
								
*if amount missing, either died in hospice or was in hospice since last IW / in last
*2 years, and insurance coverage is known to be incomplete:
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (hospice_OOP == .) & ///
								 (P1283 == 3 | P1283 == 5)

*if amount missing and insurance coverage complete (==1):
replace hospice_OOP = 0 if (hospice_OOP == .) & (P1283 == 1)								 
					
*if amount missing, either died in hospice or was in hospice since last IW / in last
*2 years, and extent of insurance coverage unknown:							 
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (hospice_OOP == .) & ///
								 (P1283 == 7 | P1283 == 8 | P1283 == 9)

*if coverage not asked (though it should have been):
replace hospice_OOP = r(mean) if (hospice_OOP == .) & ///
								 (P226 == 4 | P1280 == 1) & ///
								 (P1283 == .)

*if amount missing and neither died in hospice or was hospice patient:
replace hospice_OOP = 0 if (hospice_OOP == .) & (P1280 == 5) & (P226 != 4)

*if amount missing, did not die in hospice, but unsure if hospice patient:
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (hospice_OOP == .) & ///
								 (P226 != 4) & (P1280 == 8 | P1280 == 9)
								 
*impute if missing, take drugs regularly, coverage is incomplete:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(P1329 == 3 | P1329 == 5)

*set to 0 if missing, coverage is complete:
replace RX_OOP = 0 if (RX_OOP == .) & (P1329 == 1)

*impute if missing, take drugs regularly, coverage unknown or not asked:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(P1329 == 7 | P1329 == 8 | P1329 == 9)

*if coverage not asked (though it should have been):
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(P1325 == 1) & ///
							(P1329 == .)
							
*set to 0 if don't take drugs regularly:							
replace RX_OOP = 0 if (RX_OOP == .) & (P1325 == 5)

*impute if unknown whether take drugs regularly:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & (P1325 == 8 | P1325 == 9)

gen home_OOP = .
gen special_OOP = .

//Home care: Use: (P1341==1); Not fully covered (P1343!=1 & P1343!=6)
//Home care: Don't Use: (P1341==5); Fully covered (P1343==1 | P1343==6)
//Special services: Use: (P1355==1)
//Special services: Don't Use: (P1355==5)

*home expenses only
replace home_OOP = home_special_OOP if (P1341==1 & P1343!=1 & P1343!=6) & (P1355==5)

*special expenses only
replace special_OOP = home_special_OOP if (P1341==5 | P1343==1 | P1343==6) & (P1355==1)

*if home and special both reported:
replace home_OOP = home_shr * home_special_OOP if (P1341==1 & P1343!=1 & P1343!=6) & (P1355==1)
replace special_OOP = special_shr * home_special_OOP if (P1341==1 & P1343!=1 & P1343!=6) & (P1355==1)

*Now the imputation proceeds as a typical imputation taking our imputed data as real data and filling in the rest using the
*utilization and coverage information, imputing with means or zeros wherever applicable:

*cap expenses at 15000 each (BASE YEAR dollars) per month (on average):
replace home_OOP = min( 15000*z* months , home_OOP ) if !missing(home_OOP)
replace special_OOP = min( 15000*z* months , special_OOP ) if !missing(special_OOP)

*impute if expenses=YES, coverage=INCOMPLETE:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
					        		  	   (P1343 == 3 | P1343 == 5)

*if we assume all special facility/service expenses are completely uncovered:
qui sum special_OOP
replace special_OOP = r(mean) if (home_OOP == .) & (P1355==1)

*set to 0 if coverage=COMPLETE (==1) or no charge (==6):
replace home_OOP = 0 if (home_OOP == .) & (P1343 == 1 | P1343==6)

*impute if expenses=YES, coverage=DK/NA/RF/unsettled/missing:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP==.) & ///
							  			   (P1341 == 1) & ///
							  (P1343 == 7 | P1343 == 8 | P1343 == 9 | P1343 == .)

*set to 0 if expenses=NO:
replace home_OOP = 0 if (home_OOP == .) & ///
							 (P1341 == 5)

replace special_OOP = 0 if (special_OOP == .) & ///
							 (P1355 == 5)

*impute if expenses=DK/NA/RF:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == . ) & ///
							  			   (P1341 == 8 | P1341 == 9)

qui summ special_OOP
replace special_OOP = r(mean) if (special_OOP == . ) & ///
										   (P1355 == 8 | P1355 == 9)

*caps
replace home_OOP = min( 15000*z* months , home_OOP ) if !missing(home_OOP)
replace special_OOP = min( 15000*z* months , special_OOP ) if !missing(special_OOP)

*summing:
egen home_special_OOP_imputed = rowtotal( home_OOP special_OOP ) , missing

*re-scaling where an original sum is available in the data or where one has been imputed using brackets and our imputed sum is not equal to zero:
replace home_OOP = home_OOP * (home_special_OOP / home_special_OOP_imputed) ///
						if !missing(home_special_OOP) & home_special_OOP_imputed != 0

replace special_OOP = special_OOP * (home_special_OOP / home_special_OOP_imputed) ///
						if !missing(home_special_OOP) & home_special_OOP_imputed != 0

*fill in missing values of the original variable (where brackets/original data were not available) with the sum of imputed spending
replace home_special_OOP = home_special_OOP_imputed if missing(home_special_OOP)
drop home_special_OOP_imputed								 								

*impute where expenses=YES:
qui sum other_OOP
replace other_OOP = r(mean) if (other_OOP == .) & (P1372 == 1)

*set to 0 where expenses=NO:							    
replace other_OOP = 0 if (other_OOP == .) & (P1372 == 5)

*impute where expenses=DK/NA/RF:
qui sum other_OOP
replace other_OOP = r(mean) if (other_OOP == .) & (P1372 == 8 | P1372 == 9)

*if amount missing, expenditures = YES:
qui sum non_med_OOP
replace non_med_OOP = r(mean) if (non_med_OOP == .) & (P1385 == 1)									

*if amount missing, expenditures = NO:						          
replace non_med_OOP = 0 if (non_med_OOP == .) & (P1385 == 5)

*if amount missing, expenditures = DK/NA/RF:
qui sum non_med_OOP
replace non_med_OOP = r(mean) if (non_med_OOP == .) & (P1385 == 8 | P1385 == 9)

save $savedir/exit1996_oopi2.dta, replace


********************************************************************************

use $savedir/exit1998_oopi1.dta, clear
merge 1:1 HHID PN using $savedir/exit1998_use.dta, nogen keepusing(hospital_nights nh_nights dr_visits qtile_*)

scalar z = cpi1998 / cpiBASE

*if amount missing, expenses=YES:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (Q2575 == 1)

*if amount missing, expenses=NO:
replace MC_HMO = 0 if (MC_HMO == .) & (Q2575 == 5)

*if amount missing, expenses=DK/NA/RF:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (Q2575 == 8 | Q2575 == 9)

*if missing, coverage=YES:
qui sum long_term_care
replace long_term_care = r(mean) if (long_term_care == .) & (Q2664 == 1)

*if missing, coverage=NO:
replace long_term_care = 0 if (long_term_care == .) & (Q2664 == 5)

*if missing, coverage=DK/NA/RF:
qui sum long_term_care
replace long_term_care = r(mean) if (long_term_care == .) & (Q2664 == 8 | Q2664 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1 == .) & ///
									   (Q2591 == 1 | Q2591 == 2)

*if amount missing, pay NONE ("3") of costs:
replace private_medigap_1 = 0 if (private_medigap_1  == .) & (Q2591 == 3)

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1==.) & ///
									   (Q2591 == 8 | Q2591 == 9)

*if amount missing, no insurance through employer									   
replace private_medigap_1 = 0 if (private_medigap_1==.) & (Q2585==5)

*if amount missing, unsure whether insured through employer
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1==.) & ///
									   (Q2585 == 8 | Q2585 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2 == .) & ///
									   (Q2611 == 1 | Q2611 == 2)

*if amount missing, pay NONE ("3") of costs:
replace private_medigap_2 = 0 if (private_medigap_2  == .) & (Q2611 == 3)

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2==.) & ///
									   (Q2611 == 8 | Q2611 == 9)

*if amount missing, no other insurance									   
replace private_medigap_2 = 0 if (private_medigap_2==.) & (Q2609==5)

*if amount missing, unsure whether other insurance
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2==.) & ///
									   (Q2609 == 8 | Q2609 == 9)

*if amount missing, has other insurance
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if (private_medigap_3==.) & (Q2621==1)

*if amount missing, no other insurance									   
replace private_medigap_3 = 0 if (private_medigap_3==.) & (Q2621==5)

*if amount missing, unsure whether other insurance
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if (private_medigap_3==.) & ///
									   (Q2621 == 8 | Q2621 == 9)

egen private_medigap = rowtotal( private_medigap_1 ///
								 private_medigap_2 ///
								 private_medigap_3 ) , missing									   									   									   

/*** hospital imputations ***/

gen hospital_OOP = .

*all reported spending is hospital spending IF:
*(1) R reports hospital utilization [ died in hospital (Q491==1) OR patient overnight in hospital (Q1728==1)] AND
*(2) Hospital expenses NOT fully covered [ (Q1735!=1) ] AND either
*(3a) R reports no NH utilization [ did not die in NH (Q491!=2) AND was not patient overnight in NH (Q1743!=1) AND did not live in NH (Q519!=1) ] OR
*(3b) NH expenses not fully covered by insurance [ (Q1748==1) ]

replace hospital_OOP = hospital_NH_OOP if ((Q491==1 | Q1728==1) & Q1735!=1) & ((Q1743==5 & Q519!=1 & Q491!=2) | Q1748==1)

*cap at 15000*z*months
replace hospital_OOP = min( 15000*z*months , hospital_OOP ) if !missing(hospital_OOP)

*impute with nights spent in NH where possible if expenses were not fully covered
est restore hospital
predict x, xb
tab x qtile_hospital
replace hospital_OOP = z * x * hospital_nights if hospital_OOP == . & (Q491==1 | Q1728==1) & (Q1735!=1)
drop x

*if amount missing, and there are expenses that are known to be not fully covered, and nights not available:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if hospital_OOP == . & (Q491==1 | Q1728==1) & (Q1735==3 | Q1735==5)

*if amount missing, and expenses ARE fully covered:
replace hospital_OOP = 0 if (hospital_OOP==.) & (Q1735==1)

*if expenses==YES, amount missing, and coverage of expenses is DK/RF/NA, 
*costs are unsettled (==7), or missing (interviewee should have been asked but was not):
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & (Q491==1 | Q1728==1) & (Q1735==7 | Q1735==8 | Q1735==9 | Q1735==.)

*if amount missing and did not spend night in hospital:
replace hospital_OOP = 0 if (hospital_OOP==.) & (Q1728==5)

*if utilization is DK/NA/RF and amount missing:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & (Q1728==8 | Q1728==9)

/*** NH imputations ***/

gen NH_OOP = .

*all reported spending is NH spending IF:
*(1) R reports NH utilization [ died in NH (Q491==2) OR was patient overnight in NH (Q1743==1) OR lived in NH (Q519==1) ] AND 
*(2) These expenses were not fully covered by insurance [ (Q1748!=1) ] AND either
*(3a) No hospital utilization [ did not die in hospital (Q491!=1) AND not a patient overnight in hospital (Q1728!=1)] OR
*(3b) Hospital expenses fully covered [ (Q1735==1) ]

replace NH_OOP = hospital_NH_OOP if ((Q1743==1 | Q519==1 | Q491==2) & Q1748!=1) & ((Q1728==5 & Q491!=1) | Q1735==1)

*cap at 15000*z*months
replace NH_OOP = min( 15000*z*months , NH_OOP ) if !missing(NH_OOP)

*impute with nights spent in NH where possible if expenses were not fully covered
est restore NH
predict x, xb
tab x qtile_nh
replace NH_OOP = z * x * nh_nights if (NH_OOP==.) & (Q1743==1 | Q519==1 | Q491==2) & (Q1748!=1)
drop x

*if amount missing, and there are expenses that are not fully covered, and nights not available:
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & (Q1743==1 | Q519==1 | Q491==2) & (Q1748==3 | Q1748==5)

*if amount missing, and expenses ARE fully covered:
replace NH_OOP = 0 if (NH_OOP==.) & (Q1748==1)

*if expenses==YES, amount missing, and coverage of expenses is DK/RF/NA, 
*costs are unsettled (==7), or missing (interviewee should have been asked but was not):
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & (Q1743==1 | Q519==1 | Q491==2) & (Q1748==7 | Q1748==8 | Q1748==9 | Q1748==.)

*if amount missing and did not spend night in NH (and didnt live in NH) or hospital:
replace NH_OOP = 0 if NH_OOP==. & (Q1743==5 & Q519!=1 & Q491!=2)						

*if didn't live in NH, overnight stay is DK/NA/RF and amount missing:
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & (Q519!=1 & Q491!=2) & (Q1743==8 | Q1743==9)

/*** hospital plus NH ***/

*summing our independent imputations for hospital and NH:
egen hospital_NH_OOP_imputed = rowtotal( hospital_OOP NH_OOP ), missing

*re-scaling where an original sum is available in the data or where one has been imputed using brackets and our imputed sum is not equal to zero:
replace hospital_OOP = hospital_OOP * (hospital_NH_OOP / hospital_NH_OOP_imputed) if !missing(hospital_NH_OOP) & hospital_NH_OOP_imputed != 0
replace NH_OOP = NH_OOP * (hospital_NH_OOP / hospital_NH_OOP_imputed) if !missing(hospital_NH_OOP) & hospital_NH_OOP_imputed != 0

*fill in missing values of the original variable (where brackets were not available) with the sum of imputed hospital and NH spending.
replace hospital_NH_OOP = hospital_NH_OOP_imputed if missing(hospital_NH_OOP)
drop hospital_NH_OOP_imputed

*impose cap of $30000 (BASE YEAR dollars) per month (on average) for the sum and $15000 for each of the two components:
replace hospital_NH_OOP = min( 30000*z*months , hospital_NH_OOP) if !missing(hospital_NH_OOP)
replace hospital_OOP = min( 15000*z*months , hospital_OOP ) if !missing(hospital_OOP)
replace NH_OOP = min( 15000*z*months , NH_OOP ) if !missing(NH_OOP)

*impute using doctor visits if possible where expenses not fully covered
est restore doctor
predict x, xb
tab x qtile_doctor
replace doctor_OOP = z * x * dr_visits if doctor_OOP==. & (dr_visits > 0 & dr_visits < .) & Q1779!=1
drop x

*if amount missing, insurance coverage known/incomplete:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(Q1779 == 3 | Q1779 == 5)

*if amount missing, insurance coverage is complete:
replace doctor_OOP = 0 if (doctor_OOP == .) & (Q1779 == 1)

*if amount missing, extent of coverage unknown:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(Q1779 == 7 | Q1779 == 8 | Q1779 == 9)

*if amount missing, # visits == 0:
replace doctor_OOP = 0 if (doctor_OOP == .) & (Q1778 == 0)

*if amount missing, # visits unknown:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(Q1778 == 998 | Q1778 == 999)
								
*if amount missing, either died in hospice or was in hospice since last IW / in last
*2 years, and insurance coverage is known to be incomplete:
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (hospice_OOP == .) & ///
								 (Q1769 == 3 | Q1769 == 5)

*if amount missing and insurance coverage complete (==1):
replace hospice_OOP = 0 if (hospice_OOP == .) & (Q1769 == 1)								 
					
*if amount missing, either died in hospice or was in hospice since last IW / in last
*2 years, and extent of insurance coverage unknown:							 
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (hospice_OOP == .) & ///
								 (Q1769 == 7 | Q1769 == 8 | Q1769 == 9)

*if coverage not asked (though it should have been):
replace hospice_OOP = r(mean) if (hospice_OOP == .) & ///
								 (Q491 == 4 | Q519 == 2 | Q1764 == 1) & ///
								 (Q1769 == .)

*if amount missing and neither died in hospice or was hospice patient:
replace hospice_OOP = 0 if (hospice_OOP == .) & (Q1764 == 5) & (Q491 != 4 & Q519 != 2)

*if amount missing, did not die in hospice, but unsure if hospice patient:
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (hospice_OOP == .) & ///
								 (Q491 != 4 & Q519 != 2) & (Q1764 == 8 | Q1764 == 9)
								 
*impute if missing, take drugs regularly, coverage is incomplete:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(Q1793 == 3 | Q1793 == 5)

*set to 0 if missing, coverage is complete:
replace RX_OOP = 0 if (RX_OOP == .) & (Q1793 == 1)

*impute if missing, take drugs regularly, coverage unknown or not asked:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(Q1793 == 7 | Q1793 == 8 | Q1793 == 9)

*if coverage not asked (though it should have been):
*(NOTE: Q1792==7 "medications known")
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(Q1792 == 1 | Q1792 == 7) & ///
							(Q1793 == .)
							
*set to 0 if don't take drugs regularly:							
replace RX_OOP = 0 if (RX_OOP == .) & (Q1792 == 5)

*impute if unknown whether take drugs regularly:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & (Q1792 == 8 | Q1792 == 9)

gen home_OOP = .
gen special_OOP = .

*home expenses only
replace home_OOP = home_special_OOP if (Q1804==1 & Q1806!=1 & Q1806!=6) & (Q1808==5)

*special expenses only
replace special_OOP = home_special_OOP if (Q1804==5 | Q1806==1 | Q1806==6) & (Q1808==1)

*if home and special both reported:
replace home_OOP = home_shr * home_special_OOP if (Q1804==1 & Q1806!=1 & Q1806!=6) & (Q1808==1)
replace special_OOP = special_shr * home_special_OOP if (Q1804==1 & Q1806!=1 & Q1806!=6) & (Q1808==1)

*Now the imputation proceeds as a typical imputation taking our imputed data as real data and filling in the rest using the
*utilization and coverage information, imputing with means or zeros wherever applicable:

*cap expenses at 15000 each (BASE YEAR dollars) per month (on average):
replace home_OOP = min( 15000*z* months , home_OOP ) if !missing(home_OOP)
replace special_OOP = min( 15000*z* months , special_OOP ) if !missing(special_OOP)

*impute if expenses=YES, coverage=INCOMPLETE:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
					        		  	   (Q1806 == 3 | Q1806 == 5)

*if we assume all special facility/service expenses are completely uncovered:
qui sum special_OOP
replace special_OOP = r(mean) if (home_OOP == .) & (Q1808==1)

*set to 0 if coverage=COMPLETE (==1) or no charge (==6):
replace home_OOP = 0 if (home_OOP == .) & (Q1806 == 1 | Q1806==6)

*impute if expenses=YES, coverage=DK/NA/RF/unsettled/missing:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP==.) & ///
							  			   (Q1804 == 1) & ///
							  (Q1806 == 7 | Q1806 == 8 | Q1806 == 9 | Q1806 == .)

*set to 0 if expenses=NO:
replace home_OOP = 0 if (home_OOP == .) & ///
							 (Q1804 == 5)

replace special_OOP = 0 if (special_OOP == .) & ///
							 (Q1808 == 5)

*impute if expenses=DK/NA/RF:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == . ) & ///
							  			   (Q1804 == 8 | Q1804 == 9)

qui summ special_OOP
replace special_OOP = r(mean) if (special_OOP == . ) & ///
										   (Q1808 == 8 | Q1808 == 9)

*caps
replace home_OOP = min( 15000*z* months , home_OOP ) if !missing(home_OOP)
replace special_OOP = min( 15000*z* months , special_OOP ) if !missing(special_OOP)

*summing:
egen home_special_OOP_imputed = rowtotal( home_OOP special_OOP ) , missing

*re-scaling where an original sum is available in the data or where one has been imputed using brackets and our imputed sum is not equal to zero:
replace home_OOP = home_OOP * (home_special_OOP / home_special_OOP_imputed) ///
						if !missing(home_special_OOP) & home_special_OOP_imputed != 0

replace special_OOP = special_OOP * (home_special_OOP / home_special_OOP_imputed) ///
						if !missing(home_special_OOP) & home_special_OOP_imputed != 0

*fill in missing values of the original variable (where brackets/original data were not available) with the sum of imputed spending
replace home_special_OOP = home_special_OOP_imputed if missing(home_special_OOP)
drop home_special_OOP_imputed							 								

*impute where expenses=YES:
qui sum other_OOP
replace other_OOP = r(mean) if (other_OOP == .) & (Q1817 == 1)

*set to 0 where expenses=NO:							    
replace other_OOP = 0 if (other_OOP == .) & (Q1817 == 5)

*impute where expenses=DK/NA/RF:
qui sum other_OOP
replace other_OOP = r(mean) if (other_OOP == .) & (Q1817 == 8 | Q1817 == 9)

*if amount missing, expenditures = YES:
qui sum non_med_OOP
replace non_med_OOP = r(mean) if (non_med_OOP == .) & (Q1843 == 1)									

*if amount missing, expenditures = NO:						          
replace non_med_OOP = 0 if (non_med_OOP == .) & (Q1843 == 5)

*if amount missing, expenditures = DK/NA/RF:
qui sum non_med_OOP
replace non_med_OOP = r(mean) if (non_med_OOP == .) & (Q1843 == 8 | Q1843 == 9)

save $savedir/exit1998_oopi2.dta, replace

********************************************************************************

use $savedir/exit2000_oopi1.dta, clear
merge 1:1 HHID PN using $savedir/exit2000_use.dta, nogen keepusing(hospital_nights nh_nights dr_visits qtile_*)

scalar z = cpi2000 / cpiBASE

*if amount missing, expenses=YES:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (R2601 == 1)

*if amount missing, expenses=NO:
replace MC_HMO = 0 if (MC_HMO == .) & (R2601 == 5)

*if amount missing, expenses=DK/NA/RF:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (R2601 == 8 | R2601 == 9)

*if missing, coverage=YES:
qui sum long_term_care
replace long_term_care = r(mean) if (long_term_care == .) & (R2700 == 1)

*if missing, coverage=NO:
replace long_term_care = 0 if (long_term_care == .) & (R2700 == 5)

*if missing, coverage=DK/NA/RF:
qui sum long_term_care
replace long_term_care = r(mean) if (long_term_care == .) & (R2700 == 8 | R2700 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1 == .) & ///
									   (R2619 == 1 | R2619 == 2)

*if amount missing, pay NONE ("3") of costs:
replace private_medigap_1 = 0 if (private_medigap_1  == .) & (R2619 == 3)

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1==.) & ///
									   (R2619 == 8 | R2619 == 9)

*if amount missing, no insurance through employer									   
replace private_medigap_1 = 0 if (private_medigap_1==.) & (R2613==5)

*if amount missing, unsure whether insured through employer
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1==.) & ///
									   (R2613 == 8 | R2613 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2 == .) & ///
									   (R2635 == 1 | R2635 == 2)

*if amount missing, pay NONE ("3") of costs:
replace private_medigap_2 = 0 if (private_medigap_2  == .) & (R2635 == 3)

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2==.) & ///
									   (R2635 == 8 | R2635 == 9)

*if amount missing, no other insurance									   
replace private_medigap_2 = 0 if (private_medigap_2==.) & (R2633==5)

*if amount missing, unsure whether other insurance
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2==.) & ///
									   (R2633 == 8 | R2633 == 9)

*if amount missing, has other insurance
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if (private_medigap_3==.) & (R2645==1)

*if amount missing, no other insurance									   
replace private_medigap_3 = 0 if (private_medigap_3==.) & (R2645==5)

*if amount missing, unsure whether other insurance
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if (private_medigap_3==.) & ///
									   (R2645 == 8 | R2645 == 9)

egen private_medigap = rowtotal( private_medigap_1 ///
								 private_medigap_2 ///
								 private_medigap_3 ) , missing									   									   									   

/*** hospital imputations ***/

gen hospital_OOP = .

*all reported spending is hospital spending IF:
*(1) R reports hospital utilization [ died in hospital (R525==1) OR patient overnight in hospital (R1739==1)] AND
*(2) Hospital expenses NOT fully covered [ (R1746!=1) ] AND either
*(3a) R reports no NH utilization [ did not die in NH (R525!=2) AND was not patient overnight in NH (R1754!=1) AND did not live in NH (R558!=1) ] OR
*(3b) NH expenses not fully covered by insurance [ (R1759==1) ]

replace hospital_OOP = hospital_NH_OOP if ((R525==1 | R1739==1) & R1746!=1) & ((R1754==5 & R558!=1 & R525!=2) | R1759==1)

*cap at 15000*z*months
replace hospital_OOP = min( 15000*z*months , hospital_OOP ) if !missing(hospital_OOP)

*impute with nights spent in hospital where possible if expenses were not fully covered
est restore hospital
predict x, xb
tab x qtile_hospital
replace hospital_OOP = z * x * hospital_nights if hospital_OOP == . & (R525==1 | R1739==1) & (R1746!=1)
drop x

*if amount missing, and there are expenses that are known to be not fully covered, and nights not available:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if hospital_OOP == . & (R525==1 | R1739==1) & (R1746==3 | R1746==5)

*if amount missing, and expenses ARE fully covered:
replace hospital_OOP = 0 if (hospital_OOP==.) & (R1746==1)

*if expenses==YES, amount missing, and coverage of expenses is DK/RF/NA, 
*costs are unsettled (==7), or missing (interviewee should have been asked but was not):
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & (R525==1 | R1739==1) & (R1746==7 | R1746==8 | R1746==9 | R1746==.)

*if amount missing and did not spend night in hospital:
replace hospital_OOP = 0 if (hospital_OOP==.) & (R1739==5)

*if utilization is DK/NA/RF and amount missing:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & (R1739==8 | R1739==9)

/*** NH imputations ***/

gen NH_OOP = .

*all reported spending is NH spending IF:
*(1) R reports NH utilization [ died in NH (R525==2) OR was patient overnight in NH (R1754==1) OR lived in NH (R558==1) ] AND 
*(2) These expenses were not fully covered by insurance [ (R1759!=1) ] AND either
*(3a) No hospital utilization [ did not die in hospital (R525!=1) AND not a patient overnight in hospital (R1739!=1)] OR
*(3b) Hospital expenses fully covered [ (R1746==1) ]

replace NH_OOP = hospital_NH_OOP if ((R1754==1 | R558==1 | R525==2) & R1759!=1) & ((R1739==5 & R525!=1) | R1746==1)

*cap at 15000*z*months
replace NH_OOP = min( 15000*z*months , NH_OOP ) if !missing(NH_OOP)

*impute with nights spent in NH where possible if expenses were not fully covered
est restore NH
predict x, xb
tab x qtile_nh
replace NH_OOP = z * x * nh_nights if NH_OOP == . & (R1754==1 | R558==1 | R525==2) & (R1759!=1)
drop x

*if amount missing, and there are expenses that are not fully covered, and nights not available:
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & (R1754==1 | R558==1 | R525==2) & (R1759==3 | R1759==5)

*if amount missing, and expenses ARE fully covered:
replace NH_OOP = 0 if (NH_OOP==.) & (R1759==1)

*if expenses==YES, amount missing, and coverage of expenses is DK/RF/NA, 
*costs are unsettled (==7), or missing (interviewee should have been asked but was not):
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & (R1754==1 | R558==1 | R525==2) & (R1759==7 | R1759==8 | R1759==9 | R1759==.)

*if amount missing and did not spend night in NH (and didnt live in NH) or hospital:
replace NH_OOP = 0 if NH_OOP==. & (R1754==5 & R558!=1 & R525!=2)						

*if didn't live in NH, overnight stay is DK/NA/RF and amount missing:
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & (R558!=1 & R525!=2) & (R1754==8 | R1754==9)

/*** hospital plus NH ***/

*summing our independent imputations for hospital and NH:
egen hospital_NH_OOP_imputed = rowtotal( hospital_OOP NH_OOP ), missing

*re-scaling where an original sum is available in the data or where one has been imputed using brackets and our imputed sum is not equal to zero:
replace hospital_OOP = hospital_OOP * (hospital_NH_OOP / hospital_NH_OOP_imputed) if !missing(hospital_NH_OOP) & hospital_NH_OOP_imputed != 0
replace NH_OOP = NH_OOP * (hospital_NH_OOP / hospital_NH_OOP_imputed) if !missing(hospital_NH_OOP) & hospital_NH_OOP_imputed != 0

*fill in missing values of the original variable (where brackets were not available) with the sum of imputed hospital and NH spending.
replace hospital_NH_OOP = hospital_NH_OOP_imputed if missing(hospital_NH_OOP)
drop hospital_NH_OOP_imputed

*impose cap of $30000 (BASE YEAR dollars) per month (on average) for the sum and $15000 for each of the two components:
replace hospital_NH_OOP = min( 30000*z*months , hospital_NH_OOP) if !missing(hospital_NH_OOP)
replace hospital_OOP = min( 15000*z*months , hospital_OOP ) if !missing(hospital_OOP)
replace NH_OOP = min( 15000*z*months , NH_OOP ) if !missing(NH_OOP)

*impute using doctor visits if possible where expenses not fully covered
est restore doctor
predict x, xb
tab x qtile_doctor
replace doctor_OOP = z * x * dr_visits if doctor_OOP==. & (dr_visits > 0 & dr_visits < .) & R1795!=1
drop x

*if amount missing, insurance coverage known/incomplete:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(R1795 == 3 | R1795 == 5)

*if amount missing, insurance coverage is complete:
replace doctor_OOP = 0 if (doctor_OOP == .) & (R1795 == 1)

*if amount missing, extent of coverage unknown:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(R1795 == 7 | R1795 == 8 | R1795 == 9)

*if amount missing, # visits == 0:
replace doctor_OOP = 0 if (doctor_OOP == .) & (R1789 == 0)

*if amount missing, # visits unknown:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(R1789 == 998 | R1789 == 999)

*if amount missing, either died in hospice or was in hospice since last IW / in last
*2 years, and insurance coverage is known to be incomplete:
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (hospice_OOP == .) & ///
								 (R1780 == 3 | R1780 == 5)

*if amount missing and insurance coverage complete (==1):
replace hospice_OOP = 0 if (hospice_OOP == .) & (R1780 == 1)								 
					
*if amount missing, either died in hospice or was in hospice since last IW / in last
*2 years, and extent of insurance coverage unknown or not asked (missing):							 
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (hospice_OOP == .) & ///
								 (R525 == 4 | R558 == 2 | R1775 == 1) & ///
								 (R1780 == 7 | R1780 == 8 | R1780 == 9 | R1780 == .)

*if amount missing and neither died in hospice or was hospice patient:
replace hospice_OOP = 0 if (hospice_OOP == .) & (R1775 == 5) & (R525 != 4 & R558 != 2)

*if amount missing, did not die in hospice, but unsure if hospice patient:
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (hospice_OOP == .) & ///
								 (R525 != 4 & R558 != 2) & (R1775 == 8 | R1775 == 9)
								 
*impute if missing, take drugs regularly, coverage is incomplete:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(R1809 == 3 | R1809 == 5)

*set to 0 if missing, coverage is complete:
replace RX_OOP = 0 if (RX_OOP == .) & (R1809 == 1)

*impute if missing, take drugs regularly, coverage unknown or not asked:
*(NOTE: R1808==7 "medications known")
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(R1808 == 1 | R1808 == 7) & ///
							(R1809 == 7 | R1809 == 8 | R1809 == 9 | R1809 == .)

*set to 0 if don't take drugs regularly:							
replace RX_OOP = 0 if (RX_OOP == .) & (R1808 == 5)

*impute if unknown whether take drugs regularly:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & (R1808 == 8 | R1808 == 9)

gen home_OOP = .
gen special_OOP = .

*home expenses only
replace home_OOP = home_special_OOP if (R1820==1 & R1822!=1 & R1822!=6) & (R1824==5)

*special expenses only
replace special_OOP = home_special_OOP if (R1820==5 | R1822==1 | R1822==6) & (R1824==1)

*if home and special both reported:
replace home_OOP = home_shr * home_special_OOP if (R1820==1 & R1822!=1 & R1822!=6) & (R1824==1)
replace special_OOP = special_shr * home_special_OOP if (R1820==1 & R1822!=1 & R1822!=6) & (R1824==1)

*Now the imputation proceeds as a typical imputation taking our imputed data as real data and filling in the rest using the
*utilization and coverage information, imputing with means or zeros wherever applicable:

*cap expenses at 15000 each (BASE YEAR dollars) per month (on average):
replace home_OOP = min( 15000*z* months , home_OOP ) if !missing(home_OOP)
replace special_OOP = min( 15000*z* months , special_OOP ) if !missing(special_OOP)

*impute if expenses=YES, coverage=INCOMPLETE:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
					        		  	   (R1822 == 3 | R1822 == 5)

*if we assume all special facility/service expenses are completely uncovered:
qui sum special_OOP
replace special_OOP = r(mean) if (home_OOP == .) & (R1824==1)

*set to 0 if coverage=COMPLETE (==1) or no charge (==6):
replace home_OOP = 0 if (home_OOP == .) & (R1822 == 1 | R1822==6)

*impute if expenses=YES, coverage=DK/NA/RF/unsettled/missing:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP==.) & ///
							  			   (R1820 == 1) & ///
							  (R1822 == 7 | R1822 == 8 | R1822 == 9 | R1822 == .)

*set to 0 if expenses=NO:
replace home_OOP = 0 if (home_OOP == .) & ///
							 (R1820 == 5)

replace special_OOP = 0 if (special_OOP == .) & ///
							 (R1824 == 5)

*impute if expenses=DK/NA/RF:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == . ) & ///
							  			   (R1820 == 8 | R1820 == 9)

qui summ special_OOP
replace special_OOP = r(mean) if (special_OOP == . ) & ///
										   (R1824 == 8 | R1824 == 9)

*caps
replace home_OOP = min( 15000*z* months , home_OOP ) if !missing(home_OOP)
replace special_OOP = min( 15000*z* months , special_OOP ) if !missing(special_OOP)

*summing:
egen home_special_OOP_imputed = rowtotal( home_OOP special_OOP ) , missing

*re-scaling where an original sum is available in the data or where one has been imputed using brackets and our imputed sum is not equal to zero:
replace home_OOP = home_OOP * (home_special_OOP / home_special_OOP_imputed) ///
						if !missing(home_special_OOP) & home_special_OOP_imputed != 0

replace special_OOP = special_OOP * (home_special_OOP / home_special_OOP_imputed) ///
						if !missing(home_special_OOP) & home_special_OOP_imputed != 0

*fill in missing values of the original variable (where brackets/original data were not available) with the sum of imputed spending
replace home_special_OOP = home_special_OOP_imputed if missing(home_special_OOP)
drop home_special_OOP_imputed

*impute where expenses=YES:
qui sum other_OOP
replace other_OOP = r(mean) if (other_OOP == .) & (R1834 == 1)

*set to 0 where expenses=NO:							    
replace other_OOP = 0 if (other_OOP == .) & (R1834 == 5)

*impute where expenses=DK/NA/RF:
qui sum other_OOP
replace other_OOP = r(mean) if (other_OOP == .) & (R1834 == 8 | R1834 == 9)								 
								 
*if amount missing, expenditures = YES:
qui sum non_med_OOP
replace non_med_OOP = r(mean) if (non_med_OOP == .) & (R1863 == 1)									

*if amount missing, expenditures = NO:						          
replace non_med_OOP = 0 if (non_med_OOP == .) & (R1863 == 5)

*if amount missing, expenditures = DK/NA/RF:
qui sum non_med_OOP
replace non_med_OOP = r(mean) if (non_med_OOP == .) & (R1863 == 8 | R1863 == 9)
								 

save $savedir/exit2000_oopi2.dta, replace

********************************************************************************

use $savedir/exit2002_oopi1.dta, clear
merge 1:1 HHID PN using $savedir/exit2002_use.dta, nogen keepusing(hospital_nights nh_nights dr_visits qtile_*)

scalar z = cpi2002 / cpiBASE

*if amount missing, expenses=YES:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (SN009 == 1)

*if amount missing, expenses=NO:
replace MC_HMO = 0 if (MC_HMO == .) & (SN009 == 5)

*if amount missing, expenses=DK/NA/RF:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (SN009 == 8 | SN009 == 9)

*if missing, coverage=YES, PrevDescrPlan=N0:
qui sum long_term_care
replace long_term_care = r(mean) if (long_term_care == .) & ///
							        (SN071 == 1) & (SN072 != 1)

*if missing, coverage=NO OR coverage=YES and PrevDescrPlan==YES:
replace long_term_care = 0 if (long_term_care == .) & ///
							  ((SN071 == 5) | (SN071 == 1 & SN072 == 1))

*if missing, coverage=DK/NA/RF:
qui sum long_term_care
replace long_term_care = r(mean) if (long_term_care == .) & (SN071 == 8 | SN071 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1 == .) & ///
									   (SN039_1 == 1 | SN039_1 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 1:
replace private_medigap_1 = 0 if (private_medigap_1  == .) & ///
								 ((SN039_1 == 3) | (SN023 < 1))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1==.) & ///
									   (SN039_1 == 8 | SN039_1 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2 == .) & ///
									   (SN039_2 == 1 | SN039_2 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 2:
replace private_medigap_2 = 0 if (private_medigap_2  == .) & ///
								 ((SN039_2 == 3) | (SN023 < 2))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2==.) & ///
									   (SN039_2 == 8 | SN039_2 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if (private_medigap_3 == .) & ///
									   (SN039_3 == 1 | SN039_3 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 3:
replace private_medigap_3 = 0 if (private_medigap_3  == .) & ///
								 ((SN039_3 == 3) | (SN023 < 3))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if (private_medigap_3==.) & ///
									   (SN039_3 == 8 | SN039_3 == 9)

egen private_medigap = rowtotal( private_medigap_1 ///
								 private_medigap_2 ///
								 private_medigap_3 ) , missing

*if sum is missing, but # plans is known and > 0:
qui sum private_medigap
replace private_medigap = r(mean) if (private_medigap == .) & ///
									 (SN023 > 0) & (SN023 < 98)

*if sum missing, # plans known to be 0:									 
replace private_medigap = 0 if (private_medigap == .) & (SN023 == 0)

*if sum missing, # plans unknown:
qui sum private_medigap
replace private_medigap = r(mean) if (private_medigap == .) & ///
									 (SN023 == 98 | SN023 == 99)									   									   									   

*impute with nights spent in hospital where possible if expenses were not fully covered
est restore hospital
predict x, xb
tab x qtile_hospital
replace hospital_OOP = z * x * hospital_nights if hospital_OOP == . & (SN099==1 | SA124==1) & !(SN102==1)
drop x

*if overnight stay==YES, amount missing, and expenses ARE NOT fully covered:
sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & (SN099==1 | SA124==1) & ///
								  (SN102==2 | SN102==3 | SN102==5)

*if overnight stay==YES, amount missing, and expenses ARE fully covered:
replace hospital_OOP = 0 if (hospital_OOP==.) & (SN099==1 | SA124==1) & (SN102==1)

*if overnight stay==YES, amount missing, and coverage of expenses is DK/RF/NA, costs
*are unsettled (==7), or missing (interviewee should have been asked but was not):
sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & (SN099==1 | SA124==1) & ///
								  (SN102==7 | SN102==8 | SN102==9 | SN102==.)

*if overnight stay==NO and amount missing
replace hospital_OOP = 0 if (hospital_OOP==.) & (SN099==5 & SA124!=1)

*if overnight stay is DK/NA/RF and amount missing:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & ///
								  (SN099==8 | SN099==9) & (SA124!=1)

*impute with nights spent in NH where possible if expenses were not fully covered
est restore NH
predict x, xb
tab x qtile_nh
replace NH_OOP = z * x * nh_nights if NH_OOP == . & (SN114 == 1 | SA028 == 1 | SA124 == 2) & !(SN118 == 1)
drop x

*if amount missing; either stayed overnight in NH (SN114), lived in NH before death
*(SA028), or died in NH (SA124); insurance coverage known and incomplete:
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & ///
							(SN114 == 1 | SA028 == 1 | SA124 == 2) & ///
							(SN118 == 2 | SN118 == 3 | SN118 == 5) 

*if amount missing and insurance coverage complete:							 
replace NH_OOP = 0 if (NH_OOP == .) & (SN118 == 1)

*if amount missing; either stayed overnight in NH (SN114), lived in NH before death
*(SA028), or died in NH (SA124); insurance coverage VNknown, not settled, or
*not asked (missing) 
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP == .) & ///
							(SN114 == 1 | SA028 == 1 | SA124 == 2) & ///
							(SN118 == 7 | SN118 == 8 | SN118 == 9 | SN118 == .)
					
*if amount missing and the following are true--did not stay overnight in NH, did not
*die in NH, did not live in NH before death:
replace NH_OOP = 0 if (NH_OOP == .) & (SN114==5 & SA028!=1 & SA124!=2)

*if amount missing, did not die in NH, did not live in NH before death, but unsure 
*whether stayed overnight in NH:
qui sum NH_OOP
replace NH_OOP = r(mean)  if (NH_OOP == .) & ///
							 (SA028!=1 & SA124!=2) & ///
							 (SN114 == 8 | SN114 == 9)

*impute using doctor visits if possible where expenses not fully covered
est restore doctor
predict x, xb
tab x qtile_doctor
replace doctor_OOP = z * x * dr_visits if doctor_OOP==. & (dr_visits > 0 & dr_visits < .) & !(SN152==1 | SN152==6)
drop x

*if amount missing, insurance coverage known/incomplete:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(SN152 == 2 | SN152 == 3 | SN152 == 5)

*if amount missing, insurance coverage is complete:
replace doctor_OOP = 0 if (doctor_OOP == .) & (SN152 == 1 | SN152 == 6)

*if amount missing, extent of coverage is DK/NA/RF/unsettled:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(SN152 == 7 | SN152 == 8 | SN152 == 9)

*if amount missing, # visits known and > 0, coverage info missing:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
										   (dr_visits > 0 & dr_visits < .) & ///
		   								   (SN152 == .)
								
*if amount missing, # visits == 0:
replace doctor_OOP = 0 if (doctor_OOP == .) & (dr_visits == 0)

*if amount missing, # visits unknown:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(SN147 == 998 | SN147 == 999)

*if amount missing, either died in hospice or was in hospice since last IW / in last
*2 years, and insurance coverage is known to be incomplete:
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (hospice_OOP == .) & ///
								 (SA124 == 4 | SA028 == 2 | SN320 == 1) & ///
								 (SN324 == 2 | SN324 == 3 | SN324 == 5)

*if amount missing and insurance coverage complete (==1) or no charge (==6):
replace hospice_OOP = 0 if (hospice_OOP == .) & (SN324 == 1 | SN324 == 6)								 
					
*if amount missing, either died in hospice or was in hospice since last IW / in last
*2 years, and extent of insurance coverage VNknown or not asked (missing):							 
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (hospice_OOP == .) & ///
								 (SA124 == 4 | SA028 == 2 | SN320 == 1) & ///
								 (SN324 == 7 | SN324 == 8 | SN324 == 9 | SN324 == .)

*if amount missing and neither died in hospice or was hospice patient:
replace hospice_OOP = 0 if (hospice_OOP == .) & (SN320 == 5) & (SA124 != 4 & SA028 != 2)

*if amount missing, did not die in hospice, but unsure if hospice patient:
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (hospice_OOP == .) & ///
								 (SA124 != 4 & SA028 != 2) & (SN320 == 8 | SN320 == 9)

*impute if missing, take drugs regularly, coverage is incomplete:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(SN175 == 1) & ///
							(SN176 == 2 | SN176 == 3 | SN176 == 5)

*set to 0 if missing, coverage is complete:
replace RX_OOP = 0 if (RX_OOP == .) & (SN176 == 1)

*impute if missing, take drugs regularly, coverage unknown or not asked:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(SN175 == 1) & ///
							(SN176 == 7 | SN176 == 8 | SN176 == 9 | SN176 == .)

*set to 0 if don't take drugs regularly:							
replace RX_OOP = 0 if (RX_OOP == .) & (SN175 == 5)

*impute if unknown whether take drugs regularly:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & (SN175 == 8 | SN175 == 9)

*impute if expenses=YES, coverage=INCOMPLETE:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (SN189 == 1) & ///
							  (SN190 == 2 | SN190 == 3 | SN190 == 5)

*set to 0 if coverage=COMPLETE (==1) or no charge (==6):
replace home_OOP = 0 if (home_OOP == .) & (SN190 == 1 | SN190 == 6)

*impute if expenses=YES, coverage=DK/NA/RF/unsettled/missing:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (SN189 == 1) & ///
							  (SN190 == 7 | SN190 == 8 | SN190 == 9 | SN190 == .)

*set to 0 if expenses=NO:
replace home_OOP = 0 if (home_OOP == .) & (SN189 == 5)

*impute if expenses=DK/NA/RF:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (SN189 == 8) | (SN189 == 9) 

*impute where expenses=YES:
qui sum other_OOP
replace other_OOP = r(mean) if (other_OOP == .) & (SN332 == 1)

*set to 0 where expenses=NO:							    
replace other_OOP = 0 if (other_OOP == .) & (SN332 == 5)

*impute where expenses=DK/NA/RF:
qui sum other_OOP
replace other_OOP = r(mean) if (other_OOP == .) & (SN332 == 8 | SN332 == 9)

*if amount missing, expenditures = YES:
qui sum non_med_OOP
replace non_med_OOP = r(mean) if (non_med_OOP == .) & (SN337 == 1)									

*if amount missing, expenditures = NO:						          
replace non_med_OOP = 0 if (non_med_OOP == .) & (SN337 == 5)

*if amount missing, expenditures = DK/NA/RF:
qui sum non_med_OOP
replace non_med_OOP = r(mean) if (non_med_OOP == .) & (SN337 == 8 | SN337 == 9)							  

*if amount missing, expenses=YES, had to pay=YES:							   
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & ///
							  (SN202 == 1) & ///
							  (SN203 == 1)

*if amount missing, had to pay=NO:							  							 							
replace special_OOP = 0 if (special_OOP == .) & (SN203 == 5)

*if amount missing, expenses=YES, had to pay=DK/NA/RF/missing:
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & ///
							  (SN202 == 1) & ///
							  (SN203 == 8 | SN203 == 9 | SN203 == .)

*if amount missing, expenses=NO:
replace special_OOP = 0 if (special_OOP == .) & (SN202 == 5)

*if amount missing, expenses=DK/NA/RF:
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & ///
							  (SN202 == 8 | SN202 == 9)

save $savedir/exit2002_oopi2.dta, replace

********************************************************************************

use $savedir/exit2004_oopi1.dta, clear
merge 1:1 HHID PN using $savedir/exit2004_use.dta, nogen keepusing(hospital_nights nh_nights dr_visits qtile_*)

scalar z = cpi2004 / cpiBASE							  

*if amount missing, expenses=YES:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (TN009 == 1)

*if amount missing, expenses=NO:
replace MC_HMO = 0 if (MC_HMO == .) & (TN009 == 5)

*if amount missing, expenses=DK/NA/RF:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (TN009 == 8 | TN009 == 9)

*if missing, coverage=YES, PrevDescrPlan=N0:
qui sum long_term_care
replace long_term_care = r(mean) if (long_term_care == .) & ///
							        (TN071 == 1) & (TN072 != 1)

*if missing, coverage=NO OR coverage=YES and PrevDescrPlan==YES:
replace long_term_care = 0 if (long_term_care == .) & ///
							  ((TN071 == 5) | (TN071 == 1 & TN072 == 1))

*if missing, coverage=DK/NA/RF:
qui sum long_term_care
replace long_term_care = r(mean) if (long_term_care == .) & (TN071 == 8 | TN071 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1 == .) & ///
									   (TN039_1 == 1 | TN039_1 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 1:
replace private_medigap_1 = 0 if (private_medigap_1  == .) & ///
								 ((TN039_1 == 3) | (TN023 < 1))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1==.) & ///
									   (TN039_1 == 8 | TN039_1 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2 == .) & ///
									   (TN039_2 == 1 | TN039_2 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 2:
replace private_medigap_2 = 0 if (private_medigap_2  == .) & ///
								 ((TN039_2 == 3) | (TN023 < 2))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2==.) & ///
									   (TN039_2 == 8 | TN039_2 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if (private_medigap_3 == .) & ///
									   (TN039_3 == 1 | TN039_3 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 3:
replace private_medigap_3 = 0 if (private_medigap_3  == .) & ///
								 ((TN039_3 == 3) | (TN023 < 3))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if (private_medigap_3==.) & ///
									   (TN039_3 == 8 | TN039_3 == 9)

egen private_medigap = rowtotal( private_medigap_1 ///
								 private_medigap_2 ///
								 private_medigap_3 ) , missing

*if sum is missing, but # plans is known and > 0:
qui sum private_medigap
replace private_medigap = r(mean) if (private_medigap == .) & ///
									 (TN023 > 0) & (TN023 < 8)

*if sum missing, # plans known to be 0:									 
replace private_medigap = 0 if (private_medigap == .) & (TN023 == 0)

*if sum missing, # plans unknown:
qui sum private_medigap
replace private_medigap = r(mean) if (private_medigap == .) & ///
									 (TN023 == 8 | TN023 == 9)									   									   									   

*impute with nights spent in hospital where possible if expenses were not fully covered
est restore hospital
predict x, xb
tab x qtile_hospital
replace hospital_OOP = z * x * hospital_nights if hospital_OOP == . & (TN099==1 | TA124==1) & !(TN102==1 | TN102==6)
drop x

*if overnight stay==YES, amount missing, and expenses ARE NOT fully covered:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & (TN099==1 | TA124==1) & ///
								  (TN102==2 | TN102==3 | TN102==5)

*if overnight stay==YES, amount missing, and expenses ARE fully covered:
replace hospital_OOP = 0 if (hospital_OOP==.) & (TN099==1 | TA124==1) & (TN102==1)

*if overnight stay==YES, amount missing, and coverage of expenses is DK/RF/NA, costs
*are unsettled (==7), or missing (interviewee should have been asked but was not):
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & (TN099==1 | TA124==1) & ///
								  (TN102==7 | TN102==8 | TN102==9 | TN102==.)

*if overnight stay==NO and amount missing
replace hospital_OOP = 0 if (hospital_OOP==.) & (TN099==5 & TA124!=1)

*if overnight stay is DK/NA/RF and amount missing:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & ///
								  (TN099==8 | TN099==9) & (TA124!=1)

*impute with nights spent in NH where possible if expenses were not fully covered
est restore NH
predict x, xb
tab x qtile_nh
replace NH_OOP = z * x * nh_nights if NH_OOP == . & (TN114 == 1 | TA167 == 1 | TA124 == 2) & !(TN118 == 1 | TN118 == 6)
drop x

*if amount missing; either stayed overnight in NH (TN114), lived in NH before death
*(TA167), or died in NH (TA124); insurance coverage known and incomplete:
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & ///
							(TN114 == 1 | TA167 == 1 | TA124 == 2) & ///
							(TN118 == 2 | TN118 == 3 | TN118 == 5) 

*if amount missing and insurance coverage complete:							 
replace NH_OOP = 0 if (NH_OOP == .) & (TN118 == 1)

*if amount missing; either stayed overnight in NH (TN114), lived in NH before death
*(TA167), or died in NH (TA124); insurance coverage VNknown, not settled, or
*not asked (missing) 
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP == .) & ///
							(TN114 == 1 | TA167 == 1 | TA124 == 2) & ///
							(TN118 == 7 | TN118 == 8 | TN118 == 9 | TN118 == .)
					
*if amount missing and the following are true--did not stay overnight in NH, did not
*die in NH, did not live in NH before death:
replace NH_OOP = 0 if (NH_OOP == .) & (TN114==5 & TA167!=1 & TA124!=2)

*if amount missing, did not die in NH, did not live in NH before death, but unsure 
*whether stayed overnight in NH:
qui sum NH_OOP
replace NH_OOP = r(mean)  if (NH_OOP == .) & ///
							 (TA167!=1 & TA124!=2) & ///
							 (TN114 == 8 | TN114 == 9)

*impute using doctor visits if possible where expenses not fully covered
est restore doctor
predict x, xb
tab x qtile_doctor
replace doctor_OOP = z * x * dr_visits if doctor_OOP==. & (dr_visits > 0 & dr_visits < .) & !(TN152==1 | TN152==6)
drop x

*if amount missing, insurance coverage known/incomplete:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(TN152 == 2 | TN152 == 3 | TN152 == 5)

*if amount missing, insurance coverage is complete:
replace doctor_OOP = 0 if (doctor_OOP == .) & (TN152 == 1 | TN152 == 6)

*if amount missing, extent of coverage is DK/NA/RF/unsettled:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(TN152 == 7 | TN152 == 8 | TN152 == 9)

*if amount missing, # visits known and > 0, coverage info missing:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
										   (dr_visits > 0 & dr_visits < .) & ///
		   								   (TN152 == .)
								
*if amount missing, # visits == 0:
replace doctor_OOP = 0 if (doctor_OOP == .) & (dr_visits == 0)

*if amount missing, # visits unknown:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(TN147 == 998 | TN147 == 999)						  

*if amount missing, either died in hospice or was in hospice since last IW / in last
*2 years, and insurance coverage is known to be incomplete:
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (hospice_OOP == .) & ///
								 (TA124 == 4 | TA167 == 2 | TN320 == 1) & ///
								 (TN324 == 2 | TN324 == 3 | TN324 == 5)

*if amount missing and insurance coverage complete (==1) or no charge (==6):
replace hospice_OOP = 0 if (hospice_OOP == .) & (TN324 == 1 | TN324 == 6)								 
					
*if amount missing, either died in hospice or was in hospice since last IW / in last
*2 years, and extent of insurance coverage VNknown or not asked (missing):							 
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (hospice_OOP == .) & ///
								 (TA124 == 4 | TA167 == 2 | TN320 == 1) & ///
								 (TN324 == 7 | TN324 == 8 | TN324 == 9 | TN324 == .)

*if amount missing and neither died in hospice or was hospice patient:
replace hospice_OOP = 0 if (hospice_OOP == .) & (TN320 == 5) & (TA124 != 4 & TA167 != 2)

*if amount missing, did not die in hospice, but unsure if hospice patient:
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (hospice_OOP == .) & ///
								 (TA124 != 4 & TA167 != 2) & (TN320 == 8 | TN320 == 9)

*impute if missing, take drugs regularly, coverage is incomplete:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(TN175 == 1) & ///
							(TN176 == 2 | TN176 == 3 | TN176 == 5)

*set to 0 if missing, coverage is complete (==1) OR no charge (==6):
replace RX_OOP = 0 if (RX_OOP == .) & (TN176 == 1 | TN176 == 6)

*impute if missing, take drugs regularly, coverage unknown or not asked:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(TN175 == 1) & ///
							(TN176 == 7 | TN176 == 8 | TN176 == 9 | TN176 == .)

*set to 0 if don't take drugs regularly:							
replace RX_OOP = 0 if (RX_OOP == .) & (TN175 == 5)

*impute if unknown whether take drugs regularly:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & (TN175 == 8 | TN175 == 9)

*impute if expenses=YES, coverage=INCOMPLETE:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (TN189 == 1) & ///
							  (TN190 == 2 | TN190 == 3 | TN190 == 5)

*set to 0 if coverage=COMPLETE (==1) or no charge (==6):
replace home_OOP = 0 if (home_OOP == .) & (TN190 == 1 | TN190 == 6)

*impute if expenses=YES, coverage=DK/NA/RF/unsettled/missing:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (TN189 == 1) & ///
							  (TN190 == 7 | TN190 == 8 | TN190 == 9 | TN190 == .)

*set to 0 if expenses=NO:
replace home_OOP = 0 if (home_OOP == .) & (TN189 == 5)

*impute if expenses=DK/NA/RF:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (TN189 == 8) | (TN189 == 9) 
							  
*impute where expenses=YES:
qui sum other_OOP
replace other_OOP = r(mean) if (other_OOP == .) & (TN332 == 1)

*set to 0 where expenses=NO:							    
replace other_OOP = 0 if (other_OOP == .) & (TN332 == 5)

*impute where expenses=DK/NA/RF:
qui sum other_OOP
replace other_OOP = r(mean) if (other_OOP == .) & (TN332 == 8 | TN332 == 9)

*if amount missing, expenditures = YES:
qui sum non_med_OOP
replace non_med_OOP = r(mean) if (non_med_OOP == .) & (TN337 == 1)									

*if amount missing, expenditures = NO:						          
replace non_med_OOP = 0 if (non_med_OOP == .) & (TN337 == 5)

*if amount missing, expenditures = DK/NA/RF:
qui sum non_med_OOP
replace non_med_OOP = r(mean) if (non_med_OOP == .) & (TN337 == 8 | TN337 == 9)

*if amount missing, expenses=YES, had to pay=YES:							   
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & ///
							  (TN202 == 1) & ///
							  (TN203 == 1)

*if amount missing, had to pay=NO:							  							 							
replace special_OOP = 0 if (special_OOP == .) & (TN203 == 5)

*if amount missing, expenses=YES, had to pay=DK/NA/RF/missing:
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & ///
							  (TN202 == 1) & ///
							  (TN203 == 8 | TN203 == 9 | TN203 == .)

*if amount missing, expenses=NO:
replace special_OOP = 0 if (special_OOP == .) & (TN202 == 5)

*if amount missing, expenses=DK/NA/RF:
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & ///
							  (TN202 == 8 | TN202 == 9)							  

save $savedir/exit2004_oopi2.dta, replace

********************************************************************************

use $savedir/exit2006_oopi1.dta, clear
merge 1:1 HHID PN using $savedir/exit2006_use.dta, nogen keepusing(hospital_nights nh_nights dr_visits qtile_*)

scalar z = cpi2006 / cpiBASE

*if amount missing, expenses=YES:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (UN009 == 1)

*if amount missing, expenses=NO:
replace MC_HMO = 0 if (MC_HMO == .) & (UN009 == 5)

*if amount missing, expenses=DK/NA/RF:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (UN009 == 8 | UN009 == 9)

*if missing, coverage=YES, PrevDescrPlan=N0:
qui sum long_term_care
replace long_term_care = r(mean) if (long_term_care == .) & ///
							        (UN071 == 1) & (UN072 != 1)

*if missing, coverage=NO OR coverage=YES and PrevDescrPlan==YES:
replace long_term_care = 0 if (long_term_care == .) & ///
							  ((UN071 == 5) | (UN071 == 1 & UN072 == 1))

*if missing, coverage=DK/NA/RF:
qui sum long_term_care
replace long_term_care = r(mean) if (long_term_care == .) & (UN071 == 8 | UN071 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1 == .) & ///
									   (UN039_1 == 1 | UN039_1 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 1:
replace private_medigap_1 = 0 if (private_medigap_1  == .) & ///
								 ((UN039_1 == 3) | (UN023 < 1))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1==.) & ///
									   (UN039_1 == 8 | UN039_1 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2 == .) & ///
									   (UN039_2 == 1 | UN039_2 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 2:
replace private_medigap_2 = 0 if (private_medigap_2  == .) & ///
								 ((UN039_2 == 3) | (UN023 < 2))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2==.) & ///
									   (UN039_2 == 8 | UN039_2 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if (private_medigap_3 == .) & ///
									   (UN039_3 == 1 | UN039_3 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 3:
replace private_medigap_3 = 0 if (private_medigap_3  == .) & ///
								 ((UN039_3 == 3) | (UN023 < 3))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if (private_medigap_3==.) & ///
									   (UN039_3 == 8 | UN039_3 == 9)

egen private_medigap = rowtotal( private_medigap_1 ///
								 private_medigap_2 ///
								 private_medigap_3 ) , missing

*if sum is missing, but # plans is known and > 0:
qui sum private_medigap
replace private_medigap = r(mean) if (private_medigap == .) & ///
									 (UN023 > 0) & (UN023 < 98)

*if sum missing, # plans known to be 0:									 
replace private_medigap = 0 if (private_medigap == .) & (UN023 == 0)

*if sum missing, # plans unknown:
qui sum private_medigap
replace private_medigap = r(mean) if (private_medigap == .) & ///
									 (UN023 == 98 | UN023 == 99)									   									   									   

*impute with nights spent in hospital where possible if expenses were not fully covered
est restore hospital
predict x, xb
tab x qtile_hospital
replace hospital_OOP = z * x * hospital_nights if hospital_OOP == . & (UN099==1 | UA124==1) & !(UN102==1 | UN102==6)
drop x

*if overnight stay==YES, amount missing, and expenses ARE NOT fully covered:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & (UN099==1 | UA124==1) & ///
								  (UN102==2 | UN102==3 | UN102==5)

*if overnight stay==YES, amount missing, and expenses ARE fully covered:
replace hospital_OOP = 0 if (hospital_OOP==.) & (UN099==1 | UA124==1) & (UN102==1)

*if overnight stay==YES, amount missing, and coverage of expenses is DK/RF/NA, costs
*are unsettled (==7), or missing (interviewee should have been asked but was not):
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & (UN099==1 | UA124==1) & ///
								  (UN102==7 | UN102==8 | UN102==9 | UN102==.)

*if overnight stay==NO and amount missing
replace hospital_OOP = 0 if (hospital_OOP==.) & (UN099==5 & UA124!=1)

*if overnight stay is DK/NA/RF and amount missing:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & ///
								  (UN099==8 | UN099==9) & (UA124!=1)

*impute with nights spent in NH where possible if expenses were not fully covered
est restore NH
predict x, xb
tab x qtile_nh
replace NH_OOP = z * x * nh_nights if NH_OOP == . & (UN114 == 1 | UA167 == 1 | UA124 == 2) & !(UN118 == 1 | UN118 == 6)
drop x

*if amount missing; either stayed overnight in NH (UN114), lived in NH before death
*(UA167), or died in NH (UA124); insurance coverage known and incomplete:
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & ///
							(UN114 == 1 | UA167 == 1 | UA124 == 2) & ///
							(UN118 == 2 | UN118 == 3 | UN118 == 5) 

*if amount missing and insurance coverage complete:							 
replace NH_OOP = 0 if (NH_OOP == .) & (UN118 == 1)

*if amount missing; either stayed overnight in NH (UN114), lived in NH before death
*(UA167), or died in NH (UA124); insurance coverage VNknown, not settled, or
*not asked (missing) 
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP == .) & ///
							(UN114 == 1 | UA167 == 1 | UA124 == 2) & ///
							(UN118 == 7 | UN118 == 8 | UN118 == 9 | UN118 == .)
					
*if amount missing and the following are true--did not stay overnight in NH, did not
*die in NH, did not live in NH before death:
replace NH_OOP = 0 if (NH_OOP == .) & (UN114==5 & UA167!=1 & UA124!=2)

*if amount missing, did not die in NH, did not live in NH before death, but unsure 
*whether stayed overnight in NH:
qui sum NH_OOP
replace NH_OOP = r(mean)  if (NH_OOP == .) & ///
							 (UA167!=1 & UA124!=2) & ///
							 (UN114 == 8 | UN114 == 9)

*impute using doctor visits if possible where expenses not fully covered
est restore doctor
predict x, xb
tab x qtile_doctor
replace doctor_OOP = z * x * dr_visits if doctor_OOP==. & (dr_visits > 0 & dr_visits < .) & !(UN152 == 1 | UN152 == 6)
drop x

*if amount missing, insurance coverage known/incomplete:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(UN152 == 2 | UN152 == 3 | UN152 == 5)

*if amount missing, insurance coverage is complete:
replace doctor_OOP = 0 if (doctor_OOP == .) & (UN152 == 1 | UN152 == 6)

*if amount missing, extent of coverage is DK/NA/RF/unsettled:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(UN152 == 7 | UN152 == 8 | UN152 == 9)

*if amount missing, # visits known and > 0, coverage info missing:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
										   (dr_visits > 0 & dr_visits < .) & ///
		   								   (UN152 == .)
								
*if amount missing, # visits == 0:
replace doctor_OOP = 0 if (doctor_OOP == .) & (dr_visits == 0)

*if amount missing, # visits unknown:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(UN147 == 998 | UN147 == 999)

*if amount missing, either died in hospice or was in hospice since last IW / in last
*2 years, and insurance coverage is known to be incomplete:
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (hospice_OOP == .) & ///
								 (UA124 == 4 | UA167 == 2 | UN320 == 1) & ///
								 (UN324 == 2 | UN324 == 3 | UN324 == 5)

*if amount missing and insurance coverage complete (==1) or no charge (==6):
replace hospice_OOP = 0 if (hospice_OOP == .) & (UN324 == 1 | UN324 == 6)								 
					
*if amount missing, either died in hospice or was in hospice since last IW / in last
*2 years, and extent of insurance coverage VNknown or not asked (missing):							 
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (hospice_OOP == .) & ///
								 (UA124 == 4 | UA167 == 2 | UN320 == 1) & ///
								 (UN324 == 7 | UN324 == 8 | UN324 == 9 | UN324 == .)

*if amount missing and neither died in hospice or was hospice patient:
replace hospice_OOP = 0 if (hospice_OOP == .) & (UN320 == 5) & (UA124 != 4 & UA167 != 2)

*if amount missing, did not die in hospice, but unsure if hospice patient:
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (hospice_OOP == .) & ///
								 (UA124 != 4 & UA167 != 2) & (UN320 == 8 | UN320 == 9)

*impute if missing, take drugs regularly, coverage is incomplete:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(UN175 == 1) & ///
							(UN176 == 2 | UN176 == 3 | UN176 == 5)

*set to 0 if missing, coverage is complete (==1) OR no charge (==6):
replace RX_OOP = 0 if (RX_OOP == .) & (UN176 == 1 | UN176 == 6)

*impute if missing, take drugs regularly, coverage unknown or not asked:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(UN175 == 1) & ///
							(UN176 == 7 | UN176 == 8 | UN176 == 9 | UN176 == .)

*set to 0 if don't take drugs regularly:							
replace RX_OOP = 0 if (RX_OOP == .) & (UN175 == 5)

*impute if unknown whether take drugs regularly:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & (UN175 == 8 | UN175 == 9)

*impute if expenses=YES, coverage=INCOMPLETE:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (UN189 == 1) & ///
							  (UN190 == 2 | UN190 == 3 | UN190 == 5)

*set to 0 if coverage=COMPLETE (==1) or no charge (==6):
replace home_OOP = 0 if (home_OOP == .) & (UN190 == 1 | UN190 == 6)

*impute if expenses=YES, coverage=DK/NA/RF/unsettled/missing:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (UN189 == 1) & ///
							  (UN190 == 7 | UN190 == 8 | UN190 == 9 | UN190 == .)

*set to 0 if expenses=NO:
replace home_OOP = 0 if (home_OOP == .) & (UN189 == 5)

*impute if expenses=DK/NA/RF:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (UN189 == 8) | (UN189 == 9) 
							  
*impute where expenses=YES:
qui sum other_OOP
replace other_OOP = r(mean) if (other_OOP == .) & (UN332 == 1)

*set to 0 where expenses=NO:							    
replace other_OOP = 0 if (other_OOP == .) & (UN332 == 5)

*impute where expenses=DK/NA/RF:
qui sum other_OOP
replace other_OOP = r(mean) if (other_OOP == .) & (UN332 == 8 | UN332 == 9)

*if amount missing, expenditures = YES:
qui sum non_med_OOP
replace non_med_OOP = r(mean) if (non_med_OOP == .) & (UN337 == 1)									

*if amount missing, expenditures = NO:						          
replace non_med_OOP = 0 if (non_med_OOP == .) & (UN337 == 5)

*if amount missing, expenditures = DK/NA/RF:
qui sum non_med_OOP
replace non_med_OOP = r(mean) if (non_med_OOP == .) & (UN337 == 8 | UN337 == 9)							  

*if amount missing, expenses=YES, had to pay=YES:							   
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & ///
							  (UN202 == 1) & ///
							  (UN203 == 1)

*if amount missing, had to pay=NO:							  							 							
replace special_OOP = 0 if (special_OOP == .) & (UN203 == 5)

*if amount missing, expenses=YES, had to pay=DK/NA/RF/missing:
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & ///
							  (UN202 == 1) & ///
							  (UN203 == 8 | UN203 == 9 | UN203 == .)

*if amount missing, expenses=NO:
replace special_OOP = 0 if (special_OOP == .) & (UN202 == 5)

*if amount missing, expenses=DK/NA/RF:
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & ///
							  (UN202 == 8 | UN202 == 9)

save $savedir/exit2006_oopi2.dta, replace

********************************************************************************

use $savedir/exit2008_oopi1.dta, clear
merge 1:1 HHID PN using $savedir/exit2008_use.dta, nogen keepusing(hospital_nights nh_nights dr_visits qtile_*)

scalar z = cpi2008 / cpiBASE							  

*if amount missing, expenses=YES:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (VN009 == 1)

*if amount missing, expenses=NO:
replace MC_HMO = 0 if (MC_HMO == .) & (VN009 == 5)

*if amount missing, expenses=DK/NA/RF:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (VN009 == 8 | VN009 == 9)

*if missing, coverage=YES, PrevDescrPlan=N0:
qui sum long_term_care
replace long_term_care = r(mean) if (long_term_care == .) & ///
							        (VN071 == 1) & (VN072 != 1)

*if missing, coverage=NO OR coverage=YES and PrevDescrPlan==YES:
replace long_term_care = 0 if (long_term_care == .) & ///
							  ((VN071 == 5) | (VN071 == 1 & VN072 == 1))

*if missing, coverage=DK/NA/RF:
qui sum long_term_care
replace long_term_care = r(mean) if (long_term_care == .) & (VN071 == 8 | VN071 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1 == .) & ///
									   (VN039_1 == 1 | VN039_1 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 1:
replace private_medigap_1 = 0 if (private_medigap_1  == .) & ///
								 ((VN039_1 == 3) | (VN023 < 1))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1==.) & ///
									   (VN039_1 == 8 | VN039_1 == 9)
									   
*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2 == .) & ///
									   (VN039_2 == 1 | VN039_2 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 2:
replace private_medigap_2 = 0 if (private_medigap_2  == .) & ///
								 ((VN039_2 == 3) | (VN023 < 2))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2==.) & ///
									   (VN039_2 == 8 | VN039_2 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if (private_medigap_3 == .) & ///
									   (VN039_3 == 1 | VN039_3 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 3:
replace private_medigap_3 = 0 if (private_medigap_3  == .) & ///
								 ((VN039_3 == 3) | (VN023 < 3))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if (private_medigap_3==.) & ///
									   (VN039_3 == 8 | VN039_3 == 9)

egen private_medigap = rowtotal( private_medigap_1 ///
								 private_medigap_2 ///
								 private_medigap_3 ) , missing

*if sum is missing, but # plans is known and > 0:
qui sum private_medigap
replace private_medigap = r(mean) if (private_medigap == .) & ///
									 (VN023 > 0) & (VN023 < 98)

*if sum missing, # plans known to be 0:									 
replace private_medigap = 0 if (private_medigap == .) & (VN023 == 0)

*if sum missing, # plans unknown:
qui sum private_medigap
replace private_medigap = r(mean) if (private_medigap == .) & ///
									 (VN023 == 98 | VN023 == 99)									   									   									   

*impute with nights spent in hospital where possible if expenses were not fully covered
est restore hospital
predict x, xb
tab x qtile_hospital
replace hospital_OOP = z * x * hospital_nights if hospital_OOP == . & (VN099==1 | VA124==1) & !(VN102==1 | VN102==6)
drop x

*if overnight stay==YES, amount missing, and expenses ARE NOT fully covered:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & (VN099==1 | VA124==1) & ///
								  (VN102==2 | VN102==3 | VN102==5)

*if overnight stay==YES, amount missing, and expenses ARE fully covered:
replace hospital_OOP = 0 if (hospital_OOP==.) & (VN099==1 | VA124==1) & (VN102==1)

*if overnight stay==YES, amount missing, and coverage of expenses is DK/RF/NA, costs
*are unsettled (==7), or missing (interviewee should have been asked but was not):
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & (VN099==1 | VA124==1) & ///
								  (VN102==7 | VN102==8 | VN102==9 | VN102==.)

*if overnight stay==NO and amount missing
replace hospital_OOP = 0 if (hospital_OOP==.) & (VN099==5 & VA124!=1)

*if overnight stay is DK/NA/RF and amount missing:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & ///
								  (VN099==8 | VN099==9) & (VA124!=1)

*impute with nights spent in NH where possible if expenses were not fully covered
est restore NH
predict x, xb
tab x qtile_nh
replace NH_OOP = z * x * nh_nights if NH_OOP == . & (VN114 == 1 | VA167 == 1 | VA124 == 2) & !(VN118 == 1 | VN118 == 6)
drop x

*if amount missing; either stayed overnight in NH (VN114), lived in NH before death
*(VA167), or died in NH (VA124); insurance coverage known and incomplete:
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & ///
							(VN114 == 1 | VA167 == 1 | VA124 == 2) & ///
							(VN118 == 2 | VN118 == 3 | VN118 == 5) 

*if amount missing and insurance coverage complete:							 
replace NH_OOP = 0 if (NH_OOP == .) & (VN118 == 1)

*if amount missing; either stayed overnight in NH (VN114), lived in NH before death
*(VA167), or died in NH (VA124); insurance coverage unknown, not settled, or
*not asked (missing) 
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP == .) & ///
							(VN114 == 1 | VA167 == 1 | VA124 == 2) & ///
							(VN118 == 7 | VN118 == 8 | VN118 == 9 | VN118 == .)
					
*if amount missing and the following are true--did not stay overnight in NH, did not
*die in NH, did not live in NH before death:
replace NH_OOP = 0 if (NH_OOP == .) & (VN114==5 & VA167!=1 & VA124!=2)

*if amount missing, did not die in NH, did not live in NH before death, but unsure 
*whether stayed overnight in NH:
qui sum NH_OOP
replace NH_OOP = r(mean)  if (NH_OOP == .) & ///
							 (VA167!=1 & VA124!=2) & ///
							 (VN114 == 8 | VN114 == 9)

*impute using doctor visits if possible where expenses not fully covered
est restore doctor
predict x, xb
tab x qtile_doctor
replace doctor_OOP = z * x * dr_visits if doctor_OOP==. & (dr_visits > 0 & dr_visits < .) & !(VN152 == 1 | VN152 == 6)
drop x

*if amount missing, insurance coverage known/incomplete:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(VN152 == 2 | VN152 == 3 | VN152 == 5)

*if amount missing, insurance coverage is complete:
replace doctor_OOP = 0 if (doctor_OOP == .) & (VN152 == 1 | VN152 == 6)

*if amount missing, extent of coverage is DK/NA/RF/unsettled:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(VN152 == 7 | VN152 == 8 | VN152 == 9)

*if amount missing, # visits known and > 0, coverage info missing:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
										   (dr_visits > 0 & dr_visits < .) & ///
		   								   (VN152 == .)
								
*if amount missing, # visits == 0:
replace doctor_OOP = 0 if (doctor_OOP == .) & (dr_visits == 0)

*if amount missing, # visits unknown:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(VN147 == 998 | VN147 == 999)

*if amount missing, either died in hospice or was in hospice since last IW / in last
*2 years, and insurance coverage is known to be incomplete:
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (hospice_OOP == .) & ///
								 (VA124 == 4 | VA167 == 2 | VN320 == 1) & ///
								 (VN324 == 2 | VN324 == 3 | VN324 == 5)

*if amount missing and insurance coverage complete (==1) or no charge (==6):
replace hospice_OOP = 0 if (hospice_OOP == .) & (VN324 == 1 | VN324 == 6)								 
					
*if amount missing, either died in hospice or was in hospice since last IW / in last
*2 years, and extent of insurance coverage unknown or not asked (missing):							 
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (hospice_OOP == .) & ///
								 (VA124 == 4 | VA167 == 2 | VN320 == 1) & ///
								 (VN324 == 7 | VN324 == 8 | VN324 == 9 | VN324 == .)

*if amount missing and neither died in hospice or was hospice patient:
replace hospice_OOP = 0 if (hospice_OOP == .) & (VN320 == 5) & (VA124 != 4 & VA167 != 2)

*if amount missing, did not die in hospice, but unsure if hospice patient:
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (hospice_OOP == .) & ///
								 (VA124 != 4 & VA167 != 2) & (VN320 == 8 | VN320 == 9)

*impute if missing, take drugs regularly, coverage is incomplete:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(VN175 == 1) & ///
							(VN176 == 2 | VN176 == 3 | VN176 == 5)

*set to 0 if missing, coverage is complete (==1) OR no charge (==6):
replace RX_OOP = 0 if (RX_OOP == .) & (VN176 == 1 | VN176 == 6)

*impute if missing, take drugs regularly, coverage unknown or not asked:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(VN175 == 1) & ///
							(VN176 == 7 | VN176 == 8 | VN176 == 9 | VN176 == .)

*set to 0 if don't take drugs regularly:							
replace RX_OOP = 0 if (RX_OOP == .) & (VN175 == 5)

*impute if unknown whether take drugs regularly:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & (VN175 == 8 | VN175 == 9)

*impute if expenses=YES, coverage=DK/NA/RF/unsettled/missing:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (VN189 == 1) & ///
							  (VN190 == 7 | VN190 == 8 | VN190 == 9 | VN190 == .)

*set to 0 if expenses=NO:
replace home_OOP = 0 if (home_OOP == .) & (VN189 == 5)

*impute if expenses=DK/NA/RF:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (VN189 == 8) | (VN189 == 9) 

*impute where expenses=YES:
qui sum other_OOP
replace other_OOP = r(mean) if (other_OOP == .) & (VN332 == 1)

*set to 0 where expenses=NO:							    
replace other_OOP = 0 if (other_OOP == .) & (VN332 == 5)

*impute where expenses=DK/NA/RF:
qui sum other_OOP
replace other_OOP = r(mean) if (other_OOP == .) & (VN332 == 8 | VN332 == 9)

*if amount missing, expenditures = YES:
qui sum non_med_OOP
replace non_med_OOP = r(mean) if (non_med_OOP == .) & (VN337 == 1)									

*if amount missing, expenditures = NO:						          
replace non_med_OOP = 0 if (non_med_OOP == .) & (VN337 == 5)

*if amount missing, expenditures = DK/NA/RF:
qui sum non_med_OOP
replace non_med_OOP = r(mean) if (non_med_OOP == .) & (VN337 == 8 | VN337 == 9)

*if amount missing, expenses=YES, had to pay=YES:							   
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & ///
							  (VN202 == 1) & ///
							  (VN203 == 1)

*if amount missing, had to pay=NO:							  							 							
replace special_OOP = 0 if (special_OOP == .) & (VN203 == 5)

*if amount missing, expenses=YES, had to pay=DK/NA/RF/missing:
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & ///
							  (VN202 == 1) & ///
							  (VN203 == 8 | VN203 == 9 | VN203 == .)

*if amount missing, expenses=NO:
replace special_OOP = 0 if (special_OOP == .) & (VN202 == 5)

*if amount missing, expenses=DK/NA/RF:
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & ///
							  (VN202 == 8 | VN202 == 9)							  

save $savedir/exit2008_oopi2.dta, replace

********************************************************************************

use $savedir/exit2010_oopi1.dta, clear
merge 1:1 HHID PN using $savedir/exit2010_use.dta, nogen keepusing(hospital_nights nh_nights dr_visits qtile_*)

scalar z = cpi2010 / cpiBASE							  

*if amount missing, expenses=YES:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (WN009 == 1)

*if amount missing, expenses=NO:
replace MC_HMO = 0 if (MC_HMO == .) & (WN009 == 5)

*if amount missing, expenses=DK/NA/RF:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (WN009 == 8 | WN009 == 9)

*if missing, coverage=YES, PrevDescrPlan=N0:
qui sum long_term_care
replace long_term_care = r(mean) if (long_term_care == .) & ///
							        (WN071 == 1) & (WN072 != 1)

*if missing, coverage=NO OR coverage=YES and PrevDescrPlan==YES:
replace long_term_care = 0 if (long_term_care == .) & ///
							  ((WN071 == 5) | (WN071 == 1 & WN072 == 1))

*if missing, coverage=DK/NA/RF:
qui sum long_term_care
replace long_term_care = r(mean) if (long_term_care == .) & (WN071 == 8 | WN071 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1 == .) & ///
									   (WN039_1 == 1 | WN039_1 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 1:
replace private_medigap_1 = 0 if (private_medigap_1  == .) & ///
								 ((WN039_1 == 3) | (WN023 < 1))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1==.) & ///
									   (WN039_1 == 8 | WN039_1 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2 == .) & ///
									   (WN039_2 == 1 | WN039_2 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 2:
replace private_medigap_2 = 0 if (private_medigap_2  == .) & ///
								 ((WN039_2 == 3) | (WN023 < 2))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2==.) & ///
									   (WN039_2 == 8 | WN039_2 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if (private_medigap_3 == .) & ///
									   (WN039_3 == 1 | WN039_3 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 3:
replace private_medigap_3 = 0 if (private_medigap_3  == .) & ///
								 ((WN039_3 == 3) | (WN023 < 3))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if (private_medigap_3==.) & ///
									   (WN039_3 == 8 | WN039_3 == 9)

egen private_medigap = rowtotal( private_medigap_1 ///
								 private_medigap_2 ///
								 private_medigap_3 ) , missing

*if sum is missing, but # plans is known and > 0:
qui sum private_medigap
replace private_medigap = r(mean) if (private_medigap == .) & ///
									 (WN023 > 0) & (WN023 < 98)

*if sum missing, # plans known to be 0:									 
replace private_medigap = 0 if (private_medigap == .) & (WN023 == 0)

*if sum missing, # plans VNknown:
qui sum private_medigap
replace private_medigap = r(mean) if (private_medigap == .) & ///
									 (WN023 == 98 | WN023 == 99)									   									   									   

*impute with nights spent in hospital where possible if expenses were not fully covered
est restore hospital
predict x, xb
tab x qtile_hospital
replace hospital_OOP = z * x * hospital_nights if hospital_OOP == . & (WN099==1 | WA124==1) & !(WN102==1 | WN102==6)
drop x

*if overnight stay==YES, amount missing, and expenses ARE NOT fully covered:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & (WN099==1 | WA124==1) & ///
								  (WN102==2 | WN102==3 | WN102==5)

*if overnight stay==YES, amount missing, and expenses ARE fully covered:
replace hospital_OOP = 0 if (hospital_OOP==.) & (WN099==1 | WA124==1) & (WN102==1)

*if overnight stay==YES, amount missing, and coverage of expenses is DK/RF/NA, costs
*are unsettled (==7), or missing (interviewee should have been asked but was not):
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & (WN099==1 | WA124==1) & ///
								  (WN102==7 | WN102==8 | WN102==9 | WN102==.)

*if overnight stay==NO and amount missing
replace hospital_OOP = 0 if (hospital_OOP==.) & (WN099==5 & WA124!=1)

*if overnight stay is DK/NA/RF and amount missing:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & ///
								  (WN099==8 | WN099==9) & (WA124!=1)

*impute with nights spent in NH where possible if expenses were not fully covered
est restore NH
predict x, xb
tab x qtile_nh
replace NH_OOP = z * x * nh_nights if NH_OOP == . & (WN114 == 1 | WA028 == 1 | WA124 == 2) & !(WN118 == 1 | WN118 == 6)
drop x

*if amount missing; either stayed overnight in NH (WN114), lived in NH before death
*(WA028), or died in NH (WA124); insurance coverage known and incomplete:
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & ///
							(WN114 == 1 | WA028 == 1 | WA124 == 2) & ///
							(WN118 == 2 | WN118 == 3 | WN118 == 5) 

*if amount missing and insurance coverage complete:							 
replace NH_OOP = 0 if (NH_OOP == .) & (WN118 == 1)

*if amount missing; either stayed overnight in NH (WN114), lived in NH before death
*(WA028), or died in NH (WA124); insurance coverage VNknown, not settled, or
*not asked (missing) 
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP == .) & ///
							(WN114 == 1 | WA028 == 1 | WA124 == 2) & ///
							(WN118 == 7 | WN118 == 8 | WN118 == 9 | WN118 == .)
					
*if amount missing and the following are true--did not stay overnight in NH, did not
*die in NH, did not live in NH before death:
replace NH_OOP = 0 if (NH_OOP == .) & (WN114==5 & WA028!=1 & WA124!=2)

*if amount missing, did not die in NH, did not live in NH before death, but unsure 
*whether stayed overnight in NH:
qui sum NH_OOP
replace NH_OOP = r(mean)  if (NH_OOP == .) & ///
							 (WA028!=1 & WA124!=2) & ///
							 (WN114 == 8 | WN114 == 9)

*if amount missing, expenditures = YES, coverage=INCOMPLETE:
qui sum patient_OOP
replace patient_OOP = r(mean) if (patient_OOP == .) & ///
								 (WN135==2 | WN135==3 | WN135==5)

*if amount missing, expenditures=YES, coverage=COMPLETE:
replace patient_OOP = 0 if (patient_OOP == .) & (WN135==1 | WN135==6)
						   
*if amount missing, expenditures=YES, coverage=DK/NA/RF/unsettled:
qui sum patient_OOP
replace patient_OOP = r(mean) if (patient_OOP == .) & ///
								 (WN135==7 | WN135==8 | WN135==9)

*if amount missing, expenditures=YES, coverage=missing:
qui sum patient_OOP
replace patient_OOP = r(mean) if (patient_OOP == .) & ///
								 (WN134 == 1) & ///
								 (WN135 == .)
								 
*if amount missing, expenditures = NO:						          
replace patient_OOP = 0 if (patient_OOP == .) & (WN134 == 5)

*if amount missing, expenditures = DK/NA/RF:
qui sum patient_OOP
replace patient_OOP = r(mean) if (patient_OOP == .) & (WN134==8 | WN134==9)

*impute using doctor visits if possible where expenses not fully covered
est restore doctor
predict x, xb
tab x qtile_doctor
replace doctor_OOP = z * x * dr_visits if doctor_OOP==. & (dr_visits > 0 & dr_visits < .) & !(WN152 == 1 | WN152 == 6)
drop x

*if amount missing, insurance coverage known/incomplete:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(WN152 == 2 | WN152 == 3 | WN152 == 5)

*if amount missing, insurance coverage is complete:
replace doctor_OOP = 0 if (doctor_OOP == .) & (WN152 == 1 | WN152 == 6)

*if amount missing, extent of coverage is DK/NA/RF/unsettled:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(WN152 == 7 | WN152 == 8 | WN152 == 9)

*if amount missing, # visits known and > 0, coverage info missing:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
										   (dr_visits > 0 & dr_visits < .) & ///
		   								   (WN152 == .)
								
*if amount missing, # visits == 0:
replace doctor_OOP = 0 if (doctor_OOP == .) & (dr_visits == 0)

*if amount missing, # visits unknown:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(WN147 == 998 | WN147 == 999)

*if amount missing, expenditures = YES, coverage=INCOMPLETE:
qui sum dental_OOP
replace dental_OOP = r(mean) if (dental_OOP == .) & ///
								 (WN165==2 | WN165==3 | WN165==5)

*if amount missing, expenditures=YES, coverage=COMPLETE:
replace dental_OOP = 0 if (dental_OOP == .) & (WN165==1 | WN165==6)
						   
*if amount missing, expenditures=YES, coverage=DK/NA/RF/unsettled:
qui sum dental_OOP
replace dental_OOP = r(mean) if (dental_OOP == .) & ///
								 (WN165==7 | WN165==8 | WN165==9)

*if amount missing, expenditures=YES, coverage=missing:
qui sum dental_OOP
replace dental_OOP = r(mean) if (dental_OOP == .) & ///
								 (WN164 == 1) & ///
								 (WN165 == .)
								 
*if amount missing, expenditures = NO:						          
replace dental_OOP = 0 if (dental_OOP == .) & (WN164 == 5)

*if amount missing, expenditures = DK/NA/RF:
qui sum dental_OOP
replace dental_OOP = r(mean) if (dental_OOP == .) & (WN164==8 | WN164==9)

*if amount missing, either died in hospice or was in hospice since last IW / in last
*2 years, and insurance coverage is known to be incomplete:
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (hospice_OOP == .) & ///
								 (WA124 == 4 | WN320 == 1) & ///
								 (WN324 == 2 | WN324 == 3 | WN324 == 5)

*if amount missing and insurance coverage complete (==1) or no charge (==6):
replace hospice_OOP = 0 if (hospice_OOP == .) & (WN324 == 1 | WN324 == 6)								 
					
*if amount missing, either died in hospice or was in hospice since last IW / in last
*2 years, and extent of insurance coverage VNknown or not asked (missing):							 
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (hospice_OOP == .) & ///
								 (WA124 == 4 | WN320 == 1) & ///
								 (WN324 == 7 | WN324 == 8 | WN324 == 9 | WN324 == .)

*if amount missing and neither died in hospice or was hospice patient:
replace hospice_OOP = 0 if (hospice_OOP == .) & (WN320 == 5) & (WA124 != 4)

*if amount missing, did not die in hospice, but unsure if hospice patient:
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (hospice_OOP == .) & ///
								 (WA124 != 4) & (WN320 == 8 | WN320 == 9)

*impute if missing, take drugs regularly, coverage is incomplete:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(WN175 == 1) & ///
							(WN176 == 2 | WN176 == 3 | WN176 == 5)

*set to 0 if missing, coverage is complete (==1) OR no charge (==6):
replace RX_OOP = 0 if (RX_OOP == .) & (WN176 == 1 | WN176 == 6)

*impute if missing, take drugs regularly, coverage VNknown or not asked:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(WN175 == 1) & ///
							(WN176 == 7 | WN176 == 8 | WN176 == 9 | WN176 == .)

*set to 0 if don't take drugs regularly:							
replace RX_OOP = 0 if (RX_OOP == .) & (WN175 == 5)

*impute if VNknown whether take drugs regularly:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & (WN175 == 8 | WN175 == 9)
								
*impute if expenses=YES, coverage=INCOMPLETE:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (WN189 == 1) & ///
							  (WN190 == 2 | WN190 == 3 | WN190 == 5)

*set to 0 if coverage=COMPLETE (==1) or no charge (==6):
replace home_OOP = 0 if (home_OOP == .) & (WN190 == 1 | WN190 == 6)

*impute if expenses=YES, coverage=DK/NA/RF/unsettled/missing:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (WN189 == 1) & ///
							  (WN190 == 7 | WN190 == 8 | WN190 == 9 | WN190 == .)

*set to 0 if expenses=NO:
replace home_OOP = 0 if (home_OOP == .) & (WN189 == 5)

*impute if expenses=DK/NA/RF:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (WN189 == 8) | (WN189 == 9) 								

*impute where expenses=YES:
qui sum other_OOP
replace other_OOP = r(mean) if (other_OOP == .) & (WN332 == 1)

*set to 0 where expenses=NO:							    
replace other_OOP = 0 if (other_OOP == .) & (WN332 == 5)

*impute where expenses=DK/NA/RF:
qui sum other_OOP
replace other_OOP = r(mean) if (other_OOP == .) & (WN332 == 8 | WN332 == 9)

*if amount missing, expenditures = YES:
qui sum home_modif_OOP
replace home_modif_OOP = r(mean) if (home_modif_OOP == .) & (WN267 == 1)									

*if amount missing, expenditures = NO:						          
replace home_modif_OOP = 0 if (home_modif_OOP == .) & (WN267 == 5)

*if amount missing, expenditures = DK/NA/RF:
qui sum home_modif_OOP
replace home_modif_OOP = r(mean) if (home_modif_OOP == .) & (WN267 == 8 | WN267 == 9)

*if amount missing, expenses=YES, had to pay=YES:							   
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & ///
							  (WN202 == 1) & ///
							  (WN203 == 1)

*if amount missing, had to pay=NO:							  							 							
replace special_OOP = 0 if (special_OOP == .) & (WN203 == 5)

*if amount missing, expenses=YES, had to pay=DK/NA/RF/missing:
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & ///
							  (WN202 == 1) & ///
							  (WN203 == 8 | WN203 == 9 | WN203 == .)

*if amount missing, expenses=NO:
replace special_OOP = 0 if (special_OOP == .) & (WN202 == 5)

*if amount missing, expenses=DK/NA/RF:
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & ///
							  (WN202 == 8 | WN202 == 9)
								
save $savedir/exit2010_oopi2.dta, replace							  

********************************************************************************

use $savedir/exit2012_oopi1.dta, clear
merge 1:1 HHID PN using $savedir/exit2012_use.dta, nogen keepusing(hospital_nights nh_nights dr_visits qtile_*)

scalar z = cpi2012 / cpiBASE							  

*if amount missing, expenses=YES:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (XN009 == 1)

*if amount missing, expenses=NO:
replace MC_HMO = 0 if (MC_HMO == .) & (XN009 == 5)

*if amount missing, expenses=DK/NA/RF:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (XN009 == 8 | XN009 == 9)

*if missing, coverage=YES, PrevDescrPlan=N0:
qui sum long_term_care
replace long_term_care = r(mean) if (long_term_care == .) & ///
							        (XN071 == 1) & (XN072 != 1)

*if missing, coverage=NO OR coverage=YES and PrevDescrPlan==YES:
replace long_term_care = 0 if (long_term_care == .) & ///
							  ((XN071 == 5) | (XN071 == 1 & XN072 == 1))

*if missing, coverage=DK/NA/RF:
qui sum long_term_care
replace long_term_care = r(mean) if (long_term_care == .) & (XN071 == 8 | XN071 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1 == .) & ///
									   (XN039_1 == 1 | XN039_1 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 1:
replace private_medigap_1 = 0 if (private_medigap_1  == .) & ///
								 ((XN039_1 == 3) | (XN023 < 1))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1==.) & ///
									   (XN039_1 == 8 | XN039_1 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2 == .) & ///
									   (XN039_2 == 1 | XN039_2 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 2:
replace private_medigap_2 = 0 if (private_medigap_2  == .) & ///
								 ((XN039_2 == 3) | (XN023 < 2))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2==.) & ///
									   (XN039_2 == 8 | XN039_2 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if (private_medigap_3 == .) & ///
									   (XN039_3 == 1 | XN039_3 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 3:
replace private_medigap_3 = 0 if (private_medigap_3  == .) & ///
								 ((XN039_3 == 3) | (XN023 < 3))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if (private_medigap_3==.) & ///
									   (XN039_3 == 8 | XN039_3 == 9)

egen private_medigap = rowtotal( private_medigap_1 ///
								 private_medigap_2 ///
								 private_medigap_3 ) , missing

*if sum is missing, but # plans is known and > 0:
qui sum private_medigap
replace private_medigap = r(mean) if (private_medigap == .) & ///
									 (XN023 > 0) & (XN023 < 98)

*if sum missing, # plans known to be 0:									 
replace private_medigap = 0 if (private_medigap == .) & (XN023 == 0)

*if sum missing, # plans VNknown:
qui sum private_medigap
replace private_medigap = r(mean) if (private_medigap == .) & ///
									 (XN023 == 98 | XN023 == 99)									   									   									   

*impute with nights spent in hospital where possible if expenses were not fully covered
est restore hospital
predict x, xb
tab x qtile_hospital
replace hospital_OOP = z * x * hospital_nights if hospital_OOP == . & (XN099==1 | XA124==1) & !(XN102==1 | XN102==6)
drop x

*if overnight stay==YES, amount missing, and expenses ARE NOT fully covered:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & (XN099==1 | XA124==1) & ///
								  (XN102==2 | XN102==3 | XN102==5)

*if overnight stay==YES, amount missing, and expenses ARE fully covered:
replace hospital_OOP = 0 if (hospital_OOP==.) & (XN099==1 | XA124==1) & (XN102==1)

*if overnight stay==YES, amount missing, and coverage of expenses is DK/RF/NA, costs
*are unsettled (==7), or missing (interviewee should have been asked but was not):
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & (XN099==1 | XA124==1) & ///
								  (XN102==7 | XN102==8 | XN102==9 | XN102==.)

*if overnight stay==NO and amount missing
replace hospital_OOP = 0 if (hospital_OOP==.) & (XN099==5 & XA124!=1)

*if overnight stay is DK/NA/RF and amount missing:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & ///
								  (XN099==8 | XN099==9) & (XA124!=1)

*impute with nights spent in NH where possible if expenses were not fully covered
est restore NH
predict x, xb
tab x qtile_nh
replace NH_OOP = z * x * nh_nights if NH_OOP == . & (XN114 == 1 | XA028 == 1 | XA124 == 2) & !(XN118 == 1 | XN118 == 6)
drop x

*if amount missing; either stayed overnight in NH (WN114), lived in NH before death
*(WA028), or died in NH (WA124); insurance coverage known and incomplete:
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & ///
							(XN114 == 1 | XA028 == 1 | XA124 == 2) & ///
							(XN118 == 2 | XN118 == 3 | XN118 == 5) 

*if amount missing and insurance coverage complete:							 
replace NH_OOP = 0 if (NH_OOP == .) & (XN118 == 1)

*if amount missing; either stayed overnight in NH (WN114), lived in NH before death
*(WA028), or died in NH (WA124); insurance coverage VNknown, not settled, or
*not asked (missing) 
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP == .) & ///
							(XN114 == 1 | XA028 == 1 | XA124 == 2) & ///
							(XN118 == 7 | XN118 == 8 | XN118 == 9 | XN118 == .)
					
*if amount missing and the following are true--did not stay overnight in NH, did not
*die in NH, did not live in NH before death:
replace NH_OOP = 0 if (NH_OOP == .) & (XN114==5 & XA028!=1 & XA124!=2)

*if amount missing, did not die in NH, did not live in NH before death, but unsure 
*whether stayed overnight in NH:
qui sum NH_OOP
replace NH_OOP = r(mean)  if (NH_OOP == .) & ///
							 (XA028!=1 & XA124!=2) & ///
							 (XN114 == 8 | XN114 == 9)

*if amount missing, expenditures = YES, coverage=INCOMPLETE:
qui sum patient_OOP
replace patient_OOP = r(mean) if (patient_OOP == .) & ///
								 (XN135==2 | XN135==3 | XN135==5)

*if amount missing, expenditures=YES, coverage=COMPLETE:
replace patient_OOP = 0 if (patient_OOP == .) & (XN135==1 | XN135==6)
						   
*if amount missing, expenditures=YES, coverage=DK/NA/RF/unsettled:
qui sum patient_OOP
replace patient_OOP = r(mean) if (patient_OOP == .) & ///
								 (XN135==7 | XN135==8 | XN135==9)

*if amount missing, expenditures=YES, coverage=missing:
qui sum patient_OOP
replace patient_OOP = r(mean) if (patient_OOP == .) & ///
								 (XN134 == 1) & ///
								 (XN135 == .)
								 
*if amount missing, expenditures = NO:						          
replace patient_OOP = 0 if (patient_OOP == .) & (XN134 == 5)

*if amount missing, expenditures = DK/NA/RF:
qui sum patient_OOP
replace patient_OOP = r(mean) if (patient_OOP == .) & (XN134==8 | XN134==9)

*impute using doctor visits if possible where expenses not fully covered
est restore doctor
predict x, xb
tab x qtile_doctor
replace doctor_OOP = z * x * dr_visits if doctor_OOP==. & (dr_visits > 0 & dr_visits < .) & !(XN152 == 1 | XN152 == 6)
drop x

*if amount missing, insurance coverage known/incomplete:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(XN152 == 2 | XN152 == 3 | XN152 == 5)

*if amount missing, insurance coverage is complete:
replace doctor_OOP = 0 if (doctor_OOP == .) & (XN152 == 1 | XN152 == 6)

*if amount missing, extent of coverage is DK/NA/RF/unsettled:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(XN152 == 7 | XN152 == 8 | XN152 == 9)

*if amount missing, # visits known and > 0, coverage info missing:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
										   (dr_visits > 0 & dr_visits < .) & ///
		   								   (XN152 == .)
								
*if amount missing, # visits == 0:
replace doctor_OOP = 0 if (doctor_OOP == .) & (dr_visits == 0)

*if amount missing, # visits unknown:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(XN147 == 998 | XN147 == 999)

*if amount missing, expenditures = YES, coverage=INCOMPLETE:
qui sum dental_OOP
replace dental_OOP = r(mean) if (dental_OOP == .) & ///
								 (XN165==2 | XN165==3 | XN165==5)

*if amount missing, expenditures=YES, coverage=COMPLETE:
replace dental_OOP = 0 if (dental_OOP == .) & (XN165==1 | XN165==6)
						   
*if amount missing, expenditures=YES, coverage=DK/NA/RF/unsettled:
qui sum dental_OOP
replace dental_OOP = r(mean) if (dental_OOP == .) & ///
								 (XN165==7 | XN165==8 | XN165==9)

*if amount missing, expenditures=YES, coverage=missing:
qui sum dental_OOP
replace dental_OOP = r(mean) if (dental_OOP == .) & ///
								 (XN164 == 1) & ///
								 (XN165 == .)
								 
*if amount missing, expenditures = NO:						          
replace dental_OOP = 0 if (dental_OOP == .) & (XN164 == 5)

*if amount missing, expenditures = DK/NA/RF:
qui sum dental_OOP
replace dental_OOP = r(mean) if (dental_OOP == .) & (XN164==8 | XN164==9)

*if amount missing, either died in hospice or was in hospice since last IW / in last
*2 years, and insurance coverage is known to be incomplete:
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (hospice_OOP == .) & ///
								 (XA124 == 4 | XN320 == 1) & ///
								 (XN324 == 2 | XN324 == 3 | XN324 == 5)

*if amount missing and insurance coverage complete (==1) or no charge (==6):
replace hospice_OOP = 0 if (hospice_OOP == .) & (XN324 == 1 | XN324 == 6)								 
					
*if amount missing, either died in hospice or was in hospice since last IW / in last
*2 years, and extent of insurance coverage VNknown or not asked (missing):							 
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (hospice_OOP == .) & ///
								 (XA124 == 4 | XN320 == 1) & ///
								 (XN324 == 7 | XN324 == 8 | XN324 == 9 | XN324 == .)

*if amount missing and neither died in hospice or was hospice patient:
replace hospice_OOP = 0 if (hospice_OOP == .) & (XN320 == 5) & (XA124 != 4)

*if amount missing, did not die in hospice, but unsure if hospice patient:
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (hospice_OOP == .) & ///
								 (XA124 != 4) & (XN320 == 8 | XN320 == 9)

*impute if missing, take drugs regularly, coverage is incomplete:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(XN175 == 1) & ///
							(XN176 == 2 | XN176 == 3 | XN176 == 5)

*set to 0 if missing, coverage is complete (==1) OR no charge (==6):
replace RX_OOP = 0 if (RX_OOP == .) & (XN176 == 1 | XN176 == 6)

*impute if missing, take drugs regularly, coverage VNknown or not asked:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(XN175 == 1) & ///
							(XN176 == 7 | XN176 == 8 | XN176 == 9 | XN176 == .)

*set to 0 if don't take drugs regularly:							
replace RX_OOP = 0 if (RX_OOP == .) & (XN175 == 5)

*impute if VNknown whether take drugs regularly:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & (XN175 == 8 | XN175 == 9)
								
*impute if expenses=YES, coverage=INCOMPLETE:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (XN189 == 1) & ///
							  (XN190 == 2 | XN190 == 3 | XN190 == 5)

*set to 0 if coverage=COMPLETE (==1) or no charge (==6):
replace home_OOP = 0 if (home_OOP == .) & (XN190 == 1 | XN190 == 6)

*impute if expenses=YES, coverage=DK/NA/RF/unsettled/missing:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (XN189 == 1) & ///
							  (XN190 == 7 | XN190 == 8 | XN190 == 9 | XN190 == .)

*set to 0 if expenses=NO:
replace home_OOP = 0 if (home_OOP == .) & (XN189 == 5)

*impute if expenses=DK/NA/RF:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (XN189 == 8) | (XN189 == 9) 								

*impute where expenses=YES:
qui sum other_OOP
replace other_OOP = r(mean) if (other_OOP == .) & (XN332 == 1)

*set to 0 where expenses=NO:							    
replace other_OOP = 0 if (other_OOP == .) & (XN332 == 5)

*impute where expenses=DK/NA/RF:
qui sum other_OOP
replace other_OOP = r(mean) if (other_OOP == .) & (XN332 == 8 | XN332 == 9)

*if amount missing, expenditures = YES:
qui sum home_modif_OOP
replace home_modif_OOP = r(mean) if (home_modif_OOP == .) & (XN267 == 1)									

*if amount missing, expenditures = NO:						          
replace home_modif_OOP = 0 if (home_modif_OOP == .) & (XN267 == 5)

*if amount missing, expenditures = DK/NA/RF:
qui sum home_modif_OOP
replace home_modif_OOP = r(mean) if (home_modif_OOP == .) & (XN267 == 8 | XN267 == 9)

*if amount missing, expenses=YES, had to pay=YES:							   
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & ///
							  (XN202 == 1) & ///
							  (XN203 == 1)

*if amount missing, had to pay=NO:							  							 							
replace special_OOP = 0 if (special_OOP == .) & (XN203 == 5)

*if amount missing, expenses=YES, had to pay=DK/NA/RF/missing:
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & ///
							  (XN202 == 1) & ///
							  (XN203 == 8 | XN203 == 9 | XN203 == .)

*if amount missing, expenses=NO:
replace special_OOP = 0 if (special_OOP == .) & (XN202 == 5)

*if amount missing, expenses=DK/NA/RF:
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & ///
							  (XN202 == 8 | XN202 == 9)
								
save $savedir/exit2012_oopi2.dta, replace							  



********************************************************************************

use $savedir/exit2014_oopi1.dta, clear
merge 1:1 HHID PN using $savedir/exit2014_use.dta, nogen keepusing(hospital_nights nh_nights dr_visits qtile_* ///
YN102 YN118 YN135 YN152 YN165 YN176 YN190 YN320 YN324)


//note--no lYNger ask whether pay all/some/nYNe, but still ask whether pay any, so can recYNstruct
gen YN039_1=1 if YN040_1>0 & YN040_1<9997
replace YN039_1=3 if YN040_1==0
replace YN039_1=YN040_1-9990 if missing(YN039_1)

gen YN039_2=1 if YN040_2>0 & YN040_2<9997
replace YN039_2=3 if YN040_2==0
replace YN039_2=YN040_2-9990 if missing(YN039_2)

gen YN039_3=1 if YN040_3>0 & YN040_3<9997
replace YN039_3=3 if YN040_3==0
replace YN039_3=YN040_3-9990 if missing(YN039_3)


scalar z = cpi2014 / cpiBASE							  

*if amount missing, expenses=YES:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (YN009 == 1)

*if amount missing, expenses=NO:
replace MC_HMO = 0 if (MC_HMO == .) & (YN009 == 5)

*if amount missing, expenses=DK/NA/RF:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (YN009 == 8 | YN009 == 9)

*if missing, coverage=YES, PrevDescrPlan=N0:
qui sum long_term_care
replace long_term_care = r(mean) if (long_term_care == .) & ///
							        (YN071 == 1) & (YN072 != 1)

*if missing, coverage=NO OR coverage=YES and PrevDescrPlan==YES:
replace long_term_care = 0 if (long_term_care == .) & ///
							  ((YN071 == 5) | (YN071 == 1 & YN072 == 1))

*if missing, coverage=DK/NA/RF:
qui sum long_term_care
replace long_term_care = r(mean) if (long_term_care == .) & (YN071 == 8 | YN071 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1 == .) & ///
									   (YN039_1 == 1 | YN039_1 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 1:
replace private_medigap_1 = 0 if (private_medigap_1  == .) & ///
								 ((YN039_1 == 3) | (YN023 < 1))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1==.) & ///
									   (YN039_1 == 8 | YN039_1 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2 == .) & ///
									   (YN039_2 == 1 | YN039_2 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 2:
replace private_medigap_2 = 0 if (private_medigap_2  == .) & ///
								 ((YN039_2 == 3) | (YN023 < 2))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2==.) & ///
									   (YN039_2 == 8 | YN039_2 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if (private_medigap_3 == .) & ///
									   (YN039_3 == 1 | YN039_3 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 3:
replace private_medigap_3 = 0 if (private_medigap_3  == .) & ///
								 ((YN039_3 == 3) | (YN023 < 3))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if (private_medigap_3==.) & ///
									   (YN039_3 == 8 | YN039_3 == 9)

egen private_medigap = rowtotal( private_medigap_1 ///
								 private_medigap_2 ///
								 private_medigap_3 ) , missing

*if sum is missing, but # plans is known and > 0:
qui sum private_medigap
replace private_medigap = r(mean) if (private_medigap == .) & ///
									 (YN023 > 0) & (YN023 < 98)

*if sum missing, # plans known to be 0:									 
replace private_medigap = 0 if (private_medigap == .) & (YN023 == 0)

*if sum missing, # plans VNknown:
qui sum private_medigap
replace private_medigap = r(mean) if (private_medigap == .) & ///
									 (YN023 == 98 | YN023 == 99)									   									   									   

*impute with nights spent in hospital where possible if expenses were not fully covered
est restore hospital
predict x, xb
tab x qtile_hospital
replace hospital_OOP = z * x * hospital_nights if hospital_OOP == . & (YN099==1 | YA124==1) & !(YN102==1 | YN102==6)
drop x

*if overnight stay==YES, amount missing, and expenses ARE NOT fully covered:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & (YN099==1 | YA124==1) & ///
								  (YN102==2 | YN102==3 | YN102==5)

*if overnight stay==YES, amount missing, and expenses ARE fully covered:
replace hospital_OOP = 0 if (hospital_OOP==.) & (YN099==1 | YA124==1) & (YN102==1)

*if overnight stay==YES, amount missing, and coverage of expenses is DK/RF/NA, costs
*are unsettled (==7), or missing (interviewee should have been asked but was not):
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & (YN099==1 | YA124==1) & ///
								  (YN102==7 | YN102==8 | YN102==9 | YN102==.)

*if overnight stay==NO and amount missing
replace hospital_OOP = 0 if (hospital_OOP==.) & (YN099==5 & YA124!=1)

*if overnight stay is DK/NA/RF and amount missing:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & ///
								  (YN099==8 | YN099==9) & (YA124!=1)

*impute with nights spent in NH where possible if expenses were not fully covered
est restore NH
predict x, xb
tab x qtile_nh
replace NH_OOP = z * x * nh_nights if NH_OOP == . & (YN114 == 1 | YA028 == 1 | YA124 == 2) & !(YN118 == 1 | YN118 == 6)
drop x

*if amount missing; either stayed overnight in NH (WN114), lived in NH before death
*(WA028), or died in NH (WA124); insurance coverage known and incomplete:
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & ///
							(YN114 == 1 | YA028 == 1 | YA124 == 2) & ///
							(YN118 == 2 | YN118 == 3 | YN118 == 5) 

*if amount missing and insurance coverage complete:							 
replace NH_OOP = 0 if (NH_OOP == .) & (YN118 == 1)

*if amount missing; either stayed overnight in NH (WN114), lived in NH before death
*(WA028), or died in NH (WA124); insurance coverage VNknown, not settled, or
*not asked (missing) 
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP == .) & ///
							(YN114 == 1 | YA028 == 1 | YA124 == 2) & ///
							(YN118 == 7 | YN118 == 8 | YN118 == 9 | YN118 == .)
					
*if amount missing and the following are true--did not stay overnight in NH, did not
*die in NH, did not live in NH before death:
replace NH_OOP = 0 if (NH_OOP == .) & (YN114==5 & YA028!=1 & YA124!=2)

*if amount missing, did not die in NH, did not live in NH before death, but unsure 
*whether stayed overnight in NH:
qui sum NH_OOP
replace NH_OOP = r(mean)  if (NH_OOP == .) & ///
							 (YA028!=1 & YA124!=2) & ///
							 (YN114 == 8 | YN114 == 9)

*if amount missing, expenditures = YES, coverage=INCOMPLETE:
qui sum patient_OOP
replace patient_OOP = r(mean) if (patient_OOP == .) & ///
								 (YN135==2 | YN135==3 | YN135==5)

*if amount missing, expenditures=YES, coverage=COMPLETE:
replace patient_OOP = 0 if (patient_OOP == .) & (YN135==1 | YN135==6)
						   
*if amount missing, expenditures=YES, coverage=DK/NA/RF/unsettled:
qui sum patient_OOP
replace patient_OOP = r(mean) if (patient_OOP == .) & ///
								 (YN135==7 | YN135==8 | YN135==9)

*if amount missing, expenditures=YES, coverage=missing:
qui sum patient_OOP
replace patient_OOP = r(mean) if (patient_OOP == .) & ///
								 (YN134 == 1) & ///
								 (YN135 == .)
								 
*if amount missing, expenditures = NO:						          
replace patient_OOP = 0 if (patient_OOP == .) & (YN134 == 5)

*if amount missing, expenditures = DK/NA/RF:
qui sum patient_OOP
replace patient_OOP = r(mean) if (patient_OOP == .) & (YN134==8 | YN134==9)

*impute using doctor visits if possible where expenses not fully covered
est restore doctor
predict x, xb
tab x qtile_doctor
replace doctor_OOP = z * x * dr_visits if doctor_OOP==. & (dr_visits > 0 & dr_visits < .) & !(YN152 == 1 | YN152 == 6)
drop x

*if amount missing, insurance coverage known/incomplete:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(YN152 == 2 | YN152 == 3 | YN152 == 5)

*if amount missing, insurance coverage is complete:
replace doctor_OOP = 0 if (doctor_OOP == .) & (YN152 == 1 | YN152 == 6)

*if amount missing, extent of coverage is DK/NA/RF/unsettled:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(YN152 == 7 | YN152 == 8 | YN152 == 9)

*if amount missing, # visits known and > 0, coverage info missing:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
										   (dr_visits > 0 & dr_visits < .) & ///
		   								   (YN152 == .)
								
*if amount missing, # visits == 0:
replace doctor_OOP = 0 if (doctor_OOP == .) & (dr_visits == 0)

*if amount missing, # visits unknown:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(YN147 == 998 | YN147 == 999)

*if amount missing, expenditures = YES, coverage=INCOMPLETE:
qui sum dental_OOP
replace dental_OOP = r(mean) if (dental_OOP == .) & ///
								 (YN165==2 | YN165==3 | YN165==5)

*if amount missing, expenditures=YES, coverage=COMPLETE:
replace dental_OOP = 0 if (dental_OOP == .) & (YN165==1 | YN165==6)
						   
*if amount missing, expenditures=YES, coverage=DK/NA/RF/unsettled:
qui sum dental_OOP
replace dental_OOP = r(mean) if (dental_OOP == .) & ///
								 (YN165==7 | YN165==8 | YN165==9)

*if amount missing, expenditures=YES, coverage=missing:
qui sum dental_OOP
replace dental_OOP = r(mean) if (dental_OOP == .) & ///
								 (YN164 == 1) & ///
								 (YN165 == .)
								 
*if amount missing, expenditures = NO:						          
replace dental_OOP = 0 if (dental_OOP == .) & (YN164 == 5)

*if amount missing, expenditures = DK/NA/RF:
qui sum dental_OOP
replace dental_OOP = r(mean) if (dental_OOP == .) & (YN164==8 | YN164==9)

*if amount missing, either died in hospice or was in hospice since last IW / in last
*2 years, and insurance coverage is known to be incomplete:
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (hospice_OOP == .) & ///
								 (YA124 == 4 | YN320 == 1) & ///
								 (YN324 == 2 | YN324 == 3 | YN324 == 5)

*if amount missing and insurance coverage complete (==1) or no charge (==6):
replace hospice_OOP = 0 if (hospice_OOP == .) & (YN324 == 1 | YN324 == 6)								 
					
*if amount missing, either died in hospice or was in hospice since last IW / in last
*2 years, and extent of insurance coverage VNknown or not asked (missing):							 
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (hospice_OOP == .) & ///
								 (YA124 == 4 | YN320 == 1) & ///
								 (YN324 == 7 | YN324 == 8 | YN324 == 9 | YN324 == .)

*if amount missing and neither died in hospice or was hospice patient:
replace hospice_OOP = 0 if (hospice_OOP == .) & (YN320 == 5) & (YA124 != 4)

*if amount missing, did not die in hospice, but unsure if hospice patient:
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (hospice_OOP == .) & ///
								 (YA124 != 4) & (YN320 == 8 | YN320 == 9)

*impute if missing, take drugs regularly, coverage is incomplete:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(YN175 == 1) & ///
							(YN176 == 2 | YN176 == 3 | YN176 == 5)

*set to 0 if missing, coverage is complete (==1) OR no charge (==6):
replace RX_OOP = 0 if (RX_OOP == .) & (YN176 == 1 | YN176 == 6)

*impute if missing, take drugs regularly, coverage VNknown or not asked:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(YN175 == 1) & ///
							(YN176 == 7 | YN176 == 8 | YN176 == 9 | YN176 == .)

*set to 0 if don't take drugs regularly:							
replace RX_OOP = 0 if (RX_OOP == .) & (YN175 == 5)

*impute if VNknown whether take drugs regularly:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & (YN175 == 8 | YN175 == 9)
								
*impute if expenses=YES, coverage=INCOMPLETE:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (YN189 == 1) & ///
							  (YN190 == 2 | YN190 == 3 | YN190 == 5)

*set to 0 if coverage=COMPLETE (==1) or no charge (==6):
replace home_OOP = 0 if (home_OOP == .) & (YN190 == 1 | YN190 == 6)

*impute if expenses=YES, coverage=DK/NA/RF/unsettled/missing:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (YN189 == 1) & ///
							  (YN190 == 7 | YN190 == 8 | YN190 == 9 | YN190 == .)

*set to 0 if expenses=NO:
replace home_OOP = 0 if (home_OOP == .) & (YN189 == 5)

*impute if expenses=DK/NA/RF:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (YN189 == 8) | (YN189 == 9) 								

*impute where expenses=YES:
qui sum other_OOP
replace other_OOP = r(mean) if (other_OOP == .) & (YN332 == 1)

*set to 0 where expenses=NO:							    
replace other_OOP = 0 if (other_OOP == .) & (YN332 == 5)

*impute where expenses=DK/NA/RF:
qui sum other_OOP
replace other_OOP = r(mean) if (other_OOP == .) & (YN332 == 8 | YN332 == 9)

*if amount missing, expenditures = YES:
qui sum home_modif_OOP
replace home_modif_OOP = r(mean) if (home_modif_OOP == .) & (YN267 == 1)									

*if amount missing, expenditures = NO:						          
replace home_modif_OOP = 0 if (home_modif_OOP == .) & (YN267 == 5)

*if amount missing, expenditures = DK/NA/RF:
qui sum home_modif_OOP
replace home_modif_OOP = r(mean) if (home_modif_OOP == .) & (YN267 == 8 | YN267 == 9)

*if amount missing, expenses=YES, had to pay=YES:							   
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & ///
							  (YN202 == 1) & ///
							  (YN203 == 1)

*if amount missing, had to pay=NO:							  							 							
replace special_OOP = 0 if (special_OOP == .) & (YN203 == 5)

*if amount missing, expenses=YES, had to pay=DK/NA/RF/missing:
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & ///
							  (YN202 == 1) & ///
							  (YN203 == 8 | YN203 == 9 | YN203 == .)

*if amount missing, expenses=NO:
replace special_OOP = 0 if (special_OOP == .) & (YN202 == 5)

*if amount missing, expenses=DK/NA/RF:
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & ///
							  (YN202 == 8 | YN202 == 9)
								
save $savedir/exit2014_oopi2.dta, replace							  



********************************************************************************

use $savedir/exit1995_oopi2.dta, clear
keep HHID PN year MC_HMO private_medigap_* hospital_NH_OOP doctor_OOP hospice_OOP RX_OOP home_special_OOP other_OOP non_med_OOP ///
	hospital_OOP NH_OOP home_OOP special_OOP
save $savedir/tmp1995.dta, replace

use $savedir/exit1996_oopi2.dta, clear
keep HHID PN year MC_HMO private_medigap_* hospital_NH_OOP doctor_OOP hospice_OOP RX_OOP home_special_OOP other_OOP non_med_OOP ///
	hospital_OOP NH_OOP home_OOP special_OOP
save $savedir/tmp1996.dta, replace

use $savedir/exit1998_oopi2.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care hospital_NH_OOP doctor_OOP hospice_OOP RX_OOP home_special_OOP other_OOP non_med_OOP ///
	hospital_OOP NH_OOP home_OOP special_OOP
save $savedir/tmp1998.dta, replace

use $savedir/exit2000_oopi2.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care hospital_NH_OOP doctor_OOP hospice_OOP RX_OOP home_special_OOP other_OOP non_med_OOP ///
	hospital_OOP NH_OOP home_OOP special_OOP
save $savedir/tmp2000.dta, replace

use $savedir/exit2002_oopi2.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care hospital_OOP NH_OOP doctor_OOP hospice_OOP RX_OOP home_OOP special_OOP other_OOP non_med_OOP
save $savedir/tmp2002.dta, replace

use $savedir/exit2004_oopi2.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care hospital_OOP NH_OOP doctor_OOP hospice_OOP RX_OOP home_OOP special_OOP other_OOP non_med_OOP
save $savedir/tmp2004.dta, replace

use $savedir/exit2006_oopi2.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care hospital_OOP NH_OOP doctor_OOP hospice_OOP RX_OOP home_OOP special_OOP other_OOP non_med_OOP
save $savedir/tmp2006.dta, replace

use $savedir/exit2008_oopi2.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care hospital_OOP NH_OOP doctor_OOP hospice_OOP RX_OOP home_OOP special_OOP other_OOP non_med_OOP
save $savedir/tmp2008.dta, replace

use $savedir/exit2010_oopi2.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP hospice_OOP RX_OOP home_OOP special_OOP ///
	other_OOP home_modif_OOP
save $savedir/tmp2010.dta, replace

use $savedir/exit2012_oopi2.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP hospice_OOP RX_OOP home_OOP special_OOP ///
	other_OOP home_modif_OOP
save $savedir/tmp2012.dta, replace


use $savedir/exit2014_oopi2.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP hospice_OOP RX_OOP home_OOP special_OOP ///
	other_OOP home_modif_OOP
save $savedir/tmp2014.dta, replace

use $savedir/tmp1995.dta, clear
append using ///
$savedir/tmp1996.dta ///
$savedir/tmp1998.dta ///
$savedir/tmp2000.dta ///
$savedir/tmp2002.dta ///
$savedir/tmp2004.dta ///
$savedir/tmp2006.dta ///
$savedir/tmp2008.dta ///
$savedir/tmp2010.dta ///
$savedir/tmp2012.dta ///
$savedir/tmp2014.dta

save $savedir/exit_oopi2.dta, replace

rm $savedir/tmp1995.dta
rm $savedir/tmp1996.dta
rm $savedir/tmp1998.dta
rm $savedir/tmp2000.dta
rm $savedir/tmp2002.dta
rm $savedir/tmp2004.dta
rm $savedir/tmp2006.dta
rm $savedir/tmp2008.dta
rm $savedir/tmp2010.dta
rm $savedir/tmp2012.dta
rm $savedir/tmp2014.dta
