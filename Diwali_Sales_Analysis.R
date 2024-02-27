library("tidyverse")
library("ggplot2")
library("dplyr")
library("data.table") # importing the data.table package for reading CSV
library("forcats")

#Reading CSV file
# Read the CSV file with UTF-8 encoding
df <- fread("C:/Users/Dell/Downloads/Compressed/Python_Diwali_Sales_Analysis-main/Diwali Sales Data.csv", encoding = "UTF-8")
View(df)

#VIEW the structure of the data
str(df)

#view the top 6 values
head(df)

#drop unrelated/Blank columns
df <- df %>% 
  select(-c(Status, unnamed1))

str(df)

#count the number of missing values in each column
colSums(is.na(df))

#get the dimmensions of the dataframe
dim(df)

#drop the missing values (NA) from the dataframe
df <- na.omit(df)

colSums(is.na(df))

str(df)

#convert the Amount column to integer type
df$Amount <- as.integer(df$Amount)

#check the data type of the amount column
class(df$Amount)
str(df)

#get the columns names of the data
colnames(df)

#generate summary statistics for the dataframe
summary(df)

#summary statistics for specific columns
summary(df[ , c("Age", "Orders", "Amount")])

### ***************************Exploratery Data Analysis***************************
#********** Gender********
colnames(df)

#Creating a bar plot
plot <- ggplot(df, aes(x=Gender, fill=Gender)) + geom_bar()
plot <- plot + 
  geom_text(stat = "count", aes(label=stat(count)), vjust=-0.5)

plot

#SECOND METHOD

# Create the count plot
plot <- ggplot(df, aes(x = Gender, fill = Gender)) +
  geom_bar() +
  labs(x = "Gender", y = "Count") +  # Add axis labels
  theme_minimal()  # Adjust theme as desired
  
  # Display the plot
  print(plot)


#Group by Gender and calculate the sum of Amount column
sales_gen <- df %>% 
  group_by(Gender) %>% 
  summarize(Amount = sum(Amount)) %>% 
  arrange(desc(Amount))

sales_gen

plot <- ggplot(sales_gen, aes(x = Gender, y = Amount, fill=Gender)) +
  geom_bar(stat = "identity", width = 0.5) + # Use "identity" to specify the values in Amount
  labs(
    x = "Gender",
    y = "Total Sales Amount",
    title = "Total Sales Amount by Gender"
  ) +
  theme_minimal()

print(plot)

#From the above graphs we can see that most of the buyers are females and even the purchasing power of #the females  are greater  than the man

#*****************Age**********************
colnames(df)

df <- df %>% 
  rename(Age_Group="Age Group")

plot <-   ggplot(df, aes(x=Age_Group, fill=Gender)) + geom_bar(position = "dodge") +
geom_text(stat="count", aes(label = stat(count)), position=position_dodge(width = 0.5), vjust=-0.5) +
  labs(x="Age_Group",
       y="Count") +
  theme_minimal()

print(plot)

#Grouping by "Age_Group" and sum of Amount
sales_age <- df %>%
  group_by(`Age_Group`) %>%
  summarise(Amount = sum(Amount)) %>%
  arrange(desc(Amount))

sales_age

## Reorder Age Group based on the total sales amount
sales_age$"Age_Group" <- fct_reorder(sales_age$"Age_Group", sales_age$"Amount")

sales_age
#Create a bar plot
plot <- ggplot(sales_age, aes(x=Age_Group, y=Amount, fill=Age_Group)) + geom_bar(stat="identity") +
  labs(title = "Total Sales Amount by Age Group",
       x= "Age_Group",
       y= "Amount") + guides(fill=FALSE) +
  theme_minimal()

print(plot)

#From the above graphs we can see that most of the buyers are of the age group between 26-35 yrs female

colnames(df)

#total numbers of orders by top 10 states
# Grouping by State and calculating the sum of Orders
#Remove any special characters in the "State" column
df$State <- iconv(df$State, "UTF-8", "ASCII", sub = "")

sales_state <- df %>%
  group_by(State) %>%
  summarize(Orders = sum(Orders)) %>%
  arrange(desc(Orders)) %>% 
  head(10)

sales_state

## Reorder State based on the total sales orders
sales_state$"State" <- fct_reorder(sales_state$"State", sales_state$"Orders")
# Plotting the bar plot

sales_plot <- ggplot(sales_state, aes(x = State, y = Orders, fill = State)) +
  geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = 'none') +  # Rotate x-axis labels
  labs(x = "State", y = "Orders")  # Label axes

print(sales_plot)

#Total Amount/Sales by for top 10 states
sales_state <- df %>% 
  group_by(State) %>% 
  summarise(Amount = sum(Amount)) %>% 
  arrange(desc(Amount)) %>% 
  head(10)

sales_state

#Reorder State by the sales amount
sales_state$"State" <- fct_reorder(sales_state$"State", sales_state$"Amount")

sales_state

#plot the sales_state table

sales_plot <- ggplot(sales_state, aes(x = State, y = Amount, fill = State)) +
  geom_bar(stat = "identity") +
  labs(title = "Total Sales Amount by States",
       x = "State",
       y = "Amount") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = "none")  # Rotate x-axis labels

sales_plot  # Print the plot

#From above we can see that most of the orders are from Uttar Pradesh, Maharashtra and Karnataka respectively

#*************Marital Status*************
colnames(df)

# Count the occurrences of each marital status


# Count the occurrences of each marital status
df$Marital_Status <- factor(df$Marital_Status)

marital_counts <- df %>%
  count(Marital_Status)

marital_counts

# Create the plot
ggplot(marital_counts, aes(x = Marital_Status, y = n, fill=Marital_Status)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = n), vjust = -0.5) +  # Adding text labels above the bars
  labs(x = "Marital Status", y = "Count") +  # Labeling axes
  theme_minimal()  # Applying a minimal theme



#Finding out the sum of Amount column by Marital_Status and Gender
sales_state <- df %>%
  group_by(Marital_Status, Gender) %>%
  summarise(Amount = sum(Amount), .groups = 'keep') %>%
  arrange(desc(Amount))

sales_state

sales_plot <- ggplot(sales_state, aes(x=Marital_Status, y=Amount, fill=Gender)) +
  geom_bar(stat="identity", position="dodge") +
  labs(x='Marital Status', y="Amount") +
  theme_minimal()

sales_plot

# From the above graph we can see that most of the buyers are married (women) 
# and they have high purchasing power

#**********Occupation***********
occupation_counts <- df %>% 
  count(Occupation)

occupation_counts

occupation_plot <- ggplot(occupation_counts, aes(x=Occupation, y=n, fill = Occupation)) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust=1), legend.position = "none")
  

occupation_plot

sales_ocu <- df %>% 
  group_by(Occupation) %>% 
  summarise(Amount = sum(Amount)) %>% 
  arrange(desc(Amount))

sales_ocu

## Reorder Occupation  based on the total sales amount
sales_ocu$"Occupation" <- fct_reorder(sales_ocu$"Occupation", sales_ocu$"Amount")

sales_plot <- ggplot(sales_ocu, aes(x=Occupation, y=Amount, fill=Occupation)) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = "none") 

sales_plot

# From the above graph we can see that most of the buyers are working in IT,  Healthcare, Aviation sector

colnames(df)

#****Product Category****
prod_count <- df %>% 
  count(Product_Category)

prod_count

prod_plot <- ggplot(prod_count, aes(x=Product_Category, y=n, fill=Product_Category)) +
  geom_bar(stat="identity") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = "none")  #guides(fill=False)

prod_plot  

sales_state <- df %>% 
  group_by(Product_Category) %>% 
  summarise(Amount = sum(Amount)) %>% 
  arrange(desc(Amount))

sales_state

#reordering the Amount in desc
sales_state$Product_Category <- fct_reorder(sales_state$Product_Category, sales_state$Amount)

sales_plot <- ggplot(sales_state, aes(x=Product_Category, y=Amount, fill = Product_Category)) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) + 
  guides(fill = FALSE)

sales_plot

# From the above graph we can see that most of the sold products are from Food, Footwear and Electronics Category
sales_prd <- df %>% 
  group_by(Product_ID) %>% 
  summarise(Orders = sum(Orders)) %>% 
  arrange(desc(Orders)) %>% 
  head(10)

sales_prd

sales_prd$Product_ID <- fct_reorder(sales_prd$Product_ID, sales_prd$Orders)

sales_plot <- ggplot(sales_prd, aes(x=Product_ID, y=Orders, fill=Product_ID)) +
  geom_bar(stat="identity") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = "none")

sales_plot

#top 10 most sold products 
top_products <- df %>%
  group_by(Product_ID) %>%
  summarise(total_orders = sum(Orders)) %>%
  top_n(10, total_orders) %>%
  arrange(desc(total_orders))

top_products

#putting total order in descinding orders
top_products$Product_ID <- fct_reorder(top_products$Product_ID, top_products$total_orders)

prod_plot <- ggplot(top_products, aes(x=Product_ID, y=total_orders, fill=Product_ID)) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = "none") +
  ggtitle("Top 10 Most Sold Products")

 prod_plot

 #*****Conclusion*****
 
 # Married women age Group 26-35 yrs from UP, Maharastra Karnataka working in IT,
 # Healthcare and Aviation are more likely to buy products from Food, Clothing and
 #Electronics category
 



