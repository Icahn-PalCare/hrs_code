/*****************************************************************
PROJECT: 		MMS OOP Spending Replication Files
				
TITLE:			globals.do
			
AUTHOR: 		Sam Marshall

DATE CREATED:	31 May 2018

LAST EDITED:	10th September 2018

DESCRIPTION: 	Execute this file before running anything else in MMS distribution


ORGANIZATION:	Section 1: Set global directory paths
				Section 2: Labels
				
INPUTS: 		user directory, tracker file name
				
OUTPUTS: 		
				
NOTE:			To replicate the data with this file structure, it is only 
				  necessary to update the user global and the version of the 
				  tracker file that you have.
******************************************************************/

clear
set more off

/****************************************************************
	SECTION 1: Set global directory paths
****************************************************************/

if c(username) == "SMARSH" {
	global user "/Users/SMARSH/Dropbox (Personal)"
}
if c(username) == "sm2856" {
	global user "C:/Users/sm2856/Dropbox"
}

global filepath "${user}/MMS_2011_Replication/distribution V2_0"

* data paths
global rawdata "${filepath}/data/raw"
global buildoutput "${filepath}/data/build"
global OOPdata "${filepath}/data/OOP"

* code paths
global build "${filepath}/code/build"
global deps "${filepath}/code/dependencies"
global imp "${filepath}/code/impute"

* miscellaneous
global output "${filepath}/output"
global logs "${filepath}/logs"
global trversion "trk2006.dta"

/****************************************************************
	SECTION 2: Nominal-Real Conversions
****************************************************************/
* conversions for transforming 2006 dollars to nominal values in each year
global nom98 = (96.472/116.567)
global nom00 = (100.000/116.567)
global nom02 = (104.187/116.567)
global nom04 = (109.462/116.567)
global nom06 = (116.567/116.567)

/****************************************************************
	SECTION 3: Labels
****************************************************************/

/* TA126M   R DIED- STATE - MASKED
        In what state and county did ((she/he)) die?

        STATE:
1. Northeast Region: New England Division (ME, NH, VT, MA, RI, CT)
2. Northeast Region: Middle Atlantic Division (NY, NJ, PA)
3. Midwest Region: East North Central Division (OH, IN, IL, MI, WI)
4. Midwest Region: West North Central Division (MN, IA, MO, ND, SD, NE, KS)
5. South Region: South Atlantic Division (DE, MD, DC, VA, WV, NC, SC, GA, FL)
6. South Region: East South Central Division (KY, TN, AL, MS)
7. South Region: West South Central Division (AR, LA, OK, TX)
8. West Region: Mountain Division (MT, ID, WY, CO, NM, AZ, UT, NV)
9. West Region: Pacific Division (WA, OR, CA, AK, HI)
10. U.S., NA state
11. Foreign Country: Not in a Census Division (includes U.S.territories)
96. Same State (see questionnaire)
98. DK (Don't Know); NA (Not Ascertained)
99. RF (refused)
*/
label define death_region 1 "New England" 2 "Mid Atlantic" ///
	3 "East North Central" 4 "West North Central" 5 "South Atlantic" ///
	6 "East South Central" 7 "West South Central" 8 "Mountain" ///
	9 "Pacific" 10 "Other State" 11 "Foreign Country"


