#!/bin/bash

# Check if jq and dict are installed
if ! command -v jq &> /dev/null; then
    echo "jq is required but not installed. Please install it."
    exit 1
fi

if ! command -v dict &> /dev/null; then
    echo "dict is required but not installed. Please install it."
    exit 1
fi

JSON_FILE="markov_chain.json"

# Function to initialize JSON file if it doesn't exist
initialize_json() {
    if [ ! -f "$JSON_FILE" ]; then
        echo '{"states": {}}' > "$JSON_FILE"
    fi
}

# Function to sanitize input words
sanitize_word() {
    echo "$1" | tr -d '[:punct:]' | xargs
}

# Function to classify parts of speech using a dictionary lookup
classify_word() {
    local word="$1"
    local type=""

    {
        definitions=$(dict "$word" 2>/dev/null)
        if [[ $? -ne 0 ]]; then
            echo "Error retrieving definition for $word" >&2
            return
        fi

        if [[ -z "$definitions" ]]; then
            return  
        fi

        if echo "$definitions" | grep -qi "verb"; then
            type="verb"
        fi

        if echo "$definitions" | grep -qi "noun"; then
            type="noun"
        fi

        if echo "$definitions" | grep -qi "adjective"; then
            type="adjective"
        fi

        if echo "$definitions" | grep -qi "adverb"; then
            type="adverb"
        fi

        echo "${type}:${word}"
    } &
}

# Function to extract possible punctuation from training data
extract_punctuation() {
    punctuations=()
    words=$(jq -r '.states | to_entries | map(.key) | .[]' "$JSON_FILE")

    for word in $words; do
        case $word in
            *.) punctuations+=('.') ;;
            *!) punctuations+=('!') ;;
            *?) punctuations+=('?') ;;
        esac
    done

    punctuations=($(printf "%s\n" "${punctuations[@]}" | sort -u))
}

# Function to train the model from a text file
train_from_file() {
    for file in "$@"; do
        if [[ -f "$file" ]]; then
            echo "Training from file: $file"
            while IFS= read -r line; do
                line=$(echo "$line" | tr '[:upper:]' '[:lower:]')
                words=()
                for word in $line; do
                    sanitized="$(sanitize_word "$word")"
                    if [[ -n "$sanitized" ]]; then
                        words+=("$sanitized")
                    fi
                done

                for (( i=0; i<${#words[@]}-2; i++ )); do  # Using trigrams
                    current_state="${words[i]} ${words[i+1]} ${words[i+2]}"
                    next_state="${words[i+1]} ${words[i+2]} ${words[i+3]}"
                    
                    if ! jq -e ".states.\"$current_state\"" "$JSON_FILE" > /dev/null; then
                        jq --arg state "$current_state" '.states[$state] = []' "$JSON_FILE" > tmp.$$.json && mv tmp.$$.json "$JSON_FILE"
                    fi
                    
                    if [[ $i -lt ${#words[@]}-3 ]] && ! jq -e ".states.\"$current_state\" | index(\"$next_state\")" "$JSON_FILE" > /dev/null; then
                        jq --arg state "$current_state" --arg next "$next_state" '.states[$state] += [$next]' "$JSON_FILE" > tmp.$$.json && mv tmp.$$.json "$JSON_FILE"
                    fi
                done
            done < "$file"
        else
            echo "File not found: $file"
        fi
    done
}

# Function to get the next state based on the current state
get_next_state() {
    current_state=$1
    next_states=$(jq -r ".states[\"$current_state\"][]" "$JSON_FILE" 2>/dev/null)

    if [[ -z "$next_states" ]]; then
        echo ""
        return
    fi

    IFS=$'\n' read -r -d '' -a states_array <<< "$next_states"
    random_index=$((RANDOM % ${#states_array[@]}))
    echo "${states_array[$random_index]}"
}

# Function to clear the console screen
clear_screen() {
    clear
}

# Function to remove duplicate words from a sentence
remove_duplicates() {
    echo "$1" | awk '{ for(i=1;i<=NF;i++) if(!seen[$i]++) printf("%s%s", $i, (i==NF ? "" : " ")) }'
}

# Function to determine the appropriate punctuation based on the last word
get_end_punctuation() {
    local word="$1"
    case "$word" in
        *\? )
            echo "?"
            ;;
        *\! )
            echo "!"
            ;;
        *[.?!] )
            echo "."
            ;;
        * )
            echo "."  # Default to period if no specific punctuation is indicated
            ;;
    esac
}

# Function to generate text based on the current Markov model
generate_text() {
    read -p "Enter the number of sentences to generate: " num_sentences

    if ! [[ "$num_sentences" =~ ^[0-9]+$ ]] || [ "$num_sentences" -lt 1 ]; then
        echo "Please enter a valid number greater than 0."
        return
    fi

    initial_states=$(jq -r '.states | keys[]' "$JSON_FILE" 2>/dev/null | grep -v '^$')
    
    if [[ -z "$initial_states" ]]; then
        echo "No initial states found. Please train the model with phrases first."
        return
    fi

    sentences=()  # Array to hold generated sentences

    for (( s=0; s<num_sentences; s++ )); do
        current_state=$(echo "$initial_states" | shuf -n 1)
        sentence=""
        sentence_length=$((RANDOM % 8 + 5))
        word_count=0
        
        while [[ $word_count -lt $sentence_length ]]; do
            sentence+="$current_state "
            next_state=$(get_next_state "$current_state")
            if [[ -z "$next_state" ]]; then
                break
            fi
            current_state="$next_state"
            ((word_count++))
        done

        # Capitalize the first letter
        sentence="$(tr '[:lower:]' '[:upper:]' <<< "${sentence:0:1}")${sentence:1}"
        # Trim trailing space
        sentence=$(echo "$sentence" | sed 's/[[:space:]]\+$//')

        # Remove duplicates if necessary
        sentence=$(remove_duplicates "$sentence")

        # Determine punctuation based on last word
        last_word=$(echo "$sentence" | awk '{print $NF}')
        punctuation=$(get_end_punctuation "$last_word")
        sentence+="$punctuation"

        sentences+=("$sentence")  # Collect generated sentence
    done

    # Display generated sentences with index numbers
    echo "Generated Sentences:"
    for i in "${!sentences[@]}"; do
        echo "$((i + 1)): ${sentences[$i]}"
    done

    # Feedback loop for user input on sentences
    read -p "Enter the numbers of the bad sentences (space-separated), or press enter if none: " bad_sentence_numbers

    if [[ -n "$bad_sentence_numbers" ]]; then
        for num in $bad_sentence_numbers; do
            if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -gt 0 ] && [ "$num" -le "${#sentences[@]}" ]; then
                read -p "Please provide a better sentence for Sentence $num: " better_sentence
                train_markov_from_sentence "$better_sentence"
            else
                echo "Invalid number: $num (must be between 1 and ${#sentences[@]})"
            fi
        done
    fi
}

# Function to train from a specific sentence
train_markov_from_sentence() {
    local input="$1"
    
    input=$(echo "$input" | tr '[:upper:]' '[:lower:]')
    
    # Split input into words and form trigrams
    words=($input)
    for (( i=0; i<${#words[@]}-2; i++ )); do
        current_state="${words[i]} ${words[i+1]} ${words[i+2]}"
        next_state="${words[i+1]} ${words[i+2]} ${words[i+3]}"
        
        if ! jq -e ".states.\"$current_state\"" "$JSON_FILE" > /dev/null; then
            jq --arg state "$current_state" '.states[$state] = []' "$JSON_FILE" > tmp.$$.json && mv tmp.$$.json "$JSON_FILE"
        fi
        
        if [[ $i -lt ${#words[@]}-3 ]] && ! jq -e ".states.\"$current_state\" | index(\"$next_state\")" "$JSON_FILE" > /dev/null; then
            jq --arg state "$current_state" --arg next "$next_state" '.states[$state] += [$next]' "$JSON_FILE" > tmp.$$.json && mv tmp.$$.json "$JSON_FILE"
        fi
    done
}

# Main interaction loop
initialize_json  # Initialize JSON file if it doesn't exist

clear_screen
echo "Welcome to the Markov Chain Trainer!"
while true; do
    echo "Choose an option:"
    echo "1. Train the model with new phrases"
    echo "2. Generate a sequence with the trained model"
    echo "3. Train the model from a text file"
    echo "4. Exit"
    read -p "Enter option (1/2/3/4): " option

    case $option in
        1) 
            read -p "Enter a phrase (or type 'exit' to finish): " input
            while [[ "$input" != "exit" ]]; do
                train_markov_from_sentence "$input"
                read -p "Enter a phrase (or type 'exit' to finish): " input
            done
            ;;
        2) 
            generate_text ;;  # Function to generate text
        3) 
            read -p "Enter the text file path(s) (space separated): " -a files
            train_from_file "${files[@]}"  # Function to train from a file
            ;;
        4) 
            exit 0 ;;  # Exit the script
        *) 
            echo "Invalid option, please try again." ;;  # Handle invalid inputs
    esac
done
