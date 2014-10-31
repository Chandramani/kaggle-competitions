
# coding: utf-8

# In[2]:

import pandas as pd
import numpy as np
import os
import re
import sys
import numpy
import networkx as nxh
from pandas import read_csv
from pandas import DataFrame as df
import logging
reload(logging)
logging.basicConfig(format = u'[%(asctime)s]  %(message)s', level = logging.INFO)
from collections import Counter
from pylab import *

#### Import features and features' names

# In[3]:

f = open('data/featureList.txt')
features = f.readlines()
features = map(lambda x: x[:-1], features)


# In[4]:

filem = open('data/features.txt')
fm = filem.readlines()
fm = map(lambda x: x[:-1], fm)


# In[5]:

fmatrix = df(columns=features)

def extract(fma, user, x):
    match = re.search(r'([\w;]+);(\d+)', x)
    m = match.groups()
    fma.ix[user, m[0]] = m[1]
    
def doline(x):
    l = x.split(' ')
    fma = df(columns=features)
    for i in range(1,len(l)):
        extract(fma, l[0],l[i])
    return fma.values[0]

from multiprocessing import Pool
pool = Pool(6)

logging.info('Started parallel map')
fmatrix = df(pool.map(doline, fm),columns=features)
logging.info('Done!')

fmatrix = fmatrix.astype(float)
fmatrix.to_csv('data/fmatrix.csv',index=False)


# In[6]:

fmatrix = read_csv('data/fmatrix.csv')


#### Import egonets and training

# In[7]:

path = 'data/egonets/'
egonets =os.listdir(path)

friends = []

for fle in egonets:
    f = open(path+fle)
    lines = f.readlines()
    lines = map(lambda x: x[:-1], lines)
    
    for line in lines:
        l2 = line.split(': ')
        for sec in l2[1].split(' '):
            friends.append((fle[:-7],l2[0],sec))
        
friends = df(friends, columns=['user','friend','friend_of_friend'])

#forever_alone are people who has no friends but the main user for this egonet
#if you find someone who dont present in this table, count him as separate group (check if it legal by youself)
forever_alone = friends[friends.friend_of_friend == ''].drop(['friend_of_friend'], axis=1).reset_index().drop(['index'], axis=1).astype('float').astype('int')

friends = friends[friends.friend_of_friend != ''].reset_index().drop(['index'], axis=1).astype('float').astype('int')


# In[8]:

friends.to_csv('data/friends.csv',index=False)


# In[9]:

friends[['friend','friend_of_friend']].rename(columns={'friend':'Source','friend_of_friend':'Target'}).to_csv('data/friends_gephi.csv',index=False)


# In[10]:

path = 'data/Training/'
training = os.listdir(path)

circles = []

for fle in training:
    f = open(path+fle)
    lines = f.readlines()
    lines = map(lambda x: x[:-1], lines)
    
    for line in lines:
        l2 = line.split(': ')
        for sec in l2[1].split(' '):
            circles.append((fle[:-8],l2[0][6:],sec))
            
circles = df(circles, columns=['user','circle','friend']).astype('float').astype('int')


# In[11]:

circles.to_csv('data/circles.csv',index=False)


#### Merge info from egonets and training

# In[12]:

merged = pd.merge(friends,circles, how='left')
merged.dtypes


# In[13]:

merged.to_csv('data/friend_and_circles.csv', index=False)


# In[14]:

users = list(circles.user.unique())
train = list((Counter(map(lambda x: int(x[:-7]),egonets)) & Counter(map(lambda x: int(x[:-8]),training))).elements())
test = list((Counter(map(lambda x: int(x[:-7]),egonets)) - Counter(train)).elements())
path = 'data/egonets/'
