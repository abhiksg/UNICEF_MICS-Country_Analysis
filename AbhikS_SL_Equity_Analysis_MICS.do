        --/* Equity Analysis using MICS datasets for Sierra Leone8*/----

use "\\NetAppSvr-704f\cw-SII\home\sii\senga583\Desktop\Sierra Leone MICS6 Datasets\hh.dta" 

 /*PREPARING DATASETS*/
 
 /* Use the HH dataset */
 
/*Sorting according to cluster and  household number to systematically merge this dataset with CH dataset later */  
sort HH1 HH2 

/*Generating a new variable "Electricity" assigning values based on variable HC8 (household have access to electricity)*/
gen Electricity=. 
replace Electricity=1 if HC8==1
replace Electricity=2 if HC8==2
replace Electricity=3 if HC8==3
replace Electricity=4 if HC8==9

/*Defining and associating value labels with the new variable 'Electricity'. Defining the label by creating 3 value label that associates
1 with Yes, interconnected grid, 2 with Yes, off-grid, 3 with No, and 4 with Missing/DK */
lab def lab_elec_hh  1 "Yes, interconnected grid" 2 "Yes, off-grid" 3 "No" 4 "Missing/DK"
lab val  Electricity lab_elec_hh 

/* Tabulation of variable  Electricity based on household weights*/
tab Electricity [aw=hhweight]

/*Cross-Tabulation between the variable Electricity and area (HH6) applying hhweight */
table ( Electricity ) ( HH6 ) () [aweight = hhweight], statistic(percent)

/*Generating a new variable "internet_access" assigning values based on variable HC13 (internet access at home)*/
gen internet_access=.
replace internet_access=1 if HC13==1
replace internet_access=2 if HC13==2
replace internet_access=3 if HC13==9

/*Defining and associating value labels with the new variable 'internet_access'. Defining the label by creating 3 value label that associates
1 with Yes, 2 with No, 3 with Missing/DK */
lab def lab_internet_hh  1 "Yes" 2 "No" 3 "Missing/DK"
lab val  internet_access lab_internet_hh

/*Cross-Tabulation between the variable internet_access and area (HH6) applying hhweight */
table ( internet_access ) ( HH6 ) () [aweight = hhweight], statistic(percent)

/*Tabulations of variable helevel (education level of household head) based on household weights*/
tab helevel [aw=hhweight]

/*The preserve command here saves a temporary copy of the HH dataset that we can later revert to using the restore command */
preserve

/*Preparing women questionnaire*/
use wm, clear 

/*Generating a new variable "wnins_cov" assigning values based on variable WB18 (covered by health insurance)*/
gen wmins_cov=.

/*Defining and associating value labels with the new variable 'internet_access'. Defining the label by creating 2 value label that associates
1 with "With insurance', and 2 with "Without insurance" */
replace wmins_cov=1 if WB18==1
replace wmins_cov=2 if WB18==2
lab def lab_ins_wm  1 "With Insurance" 2 "Without insurance" 
lab val  wmins_cov lab_ins_wm

/*Cross-Tabulation between the variable covered by health insurance (wmins_cov) and area (HH6) applying hhweight */
table ( wmins_cov ) ( HH6 ) (), statistic(percent)
table ( wmins_cov ) ( HH6 ) () [aweight = wmweight], statistic(percent)

/* Generating a new variable "wm_fd" assigning values based on variable disability (functional disabilities)*/
gen wm_fd=.
replace wm_fd=1 if disability==1
replace wm_fd=2 if disability==2

/*Defining and associating value labels with the new variable 'internet_access'. Defining the label by creating 2 value label that associates
1 with "Has functional difficulty", and 2 with "Has no functional difficulty" */
lab def lab_fd_wm  1 "Has functional difficulty" 2 "Has no functional difficulty"
lab val  wm_fd lab_fd_wm

/*Cross-Tabulation between the variable women finctional difficulty (wm_fd) with area (HH6), region (HH7), and wealthquantile (windex5) applying weight = hhweight */
table ( wm_fd ) ( HH6 ) () [aweight = wmweight], statistic(percent)
table ( wmins_cov ) ( HH7 ) () [aweight = wmweight], statistic(percent)
table ( wmins_cov ) ( windex5 ) () [aweight = wmweight], statistic(percent)
 
 /*The command 'restore' here brings back HH dataset, before the wm dataset was used*/
restore

/*Save the dataset as 'SL_hh */
save SL_hh

 /* Use the HL dataset */
use "\\NetAppSvr-704f\cw-SII\home\sii\senga583\Desktop\Sierra Leone MICS6 Datasets\hl.dta" 

/*Generate, define and assign value to a new variable total to account for total number of observations */
gen total=1 

/*Define the label by creating a value label called tot that associates '1' with total*/
lab def tot 1 "Total"

/* This command associates the variable 'total' generated above with the label 'tot'   */ 
lab val total tot

/*Generating a new variable to group children by official school age bracket according to education level*/
gen age_school=.

/*Assigning value for education: For primary education, assign 1, for lower secondary education, assign 2, for upper secondary education, assign 3 to official age bracket 
 */
replace age_school=1 if (schage>=6&schage<=11)
replace age_school=2 if (schage>=12&schage<=14)
replace age_school=3 if (schage>=15&schage<=18)

/*Defining and associating value labels with the new variable*/
lab def lab_age_sch  1 "Primary" 2 "Lower secondary" 3 "Upper secondary"
lab val age_school lab_age_sch

/*Generate a dummy variable "attendance" to calculate attendance according to the grouping created ["attendance=1" shows if the individual attended the relevant level ;
 "attendance=0" shows that the individual did not attend the level] */
gen attendance=0 if age_school!=.
replace attendance=1 if age_school==1&ED9==1&(ED10A==1|ED10A==2) 
replace attendance=1 if age_school==2&ED9==1&(ED10A==2|ED10A==3) 
replace attendance=1 if age_school==3&ED9==1&(ED10A==3|ED10A==4|ED10A==5)

/*The command displays the mean attendance by education level (using age_school grouping in a table and applying hhweight */
table ( age_school ) ( attendance ) () [aweight = hhweight], statistic(frequency) statistic(mean attendance)

/*Tabulations  made based on socioeconomic and demographic factors. These are:
HL4 represents gender 
HH6 represents urban/ rural
hh7r reperents region
melevel represents mother's education level
ethnicity represents the various etnicities
windex5 represents the different wealth quintiles*/
foreach var of var total HL4 HH6  HH7* melevel ethnicity windex5  {
table `var' [aw=hhweight], statistic (mean attendance)
}

/*The preserve command here saves a temporary copy of the HL dataset that we can later revert to using the restore command */
preserve

/* Use the WM dataset */
use wm,clear

/* Filtering to keep only completed questionnaires*/
keep if WM17==1

/*Renaming to match variable name in HL dataset. In HL, line number is 'HL1' whereas in  women's questionnaire it is 'LN'*/
ren LN HL1

/* Only keeping relevant variables in the questionnaire.*/
keep HH1 HH2 HL1 WB14 WB18 WB19*  MT4 MT5 welevel wmweight insurance

/*Sorting according to cluster, household and line number to systematically merge this dataset with HL dataset. */ 
sort HH1 HH2 HL1

/* Saving women dataset with the changes on renaming and dropping variable as well as sorted dataset */
save women,replace

/*The preserve command here saves a temporary copy of the HL dataset that we can later revert to using the restore command */
preserve

/* Use the MN dataset */
use mn,clear

/* Filtering to keep only completed questionnaires*/
keep if MWM17==1

/*Renaming to match variable name in HL dataset. In HL, line number is 'HL1' whereas in men questionnaire it is 'LN'*/
ren LN HL1

/* Only keeping relevant variables in the questionnaire.*/
keep HH1 HH2 HL1 MWB14 MWB18 MWB19* MMT4 MMT5 mwelevel mnweight minsurance

/*Sorting according to cluster, household and line number to systematically merge this dataset with HL dataset. */
sort HH1 HH2 HL1

/* Saving women dataset with the changes on renaming and dropping variable as well as sorted dataset */
save men, replace

 /*The command 'restore' here brings back HH dataset, before the mn dataset was used*/
restore

/*Sorting according to cluster, household and line number to systematically merge this dataset with HL dataset. */
sort HH1 HH2 HL1

/*Joining corresponding observations in HL with those in the men's questionnaire using a one to one merge*/
merge 1:1 HH1 HH2 HL1 using men

/*Remove '_merge' variable */
drop _merge

/*Sorting according to cluster, household and line number to systematically merge this dataset with HL dataset. */
sort HH1 HH2 HL1

/*Joining corresponding observations in HL with those in the women's questionnaire using a one to one merge*/
merge 1:1 HH1 HH2 HL1 using women

/*Remove '_merge' variable */
drop _merge

           --/* Calculating literacy in the merged dataset (HL,WM,MN)*/--
 
/*WB14 and MEB14 contain information on whether the man or woman was able to read
a part of the sentence. Filling  all observations in WB14*/
replace WB14=MWB14 if WB14==.
replace WB18=MWB18 if WB18==.

/*Erase the men and women's questionnaire from memory */
erase men.dta
erase women.dta

/*Ensure equivalence in weights since the data is merged from different questionnaires*/
gen nweight=mnweight
replace nweight=wmweight if nweight==.

/*Generate a new variable for all observation*/
gen literate=.

/*Replace the value for literate using MWB14 and WB14:
MWB14==1|WB14==1 represents cannot read at all
MWB14==2|WB14==2 represents able to read only parts of the sentence. Therefore literate=0 represents those who are not literate*/
replace literate=0 if MWB14==1|MWB14==2|WB14==1|WB14==2

/*Replace the value for literate using MWB14 and WB14:
MWB14==3|WB14==3 represents able to read complete sentence (m)welevel>=2&(m)welevel<=5 represents at least attaining lower secondary education.
Therefore literate=1 represents those who are literate  */
replace literate=1 if MWB14==3|WB14==3
replace literate=1 if welevel>=2&welevel<=5
replace literate=1 if mwelevel>=2&mwelevel<=5

/*Save the dataset as 'SL_ready */
save SL_ready,replace

                         ---/* Use the CH dataset */--- 
use "\\NetAppSvr-704f\cw-SII\home\sii\senga583\Desktop\Sierra Leone MICS6 Datasets\ch.dta" 

/*Sorting according to cluster and  household number to systematically merge this dataset with HH (SL_HH) dataset, we saved earlier */
sort HH1 HH2 

/*Joining corresponding observations in CH with those in the household questionnaire using a many to one merge*/
merge m:1 HH1 HH2 using SL_hh

                ---/*calculating moderate and severe stunting*/---

/* Summarizing and tabulating HAZ2 (height for age z-score WHO), checking for outliers*/
sum HAZ2
tab HAZ2
tab WHZFLAG

/* Generating new variable HAZ3 equal to HAZ2*/
gen HAZ3= HAZ2

/* Replazing the value HAZ3 equal if value HAZ2>6, correxting for outliers*/
replace HAZ3 =. if HAZ2 >6

/* Summarizing, tabulating and checking histogram of HAZ3 for outliers and distribution*/
tab HAZFLAG
sum HAZ3
hist HAZ3

/*Generating moderately stunting variable (ms_stunt) by recoding values of HAZ3, after correcting for outliers and tabulating the result*/
recode HAZ3 (-6/-2=1) (-2.001/6=0), gen (ms_stunt)
tab ms_stunt [aw=chweight]

/*Generating weight variable, multiplying children weight with no.of members in the houshold*/
gen weight = chweight* HH48
tab ms_stunt [aw=weight]

/*Generating severely stunting variable (severely_stunted) by recoding values of HAZ3, after correcting it for outliers and tabulating */
recode HAZ3 (-6/-3=1) (-3.001/6=0), gen (severely_stunted)
tab severely_stunt [aw=weight]

         ---/*Child Health insurance coverge analysis for Sierra Leone*/---
	  
/* Checking the distirbution of variables UB9 (covered by any health insurance), HC13 (inernet access at home), minsurance(mother's health insurance status), melevel(mother;s education level), helevel(education level of the household head) through histograms and tabulating them*/
hist UB9
tab UB9 [aw=chweight]
hist HC13
tab HC13 [aw=chweight]
hist minsurance
hist melevel
hist helevel

/* checking the labels of variables*/
codebook UB9
codebook melevel

/* Generate a dummy variable "mother_edu".
 ["mother_edu=1"shows if the mother attended anytype of educational inst ;
 "mother_edu=0" shows that the mother did not attended anytype of educational inst.] */
gen mother_edu=.
replace mother_edu=0 if melevel==0
replace mother_edu=1 if melevel==1|melevel==2|melevel==3
replace mother_edu=. if melevel==.

/*Generate a dummy variable "elec".
 ["elec=1" shows if the hosuehold has access to some type of electricity;
 elec=0" shows that the household does not have access to anytype of electricity.] */
gen elec=.
codebook Electricity
replace elec=0 if Electricity==3
replace elec=1 if Electricity==1|Electricity==2
replace elec=. if Electricity==1|Electricity==4

/*Generate a dummy variable "internet_access".
 ["internet_access=1" shows if the hosuehold has access to internet. ;
 "internet_access=0" shows that the household does not have access to internet.] */
codebook internet_access
gen internet=.
replace internet=0 if internet_access==2
replace internet=1 if internet_access==1
replace internet=. if internet_access==3
codebook minsurance

/*Generate a dummy variable "mother_healthcov".
 ["mother_healthcov=1" shows if the mother has health insurance cover;
 "mother_healthcov=0" shows that the the mother does not have health insurance cover.] */
gen mother_healthcov=.
replace mother_healthcov=0 if minsurance==2
replace mother_healthcov=1 if minsurance==1
replace mother_healthcov=. if minsurance==9

/*Generate a dummy variable "area".
 ["area=1" shows the household is classified as urban;
 "area=0" shows that the household is classified as rural.] */
codebook HH6
gen area=.
replace area=0 if HH6==2
replace area=1 if HH6==1 

/*Generate a dummy variable "gender".
 ["gender=1" shows the individual is classified as male;
 "gender=0" shows that the hindividual is classified as female.] */
codebook HL4
gen gender=.
replace gender=0 if HL4==2
replace gender=1 if HL4==1

/*Generate a dummy variable "child_inscov".
 ["child_inscovr=1" shows the child has health insurance covergae;
 "child_inscovr=0" shows that the child has health insurance covergae.] */
gen child_inscov=.
replace child_inscov=0 if UB9==2
replace child_inscov=1 if UB9==1
replace child_inscov=. if UB9==9

/*Checking descriptive statistics*/
sum gender area mother_healthcov internet elec ch_ins mother_edu child_inscov

/*Checking variables for correlation and statistical significance @=0.5 */
correlate gender area mother_healthcov internet elec ch_ins mother_edu child_inscov
pwcorr gender area mother_healthcov internet elec ch_ins mother_edu child_inscov, star(0.5)
/* Performing Logistical Regresion*/
logistic child_inscov i.gender i.area i.mother_healthcov i.internet i.elec  i.mother_edu, or nolog
/*Performing Post-Regression diagonsitics*/
linktest
estat classification
estat gof, group(10)

