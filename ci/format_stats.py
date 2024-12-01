#!/usr/bin/env python3
import os
import re
import csv
import argparse

def collect_metrics(log_folder, target_metric):
    collected_data = []

    # Ensure the folder exists
    if not os.path.exists(log_folder):
        print(f"Error: Folder {log_folder} does not exist.")
        return collected_data

    # Regular expressions for core-specific and system-level metrics
    core_pattern = re.compile(rf"PERF: core(\d+):.*{target_metric}=(\S+)")
    system_pattern = re.compile(rf"PERF: .*{target_metric}=(\S+)")
    
    # Iterate through all files in the folder
    for root, _, files in os.walk(log_folder):
        for file in files:
            filepath = os.path.join(root, file)
            file_metrics = {"file": file}
            with open(filepath, 'r') as f:
                for line in f:
                    # Match core-specific metrics
                    core_match = core_pattern.search(line)
                    if core_match:
                        core_id, value = core_match.groups()
                        file_metrics[f"core{core_id}_{target_metric}"] = value
                    
                    # Match system-level metrics
                    system_match = system_pattern.search(line)
                    if system_match:
                        value = system_match.group(1)
                        file_metrics[f"system_{target_metric}"] = value

            collected_data.append(file_metrics)

    return collected_data

def save_to_csv(collected_data, output_file):
    # Collect all unique column names
    columns = set()
    for data in collected_data:
        columns.update(data.keys())

    # Ensure 'file' is the first column, followed by the rest in sorted order
    columns = ['file'] + sorted(col for col in columns if col != 'file')
    
    # Write data to CSV
    with open(output_file, 'w', newline='') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=columns)
        writer.writeheader()
        writer.writerows(collected_data)
    
    print(f"Metrics saved to {output_file}")


def main():
    import argparse

    parser = argparse.ArgumentParser(description="Extract metrics from log files and save them as a CSV.")
    parser.add_argument("log_folder", help="Path to the folder containing log files.")
    parser.add_argument("target_metric", help="The target metric to extract (e.g., IPC).")
    args = parser.parse_args()

    # Ensure the output folder exists
    output_folder = "organized_results"
    os.makedirs(output_folder, exist_ok=True)

    # Generate the output file name dynamically
    folder_name = os.path.basename(os.path.normpath(args.log_folder))
    output_file = os.path.join(output_folder, f"{folder_name}_{args.target_metric}_metrics.csv")

    collected_data = collect_metrics(args.log_folder, args.target_metric)
    save_to_csv(collected_data, output_file)



if __name__ == "__main__":
    main()

