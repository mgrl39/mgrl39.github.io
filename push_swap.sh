#!/bin/bash

# Nickname
NICKNAME="mgrl39"

# Path to the push_swap and checker executables
PUSH_SWAP="./push_swap"
CHECKER="./checker_linux"  # Use checker_Mac if you are on MacOS

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if push_swap exists
if [ ! -f "$PUSH_SWAP" ]; then
    echo -e "${RED}Error: ${PUSH_SWAP} not found. Exiting.${NC}"
    exit 1
fi

# Check if checker exists
if [ ! -f "$CHECKER" ]; then
    echo -e "${RED}Error: ${CHECKER} not found. Exiting.${NC}"
    exit 1
fi

# Function to run a test and check for memory leaks
run_test_with_valgrind() {
    CMD=$1
    EXPECTED_OUTPUT=$2

    echo -e "${YELLOW}Running: $CMD${NC}"
    OUTPUT=$(eval $CMD)

    if [ "$OUTPUT" == "$EXPECTED_OUTPUT" ]; then
        echo -e "${GREEN}Test passed${NC}"
    else
        echo -e "${RED}Test failed${NC}"
        echo -e "Expected: ${EXPECTED_OUTPUT}"
        echo -e "Got: ${OUTPUT}"
    fi

    echo -e "${YELLOW}Checking for memory leaks...${NC}"
    VALGRIND_CMD="valgrind --leak-check=full --error-exitcode=1 $CMD"
    eval $VALGRIND_CMD 2>&1 | tee /tmp/valgrind_output.log | grep -E 'allocs|frees|ERROR SUMMARY'
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}No memory leaks detected${NC}"
    else
        echo -e "${RED}Memory leaks detected${NC}"
    fi

    echo "================================="
}

# Function for non-numeric input test
test_non_numeric_input() {
    echo -e "${YELLOW}Running Test: Non-numeric Input...${NC}"
    OUTPUT=$(./push_swap a b c d e 2>&1)
    echo "Output: ${OUTPUT}"
    run_test_with_valgrind "./push_swap a b c d e 2>&1" "Error"
}

# Function for duplicate numbers test
test_duplicate_numbers() {
    echo -e "${YELLOW}Running Test: Duplicate Numbers...${NC}"
    OUTPUT=$(./push_swap 1 2 3 1 2>&1)
    echo "Output: ${OUTPUT}"
    run_test_with_valgrind "./push_swap 1 2 3 1 2>&1" "Error"
}

# Function for number out of range test
test_number_out_of_range() {
    echo -e "${YELLOW}Running Test: Number Out of Range...${NC}"
    OUTPUT=$(./push_swap 1 2147483648 2>&1)
    echo "Output: ${OUTPUT}"
    run_test_with_valgrind "./push_swap 1 2147483648 2>&1" "Error"
}

# Function for empty input test
test_empty_input() {
    echo -e "${YELLOW}Running Test: Empty Input...${NC}"
    OUTPUT=$(./push_swap 2>/dev/null)
    echo "Output: ${OUTPUT}"
    if [ -z "$OUTPUT" ]; then
        echo -e "${GREEN}Test passed${NC}"
    else
        echo -e "${RED}Test failed${NC}"
        echo -e "Output: ${OUTPUT}"
    fi
}

# Function for identity tests
run_identity_tests() {
    echo -e "${YELLOW}Running Identity Tests...${NC}"
    run_test_with_valgrind "$PUSH_SWAP 42" ""
    run_test_with_valgrind "$PUSH_SWAP 2 3" ""
    run_test_with_valgrind "$PUSH_SWAP 0 1 2 3" ""
    run_test_with_valgrind "$PUSH_SWAP 0 1 2 3 4 5 6 7 8 9" ""
}

# Function for simple version tests
run_simple_tests() {
    echo -e "${YELLOW}Running Simple Version Tests...${NC}"

    # Run specific tests within simple version tests
    test_non_numeric_input
    test_duplicate_numbers
    test_number_out_of_range
    test_empty_input
    run_identity_tests

    # Additional simple version tests
    echo -e "${YELLOW}Running Additional Simple Version Tests...${NC}"

    # Test with fixed argument
    ARG="2 1 0"
    run_test_with_valgrind "$PUSH_SWAP $ARG | $CHECKER $ARG" "OK"

    # Test with randomly generated arguments
    ARG=$(shuf -i 0-3 -n 3 | xargs)
    run_test_with_valgrind "$PUSH_SWAP $ARG | $CHECKER $ARG" "OK"

    # Another fixed argument
    ARG="1 5 2 4 3"
    run_test_with_valgrind "$PUSH_SWAP $ARG | $CHECKER $ARG" "OK"

    # Another random test
    ARG=$(shuf -i 0-4 -n 5 | xargs)
    run_test_with_valgrind "$PUSH_SWAP $ARG | $CHECKER $ARG" "OK"
}

# Function for middle version tests
run_middle_tests() {
    echo -e "${YELLOW}Running Middle Version Test...${NC}"

    # Initialize variables to keep track of the best result and the total sum for average
    BEST_INSTRUCTIONS_SIZE=9999999
    TOTAL_INSTRUCTIONS_SIZE=0

    # Run the test 300 times
    for i in {1..300}; do
        # Generate 100 random values
        ARG=$(shuf -i 0-10000 -n 100 | xargs)
        echo "Testing with: $ARG"

        # Run the test
        OUTPUT=$(./push_swap $ARG | ./checker_linux $ARG)
        RESULT_CODE=$?

        # Check the result
        if [ $RESULT_CODE -eq 0 ]; then
            echo -e "${GREEN}Checker output: OK${NC}"
            
            # Measure the number of instructions
            INSTRUCTIONS_SIZE=$(./push_swap $ARG | wc -l)
            echo -e "Number of instructions: ${INSTRUCTIONS_SIZE}"
            
            # Update the best result if current is better
            if [ $INSTRUCTIONS_SIZE -lt $BEST_INSTRUCTIONS_SIZE ]; then
                BEST_INSTRUCTIONS_SIZE=$INSTRUCTIONS_SIZE
            fi

            # Accumulate the total number of instructions for average calculation
            TOTAL_INSTRUCTIONS_SIZE=$((TOTAL_INSTRUCTIONS_SIZE + INSTRUCTIONS_SIZE))
        else
            echo -e "${RED}Checker output: Error${NC}"
            echo -e "Output: ${OUTPUT}"
        fi
    done

    # Calculate the average number of instructions
    AVERAGE_INSTRUCTIONS_SIZE=$((TOTAL_INSTRUCTIONS_SIZE / 100))

    # Assign points based on the best number of instructions
    if [ $BEST_INSTRUCTIONS_SIZE -lt 700 ]; then
        POINTS=5
    elif [ $BEST_INSTRUCTIONS_SIZE -lt 900 ]; then
        POINTS=4
    elif [ $BEST_INSTRUCTIONS_SIZE -lt 1100 ]; then
        POINTS=3
    elif [ $BEST_INSTRUCTIONS_SIZE -lt 1300 ]; then
        POINTS=2
    elif [ $BEST_INSTRUCTIONS_SIZE -lt 1500 ]; then
        POINTS=1
    else
        POINTS=0
    fi

    echo -e "${YELLOW}Best number of instructions: ${BEST_INSTRUCTIONS_SIZE}${NC}"
    echo -e "${YELLOW}Average number of instructions: ${AVERAGE_INSTRUCTIONS_SIZE}${NC}"
    echo -e "${YELLOW}Points awarded: ${POINTS}${NC}"
}

# Function for advanced version tests
run_advanced_tests() {
    echo -e "${YELLOW}Running Advanced Version Test...${NC}"

    # Initialize variables for the advanced test
    TOTAL_INSTRUCTIONS_SIZE=0
    SUCCESSFUL_TESTS=0
    POINTS=0

    # Run the advanced test 300 times
    for i in {1..300}; do
        # Generate 500 random values
        ARG=$(shuf -i 0-10000 -n 500 | xargs)
        echo "Testing with: $ARG"

        # Run the test
        OUTPUT=$(./push_swap $ARG | ./checker_linux $ARG)
        RESULT_CODE=$?

        # Check the result
        if [ $RESULT_CODE -eq 0 ]; then
            echo -e "${GREEN}Checker output: OK${NC}"
            
            # Measure the number of instructions
            INSTRUCTIONS_SIZE=$(./push_swap $ARG | wc -l)
            echo -e "Number of instructions: ${INSTRUCTIONS_SIZE}"
            
            # Accumulate the total number of instructions
            TOTAL_INSTRUCTIONS_SIZE=$((TOTAL_INSTRUCTIONS_SIZE + INSTRUCTIONS_SIZE))
            SUCCESSFUL_TESTS=$((SUCCESSFUL_TESTS + 1))
        else
            echo -e "${RED}Checker output: Error${NC}"
            echo -e "Output: ${OUTPUT}"
        fi
    done

    # Calculate the average number of instructions
    if [ $SUCCESSFUL_TESTS -gt 0 ]; then
        AVERAGE_INSTRUCTIONS_SIZE=$((TOTAL_INSTRUCTIONS_SIZE / SUCCESSFUL_TESTS))
    else
        AVERAGE_INSTRUCTIONS_SIZE=0
    fi

    # Assign points based on the average number of instructions
    if [ $AVERAGE_INSTRUCTIONS_SIZE -lt 5500 ]; then
        POINTS=5
    elif [ $AVERAGE_INSTRUCTIONS_SIZE -lt 7000 ]; then
        POINTS=4
    elif [ $AVERAGE_INSTRUCTIONS_SIZE -lt 8500 ]; then
        POINTS=3
    elif [ $AVERAGE_INSTRUCTIONS_SIZE -lt 10000 ]; then
        POINTS=2
    elif [ $AVERAGE_INSTRUCTIONS_SIZE -lt 11500 ]; then
        POINTS=1
    else
        POINTS=0
    fi

    echo -e "${YELLOW}Average number of instructions (Advanced): ${AVERAGE_INSTRUCTIONS_SIZE}${NC}"
    echo -e "${YELLOW}Points awarded (Advanced): ${POINTS}${NC}"
}


# Function to display the menu and handle user input
show_menu() {
    echo -e "${YELLOW}Select which tests to run:${NC}"
    echo "1) Run Simple Version Tests (includes specific tests)"
    echo "2) Run Middle Version Test"
    echo "3) Run Advanced Version Test"
    echo "4) Run All Tests"
    echo "0) Exit"
    read -p "Enter your choice: " choice

    case $choice in
        1) run_simple_tests ;;
        2) run_middle_tests ;;
        3) run_advanced_tests ;;
        4) 
            run_simple_tests
            run_middle_tests
            run_advanced_tests
            ;;
        0) exit 0 ;;
        *) echo -e "${RED}Invalid choice${NC}" ;;
    esac
}

# Main script execution
show_menu

