capture log close
clear all
set mem 500m
set more off

local logpath H:\OOP\local_logs
local datapath H:\OOP\data

log using `logpath'\6-mc_oop_dementia-LOG.txt, text replace

cd `datapath'

use oop_mc_sample_public.dta 
********************************************
describe

sum snf_paid_by_mc_2yr_wi, detail
sum nh_oop_24m, detail
sum nh_cost_medicaid_24m, detail
sum nh_cost_private_24m, detail


********************************************
log close




