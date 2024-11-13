#!/bin/bash

# Check if a folder name is provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <source_folder>"
    exit 1
fi

# Use the provided folder name as the source folder
source_folder="$1"

# Define the main results directory
base_results_dir="organized_results"

# Use the timestamp from the source folder name
timestamp=$(basename "$source_folder")
run_dir="$base_results_dir/$timestamp"
mkdir -p "$run_dir"

# Function to process each logfile and create its own CSV file
process_logfile() {
    local logfile="$1"
    local test_name=$(basename "$logfile" .log)
    local output_file="$run_dir/${test_name}.csv"
    echo "Metric,Value" > "$output_file"  # Initialize CSV with header

    # Read each "PERF:" line from the logfile
    while IFS= read -r line; do
        if [[ "$line" == PERF:* ]]; then
            line_content="${line#PERF: }"

            # Check if the line contains "instrs", "cycles", and "IPC" together
            if [[ "$line_content" =~ instrs=.*cycles=.*IPC=.* ]]; then
                prefix=$(echo "$line_content" | sed -E 's/([^ ]*): .*/\1/')
                metrics_part=$(echo "$line_content" | sed -E 's/[^ ]*: (.*)/\1/')
                
                IFS=',' read -ra metrics_array <<< "$metrics_part"
                
                for metric_pair in "${metrics_array[@]}"; do
                    metric_name=$(echo "$metric_pair" | sed -E 's/([^=]+)=.*/\1/' | xargs)
                    metric_value=$(echo "$metric_pair" | sed -E 's/^[^=]+=([0-9]+(\.[0-9]+)?).*/\1/' | xargs)
                    
                    # Combine prefix with metric name if the prefix exists
                    if [[ "$prefix" != "$line_content" ]]; then
                        metric_name="$prefix: $metric_name"
                    fi

                    # Write the metric name and value to the CSV
                    echo "$metric_name,$metric_value" >> "$output_file"
                done
            else
                # For other lines, capture the metric name and numeric value only
                metric_name=$(echo "$line_content" | sed -E 's/([^=]+)=.*/\1/' | xargs)
                metric_value=$(echo "$line_content" | sed -E 's/^[^=]+=([0-9]+(\.[0-9]+)?).*/\1/' | xargs)
                
                # Write the metric directly to the CSV
                echo "$metric_name,$metric_value" >> "$output_file"
            fi
        fi
    done < "$logfile"
}

# Process each .log file in the specified source folder
for logfile in "$source_folder"/*.log; do
    process_logfile "$logfile"
done

echo "Organized results saved in $run_dir"
