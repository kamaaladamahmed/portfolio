#!/usr/bin/env python
# coding: utf-8

# In[1]:


import os, shutil


# In[11]:


path = r"/Users/adamahmed/Desktop/Project Folder/"


# In[19]:


file_name = os.listdir(path)


# In[27]:


folder_names = ['csv files', 'image files', 'text files', 'pdf files']

for loop in range(0,4):
    if not os.path.exists(path + folder_names[loop]):
        os.makedirs(path + folder_names[loop])
        
for file in file_name:
    if ".csv" in file and not os.path.exists(path + "csv files/" + file):
        shutil.move(path + file, path + "csv files/" + file)
    elif ".png" in file and not os.path.exists(path + "image files/" + file):
        shutil.move(path + file, path + "image files/" + file)
    elif ".txt" in file and not os.path.exists(path + "text files/" + file):
        shutil.move(path + file, path + "text files/" + file)
    elif ".pdf" in file and not os.path.exists(path + "pdf files/" + file):
        shutil.move(path + file, path + "pdf files/" + file)


# In[ ]:




