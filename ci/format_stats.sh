#!/bin/bash

# Check if folder and statistic name are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <source_folder> <statistic_name>"
    exit 1
fi

source_folder="$1"
statistic="$2"
base_results_dir="organized_results"
timestamp=$(basename "$source_folder")
summary_file="$base_results_dir/${timestamp}_${statistic}_summary.csv"

mkdir -p "$base_results_dir"
echo "Logfile,$statistic" > "$summary_file"  # Initialize summary CSV with header

# Process each logfile for the specified statistic
for logfile in "$source_folder"/*.log; do
    test_name=$(basename "$logfile" .log)
    metric_value=""

    # Read each line from the logfile
    while IFS= read -r line; do
        if [[ "$line" == PERF:* ]]; then
            line_content="${line#PERF: }"

            # Handle special cases for "instrs", "cycles", and "IPC" appearing together
            if [[ "$statistic" == "IPC" || "$statistic" == "instrs" || "$statistic" == "cycles" ]]; then
                if [[ "$line_content" =~ instrs=.*cycles=.*IPC=.* ]]; then
                    case "$statistic" in
                        "instrs") metric_value=$(echo "$line_content" | grep -o "instrs=[0-9-]*\(\.[0-9]*\)\?" | sed "s/instrs=//") ;;
                        "cycles") metric_value=$(echo "$line_content" | grep -o "cycles=[0-9-]*\(\.[0-9]*\)\?" | sed "s/cycles=//") ;;
                        "IPC") metric_value=$(echo "$line_content" | grep -o "IPC=[0-9-]*\(\.[0-9]*\)\?" | sed "s/IPC=//") ;;
                    esac
                    break  # Stop after finding the first relevant line
                fi
            else
                # For general statistics, extract the value if the line contains the requested statistic
                if [[ "$line_content" =~ $statistic=.* ]]; then
                    metric_value=$(echo "$line_content" | grep -o "$statistic=[0-9-]*\(\.[0-9]*\)\?" | sed "s/$statistic=//")
                    break  # Stop after finding the first relevant line
                fi
            fi
        fi
    done < "$logfile"

    # Only add to the summary CSV if the metric value was found
    if [[ -n "$metric_value" ]]; then
        echo "$test_name,$metric_value" >> "$summary_file"
    fi
done

echo "Summary for $statistic saved in $summary_file"
