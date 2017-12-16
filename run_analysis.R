##preliminary
require(reshape2)
require(dplyr)
require(data.table,quietly = T)
setwd("C:/Users/wuzon/Desktop/Data Science/Course 3 - Clean data/UCI HAR Dataset")
p<-getwd()
##Reading data
SubjectTrain <- fread(file.path(p, "train", "subject_train.txt"))
SubjectTest  <- fread(file.path(p, "test" , "subject_test.txt" ))
ActivityTrain <- fread(file.path(p, "train", "Y_train.txt"))
ActivityTest  <- fread(file.path(p, "test" , "Y_test.txt" ))
DataTrain<- fread(file.path(p, "train", "X_train.txt"))
DataTest<-fread(file.path(p,"test","X_test.txt"))
Subject<-rbind(SubjectTrain,SubjectTest)
setnames(Subject,"V1","subject")

##Task 1 - Merge the training and the test data sets

### step 1 - Merge the rows
Activity<-rbind(ActivityTest,ActivityTrain)
setnames(Activity,"V1","activity")
dat<-rbind(DataTrain,DataTest)
### step 2 - Merge the columns
data<-cbind(Subject,Activity,dat)
setkey(data,"subject","activity")


##Task 2 - Extract only the mean and SD
Feature<-fread(file.path(p,"features.txt"))
setnames(Feature,names(Feature),c("FeatureNum","FeatureName"))
dat<-Feature[grepl("mean\\(\\)|std\\(\\)",FeatureName)]


##Task 3 
activitylabels<-fread(file.path(p,"activity_labels.txt"))

setnames(activitylabels,names(activitylabels),c("activity","activityName"))
fullData<-merge(data,activitylabels,by="activity",all.x=TRUE)
fullData$activity<-factor(fullData$activity,levels=c(1,2,3,4,5,6),labels = activitylabels$activityNam)
finalData<-fullData[,-564]


##Task 4 - Appropriately labels the data set with descriptive variable names

###deal with the duplicated feature name by concatenate the row numbers with feature name
colName<-paste(as.character(row_number(Feature)),Feature[,FeatureName],sep="_")
subcolName<-colName[1:561]
colnames(finalData) <- c("subject", "activity",subcolName)

##Task 5 - From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
tidyData <- finalData %>%
  group_by(activity,subject) %>%
  summarise_all(funs(mean))
tidyData


##Data output
write.table(tidyData,"Course3-project",row.names=FALSE)