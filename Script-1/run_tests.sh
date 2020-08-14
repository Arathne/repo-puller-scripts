#!/bin/sh

##
# @file     run_tests.sh
# @brief    Copy in the configuration file and run the tests
#
# @author   gachshel    Gabriel Shelton
# @date     2019-01-25

TEST_DIR='tests/'

##
# @brief    Copy in the config file and run tests
# @param    Assignment name
function main {
    local assignment=$1
    local test_configuration=${TEST_DIR}/${assignment}.conf
    
    # If the test configuration does not exist (exit, no tests)
    if [ ! -f ${test_configuration} ]; then
        echo "No Tests"
        exit -1
    fi

    # Loop through the folders in assignment checking if there is a folder named base.
    # If so move the test file in and run the tests, else move on
    for dir in $(ls "$assignment"); do
        local target=${assignment}/${dir}/base/
        echo "Testing: $target"
        if [ -d ${target} ]; then
            cp ${test_configuration} ${target}
            python3 /home/gachshel/tools/pytester/main.py "${target}${assignment}.conf"
        fi
    done

    echo "Tests Completed"
}

main "$@"
