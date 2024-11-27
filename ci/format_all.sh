#!/bin/bash

# Check if folders and statistic name are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <folders> <statistic_name>"
    echo "Example: $0 \"baseline,cores\" IPC"
    exit 1
fi

# Inputs
folders="$1"
statistic="$2"
base_results_dir="organized_results"
summary_file="$base_results_dir/${statistic}_summary.csv"

# Create the base results directory if it doesn't exist
mkdir -p "$base_results_dir"
echo "Logfile,$statistic,Status" > "$summary_file"  # Initialize CSV with header

# Split the input folders by comma
IFS=',' read -r -a folder_array <<< "$folders"

# Function to locate folders dynamically
find_folder_path() {
    local folder_name="$1"
    find RESULTS/ -type d -name "$folder_name" 2>/dev/null | head -n 1
}

# Track failed tests
failed_tests=()

# Iterate through the specified folders
for folder in "${folder_array[@]}"; do
    folder_path=$(find_folder_path "$folder")
    if [ -z "$folder_path" ]; then
        echo "Warning: Folder '$folder' not found in RESULTS/. Skipping."
        continue
    fi

    echo "Processing folder: $folder_path"

    # Find all .log files in the folder
    for logfile in "$folder_path"/*.log; do
        if [ ! -f "$logfile" ]; then
            echo "No log files found in '$folder_path'. Skipping."
            continue
        fi

        test_name=$(basename "$logfile" .log)
        metric_value=""
        status="Success"

        # Read each line from the logfile
        while IFS= read -r line; do
            if [[ "$line" =~ [Ff]ailed|[Ee]rror ]]; then
                status="Failed"
                failed_tests+=("$test_name ($folder)")
                break
            fi

            if [[ "$line" == PERF:* ]]; then
                line_content="${line#PERF: }"

                # Handle special cases for "instrs", "cycles", and "IPC"
                if [[ "$statistic" == "IPC" || "$statistic" == "instrs" || "$statistic" == "cycles" ]]; then
                    if [[ "$line_content" =~ instrs=.*cycles=.*IPC=.* ]]; then
                        case "$statistic" in
                            "instrs") metric_value=$(echo "$line_content" | grep -o "instrs=[0-9-]*\(\.[0-9]*\)\?" | sed "s/instrs=//") ;;
                            "cycles") metric_value=$(echo "$line_content" | grep -o "cycles=[0-9-]*\(\.[0-9]*\)\?" | sed "s/cycles=//") ;;
                            "IPC") metric_value=$(echo "$line_content" | grep -o "IPC=[0-9-]*\(\.[0-9]*\)\?" | sed "s/IPC=//") ;;
                        esac
                        break
                    fi
                else
                    if [[ "$line_content" =~ $statistic=.* ]]; then
                        metric_value=$(echo "$line_content" | grep -o "$statistic=[0-9-]*\(\.[0-9]*\)\?" | sed "s/$statistic=//")
                        break
                    fi
                fi
            fi
        done < "$logfile"

        # Add the result to the summary file
        if [ "$status" == "Failed" ]; then
            echo "$test_name,,Failed" >> "$summary_file"
        elif [[ -n "$metric_value" ]]; then
            echo "$test_name,$metric_value,Success" >> "$summary_file"
        else
            echo "$test_name,,No Data" >> "$summary_file"
        fi
    done
done

# Report failed tests
if [ "${#failed_tests[@]}" -gt 0 ]; then
    echo "The following tests failed:"
    for failed_test in "${failed_tests[@]}"; do
        echo "- $failed_test"
    done
else
    echo "No tests failed."
fi

echo "Summary for $statistic saved in $summary_file"
