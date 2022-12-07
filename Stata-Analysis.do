* Final Project 
* Econ 35
* Brooke Coneeny, Sydney Levy, Ellie Miller, Ally Scheve

clear
set more off
capture restore
capture log close


*------------------------
* Directory Configuration
*------------------------
*Brooke Coneeny
if "`c(username)'" == "bcone" {
    global root = "C:\Users\bcone\Dropbox\Econometrics Group Project"
    }
	
*Sydney Elizabeth Levy
if "`c(username)'" == "levys" {
    global root = "C:\Users\levys\Dropbox\SL Econ 35\Econometrics Group Project"
	}
	
*Eleanor Newkirk Miller
if "`c(username)'" == "ellie" {
    global root = "/Users/ellie/Dropbox/Econometrics Group Project"
    }
	
*Ally Scheve
if "`c(username)'" == "allyscheve" {
    global root = "/Users/allyscheve/Dropbox/Econometrics Group Project"
    }
	
global data = "$root/Data"
global output = "$root/Output"
global logs = "$root/Programs (do files)/Log Files"

*------------------
* Import data
*------------------
import delimited "$data/school_survey.csv", clear


* Label highest level sport during sophomore year
label var highest_level_sport_b "highest level of participation in sports (soph year)"
label define highest_level_sport_b 0 "No Paric" 1 "JV" 2 "Varsity" 3 "Vars Capt"

* Played a sport sophomore year of high school (and made it to 12th grade)
gen play_hs_soph = .
replace play_hs_soph = 1 if num_sports > 0 & num_sports < 8 & grade_level_f1 == 3
replace play_hs_soph = 0 if num_sports ==0 & grade_level_f1 == 3

* Var for played a sport senior year of high school (and made it to 12th grade)
gen play_hs_sen = .
replace play_hs_sen = 1 if (int_mural_f1 == 2 | int_mural_f1 == 3 |  ///
			int_schol_f1 == 2 | int_schol_f1 == 3) & grade_level_f1 == 3
replace play_hs_sen = 0 if int_mural_f1 == 1 & int_schol_f1 == 1 & grade_level_f1 == 3

* Compare sophomore year sports paritcipation to senior year
tab play_hs_soph play_hs_sen, row

* F2 = Percent of students who attended post secondary edu
tab post_secondary_college_f2 if (post_secondary_college_f2 == 1 | ///
		post_secondary_college_f2 == 0) 

	* broken down by whether they played sports sophomore year
bysort play_hs_soph: tab post_secondary_college_f2 ///
	if (post_secondary_college_f2 == 1 | post_secondary_college_f2 == 0) ///
	& play_hs_soph != .
	
* Compare GPA senior year broken down by participation in sports
*tab  Sophomore_GPA_F1 if (play_hs_soph == 1 | play_hs_soph == 0)
	
* Variable for whether student intended to go to college in base year
gen intend_college_b = . 
replace intend_college_b = 0 if future_edu_plans == 1 | future_edu_plans ==2
replace intend_college_b = 1 if future_edu_plans == 3 | future_edu_plans == 4 ///
| future_edu_plans == 5 | future_edu_plans == 6 | future_edu_plans == 7

* Change in Math Quartile
gen change_math_quartile = . 
replace change_math_quartile = math_q_f1 - math_q_b if (math_q_b != -8) & ///
	(math_q_f1 != -8)

* Maybe Outcome Variables
lab var math_q_b "BY Math Standardized Test Quartile"
lab var math_q_f1 "F1 Math Standardized Test Quartile"	
lab var stan_comp_test_q_b "BY Standardized Test Quartile"
lab var reading_q_b "BY Reading Standardized Test Quartile"

*Label Outcome variables
lab var post_secondary_college_f2 "College Attendance"
lab var change_math_quartile "Change in Math Quartile"

*Outcome Variables
gen college = . 
replace college = post_secondary_college_f2 if post_secondary_college_f2 == 0 | ///
	post_secondary_college_f2 == 1
lab var college "Attended College"

*Depenedent Variables
gen athlete = . 
replace athlete = 1 if play_hs_soph == 1 | play_hs_sen ==1
replace athlete = 0 if play_hs_soph == 0 & play_hs_sen == 0
lab var athlete "Athlete"

gen athlete_all_4 = . 
replace athlete_all_4 = 1 if play_hs_soph == 1 & play_hs_sen == 1
replace athlete_all_4 = 0 if play_hs_soph == 0 & play_hs_sen == 0
replace athlete_all_4 = 0 if play_hs_soph == 1 & play_hs_sen == 0
replace athlete_all_4 = 0 if play_hs_soph == 0 & play_hs_sen == 1
lab var athlete_all_4 "Athlete Sophomore and Senior Year"

gen athlete_only_soph = . 
replace athlete_only_soph = 1 if play_hs_soph == 1 & play_hs_sen == 0
replace athlete_only_soph = 0 if play_hs_soph == 1 & play_hs_sen == 1
replace athlete_only_soph = 0 if play_hs_soph == 0 & play_hs_sen == 0
replace athlete_only_soph = 0 if play_hs_soph == 0 & play_hs_sen == 1
lab var athlete_only_soph "Athlete Only Sophomore Year"

gen athlete_began_sen = . 
replace athlete_began_sen = 1 if play_hs_soph == 0 & play_hs_sen == 1
replace athlete_began_sen = 0 if play_hs_soph == 1 & play_hs_sen == 0
replace athlete_began_sen = 0 if play_hs_soph == 0 & play_hs_sen == 0
replace athlete_began_sen = 0 if play_hs_soph == 1 & play_hs_sen == 1
lab var athlete_began_sen "Athlete Only Senior Year" 

gen no_athlete = . 
replace no_athlete = 1 if athlete == 0
replace no_athlete = 0 if play_hs_soph == 1 | play_hs_sen == 1
lab var no_athlete "Never an Athlete"

*Important Controls
lab var intend_college_b "College Intentions" 

* Create Demographic Controls
gen female = . 
replace female = 1 if sex == 2
replace female = 0 if sex == 1
lab var female "Female"

gen hispanic = 0 if race != -4 & race != -8
replace hispanic =1 if race == 4 | race == 5
lab var hispanic "Hispanic"

gen white = 0 if race != -4 & race != -8
replace white = 1 if race == 7
lab var white "White"

gen black = 0 if race != -4 & race != -8
replace black = 1 if race == 3
lab var black "Black"

gen asian = 0 if race != -4 & race != -8
replace asian = 1 if race == 2
lab var asian "Asian"

gen american_indian = 0 if race != -4 & race != -8
replace american_indian = 1 if race ==1
lab var american_indian "American Indian"

gen english_native_lang = . 
replace english_native_lang = 0 if english == 0
replace english_native_lang = 1 if english == 1
lab var english_native_lang "English is Native Langauge"

** How do we want to encode DOB? 
gen age_months = . 
replace age_months = 198712 - dob if dob >= 198700 & dob <= 198712
replace age_months = 12 + (198612 - dob) if dob >= 198600 & dob <= 198612
replace age_months = 24 + (198512 - dob) if dob >= 198500 & dob <= 198512
replace age_months = 36 + (198412 - dob) if dob >= 198400 & dob <= 198412
replace age_months = 48 + (198312 - dob) if dob >= 198300 & dob <= 198312
lab var age_month "Months before Dec 1987 Student Was Born"


gen siblings = . 
replace siblings = num_siblings if num_siblings >= 0
lab var siblings "Number of Siblings"

gen parent_grad_4_year = . 
replace parent_grad_4_year = 0 if parent_highest_ed > 0 & parent_highest_ed <= 5
replace parent_grad_4_year = 1 if parent_highest_ed > 5 & parent_highest_ed <= 8
lab var parent_grad_4_year "Parent College Graduate"

gen parent_attended_post_sec = . 
replace parent_attended_post_sec = 0 if parent_highest_ed > 0 & parent_highest_ed <= 2
replace parent_attended_post_sec = 1 if parent_highest_ed > 2 & parent_highest_ed <= 8
lab var parent_attended_post_sec "At least 1 parent attended post-secondary institution"

gen income_above_50_k = . 
replace income_above_50_k = 0 if fam_income >= 1 & fam_income <=9
replace income_above_50_k = 1 if fam_income >=10 & fam_income <= 13
lab var income_above_50_k "Income above $50k"

* Create Extracurricular Controls
gen tv = . 
replace tv = hours_tv_b if hours_tv_b >= 0 & hours_tv_b <=8
lab var tv "Hours Watching TV per Week"

gen paid_work = . 
replace paid_work = student_job_b if student_job_b == 0 | student_job_b == 1
lab var paid_work "Held Job Soph Year HS"

*Athlete Gender interaction term 
gen athlete_gender = . 
replace athlete_gender = athlete*female
lab var athlete_gender "Athlete Gender Interaction"


* Multiple Regressions
reg college athlete, r
est store reg0

reg college athlete intend_college_b female hispanic white /// 
	black asian american_indian english_native_lang age_months siblings ///
	parent_grad_4_year income_above_50_k tv paid_work, r
est store reg1
	
reg college athlete_all_4 athlete_only_soph athlete_began_sen,r
est store reg1a
	
reg college athlete_all_4 athlete_only_soph athlete_began_sen intend_college_b ///
	female hispanic white black asian american_indian english_native_lang ///
	age_months siblings parent_grad_4_year income_above_50_k tv paid_work, r
est store reg3

reg college athlete athlete_gender intend_college_b female hispanic white /// 
	black asian american_indian english_native_lang age_months siblings ///
	parent_grad_4_year income_above_50_k tv paid_work, r
est store reg4

*Logit / Probit analysis
logit college athlete intend_college_b female hispanic white /// 
	black asian american_indian english_native_lang age_months siblings ///
	parent_grad_4_year income_above_50_k tv paid_work, r
est store log1

probit college athlete intend_college_b female hispanic white /// 
	black asian american_indian english_native_lang age_months siblings ///
	parent_grad_4_year income_above_50_k tv paid_work, r
est store prob1

reg change_math_quartile athlete, r
est store reg20

reg change_math_quartile athlete female hispanic white /// 
	black asian american_indian english_native_lang age_months siblings ///
	parent_grad_4_year income_above_50_k tv paid_work, r
est store reg21

reg change_math_quartile athlete_all_4 athlete_only_soph athlete_began_sen,r
est store reg21a

reg change_math_quartile athlete_all_4 athlete_only_soph athlete_began_sen ///
	female hispanic white black asian american_indian english_native_lang ///
	age_months siblings parent_grad_4_year income_above_50_k tv paid_work, r
est store reg22

*Interaction Terms
gen fem_athlete=female*athlete
reg college fem_athlete athlete intend_college_b female hispanic white /// 
	black asian american_indian english_native_lang age_months siblings ///
	parent_grad_4_year income_above_50_k tv paid_work, r

gen fem_athleteall4=female*athlete_all_4
reg college athlete_all_4 athlete_only_soph athlete_began_sen fem_athleteall4 ///
intend_college_b female hispanic white /// 
	black asian american_indian english_native_lang age_months siblings ///
	parent_grad_4_year income_above_50_k tv paid_work, r	

gen fem_athletequit=female*athlete_only_soph
reg college athlete_all_4 athlete_only_soph athlete_began_sen fem_athletequit ///
intend_college_b female hispanic white /// 
	black asian american_indian english_native_lang age_months siblings ///
	parent_grad_4_year income_above_50_k tv paid_work, r	

gen asian_athlete=asian*athlete
reg college asian_athlete athlete intend_college_b female hispanic white /// 
	black asian american_indian english_native_lang age_months siblings ///
	parent_grad_4_year income_above_50_k tv paid_work, r
	
gen white_athlete=white*athlete
reg college white_athlete athlete intend_college_b female hispanic white /// 
	black asian american_indian english_native_lang age_months siblings ///
	parent_grad_4_year income_above_50_k tv paid_work, r

gen black_athlete=black*athlete
reg college black_athlete athlete intend_college_b female hispanic white /// 
	black asian american_indian english_native_lang age_months siblings ///
	parent_grad_4_year income_above_50_k tv paid_work, r
	
gen inc50k_athlete=income_above_50_k*athlete
reg college inc50k_athlete athlete intend_college_b female hispanic white /// 
	black asian american_indian english_native_lang age_months siblings ///
	parent_grad_4_year income_above_50_k tv paid_work, r
est store reg8
test inc50k_athlete+income_above_50_k=0	
est store marginal3
	
gen paidwork_athlete=paid_work*athlete
reg college paidwork_athlete athlete intend_college_b female hispanic white /// 
	black asian american_indian english_native_lang age_months siblings ///
	parent_grad_4_year income_above_50_k tv paid_work, r

	
gen parentgrad_athlete=parent_grad_4_year*athlete
reg college parentgrad_athlete athlete intend_college_b female hispanic white /// 
	black asian american_indian english_native_lang age_months siblings ///
	parent_grad_4_year income_above_50_k tv paid_work, r
est store reg9
test parentgrad_athlete+parent_grad_4_year=0
est store marginal4

*Band 
gen band_soph=.
replace band_soph=1 if band_chorus_b==1
replace band_soph=0 if band_chorus_b==0

gen band_senior=.
replace band_senior=1 if band_chorus_f1==2|band_chorus_f1==3
replace band_senior=0 if band_chorus_f1==1

gen band=.
replace band=1 if band_soph==1|band_senior==1
replace band=0 if band_soph==0&band_senior==0
lab var band "Band Participant"

gen band_sophsen=.
replace band_sophsen=1 if band_soph==1&band_senior==1
replace band_sophsen=0 if band_soph==0|band_senior==0
lab var band_sophsen "Band Sophmore and Senior Year"

gen band_only_soph=.
replace band_only_soph=1 if band_soph==1&band_senior==0
replace band_only_soph=0 if band_soph==0
replace band_only_soph=0 if band_soph==1&band_senior==1
lab var band_only_soph "Band Only Sophmore Year"

gen band_only_senior=.
replace band_only_senior=1 if band_soph==0&band_senior==1
replace band_only_senior=0 if band_senior==0
replace band_only_senior=0 if band_soph==1&band_senior==1
lab var band_only_senior "Band Only Senior Year"

gen band_no=.
replace band_no=1 if band_soph==0&band_senior==0
replace band_no=0 if band_soph==1|band_senior==1

reg college band, r
est store band1

reg college band intend_college_b female hispanic white /// 
	black asian american_indian english_native_lang age_months siblings ///
	parent_grad_4_year income_above_50_k tv paid_work, r
est store band2

reg college band_sophsen band_only_soph band_only_senior, r
est store band2a

reg college band_sophsen band_only_soph band_only_senior intend_college_b female hispanic white /// 
	black asian american_indian english_native_lang age_months siblings ///
	parent_grad_4_year income_above_50_k tv paid_work, r
est store band17

reg change_math_quartile band, r
est store band16

reg change_math_quartile band intend_college_b female hispanic white /// 
	black asian american_indian english_native_lang age_months siblings ///
	parent_grad_4_year income_above_50_k tv paid_work, r
est store band15

reg change_math_quartile band_sophsen band_only_soph band_only_senior,r 
est store band15a

reg change_math_quartile band_sophsen band_only_soph band_only_senior intend_college_b female hispanic white /// 
	black asian american_indian english_native_lang age_months siblings ///
	parent_grad_4_year income_above_50_k tv paid_work, r
est store band18

gen female_band=band*female
reg college band intend_college_b female female_band hispanic white /// 
	black asian american_indian english_native_lang age_months siblings ///
	parent_grad_4_year income_above_50_k tv paid_work, r

gen inc50k_band=income_above_50_k*band
reg college inc50k_band band intend_college_b female hispanic white /// 
	black asian american_indian english_native_lang age_months siblings ///
	parent_grad_4_year income_above_50_k tv paid_work, r
est store band3



gen parentgrad_band=parent_grad_4_year*band
reg college parentgrad_band band intend_college_b female hispanic white /// 
	black asian american_indian english_native_lang age_months siblings ///
	parent_grad_4_year income_above_50_k tv paid_work, r	
est store band4

marginsplot (band3, color(navy) ciopts(lcolor(navy))) (marginal1, color(navy) ciopts(lcolor(navy))), keep(athlete athlete_all_4 athlete_only_soph athlete_began_sen) xline(0) legend(off) graphregion(color(white)) bgcolor(white) xtitle("Attend College")

****MARGINAL EFFECT***
reg college athlete##income_above_50_k intend_college_b female hispanic white /// 
	black asian american_indian english_native_lang age_months siblings ///
	parent_grad_4_year tv paid_work, r
margins, dydx(income_above_50_k) at((mean) _all athlete=(0 1))
marginsplot, yline(0) yscale(range(0 .2)) ytitle(Marginal Effect of Income Above 50k on College Attendance) xscale(range(-.5 1.5)) xdimension(athlete, elabels(0 "Not an Athlete" 1 "Athlete") )  recast(scatter) title("") xlabels(0 1)


reg college band##income_above_50_k intend_college_b female hispanic white /// 
	black asian american_indian english_native_lang age_months siblings ///
	parent_grad_4_year tv paid_work, r
margins, dydx(income_above_50_k) at((mean) _all band=(0 1))
marginsplot, yline(0) yscale(range(0 .14)) ytitle(Marginal Effect of Income Above 50k on College Attendance) xscale(range(-.5 1.5)) xdimension(band, elabels(0 "Not in Band" 1 "Band Participant") ) recast(scatter) title("") xlabels(0 1)


reg college athlete##parent_grad_4_year intend_college_b female hispanic white /// 
	black asian american_indian english_native_lang age_months siblings ///
	income_above_50_k tv paid_work, r
margins, dydx(parent_grad_4_year) at((mean) _all athlete=(0 1))
marginsplot, yline(0) yscale(range(0 .2)) ytitle(Marginal Effect of Parent College Graduate on College Attendance) xscale(range(-.5 1.5)) xdimension(athlete, elabels(0 "Not an Athlete" 1 "Athlete")) recast(scatter) title("") xlabels(0 1)

reg college band##parent_grad_4_year intend_college_b female hispanic white /// 
	black asian american_indian english_native_lang age_months siblings ///
	income_above_50_k tv paid_work, r
margins, dydx(parent_grad_4_year) at((mean) _all band=(0 1))
marginsplot, yline(0) yscale(range(0 .14)) ytitle(Marginal Effect of Parent College Graduate on College Attendance) xscale(range(-.5 1.5)) xdimension(band, elabels(0 "Not in Band" 1 "Band Participant" )) recast(scatter) title("") xlabels(0 1)

*Table 1**
esttab reg8 reg9 band3 band4 using "bandreg.tex", nomtitles booktabs ///
	coeflabels(athlete "Athlete" band "Band Participant" female "Female" hispanic "Hispanic" white "White" black "Black" asian "Asian" american_indian "American Indian" english_native_lang "English is Native Language" age_months "Age" siblings "Number of Siblings" parent_grad_4_year "Parent College Graduate" income_above_50_k "Income Above 50K" tv "Hours Watching per Week" paid_work "Held Paid Job as Sophomore" inc50k_band "Income Above 50K*Band Participant" parentgrad_band "Parent College Graduate*Band Participant" inc50k_athlete "Income Above 50K*Athlete" parentgrad_athlete "Parent College Graduate*Athlete") ///
	keep(athlete inc50k_athlete parentgrad_athlete band inc50k_band parentgrad_band female hispanic white black american_indian english_native_lang siblings parent_grad_4_year income_above_50_k tv paid_work) order(athlete inc50k_athlete parentgrad_athlete band inc50k_band parentgrad_band female hispanic white black american_indian english_native_lang siblings parent_grad_4_year income_above_50_k tv paid_work) notes label star(* 0.05 ** 0.01 *** 0.001) compress r2 se scalars("year Year") replace
	
/*esttab reg20 reg21 reg22 using "gproj2reredo.tex", se label
esttab log1 using "gproj3.tex", se label
esttab prob1 using "gproj4.tex", se label*/

***Summary Statistics***
estpost summarize athlete athlete_all_4 athlete_only_soph athlete_began_sen band band_sophsen band_only_soph band_only_senior
esttab using "sumindependent.tex", replace ///
	cells ("count mean sd min max") nonumber ///
	nomtitle nonote noobs label booktabs f ///
	collabels("N" "Mean" "St. Dev." "Min" "Max")
	
estpost summarize college change_math_quartile
esttab using "outcomesums.tex", replace ///
	cells ("count mean sd min max") nonumber ///
	nomtitle nonote noobs label booktabs f ///
	collabels("N" "Mean" "St. Dev." "Min" "Max")

lab var age_months "Age"
estpost summarize female white asian black american_indian hispanic age_months
esttab using "demographicsum1.tex", replace ///
	cells ("count mean sd min max") nonumber ///
	nomtitle nonote noobs label booktabs f ///
	collabels("N" "Mean" "St. Dev." "Min" "Max")
	
estpost summarize english_native_lang income_above_50_k parent_grad_4_year  ///
	intend_college siblings paid_work tv
esttab using "morecontrolssum2.tex", replace ///
	cells ("count mean sd min max") nonumber ///
	nomtitle nonote noobs label booktabs f ///
	collabels("N" "Mean" "St. Dev." "Min" "Max")

**FIGURE 1**
coefplot (reg1, color(navy) ciopts(lcolor(navy))), bylabel(Panel A) legend(off) xscale(r(-.02,.1)) || (reg3, color(navy) ciopts(lcolor(navy))), bylabel(Panel B) legend(off) xscale(r(-.02,.1)) ||, keep(athlete athlete_all_4 athlete_only_soph athlete_began_sen) xline(0) legend(off) graphregion(color(white)) bgcolor(white) xtitle("Attend College")
**FIGURE 2**
coefplot (reg21, color(navy) ciopts(lcolor(navy))), bylabel(Panel A) legend(off) xscale(r(-.02,.1)) || (reg22, color(navy) ciopts(lcolor(navy))), bylabel(Panel B) legend(off) xscale(r(-.02,.1)) ||, keep(athlete athlete_all_4 athlete_only_soph athlete_began_sen) xline(0) legend(off) graphregion(color(white)) bgcolor(white) xtitle("Change in Math Quartile")

**FIGURE 3***
coefplot (band2, color(navy) ciopts(lcolor(navy))), bylabel(Panel A) legend(off) xscale(r(-.02,.1)) || (band17, color(navy) ciopts(lcolor(navy))), bylabel(Panel B) legend(off) xscale(r(-.02,.1)) ||, keep(band band_sophsen band_only_soph band_only_senior) xline(0) legend(off) graphregion(color(white)) bgcolor(white) xtitle("Attend College")
**FIGURE 4**
coefplot (band15, color(navy) ciopts(lcolor(navy))), bylabel(Panel A) legend(off) xscale(r(-.02,.1)) || (band18, color(navy) ciopts(lcolor(navy))), bylabel(Panel B) legend(off) xscale(r(-.02,.1)) ||, keep(band band_sophsen band_only_soph band_only_senior) xline(0) legend(off) graphregion(color(white)) bgcolor(white) xtitle("Change in Math Quartile")


***APPENDIX TABLES***
*For Figure 1
esttab reg0 reg1 reg1a reg3 using "tableA1.tex", nomtitles booktabs ///
coeflabels(athlete "Athlete" athlete_all_4 "Athlete Sophomore and Senior Year" athlete_only_soph "Athlete Only Sophomore Year" athlete_began_sen "Athlete Only Senior Year" female "Female" hispanic "Hispanic" white "White" black "Black" asian "Asian" american_indian "American Indian" english_native_lang "English is Native Language" age_months "Age" siblings "Number of Siblings" parent_grad_4_year "Parent College Graduate" income_above_50_k "Income Above 50K" tv "Hours Watching per Week" paid_work "Held Paid Job as Sophomore") ///
	keep(athlete athlete_all_4 athlete_only_soph athlete_began_sen female hispanic white black american_indian english_native_lang siblings parent_grad_4_year income_above_50_k tv paid_work) order(athlete athlete_all_4 athlete_only_soph athlete_began_sen female hispanic white black american_indian english_native_lang siblings parent_grad_4_year income_above_50_k tv paid_work) notes label star(* 0.05 ** 0.01 *** 0.001) compress r2 se replace	
*For Figure 2
esttab reg20 reg21 reg21a reg22 using "tableA2.tex", nomtitles booktabs ///
coeflabels(athlete "Athlete" athlete_all_4 "Athlete Sophomore and Senior Year" athlete_only_soph "Athlete Only Sophomore Year" athlete_began_sen "Athlete Only Senior Year" female "Female" hispanic "Hispanic" white "White" black "Black" asian "Asian" american_indian "American Indian" english_native_lang "English is Native Language" age_months "Age" siblings "Number of Siblings" parent_grad_4_year "Parent College Graduate" income_above_50_k "Income Above 50K" tv "Hours Watching per Week" paid_work "Held Paid Job as Sophomore") ///
	keep(athlete athlete_all_4 athlete_only_soph athlete_began_sen female hispanic white black american_indian english_native_lang siblings parent_grad_4_year income_above_50_k tv paid_work) order(athlete athlete_all_4 athlete_only_soph athlete_began_sen female hispanic white black american_indian english_native_lang siblings parent_grad_4_year income_above_50_k tv paid_work) notes label star(* 0.05 ** 0.01 *** 0.001) compress r2 se replace
*For Figure 3
esttab band1 band2 band2a band17 using "tableB1.tex", nomtitles booktabs ///
	coeflabels(band "Band Participant" band_sophsen "Band Sophomore and Senior Year" band_only_soph "Band Only Sophomore Year" band_only_senior "Band Only Senior Year" female "Female" hispanic "Hispanic" white "White" black "Black" asian "Asian" american_indian "American Indian" english_native_lang "English is Native Language" age_months "Age" siblings "Number of Siblings" parent_grad_4_year "Parent College Graduate" income_above_50_k "Income Above 50K" tv "Hours Watching per Week" paid_work "Held Paid Job as Sophomore") ///
	keep(band band_sophsen band_only_soph band_only_senior female hispanic white black american_indian english_native_lang siblings parent_grad_4_year income_above_50_k tv paid_work) order(band band_sophsen band_only_soph band_only_senior female hispanic white black american_indian english_native_lang siblings parent_grad_4_year income_above_50_k tv paid_work) notes label star(* 0.05 ** 0.01 *** 0.001) compress r2 se scalars("year Year") replace
*For Figure 4
esttab band16 band15 band15a band18 using "tableB2.tex", nomtitles booktabs ///
	coeflabels(band "Band Participant" band_sophsen "Band Sophomore and Senior Year" band_only_soph "Band Only Sophomore Year" band_only_senior "Band Only Senior Year" female "Female" hispanic "Hispanic" white "White" black "Black" asian "Asian" american_indian "American Indian" english_native_lang "English is Native Language" age_months "Age" siblings "Number of Siblings" parent_grad_4_year "Parent College Graduate" income_above_50_k "Income Above 50K" tv "Hours Watching per Week" paid_work "Held Paid Job as Sophomore") ///
	keep(band band_sophsen band_only_soph band_only_senior female hispanic white black american_indian english_native_lang siblings parent_grad_4_year income_above_50_k tv paid_work) order(band band_sophsen band_only_soph band_only_senior female hispanic white black american_indian english_native_lang siblings parent_grad_4_year income_above_50_k tv paid_work) notes label star(* 0.05 ** 0.01 *** 0.001) compress r2 se scalars("year Year") replace

	
*Logit
logit college athlete intend_college_b female hispanic white /// 
	black asian american_indian english_native_lang age_months siblings ///
	parent_grad_4_year income_above_50_k tv paid_work, r
est store log1

logit college athlete_all_4 athlete_only_soph athlete_began_sen intend_college_b female hispanic white /// 
	black asian american_indian english_native_lang age_months siblings ///
	parent_grad_4_year income_above_50_k tv paid_work, r
est store log2

esttab log1 log2 using "tableC1.tex", nomtitles booktabs ///
	coeflabels(athlete "Athlete" athlete_all_4 "Athlete Sophomore and Senior Year" athlete_only_soph "Athlete Only Sophomore Year" athlete_began_sen "Athlete Only Senior Year" female "Female" hispanic "Hispanic" white "White" black "Black" asian "Asian" american_indian "American Indian" english_native_lang "English is Native Language" age_months "Age" siblings "Number of Siblings" parent_grad_4_year "Parent College Graduate" income_above_50_k "Income Above 50K" tv "Hours Watching per Week" paid_work "Held Paid Job as Sophomore") ///
	keep(athlete athlete_all_4 athlete_only_soph athlete_began_sen female hispanic white black american_indian english_native_lang siblings parent_grad_4_year income_above_50_k tv paid_work) order(athlete athlete_all_4 athlete_only_soph athlete_began_sen female hispanic white black american_indian english_native_lang siblings parent_grad_4_year income_above_50_k tv paid_work) notes label star(* 0.05 ** 0.01 *** 0.001) compress r2 se scalars("year Year") replace
	
logit college band intend_college_b female hispanic white /// 
	black asian american_indian english_native_lang age_months siblings ///
	parent_grad_4_year income_above_50_k tv paid_work, r
est store log3

logit college band_sophsen band_only_soph band_only_senior intend_college_b female hispanic white /// 
	black asian american_indian english_native_lang age_months siblings ///
	parent_grad_4_year income_above_50_k tv paid_work, r
est store log4

esttab log3 log4 using "tableC2.tex", nomtitles booktabs ///
	coeflabels(band "Band Participant" band_sophsen "Band Sophomore and Senior Year" band_only_soph "Band Only Sophomore Year" band_only_senior "Band Only Senior Year" female "Female" hispanic "Hispanic" white "White" black "Black" asian "Asian" american_indian "American Indian" english_native_lang "English is Native Language" age_months "Age" siblings "Number of Siblings" parent_grad_4_year "Parent College Graduate" income_above_50_k "Income Above 50K" tv "Hours Watching per Week" paid_work "Held Paid Job as Sophomore") ///
	keep(band band_sophsen band_only_soph band_only_senior female hispanic white black american_indian english_native_lang siblings parent_grad_4_year income_above_50_k tv paid_work) order(band band_sophsen band_only_soph band_only_senior female hispanic white black american_indian english_native_lang siblings parent_grad_4_year income_above_50_k tv paid_work) notes label star(* 0.05 ** 0.01 *** 0.001) compress r2 se scalars("year Year") replace
