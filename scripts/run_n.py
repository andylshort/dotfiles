#!/usr/bin/env python3
import os
import sys

if __name__ == "__main__":
    for run in range(0, int(sys.argv[1])):
        #print("Running " + str(sys.argv[2:]))
        
        os.system(" ".join(sys.argv[2:]))
