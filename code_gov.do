// Author: Karina Shyrokykh
// Journal: Governance 
// Title: Help your neighbour, help yourself: The drivers of EU’ climate cooperation in trans-governmental networks with its neighbours 
  
use "/Desktop/data.dta"

xtset ccode
xtset ccode year
xtset ccode year, yearly

///////////// Descriptive statistics  //////////
// Fig 1, appendix
hist events_total

// Table 1.  Summary statistics, manuscript
sum events_total logdis log_risk  loggdppc state_capacity  democracy log_eu_total_trade WGI_polstab member_asp freetradeagreement association_status log_emissions ett_taiex_req energy_2

cor logdis log_risk  loggdppc state_capacity  democracy log_eu_total_trade WGI_polstab member_asp freetradeagreement association_status log_emissions ett_taiex_req energy_2

///// Tests 
//serial correlation
xtserial events_total 

xtserial events_total freetradeagreement association_status log_emissions logdis loggdppc state_capacity log_risk democracy eap, output // serial correlation is detected, solution is to use clustering at the panel level


//heteroscedasticity
scatter events_total log_risk
scatter events_total logdis


//Table 2, manuscript, IRR
xtnbreg events_total logdis log_risk  loggdppc state_capacity  democracy log_eu_total_trade log_emissions association_status i.year  ett_taiex_req, i(ccode) robust pa irr 
est sto m1_req

// Fig 2, manuscript
margins, at(logdis=(6(0.5)12)) vsquish
marginsplot 

xtnbreg events_total logdis c.log_risk##c.state_capacity   loggdppc   democracy log_eu_total_trade  association_status log_emissions  i.year  ett_taiex_req , i(ccode)  robust pa irr
est sto m2_req

xtnbreg events_total c.logdis##c.state_capacity log_risk  loggdppc   democracy log_eu_total_trade association_status log_emissions i.year   ett_taiex_req , i(ccode)  robust pa irr
est sto m3_req

esttab m1_req m2_req m3_req  using "Table2.rtf", ///
legend label title(Table 6. )  se b(%9.3f) eform replace

* Appendix
* Robustness Poisson vs neg binom
quietly poisson events_total logdis log_risk  loggdppc state_capacity  democracy log_eu_total_trade log_emissions WGI_polstab member_asp freetradeagreement association_status ett_taiex_req,  robust 
est store poisson
quietly nbreg events_total logdis log_risk  loggdppc state_capacity  democracy log_eu_total_trade log_emissions WGI_polstab member_asp freetradeagreement association_status ett_taiex_req,  robust 
est store nbreg
lrtest poisson nbreg, stats force


// Appendix E, Table 1
xtnbreg events_total logdis log_risk  loggdppc state_capacity  democracy log_eu_total_trade log_emissions association_status i.year  ett_taiex_req, i(ccode) robust pa 
est sto m1

xtnbreg events_total c.logdis##c.state_capacity log_risk  loggdppc   democracy log_eu_total_trade association_status log_emissions i.year   ett_taiex_req , i(ccode)  robust pa 
est sto m2

xtnbreg events_total logdis c.log_risk##c.state_capacity   loggdppc   democracy log_eu_total_trade  association_status log_emissions  i.year  ett_taiex_req , i(ccode)  robust pa 
est sto m3

esttab m1 m2 m3 using ///
"Table2_2.rtf", ///
cells(b(star fmt(3)) se(par fmt(2))) ///
legend label title(Table 1.) ///
nonumbers mtitles("Model 1" "Model 2" "Model 3") ///
 stats(alpha N) b(%9.3f) replace


// Table 2 in appendix D, Table 2 (without Russia)
xtnbreg events_total logdis log_risk  loggdppc state_capacity  democracy log_eu_total_trade log_emissions association_status i.year  ett_taiex_req if country != "Russia", i(ccode) robust pa 
est sto m1_rus
 
xtnbreg events_total logdis c.log_risk##c.state_capacity   loggdppc   democracy log_eu_total_trade  association_status log_emissions  i.year  ett_taiex_req if country != "Russia", i(ccode)  robust pa 
est sto m2_rus

xtnbreg events_total c.logdis##c.state_capacity log_risk  loggdppc   democracy log_eu_total_trade association_status log_emissions i.year   ett_taiex_req if country != "Russia", i(ccode)  robust pa 
est sto m3_rus


esttab  m1_rus  m2_rus  m3_rus using ///
"Table2_2.rtf", ///
cells(b(star fmt(3)) se(par fmt(2))) ///
legend label title(Table 1.) ///
nonumbers mtitles("Model 1" "Model 2" "Model 3") ///
 b(%9.3f) replace

// Table 3 in Appendix D additional controls -- energy and EU membership aspirations
xtnbreg events_total logdis log_risk  loggdppc state_capacity  democracy log_eu_total_trade log_emissions ett_taiex_req ///
 member_asp  association_status i.year energy_2  , i(ccode) robust pa irr
est sto m1_irr_en

 xtnbreg events_total logdis c.log_risk##c.state_capacity  loggdppc  democracy log_eu_total_trade log_emissions ett_taiex_req ///
 member_asp  association_status i.year energy_2  , i(ccode) robust pa irr
 est sto m2_irr_en
 
 xtnbreg events_total c.logdis##c.state_capacity  log_risk  loggdppc  democracy log_eu_total_trade log_emissions ett_taiex_req ///
 member_asp  association_status i.year energy_2 , i(ccode) robust pa irr
 est sto m3_irr_en
 
esttab m1_irr_en m2_irr_en m3_irr_en  using "Table2b_en.rtf", ///
legend label title(Table 3. ) se  b(%9.3f) eform replace


// Robustness check -- 2SLS
ivregress 2sls  events_total logdis log_risk  loggdppc   democracy log_eu_total_trade  WGI_polstab member_asp freetradeagreement association_status eap i.year  (state_capacity = l.events_total ll.events_total )
estat endog 

// Modelling endogeniety  
reg state_capacity l.events_total    ll.events_total  
predict v2hat

xtnbreg  events_total logdis log_risk  loggdppc state_capacity  democracy log_eu_total_trade  WGI_polstab member_asp  association_status  i.year log_emissions freetradeagreement v2hat, i(ccode) robust pa
est sto m_endog_1

xtnbreg events_total logdis c.log_risk##c.state_capacity   loggdppc   democracy log_eu_total_trade  WGI_polstab member_asp   association_status  i.year log_emissions freetradeagreement v2hat, i(ccode)  robust pa
est sto m_endog_2

xtnbreg events_total c.logdis##c.state_capacity log_risk  loggdppc   democracy log_eu_total_trade   WGI_polstab member_asp  association_status i.year log_emissions freetradeagreement v2hat, i(ccode)  robust pa
est sto m_endog_3

esttab m_endog_1 m_endog_2 m_endog_3 using "/Desktop/Table2.rtf", ///
cells(b(star fmt(3)) se(par fmt(2))) ///
legend label title("Table 2. NBRM with endogenous explanatory variable") nonumbers mtitles("Model 1"  "Mode 2" ) ///
star(* 0.10 ** 0.05 *** 0.01) stats( N ) b(%9.3f) replace



