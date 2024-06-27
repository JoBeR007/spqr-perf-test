new_order_res=$(ls -t results/tpcc_*.results.NewOrder.csv | head -1)
summary=$(ls -t results/tpcc_*.summary.json | head -1)

tpmC=$(awk -F',' '{sum += $2} END {print sum/NR * 60}' "$new_order_res")
lat_median_micro=$(jq -r '.["Latency Distribution"]["Median Latency (microseconds)"]' "$summary")
lat_avg_micro=$(jq -r '.["Latency Distribution"]["Average Latency (microseconds)"]' "$summary")
lat_75th_micro=$(jq -r '.["Latency Distribution"]["75th Percentile Latency (microseconds)"]' "$summary")
lat_90th_micro=$(jq -r '.["Latency Distribution"]["90th Percentile Latency (microseconds)"]' "$summary")
lat_95th_micro=$(jq -r '.["Latency Distribution"]["95th Percentile Latency (microseconds)"]' "$summary")
lat_99th_micro=$(jq -r '.["Latency Distribution"]["99th Percentile Latency (microseconds)"]' "$summary")
goodput=$(jq -r '.["Goodput (requests/second)"]' "$summary")

# Convert microseconds to milliseconds
lat_median=$(bc <<< "scale=2; $lat_median_micro / 1000")
lat_avg=$(bc <<< "scale=2; $lat_avg_micro / 1000")
lat_75th=$(bc <<< "scale=2; $lat_75th_micro / 1000")
lat_90th=$(bc <<< "scale=2; $lat_90th_micro / 1000")
lat_95th=$(bc <<< "scale=2; $lat_95th_micro / 1000")
lat_99th=$(bc <<< "scale=2; $lat_99th_micro / 1000")

echo "$tpmC, $lat_median, $lat_avg, $lat_75th, $lat_90th, $lat_95th, $lat_99th, $goodput"

