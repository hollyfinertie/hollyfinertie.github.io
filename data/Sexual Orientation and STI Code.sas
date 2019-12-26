
*/Holly Finertie HF2379 & Grace Mackson GM2821; 


*/STEP 1: IMPORT SXQ and DEMO data from NHANES for 2009-2014

SXQ_F from 2009-2010 Sexual Behavior file in Questionnaire Data
SXQ_G from 2011-2012 Sexual Behavior file in Questionnaire Data
SXQ_H from 2013-2014 Sexual Behavior file in Questionnaire Data
DEMO_F from 2009-2010 Demographic Variables and Sample Weights in Demographics Data 
DEMO_G from 2011-2012 Demographic Variables and Sample Weights in Demographics Data 
DEMO_H from 2013-2014 Demographic Variables and Sample Weights in Demographics Data 

DEMO houses variables for Age (covariate) and Sex (potential effect modifier variables) while SXQ 
houses variables for STI diagnosis (outcome) and sexual orientation (exposure). We decided to use 6 years 
of data because our exposure of interest is rare.; 

libname SXQ2009 xport "/home/hf23790/sasuser.v94/SXQ_F.XPT";
libname SXQ2011 xport "/home/hf23790/sasuser.v94/SXQ_G.XPT";
libname SXQ2013 xport "/home/hf23790/sasuser.v94/SXQ_H.XPT";
libname DEMO2009 xport "/home/hf23790/sasuser.v94/DEMO_F.XPT"; 
libname DEMO2011 xport "/home/hf23790/sasuser.v94/DEMO_G.XPT"; 
libname DEMO2013 xport "/home/hf23790/sasuser.v94/DEMO_H.XPT"; 
run;

*/STEP 2: CREATE FORMATTING, STACK DATA SETS & OPERATIONALIZE PARAMETERS: 

Please see a summary of the below in “Methods” Section: 

We hypothesize that the relationship between sexual orientation and STI diagnosis in American adults aged 18-59 is 
modified by gender, controlling for age. In order to test this, we defined our parameters as follows: 

	Exposure: HOMO - NHANES questioned respondents about their sexual orientation by asking: “Describe sexual orientation” 
	using SXQ294 for females and SXQ292 for males in the SXQ data set. Responses across sexes were numbered the same, so we 
	used the same criteria to classify sexual orientation into one variable for males and females. Because our hypothesis relies 
	on categorized sexual orientation, we used reponses for (1) Heterosexual (2) Homosexual and (3) Bisexual and excluded 
	responses for (4) Something Else (5) Not Sure (7) Refused (9) Don’t know and (.) Missing. This limited our ability to run 
	analyses on individuals who do not fall into pre specified categories of sexual orientation. We decided not to use “Something 
	Else” as we could not extrapolate what that response meant. In order to compare STI diagnoses between Homosexuals, Bisexuals, 
	and Heterosexuals, we categorized this variable into 3 different groups: Heterosexual=0, Homosexual=1, and Bisexual= 2. 
 
	Outcome: STI - we dichotomized the outcome using self-reported diagnoses in four common STIs: herpes, genital warts, gonorrhea, 
	and chlamydia. We excluded HIV due to its elevated rate among the homosexual male population, and HPV due to the current inability 
	to diagnose males. NHANES does not collect data on Syphilis. We used the following variables in the SXQ file: SXQ270 - “Doctor 
	ever told you had gonorrhea”, SXQ265 - “Doctor ever told you had genital warts”, SXQ260 - “Doctor ever told you had genital herpes” 
	and SXQ272 - “Doctor ever told you had chlamydia”. Responses across questions were the same: (1) Yes, (2), No, (7) Refused, (9) Don’t 
	Know, and (.) Missing. Because our hypothesis relies on a yes or no response to any STI diagnosis, we excluded 7, 9, and missing data. 
	We decided to dichotomize this variable instead of making it continuous or categorical, because we are interested in if gender and 
	sexual orientation explain the proportion of people who have been diagnosed with any of the STIs of interest. Those who answered “Yes” 
	to any of the four questions were classified as STI=1 formatted as “1 or more” and those who answered “No” to all of the four questions 
	were classified as STI=0 formatted as “none”. All other responses were deleted. 

	Covariate: AGE - we hypothesize that there may be an association between age and STI diagnosis (outcome). Those who are older may be 
	more likely to have been diagnosed with any of the STIs at some point in their lifetime compared to a younger person, all else equal. 
	We renamed the continuous variable RIDAGEYR from the DEMO dataset as AGE. We excluded respondents outside of our population of interest, 
	keeping only adults 18-59 years old. 

	Effect Modifier: SEX - We hypothesized that self-reported sex modifies the relationship between sexual orientation and STI diagnosis. 
	After renaming the RIAGENDR variable in the DEMO dataset to SEX, we dichotomized SEX into 1 formatted as “Male” if respondents self-reported 
	a Male gender and 2 formatted as “Female” if respondents self-reported a Female gender. There was no missing data and no data was excluded.

*/create formatting for STI, SEX, and HOMO variables;

proc format;
value STIf 1="1 or more" 0="None"; */binary outcome format;
value SEXf 1="Male" 2="Female"; */binary sex format;
value HOMOf  0 = "Heterosexual" 1 = "Homosexual" 2 = "Bisexual"; */categorical exposure format;
run;

*/stack SXQ data sets for 2009-2014 and define parameters for exposure (HOMO) and outcome (STI);

data SXQ; set SXQ2009.SXQ_F SXQ2011.SXQ_G SXQ2013.SXQ_H; 
if SXQ292 = 1 or SXQ294 = 1 then HOMO =0; */heterosexual respondents=0;
else if SXQ292 = 2 or SXQ294 = 2 then HOMO=1; */homosexual respondents=1/;
else if SXQ292 = 3 or SXQ294 = 3 then HOMO=2; */bisexual respondents=2;
else if SXQ292 in (4,5,7,9,.) and SXQ294 in (4,5,7,9,.) then delete;*/remove missing, "Something else", "Not sure", "Refused", "Don't Know" responses;
format HOMO HOMOf.; */apply formatting to HOMO variable */;
if SXQ260=1 or SXQ265=1 or SXQ270=1 or SXQ272=1 then STI=1; */Define STI=1 if answered yes to any STI diagnoses;
else if SXQ260=2 and SXQ265=2 and SXQ270=2 and SXQ272=2 then STI=0; */Define STI=0 if answered no to all STI diagnosises;
else if SXQ260 in (7,9,.) or SXQ265 IN (7,9,.) or SXQ270 in (7,9,.) or SXQ272 in (7,9,.) then delete; */ Remove "Missing", "Don't Know" and "Refused" 
responses that are not already classified as STI=1;
format STI STIf.; */apply formatting to STI variable;
keep SEQN STI HOMO; */keep SEQN, outcome (STI), and exposure (HOMO) variables;
run; 


*/stack DEMO data sets for 2009-2014 and define covariate (AGE) and potential effect modifier (SEX);

data DEMO; set DEMO2009.DEMO_F DEMO2011.DEMO_G DEMO2013.DEMO_H; 
SEX=RIAGENDR; */ create SEX variable;
AGE=RIDAGEYR; */create AGE variable;
if SEX=. then delete; */delete missing responses for SEX variable;
if AGE=. or AGE ge 60 OR AGE lt 18 then delete; */limit to population of interest - adults aged 18-59;
format SEX SEXf.; */apply formatting to SEX variable;
keep SEQN SEX AGE; */keep SEQN, potential modifier (SEX), and covariate (AGE) variables;
run;

*/STEP 3: REVIEW NEW SXQ AND DEMO DATA SETS

After defining our parameters, we want to check our data for any weirdness. Specifically: 

	Exposure (HOMO): After applying the formatting, we confirmed there are only “Heterosexual”, “Homosexual”, and “Bisexual” groups. 
	Outcome (STI): After applying the formatting, we confirmed there are only “none” or “1 or more” groups. 
	Covariate (AGE): We confirmed our sample includes adults 18-59 only. 
	Effect Modifier (SEX): After applying the formatting, we confirmed there are only “Male” and “Female” groups;

proc freq data=SXQ;
table STI HOMO; */confirmed "none" and "1 or more" groups for STI and "Heterosexual", "Homosexual", and "Bisexual" groups for HOMO.;
proc freq data=DEMO;
table SEX; */ confirmed Male and Female gender groups;
proc means n nmiss min max std data=DEMO; */ confirmed min and max of AGE is 18-59;
var AGE;
run;

*/STEP 4: CREATE COMPLETE DATA SET: 

Merge SXQ and DEMO data sets into “complete” data set only if SEQN is the same. We used the SEQN criteria because we are only interested in 
respondents that have data for all 5 variables. 

See “Findings” Section: 9,877 observations and 5 variables (SEQN, HOMO, SEX, STI, AGE);

proc sort data=DEMO;
by SEQN;
proc sort data=SXQ;
by SEQN;
run;

data complete; merge SXQ (in=wine) DEMO (in=cheese);
if wine and cheese; 
by SEQN;
run;

*/STEP 5: CREATE TABLE 1 “Frequency of Sexual Orientation Identifications”

All numbers in Table 1 come from the below information;

proc freq data=complete;
table sex*homo;
Run;

*/ See Table 1: 

	Heterosexuals make up 95.07% of our population (N=9390)
	Homosexuals 1.72% of our population (N=170)
	Bisexuals 3.21% of our sample. (N=317)
	Males make up 49.9% of our sample. (N=4929)
	Females make up 51.1% of our sample (N=4948)
	Hetersexual Males make up 48.19% (N=4760)
	Hetersexual Females make up 46.88% (N=4630)
	Homosexual Males make up 1% (N=99)
	Homosexual Females make up 0.72% (N=71)
	Bisexual Males make up 0.71% (N=70)
	Bisexual Females make up 2.5% (N=247);

proc means data=complete;
var age;
class homo;
Run;

*/See Table 1: 

	The average age of Heterosexuals is 38.02 (STI 12.09)
	The average age of Homosexuals is 35.43 (STI 12.49)
	The average age of Bisexuals is 32.05 (STI 11.27); 

proc means data=complete;
var age;
Run;

*/See Table 1: 

	The average age of the sample is 37.79 (STI 12.12);

*/STEP 6: CALCULATE CRUDE ASSOCIATION

Because our outcome variable is dichotomous and we are curious about the relationship between sexual orientation and STI diagnosis, 
we used logistic regression to calculate our crude odds ratio. We confirmed this number using proc freq. ;

proc logistic data=complete;
class HOMO (ref='Heterosexual') / param=ref; */used heterosexual as reference group for all analyses;
model STI=homo/cl;
Run;

*/as presented in our “Findings” section, 

	OR_homo to hetero=1.08 95% CI (0.62, 1.87)
	OR_bisexual to hetero=2.19 95% CI (1.60 , 3.00) or OR=119% greater
	HOMO variable: chi-square=24.04 with P(chi-square>24.04)<0.001 from Wald Test;

proc sort data=complete;
by descending STI;	
proc freq data=complete order=data;
table homo*STI;
run;

*/double checked crude ORs using proc freq: 

	OR_homo to hetero=(14/156)/(723/8667)=1.08
	OR_bisexual to hetero=(49/268)/(723/8667)=2.19;


*/STEP 7: CALCULATE ADJUSTED ASSOCIATION WITH EFFECT MODIFIER AND COVARIATE

We added AGE, SEX, and the interaction term SEX*HOMO into our model to test the adjusted association modified by SEX and controlled by AGE. ;

proc logistic data=complete;
class HOMO (ref='Heterosexual') / param=ref;
model STI=age sex homo homo*sex/cl;
oddsratio homo / at(sex=1);
oddsratio homo / at(sex=2);
Run;

*/As presented in our “Findings” Section:

Female: 
	OR_homo to hetero=0.51 with 95%CI(0.19, 1.41) 
	OR_bisexual to hetero=1.61 with 95%CI (1.11, 2.31)

Male: 
	OR_homo to hetero=2.32 with 95%CI (1.19, 4.53)
	OR_bisexual to hetero=4.18 with 95%CI (2.21, 7.91)
;

*\STEP 8: TEST FOR SIGNIFICANCE OF EFFECT MODIFIER (SEX)

Using the Joint Wald Test as mentioned in our Methods section, we confirmed our interaction term (SEX*HOMO) modifies the relationship 
between sexual orientation and STI diagnosis at the 5% level of significance. We used the code above to determine the significance. 

As seen in our “Findings” Section:

	HOMO*SEX Interaction term: chi-square = 12.13 with P(chi-square>12.13)=0.0023). We found this Wald Chi Square test statistic in the 
	Joint Tests table for the HOMO*SEX interaction term.  

*\CONCLUSION: Our data support the hypothesis that the relationship between sexual orientation and STI diagnosis is modified by sex, controlling for age.; 










