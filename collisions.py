import sys
import pandas as pd
data = pd.read_csv(sys.argv[1], sep=" ", comment="#") 
if __name__ == '__main__':
    exit(any(data['index'].duplicated()))
