#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pandas as pd
import seaborn as sns
import numpy as np


# In[2]:


df = pd.read_csv(r'C:\Users\Dell\Downloads\TWO_CENTURIES_OF_UM_RACES.csv')


# In[3]:


#see the data thats been imported


# In[4]:


df.head(10)


# In[5]:


df.shape


# In[6]:


df.dtypes


# In[7]:


#Clean up data


# In[8]:


#Only want USA Races, 50k or 50Mi, 2020


# In[9]:


#Step 1 show only 50K or 50Mi


# In[10]:


#checking unique values in the 'Event distance/length' column
len(df['Event distance/length'].unique())


# In[11]:


#50mi


# In[12]:


df[df['Event distance/length'] == '50km']


# In[14]:


#combine 50k/50mi with .isin
df[(df["Event distance/length"].isin(["50km", "50mi"])) &
   (df["Year of event"] == 2020)]


# In[15]:


#Extracting the "Everglades 50 Mile Ultra Run (USA) from "Event name" column extracting USA only 
df[df["Event name"] == "Everglades 50 Mile Ultra Run (USA)"]["Event name"].str.split("(").str.get(1).str.split(")").str.get(0)


# In[17]:


#Extracting USA only
df[df["Event name"].str.split("(").str.get(1).str.split(")").str.get(0) == "USA"]


# In[18]:


#Extracting a 50k, 50mi, year = 2020, USA
df[(df["Event distance/length"].isin(["50km", "50mi"])) & 
   (df["Year of event"] == 2020) &
   (df["Event name"].str.split("(").str.get(1).str.split(")").str.get(0) == "USA") ]


# In[15]:


#second method


# In[22]:


df2 = df[(df["Event distance/length"].isin(["50km", "50mi"])) & 
            (df["Year of event"] == 2020) & 
            (df["Event name"].str.extract(r'\((.*?)\)')[0] == "USA")]


# In[23]:


df2.head(10)


# In[24]:


df2.shape


# In[25]:


#checking Event name column
df2["Event name"]


# In[26]:


#Remove (USA) from Event name
df2["Event name"].str.split("(").str.get(0)


# In[27]:


#Saving it in df2 event column
df2["Event name"] = df2["Event name"].str.split("(").str.get(0)


# In[28]:


#SECOND METHOD
df2["Event name"]


# In[29]:


#Removing a leading and trailing spaces
df2["Event name"] = df2["Event name"].astype(str).str.strip()
df2["Event name"]


# In[30]:


df2.head(10)


# In[31]:


#Clean up athlete age


# In[32]:


#calculating AGE 
df2['athlete_age'] = 2020 - df2['Athlete year of birth']

df2['athlete_age']


# In[33]:


df2['Athlete performance'].str.split(' ').str.get(0)


# In[34]:


#Drop Columns: Athlete Club, Athlete Country, Athlete year of birth, Athlete age category
df2.columns


# In[35]:


df2 = df2.drop(['Athlete club', 'Athlete country', 'Athlete year of birth', 'Athlete age category'], axis = 1)


# In[36]:


df2.head()


# In[32]:


#Clean up NULL values


# In[37]:


df2.isna().sum()


# In[38]:


#Checking the NA values in athlete_age column
df2[df2['athlete_age'].isna() == 1]


# In[39]:


df2.dropna()


# In[40]:


df2.shape


# In[41]:


#Cheak dupes


# In[42]:


df2[df2.duplicated() == True]


# In[44]:


#reset index
df2.head()


# In[45]:


df2.reset_index(drop = True)


# In[41]:


#fix dtypes


# In[46]:


df2.dtypes


# In[48]:


non_finite_values = df2['athlete_age'].isnull() | np.isinf(df2['athlete_age'])

df2 = df2[~non_finite_values]

df2['athlete_age'] = df2['athlete_age'].astype(int)


# In[49]:


df2['Athlete average speed'] = df2['Athlete average speed'].astype(float)


# In[51]:


df2.dtypes


# In[52]:


df2.head()


# In[53]:


df2.columns


# In[54]:


#Renaming the column names

df3 = df2.rename(columns = {'Year of event': 'year'
                  ,'Event dates': 'race_day'
                  , 'Event name': 'race_name'
                  ,'Event distance/length': 'race_length'
                  ,'Event number of finishers': 'race_number_of_finishers'
                  , 'Athlete performance': 'athlete_performance'
                  , 'Athlete gender': 'athlete_gender'
                  ,'Athlete average speed': 'athlete_average_speed'
                  , 'Athlete ID': 'athlete_id'
                  , 'athlete_age': 'athlete_age'
})


# In[55]:


df3 = df3[['race_day', 'race_name', 'race_length', 'race_number_of_finishers', 'athlete_id', 'athlete_gender', 'athlete_age', 'athlete_average_speed', 'year']]


# In[56]:


df3.head()


# In[57]:


#find races that ran in 2020 Sarasota | Everglades


# In[58]:


# Filter rows where 'race_name' is 'Everglades 50 Mile Ultra Run'
df3[df3['race_name'] == "Everglades 50 Mile Ultra Run"]


# In[59]:


#222509


# In[60]:


df3[df3['athlete_id'] == 222509]


# In[55]:


#charts and Graphs


# In[56]:


sns.histplot(df3['race_length'])


# In[61]:


sns.histplot(df3, x="race_length", hue= "athlete_gender")


# In[63]:


sns.displot(df3[df3["race_length"] == "50mi"]["athlete_average_speed"])


# In[67]:


sns.violinplot(data = df3, x='race_length', y='athlete_average_speed', hue='athlete_gender', split = True, inner = 'quart' , linewidth = 1)


# In[68]:


sns.lmplot(data = df3, x='athlete_age', y='athlete_average_speed', hue='athlete_gender')


# In[61]:


#Questions i want to find out from data
#'race_day', 
#'race_name', 
#'race_length', 
#'race_number_of_finishers',
#'athlete_id', 
#'athlete_gender', #
#'athlete_age', 
#'athlete_average_speed',
#'year'


# In[69]:


#Difference in speed for 50k, 50mi male to female


# In[70]:


athelete_avg_speed = df3.groupby(["race_length", "athlete_gender"], as_index=False)["athlete_average_speed"].mean().sort_values(by="athlete_average_speed", ascending = False)

sns.set(rc={'figure.figsize':(7,4)})
sns.barplot(data=athelete_avg_speed, x='race_length', y='athlete_average_speed', hue='athlete_gender')
athelete_avg_speed


# In[71]:


#What age groups are the best in the 50mi Race(20 + races min)


# In[77]:


#athlete age
avg_speed_age_group = df3.query("race_length == '50mi'").groupby(["athlete_age"], as_index=False)["athlete_average_speed"].agg(["mean", "count"]).sort_values(by="mean", ascending = False).query("count>19").head(15)
avg_speed_age_group
sns.barplot(data = avg_speed_age_group, x='athlete_age', y='mean', color = "skyblue")



# In[75]:


#count
avg_speed_age_group = df3.query("race_length == '50mi'").groupby(["athlete_age"], as_index=False)["athlete_average_speed"].agg(["mean", "count"]).sort_values(by="mean", ascending = False).query("count>19").head(15)
avg_speed_age_group
sns.barplot(data = avg_speed_age_group, x='athlete_age', y='count', color = "gold")


# In[67]:


#What age groups are the worst in the 50mi Race(20 + races min) (Show 20)


# In[78]:


#athlete age
avg_speed_age_group = df3.query("race_length == '50mi'").groupby(["athlete_age"], as_index=False)["athlete_average_speed"].agg(["mean", "count"]).sort_values(by="mean", ascending = True).query("count>9").head(15)
avg_speed_age_group
sns.barplot(data = avg_speed_age_group, x='athlete_age', y='mean', color = "skyblue")


# In[79]:


#count
avg_speed_age_group = df3.query("race_length == '50mi'").groupby(["athlete_age"], as_index=False)["athlete_average_speed"].agg(["mean", "count"]).sort_values(by="mean", ascending = True).query("count>9").head(15)
avg_speed_age_group
sns.barplot(data = avg_speed_age_group, x='athlete_age', y='count', color = "gold")


# In[70]:


#Seasons for the Data <- Slower in summer than Winter?

#Spring 3-5
#Summer 6-8
#Fall  9-6
#Winter 12-2

#Split between two decimals


# In[80]:


df3 = df3.dropna(subset=['race_day'])

#Creating a race_month column
df3['race_month'] = df3['race_day'].str.split('.').str.get(1).astype(int)
df3.head()


# In[81]:


df3['race_seasons'] = df3['race_month'].apply(lambda x: 'Winter' if x > 11 else 'Fall' if x > 8 else 'Summer' if x > 5 else 'Spring' if x > 2 else 'Winter')


# In[83]:


df3.reset_index(drop = True)
df3.head(25)


# In[84]:


seasons = df3.groupby(['race_seasons'])['athlete_average_speed'].agg(['mean', 'count']).sort_values(by = 'mean', ascending = False)
seasons

# Resetting index to make 'race_seasons' a column again
seasons = seasons.reset_index()

sns.barplot(data = seasons, x='race_seasons', y='mean', color = "skyblue")


# In[100]:


#50 miler only


# In[85]:


seasons = df3.query('race_length == "50mi"').groupby(['race_seasons'])['athlete_average_speed'].agg(['mean', 'count']).sort_values(by = 'mean', ascending = False)
seasons

# Resetting index to make 'race_seasons' a column again
seasons = seasons.reset_index()

sns.barplot(data = seasons, x='race_seasons', y='mean', color = "magenta")


# In[ ]:





# In[ ]:





# In[ ]:




