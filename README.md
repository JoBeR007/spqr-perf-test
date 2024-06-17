# SPQR Performance Test

This repository contains a performance test scripts for [SPQR](https://github.com/pg-sharding/spqr). The purpose of this helper scripts is to evaluate the performance and scalability of the SPQR under TPC-C benchmark load conditions.

## Features

- Automated performance testing using fork of [Benchbase](https://github.com/JoBeR007/benchbase-spqr/tree/spqr-support)
- Configurable test configuration to simulate different loads and usage patterns

## Getting Started

To get started with the SPQR performance test suite, follow these steps:

1. Clone the repository on the VM with SPQR router:
```
git clone https://github.com/JoBeR007/spqr-perf-test.git
```
2. Install required dependencies on SPQR router:
```
cd spqr-perf-test
bash install-router-dependencies.sh
```
3. On VM with benchmark install dependencies and build benchmark:
```
bash rebuild-bench.sh
```
4. Configure env variables needed for setup-configs.sh:
```
HOSTPORT1 - HOSTPORT6, POSTGRES_USER, POSTGRES_PASS, POSTGRES_DB, ROUTER_IP, BENCH_IP, BENCH_USER
```

5. Launch standby script in tmux or cronjob:
```
tmux new-session -s test
bash standby.sh

// Configure variables and job in crontab 
crontab -e
```
