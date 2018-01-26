/*LOAD CPI DATA: USED TO CONVERT EXPENSES INTO CONSTANT DOLLARS*/

/*
Input CPI data:
Old Source: ftp://ftp.bls.gov/pub/special.requests/cpi/cpiai.txt, annual average column
Newest Source: http://www.bls.gov/cpi/cpifiles/cpiai.txt, annual average column

note--accessed from BLS and updated through 2016 on 11/30/17--(data.bls.gov/cgi-bin/surveymost)

*/
     
scalar cpi1992 = 140.3
scalar cpi1993 = 144.5
scalar cpi1994 = 148.2
scalar cpi1995 = 152.4
scalar cpi1996 = 156.9
scalar cpi1998 = 163.0
scalar cpi2000 = 172.2 
scalar cpi2002 = 179.9
scalar cpi2004 = 188.9
scalar cpi2006 = 201.6
scalar cpi2008 = 215.303
scalar cpi2010 = 218.056
scalar cpi2012 = 229.594
scalar cpi2014 = 236.736
scalar cpi2016 = 240.008
/*Select base year*/

scalar cpiBASE = cpi2012

scalar list
