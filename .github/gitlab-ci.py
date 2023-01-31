#!/usr/bin/env python3
#
# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Paul Scheffler <paulsc@iis.ee.ethz.ch>

import os
import sys
import time
import requests

# How often to retry if no pipeline exists and period (currently: 2 min timeout)
RETRY_CNT = 12
RETRY_PERIOD = 10

# How often to poll and period (currently: 2 hour timeout)
POLL_CNT = 720
POLL_PERIOD = 10

def main():
    token = os.environ['TOKEN']
    sha = os.environ['SHA']
    pipelines = os.environ['PIPELINES']

    # Wait for pipeline to spawn
    for i in range(1,RETRY_CNT+1):
        response = requests.get(pipelines, headers={'PRIVATE-TOKEN': token}).json()
        try:
            next(p for p in response if p['sha'] == sha)
            break
        except StopIteration:
            print(f'No pipeline yet for SHA {sha} (attempt {i})')
            time.sleep(RETRY_PERIOD)
    else:
        print(f'Pipeline spawn timeout after {RETRY_CNT} attempts')
        return 2

    # Wait for pipeline to complete
    for _ in range(1,POLL_CNT+1):
        response = requests.get(pipelines, headers={'PRIVATE-TOKEN': token}).json()
        pipeline = next(p for p in response if p['sha'] == sha)
        if pipeline['status'] == 'success':
            print(f'Pipeline success! See {pipeline["web_url"]}')
            return 0
        elif pipeline['status'] == 'failed':
            print(f'Pipeline failure! See {pipeline["web_url"]}')
            return 1
        print(f'Pipeline status: {pipeline["status"]}')
    else:
        print(f'Pipeline completion timeout after {POLL_CNT} attempts; See {pipeline["web_url"]}')
        return 2


if __name__ == '__main__':
    sys.exit(main())
