#!/bin/bash

# Specify the folder containing the logfiles
folder="results_20241030_212305"  # Replace with your target folder

# Define the consolidated output file
output_file="consolidated_results.csv"
echo -n > "$output_file"  # Clear the file if it exists

# Associative array to store metrics by logfile
declare -A metrics

# Array to keep track of unique metric names
unique_metrics=()
column_headers=()

# Loop through each .log file in the specified folder
for logfile in "$folder"/*.log; do
    # Extract the test name from the logfile name (e.g., logfile1)
    test_name=$(basename "$logfile" .log)
    column_headers+=("$test_name")

    # Read each "PERF:" line from the logfile
    while IFS= read -r line; do
        if [[ "$line" == PERF:* ]]; then
            # Remove the "PERF: " prefix
            line_content="${line#PERF: }"
            
            # Check if the line contains "instrs", "cycles", and "IPC" together
            if [[ "$line_content" =~ instrs=.*cycles=.*IPC=.* ]]; then
                # Split the prefix from the metrics (e.g., "core3: instrs=..." becomes "core3:" and the rest)
                prefix=$(echo "$line_content" | sed -E 's/([^ ]*): .*/\1/')
                metrics_part=$(echo "$line_content" | sed -E 's/[^ ]*: (.*)/\1/')
                
                # Split the metrics part by commas into individual metrics
                IFS=',' read -ra metrics_array <<< "$metrics_part"
                
                for metric_pair in "${metrics_array[@]}"; do
                    # Extract each metric name and numeric value only
                    metric_name=$(echo "$metric_pair" | sed -E 's/([^=]+)=.*/\1/' | xargs)
                    metric_value=$(echo "$metric_pair" | sed -E 's/^[^=]+=([0-9]+(\.[0-9]+)?).*/\1/' | xargs)
                    
                    # Combine prefix with metric name if the prefix exists
                    full_metric_name="$metric_name"
                    if [[ "$prefix" != "$line_content" ]]; then
                        full_metric_name="$prefix: $metric_name"
                    fi
                    
                    # Store each metric as a separate entry
                    metrics["$full_metric_name,$test_name"]="$metric_value"
                    
                    # Add to unique metrics if it's a new metric
                    if [[ ! " ${unique_metrics[@]} " =~ " ${full_metric_name} " ]]; then
                        unique_metrics+=("$full_metric_name")
                    fi
                done
            else
                # For other lines, capture the metric name and numeric value as before
                metric_name=$(echo "$line_content" | sed -E 's/([^=]+)=.*/\1/' | xargs)
                metric_value=$(echo "$line_content" | sed -E 's/^[^=]+=([0-9]+(\.[0-9]+)?).*/\1/' | xargs)
                
                # Store the metric in the associative array
                metrics["$metric_name,$test_name"]="$metric_value"
                
                # Add to unique metrics if it's a new metric
                if [[ ! " ${unique_metrics[@]} " =~ " ${metric_name} " ]]; then
                    unique_metrics+=("$metric_name")
                fi
            fi
        fi
    done < "$logfile"
done

# Output header row (Metric, then each logfile name)
echo -n "Metric" > "$output_file"
for col in "${column_headers[@]}"; do
    echo -n ",$col" >> "$output_file"
done
echo >> "$output_file"

# Output each metric row, with values for each logfile
for metric in "${unique_metrics[@]}"; do
    echo -n "$metric" >> "$output_file"
    for col in "${column_headers[@]}"; do
        # Print value if it exists, otherwise leave blank, and wrap in quotes
        value="${metrics[$metric,$col]}"
        echo -n ",${value:-}" >> "$output_file"
    done
    echo >> "$output_file"
done

echo "Consolidated results saved in $output_file"
