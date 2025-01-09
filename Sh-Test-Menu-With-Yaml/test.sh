#!/bin/bash

# Check if Python 3 and PyYAML are installed
if ! command -v python3 &> /dev/null; then
    echo "Python3 is not installed. Please install it to run this script."
    exit 1
fi

# Install PyYAML package if it's not installed
if ! python3 -c "import yaml" &> /dev/null; then
    echo "Installing PyYAML since it's not found."
    pip3 install pyyaml
fi

# Check if the questions file exists
if [ ! -f questions.yaml ]; then
    echo "questions.yaml file not found!"
    exit 1
fi

# Load questions from YAML file
load_questions() {
    python3 - <<END
import yaml
with open('questions.yaml', 'r') as file:
    questions = yaml.safe_load(file)
    for question in questions:
        print(question)
END
}

# Parse YAML file
questions=$(load_questions)

# Shuffle questions
questions=$(echo "$questions" | shuf)

# Initialize score tracking
score=0
total=0

# Start timer
SECONDS=0

# Welcome message
echo "Welcome to the Quiz!"
echo "You will be presented with multiple-choice questions."
echo "Please respond with A, B, C, or D."
echo "Let's start!"
sleep 2

# Loop to read and present each question
IFS=$'\n'  # Set Internal Field Separator to newline to read questions correctly
for question in $questions; do
    # Extract details using Python for each question
    q=$(echo "$question" | python3 -c "import sys, yaml; print(yaml.safe_load(sys.stdin)['question'])")
    options=$(echo "$question" | python3 -c "import sys, yaml; options = yaml.safe_load(sys.stdin)['options']; print('\n'.join(options))")
    correct_answer=$(echo "$question" | python3 -c "import sys, yaml; print(yaml.safe_load(sys.stdin)['answer'])")

    # Clear the screen for a cleaner interface
    clear 

    # Display the question and options
    echo "----------------------------------------"
    echo "QUESTION $((total + 1)) of $(echo "$questions" | wc -l)"
    echo "----------------------------------------"
    echo "$q"
    echo "Options:"
    echo "$options"
    echo "----------------------------------------"

    # Increment total questions
    total=$((total + 1))

    # Read user answer with prompt and input validation
    read -p "Your answer (A, B, C, D): " user_answer
    user_answer=${user_answer^^}  # Convert answer to uppercase
    
    while ! [[ "A B C D" =~ $user_answer ]]; do
        echo "Invalid input. Please enter A, B, C, or D."
        read -p "Your answer (A, B, C, D): " user_answer
        user_answer=${user_answer^^}
    done

    # Check answer
    if [[ "$user_answer" == "$correct_answer" ]]; then
        echo -e "\e[32mCorrect!\e[0m"  # Green color for correct
        score=$((score + 1))
    else
        echo -e "\e[31mIncorrect. The correct answer is $correct_answer.\e[0m"  # Red color for incorrect
    fi

    echo ""
    sleep 1  # Pause for readability
done

# Clear the screen after the quiz ends
clear 

# Final Score
echo "----------------------------------------"
echo "YOUR FINAL SCORE: $score out of $total"
echo "Total time taken: $SECONDS seconds"
percentage=$(echo "scale=2; $score/$total*100" | bc)
echo "Your percentage score: $percentage%"
echo "----------------------------------------"

# Save results to a file
{
echo "Final Score: $score out of $total"
echo "Total time taken: $SECONDS seconds"
echo "Percentage score: $percentage%"
} >> quiz_results.txt

echo "Your results have been saved to quiz_results.txt"
