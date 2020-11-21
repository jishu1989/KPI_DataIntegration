# Task: File Parsing and Pipelining

The store_kpi.zip attachment was downloaded and saved in the following location:
```
"/home/soumya/Documents/dataengg/store_kpi.zip"
```
I have used R to do the task.

### Unzipping the Zipped Folder

We start with unzipping the file and create a location in the source folder where the
unzipped file will be stored. The below code shows how the process of unzipping the
zipped folder is done:

**R Script**

```
zipR="/home/soumya/Documents/dataengg/store_kpi.zip"
outDir="/home/soumya/Documents/dataengg/unzip"#folder to store unzipped files
unzip(zipR,exdir=outDir)
```

### Data & Directory Structure

The data is present in hierarchical structure. The main source folder : store_kpi, contains
58 folders which are named according to the date of transaction. Each folder contains multiple
csv files. The ```.csv``` files contains store specific transaction details and named according to the store name. Each ```.csv``` file has 12 columns : containing the month, year, store, kpi , avg. daily sales, margin, bs.pcs, sales, visitors, etc.

### Loading the data
**R Script**

The idea is to extract information from all the .csv files and load them into one single dataframe. In order to do that first we list all the files in sub directories of the source file.
```
files= dir(outDir, recursive=TRUE, full.names=TRUE, pattern="\\.csv$")
```
`dir()` funtion creates a character vector for names of files or directories in the named directory. `outDir` is the directory path for the source folder. Adding the parameter `recursive=TRUE` iterates over all the directories of the source folder. `full.names=TRUE`, returns the directory path which is prepended to the file names to give a relative file path, as in:
```
"/home/soumya/Documents/dataengg/unzip/2017-12-01/1030.csv"
```
`pattern="\\.csv$"` : selects file-names which ends with `.csv` extension.

```
df_store=data.frame()

for(i in 1:length(files))
{
  df=read.csv(files[i])
  df=cbind(df,files[i])
  df_store=rbind(df_store,df)
}
```
In the above code an empty dataframe is declared: df_store. A `for-loop` is used to iterate over the file path. The df dataframe reads a single `.csv` file and stores in it.   `df=cbind(df,files[i])` is used to add an extra column containing the file path to the dataframe.
`df_store=rbind(df_store,df)` is used to append the all dataframes togather in iteration. So now all the `.csv` files from all the directories are now appended into a single dataframe.



### Data Processing
**R Script**

In order to create `Date` column we need to remove some parts of the file-path name using `gsub`. Then select part of the string using `substr` function.
```
df_store$`files[i]`= gsub("/home/soumya/Documents/dataengg/unzip/","",df_store$`files[i]`)
df_store$Date=substr(df_store$`files[i]`,1,10)
```
Now the dataframe consists of Date column so we can use this follow the transactions date wise. But there are more steps to go to make the dataframe as required in the schema. In order to do so we reshape the dataframe.

```
library(reshape2)

DAT = melt(dummy, id.vars = c("Date", "store","kpi"),measure.vars = c("days.open", "avg.daily.sales", "margin..","bs.pcs","bs..","sales","visitors","receipts"))

DF=na.omit(DAT)

DF1=DF[,c(1,2,3,5)]

DF2=dcast(DF1, Date + store ~ kpi, value.var = "value",fun.aggregate = sum)
```

By using `melt` we transform the shape of the dataframe from wide to long. Then remove the NAs. Used `dcast` to make the table wide with kpi as the column name.
```
> head(DF2)
        Date store Avg daily sales Basket size, pieces Basket size, value Days open Margin, value Receipts  Sales Visitors
1 2015-01-01  1028           14556                  11                189        18        195306     9780 207452    22508
2 2015-01-01  1029           23163                  11                226        83        720831    25225 571887    40722
3 2015-01-01  1030            5426                  11                 56        29        138853     9884 319647    32921
4 2015-01-01  1031            6113                  11                135       126         26856     5824 308871     9469
5 2015-01-01  1032            4296                   7                186        68         57116     3414  87369     2270
6 2015-01-01  1033            3738                   5                156        48         54384     2110 112698    16932
```
This dataframe can be downloaded and can be saved as result.csv , using the below code:
```
write.csv(DF2,file = "/home/soumya/Documents/dataengg/result.csv")
```

### Analytics
**R Script**

The task:2 asks to answer some analytical questions from the dataset created. Since in the dataframe the columns on which we need to perform numeric operations are automatically numeric, hence we don't need to do the type conversions.

**Average Margin value of store: 1050**
```
> mean(DF2$`Margin, value`[DF2$store=="1050"])
[1] 218666.7
```

**Highest Sales of Store : 1071 by (date & amount)**
```
> DF_1071=DF2[DF2$store=="1071",]
>
> aggregate(DF_1071$Sales,by = list(DF_1071$Date),
+           FUN = max)
      Group.1      x
1  2018-06-01  10768
2  2018-07-01  89151
3  2018-08-01 184767
4  2018-09-01  62689
5  2018-10-01  46630
6  2018-11-01 122707
7  2018-12-01  79844
8  2019-01-01 108593
9  2019-02-01 155310
10 2019-03-01  97233
11 2019-04-01  31432
12 2019-05-01 164041
13 2019-06-01 121061
14 2019-07-01 116941
15 2019-08-01 310674
16 2019-09-01 136354
17 2019-10-01 103610
18 2019-11-01 166927
19 2019-12-01 209087
```
**Average of all KPI of Store : 1066**

```
> aggregate(DF_1066[,c(3:10)], by=list(DF_1066$store),FUN=mean)
  Group.1 Avg daily sales Basket size, pieces Basket size, value Days open Margin, value Receipts    Sales Visitors
1    1066        4523.061            9.306122           130.3265  93.95918      85718.33 2501.939 108024.4 12756.02
```


