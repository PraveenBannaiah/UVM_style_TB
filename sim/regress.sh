#!/bin/bash

set -e  # Stop on first error
set -x  # Print each command

rm -f merged_tests.ucdb
rm -f regression.ucdb
make cli TEST_SEED=100 GEN_TRANS_TYPE=csr_reset_test
make cli TEST_SEED=101 GEN_TRANS_TYPE=iicmb_core_enable_test
make cli TEST_SEED=102 GEN_TRANS_TYPE=FSM_reset_test
make cli TEST_SEED=103 GEN_TRANS_TYPE=Invalid_bus_range_test
make cli TEST_SEED=104 GEN_TRANS_TYPE=FSMR_permission_test
make cli TEST_SEED=105 GEN_TRANS_TYPE=I2C_sda_check
make cli TEST_SEED=106 GEN_TRANS_TYPE=test_base
make cli TEST_SEED=112 GEN_TRANS_TYPE=test_random
make cli TEST_SEED=107 GEN_TRANS_TYPE=dpr_register_test
make cli TEST_SEED=108 GEN_TRANS_TYPE=cmdr_status_bits
make cli TEST_SEED=109 GEN_TRANS_TYPE=cmdr_read_test
make cli TEST_SEED=110 GEN_TRANS_TYPE=invalid_address_test
make cli TEST_SEED=111 GEN_TRANS_TYPE=i2cmb_test
make create_merged_tests
make convert_testplan
make create_regression
vsim -viewcov regression.ucdb


