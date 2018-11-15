
scalar drop _all
do load_cpi

******************************************************************************** //rrd: this section makes scalars for per night costs

use $savedir/core_all.dta, clear
drop if P==1 //appended private medigap data
merge 1:1 HHID PN year using $savedir/core_use.dta, nogen keepusing(hospital_nights nh_nights dr_visits qtile_*)

*share variables used in imputing home/special and dr/dental/outpatient in 1996-2000

*using 2002-2010 data, where a respondent reports non-missing home and special spending, we compute the share accounted for by each.

gen home_shr    = home_all    / (home_all + special_all)
gen special_shr = special_all / (home_all + special_all)

*using 2002,2010 data, where R reports non-missing for all 3 variables - doctor, dental, and outpatient spending - we compute the share accounted for by each.

gen doctor_shr  = doctor_all  / (doctor_all + patient_all + dental_all)
gen patient_shr = patient_all / (doctor_all + patient_all + dental_all)
gen dental_shr  = dental_all  / (doctor_all + patient_all + dental_all)

*because our imputations will require making imputations who report only 2 or the 3 spending categories, we also compute the share accounted for
*by each subcategory with respect to each possible pair that it may belong to.  

*doctor/dental only

gen doctor_shr_dr_dent = doctor_all  / (doctor_all + dental_all)
gen dental_shr_dr_dent = dental_all  / (doctor_all + dental_all)

*doctor/patient only

gen doctor_shr_dr_patient  = doctor_all  / (doctor_all + patient_all)
gen patient_shr_dr_patient = patient_all  / (doctor_all + patient_all)

*dental/patient only

gen patient_shr_patient_dent = patient_all / (patient_all + dental_all)
gen dental_shr_patient_dent  = dental_all  / (patient_all + dental_all)

qui summ home_shr
scalar home_shr = r(mean)
drop home_shr

qui summ special_shr
scalar special_shr = r(mean)
drop special_shr
 
qui summ doctor_shr
scalar doctor_shr = r(mean)
drop doctor_shr
 
qui summ patient_shr
scalar patient_shr = r(mean)
drop patient_shr
 
qui summ dental_shr
scalar dental_shr = r(mean)
drop dental_shr
 
qui summ doctor_shr_dr_dent
scalar doctor_shr_dr_dent = r(mean)
drop doctor_shr_dr_dent
 
qui summ dental_shr_dr_dent
scalar dental_shr_dr_dent = r(mean)
drop dental_shr_dr_dent
 
qui summ doctor_shr_dr_patient
scalar doctor_shr_dr_patient = r(mean)
drop doctor_shr_dr_patient
 
qui summ patient_shr_dr_patient
scalar patient_shr_dr_patient = r(mean)
drop patient_shr_dr_patient
 
qui summ patient_shr_patient_dent
scalar patient_shr_patient_dent = r(mean)
drop patient_shr_patient_dent
 
qui summ dental_shr_patient_dent
scalar dental_shr_patient_dent = r(mean)
drop dental_shr_patient_dent

est clear

gen hospital_per = hospital_all / hospital_nights
reg hospital_per i.qtile_hospital		//rrd: just getting cost per night in each quintile in REAL DOLLARS!
est store hospital

gen nh_per = nursing_home_all / nh_nights
reg nh_per i.qtile_nh
est store NH

gen doctor_per = doctor_all / dr_visits
reg doctor_per i.qtile_doctor
est store doctor

********************************************************************************
/*
use $savedir/core1992_oopi1.dta, clear
merge 1:1 HHID PN using $savedir/core1992_use.dta, nogen keepusing(hospital_nights nh_nights dr_visits qtile_*)

/*
//Respondent
                        
        6632    R14.    Do you have any type of health insurance coverage,
        16632           Medigap or other supplemental coverage, or long-term
                        care insurance that is purchased directly from an
                        insurance company or through a membership
                        organization such as AARP (the American Association
                        of Retired Persons)? [IMPUTED]                                                                                   

//Spouse

        6832    R37.    Does your (husband/wife/partner) have any type of
        16832           health insurance coverage, Medigap or other
                        supplemental coverage, or long-term care insurance
                        that is purchased directly from an insurance company
                        or through a membership organization such as AARP
                        (the American Association of Retired Persons)?
                        [IMPUTED]        
*/

qui summ private_ltc if PN==APN_FIN
replace private_ltc = r(mean) if missing(private_ltc) & PN==APN_FIN & (V6632==1)	//rrd: old cases of V6632 dont exist, changed to 1 

qui summ private_ltc if PN!=APN_FIN
replace private_ltc = r(mean) if missing(private_ltc) & PN!=APN_FIN & (V6832==1)		//rrd: same

//rrd: added these
replace private_ltc = 0 if missing(private_ltc) & PN==APN_FIN & (V6632==5)
replace private_ltc = 0 if missing(private_ltc) & PN!=APN_FIN & (V6832==5)
qui summ private_ltc if PN==APN_FIN
replace private_ltc = r(mean) if missing(private_ltc) & PN==APN_FIN & (V6632==.)	
qui summ private_ltc if PN!=APN_FIN
replace private_ltc = r(mean) if missing(private_ltc) & PN!=APN_FIN & (V6832==.)	


save $savedir/core1992_oopi2.dta, replace

********************************************************************************

use $savedir/core1993_oopi1.dta, clear
merge 1:1 HHID PN using $savedir/core1993_use.dta, nogen keepusing(hospital_nights nh_nights dr_visits qtile_*)

scalar z = cpi1993 / cpiBASE

qui summ private_ltc
replace private_ltc = r(mean) if missing(private_ltc) & V1859==1

replace private_ltc = 0 if missing(private_ltc) & V1859==5

qui summ private_ltc
replace private_ltc = r(mean) if missing(private_ltc) & V1859==8 | V1859==9

*impute with nights spent in NH where possible if expenses were not fully covered
est restore NH
predict x, xb
tab x qtile_nh
replace NH_OOP93 = z * x * nh_nights if NH_OOP93 == . & (V622 == 1) & (V627 != 5)
drop x

*if amount missing; either stayed overnight in NH (V622)
*insurance coverage (V627) known and incomplete:
sum NH_OOP93
replace NH_OOP93 = r(mean) if (NH_OOP93==.) & V622==1 & V627==1 

*if amount missing and insurance coverage complete:							 
replace NH_OOP93 = 0 if (NH_OOP93 == .) & V622==1 & V627==5

*if amount missing; either stayed overnight in NH (V622R)
*insurance coverage unknown or not settled or missing (not asked)
sum NH_OOP93
replace NH_OOP93 = r(mean) if (NH_OOP93 == .) & V622==1 & (V627==7 | V627==8 | V627==9 | V627==.)
					
*if amount missing and the following are true--did not stay overnight in NH
*and did not live in NH before death:
replace NH_OOP93 = 0 if (NH_OOP93 == .) & (V622==5)

*if amount missing, does not live in NH, but unsure whether stayed overnight in NH:
sum NH_OOP93
replace NH_OOP93 = r(mean)  if (NH_OOP93 == .) & (V622==8 | V622==9)

*Imputation for all non NH spending if missing value after bracket imputation. Imputation is complicated by a lack of information.
*To keep it simple, we generate indicators for whether an expense of each type occured and regress spending on the indicators.
*We use the regression to predict spending for those with missing values. 
*Where all indicators equal 0 (no spending in any category), set equal to 0.

gen x1 = !(V605==5 | V610==5) if V605!=. | V610!=.	//hospital
gen x2 = !(V639==5 | V642==5) if V639!=. | V642!=.	//doctor
gen x3 = !(V654==5 | V657==5) if V654!=. | V657!=.	//outpatient
gen x4 = !(V669==5 | V672==5) if V669!=. | V672!=.	//dentist
gen x5 = !(V685==5 | V689==5) if V685!=. | V689!=.	//drugs
gen x6 = !(V701==5 | V703==5) if V701!=. | V703!=.	//home
gen x7 = !(V715==5) if V715!=.	//special

reg non_NH_OOP93 x1 x2 x3 x4 x5 x6 x7
predict y, xb

replace non_NH_OOP93 = y if missing(non_NH_OOP93) & !(x1==0 & x2==0 & x3==0 & x4==0 & x5==0 & x6==0 & x7==0)

replace non_NH_OOP93 = 0 if missing(non_NH_OOP93) & x1==0 & x2==0 & x3==0 & x4==0 & x5==0 & x6==0 & x7==0	//no spending in any category

drop x1 x2 x3 x4 x5 x6 x7 y

save $savedir/core1993_oopi2.dta, replace

********************************************************************************

use $savedir/core1994_oopi1.dta, clear
merge 1:1 HHID PN using $savedir/core1994_use.dta, nogen keepusing(hospital_nights nh_nights dr_visits qtile_*)

scalar z = cpi1994 / cpiBASE

egen x = rownonmiss(W6705 W6707 W6708 W6709)	//rrd: how do these differentiate?
gen ephi_cov = .
replace ephi_cov = 1 if (W6705==1 | W6705==3 | W6707==1 | W6708==1 | W6708==3 | W6709==1) & x>0		//rrd: why x?
replace ephi_cov = 5 if (W6705==5 | W6705==6 | W6705==7 | W6707==5 | W6708==5 | W6708==6 | W6708==7 | W6709==5 | W6709==6 | W6709==7) & x>0 //rrd: would this ever overwrite?
replace ephi_cov = 8 if ephi_cov!=1 & ephi_cov!=5 & x>0
drop x

*EPHI

qui summ private_medigap_1		//rrd: should this be restricted to thise with ephi?
replace private_medigap_1 = r(mean) if missing(private_medigap_1) & ephi_cov==1
replace private_medigap_1 = 0 if missing(private_medigap_1) & ephi_cov==5		//rrd: assuming no coverage? why not non ephi medigap?
qui summ private_medigap_1
replace private_medigap_1 = r(mean) if missing(private_medigap_1) & ephi_cov==8

/*
        W6724   R4.     Do you currently have any type of health insurance
                        coverage obtained through your [or your (husband's/
                        wife's/partner's)] employer, former employer, or
                        union, such as Blue Cross-Blue Shield or a Health
                        Maintenance Organization?
*/

//rrd: this is other esi not indicated last time
qui summ private_medigap_2
replace private_medigap_2 = r(mean) if missing(private_medigap_2) & (W6724==1)
replace private_medigap_2 = 0 if missing(private_medigap_2) & (W6724==5)

qui summ private_medigap_3
replace private_medigap_3 = r(mean) if missing(private_medigap_3) & (W6724==1 & W6725>1)	//more than 1 plan (includes unknown # of plans)
replace private_medigap_3 = 0 if missing(private_medigap_3) & (W6724==5 | W6725==1)	//not covered or only 1 plan

*add spending for the two plans together to impute for those who are unsure if they have any insurance of this type
egen private_medigap_2_3 = rowtotal( private_medigap_2 private_medigap_3 ),m
qui summ private_medigap_2_3
replace private_medigap_2_3 = r(mean) if missing(private_medigap_2_3) & (W6724==8 | W6724==9)	//unknown whether covered

//rrd: this is other private for ind (AARP)
qui summ private_medigap_4
replace private_medigap_4 = r(mean) if missing(private_medigap_4) & (W6754==1)
replace private_medigap_4 = 0 if missing(private_medigap_4) & (W6754==5)
qui summ private_medigap_4
replace private_medigap_4 = r(mean) if missing(private_medigap_4) & (W6754==8 | W6754==9)

//rrd: this is medigap
qui summ private_medigap_5
replace private_medigap_5 = r(mean) if missing(private_medigap_5) & (W6757==1)
replace private_medigap_5 = 0 if missing(private_medigap_5) & (W6757==5)
qui summ private_medigap_5
replace private_medigap_5 = r(mean) if missing(private_medigap_5) & (W6757==8 | W6757==9)

egen private_ltc = rowtotal( private_medigap_1 ///				//use this name because spending is not purely private/medigap: includes ltc
							 private_medigap_2_3 ///
							 private_medigap_4 ///
							 private_medigap_5),m

replace private_ltc = min( private_ltc, 2000*z ) if !missing(private_ltc)	//cap reflects fact that LTC spending may be included

/* hospital + NH + doctor*/

/*
                        1.      Completely covered by health insurance
                        2.      Paid for entirely out-of-pocket
                        3.      Partly covered by health insurance
                                (partly by R)
                        4.      Paid by other person (relative, previous
                                spouse/partner)
                        5.      Paid by current/previous employer/union
                        6.      Free or Did Not Pay (e.g., free clinic; "a
                                friend is a doctor"; "could not pay"; "still
                                owe")

                        7.      Other (specify)

                        8.      Don't Know/Not Ascertained; DK/NA
                        9.      Refused/Not Ascertained; RF/NA                                
*/

/* hospital */

gen hospital_OOP = .

*all spending is hospital if R reports hospital utilization not completely covered by insurance and 
*either (a) no NH utilization or (b) NH expenses fully covered AND
*either (c) no doctor utilization or (d) doctor expenses covered by insurance
replace hospital_OOP = hospital_NH_doctor_OOP if (W410==1 & W414!=1 & W414!=4 & W414!=5 & W414!=6) & ///
										  		 (W415==5 | W419==1 | W419==4 | W419==5 | W414==6) & ///
										  		 (W420==0 | W421==1 | W421==4 | W421==5 | W421==6)		//rrd: hop only, no doc, no nh

*cap at 15000*z*months
replace hospital_OOP = min( 15000*z*months , hospital_OOP ) if !missing(hospital_OOP)

*impute with nights spent in hospital where possible if expenses were not fully covered
est restore hospital
predict x, xb
tab x qtile_hospital
replace hospital_OOP = z * x * hospital_nights if hospital_OOP == . & (W410==1) & (W414!=1 & W414!=4 & W414!=5 & W414!=6)
drop x

*if amount missing, and there are expenses that are known to be not fully covered, and nights not available:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if hospital_OOP == . & (W410==1) & (414==2 | W414==3)		//rrd: changed these latter 2 be W414

*if amount missing, and expenses ARE fully covered:
replace hospital_OOP = 0 if (hospital_OOP==.) & (W414==1 | W414==4 | W414==5 | W414==6)

*if expenses==YES, amount missing, and coverage of expenses is DK/RF/NA costs are unsettled (==7), or missing (interviewee should have been asked but was not):
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & (W410==1) & (W414==7 | W414==8 | W414==9 | W414==.)  //rrd: changed these latter 4 be W414

*if amount missing and did not spend night in hospital:
replace hospital_OOP = 0 if (hospital_OOP==.) & (W410==5)		//rrd: consider using hospotal_use var

*if utilization is DK/NA/RF and amount missing:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & (W410==7 | W410==8 | W410==9)

/* NH */

gen NH_OOP = .

*all spending is NH if R reports NH utilization not completely covered by insurance and 
*either (a) no hospital utilization or (b) hospital expenses fully covered AND
*either (c) no doctor utilization or (d) doctor expenses covered by insurance
replace NH_OOP = hospital_NH_doctor_OOP if (W410==5 | W414==1 | W414==4 | W414==5 | W414==6) & ///
										   (W415==1 & W419!=1 & W419!=4 & W419!=5 & W414!=6) & ///
										   (W420==0 | W421==1 | W421==4 | W421==5 | W421==6)		//rrd: nh only no host no doc

*cap at 15000*z*months
replace NH_OOP = min( 15000*z*months , NH_OOP ) if !missing(NH_OOP)

*impute with nights spent in NH where possible if expenses were not fully covered
est restore NH
predict x, xb
tab x qtile_nh
replace NH_OOP = z * x * nh_nights if NH_OOP == . & (W415==1 & W419!=1 & W419!=4 & W419!=5 & W414!=6)
drop x

*if amount missing, and there are expenses that are not fully covered, and nights not available:
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & (W415==1) & (W419==2 | W419==3)

*if amount missing, and expenses ARE fully covered:
replace NH_OOP = 0 if (NH_OOP==.) & (W419==1 | W419==4 | W419==5 | W419==6)

*if expenses==YES, amount missing, and coverage of expenses is DK/RF/NA, 
*costs are unsettled (==7), or missing (interviewee should have been asked but was not):
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & (W415==1) & (W419==7 | W419==8 | W419==9 | W419==.)

*if amount missing and did not spend night in NH (and didnt live in NH) or hospital:
replace NH_OOP = 0 if NH_OOP==. & (W415==5)						

*if didn't live in NH, overnight stay is DK/NA/RF and amount missing:
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & (W415==7 | W415==8 | W415==9)

/* doctor */

gen doctor_OOP = .

*all spending is doctor if R reports doctor utilization not completely covered by insurance and 
*either (a) no hospital utilization or (b) hospital expenses fully covered AND
*either (c) no NH utilization or (d) NH expenses covered by insurance
replace doctor_OOP = hospital_NH_doctor_OOP if (W410==5 | W414==1 | W414==4 | W414==5 | W414==6) & ///
										       (W415==5 | W419==1 | W419==4 | W419==5 | W414==6) & ///
										       (W420>0 & W420<=994 & W421!=1 & W421!=4 & W421!=5 & W421!=6)

*cap at 5000*z*months
replace doctor_OOP = min( 5000*z*months , doctor_OOP ) if !missing(doctor_OOP)

*impute with nights spent in NH where possible if expenses were not fully covered
est restore doctor
predict x, xb
tab x qtile_doctor
replace doctor_OOP = z * x * dr_visits if doctor_OOP == . & (W420>0 & W420<=994 & W421!=1 & W421!=4 & W421!=5 & W421!=6)
drop x

*if amount missing, and there are expenses that are not fully covered, and nights not available:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP==.) & (W420>0 & W420<=994) & (W421==2 | W421==3)		//rrd: nights not avil means W420 is missing so this is null. huh?

*if amount missing, and expenses ARE fully covered:
replace doctor_OOP = 0 if (doctor_OOP==.) & (W421==1 | W421==4 | W421==5 | W421==6)		//rrd: need we check use==1?

*if expenses==YES, amount missing, and coverage of expenses is DK/RF/NA, 
*costs are unsettled (==7), or missing (interviewee should have been asked but was not):
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP==.) & (W420>0 & W420<=994) & (W421==7 | W421==8 | W421==9 | W421==.)

*if amount missing and did not spend night in doctor (and didnt live in doctor) or hospital:
replace doctor_OOP = 0 if doctor_OOP==. & (W420==0)						

*if doctor is DK/NA/RF and amount missing:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP==.) & (W420==997 | W420==998 | W420==999)

*summing our independent imputations for hospital, NH, and doctor:
egen X = rowtotal( hospital_OOP NH_OOP doctor_OOP ), missing

*re-scaling where an original sum is available in the data or where one has been imputed using brackets and our imputed sum is not equal to zero:
replace hospital_OOP = hospital_OOP * (hospital_NH_doctor_OOP / X) if !missing(hospital_NH_doctor_OOP) & X != 0
replace NH_OOP = NH_OOP * (hospital_NH_doctor_OOP / X) if !missing(hospital_NH_doctor_OOP) & X != 0
replace doctor_OOP = doctor_OOP * (hospital_NH_doctor_OOP / X) if !missing(hospital_NH_doctor_OOP) & X != 0

*fill in missing values of the original variable (where brackets were not available) with the sum of imputed hospital and NH spending.
replace hospital_NH_doctor_OOP = X if missing(hospital_NH_doctor_OOP)
drop X

*impose cap of $35000 (BASE YEAR dollars) per month (on average) for the sum and $15000 for hospital and NH and $5000 for doctor:
replace hospital_NH_doctor_OOP = min( 35000*z*months , hospital_NH_doctor_OOP) if !missing(hospital_NH_doctor_OOP)
replace hospital_OOP = min( 15000*z*months , hospital_OOP ) if !missing(hospital_OOP)
replace NH_OOP = min( 15000*z*months , NH_OOP ) if !missing(NH_OOP)
replace doctor_OOP = min( 5000*z*months , doctor_OOP ) if !missing(doctor_OOP)

qui summ RX_OOP
replace RX_OOP = r(mean) if missing(RX_OOP) & W433==1

replace RX_OOP = 0 if missing(RX_OOP) & W433==5

qui summ RX_OOP
replace RX_OOP = r(mean) if missing(RX_OOP) & (W433==8 | W433==9)

save $savedir/core1994_oopi2.dta, replace

********************************************************************************

use $savedir/core1995_oopi1.dta, clear
merge 1:1 HHID PN using $savedir/core1995_use.dta, nogen keepusing(hospital_nights nh_nights dr_visits qtile_*)

scalar z = cpi1995 / cpiBASE

*if amount missing, expenses=YES:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (D5183 == 1)

*if amount missing, expenses=NO:
replace MC_HMO = 0 if (MC_HMO == .) & (D5183 == 5)

*if amount missing, expenses=DK/NA/RF:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (D5183 == 8 | D5183 == 9)

*if missing, coverage=YES:
qui sum long_term_care
replace long_term_care = r(mean) if (long_term_care == .) & (D5263 == 1)

*if missing, coverage=NO:
replace long_term_care = 0 if (long_term_care == .) & (D5263 == 5)

*if missing, coverage=DK/NA/RF:
qui sum long_term_care
replace long_term_care = r(mean) if (long_term_care == .) & (D5263 == 7 | D5263 == 8 | D5263 == 9)

qui summ private_medigap_1
//rrd: D5263 in next line should use D5214     or D5215     or D5225M1   !!!
replace private_medigap_1 = r(mean) if missing(private_medigap_1) & D5214==1 & (D5226!=2)	//if has insurance, premium not paid entirely by employer/union
replace private_medigap_1 = 0 if missing(private_medigap_1) & (D5214==5 | D5226==2)		//if no insurance, of premium entirely paid

qui summ private_medigap_2
//rrd: D5263 in next two line should be D5214     or D5215   ;  second D5215 should be D5226/D5243          
replace private_medigap_2 = r(mean) if missing(private_medigap_2) & D5214==1 & D5215>=2 & D5226!=2	//if has insurance, #plans >=2, not fully paid
//rrd: see above
replace private_medigap_2 = 0 if missing(private_medigap_2) & (D5214==5 | D5215==1 | D5226==2)	//if no insurance, only 1 plan, or fully paid

egen private_medigap = rowtotal( private_medigap_1 ///
								 private_medigap_2 ) , missing

qui summ private_medigap
replace private_medigap = r(mean) if missing(private_medigap) & (D5214==8 | D5214==9)	//if unsure of whether has insurance

replace private_medigap = min( private_medigap , cond(D5144==1,400*z,2000*z) ) if !missing(private_medigap)

gen hospital_OOP = .

*all spending is hospital if R reports hospital utilization not completely covered by insurance and either (a) no NH utilization or 
*(b) NH expenses fully covered
replace hospital_OOP = hospital_NH_OOP if (D1664==1 & D1669!=1) & ((D1681==5 & D240!=1) | D1686==1)

*cap at 15000*z*months
replace hospital_OOP = min( 15000*z*months , hospital_OOP ) if !missing(hospital_OOP)

*impute with nights spent in hospital where possible if expenses were not fully covered
est restore hospital
predict x, xb				//rrd: these should be coverted to nominal dolalrs (just mult by z)
tab x qtile_hospital
replace hospital_OOP = z * x * hospital_nights if hospital_OOP == . & (D1664==1) & (D1669!=1)  //rrd: added z*
drop x

*if amount missing, and there are expenses that are known to be not fully covered, and nights not available:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if hospital_OOP == . & (D1664==1) & (D1669==3 | D1669==5)

*if amount missing, and expenses ARE fully covered:
replace hospital_OOP = 0 if (hospital_OOP==.) & (D1669==1)

*if expenses==YES, amount missing, and coverage of expenses is DK/RF/NA, 
*costs are unsettled (==7), or missing (interviewee should have been asked but was not):
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & (D1664==1) & (D1669==7 | D1669==8 | D1669==9 | D1669==.)

*if amount missing and did not spend night in hospital:
replace hospital_OOP = 0 if (hospital_OOP==.) & (D1664==5)

*if utilization is DK/NA/RF and amount missing:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & (D1664==8 | D1664==9)

gen NH_OOP = .

*all spending is NH if R reports NH utilization not completely covered by insurance and either (a) no hospital utilization or 
*(b) all hospital expenses fully covered
replace NH_OOP = hospital_NH_OOP if ((D1681==1 | D240==1) & D1686!=1) & (D1664==5 | D1669==1)

*cap at 15000*z*months
replace NH_OOP = min( 15000*z*months , NH_OOP ) if !missing(NH_OOP)

*impute with nights spent in NH where possible if expenses were not fully covered
est restore NH
predict x, xb
tab x qtile_nh
replace NH_OOP = z * x * nh_nights if NH_OOP == . & (D1681==1 | D240==1) & (D1686!=1)
drop x

*if amount missing, and there are expenses that are not fully covered, and nights not available:
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & (D1681==1 | D240==1) & (D1686==3 | D1686==5)

*if amount missing, and expenses ARE fully covered:
replace NH_OOP = 0 if (NH_OOP==.) & (D1686==1)

*if expenses==YES, amount missing, and coverage of expenses is DK/RF/NA, 
*costs are unsettled (==7), or missing (interviewee should have been asked but was not):
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & (D1681==1 | D240==1) & (D1686==7 | D1686==8 | D1686==9 | D1686==.)

*if amount missing and did not spend night in NH (and didnt live in NH) or hospital:
replace NH_OOP = 0 if NH_OOP==. & (D1681==5 & D240!=1)						

*if didn't live in NH, overnight stay is DK/NA/RF and amount missing:
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & (D240!=1) & (D1681==8 | D1681==9)

*caps
replace hospital_OOP = min( 15000*z*months , hospital_OOP ) if !missing(hospital_OOP)
replace NH_OOP = min( 15000*z*months , NH_OOP ) if !missing(NH_OOP)

*summing our independent imputations for hospital and NH:
egen hospital_NH_OOP_imputed = rowtotal( hospital_OOP NH_OOP ), missing

*re-scaling where an original sum is available in the data or where one has been imputed using brackets and our imputed sum is not equal to zero:
replace hospital_OOP = hospital_OOP * (hospital_NH_OOP / hospital_NH_OOP_imputed) if !missing(hospital_NH_OOP) & hospital_NH_OOP_imputed != 0
replace NH_OOP = NH_OOP * (hospital_NH_OOP / hospital_NH_OOP_imputed) if !missing(hospital_NH_OOP) & hospital_NH_OOP_imputed != 0

*fill in missing values of the original variable (where brackets were not available) with the sum of imputed hospital and NH spending.
replace hospital_NH_OOP = hospital_NH_OOP_imputed if missing(hospital_NH_OOP)
drop hospital_NH_OOP_imputed

gen doctor_OOP = .
gen dental_OOP = .
gen patient_OOP = .

*dr expenses only
replace doctor_OOP = doctor_patient_dental_OOP ///
						if (D1698>0 & D1698<997 & D1701!=1) & (D1713==5 | D1716==1) & (D1728==5 | D1731==1)

*patient expenses only
replace patient_OOP = doctor_patient_dental_OOP ///
						if (D1698==0 | D1701==1) & (D1713==1 & D1716!=1) & (D1728==5 | D1731==1)
						
*dental expenses only
replace dental_OOP = doctor_patient_dental_OOP ///
						if (D1698==0 | D1701==1) & (D1713==5 | D1716==1) & (D1728==1 & D1731!=1)

*dr, patient, and dental expenses
replace doctor_OOP = doctor_shr * doctor_patient_dental_OOP ///
						if (D1698>0 & D1698<997 & D1701!=1) & (D1713==1 & D1716!=1) & (D1728==1 & D1731!=1)

replace patient_OOP = patient_shr * doctor_patient_dental_OOP ///
						if (D1698>0 & D1698<997 & D1701!=1) & (D1713==1 & D1716!=1) & (D1728==1 & D1731!=1)

replace dental_OOP = dental_shr * doctor_patient_dental_OOP ///
						if (D1698>0 & D1698<997 & D1701!=1) & (D1713==1 & D1716!=1) & (D1728==1 & D1731!=1)

*dr and dental expenses only
replace doctor_OOP = doctor_shr_dr_dent * doctor_patient_dental_OOP ///
						if (D1698>0 & D1698<997 & D1701!=1) & (D1713==5 | D1716==1) & (D1728==1 & D1731!=1)

replace dental_OOP = dental_shr_dr_dent * doctor_patient_dental_OOP ///
						if (D1698>0 & D1698<997 & D1701!=1) & (D1713==5 | D1716==1) & (D1728==1 & D1731!=1)

*dr and patient expenses only
replace doctor_OOP = doctor_shr_dr_patient * doctor_patient_dental_OOP ///
						if (D1698>0 & D1698<997 & D1701!=1) & (D1713==1 & D1716!=1) & (D1728==5 | D1731!=1) 

replace patient_OOP = patient_shr_dr_patient * doctor_patient_dental_OOP ///
						if (D1698>0 & D1698<997 & D1701!=1) & (D1713==1 & D1716!=1) & (D1728==5 | D1731!=1)

*patient and dental expenses only
replace patient_OOP = patient_shr_patient_dent * doctor_patient_dental_OOP ///
						if (D1698==0 | D1701==1) & (D1713==1 & D1716!=1) & (D1728==1 & D1731!=1)
						
replace dental_OOP = dental_shr_patient_dent * doctor_patient_dental_OOP ///
						if (D1698==0 | D1701==1) & (D1713==1 & D1716!=1) & (D1728==1 & D1731!=1)

*Now the imputation proceeds as a typical imputation taking our imputed data as real data and filling in the rest using the
*utilization and coverage information, imputing with means or zeros wherever applicable:

*impose caps: doctor=5000, dental=1000, outpatient=15000)
replace doctor_OOP = min( 5000*z*months , doctor_OOP) if !missing(doctor_OOP)
replace patient_OOP = min( 15000*z*months , patient_OOP) if !missing(patient_OOP)
replace dental_OOP = min( 1000*z*months , dental_OOP) if !missing(dental_OOP)

*impute using doctor visits if possible where expenses not fully covered
est restore doctor
predict x, xb
tab x qtile_doctor
replace doctor_OOP = z * x * dr_visits if doctor_OOP==. & (dr_visits > 0 & dr_visits < .) & D1701!=1
drop x

*if amount missing, and there are expenses that are not fully covered:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP==.) & ///
										   (D1701==3 | D1701==5)

qui summ patient_OOP
replace patient_OOP = r(mean) if (patient_OOP==.) & ///
	   										  (D1716==3 | D1716==5)		//rrd: need we check use?

qui summ dental_OOP
replace dental_OOP = r(mean) if (dental_OOP==.) & ///
	   										 (D1731==3 | D1731==5)

*if amount missing, and expenses ARE fully covered:
replace doctor_OOP = 0 if (doctor_OOP==.) & ///
							 (D1701==1)
								 
replace patient_OOP = 0 if (patient_OOP==.) & ///
							    (D1716==1)

replace dental_OOP = 0 if (dental_OOP==.) & ///
							   (D1731==1)

*if expenses==YES, amount missing, and coverage of expenses is DK/RF/NA, 
*costs are unsettled (==7), or missing (interviewee should have been asked but was not):
qui summ doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP==.) & ///
										   (D1698 > 0 & D1698 < 998) & ///
									(D1701==7 | D1701==8 | D1701==9 | D1701==.)

qui summ patient_OOP
replace patient_OOP = r(mean) if (patient_OOP==.) & ///
	   										  (D1713==1) & ///
	   								(D1716==7 | D1716==8 | D1716==9 | D1716==.)

qui summ dental_OOP
replace dental_OOP = r(mean) if (dental_OOP==.) & ///
	   										 (D1728==1) & ///
	   								(D1731==7 | D1731==8 | D1731==9 | D1731==.)
	   								
*if amount missing and no doctor visit, outpatient surgery, dentist visit:
replace doctor_OOP = 0 if (doctor_OOP==.) & ///
							 (D1698==0)

replace patient_OOP = 0 if (patient_OOP==.) & ///
							    (D1713==5)						

replace dental_OOP = 0 if (dental_OOP==.) & ///
							   (D1728==5)
							    
*if doctor visit, outpatient surgery, dental visit is DK/NA/RF and amount missing:
qui summ doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP==.) & ///
										   (D1698==998 | D1698==999)

qui summ patient_OOP											   
replace patient_OOP = r(mean) if (patient_OOP==.) & ///
											  (D1713==8 | D1713==9)

qui summ dental_OOP
replace dental_OOP = r(mean) if (dental_OOP==.) & ///
											 (D1728==8 | D1728==9)

*caps
replace doctor_OOP = min( 5000*z*months , doctor_OOP) if !missing(doctor_OOP)
replace patient_OOP = min( 15000*z*months , patient_OOP) if !missing(patient_OOP)
replace dental_OOP = min( 1000*z*months , dental_OOP) if !missing(dental_OOP)
											  
*summing
egen doctor_patient_dental_OOP_imp = rowtotal( doctor_OOP patient_OOP dental_OOP ), missing

*re-scaling where an original sum is available in the data or where one has been imputed using brackets and our imputed sum is not equal to zero:
replace doctor_OOP = doctor_OOP * (doctor_patient_dental_OOP / doctor_patient_dental_OOP_imp) ///
						if !missing(doctor_patient_dental_OOP) & doctor_patient_dental_OOP_imp != 0
						
replace patient_OOP = patient_OOP * (doctor_patient_dental_OOP / doctor_patient_dental_OOP_imp) ///
						if !missing(doctor_patient_dental_OOP) & doctor_patient_dental_OOP_imp != 0
						
replace dental_OOP = dental_OOP * (doctor_patient_dental_OOP / doctor_patient_dental_OOP_imp) ///
						if !missing(doctor_patient_dental_OOP) & doctor_patient_dental_OOP_imp != 0

*fill in missing values of the original variable (where brackets/original data were not available) with the sum of imputed spending.
replace doctor_patient_dental_OOP = doctor_patient_dental_OOP_imp if missing(doctor_patient_dental_OOP)
drop doctor_patient_dental_OOP_imp	

*impute if missing, take drugs regularly, coverage is incomplete:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(D1748 == 2 | D1748 == 3 | D1748 == 5)

*set to 0 if missing, coverage is complete (==1) OR no charge (==6):
replace RX_OOP = 0 if (RX_OOP == .) & (D1748 == 1 | D1748 == 6)

*impute if missing, take drugs and coverage=DK/NA/RF/unsettled:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(D1748 == 7 | D1748 == 8 | D1748 == 9)

*impute if missing, take drugs regularly (D1744==1) or medications known (==7), 
*and coverage info is missing:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(D1744 == 1) & ///
							(D1748 == .)
							
*set to 0 if don't take drugs regularly:							
replace RX_OOP = 0 if (RX_OOP == .) & (D1744 == 5)

*impute if unknown whether take drugs regularly:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & (D1744 == 8 | D1744 == 9)

gen home_OOP = .
gen special_OOP = .

*home expenses only
replace home_OOP = home_special_OOP if (D1760==1 & D1762!=1 & D1762!=6) & (D1774==5)

*special expenses only
replace special_OOP = home_special_OOP if (D1760==5 | D1762==1 | D1762==6) & (D1774==1)

*if home and special both reported:
replace home_OOP = home_shr * home_special_OOP if (D1760==1 & D1762!=1 & D1762!=6) & (D1774==1)
replace special_OOP = special_shr * home_special_OOP if (D1760==1 & D1762!=1 & D1762!=6) & (D1774==1)

*Now the imputation proceeds as a typical imputation taking our imputed data as real data and filling in the rest using the
*utilization and coverage information, imputing with means or zeros wherever applicable:

*cap expenses at 15000 each (BASE YEAR dollars) per month (on average):
replace home_OOP = min( 15000*z* months , home_OOP ) if !missing(home_OOP)
replace special_OOP = min( 15000*z* months , special_OOP ) if !missing(special_OOP)

*impute if expenses=YES, coverage=INCOMPLETE:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
					        		  	   (D1762 == 3 | D1762 == 5)

*if we assume all special facility/service expenses are completely uncovered:
qui sum special_OOP
replace special_OOP = r(mean) if (home_OOP == .) & (D1774==1)

*set to 0 if coverage=COMPLETE (==1) or no charge (==6):
replace home_OOP = 0 if (home_OOP == .) & (D1762 == 1 | D1762==6)

*impute if expenses=YES, coverage=DK/NA/RF/unsettled/missing:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP==.) & ///
							  			   (D1760 == 1) & ///
							  (D1762 == 7 | D1762 == 8 | D1762 == 9 | D1762 == .)

*set to 0 if expenses=NO:
replace home_OOP = 0 if (home_OOP == .) & ///
							 (D1760 == 5)

replace special_OOP = 0 if (special_OOP == .) & ///
							 (D1774 == 5)

*impute if expenses=DK/NA/RF:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == . ) & ///
							  			   (D1760 == 8 | D1760 == 9)

qui summ special_OOP
replace special_OOP = r(mean) if (special_OOP == . ) & ///
										   (D1774 == 8 | D1774 == 9)

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

save $savedir/core1995_oopi2.dta, replace

********************************************************************************

use $savedir/core1996_oopi1.dta, clear
merge 1:1 HHID PN using $savedir/core1996_use.dta, nogen keepusing(hospital_nights nh_nights dr_visits qtile_*)

scalar z = cpi1996 / cpiBASE

*if amount missing, expenses=YES:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (E5148 == 1)

*if amount missing, expenses=NO:
replace MC_HMO = 0 if (MC_HMO == .) & (E5148 == 5)

*if amount missing, expenses=DK/NA/RF:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (E5148 == 8 | E5148 == 9)

*if missing, coverage=YES:
qui sum long_term_care
replace long_term_care = r(mean) if (long_term_care == .) & (E5266 == 1)

*if missing, coverage=NO:
replace long_term_care = 0 if (long_term_care == .) & (E5266 == 5)

*if missing, coverage=DK/NA/RF:
qui sum long_term_care
replace long_term_care = r(mean) if (long_term_care == .) & (E5266 == 7 | E5266 == 8 | E5266 == 9)

/*
          R13. (Not including Medicare/Medicaid/Champus-Champva) are you covered by
          any employer-provided health insurance?
*/

*EPHI, plan #1

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1 == .) & ///
									   (E5166_1 == 1 | E5166_1 == 2)

*if amount missing, pay NONE ("3") of costs:
replace private_medigap_1 = 0 if (private_medigap_1  == .) & (E5166_1 == 3)

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1==.) & ///
									   (E5166_1 == 7 | E5166_1 == 8 | E5166_1 == 9)

*if amount missing, no insurance through employer									   
replace private_medigap_1 = 0 if (private_medigap_1==.) & (E5160==5)

*EPHI, plan #2

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2 == .) & ///
									   (E5166_2 == 1 | E5166_2 == 2)

*if amount missing, pay NONE ("3") of costs:
replace private_medigap_2 = 0 if (private_medigap_2  == .) & (E5166_2 == 3)

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2==.) & ///
									   (E5166_2 == 7 | E5166_2 == 8 | E5166_2 == 9)

*if amount missing, no insurance through employer									   
replace private_medigap_2 = 0 if (private_medigap_2==.) & (E5160==5)

*total for EPHI, plan 1 + 2, for imputation for those who are unsure whether they have EPHI:

egen private_medigap_1_2 = rowtotal(private_medigap_1 private_medigap_2), m

*if amount missing, unsure whether insured through employer
qui sum private_medigap_1_2
replace private_medigap_1_2 = r(mean) if (private_medigap_1_2==.) & ///
									   (E5160 == 8 | E5160 == 9)

/*
          R46. Not counting long-term care insurance or Medicare, (or Medicaid/or any
          other insurance we've discussed), do you have any other insurance that pays
          any part of hospital or doctor bills? Sometimes this is called a Medigap or
          Medicare Supplement policy.
*/
									   
*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if (private_medigap_3 == .) & ///
									   (E5208 == 1 | E5208 == 2)

*if amount missing, pay NONE ("3") of costs:
replace private_medigap_3 = 0 if (private_medigap_3  == .) & (E5208 == 3)

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if (private_medigap_3==.) & ///
									   (E5208 == 8 | E5208 == 9)

*if amount missing, no other insurance									   
replace private_medigap_3 = 0 if (private_medigap_3==.) & (E5206==5)

*if amount missing, unsure whether other insurance
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if (private_medigap_3==.) & ///
									   (E5206 == 8 | E5206 == 9)

/*
          R48. Do you have any basic health insurance coverage purchased directly from
          an insurance company or through a membership organization?
*/

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_4
replace private_medigap_4 = r(mean) if (private_medigap_4 == .) & ///
									   (E5220 == 1 | E5220 == 2)

*if amount missing, pay NONE ("3") of costs:
replace private_medigap_4 = 0 if (private_medigap_4  == .) & (E5220 == 3)

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_4
replace private_medigap_4 = r(mean) if (private_medigap_4==.) & ///
									   (E5220 == 8 | E5220 == 9)

*if amount missing, no other insurance									   
replace private_medigap_4 = 0 if (private_medigap_4==.) & (E5218 ==5)

*if amount missing, unsure whether other insurance
qui sum private_medigap_4
replace private_medigap_4 = r(mean) if (private_medigap_4==.) & ///
									   (E5218 == 8 | E5218 == 9)									   									   									   

egen private_medigap = rowtotal( private_medigap_1_2 ///
								 private_medigap_3 ///
								 private_medigap_4 ) , missing

replace private_medigap = min( private_medigap , cond(E5133==1,400*z,2000*z) ) if !missing(private_medigap)

gen hospital_OOP = .

*all spending is hospital if R reports hospital utilization not completely covered by insurance and either (a) no NH utilization or 
*(b) NH expenses fully covered
replace hospital_OOP = hospital_NH_OOP if (E1770==1 & E1775!=1) & ((E1776==5 & E240!=1) | E1781==1)

*cap at 15000*z*months
replace hospital_OOP = min( 15000*z*months , hospital_OOP ) if !missing(hospital_OOP)

*impute with nights spent in hospital where possible if expenses were not fully covered
est restore hospital
predict x, xb
tab x qtile_hospital
replace hospital_OOP = z * x * hospital_nights if hospital_OOP == . & (E1770==1) & (E1775!=1)
drop x

*if amount missing, and there are expenses that are known to be not fully covered, and nights not available:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if hospital_OOP == . & (E1770==1) & (E1775==3 | E1775==5)

*if amount missing, and expenses ARE fully covered:
replace hospital_OOP = 0 if (hospital_OOP==.) & (E1775==1)

*if expenses==YES, amount missing, and coverage of expenses is DK/RF/NA, 
*costs are unsettled (==7), or missing (interviewee should have been asked but was not):
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & (E1770==1) & (E1775==7 | E1775==8 | E1775==9 | E1775==.)

*if amount missing and did not spend night in hospital:
replace hospital_OOP = 0 if (hospital_OOP==.) & (E1770==5)

*if utilization is DK/NA/RF and amount missing:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & (E1770==8 | E1770==9)

gen NH_OOP = .

*all spending is NH if R reports NH utilization not completely covered by insurance and either (a) no hospital utilization or 
*(b) all hospital expenses fully covered
replace NH_OOP = hospital_NH_OOP if ((E1776==1 | E240==1) & E1781!=1) & (E1770==5 | E1775==1)

*cap at 15000*z*months
replace NH_OOP = min( 15000*z*months , NH_OOP ) if !missing(NH_OOP)

*impute with nights spent in NH where possible if expenses were not fully covered
est restore NH
predict x, xb
tab x qtile_nh
replace NH_OOP = z * x * nh_nights if NH_OOP == . & (E1776==1 | E240==1) & (E1781!=1)
drop x

*if amount missing, and there are expenses that are not fully covered, and nights not available:
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & (E1776==1 | E240==1) & (E1781==3 | E1781==5)

*if amount missing, and expenses ARE fully covered:
replace NH_OOP = 0 if (NH_OOP==.) & (E1781==1)

*if expenses==YES, amount missing, and coverage of expenses is DK/RF/NA, 
*costs are unsettled (==7), or missing (interviewee should have been asked but was not):
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & (E1776==1 | E240==1) & (E1781==7 | E1781==8 | E1781==9 | E1781==.)

*if amount missing and did not spend night in NH (and didnt live in NH) or hospital:
replace NH_OOP = 0 if NH_OOP==. & (E1776==5 & E240!=1)						

*if didn't live in NH, overnight stay is DK/NA/RF and amount missing:
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & (E240!=1) & (E1776==8 | E1776==9)

*caps
replace hospital_OOP = min( 15000*z*months , hospital_OOP ) if !missing(hospital_OOP)
replace NH_OOP = min( 15000*z*months , NH_OOP ) if !missing(NH_OOP)

*summing our independent imputations for hospital and NH:
egen hospital_NH_OOP_imputed = rowtotal( hospital_OOP NH_OOP ), missing

*re-scaling where an original sum is available in the data or where one has been imputed using brackets and our imputed sum is not equal to zero:
replace hospital_OOP = hospital_OOP * (hospital_NH_OOP / hospital_NH_OOP_imputed) if !missing(hospital_NH_OOP) & hospital_NH_OOP_imputed != 0
replace NH_OOP = NH_OOP * (hospital_NH_OOP / hospital_NH_OOP_imputed) if !missing(hospital_NH_OOP) & hospital_NH_OOP_imputed != 0

*fill in missing values of the original variable (where brackets were not available) with the sum of imputed hospital and NH spending.
replace hospital_NH_OOP = hospital_NH_OOP_imputed if missing(hospital_NH_OOP)
drop hospital_NH_OOP_imputed

gen doctor_OOP = .
gen dental_OOP = .
gen patient_OOP = .

*dr expenses only
replace doctor_OOP = doctor_patient_dental_OOP ///
						if (E1790>0 & E1790<997 & E1793!=1) & (E1795==5 | E1798==1) & (E1800==5 | E1803==1)

*patient expenses only
replace patient_OOP = doctor_patient_dental_OOP ///
						if (E1790==0 | E1793==1) & (E1795==1 & E1798!=1) & (E1800==5 | E1803==1)
						
*dental expenses only
replace dental_OOP = doctor_patient_dental_OOP ///
						if (E1790==0 | E1793==1) & (E1795==5 | E1798==1) & (E1800==1 & E1803!=1)

*dr, patient, and dental expenses
replace doctor_OOP = doctor_shr * doctor_patient_dental_OOP ///
						if (E1790>0 & E1790<997 & E1793!=1) & (E1795==1 & E1798!=1) & (E1800==1 & E1803!=1)

replace patient_OOP = patient_shr * doctor_patient_dental_OOP ///
						if (E1790>0 & E1790<997 & E1793!=1) & (E1795==1 & E1798!=1) & (E1800==1 & E1803!=1)

replace dental_OOP = dental_shr * doctor_patient_dental_OOP ///
						if (E1790>0 & E1790<997 & E1793!=1) & (E1795==1 & E1798!=1) & (E1800==1 & E1803!=1)

*dr and dental expenses only
replace doctor_OOP = doctor_shr_dr_dent * doctor_patient_dental_OOP ///
						if (E1790>0 & E1790<997 & E1793!=1) & (E1795==5 | E1798==1) & (E1800==1 & E1803!=1)

replace dental_OOP = dental_shr_dr_dent * doctor_patient_dental_OOP ///
						if (E1790>0 & E1790<997 & E1793!=1) & (E1795==5 | E1798==1) & (E1800==1 & E1803!=1)

*dr and patient expenses only
replace doctor_OOP = doctor_shr_dr_patient * doctor_patient_dental_OOP ///
						if (E1790>0 & E1790<997 & E1793!=1) & (E1795==1 & E1798!=1) & (E1800==5 | E1803!=1) 

replace patient_OOP = patient_shr_dr_patient * doctor_patient_dental_OOP ///
						if (E1790>0 & E1790<997 & E1793!=1) & (E1795==1 & E1798!=1) & (E1800==5 | E1803!=1)

*patient and dental expenses only
replace patient_OOP = patient_shr_patient_dent * doctor_patient_dental_OOP ///
						if (E1790==0 | E1793==1) & (E1795==1 & E1798!=1) & (E1800==1 & E1803!=1)
						
replace dental_OOP = dental_shr_patient_dent * doctor_patient_dental_OOP ///
						if (E1790==0 | E1793==1) & (E1795==1 & E1798!=1) & (E1800==1 & E1803!=1)

*Now the imputation proceeds as a typical imputation taking our imputed data as real data and filling in the rest using the
*utilization and coverage information, imputing with means or zeros wherever applicable:

*impose caps: doctor=5000, dental=1000, outpatient=15000)
replace doctor_OOP = min( 5000*z*months , doctor_OOP) if !missing(doctor_OOP)
replace patient_OOP = min( 15000*z*months , patient_OOP) if !missing(patient_OOP)
replace dental_OOP = min( 1000*z*months , dental_OOP) if !missing(dental_OOP)

*impute using doctor visits if possible where expenses not fully covered
est restore doctor
predict x, xb
tab x qtile_doctor
replace doctor_OOP = z * x * dr_visits if doctor_OOP==. & (dr_visits > 0 & dr_visits < .) & E1793!=1
drop x

*if amount missing, and there are expenses that are not fully covered:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP==.) & ///
										   (E1793==3 | E1793==5)

qui summ patient_OOP
replace patient_OOP = r(mean) if (patient_OOP==.) & ///
	   										  (E1798==3 | E1798==5)

qui summ dental_OOP
replace dental_OOP = r(mean) if (dental_OOP==.) & ///
	   										 (E1803==3 | E1803==5)

*if amount missing, and expenses ARE fully covered:
replace doctor_OOP = 0 if (doctor_OOP==.) & ///
							 (E1793==1)
								 
replace patient_OOP = 0 if (patient_OOP==.) & ///
							    (E1798==1)

replace dental_OOP = 0 if (dental_OOP==.) & ///
							   (E1803==1)

*if expenses==YES, amount missing, and coverage of expenses is DK/RF/NA, 
*costs are unsettled (==7), or missing (interviewee should have been asked but was not):
qui summ doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP==.) & ///
										   (E1790 > 0 & E1790 < 998) & ///
									(E1793==7 | E1793==8 | E1793==9 | E1793==.)

qui summ patient_OOP
replace patient_OOP = r(mean) if (patient_OOP==.) & ///
	   										  (E1795==1) & ///
	   								(E1798==7 | E1798==8 | E1798==9 | E1798==.)

qui summ dental_OOP
replace dental_OOP = r(mean) if (dental_OOP==.) & ///
	   										 (E1800==1) & ///
	   								(E1803==7 | E1803==8 | E1803==9 | E1803==.)
	   								
*if amount missing and no doctor visit, outpatient surgery, dentist visit:
replace doctor_OOP = 0 if (doctor_OOP==.) & ///
							 (E1790==0)

replace patient_OOP = 0 if (patient_OOP==.) & ///
							    (E1795==5)						

replace dental_OOP = 0 if (dental_OOP==.) & ///
							   (E1800==5)
							    
*if doctor visit, outpatient surgery, dental visit is DK/NA/RF and amount missing:
qui summ doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP==.) & ///
										   (E1790==998 | E1790==999)

qui summ patient_OOP											   
replace patient_OOP = r(mean) if (patient_OOP==.) & ///
											  (E1795==8 | E1795==9)

qui summ dental_OOP
replace dental_OOP = r(mean) if (dental_OOP==.) & ///
											 (E1800==8 | E1800==9)

*caps
replace doctor_OOP = min( 5000*z*months , doctor_OOP) if !missing(doctor_OOP)
replace patient_OOP = min( 15000*z*months , patient_OOP) if !missing(patient_OOP)
replace dental_OOP = min( 1000*z*months , dental_OOP) if !missing(dental_OOP)
											  
*summing
egen doctor_patient_dental_OOP_imp = rowtotal( doctor_OOP patient_OOP dental_OOP ), missing

*re-scaling where an original sum is available in the data or where one has been imputed using brackets and our imputed sum is not equal to zero:
replace doctor_OOP = doctor_OOP * (doctor_patient_dental_OOP / doctor_patient_dental_OOP_imp) ///
						if !missing(doctor_patient_dental_OOP) & doctor_patient_dental_OOP_imp != 0
						
replace patient_OOP = patient_OOP * (doctor_patient_dental_OOP / doctor_patient_dental_OOP_imp) ///
						if !missing(doctor_patient_dental_OOP) & doctor_patient_dental_OOP_imp != 0
						
replace dental_OOP = dental_OOP * (doctor_patient_dental_OOP / doctor_patient_dental_OOP_imp) ///
						if !missing(doctor_patient_dental_OOP) & doctor_patient_dental_OOP_imp != 0

*fill in missing values of the original variable (where brackets/original data were not available) with the sum of imputed spending.
replace doctor_patient_dental_OOP = doctor_patient_dental_OOP_imp if missing(doctor_patient_dental_OOP)
drop doctor_patient_dental_OOP_imp	

*impute if missing, take drugs regularly, coverage is incomplete:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(E1815 == 2 | E1815 == 3 | E1815 == 5)

*set to 0 if missing, coverage is complete (==1) OR no charge (==6):
replace RX_OOP = 0 if (RX_OOP == .) & (E1815 == 1 | E1815 == 6)

*impute if missing, take drugs and coverage=DK/NA/RF/unsettled:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(E1815 == 7 | E1815 == 8 | E1815 == 9)

*impute if missing, take drugs regularly (E1811==1) or medications known (==7), 
*and coverage info is missing:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(E1811 == 1) & ///
							(E1815 == .)
							
*set to 0 if don't take drugs regularly:							
replace RX_OOP = 0 if (RX_OOP == .) & (E1811 == 5)

*impute if unknown whether take drugs regularly:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & (E1811 == 8 | E1811 == 9)

gen home_OOP = .
gen special_OOP = .

*home expenses only
replace home_OOP = home_special_OOP if (E1827==1 & E1829!=1 & E1829!=6) & (E1831==5)

*special expenses only
replace special_OOP = home_special_OOP if (E1827==5 | E1829==1 | E1829==6) & (E1831==1)

*if home and special both reported:
replace home_OOP = home_shr * home_special_OOP if (E1827==1 & E1829!=1 & E1829!=6) & (E1831==1)
replace special_OOP = special_shr * home_special_OOP if (E1827==1 & E1829!=1 & E1829!=6) & (E1831==1)

*Now the imputation proceeds as a typical imputation taking our imputed data as real data and filling in the rest using the
*utilization and coverage information, imputing with means or zeros wherever applicable:

*cap expenses at 15000 each (BASE YEAR dollars) per month (on average):
replace home_OOP = min( 15000*z* months , home_OOP ) if !missing(home_OOP)
replace special_OOP = min( 15000*z* months , special_OOP ) if !missing(special_OOP)

*impute if expenses=YES, coverage=INCOMPLETE:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
					        		  	   (E1829 == 3 | E1829 == 5)

*if we assume all special facility/service expenses are completely uncovered:
qui sum special_OOP
replace special_OOP = r(mean) if (home_OOP == .) & (E1831==1)

*set to 0 if coverage=COMPLETE (==1) or no charge (==6):
replace home_OOP = 0 if (home_OOP == .) & (E1829 == 1 | E1829==6)

*impute if expenses=YES, coverage=DK/NA/RF/unsettled/missing:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP==.) & ///
							  			   (E1827 == 1) & ///
							  (E1829 == 7 | E1829 == 8 | E1829 == 9 | E1829 == .)

*set to 0 if expenses=NO:
replace home_OOP = 0 if (home_OOP == .) & ///
							 (E1827 == 5)

replace special_OOP = 0 if (special_OOP == .) & ///
							 (E1831 == 5)

*impute if expenses=DK/NA/RF:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == . ) & ///
							  			   (E1827 == 8 | E1827 == 9)

qui summ special_OOP
replace special_OOP = r(mean) if (special_OOP == . ) & ///
										   (E1831 == 8 | E1831 == 9)

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

save $savedir/core1996_oopi2.dta, replace

********************************************************************************
*/
use $savedir/core1998_oopi1.dta, clear
merge 1:1 HHID PN using $savedir/core1998_use.dta, nogen keepusing(hospital_nights nh_nights dr_visits qtile_*)

scalar z = cpi1998 / cpiBASE

*if amount missing, expenses=YES:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (F5881 == 1)

*if amount missing, expenses=NO:
replace MC_HMO = 0 if (MC_HMO == .) & (F5881 == 5)

*if amount missing, expenses=DK/NA/RF:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (F5881 == 8 | F5881 == 9)

*if missing, coverage=YES:
qui sum long_term_care
replace long_term_care = r(mean) if (long_term_care == .) & (F5999 == 1)

*if missing, coverage=NO:
replace long_term_care = 0 if (long_term_care == .) & (F5999 == 5)

*if missing, coverage=DK/NA/RF:
qui sum long_term_care
replace long_term_care = r(mean) if (long_term_care == .) & (F5999 == 8 | F5999 == 9)

/*
          R13. (Not including Medicare/Medicaid/CHAMPUS/CHAMP-VA) are you covered by
          any employer-provided health insurance?
          
	//Note: R12x asks about insurance for the self-employed.  However, the follow-up questions on # plans, premiums, etc. are asked only of those with EPHI.          
*/

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1 == .) & ///
									   (F5899 == 1 | F5899 == 2)

*if amount missing, pay NONE ("3") of costs:
replace private_medigap_1 = 0 if (private_medigap_1  == .) & (F5899 == 3)

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1==.) & ///
									   (F5899 == 8 | F5899 == 9)

*if amount missing, no insurance through employer									   
replace private_medigap_1 = 0 if (private_medigap_1==.) & (F5893==5)

*if amount missing, unsure whether insured through employer
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1==.) & ///
									   (F5893 == 8 | F5893 == 9)

/*
          R46. Not counting long-term care insurance or Medicare, (or Medicaid/or any
          other insurance we've discussed), do you have any other insurance that pays
          any part of hospital or doctor bills?  Sometimes this is called a Medigap or
          Medicare Supplement policy.
*/

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2 == .) & ///
									   (F5940 == 1 | F5940 == 2)

*if amount missing, pay NONE ("3") of costs:
replace private_medigap_2 = 0 if (private_medigap_2  == .) & (F5940 == 3)

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2==.) & ///
									   (F5940 == 8 | F5940 == 9)

*if amount missing, no other insurance									   
replace private_medigap_2 = 0 if (private_medigap_2==.) & (F5938==5)

*if amount missing, unsure whether other insurance
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2==.) & ///
									   (F5938 == 8 | F5938 == 9)

/*
          R48. Do you have any basic health insurance coverage purchased directly from
          an insurance company or through a membership organization?
*/
									   
*if amount missing, has other insurance
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if (private_medigap_3==.) & (F5950==1)

*if amount missing, no other insurance									   
replace private_medigap_3 = 0 if (private_medigap_3==.) & (F5950==5)

*if amount missing, unsure whether other insurance
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if (private_medigap_3==.) & ///
									   (F5950 == 8 | F5950 == 9)									   									   

egen private_medigap = rowtotal( private_medigap_1 ///
								 private_medigap_2 ///
								 private_medigap_3 ) , missing

replace private_medigap = min( private_medigap , cond(F5866==1,400*z,2000*z) ) if !missing(private_medigap)

gen hospital_OOP = .

*all spending is hospital if R reports hospital utilization not completely covered by insurance and either (a) no NH utilization or 
*(b) NH expenses fully covered
replace hospital_OOP = hospital_NH_OOP if (F2295==1 & F2298!=1) & ((F2299==5 & F517!=1) | F2304==1)

*cap at 15000*z*months
replace hospital_OOP = min( 15000*z*months , hospital_OOP ) if !missing(hospital_OOP)

*impute with nights spent in hospital where possible if expenses were not fully covered
est restore hospital
predict x, xb
tab x qtile_hospital
replace hospital_OOP = z * x * hospital_nights if hospital_OOP == . & (F2295==1) & (F2298!=1)
drop x

*if amount missing, and there are expenses that are known to be not fully covered, and nights not available:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if hospital_OOP == . & (F2295==1) & (F2298==3 | F2298==5)

*if amount missing, and expenses ARE fully covered:
replace hospital_OOP = 0 if (hospital_OOP==.) & (F2298==1)

*if expenses==YES, amount missing, and coverage of expenses is DK/RF/NA, 
*costs are unsettled (==7), or missing (interviewee should have been asked but was not):
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & (F2295==1) & (F2298==7 | F2298==8 | F2298==9 | F2298==.)

*if amount missing and did not spend night in hospital:
replace hospital_OOP = 0 if (hospital_OOP==.) & (F2295==5)

*if utilization is DK/NA/RF and amount missing:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & (F2295==8 | F2295==9)

gen NH_OOP = .

*all spending is NH if R reports NH utilization not completely covered by insurance and either (a) no hospital utilization or 
*(b) all hospital expenses fully covered
replace NH_OOP = hospital_NH_OOP if ((F2299==1 | F517==1) & F2304!=1) & (F2295==5 | F2298==1)

*cap at 15000*z*months
replace NH_OOP = min( 15000*z*months , NH_OOP ) if !missing(NH_OOP)

*impute with nights spent in NH where possible if expenses were not fully covered
est restore NH
predict x, xb
tab x qtile_nh
replace NH_OOP = z * x * nh_nights if NH_OOP == . & (F2299==1 | F517==1) & (F2304!=1)
drop x

*if amount missing, and there are expenses that are not fully covered, and nights not available:
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & (F2299==1 | F517==1) & (F2304==3 | F2304==5)

*if amount missing, and expenses ARE fully covered:
replace NH_OOP = 0 if (NH_OOP==.) & (F2304==1)

*if expenses==YES, amount missing, and coverage of expenses is DK/RF/NA, 
*costs are unsettled (==7), or missing (interviewee should have been asked but was not):
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & (F2299==1 | F517==1) & (F2304==7 | F2304==8 | F2304==9 | F2304==.)

*if amount missing and did not spend night in NH (and didnt live in NH) or hospital:
replace NH_OOP = 0 if NH_OOP==. & (F2299==5 & F517!=1)						

*if didn't live in NH, overnight stay is DK/NA/RF and amount missing:
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & (F517!=1) & (F2299==8 | F2299==9)

*caps
replace hospital_OOP = min( 15000*z*months , hospital_OOP ) if !missing(hospital_OOP)
replace NH_OOP = min( 15000*z*months , NH_OOP ) if !missing(NH_OOP)

*summing our independent imputations for hospital and NH:
egen hospital_NH_OOP_imputed = rowtotal( hospital_OOP NH_OOP ), missing

*re-scaling where an original sum is available in the data or where one has been imputed using brackets and our imputed sum is not equal to zero:
replace hospital_OOP = hospital_OOP * (hospital_NH_OOP / hospital_NH_OOP_imputed) if !missing(hospital_NH_OOP) & hospital_NH_OOP_imputed != 0
replace NH_OOP = NH_OOP * (hospital_NH_OOP / hospital_NH_OOP_imputed) if !missing(hospital_NH_OOP) & hospital_NH_OOP_imputed != 0

*fill in missing values of the original variable (where brackets were not available) with the sum of imputed hospital and NH spending.
replace hospital_NH_OOP = hospital_NH_OOP_imputed if missing(hospital_NH_OOP)
drop hospital_NH_OOP_imputed

gen doctor_OOP = .
gen dental_OOP = .
gen patient_OOP = .

*dr expenses only
replace doctor_OOP = doctor_patient_dental_OOP ///
						if (F2331>0 & F2331<998 & F2332!=1) & (F2333==5 | F2334==1) & (F2335==5 | F2336==1)

*patient expenses only
replace patient_OOP = doctor_patient_dental_OOP ///
						if (F2331==0 | F2332==1) & (F2333==1 & F2334!=1) & (F2335==5 | F2336==1)
						
*dental expenses only
replace dental_OOP = doctor_patient_dental_OOP ///
						if (F2331==0 | F2332==1) & (F2333==5 | F2334==1) & (F2335==1 & F2336!=1)

*dr, patient, and dental expenses
replace doctor_OOP = doctor_shr * doctor_patient_dental_OOP ///
						if (F2331>0 & F2331<998 & F2332!=1) & (F2333==1 & F2334!=1) & (F2335==1 & F2336!=1)

replace patient_OOP = patient_shr * doctor_patient_dental_OOP ///
						if (F2331>0 & F2331<998 & F2332!=1) & (F2333==1 & F2334!=1) & (F2335==1 & F2336!=1)

replace dental_OOP = dental_shr * doctor_patient_dental_OOP ///
						if (F2331>0 & F2331<998 & F2332!=1) & (F2333==1 & F2334!=1) & (F2335==1 & F2336!=1)

*dr and dental expenses only
replace doctor_OOP = doctor_shr_dr_dent * doctor_patient_dental_OOP ///
						if (F2331>0 & F2331<998 & F2332!=1) & (F2333==5 | F2334==1) & (F2335==1 & F2336!=1)

replace dental_OOP = dental_shr_dr_dent * doctor_patient_dental_OOP ///
						if (F2331>0 & F2331<998 & F2332!=1) & (F2333==5 | F2334==1) & (F2335==1 & F2336!=1)

*dr and patient expenses only
replace doctor_OOP = doctor_shr_dr_patient * doctor_patient_dental_OOP ///
						if (F2331>0 & F2331<998 & F2332!=1) & (F2333==1 & F2334!=1) & (F2335==5 | F2336!=1) 

replace patient_OOP = patient_shr_dr_patient * doctor_patient_dental_OOP ///
						if (F2331>0 & F2331<998 & F2332!=1) & (F2333==1 & F2334!=1) & (F2335==5 | F2336!=1)

*patient and dental expenses only
replace patient_OOP = patient_shr_patient_dent * doctor_patient_dental_OOP ///
						if (F2331==0 | F2332==1) & (F2333==1 & F2334!=1) & (F2335==1 & F2336!=1)
						
replace dental_OOP = dental_shr_patient_dent * doctor_patient_dental_OOP ///
						if (F2331==0 | F2332==1) & (F2333==1 & F2334!=1) & (F2335==1 & F2336!=1)

*Now the imputation proceeds as a typical imputation taking our imputed data as real data and filling in the rest using the
*utilization and coverage information, imputing with means or zeros wherever applicable:

*impose caps: doctor=5000, dental=1000, outpatient=15000)
replace doctor_OOP = min( 5000*z*months , doctor_OOP) if !missing(doctor_OOP)
replace patient_OOP = min( 15000*z*months , patient_OOP) if !missing(patient_OOP)
replace dental_OOP = min( 1000*z*months , dental_OOP) if !missing(dental_OOP)

*impute using doctor visits if possible where expenses not fully covered
est restore doctor
predict x, xb
tab x qtile_doctor
replace doctor_OOP = z * x * dr_visits if doctor_OOP==. & (dr_visits > 0 & dr_visits < .) & F2332!=1
drop x

*if amount missing, and there are expenses that are not fully covered:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP==.) & ///
										   (F2332==3 | F2332==5)

qui summ patient_OOP
replace patient_OOP = r(mean) if (patient_OOP==.) & ///
	   										  (F2334==3 | F2334==5)

qui summ dental_OOP
replace dental_OOP = r(mean) if (dental_OOP==.) & ///
	   										 (F2336==3 | F2336==5)

*if amount missing, and expenses ARE fully covered:
replace doctor_OOP = 0 if (doctor_OOP==.) & ///
							 (F2332==1)
								 
replace patient_OOP = 0 if (patient_OOP==.) & ///
							    (F2334==1)

replace dental_OOP = 0 if (dental_OOP==.) & ///
							   (F2336==1)

*if expenses==YES, amount missing, and coverage of expenses is DK/RF/NA, 
*costs are unsettled (==7), or missing (interviewee should have been asked but was not):
qui summ doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP==.) & ///
										   (F2331 > 0 & F2331 < 998) & ///
									(F2332==7 | F2332==8 | F2332==9 | F2332==.)

qui summ patient_OOP
replace patient_OOP = r(mean) if (patient_OOP==.) & ///
	   										  (F2333==1) & ///
	   								(F2334==7 | F2334==8 | F2334==9 | F2334==.)

qui summ dental_OOP
replace dental_OOP = r(mean) if (dental_OOP==.) & ///
	   										 (F2335==1) & ///
	   								(F2336==7 | F2336==8 | F2336==9 | F2336==.)
	   								
*if amount missing and no doctor visit, outpatient surgery, dentist visit:
replace doctor_OOP = 0 if (doctor_OOP==.) & ///
							 (F2331==0)

replace patient_OOP = 0 if (patient_OOP==.) & ///
							    (F2333==5)						

replace dental_OOP = 0 if (dental_OOP==.) & ///
							   (F2335==5)
							    
*if doctor visit, outpatient surgery, dental visit is DK/NA/RF and amount missing:
qui summ doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP==.) & ///
										   (F2331==998 | F2331==999)

qui summ patient_OOP											   
replace patient_OOP = r(mean) if (patient_OOP==.) & ///
											  (F2333==8 | F2333==9)

qui summ dental_OOP
replace dental_OOP = r(mean) if (dental_OOP==.) & ///
											 (F2335==8 | F2335==9)

*caps
replace doctor_OOP = min( 5000*z*months , doctor_OOP) if !missing(doctor_OOP)
replace patient_OOP = min( 15000*z*months , patient_OOP) if !missing(patient_OOP)
replace dental_OOP = min( 1000*z*months , dental_OOP) if !missing(dental_OOP)
											  
*summing
egen doctor_patient_dental_OOP_imp = rowtotal( doctor_OOP patient_OOP dental_OOP ), missing

*re-scaling where an original sum is available in the data or where one has been imputed using brackets and our imputed sum is not equal to zero:
replace doctor_OOP = doctor_OOP * (doctor_patient_dental_OOP / doctor_patient_dental_OOP_imp) ///
						if !missing(doctor_patient_dental_OOP) & doctor_patient_dental_OOP_imp != 0
						
replace patient_OOP = patient_OOP * (doctor_patient_dental_OOP / doctor_patient_dental_OOP_imp) ///
						if !missing(doctor_patient_dental_OOP) & doctor_patient_dental_OOP_imp != 0
						
replace dental_OOP = dental_OOP * (doctor_patient_dental_OOP / doctor_patient_dental_OOP_imp) ///
						if !missing(doctor_patient_dental_OOP) & doctor_patient_dental_OOP_imp != 0

*fill in missing values of the original variable (where brackets/original data were not available) with the sum of imputed spending.
replace doctor_patient_dental_OOP = doctor_patient_dental_OOP_imp if missing(doctor_patient_dental_OOP)
drop doctor_patient_dental_OOP_imp	

*impute if missing, take drugs regularly, coverage is incomplete:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(F2346 == 2 | F2346 == 3 | F2346 == 5)

*set to 0 if missing, coverage is complete (==1) OR no charge (==6):
replace RX_OOP = 0 if (RX_OOP == .) & (F2346 == 1 | F2346 == 6)

*impute if missing, take drugs and coverage=DK/NA/RF/unsettled:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(F2346 == 7 | F2346 == 8 | F2346 == 9)

*impute if missing, take drugs regularly (F2345==1) or medications known (==7), 
*and coverage info is missing:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(F2345 == 1 | F2345 == 7) & ///
							(F2346 == .)
							
*set to 0 if don't take drugs regularly:							
replace RX_OOP = 0 if (RX_OOP == .) & (F2345 == 5)

*impute if unknown whether take drugs regularly:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & (F2345 == 8 | F2345 == 9)

gen home_OOP = .
gen special_OOP = .

*home expenses only
replace home_OOP = home_special_OOP if (F2357==1 & F2359!=1 & F2359!=6) & (F2361==5)

*special expenses only
replace special_OOP = home_special_OOP if (F2357==5 | F2359==1 | F2359==6) & (F2361==1)

*if home and special both reported:
replace home_OOP = home_shr * home_special_OOP if (F2357==1 & F2359!=1 & F2359!=6) & (F2361==1)
replace special_OOP = special_shr * home_special_OOP if (F2357==1 & F2359!=1 & F2359!=6) & (F2361==1)

*Now the imputation proceeds as a typical imputation taking our imputed data as real data and filling in the rest using the
*utilization and coverage information, imputing with means or zeros wherever applicable:

*cap expenses at 15000 each (BASE YEAR dollars) per month (on average):
replace home_OOP = min( 15000*z* months , home_OOP ) if !missing(home_OOP)
replace special_OOP = min( 15000*z* months , special_OOP ) if !missing(special_OOP)

*impute if expenses=YES, coverage=INCOMPLETE:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
					        		  	   (F2359 == 3 | F2359 == 5)

*if we assume all special facility/service expenses are completely uncovered:
qui sum special_OOP
replace special_OOP = r(mean) if (home_OOP == .) & (F2361==1)

*set to 0 if coverage=COMPLETE (==1) or no charge (==6):
replace home_OOP = 0 if (home_OOP == .) & (F2359 == 1 | F2359==6)

*impute if expenses=YES, coverage=DK/NA/RF/unsettled/missing:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP==.) & ///
							  			   (F2357 == 1) & ///
							  (F2359 == 7 | F2359 == 8 | F2359 == 9 | F2359 == .)

*set to 0 if expenses=NO:
replace home_OOP = 0 if (home_OOP == .) & ///
							 (F2357 == 5)

replace special_OOP = 0 if (special_OOP == .) & ///
							 (F2361 == 5)

*impute if expenses=DK/NA/RF:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == . ) & ///
							  			   (F2357 == 8 | F2357 == 9)

qui summ special_OOP
replace special_OOP = r(mean) if (special_OOP == . ) & ///
										   (F2361 == 8 | F2361 == 9)

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

save $savedir/core1998_oopi2.dta, replace

********************************************************************************

use $savedir/core2000_oopi1.dta, clear
merge 1:1 HHID PN using $savedir/core2000_use.dta, nogen keepusing(hospital_nights nh_nights dr_visits qtile_*)

scalar z = cpi2000 / cpiBASE

*if amount missing, expenses=YES:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (G6254 == 1)

*if amount missing, expenses=NO:
replace MC_HMO = 0 if (MC_HMO == .) & (G6254 == 5)

*if amount missing, expenses=DK/NA/RF:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (G6254 == 8 | G6254 == 9)

*if missing, coverage=YES:
qui sum long_term_care
replace long_term_care = r(mean) if (long_term_care == .) & (G6393 == 1)

*if missing, coverage=NO:
replace long_term_care = 0 if (long_term_care == .) & (G6393 == 5)

*if missing, coverage=DK/NA/RF:
qui sum long_term_care
replace long_term_care = r(mean) if (long_term_care == .) & (G6393 == 8 | G6393 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1 == .) & ///
									   (G6272 == 1 | G6272 == 2)

*if amount missing, pay NONE ("3") of costs:
replace private_medigap_1 = 0 if (private_medigap_1  == .) & (G6272 == 3)

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1==.) & ///
									   (G6272 == 8 | G6272 == 9)

*if amount missing, no insurance through employer									   
replace private_medigap_1 = 0 if (private_medigap_1==.) & (G6266==5)

*if amount missing, unsure whether insured through employer
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1==.) & ///
									   (G6266 == 8 | G6266 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2 == .) & ///
									   (G6314 == 1 | G6314 == 2)

*if amount missing, pay NONE ("3") of costs:
replace private_medigap_2 = 0 if (private_medigap_2  == .) & (G6314 == 3)

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2==.) & ///
									   (G6314 == 8 | G6314 == 9)

*if amount missing, no other insurance									   
replace private_medigap_2 = 0 if (private_medigap_2==.) & (G6312==5)

*if amount missing, unsure whether other insurance
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2==.) & ///
									   (G6312 == 8 | G6312 == 9)
									   
*if amount missing, has other insurance
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if (private_medigap_3==.) & (G6325==1)

*if amount missing, no other insurance									   
replace private_medigap_3 = 0 if (private_medigap_3==.) & (G6325==5)

*if amount missing, unsure whether other insurance
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if (private_medigap_3==.) & ///
									   (G6325 == 8 | G6325 == 9)

egen private_medigap = rowtotal( private_medigap_1 ///
								 private_medigap_2 ///
								 private_medigap_3 ) , missing									   									   									   

replace private_medigap = min( private_medigap , cond(G6238==1,400*z,2000*z) ) if !missing(private_medigap)

gen hospital_OOP = .

*all spending is hospital if R reports hospital utilization not completely covered by insurance and either (a) no NH utilization or 
*(b) NH expenses fully covered
replace hospital_OOP = hospital_NH_OOP if (G2567==1 & G2570!=1) & ((G2571==5 & G558!=1) | G2576==1)

*cap at 15000*z*months
replace hospital_OOP = min( 15000*z*months , hospital_OOP ) if !missing(hospital_OOP)

*impute with nights spent in hospital where possible if expenses were not fully covered
est restore hospital
predict x, xb
tab x qtile_hospital
replace hospital_OOP = z * x * hospital_nights if hospital_OOP == . & (G2567==1) & (G2570!=1)
drop x

*if amount missing, and there are expenses that are known to be not fully covered, and nights not available:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if hospital_OOP == . & (G2567==1) & (G2570==3 | G2570==5)

*if amount missing, and expenses ARE fully covered:
replace hospital_OOP = 0 if (hospital_OOP==.) & (G2570==1)

*if expenses==YES, amount missing, and coverage of expenses is DK/RF/NA, 
*costs are unsettled (==7), or missing (interviewee should have been asked but was not):
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & (G2567==1) & (G2570==7 | G2570==8 | G2570==9 | G2570==.)

*if amount missing and did not spend night in hospital:
replace hospital_OOP = 0 if (hospital_OOP==.) & (G2567==5)

*if utilization is DK/NA/RF and amount missing:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & (G2567==8 | G2567==9)

gen NH_OOP = .

*all spending is NH if R reports NH utilization not completely covered by insurance and either (a) no hospital utilization or 
*(b) all hospital expenses fully covered
replace NH_OOP = hospital_NH_OOP if ((G2571==1 | G558==1) & G2576!=1) & (G2567==5 | G2570==1)

*cap at 15000*z*months
replace NH_OOP = min( 15000*z*months , NH_OOP ) if !missing(NH_OOP)

*impute with nights spent in NH where possible if expenses were not fully covered
est restore NH
predict x, xb
tab x qtile_nh
replace NH_OOP = z * x * nh_nights if NH_OOP == . & (G2571==1 | G558==1) & (G2576!=1)
drop x

*if amount missing, and there are expenses that are not fully covered, and nights not available:
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & (G2571==1 | G558==1) & (G2576==3 | G2576==5)

*if amount missing, and expenses ARE fully covered:
replace NH_OOP = 0 if (NH_OOP==.) & (G2576==1)

*if expenses==YES, amount missing, and coverage of expenses is DK/RF/NA, 
*costs are unsettled (==7), or missing (interviewee should have been asked but was not):
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & (G2571==1 | G558==1) & (G2576==7 | G2576==8 | G2576==9 | G2576==.)

*if amount missing and did not spend night in NH (and didnt live in NH) or hospital:
replace NH_OOP = 0 if NH_OOP==. & (G2571==5 & G558!=1)						

*if didn't live in NH, overnight stay is DK/NA/RF and amount missing:
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & (G558!=1) & (G2571==8 | G2571==9)

*caps
replace hospital_OOP = min( 15000*z*months , hospital_OOP ) if !missing(hospital_OOP)
replace NH_OOP = min( 15000*z*months , NH_OOP ) if !missing(NH_OOP)

*summing our independent imputations for hospital and NH:
egen hospital_NH_OOP_imputed = rowtotal( hospital_OOP NH_OOP ), missing

*re-scaling where an original sum is available in the data or where one has been imputed using brackets and our imputed sum is not equal to zero:
replace hospital_OOP = hospital_OOP * (hospital_NH_OOP / hospital_NH_OOP_imputed) if !missing(hospital_NH_OOP) & hospital_NH_OOP_imputed != 0
replace NH_OOP = NH_OOP * (hospital_NH_OOP / hospital_NH_OOP_imputed) if !missing(hospital_NH_OOP) & hospital_NH_OOP_imputed != 0

*fill in missing values of the original variable (where brackets were not available) with the sum of imputed hospital and NH spending.
replace hospital_NH_OOP = hospital_NH_OOP_imputed if missing(hospital_NH_OOP)
drop hospital_NH_OOP_imputed

gen doctor_OOP = .
gen dental_OOP = .
gen patient_OOP = .

*turns # dr visits into Y(1)/N(5)/DK(8)/RF(9) variable, using bracketing variables:
recode G2603 (0=5) (1/997=1) (998=8) (999=9)
replace G2603 = 1 if (G2604 == 3 | G2604 == 5 | ///
					  G2605 == 3 | G2605 == 5 | ///
					  G2606 == 1 | ///
					  G2607 == 3 | G2607 == 5)
replace G2603 = 5 if (G2606 == 5)
tab G2603,m

*dr expenses only
replace doctor_OOP = doctor_patient_dental_OOP ///
						if (G2603==1 & G2609!=1) & (G2610==5 | G2611==1) & (G2612==5 | G2613==1)

*patient expenses only
replace patient_OOP = doctor_patient_dental_OOP ///
						if (G2603==5 | G2609==1) & (G2610==1 & G2611!=1) & (G2612==5 | G2613==1)
						
*dental expenses only
replace dental_OOP = doctor_patient_dental_OOP ///
						if (G2603==5 | G2609==1) & (G2610==5 | G2611==1) & (G2612==1 & G2613!=1)

*dr, patient, and dental expenses
replace doctor_OOP = doctor_shr * doctor_patient_dental_OOP ///
						if (G2603==1 & G2609!=1) & (G2610==1 & G2611!=1) & (G2612==1 & G2613!=1)

replace patient_OOP = patient_shr * doctor_patient_dental_OOP ///
						if (G2603==1 & G2609!=1) & (G2610==1 & G2611!=1) & (G2612==1 & G2613!=1)

replace dental_OOP = dental_shr * doctor_patient_dental_OOP ///
						if (G2603==1 & G2609!=1) & (G2610==1 & G2611!=1) & (G2612==1 & G2613!=1)

*dr and dental expenses only
replace doctor_OOP = doctor_shr_dr_dent * doctor_patient_dental_OOP ///
						if (G2603==1 & G2609!=1) & (G2610==5 | G2611==1) & (G2612==1 & G2613!=1)

replace dental_OOP = dental_shr_dr_dent * doctor_patient_dental_OOP ///
						if (G2603==1 & G2609!=1) & (G2610==5 | G2611==1) & (G2612==1 & G2613!=1)

*dr and patient expenses only
replace doctor_OOP = doctor_shr_dr_patient * doctor_patient_dental_OOP ///
						if (G2603==1 & G2609!=1) & (G2610==1 & G2611!=1) & (G2612==5 | G2613!=1) 

replace patient_OOP = patient_shr_dr_patient * doctor_patient_dental_OOP ///
						if (G2603==1 & G2609!=1) & (G2610==1 & G2611!=1) & (G2612==5 | G2613!=1)

*patient and dental expenses only
replace patient_OOP = patient_shr_patient_dent * doctor_patient_dental_OOP ///
						if (G2603==5 | G2609==1) & (G2610==1 & G2611!=1) & (G2612==1 & G2613!=1)
						
replace dental_OOP = dental_shr_patient_dent * doctor_patient_dental_OOP ///
						if (G2603==5 | G2609==1) & (G2610==1 & G2611!=1) & (G2612==1 & G2613!=1)

*Now the imputation proceeds as a typical imputation taking our imputed data as real data and filling in the rest using the
*utilization and coverage information, imputing with means or zeros wherever applicable:

*impose caps: doctor=5000, dental=1000, outpatient=15000)
replace doctor_OOP = min( 5000*z*months , doctor_OOP) if !missing(doctor_OOP)
replace patient_OOP = min( 15000*z*months , patient_OOP) if !missing(patient_OOP)
replace dental_OOP = min( 1000*z*months , dental_OOP) if !missing(dental_OOP)

*impute using doctor visits if possible where expenses not fully covered
est restore doctor
predict x, xb
tab x qtile_doctor
replace doctor_OOP = z * x * dr_visits if doctor_OOP==. & (dr_visits > 0 & dr_visits < .) & G2609!=1
drop x

*if amount missing, and there are expenses that are not fully covered:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP==.) & ///
										   (G2609==3 | G2609==5)

qui summ patient_OOP
replace patient_OOP = r(mean) if (patient_OOP==.) & ///
	   										  (G2611==3 | G2611==5)

qui summ dental_OOP
replace dental_OOP = r(mean) if (dental_OOP==.) & ///
	   										 (G2613==3 | G2613==5)

*if amount missing, and expenses ARE fully covered:
replace doctor_OOP = 0 if (doctor_OOP==.) & ///
							 (G2609==1)
								 
replace patient_OOP = 0 if (patient_OOP==.) & ///
							    (G2611==1)

replace dental_OOP = 0 if (dental_OOP==.) & ///
							   (G2613==1)

*if expenses==YES, amount missing, and coverage of expenses is DK/RF/NA, 
*costs are unsettled (==7), or missing (interviewee should have been asked but was not):
qui summ doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP==.) & ///
										   (G2603==1) & ///
									(G2609==7 | G2609==8 | G2609==9 | G2609==.)

qui summ patient_OOP
replace patient_OOP = r(mean) if (patient_OOP==.) & ///
	   										  (G2610==1) & ///
	   								(G2611==7 | G2611==8 | G2611==9 | G2611==.)

qui summ dental_OOP
replace dental_OOP = r(mean) if (dental_OOP==.) & ///
	   										 (G2612==1) & ///
	   								(G2613==7 | G2613==8 | G2613==9 | G2613==.)
	   								
*if amount missing and no doctor visit, outpatient surgery, dentist visit:
replace doctor_OOP = 0 if (doctor_OOP==.) & ///
							 (G2603==5)

replace patient_OOP = 0 if (patient_OOP==.) & ///
							    (G2610==5)						

replace dental_OOP = 0 if (dental_OOP==.) & ///
							   (G2612==5)
							    
*if doctor visit, outpatient surgery, dental visit is DK/NA/RF and amount missing:
qui summ doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP==.) & ///
										   (G2603==8 | G2603==9)

qui summ patient_OOP											   
replace patient_OOP = r(mean) if (patient_OOP==.) & ///
											  (G2610==8 | G2610==9)

qui summ dental_OOP
replace dental_OOP = r(mean) if (dental_OOP==.) & ///
											 (G2612==8 | G2612==9)

*caps
replace doctor_OOP = min( 5000*z*months , doctor_OOP) if !missing(doctor_OOP)
replace patient_OOP = min( 15000*z*months , patient_OOP) if !missing(patient_OOP)
replace dental_OOP = min( 1000*z*months , dental_OOP) if !missing(dental_OOP)
											  
*summing
egen doctor_patient_dental_OOP_imp = rowtotal( doctor_OOP patient_OOP dental_OOP ), missing

*re-scaling where an original sum is available in the data or where one has been imputed using brackets and our imputed sum is not equal to zero:
replace doctor_OOP = doctor_OOP * (doctor_patient_dental_OOP / doctor_patient_dental_OOP_imp) ///
						if !missing(doctor_patient_dental_OOP) & doctor_patient_dental_OOP_imp != 0
						
replace patient_OOP = patient_OOP * (doctor_patient_dental_OOP / doctor_patient_dental_OOP_imp) ///
						if !missing(doctor_patient_dental_OOP) & doctor_patient_dental_OOP_imp != 0
						
replace dental_OOP = dental_OOP * (doctor_patient_dental_OOP / doctor_patient_dental_OOP_imp) ///
						if !missing(doctor_patient_dental_OOP) & doctor_patient_dental_OOP_imp != 0

*fill in missing values of the original variable (where brackets/original data were not available) with the sum of imputed spending.
replace doctor_patient_dental_OOP = doctor_patient_dental_OOP_imp if missing(doctor_patient_dental_OOP)
drop doctor_patient_dental_OOP_imp	

*impute if missing, take drugs regularly, coverage is incomplete:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(G2623 == 2 | G2623 == 3 | G2623 == 5)

*set to 0 if missing, coverage is complete (==1) OR no charge (==6):
replace RX_OOP = 0 if (RX_OOP == .) & (G2623 == 1 | G2623 == 6)

*impute if missing, take drugs and coverage=DK/NA/RF/unsettled:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(G2623 == 7 | G2623 == 8 | G2623 == 9)

*impute if missing, take drugs regularly (G2622==1) or medications known (==7), 
*and coverage info is missing:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(G2622 == 1 | G2622 == 7) & ///
							(G2623 == .)
							
*set to 0 if don't take drugs regularly:							
replace RX_OOP = 0 if (RX_OOP == .) & (G2622 == 5)

*impute if unknown whether take drugs regularly:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & (G2622 == 8 | G2622 == 9)

gen home_OOP = .
gen special_OOP = .

*home expenses only
replace home_OOP = home_special_OOP if (G2634==1 & G2636!=1 & G2636!=6) & (G2638==5)

*special expenses only
replace special_OOP = home_special_OOP if (G2634==5 | G2636==1 | G2636==6) & (G2638==1)

*if home and special both reported:
replace home_OOP = home_shr * home_special_OOP if (G2634==1 & G2636!=1 & G2636!=6) & (G2638==1)
replace special_OOP = special_shr * home_special_OOP if (G2634==1 & G2636!=1 & G2636!=6) & (G2638==1)

*Now the imputation proceeds as a typical imputation taking our imputed data as real data and filling in the rest using the
*utilization and coverage information, imputing with means or zeros wherever applicable:

*cap expenses at 15000 each (BASE YEAR dollars) per month (on average):
replace home_OOP = min( 15000*z* months , home_OOP ) if !missing(home_OOP)
replace special_OOP = min( 15000*z* months , special_OOP ) if !missing(special_OOP)

*impute if expenses=YES, coverage=INCOMPLETE:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
					        		  	   (G2636 == 3 | G2636 == 5)

*if we assume all special facility/service expenses are completely uncovered:
qui sum special_OOP
replace special_OOP = r(mean) if (home_OOP == .) & (G2638==1)

*set to 0 if coverage=COMPLETE (==1) or no charge (==6):
replace home_OOP = 0 if (home_OOP == .) & (G2636 == 1 | G2636==6)

*impute if expenses=YES, coverage=DK/NA/RF/unsettled/missing:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP==.) & ///
							  			   (G2634 == 1) & ///
							  (G2636 == 7 | G2636 == 8 | G2636 == 9 | G2636 == .)

*set to 0 if expenses=NO:
replace home_OOP = 0 if (home_OOP == .) & ///
							 (G2634 == 5)

replace special_OOP = 0 if (special_OOP == .) & ///
							 (G2638 == 5)

*impute if expenses=DK/NA/RF:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == . ) & ///
							  			   (G2634 == 8 | G2634 == 9)

qui summ special_OOP
replace special_OOP = r(mean) if (special_OOP == . ) & ///
										   (G2638 == 8 | G2638 == 9)

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

save $savedir/core2000_oopi2.dta, replace

********************************************************************************

use $savedir/core2002_oopi1.dta, clear
merge 1:1 HHID PN using $savedir/core2002_use.dta, nogen keepusing(hospital_nights nh_nights dr_visits qtile_*)

scalar z = cpi2002 / cpiBASE

*if amount missing, expenses=YES:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (HN009 == 1)

*if amount missing, expenses=NO:
replace MC_HMO = 0 if (MC_HMO == .) & (HN009 == 5)

*if amount missing, expenses=DK/NA/RF:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (HN009 == 8 | HN009 == 9)

*if missing, coverage=YES, PrevDescrPlan!=YES (!=1) (could be NO or DK/NA/RF):
qui sum long_term_care
replace long_term_care = r(mean) if (long_term_care == .) & ///
							        (HN071 == 1) & (HN072 != 1)

*if missing, coverage=NO OR coverage=YES and PrevDescrPlan==YES:
replace long_term_care = 0 if (long_term_care == .) & ///
							  ((HN071 == 5) | (HN071 == 1 & HN072 == 1))

*if missing, coverage=DK/NA/RF:
qui sum long_term_care
replace long_term_care = r(mean) if (long_term_care == .) & (HN071 == 8 | HN071 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1 == .) & ///
									   (HN039_1 == 1 | HN039_1 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 1:
replace private_medigap_1 = 0 if (private_medigap_1  == .) & ///
								 ((HN039_1 == 3) | (HN023 < 1))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1==.) & ///
									   (HN039_1 == 8 | HN039_1 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2 == .) & ///
									   (HN039_2 == 1 | HN039_2 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 2:
replace private_medigap_2 = 0 if (private_medigap_2  == .) & ///
								 ((HN039_2 == 3) | (HN023 < 2))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2==.) & ///
									   (HN039_2 == 8 | HN039_2 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if (private_medigap_3 == .) & ///
									   (HN039_3 == 1 | HN039_3 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 3:
replace private_medigap_3 = 0 if (private_medigap_3  == .) & ///
								 ((HN039_3 == 3) | (HN023 < 3))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if (private_medigap_3==.) & ///
									   (HN039_3 == 8 | HN039_3 == 9)
									   
egen private_medigap = rowtotal( private_medigap_1 ///
								 private_medigap_2 ///
								 private_medigap_3 ) , missing

*if sum is missing, but # plans is known and > 0:
qui sum private_medigap
replace private_medigap = r(mean) if (private_medigap == .) & ///
									 (HN023 > 0) & (HN023 < 98)

*if sum missing, # plans known to be 0:									 
replace private_medigap = 0 if (private_medigap == .) & (HN023 == 0)

*if sum missing, # plans unknown:
qui sum private_medigap
replace private_medigap = r(mean) if (private_medigap == .) & ///
									 (HN023 == 98 | HN023 == 99)									   									   									   

replace private_medigap = min( private_medigap , cond(HN001==1,400*z,2000*z) ) if !missing(private_medigap)

*impute with nights spent in hospital where possible if expenses were not fully covered
est restore hospital
predict x, xb
tab x qtile_hospital
replace hospital_OOP = z * x * hospital_nights if hospital_OOP == . & (HN099==1) & !(HN102==1 | HN102==6)
drop x

*if overnight stay==YES, amount missing, and expenses ARE NOT fully covered or no charge:
qui sum hospital_OOP								  
replace hospital_OOP = r(mean) if (hospital_OOP==.) & ///
								  (HN102==2 | HN102==3 | HN102==5)
								  								  								  
*if overnight stay==YES, amount missing, and expenses ARE fully covered:
replace hospital_OOP = 0 if (hospital_OOP==.) & (HN102==1 | HN102==6)

*if overnight stay==YES, amount missing, and coverage of expenses is DK/RF/NA, or costs
*are unsettled (==7):
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & ///
								  (HN102==7 | HN102==8 | HN102==9)

*if overnight stay==YES, coverage question not asked:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & ///
								  (HN099==1) & ///
								  (HN102==.)

*if overnight stay==NO and amount missing
replace hospital_OOP = 0 if (hospital_OOP==.) & (HN099==5)

*if overnight stay is DK/NA/RF and amount missing:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & (HN099==8 | HN099==9)

*impute with nights spent in NH where possible if expenses were not fully covered
est restore NH
predict x, xb
tab x qtile_nh
replace NH_OOP = x * nh_nights if NH_OOP == . & (HN114 == 1 | HA028 == 1) & !(HN118 == 1 | HN118 == 6)
drop x

*if amount missing; either stayed overnight in NH (HN114) or lives in NH (HA028); 
*insurance coverage known and incomplete:
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & ///
							(HN118 == 2 | HN118 == 3 | HN118 == 5) 

*if amount missing and insurance coverage complete or no charge:							 
replace NH_OOP = 0 if (NH_OOP == .) & (HN118 == 1 | HN118 == 6)

*if amount missing; either stayed overnight in NH (HN114), lived in NH
*(HA028); insurance coverage unknown, not settled 
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP == .) & ///
							(HN118 == 7 | HN118 == 8 | HN118 == 9)
					
*if amount missing; either stayed overnight in NH (HN114), lived in NH
*(HA028); coverage question not asked: 
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP == .) & ///
							(HN114 == 1 | HA028 == 1) & ///
							(HN118 == .)
					
*if amount missing and the following are true--did not stay overnight in NH
*and did not live in NH before death:
replace NH_OOP = 0 if (NH_OOP == .) & (HN114==5 & HA028!=1)

*if amount missing, does not live in NH, but unsure whether stayed overnight in NH:
qui sum NH_OOP
replace NH_OOP = r(mean)  if (NH_OOP == .) & ///
							 (HA028!=1) & ///
							 (HN114 == 8 | HN114 == 9)

*if amount missing, expenditures = YES, coverage=INCOMPLETE:
qui sum patient_OOP
replace patient_OOP = r(mean) if (patient_OOP == .) & ///
								 (HN135==2 | HN135==3 | HN135==5)

*if amount missing, expenditures=YES, coverage=COMPLETE:
replace patient_OOP = 0 if (patient_OOP == .) & (HN135==1 | HN135==6)
						   
*if amount missing, expenditures=YES, coverage=DK/NA/RF/unsettled:
qui sum patient_OOP
replace patient_OOP = r(mean) if (patient_OOP == .) & ///
								 (HN135==7 | HN135==8 | HN135==9)

*if amount missing, expenditures=YES, coverage=missing:
qui sum patient_OOP
replace patient_OOP = r(mean) if (patient_OOP == .) & ///
								 (HN134 == 1) & ///
								 (HN135 == .)
								 
*if amount missing, expenditures = NO:						          
replace patient_OOP = 0 if (patient_OOP == .) & (HN134 == 5)

*if amount missing, expenditures = DK/NA/RF:
qui sum patient_OOP
replace patient_OOP = r(mean) if (patient_OOP == .) & (HN134==8 | HN134==9)

*impute using doctor visits if possible where expenses not fully covered
est restore doctor
predict x, xb
tab x qtile_doctor
replace doctor_OOP = z * x * dr_visits if doctor_OOP==. & (dr_visits > 0 & dr_visits < .) & HN152!=1
drop x

*if amount missing, insurance coverage known/incomplete:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(HN152 == 2 | HN152 == 3 | HN152 == 5)

*if amount missing, insurance coverage is complete:
replace doctor_OOP = 0 if (doctor_OOP == .) & (HN152 == 1 | HN152 == 6)

*if amount missing, extent of coverage is DK/NA/RF/unsettled:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(HN152 == 7 | HN152 == 8 | HN152 == 9)

*if amount missing, # visits known and > 0, coverage info missing:
qui summ doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
										   (dr_visits > 0 & dr_visits < .) & ///
		   								   (HN152 == .)
								
*if amount missing, # visits == 0:
replace doctor_OOP = 0 if (doctor_OOP == .) & (dr_visits == 0)

*if amount missing, # visits unknown:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(HN147 == 998 | HN147 == 999)

*if amount missing, expenditures = YES, coverage=INCOMPLETE:
qui sum dental_OOP
replace dental_OOP = r(mean) if (dental_OOP == .) & ///
								 (HN165==2 | HN165==3 | HN165==5)

*if amount missing, expenditures=YES, coverage=COMPLETE:
replace dental_OOP = 0 if (dental_OOP == .) & (HN165==1 | HN165==6)
						   
*if amount missing, expenditures=YES, coverage=DK/NA/RF/unsettled:
qui sum dental_OOP
replace dental_OOP = r(mean) if (dental_OOP == .) & ///
								 (HN165==7 | HN165==8 | HN165==9)

*if amount missing, expenditures=YES, coverage=missing:
qui sum dental_OOP
replace dental_OOP = r(mean) if (dental_OOP == .) & ///
								 (HN164 == 1) & ///
								 (HN165 == .)
								 
*if amount missing, expenditures = NO:						          
replace dental_OOP = 0 if (dental_OOP == .) & (HN164 == 5)

*if amount missing, expenditures = DK/NA/RF:
qui sum dental_OOP
replace dental_OOP = r(mean) if (dental_OOP == .) & (HN164==8 | HN164==9)

*impute if missing, take drugs regularly, coverage is incomplete:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(HN176 == 2 | HN176 == 3 | HN176 == 5)

*set to 0 if missing, coverage is complete (==1) OR no charge (==6):
replace RX_OOP = 0 if (RX_OOP == .) & (HN176 == 1 | HN176 == 6)

*impute if missing, take drugs and coverage=DK/NA/RF/unsettled:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(HN176 == 7 | HN176 == 8 | HN176 == 9)

*impute if missing, take drugs regularly (HN175==1) or medications known (==7), 
*and coverage info is missing:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(HN175 == 1 | HN175 == 7) & ///
							(HN176 == .)
							
*set to 0 if don't take drugs regularly:							
replace RX_OOP = 0 if (RX_OOP == .) & (HN175 == 5)

*impute if unknown whether take drugs regularly:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & (HN175 == 8 | HN175 == 9)

*impute if expenses=YES, coverage=INCOMPLETE:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (HN190 == 2 | HN190 == 3 | HN190 == 5)

*set to 0 if coverage=COMPLETE (==1) or no charge (==6):
replace home_OOP = 0 if (home_OOP == .) & (HN190 == 1 | HN190 == 6)

*impute if expenses=YES, coverage=DK/NA/RF/unsettled:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (HN190 == 7 | HN190 == 8 | HN190 == 9)

*impute if expenses=YES, coverage=missing:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (HN189 == 1) & ///
							  (HN190 == .)
							  
*set to 0 if expenses=NO:
replace home_OOP = 0 if (home_OOP == .) & (HN189 == 5)

*impute if expenses=DK/NA/RF:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (HN189 == 8) | (HN189 == 9) 
							  
*impute where expenses=YES, had to pay=YES:
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & (HN202==1) & (HN203==1)

*set to 0 where expenses=YES, had to pay=NO:
replace special_OOP = 0 if (special_OOP == .) & (HN202==1) & (HN203==5)

*impute where expenses=YES, had to pay=DK/NA/RF:
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & (HN202==1) & ///
											      (HN203==8 | HN203==9)

*impute where expenses=YES, had to pay=missing:
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & (HN202==1) & ///
											      (HN203==.)

*set to 0 where expenses=NO:							    
replace special_OOP = 0 if (special_OOP == .) & (HN202 == 5)

*impute where expenses=DK/NA/RF:
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & (HN202 == 8 | HN202 == 9)

save $savedir/core2002_oopi2.dta, replace

********************************************************************************

use $savedir/core2004_oopi1.dta, clear
merge 1:1 HHID PN using $savedir/core2004_use.dta, nogen keepusing(hospital_nights nh_nights dr_visits qtile_*)

scalar z = cpi2004 / cpiBASE							  

*if amount missing, expenses=YES:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (JN009 == 1)

*if amount missing, expenses=NO:
replace MC_HMO = 0 if (MC_HMO == .) & (JN009 == 5)

*if amount missing, expenses=DK/NA/RF:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (JN009 == 8 | JN009 == 9)

*if missing, coverage=YES, PrevDescrPlan!=YES (!=1) (could be NO or DK/NA/RF):
qui sum long_term_care
replace long_term_care = r(mean) if (long_term_care == .) & ///
							        (JN071 == 1) & (JN072 != 1)

*if missing, coverage=NO OR coverage=YES and PrevDescrPlan==YES:
replace long_term_care = 0 if (long_term_care == .) & ///
							  ((JN071 == 5) | (JN071 == 1 & JN072 == 1))

*if missing, coverage=DK/NA/RF:
qui sum long_term_care
replace long_term_care = r(mean) if (long_term_care == .) & (JN071 == 8 | JN071 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1 == .) & ///
									   (JN039_1 == 1 | JN039_1 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 1:
replace private_medigap_1 = 0 if (private_medigap_1  == .) & ///
								 ((JN039_1 == 3) | (JN023 < 1))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1==.) & ///
									   (JN039_1 == 8 | JN039_1 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2 == .) & ///
									   (JN039_2 == 1 | JN039_2 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 2:
replace private_medigap_2 = 0 if (private_medigap_2  == .) & ///
								 ((JN039_2 == 3) | (JN023 < 2))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2==.) & ///
									   (JN039_2 == 8 | JN039_2 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if (private_medigap_3 == .) & ///
									   (JN039_3 == 1 | JN039_3 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 3:
replace private_medigap_3 = 0 if (private_medigap_3  == .) & ///
								 ((JN039_3 == 3) | (JN023 < 3))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if (private_medigap_3==.) & ///
									   (JN039_3 == 8 | JN039_3 == 9)
									   
egen private_medigap = rowtotal( private_medigap_1 ///
								 private_medigap_2 ///
								 private_medigap_3 ) , missing

*if sum is missing, but # plans is known and > 0:
qui sum private_medigap
replace private_medigap = r(mean) if (private_medigap == .) & ///
									 (JN023 > 0) & (JN023 < 98)

*if sum missing, # plans known to be 0:									 
replace private_medigap = 0 if (private_medigap == .) & (JN023 == 0)

*if sum missing, # plans unknown:
qui sum private_medigap
replace private_medigap = r(mean) if (private_medigap == .) & ///
									 (JN023 == 98 | JN023 == 99)									   									   									   

replace private_medigap = min( private_medigap , cond(JN001==1,400*z,2000*z) ) if !missing(private_medigap)

*impute with nights spent in hospital where possible if expenses were not fully covered
est restore hospital
predict x, xb
tab x qtile_hospital
replace hospital_OOP = z * x * hospital_nights if hospital_OOP == . & (JN099==1) & !(JN102==1 | JN102==6)
drop x

*if overnight stay==YES, amount missing, and expenses ARE NOT fully covered or no charge:
qui sum hospital_OOP								  
replace hospital_OOP = r(mean) if (hospital_OOP==.) & ///
								  (JN102==2 | JN102==3 | JN102==5)
								  								  								  
*if overnight stay==YES, amount missing, and expenses ARE fully covered:
replace hospital_OOP = 0 if (hospital_OOP==.) & (JN102==1 | JN102==6)

*if overnight stay==YES, amount missing, and coverage of expenses is DK/RF/NA, or costs
*are unsettled (==7):
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & ///
								  (JN102==7 | JN102==8 | JN102==9)

*if overnight stay==YES, coverage question not asked:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & ///
								  (JN099==1) & ///
								  (JN102==.)

*if overnight stay==NO and amount missing
replace hospital_OOP = 0 if (hospital_OOP==.) & (JN099==5)

*if overnight stay is DK/NA/RF and amount missing:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & (JN099==8 | JN099==9)

*impute with nights spent in NH where possible if expenses were not fully covered
est restore NH
predict x, xb
tab x qtile_nh
replace NH_OOP = z * x * nh_nights if NH_OOP == . & (JN114 == 1 | JA028 == 1) & !(JN118 == 1 | JN118 == 6)
drop x

*if amount missing; either stayed overnight in NH (JN114) or lives in NH (JA028); 
*insurance coverage known and incomplete:
sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & ///
							(JN118 == 2 | JN118 == 3 | JN118 == 5) 

*if amount missing and insurance coverage complete or no charge:							 
replace NH_OOP = 0 if (NH_OOP == .) & (JN118 == 1 | JN118 == 6)

*if amount missing; either stayed overnight in NH (JN114), lived in NH
*(JA028); insurance coverage unknown, not settled 
sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP == .) & ///
							(JN118 == 7 | JN118 == 8 | JN118 == 9)
					
*if amount missing; either stayed overnight in NH (JN114), lived in NH
*(JA028); coverage question not asked: 
sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP == .) & ///
							(JN114 == 1 | JA028 == 1) & ///
							(JN118 == .)
					
*if amount missing and the following are true--did not stay overnight in NH
*and did not live in NH before death:
replace NH_OOP = 0 if (NH_OOP == .) & (JN114==5 & JA028!=1)

*if amount missing, does not live in NH, but unsure whether stayed overnight in NH:
sum NH_OOP
replace NH_OOP = r(mean)  if (NH_OOP == .) & ///
							 (JA028!=1) & ///
							 (JN114 == 8 | JN114 == 9)

*if amount missing, expenditures = YES, coverage=INCOMPLETE:
qui sum patient_OOP
replace patient_OOP = r(mean) if (patient_OOP == .) & ///
								 (JN135==2 | JN135==3 | JN135==5)

*if amount missing, expenditures=YES, coverage=COMPLETE:
replace patient_OOP = 0 if (patient_OOP == .) & (JN135==1 | JN135==6)
						   
*if amount missing, expenditures=YES, coverage=DK/NA/RF/unsettled:
qui sum patient_OOP
replace patient_OOP = r(mean) if (patient_OOP == .) & ///
								 (JN135==7 | JN135==8 | JN135==9)

*if amount missing, expenditures=YES, coverage=missing:
qui sum patient_OOP
replace patient_OOP = r(mean) if (patient_OOP == .) & ///
								 (JN134 == 1) & ///
								 (JN135 == .)
								 
*if amount missing, expenditures = NO:						          
replace patient_OOP = 0 if (patient_OOP == .) & (JN134 == 5)

*if amount missing, expenditures = DK/NA/RF:
qui sum patient_OOP
replace patient_OOP = r(mean) if (patient_OOP == .) & (JN134==8 | JN134==9)

*impute using doctor visits if possible where expenses not fully covered
est restore doctor
predict x, xb
tab x qtile_doctor
replace doctor_OOP = z * x * dr_visits if doctor_OOP==. & (dr_visits > 0 & dr_visits < .) & JN152!=1
drop x

*if amount missing, insurance coverage known/incomplete:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(JN152 == 2 | JN152 == 3 | JN152 == 5)

*if amount missing, insurance coverage is complete:
replace doctor_OOP = 0 if (doctor_OOP == .) & (JN152 == 1 | JN152 == 6)

*if amount missing, extent of coverage is DK/NA/RF/unsettled:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(JN152 == 7 | JN152 == 8 | JN152 == 9)

*if amount missing, # visits known and > 0, coverage info missing:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
										   (dr_visits > 0 & dr_visits < .) & ///
		   								   (JN152 == .)
								
*if amount missing, # visits == 0:
replace doctor_OOP = 0 if (doctor_OOP == .) & (dr_visits == 0)

*if amount missing, # visits unknown:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(JN147 == 998 | JN147 == 999)
								
*if amount missing, expenditures = YES, coverage=INCOMPLETE:
qui sum dental_OOP
replace dental_OOP = r(mean) if (dental_OOP == .) & ///
								 (JN165==2 | JN165==3 | JN165==5)

*if amount missing, expenditures=YES, coverage=COMPLETE:
replace dental_OOP = 0 if (dental_OOP == .) & (JN165==1 | JN165==6)
						   
*if amount missing, expenditures=YES, coverage=DK/NA/RF/unsettled:
qui sum dental_OOP
replace dental_OOP = r(mean) if (dental_OOP == .) & ///
								 (JN165==7 | JN165==8 | JN165==9)

*if amount missing, expenditures=YES, coverage=missing:
qui sum dental_OOP
replace dental_OOP = r(mean) if (dental_OOP == .) & ///
								 (JN164 == 1) & ///
								 (JN165 == .)
								 
*if amount missing, expenditures = NO:						          
replace dental_OOP = 0 if (dental_OOP == .) & (JN164 == 5)

*if amount missing, expenditures = DK/NA/RF:
qui sum dental_OOP
replace dental_OOP = r(mean) if (dental_OOP == .) & (JN164==8 | JN164==9)								

*impute if missing, take drugs regularly, coverage is incomplete:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(JN176 == 2 | JN176 == 3 | JN176 == 5)

*set to 0 if missing, coverage is complete (==1) OR no charge (==6):
replace RX_OOP = 0 if (RX_OOP == .) & (JN176 == 1 | JN176 == 6)

*impute if missing, take drugs and coverage=DK/NA/RF/unsettled:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(JN176 == 7 | JN176 == 8 | JN176 == 9)

*impute if missing, take drugs regularly (JN175==1) or medications known (==7), 
*and coverage info is missing:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(JN175 == 1 | JN175 == 7) & ///
							(JN176 == .)
							
*set to 0 if don't take drugs regularly:							
replace RX_OOP = 0 if (RX_OOP == .) & (JN175 == 5)

*impute if unknown whether take drugs regularly:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & (JN175 == 8 | JN175 == 9)

*impute if expenses=YES, coverage=INCOMPLETE:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (JN190 == 2 | JN190 == 3 | JN190 == 5)

*set to 0 if coverage=COMPLETE (==1) or no charge (==6):
replace home_OOP = 0 if (home_OOP == .) & (JN190 == 1 | JN190 == 6)

*impute if expenses=YES, coverage=DK/NA/RF/unsettled:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (JN190 == 7 | JN190 == 8 | JN190 == 9)

*impute if expenses=YES, coverage=missing:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (JN189 == 1) & ///
							  (JN190 == .)
							  
*set to 0 if expenses=NO:
replace home_OOP = 0 if (home_OOP == .) & (JN189 == 5)

*impute if expenses=DK/NA/RF:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (JN189 == 8) | (JN189 == 9) 
							  
*impute where expenses=YES, had to pay=YES:
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & (JN202==1) & (JN203==1)

*set to 0 where expenses=YES, had to pay=NO:
replace special_OOP = 0 if (special_OOP == .) & (JN202==1) & (JN203==5)

*impute where expenses=YES, had to pay=DK/NA/RF:
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & (JN202==1) & ///
											          (JN203==8 | JN203==9)

*impute where expenses=YES, had to pay=missing:
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & (JN202==1) & ///
											          (JN203==.)

*set to 0 where expenses=NO:							    
replace special_OOP = 0 if (special_OOP == .) & (JN202 == 5)

*impute where expenses=DK/NA/RF:
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & (JN202 == 8 | JN202 == 9)							  

save $savedir/core2004_oopi2.dta, replace

********************************************************************************

use $savedir/core2006_oopi1.dta, clear
merge 1:1 HHID PN using $savedir/core2006_use.dta, nogen keepusing(hospital_nights nh_nights dr_visits qtile_*)

scalar z = cpi2006 / cpiBASE

*if amount missing, expenses=YES:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (KN009 == 1)

*if amount missing, expenses=NO:
replace MC_HMO = 0 if (MC_HMO == .) & (KN009 == 5)

*if amount missing, expenses=DK/NA/RF:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (KN009 == 8 | KN009 == 9)

*if amount missing, expenses=DK/NA/RF:
qui sum MC_D
replace MC_D = r(mean) if (MC_D == .) & (KN352 == 8 | KN352 == 9)

*special calculation for the number of months R has had MC Part D (this variable is unique to this wave):
gen MC_D_mo = KN395 if (KN395 !=98 & KN395 != 99)
gen MC_D_yr  = KN396 if (KN396 !=9998 & KN396 != 9999)
gen MC_D_date  = MC_D_yr + ((MC_D_mo - 1) / 12)

gen MC_D_months = round( 12 * (curr_iw_date - MC_D_date) )
replace MC_D_months = 1 if MC_D_months==0
replace MC_D_months = 0 if MC_D_months<0

*if missing, assume part d started on January 1, 2006:
replace MC_D_months = max( round( 12 * (curr_iw_date - 2006) ), 0) if missing(MC_D_months) & !missing(MC_D)

*cap the number of months respondent could have had mc part d at the number of months since January 1, 2006:
replace MC_D_months = min( MC_D_months, max( round( 12 * (curr_iw_date - 2006) ), 0) ) if !missing(MC_D_months)
						
*if missing, coverage=YES, PrevDescrPlan!=YES (!=1) (could be NO or DK/NA/RF):
qui sum long_term_care
replace long_term_care = r(mean) if (long_term_care == .) & ///
							        (KN071 == 1) & (KN072 != 1)

*if missing, coverage=NO OR coverage=YES and PrevDescrPlan==YES:
replace long_term_care = 0 if (long_term_care == .) & ///
							  ((KN071 == 5) | (KN071 == 1 & KN072 == 1))

*if missing, coverage=DK/NA/RF:
qui sum long_term_care
replace long_term_care = r(mean) if (long_term_care == .) & (KN071 == 8 | KN071 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1 == .) & ///
									   (KN039_1 == 1 | KN039_1 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 1:
replace private_medigap_1 = 0 if (private_medigap_1  == .) & ///
								 ((KN039_1 == 3) | (KN023 < 1))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1==.) & ///
									   (KN039_1 == 8 | KN039_1 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2 == .) & ///
									   (KN039_2 == 1 | KN039_2 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 2:
replace private_medigap_2 = 0 if (private_medigap_2  == .) & ///
								 ((KN039_2 == 3) | (KN023 < 2))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2==.) & ///
									   (KN039_2 == 8 | KN039_2 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if (private_medigap_3 == .) & ///
									   (KN039_3 == 1 | KN039_3 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 3:
replace private_medigap_3 = 0 if (private_medigap_3  == .) & ///
								 ((KN039_3 == 3) | (KN023 < 3))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if (private_medigap_3==.) & ///
									   (KN039_3 == 8 | KN039_3 == 9)

egen private_medigap = rowtotal( private_medigap_1 ///
								 private_medigap_2 ///
								 private_medigap_3 ) , missing

*if sum is missing, but # plans is known and > 0:
qui sum private_medigap
replace private_medigap = r(mean) if (private_medigap == .) & ///
									 (KN023 > 0) & (KN023 < 98)

*if sum missing, # plans known to be 0:									 
replace private_medigap = 0 if (private_medigap == .) & (KN023 == 0)

*if sum missing, # plans unknown:
qui sum private_medigap
replace private_medigap = r(mean) if (private_medigap == .) & ///
									 (KN023 == 98 | KN023 == 99)									   									   									   

replace private_medigap = min( private_medigap , cond(KN001==1,400*z,2000*z) ) if !missing(private_medigap)

*impute with nights spent in hospital where possible if expenses were not fully covered
est restore hospital
predict x, xb
tab x qtile_hospital
replace hospital_OOP = z * x * hospital_nights if hospital_OOP == . & (KN099==1) & !(KN102==1 | KN102==6)
drop x

*if overnight stay==YES, amount missing, and expenses ARE NOT fully covered or no charge:
qui sum hospital_OOP								  
replace hospital_OOP = r(mean) if (hospital_OOP==.) & ///
								  (KN102==2 | KN102==3 | KN102==5)
								  								  								  
*if overnight stay==YES, amount missing, and expenses ARE fully covered:
replace hospital_OOP = 0 if (hospital_OOP==.) & (KN102==1 | KN102==6)

*if overnight stay==YES, amount missing, and coverage of expenses is DK/RF/NA, or costs
*are unsettled (==7):
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & ///
								  (KN102==7 | KN102==8 | KN102==9)

*if overnight stay==YES, coverage question not asked:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & ///
								  (KN099==1) & ///
								  (KN102==.)

*if overnight stay==NO and amount missing
replace hospital_OOP = 0 if (hospital_OOP==.) & (KN099==5)

*if overnight stay is DK/NA/RF and amount missing:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & (KN099==8 | KN099==9)

*impute with nights spent in NH where possible if expenses were not fully covered
est restore NH
predict x, xb
tab x qtile_nh
replace NH_OOP = z * x * nh_nights if NH_OOP == . & (KN114 == 1 | KA028 == 1) & !(KN118 == 1 | KN118 == 6)
drop x

*if amount missing; either stayed overnight in NH (KN114) or lives in NH (KA028); 
*insurance coverage known and incomplete:
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & ///
							(KN118 == 2 | KN118 == 3 | KN118 == 5) 

*if amount missing and insurance coverage complete or no charge:							 
replace NH_OOP = 0 if (NH_OOP == .) & (KN118 == 1 | KN118 == 6)

*if amount missing; either stayed overnight in NH (KN114), lived in NH
*(KA028); insurance coverage unknown, not settled 
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP == .) & ///
							(KN118 == 7 | KN118 == 8 | KN118 == 9)
					
*if amount missing; either stayed overnight in NH (KN114), lived in NH
*(KA028); coverage question not asked: 
qui sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP == .) & ///
							(KN114 == 1 | KA028 == 1) & ///
							(KN118 == .)
					
*if amount missing and the following are true--did not stay overnight in NH
*and did not live in NH before death:
replace NH_OOP = 0 if (NH_OOP == .) & (KN114==5 & KA028!=1)

*if amount missing, does not live in NH, but unsure whether stayed overnight in NH:
qui sum NH_OOP
replace NH_OOP = r(mean)  if (NH_OOP == .) & ///
							 (KA028!=1) & ///
							 (KN114 == 8 | KN114 == 9)

*if amount missing, expenditures = YES, coverage=INCOMPLETE:
qui sum patient_OOP
replace patient_OOP = r(mean) if (patient_OOP == .) & ///
								 (KN135==2 | KN135==3 | KN135==5)

*if amount missing, expenditures=YES, coverage=COMPLETE:
replace patient_OOP = 0 if (patient_OOP == .) & (KN135==1 | KN135==6)
						   
*if amount missing, expenditures=YES, coverage=DK/NA/RF/unsettled:
qui sum patient_OOP
replace patient_OOP = r(mean) if (patient_OOP == .) & ///
								 (KN135==7 | KN135==8 | KN135==9)

*if amount missing, expenditures=YES, coverage=missing:
qui sum patient_OOP
replace patient_OOP = r(mean) if (patient_OOP == .) & ///
								 (KN134 == 1) & ///
								 (KN135 == .)
								 
*if amount missing, expenditures = NO:						          
replace patient_OOP = 0 if (patient_OOP == .) & (KN134 == 5)

*if amount missing, expenditures = DK/NA/RF:
qui sum patient_OOP
replace patient_OOP = r(mean) if (patient_OOP == .) & (KN134==8 | KN134==9)

*impute using doctor visits if possible where expenses not fully covered
est restore doctor
predict x, xb
tab x qtile_doctor
replace doctor_OOP = z * x * dr_visits if doctor_OOP==. & (dr_visits > 0 & dr_visits < .) & KN152!=1
drop x

*if amount missing, insurance coverage known/incomplete:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(KN152 == 2 | KN152 == 3 | KN152 == 5)

*if amount missing, insurance coverage is complete:
replace doctor_OOP = 0 if (doctor_OOP == .) & (KN152 == 1 | KN152 == 6)

*if amount missing, extent of coverage is DK/NA/RF/unsettled:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(KN152 == 7 | KN152 == 8 | KN152 == 9)

*if amount missing, # visits known and > 0, coverage info missing:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
										   (dr_visits > 0 & dr_visits < .) & ///
		   								   (KN152 == .)
								
*if amount missing, # visits == 0:
replace doctor_OOP = 0 if (doctor_OOP == .) & (dr_visits == 0)

*if amount missing, # visits unknown:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(KN147 == 998 | KN147 == 999)

*if amount missing, expenditures = YES, coverage=INCOMPLETE:
qui sum dental_OOP
replace dental_OOP = r(mean) if (dental_OOP == .) & ///
								 (KN165==2 | KN165==3 | KN165==5)

*if amount missing, expenditures=YES, coverage=COMPLETE:
replace dental_OOP = 0 if (dental_OOP == .) & (KN165==1 | KN165==6)
						   
*if amount missing, expenditures=YES, coverage=DK/NA/RF/unsettled:
qui sum dental_OOP
replace dental_OOP = r(mean) if (dental_OOP == .) & ///
								 (KN165==7 | KN165==8 | KN165==9)

*if amount missing, expenditures=YES, coverage=missing:
qui sum dental_OOP
replace dental_OOP = r(mean) if (dental_OOP == .) & ///
								 (KN164 == 1) & ///
								 (KN165 == .)
								 
*if amount missing, expenditures = NO:						          
replace dental_OOP = 0 if (dental_OOP == .) & (KN164 == 5)

*if amount missing, expenditures = DK/NA/RF:
qui sum dental_OOP
replace dental_OOP = r(mean) if (dental_OOP == .) & (KN164==8 | KN164==9)

*impute if missing, take drugs regularly, coverage is incomplete:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(KN176 == 2 | KN176 == 3 | KN176 == 5)

*set to 0 if missing, coverage is complete (==1) OR no charge (==6):
replace RX_OOP = 0 if (RX_OOP == .) & (KN176 == 1 | KN176 == 6)

*impute if missing, take drugs and coverage=DK/NA/RF/unsettled:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(KN176 == 7 | KN176 == 8 | KN176 == 9)

*impute if missing, take drugs regularly (KN175==1) or medications known (==7), 
*and coverage info is missing:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(KN175 == 1 | KN175 == 7) & ///
							(KN176 == .)
							
*set to 0 if don't take drugs regularly:							
replace RX_OOP = 0 if (RX_OOP == .) & (KN175 == 5)

*impute if unknown whether take drugs regularly:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & (KN175 == 8 | KN175 == 9)

*impute if expenses=YES, coverage=INCOMPLETE:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (KN190 == 2 | KN190 == 3 | KN190 == 5)

*set to 0 if coverage=COMPLETE (==1) or no charge (==6):
replace home_OOP = 0 if (home_OOP == .) & (KN190 == 1 | KN190 == 6)

*impute if expenses=YES, coverage=DK/NA/RF/unsettled:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (KN190 == 7 | KN190 == 8 | KN190 == 9)

*impute if expenses=YES, coverage=missing:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (KN189 == 1) & ///
							  (KN190 == .)
							  
*set to 0 if expenses=NO:
replace home_OOP = 0 if (home_OOP == .) & (KN189 == 5)

*impute if expenses=DK/NA/RF:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (KN189 == 8) | (KN189 == 9) 
							  
*impute where expenses=YES, had to pay=YES:
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & (KN202==1) & (KN203==1)

*set to 0 where expenses=YES, had to pay=NO:
replace special_OOP = 0 if (special_OOP == .) & (KN202==1) & (KN203==5)

*impute where expenses=YES, had to pay=DK/NA/RF:
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & (KN202==1) & ///
											      (KN203==8 | KN203==9)

*impute where expenses=YES, had to pay=missing:
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & (KN202==1) & ///
											      (KN203==.)

*set to 0 where expenses=NO:							    
replace special_OOP = 0 if (special_OOP == .) & (KN202 == 5)

*impute where expenses=DK/NA/RF:
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & (KN202 == 8 | KN202 == 9)

save $savedir/core2006_oopi2.dta, replace

********************************************************************************

use $savedir/core2008_oopi1.dta, clear
merge 1:1 HHID PN using $savedir/core2008_use.dta, nogen keepusing(hospital_nights nh_nights dr_visits qtile_*)

scalar z = cpi2008 / cpiBASE							  

*if amount missing, expenses=YES:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (LN009 == 1)

*if amount missing, expenses=NO:
replace MC_HMO = 0 if (MC_HMO == .) & (LN009 == 5)

*if amount missing, expenses=DK/NA/RF:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (LN009 == 8 | LN009 == 9)

*if amount missing, signed up for coverage=YES & how pay premiums != don't pay anything):
qui sum MC_D
replace MC_D = r(mean) if (MC_D == .) & (LN352 == 1 | LN352 == 3) & (LN423 != 4)  //rrd: changed 5 to 4 for LN423

*if amount missing, expenses=NO or how pay premiums==don't pay anything:
replace MC_D = 0 if (MC_D == .) & (LN352 == 5 | LN423 == 4)		//rrd: changed 5 to 4 for LN423

*if amount missing, expenses=DK/NA/RF:
qui sum MC_D
replace MC_D = r(mean) if (MC_D == .) & (LN352 == 8 | LN352 == 9)

*if missing, coverage=YES, PrevDescrPlan!=YES (!=1) (could be NO or DK/NA/RF):
qui sum long_term_care
replace long_term_care = r(mean) if (long_term_care == .) & ///
							        (LN071 == 1) & (LN072 != 1)

*if missing, coverage=NO OR coverage=YES and PrevDescrPlan==YES:
replace long_term_care = 0 if (long_term_care == .) & ///
							  ((LN071 == 5) | (LN071 == 1 & LN072 == 1))

*if missing, coverage=DK/NA/RF:
qui sum long_term_care
replace long_term_care = r(mean) if (long_term_care == .) & (LN071 == 8 | LN071 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1 == .) & ///
									   (LN039_1 == 1 | LN039_1 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 1:
replace private_medigap_1 = 0 if (private_medigap_1  == .) & ///
								 ((LN039_1 == 3) | (LN023 < 1))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1==.) & ///
									   (LN039_1 == 8 | LN039_1 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2 == .) & ///
									   (LN039_2 == 1 | LN039_2 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 2:
replace private_medigap_2 = 0 if (private_medigap_2  == .) & ///
								 ((LN039_2 == 3) | (LN023 < 2))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2==.) & ///
									   (LN039_2 == 8 | LN039_2 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if (private_medigap_3 == .) & ///
									   (LN039_3 == 1 | LN039_3 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 3:
replace private_medigap_3 = 0 if (private_medigap_3  == .) & ///
								 ((LN039_3 == 3) | (LN023 < 3))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if (private_medigap_3==.) & ///
									   (LN039_3 == 8 | LN039_3 == 9)

egen private_medigap = rowtotal( private_medigap_1 ///
								 private_medigap_2 ///
								 private_medigap_3 ) , missing

*if sum is missing, but # plans is known and > 0:
qui sum private_medigap
replace private_medigap = r(mean) if (private_medigap == .) & ///
									 (LN023 > 0) & (LN023 < 98)

*if sum missing, # plans known to be 0:									 
replace private_medigap = 0 if (private_medigap == .) & (LN023 == 0)

*if sum missing, # plans unknown:
qui sum private_medigap
replace private_medigap = r(mean) if (private_medigap == .) & ///
									 (LN023 == 98 | LN023 == 99)									   									   									   

replace private_medigap = min( private_medigap , cond(LN001==1,400*z,2000*z) ) if !missing(private_medigap)

*impute with nights spent in hospital where possible if expenses were not fully covered
est restore hospital
predict x, xb
tab x qtile_hospital
replace hospital_OOP = z * x * hospital_nights if hospital_OOP == . & (LN099==1) & !(LN102==1 | LN102==6)
drop x

*if overnight stay==YES, amount missing, and expenses ARE NOT fully covered or no charge:
qui sum hospital_OOP								  
replace hospital_OOP = r(mean) if (hospital_OOP==.) & ///
								  (LN102==2 | LN102==3 | LN102==5)
								  								  								  
*if overnight stay==YES, amount missing, and expenses ARE fully covered:
replace hospital_OOP = 0 if (hospital_OOP==.) & (LN102==1 | LN102==6)

*if overnight stay==YES, amount missing, and coverage of expenses is DK/RF/NA, or costs
*are unsettled (==7):
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & ///
								  (LN102==7 | LN102==8 | LN102==9)

*if overnight stay==YES, coverage question not asked:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & ///
								  (LN099==1) & ///
								  (LN102==.)

*if overnight stay==NO and amount missing
replace hospital_OOP = 0 if (hospital_OOP==.) & (LN099==5)

*if overnight stay is DK/NA/RF and amount missing:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & (LN099==8 | LN099==9)

*impute with nights spent in NH where possible if expenses were not fully covered
est restore NH
predict x, xb
tab x qtile_nh
replace NH_OOP = z * x * nh_nights if NH_OOP == . & (LN114 == 1 | LA028 == 1) & !(LN118 == 1 | LN118 == 6)
drop x

*if amount missing; either stayed overnight in NH (LN114) or lives in NH (LA028); 
*insurance coverage known and incomplete:
sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & ///
							(LN118 == 2 | LN118 == 3 | LN118 == 5) 

*if amount missing and insurance coverage complete or no charge:							 
replace NH_OOP = 0 if (NH_OOP == .) & (LN118 == 1 | LN118 == 6)

*if amount missing; either stayed overnight in NH (LN114), lived in NH
*(LA028); insurance coverage unknown, not settled
sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP == .) & ///
							(LN118 == 7 | LN118 == 8 | LN118 == 9)
					
*if amount missing; either stayed overnight in NH (LN114), lived in NH
*(LA028); coverage question not asked: 
sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP == .) & ///
							(LN114 == 1 | LA028 == 1) & ///
							(LN118 == .)
					
*if amount missing and the following are true--did not stay overnight in NH
*and did not live in NH before death:
replace NH_OOP = 0 if (NH_OOP == .) & (LN114==5 & LA028!=1)

*if amount missing, does not live in NH, but unsure whether stayed overnight in NH:
sum NH_OOP
replace NH_OOP = r(mean)  if (NH_OOP == .) & ///
							 (LA028!=1) & ///
							 (LN114 == 8 | LN114 == 9)
							 
*if amount missing, expenditures = YES, coverage=INCOMPLETE:
qui sum patient_OOP
replace patient_OOP = r(mean) if (patient_OOP == .) & ///
								 (LN135==2 | LN135==3 | LN135==5)

*if amount missing, expenditures=YES, coverage=COMPLETE:
replace patient_OOP = 0 if (patient_OOP == .) & (LN135==1 | LN135==6)
						   
*if amount missing, expenditures=YES, coverage=DK/NA/RF/unsettled:
qui sum patient_OOP
replace patient_OOP = r(mean) if (patient_OOP == .) & ///
								 (LN135==7 | LN135==8 | LN135==9)

*if amount missing, expenditures=YES, coverage=missing:
qui sum patient_OOP
replace patient_OOP = r(mean) if (patient_OOP == .) & ///
								 (LN134 == 1) & ///
								 (LN135 == .)
								 
*if amount missing, expenditures = NO:						          
replace patient_OOP = 0 if (patient_OOP == .) & (LN134 == 5)

*if amount missing, expenditures = DK/NA/RF:
qui sum patient_OOP
replace patient_OOP = r(mean) if (patient_OOP == .) & (LN134==8 | LN134==9)

*impute using doctor visits if possible where expenses not fully covered
est restore doctor
predict x, xb
tab x qtile_doctor
replace doctor_OOP = z * x * dr_visits if doctor_OOP==. & (dr_visits > 0 & dr_visits < .) & LN152!=1
drop x

*if amount missing, insurance coverage known/incomplete:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(LN152 == 2 | LN152 == 3 | LN152 == 5)

*if amount missing, insurance coverage is complete:
replace doctor_OOP = 0 if (doctor_OOP == .) & (LN152 == 1 | LN152 == 6)

*if amount missing, extent of coverage is DK/NA/RF/unsettled:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(LN152 == 7 | LN152 == 8 | LN152 == 9)

*if amount missing, # visits known and > 0, coverage info missing:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
										   (dr_visits > 0 & dr_visits < .) & ///
		   								   (LN152 == .)
								
*if amount missing, # visits == 0:
replace doctor_OOP = 0 if (doctor_OOP == .) & (dr_visits == 0)

*if amount missing, # visits unknown:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(LN147 == 998 | LN147 == 999)

*if amount missing, expenditures = YES, coverage=INCOMPLETE:
qui sum dental_OOP
replace dental_OOP = r(mean) if (dental_OOP == .) & ///
								 (LN165==2 | LN165==3 | LN165==5)

*if amount missing, expenditures=YES, coverage=COMPLETE:
replace dental_OOP = 0 if (dental_OOP == .) & (LN165==1 | LN165==6)
						   
*if amount missing, expenditures=YES, coverage=DK/NA/RF/unsettled:
qui sum dental_OOP
replace dental_OOP = r(mean) if (dental_OOP == .) & ///
								 (LN165==7 | LN165==8 | LN165==9)

*if amount missing, expenditures=YES, coverage=missing:
qui sum dental_OOP
replace dental_OOP = r(mean) if (dental_OOP == .) & ///
								 (LN164 == 1) & ///
								 (LN165 == .)
								 
*if amount missing, expenditures = NO:						          
replace dental_OOP = 0 if (dental_OOP == .) & (LN164 == 5)

*if amount missing, expenditures = DK/NA/RF:
qui sum dental_OOP
replace dental_OOP = r(mean) if (dental_OOP == .) & (LN164==8 | LN164==9)

*impute if missing, take drugs regularly, coverage is incomplete:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(LN176 == 2 | LN176 == 3 | LN176 == 5)

*set to 0 if missing, coverage is complete (==1) OR no charge (==6):
replace RX_OOP = 0 if (RX_OOP == .) & (LN176 == 1 | LN176 == 6)

*impute if missing, take drugs and coverage=DK/NA/RF/unsettled:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(LN176 == 7 | LN176 == 8 | LN176 == 9)

*impute if missing, take drugs regularly (LN175==1) or medications known (==7), 
*and coverage info is missing:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(LN175 == 1 | LN175 == 7) & ///
							(LN176 == .)
							
*set to 0 if don't take drugs regularly:							
replace RX_OOP = 0 if (RX_OOP == .) & (LN175 == 5)

*impute if unknown whether take drugs regularly:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & (LN175 == 8 | LN175 == 9)

*impute if expenses=YES, coverage=INCOMPLETE:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (LN190 == 2 | LN190 == 3 | LN190 == 5)

*set to 0 if coverage=COMPLETE (==1) or no charge (==6):
replace home_OOP = 0 if (home_OOP == .) & (LN190 == 1 | LN190 == 6)

*impute if expenses=YES, coverage=DK/NA/RF/unsettled:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (LN190 == 7 | LN190 == 8 | LN190 == 9)

*impute if expenses=YES, coverage=missing:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (LN189 == 1) & ///
							  (LN190 == .)
							  
*set to 0 if expenses=NO:
replace home_OOP = 0 if (home_OOP == .) & (LN189 == 5)

*impute if expenses=DK/NA/RF:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (LN189 == 8) | (LN189 == 9) 
							  
*impute where expenses=YES, had to pay=YES:
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & (LN202==1) & (LN203==1)

*set to 0 where expenses=YES, had to pay=NO:
replace special_OOP = 0 if (special_OOP == .) & (LN202==1) & (LN203==5)

*impute where expenses=YES, had to pay=DK/NA/RF:
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & (LN202==1) & ///
											      (LN203==8 | LN203==9)

*impute where expenses=YES, had to pay=missing:
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & (LN202==1) & ///
											      (LN203==.)

*set to 0 where expenses=NO:							    
replace special_OOP = 0 if (special_OOP == .) & (LN202 == 5)

*impute where expenses=DK/NA/RF:
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & (LN202 == 8 | LN202 == 9)

save $savedir/core2008_oopi2.dta, replace

********************************************************************************

use $savedir/core2010_oopi1.dta, clear
merge 1:1 HHID PN using $savedir/core2010_use.dta, nogen keepusing(hospital_nights nh_nights dr_visits qtile_*)

scalar z = cpi2010 / cpiBASE							  

*if amount missing, expenses=YES, how pay != don't pay anything:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (MN009 == 1) & (MN265 != 5)

*if amount missing, expenses=NO or how pay = don't pay anything:
replace MC_HMO = 0 if (MC_HMO == .) & (MN009 == 5 | MN265 == 5)

*if amount missing, expenses=DK/NA/RF:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (MN009 == 8 | MN009 == 9)

*if amount missing, signed up for coverage=YES & how pay premiums != don't pay anything):
qui sum MC_D
replace MC_D = r(mean) if (MC_D == .) & (MN352 == 1 | MN352 == 3) & (MN423 != 4) //rrd: changed 5 to 4 for MN423

*if amount missing, expenses=NO or how pay premiums==don't pay anything:
replace MC_D = 0 if (MC_D == .) & (MN352 == 5 | MN423 == 4) //rrd: changed 5 to 4 for MN423

*if amount missing, expenses=DK/NA/RF:
qui sum MC_D
replace MC_D = r(mean) if (MC_D == .) & (MN352 == 8 | MN352 == 9)

*if missing, coverage=YES, PrevDescrPlan!=YES (!=1) (could be NO or DK/NA/RF):
qui sum long_term_care
replace long_term_care = r(mean) if (long_term_care == .) & ///
							        (MN071 == 1) & (MN072 != 1)

*if missing, coverage=NO OR coverage=YES and PrevDescrPlan==YES:
replace long_term_care = 0 if (long_term_care == .) & ///
							  ((MN071 == 5) | (MN071 == 1 & MN072 == 1))

*if missing, coverage=DK/NA/RF:
qui sum long_term_care
replace long_term_care = r(mean) if (long_term_care == .) & (MN071 == 8 | MN071 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1 == .) & ///
									   (MN039_1 == 1 | MN039_1 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 1:
replace private_medigap_1 = 0 if (private_medigap_1  == .) & ///
								 ((MN039_1 == 3) | (MN023 < 1))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1==.) & ///
									   (MN039_1 == 8 | MN039_1 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2 == .) & ///
									   (MN039_2 == 1 | MN039_2 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 2:
replace private_medigap_2 = 0 if (private_medigap_2  == .) & ///
								 ((MN039_2 == 3) | (MN023 < 2))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2==.) & ///
									   (MN039_2 == 8 | MN039_2 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if (private_medigap_3 == .) & ///
									   (MN039_3 == 1 | MN039_3 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 3:
replace private_medigap_3 = 0 if (private_medigap_3  == .) & ///
								 ((MN039_3 == 3) | (MN023 < 3))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if (private_medigap_3==.) & ///
									   (MN039_3 == 8 | MN039_3 == 9)

egen private_medigap = rowtotal( private_medigap_1 ///
								 private_medigap_2 ///
								 private_medigap_3 ) , missing

*if sum is missing, but # plans is known and > 0:
qui sum private_medigap
replace private_medigap = r(mean) if (private_medigap == .) & ///
									 (MN023 > 0) & (MN023 < 98)

*if sum missing, # plans known to be 0:									 
replace private_medigap = 0 if (private_medigap == .) & (MN023 == 0)

*if sum missing, # plans unknown:
qui sum private_medigap
replace private_medigap = r(mean) if (private_medigap == .) & ///
									 (MN023 == 98 | MN023 == 99)									   									   									   

replace private_medigap = min( private_medigap , cond(MN001==1,400*z,2000*z) ) if !missing(private_medigap)

*impute with nights spent in hospital where possible if expenses were not fully covered
est restore hospital
predict x, xb
tab x qtile_hospital
replace hospital_OOP = z * x * hospital_nights if hospital_OOP == . & (MN099==1) & !(MN102==1 | MN102==6)
drop x

*if overnight stay==YES, amount missing, and expenses ARE NOT fully covered or no charge:
qui sum hospital_OOP								  
replace hospital_OOP = r(mean) if (hospital_OOP==.) & ///
								  (MN102==2 | MN102==3 | MN102==5)
								  								  								  
*if overnight stay==YES, amount missing, and expenses ARE fully covered:
replace hospital_OOP = 0 if (hospital_OOP==.) & (MN102==1 | MN102==6)

*if overnight stay==YES, amount missing, and coverage of expenses is DK/RF/NA, or costs
*are unsettled (==7):
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & ///
								  (MN102==7 | MN102==8 | MN102==9)

*if overnight stay==YES, coverage question not asked:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & ///
								  (MN099==1) & ///
								  (MN102==.)

*if overnight stay==NO and amount missing
replace hospital_OOP = 0 if (hospital_OOP==.) & (MN099==5)

*if overnight stay is DK/NA/RF and amount missing:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & (MN099==8 | MN099==9)

*impute with nights spent in NH where possible if expenses were not fully covered
est restore NH
predict x, xb
tab x qtile_nh
replace NH_OOP = z * x * nh_nights if NH_OOP == . & (MN114 == 1 | MA028 == 1) & !(MN118 == 1 | MN118 == 6)
drop x

*if amount missing; either stayed overnight in NH (MN114) or lives in NH (MA028); 
*insurance coverage known and incomplete:
sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & ///
							(MN118 == 2 | MN118 == 3 | MN118 == 5) 

*if amount missing and insurance coverage complete or no charge:							 
replace NH_OOP = 0 if (NH_OOP == .) & (MN118 == 1 | MN118 == 6)

*if amount missing; either stayed overnight in NH (MN114), lived in NH
*(MA028); insurance coverage unknown, not settled
sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP == .) & ///
							(MN118 == 7 | MN118 == 8 | MN118 == 9)
					
*if amount missing; either stayed overnight in NH (MN114), lived in NH
*(MA028); coverage question not asked: 
sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP == .) & ///
							(MN114 == 1 | MA028 == 1) & ///
							(MN118 == .)
					
*if amount missing and the following are true--did not stay overnight in NH
*and did not live in NH before death:
replace NH_OOP = 0 if (NH_OOP == .) & (MN114==5 & MA028!=1)

*if amount missing, does not live in NH, but unsure whether stayed overnight in NH:
sum NH_OOP
replace NH_OOP = r(mean)  if (NH_OOP == .) & ///
							 (MA028!=1) & ///
							 (MN114 == 8 | MN114 == 9)

*if amount missing, expenditures = YES, coverage=INCOMPLETE:
qui sum patient_OOP
replace patient_OOP = r(mean) if (patient_OOP == .) & ///
								 (MN135==2 | MN135==3 | MN135==5)

*if amount missing, expenditures=YES, coverage=COMPLETE:
replace patient_OOP = 0 if (patient_OOP == .) & (MN135==1 | MN135==6)
						   
*if amount missing, expenditures=YES, coverage=DK/NA/RF/unsettled:
qui sum patient_OOP
replace patient_OOP = r(mean) if (patient_OOP == .) & ///
								 (MN135==7 | MN135==8 | MN135==9)

*if amount missing, expenditures=YES, coverage=missing:
qui sum patient_OOP
replace patient_OOP = r(mean) if (patient_OOP == .) & ///
								 (MN134 == 1) & ///
								 (MN135 == .)
								 
*if amount missing, expenditures = NO:						          
replace patient_OOP = 0 if (patient_OOP == .) & (MN134 == 5)

*if amount missing, expenditures = DK/NA/RF:
qui sum patient_OOP
replace patient_OOP = r(mean) if (patient_OOP == .) & (MN134==8 | MN134==9)

*impute using doctor visits if possible where expenses not fully covered
est restore doctor
predict x, xb
tab x qtile_doctor
replace doctor_OOP = z * x * dr_visits if doctor_OOP==. & (dr_visits > 0 & dr_visits < .) & MN152!=1
drop x

*if amount missing, insurance coverage known/incomplete:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(MN152 == 2 | MN152 == 3 | MN152 == 5)

*if amount missing, insurance coverage is complete:
replace doctor_OOP = 0 if (doctor_OOP == .) & (MN152 == 1 | MN152 == 6)

*if amount missing, extent of coverage is DK/NA/RF/unsettled:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(MN152 == 7 | MN152 == 8 | MN152 == 9)

*if amount missing, # visits known and > 0, coverage info missing:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
										   (dr_visits > 0 & dr_visits < .) & ///
		   								   (MN152 == .)
								
*if amount missing, # visits == 0:
replace doctor_OOP = 0 if (doctor_OOP == .) & (dr_visits == 0)

*if amount missing, # visits unknown:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(MN147 == 998 | MN147 == 999)

*if amount missing, expenditures = YES, coverage=INCOMPLETE:
qui sum dental_OOP
replace dental_OOP = r(mean) if (dental_OOP == .) & ///
								 (MN165==2 | MN165==3 | MN165==5)

*if amount missing, expenditures=YES, coverage=COMPLETE:
replace dental_OOP = 0 if (dental_OOP == .) & (MN165==1 | MN165==6)
						   
*if amount missing, expenditures=YES, coverage=DK/NA/RF/unsettled:
qui sum dental_OOP
replace dental_OOP = r(mean) if (dental_OOP == .) & ///
								 (MN165==7 | MN165==8 | MN165==9)

*if amount missing, expenditures=YES, coverage=missing:
qui sum dental_OOP
replace dental_OOP = r(mean) if (dental_OOP == .) & ///
								 (MN164 == 1) & ///
								 (MN165 == .)
								 
*if amount missing, expenditures = NO:						          
replace dental_OOP = 0 if (dental_OOP == .) & (MN164 == 5)

*if amount missing, expenditures = DK/NA/RF:
qui sum dental_OOP
replace dental_OOP = r(mean) if (dental_OOP == .) & (MN164==8 | MN164==9)

*impute if missing, take drugs regularly, coverage is incomplete:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(MN176 == 2 | MN176 == 3 | MN176 == 5)

*set to 0 if missing, coverage is complete (==1) OR no charge (==6):
replace RX_OOP = 0 if (RX_OOP == .) & (MN176 == 1 | MN176 == 6)

*impute if missing, take drugs and coverage=DK/NA/RF/unsettled:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(MN176 == 7 | MN176 == 8 | MN176 == 9)

*impute if missing, take drugs regularly (MN175==1) or medications known (==7), 
*and coverage info is missing:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(MN175 == 1 | MN175 == 7) & ///
							(MN176 == .)
							
*set to 0 if don't take drugs regularly:							
replace RX_OOP = 0 if (RX_OOP == .) & (MN175 == 5)

*impute if unknown whether take drugs regularly:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & (MN175 == 8 | MN175 == 9)

*impute if expenses=YES, coverage=INCOMPLETE:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (MN190 == 2 | MN190 == 3 | MN190 == 5)

*set to 0 if coverage=COMPLETE (==1) or no charge (==6):
replace home_OOP = 0 if (home_OOP == .) & (MN190 == 1 | MN190 == 6)

*impute if expenses=YES, coverage=DK/NA/RF/unsettled:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (MN190 == 7 | MN190 == 8 | MN190 == 9)

*impute if expenses=YES, coverage=missing:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (MN189 == 1) & ///
							  (MN190 == .)
							  
*set to 0 if expenses=NO:
replace home_OOP = 0 if (home_OOP == .) & (MN189 == 5)

*impute if expenses=DK/NA/RF:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (MN189 == 8) | (MN189 == 9) 
							  
*impute where expenses=YES, had to pay=YES:
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & (MN202==1) & (MN203==1)

*set to 0 where expenses=YES, had to pay=NO:
replace special_OOP = 0 if (special_OOP == .) & (MN202==1) & (MN203==5)

*impute where expenses=YES, had to pay=DK/NA/RF:
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & (MN202==1) & ///
											      (MN203==8 | MN203==9)

*impute where expenses=YES, had to pay=missing:
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & (MN202==1) & ///
											      (MN203==.)

*set to 0 where expenses=NO:							    
replace special_OOP = 0 if (special_OOP == .) & (MN202 == 5)

*impute where expenses=DK/NA/RF:
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & (MN202 == 8 | MN202 == 9)

*impute where expenses=YES:
qui sum other_OOP
replace other_OOP = r(mean) if (other_OOP == .) & (MN332 == 1)

*set to 0 where expenses=NO:							    
replace other_OOP = 0 if (other_OOP == .) & (MN332 == 5)

*impute where expenses=DK/NA/RF:
qui sum other_OOP
replace other_OOP = r(mean) if (other_OOP == .) & (MN332 == 8 | MN332 == 9)

save $savedir/core2010_oopi2.dta, replace							  

********************************************************************************

use $savedir/core2012_oopi1.dta, clear
merge 1:1 HHID PN using $savedir/core2012_use.dta, nogen keepusing(hospital_nights nh_nights dr_visits qtile_*)

scalar z = cpi2012 / cpiBASE							  

*if amount missing, expenses=YES, how pay != don't pay anything:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (NN009 == 1) 

*if amount missing, expenses=NO or how pay = don't pay anything:
replace MC_HMO = 0 if (MC_HMO == .) & (NN009 == 5)

*if amount missing, expenses=DK/NA/RF:
qui sum MC_HMO
replace MC_HMO = r(mean) if (MC_HMO == .) & (NN009 == 8 | NN009 == 9)

*if amount missing, signed up for coverage=YES & how pay premiums != don't pay anything):
qui sum MC_D
replace MC_D = r(mean) if (MC_D == .) & (NN352 == 1 | NN352 == 3) 

*if amount missing, expenses=NO or how pay premiums==don't pay anything:
replace MC_D = 0 if (MC_D == .) & (NN352 == 5)

*if amount missing, expenses=DK/NA/RF:
qui sum MC_D
replace MC_D = r(mean) if (MC_D == .) & (NN352 == 8 | NN352 == 9)

*if missing, coverage=YES, PrevDescrPlan!=YES (!=1) (could be NO or DK/NA/RF):
qui sum long_term_care
replace long_term_care = r(mean) if (long_term_care == .) & ///
							        (NN071 == 1) & (NN072 != 1)

*if missing, coverage=NO OR coverage=YES and PrevDescrPlan==YES:
replace long_term_care = 0 if (long_term_care == .) & ///
							  ((NN071 == 5) | (NN071 == 1 & NN072 == 1))

*if missing, coverage=DK/NA/RF:
qui sum long_term_care
replace long_term_care = r(mean) if (long_term_care == .) & (NN071 == 8 | NN071 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1 == .) & ///
									   (NN039_1 == 1 | NN039_1 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 1:
replace private_medigap_1 = 0 if (private_medigap_1  == .) & ///
								 ((NN039_1 == 3) | (NN023 < 1))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if (private_medigap_1==.) & ///
									   (NN039_1 == 8 | NN039_1 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2 == .) & ///
									   (NN039_2 == 1 | NN039_2 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 2:
replace private_medigap_2 = 0 if (private_medigap_2  == .) & ///
								 ((NN039_2 == 3) | (NN023 < 2))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if (private_medigap_2==.) & ///
									   (NN039_2 == 8 | NN039_2 == 9)

*if amount missing, pay ALL ("1") or SOME ("2") of costs:
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if (private_medigap_3 == .) & ///
									   (NN039_3 == 1 | NN039_3 == 2)

*if amount missing, pay NONE ("3") of costs OR # plans < 3:
replace private_medigap_3 = 0 if (private_medigap_3  == .) & ///
								 ((NN039_3 == 3) | (NN023 < 3))

*if amount missing, DK/NA/RF whether pay any of the costs:
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if (private_medigap_3==.) & ///
									   (NN039_3 == 8 | NN039_3 == 9)

egen private_medigap = rowtotal( private_medigap_1 ///
								 private_medigap_2 ///
								 private_medigap_3 ) , missing

*if sum is missing, but # plans is known and > 0:
qui sum private_medigap
replace private_medigap = r(mean) if (private_medigap == .) & ///
									 (NN023 > 0) & (NN023 < 98)

*if sum missing, # plans known to be 0:									 
replace private_medigap = 0 if (private_medigap == .) & (NN023 == 0)

*if sum missing, # plans unknown:
qui sum private_medigap
replace private_medigap = r(mean) if (private_medigap == .) & ///
									 (NN023 == 98 | NN023 == 99)									   									   									   

replace private_medigap = min( private_medigap , cond(NN001==1,400*z,2000*z) ) if !missing(private_medigap)

*impute with nights spent in hospital where possible if expenses were not fully covered
est restore hospital
predict x, xb
tab x qtile_hospital
replace hospital_OOP = z * x * hospital_nights if hospital_OOP == . & (NN099==1) & !(NN102==1 | NN102==6)
drop x

*if overnight stay==YES, amount missing, and expenses ARE NOT fully covered or no charge:
qui sum hospital_OOP								  
replace hospital_OOP = r(mean) if (hospital_OOP==.) & ///
								  (NN102==2 | NN102==3 | NN102==5)
								  								  								  
*if overnight stay==YES, amount missing, and expenses ARE fully covered:
replace hospital_OOP = 0 if (hospital_OOP==.) & (NN102==1 | NN102==6)

*if overnight stay==YES, amount missing, and coverage of expenses is DK/RF/NA, or costs
*are unsettled (==7):
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & ///
								  (NN102==7 | NN102==8 | NN102==9)

*if overnight stay==YES, coverage question not asked:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & ///
								  (NN099==1) & ///
								  (NN102==.)

*if overnight stay==NO and amount missing
replace hospital_OOP = 0 if (hospital_OOP==.) & (NN099==5)

*if overnight stay is DK/NA/RF and amount missing:
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (hospital_OOP==.) & (NN099==8 | NN099==9)

*impute with nights spent in NH where possible if expenses were not fully covered
est restore NH
predict x, xb
tab x qtile_nh
replace NH_OOP = z * x * nh_nights if NH_OOP == . & (NN114 == 1 | NA028 == 1) & !(NN118 == 1 | NN118 == 6)
drop x

*if amount missing; either stayed overnight in NH (MN114) or lives in NH (MA028); 
*insurance coverage known and incomplete:
sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP==.) & ///
							(NN118 == 2 | NN118 == 3 | NN118 == 5) 

*if amount missing and insurance coverage complete or no charge:							 
replace NH_OOP = 0 if (NH_OOP == .) & (NN118 == 1 | NN118 == 6)

*if amount missing; either stayed overnight in NH (MN114), lived in NH
*(MA028); insurance coverage unknown, not settled
sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP == .) & ///
							(NN118 == 7 | NN118 == 8 | NN118 == 9)
					
*if amount missing; either stayed overnight in NH (MN114), lived in NH
*(MA028); coverage question not asked: 
sum NH_OOP
replace NH_OOP = r(mean) if (NH_OOP == .) & ///
							(NN114 == 1 | NA028 == 1) & ///
							(NN118 == .)
					
*if amount missing and the following are true--did not stay overnight in NH
*and did not live in NH before death:
replace NH_OOP = 0 if (NH_OOP == .) & (NN114==5 & NA028!=1)

*if amount missing, does not live in NH, but unsure whether stayed overnight in NH:
sum NH_OOP
replace NH_OOP = r(mean)  if (NH_OOP == .) & ///
							 (NA028!=1) & ///
							 (NN114 == 8 | NN114 == 9)

*if amount missing, expenditures = YES, coverage=INCOMPLETE:
qui sum patient_OOP
replace patient_OOP = r(mean) if (patient_OOP == .) & ///
								 (NN135==2 | NN135==3 | NN135==5)

*if amount missing, expenditures=YES, coverage=COMPLETE:
replace patient_OOP = 0 if (patient_OOP == .) & (NN135==1 | NN135==6)
						   
*if amount missing, expenditures=YES, coverage=DK/NA/RF/unsettled:
qui sum patient_OOP
replace patient_OOP = r(mean) if (patient_OOP == .) & ///
								 (NN135==7 | NN135==8 | NN135==9)

*if amount missing, expenditures=YES, coverage=missing:
qui sum patient_OOP
replace patient_OOP = r(mean) if (patient_OOP == .) & ///
								 (NN134 == 1) & ///
								 (NN135 == .)
								 
*if amount missing, expenditures = NO:						          
replace patient_OOP = 0 if (patient_OOP == .) & (NN134 == 5)

*if amount missing, expenditures = DK/NA/RF:
qui sum patient_OOP
replace patient_OOP = r(mean) if (patient_OOP == .) & (NN134==8 | NN134==9)

*impute using doctor visits if possible where expenses not fully covered
est restore doctor
predict x, xb
tab x qtile_doctor
replace doctor_OOP = z * x * dr_visits if doctor_OOP==. & (dr_visits > 0 & dr_visits < .) & NN152!=1
drop x

*if amount missing, insurance coverage known/incomplete:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(NN152 == 2 | NN152 == 3 | NN152 == 5)

*if amount missing, insurance coverage is complete:
replace doctor_OOP = 0 if (doctor_OOP == .) & (NN152 == 1 | NN152 == 6)

*if amount missing, extent of coverage is DK/NA/RF/unsettled:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(NN152 == 7 | NN152 == 8 | NN152 == 9)

*if amount missing, # visits known and > 0, coverage info missing:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
										   (dr_visits > 0 & dr_visits < .) & ///
		   								   (NN152 == .)
								
*if amount missing, # visits == 0:
replace doctor_OOP = 0 if (doctor_OOP == .) & (dr_visits == 0)

*if amount missing, # visits unknown:
qui sum doctor_OOP
replace doctor_OOP = r(mean) if (doctor_OOP == .) & ///
								(NN147 == 998 | NN147 == 999)

*if amount missing, expenditures = YES, coverage=INCOMPLETE:
qui sum dental_OOP
replace dental_OOP = r(mean) if (dental_OOP == .) & ///
								 (NN165==2 | NN165==3 | NN165==5)

*if amount missing, expenditures=YES, coverage=COMPLETE:
replace dental_OOP = 0 if (dental_OOP == .) & (NN165==1 | NN165==6)
						   
*if amount missing, expenditures=YES, coverage=DK/NA/RF/unsettled:
qui sum dental_OOP
replace dental_OOP = r(mean) if (dental_OOP == .) & ///
								 (NN165==7 | NN165==8 | NN165==9)

*if amount missing, expenditures=YES, coverage=missing:
qui sum dental_OOP
replace dental_OOP = r(mean) if (dental_OOP == .) & ///
								 (NN164 == 1) & ///
								 (NN165 == .)
								 
*if amount missing, expenditures = NO:						          
replace dental_OOP = 0 if (dental_OOP == .) & (NN164 == 5)

*if amount missing, expenditures = DK/NA/RF:
qui sum dental_OOP
replace dental_OOP = r(mean) if (dental_OOP == .) & (NN164==8 | NN164==9)

*impute if missing, take drugs regularly, coverage is incomplete:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(NN176 == 2 | NN176 == 3 | NN176 == 5)

*set to 0 if missing, coverage is complete (==1) OR no charge (==6):
replace RX_OOP = 0 if (RX_OOP == .) & (NN176 == 1 | NN176 == 6)

*impute if missing, take drugs and coverage=DK/NA/RF/unsettled:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(NN176 == 7 | NN176 == 8 | NN176 == 9)

*impute if missing, take drugs regularly (MN175==1) or medications known (==7), 
*and coverage info is missing:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & ///
							(NN175 == 1 | NN175 == 7) & ///
							(NN176 == .)
							
*set to 0 if don't take drugs regularly:							
replace RX_OOP = 0 if (RX_OOP == .) & (NN175 == 5)

*impute if unknown whether take drugs regularly:
qui sum RX_OOP
replace RX_OOP = r(mean) if (RX_OOP == .) & (NN175 == 8 | NN175 == 9)

*impute if expenses=YES, coverage=INCOMPLETE:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (NN190 == 2 | NN190 == 3 | NN190 == 5)

*set to 0 if coverage=COMPLETE (==1) or no charge (==6):
replace home_OOP = 0 if (home_OOP == .) & (NN190 == 1 | NN190 == 6)

*impute if expenses=YES, coverage=DK/NA/RF/unsettled:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (NN190 == 7 | NN190 == 8 | NN190 == 9)

*impute if expenses=YES, coverage=missing:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (NN189 == 1) & ///
							  (NN190 == .)
							  
*set to 0 if expenses=NO:
replace home_OOP = 0 if (home_OOP == .) & (NN189 == 5)

*impute if expenses=DK/NA/RF:
qui sum home_OOP
replace home_OOP = r(mean) if (home_OOP == .) & ///
							  (NN189 == 8) | (NN189 == 9) 
							  
*impute where expenses=YES, had to pay=YES:
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & (NN202==1) & (NN203==1)

*set to 0 where expenses=YES, had to pay=NO:
replace special_OOP = 0 if (special_OOP == .) & (NN202==1) & (NN203==5)

*impute where expenses=YES, had to pay=DK/NA/RF:
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & (NN202==1) & ///
											      (NN203==8 | NN203==9)

*impute where expenses=YES, had to pay=missing:
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & (NN202==1) & ///
											      (NN203==.)

*set to 0 where expenses=NO:							    
replace special_OOP = 0 if (special_OOP == .) & (NN202 == 5)

*impute where expenses=DK/NA/RF:
qui sum special_OOP
replace special_OOP = r(mean) if (special_OOP == .) & (NN202 == 8 | NN202 == 9)

*impute where expenses=YES:
qui sum other_OOP
replace other_OOP = r(mean) if (other_OOP == .) & (NN332 == 1)

*set to 0 where expenses=NO:							    
replace other_OOP = 0 if (other_OOP == .) & (NN332 == 5)

*impute where expenses=DK/NA/RF:
qui sum other_OOP
replace other_OOP = r(mean) if (other_OOP == .) & (NN332 == 8 | NN332 == 9)

save $savedir/core2012_oopi2.dta, replace							  


********************************************************************************
/*
use $savedir/core1992_oopi2.dta, clear
keep HHID PN year private_ltc
save $savedir/tmp1992.dta, replace

use $savedir/core1993_oopi2.dta, clear
keep HHID PN year private_ltc NH_OOP93 non_NH_OOP93
save $savedir/tmp1993.dta, replace

use $savedir/core1994_oopi2.dta, clear
keep HHID PN year private_medigap_* hospital_NH_doctor_OOP RX_OOP ///
	hospital_OOP NH_OOP doctor_OOP
save $savedir/tmp1994.dta, replace

use $savedir/core1995_oopi2.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care RX_OOP hospital_NH_OOP doctor_patient_dental_OOP home_special_OOP ///
	hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP home_OOP special_OOP
save $savedir/tmp1995.dta, replace

use $savedir/core1996_oopi2.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care RX_OOP hospital_NH_OOP doctor_patient_dental_OOP home_special_OOP ///
	hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP home_OOP special_OOP
save $savedir/tmp1996.dta, replace
*/
use $savedir/core1998_oopi2.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care RX_OOP hospital_NH_OOP doctor_patient_dental_OOP home_special_OOP ///
	hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP home_OOP special_OOP
save $savedir/tmp1998.dta, replace

use $savedir/core2000_oopi2.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care RX_OOP hospital_NH_OOP doctor_patient_dental_OOP home_special_OOP ///
	hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP home_OOP special_OOP
save $savedir/tmp2000.dta, replace

use $savedir/core2002_oopi2.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care RX_OOP hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP home_OOP special_OOP
save $savedir/tmp2002.dta, replace

use $savedir/core2004_oopi2.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care RX_OOP hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP home_OOP special_OOP
save $savedir/tmp2004.dta, replace

use $savedir/core2006_oopi2.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care RX_OOP hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP home_OOP special_OOP
save $savedir/tmp2006.dta, replace

use $savedir/core2008_oopi2.dta, clear
keep HHID PN year MC_HMO MC_D private_medigap_* long_term_care RX_OOP hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP home_OOP special_OOP
save $savedir/tmp2008.dta, replace

use $savedir/core2010_oopi2.dta, clear
keep HHID PN year MC_HMO MC_D private_medigap_* long_term_care RX_OOP hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP home_OOP special_OOP other_OOP
save $savedir/tmp2010.dta, replace

use $savedir/core2012_oopi2.dta, clear
keep HHID PN year MC_HMO MC_D private_medigap_* long_term_care RX_OOP hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP home_OOP special_OOP other_OOP
save $savedir/tmp2012.dta, replace

use $savedir/tmp1998.dta 
append using $savedir/tmp2000.dta 
append using $savedir/tmp2002.dta 
append using $savedir/tmp2004.dta 
append using $savedir/tmp2006.dta 
append using $savedir/tmp2008.dta 
append using $savedir/tmp2010.dta 
append using $savedir/tmp2012.dta 

save $savedir/core_oopi2.dta, replace

cap rm $savedir/tmp1992.dta
cap rm $savedir/tmp1993.dta
cap rm $savedir/tmp1994.dta
cap rm $savedir/tmp1995.dta
cap rm $savedir/tmp1996.dta
cap rm $savedir/tmp1998.dta
cap rm $savedir/tmp2000.dta
cap rm $savedir/tmp2002.dta
cap rm $savedir/tmp2004.dta
cap rm $savedir/tmp2006.dta
cap rm $savedir/tmp2008.dta
cap rm $savedir/tmp2010.dta
cap rm $savedir/tmp2012.dta
