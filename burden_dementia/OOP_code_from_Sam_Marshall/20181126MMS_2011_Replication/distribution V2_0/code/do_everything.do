/*****************************************************************
PROJECT: 		MMS OOP Spending Replication Files
				
TITLE:			do_everything.do
			
AUTHOR: 		Sam Marshall

DATE CREATED:	23rd July 2018

LAST EDITED:	23rd July 2018

DESCRIPTION: 	Do all of the do files in the correct order


ORGANIZATION:	Section 1: Build the data
				
INPUTS: 		
				
OUTPUTS: 		
				
NOTE:			You still must run globals.do to initialize this file
******************************************************************/

/****************************************************************
	SECTION 1: Build the data
****************************************************************/

do "${build}/exit_expenditures.do"

do "${build}/1998build.do"
do "${build}/2000build.do"
do "${build}/2002build.do"
do "${build}/2004build.do"
do "${build}/2006build.do"

/****************************************************************
	SECTION 2: Impute the OOP Medical expenditures
****************************************************************/

do "${imp}/98exit.do"
do "${imp}/00exit.do"
do "${imp}/02exit.do"
do "${imp}/04exit.do"
do "${imp}/06exit.do"

/****************************************************************
	SECTION 3: Combine the files
****************************************************************/

do "${build}/exit_combine.do"
