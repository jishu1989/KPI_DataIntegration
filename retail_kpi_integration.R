#unzipping files
zipR="/home/soumya/Documents/dataengg/store_kpi.zip"
outDir="/home/soumya/Documents/dataengg/unzip"#folder to store unzipped files
unzip(zipR,exdir=outDir)

#loading files and adding file and folder name to the dataframe
files= dir(outDir, recursive=TRUE, full.names=TRUE, pattern="\\.csv$")

df_store=data.frame()

for(i in 1:length(files))
{
  df=read.csv(files[i])
  df=cbind(df,files[i])
  df_store=rbind(df_store,df)
}


df_store$`files[i]`= gsub("/home/soumya/Documents/dataengg/unzip/","",df_store$`files[i]`)

df_store$Date=substr(df_store$`files[i]`,1,10)

#write.csv(df_store,file = "/home/soumya/Documents/dataengg/result.csv")


######analytics#####
#creating a dummy dataframe so that our original dataframe is not affected

dummy=df_store

library(reshape2)

DAT = melt(dummy, id.vars = c("Date", "store","kpi"),
           +              measure.vars = c("days.open", "avg.daily.sales", "margin..","bs.pcs","bs..","sales","visitors","receipts"))

DF=na.omit(DAT)

DF1=DF[,c(1,2,3,5)]

DF2=dcast(DF1, Date + store ~ kpi, value.var = "value",fun.aggregate = sum)

write.csv(DF2,file = "/home/soumya/Documents/dataengg/result.csv")

#dummy=na.omit(dummy)
#dummy[is.na(dummy)]=0 # remove the NAs and replaced them with 0

#calculating the average Marging of store 1050
mean(DF2$`Margin, value`[DF2$store=="1050"])

#calculating highest sales of store=1071(both date and amount)
DF_1071=DF2[DF2$store=="1071",]

aggregate(DF_1071$Sales,by = list(DF_1071$Date),
          FUN = max)


#average of all KPI store=1066
DF_1066=DF2[DF2$store=="1066",]

aggregate(DF_1066[,c(3:10)], by=list(DF_1066$store),FUN=mean)




