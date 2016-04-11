#############################################################################################################
#'Getting and Cleaning Data' Class Project - David R Scott ('Belaqua@me.com') 
# Created April, 2016, in R v3.2.4
#This program creates as its output a tidy data set called "ActivityDataSummarized.txt", which
#includes summary statistics from SmartPhones Dataset on Human Activity Recognition devices (see 
#details in the project codebook and README.md file associated with this project, at: 
#
#              https://github.com/Belacqua/DRS-Getting-and-Cleaning-Data-Project.git
#######################################################################
#DEPENDENCIES:
#This programming depends on the working directory including the following 
#files which are part of the project data package. It will NOT run correctly 
#unless these files are in the Working directory:
#  "X_test.txt"          "X_train.txt"         "y_test.txt"          "y_train.txt"
#  "subject_test.txt"    "subject_train.txt"  "activity_labels.txt" "features.txt"
#
#Part 5 alse requires the plyr package.
#######################################################################
#Please check to verify the above files are in the working directory.
dir()

#######################################################################
#PART 1:Merge the Training and Test Data into a single 'tidy' data set.
#######################################################################
#First, Read in, view and look at the structure of the Test and Training Data:

#Train
X_train <- read.table("X_train.txt", quote="\"", comment.char="")
X_train$DataUse="Train"
#View(X_train); str(X_train)

subject_train <- read.table("subject_train.txt", quote="\"", comment.char="")
names(subject_train)=c("Subject")
X_train=cbind(X_train,subject_train)
tail(X_train)

Y_train <- read.table("y_train.txt", quote="\"", comment.char="")

#Test
X_test <- read.table("X_test.txt", quote="\"", comment.char="")
X_test$DataUse="Test"
#View(X_test); str(X_test)

Y_test <- read.table("y_test.txt", quote="\"", comment.char="")
#str(Y_test); View(Y_test)

subject_test <- read.table("subject_test.txt", quote="\"", comment.char="")
names(subject_test)=c("Subject")
str(subject_test) 
X_test=cbind(X_test,subject_test)
tail(X_test)

#Next, Combine the Training and Test data sets for the X and then Y data.
X<-rbind(X_train,X_test)
#str(X); View(X) 

Y<-rbind(Y_train,Y_test)
#str(Y); View(Y)

#Next, create feature names. Read in features for X, and create them for Y, 
#and for the Data Use column (train/test) and the subject column (1-30). 
#Then add them to the data as column headers. 
#NOTE: AS mentioned above, this step accomplishes most of criteria 4 from 
#      the list at the top of the program.  
features <- read.table("features.txt", quote="\"", comment.char="")
#str(features); View(features)

#######################################################################
#PART 2: Limit to only Mean and Standard Deviaton measures. 
#######################################################################
#First, separate out the Subject data, to re-attache later after 
#limiting to the Mean and SD measures. These are listed as the 563rd column 
#in the newly combined X data set.
X.Subjects<-as.data.frame(X[,563])
str(X.Subjects)

var.index=grepl("mean()",features$V2)+grepl("std()",features$V2)
new_features<-cbind(features,var.index)
new_features<-new_features[new_features$var.index==1,1:2]
length(new_features$V2) 

#Bring in the column names for the 'Test/Train' indicator I have added to the data for reference, and 
#Subject ID, to combine with the other feature names. 
DataUseSubjectHeaders<-as.data.frame(cbind(c(562,563),c("DataUse","Subject")))

XNew<-cbind(X[,var.index],X[,562],X[,563])
#str(XNew)
final.Xfeatures<-rbind(new_features,DataUseSubjectHeaders)
#names(XNew)=final.Xfeatures$V2; head(XNew); View(XNew); str(XNew)

names(Y)=c("Activity"); head(Y)

#Next, combine X (measured data) and Y (Activity Category).
ActivityData=cbind(XNew,Y); names(ActivityData)
#str(ActivityData); View(ActivityData)

#######################################################################
#PART 3: Apply descriptive activity names to name the Activity variable   
#                               in the data set.
#######################################################################

#First, create decriptive Names for the afrom the numeric activity categories, 
# by reading in the activity labels file, renaming the headers, and merging to 
# the ActivityData file.
activity_labels <- read.table("activity_labels.txt", quote="\"", comment.char="")
names(activity_labels)=c("Activity","ActivityCategory")
#str(activity_labels);View(activity_labels)

#Chose only the activity data associated with the final column list, based on the 'mean' and 
#'standard deviation' criterion used above.
ActivityData<-merge(ActivityData,activity_labels, by.x="Activity",by.y="Activity")
ActivityData<-ActivityData[,2:83]
#tail(ActivityData); View(ActivityData); str(ActivityData)

#######################################################################
#PART 4: Label the data set with descriptive variable names.  
#######################################################################
names(ActivityData)

#This code section replaces abbreviations with actual names of the measures, via the gsub function.
#(See the codebook for more details on what these terms mean.)
names(ActivityData) <- gsub("tBodyAcc", "timeBodyAcceleration", names(ActivityData))
names(ActivityData) <- gsub("tGravityAcc", "timeGravityAcceleration", names(ActivityData))
names(ActivityData) <- gsub("tBodyGyro", "timeBodyGyroscope", names(ActivityData))
names(ActivityData) <- gsub("fBodyAcc", "frequencyBodyAcceleration", names(ActivityData))
names(ActivityData) <- gsub("fBodyGyro", "frequencyBodyGyroscope", names(ActivityData))
names(ActivityData) <- gsub("std", "StandardDeviation", names(ActivityData))
names(ActivityData) <- gsub("meanFreq", "meanFrequency", names(ActivityData))
names(ActivityData) <- gsub("fBodyBodyAccJerkMag", "frequencyBodyBodyAccelerationJerkMagnitude", names(ActivityData))
names(ActivityData) <- gsub("fBodyBodyGyroMag", "frequencyBodyBodyGyroscopeMagnitude", names(ActivityData))
names(ActivityData) <- gsub("fBodyBodyGyroJerkMag", "frequencyBodyBodyGyroscopeJerkMagnitude", names(ActivityData))
names(ActivityData) <- gsub("-", "", names(ActivityData))
names(ActivityData) <- gsub("[()]", "", names(ActivityData))

names(ActivityData)

#######################################################################
#PART 5: Create a 2nd tidy data set with the average of each variable, 
#        for each Activity and each Subject.  
#######################################################################

#Group by Activity and Subject, and write out the summarized data.
library(plyr)
ActivityDataGrouped<-group_by(ActivityData,Subject,ActivityCategory)
names(ActivityDataGrouped)

ActivityDataSummarized<-ddply(ActivityDataGrouped,c("Subject","ActivityCategory"),summarise, 
                              timeBodyAccelerationmeanXAverage=mean(timeBodyAccelerationmeanX), 
                              timeBodyAccelerationmeanYAverage=mean(timeBodyAccelerationmeanY), 
                              timeBodyAccelerationmeanZAverage=mean(timeBodyAccelerationmeanZ), 
                              timeBodyAccelerationStandardDeviationXAverage=mean(timeBodyAccelerationStandardDeviationX), 
                              timeBodyAccelerationStandardDeviationYAverage=mean(timeBodyAccelerationStandardDeviationY), 
                              timeBodyAccelerationStandardDeviationZAverage=mean(timeBodyAccelerationStandardDeviationZ), 
                              timeGravityAccelerationmeanXAverage=mean(timeGravityAccelerationmeanX), 
                              timeGravityAccelerationmeanYAverage=mean(timeGravityAccelerationmeanY), 
                              timeGravityAccelerationmeanZAverage=mean(timeGravityAccelerationmeanZ), 
                              timeGravityAccelerationStandardDeviationXAverage=mean(timeGravityAccelerationStandardDeviationX), 
                              timeGravityAccelerationStandardDeviationYAverage=mean(timeGravityAccelerationStandardDeviationY), 
                              timeGravityAccelerationStandardDeviationZAverage=mean(timeGravityAccelerationStandardDeviationZ), 
                              timeBodyAccelerationJerkmeanXAverage=mean(timeBodyAccelerationJerkmeanX), 
                              timeBodyAccelerationJerkmeanYAverage=mean(timeBodyAccelerationJerkmeanY), 
                              timeBodyAccelerationJerkmeanZAverage=mean(timeBodyAccelerationJerkmeanZ), 
                              timeBodyAccelerationJerkStandardDeviationXAverage=mean(timeBodyAccelerationJerkStandardDeviationX), 
                              timeBodyAccelerationJerkStandardDeviationYAverage=mean(timeBodyAccelerationJerkStandardDeviationY), 
                              timeBodyAccelerationJerkStandardDeviationZAverage=mean(timeBodyAccelerationJerkStandardDeviationZ), 
                              timeBodyGyroscopemeanXAverage=mean(timeBodyGyroscopemeanX), 
                              timeBodyGyroscopemeanYAverage=mean(timeBodyGyroscopemeanY), 
                              timeBodyGyroscopemeanZAverage=mean(timeBodyGyroscopemeanZ), 
                              timeBodyGyroscopeStandardDeviationXAverage=mean(timeBodyGyroscopeStandardDeviationX), 
                              timeBodyGyroscopeStandardDeviationYAverage=mean(timeBodyGyroscopeStandardDeviationY), 
                              timeBodyGyroscopeStandardDeviationZAverage=mean(timeBodyGyroscopeStandardDeviationZ), 
                              timeBodyGyroscopeJerkmeanXAverage=mean(timeBodyGyroscopeJerkmeanX), 
                              timeBodyGyroscopeJerkmeanYAverage=mean(timeBodyGyroscopeJerkmeanY), 
                              timeBodyGyroscopeJerkmeanZAverage=mean(timeBodyGyroscopeJerkmeanZ), 
                              timeBodyGyroscopeJerkStandardDeviationXAverage=mean(timeBodyGyroscopeJerkStandardDeviationX), 
                              timeBodyGyroscopeJerkStandardDeviationYAverage=mean(timeBodyGyroscopeJerkStandardDeviationY), 
                              timeBodyGyroscopeJerkStandardDeviationZAverage=mean(timeBodyGyroscopeJerkStandardDeviationZ), 
                              timeBodyAccelerationMagmeanAverage=mean(timeBodyAccelerationMagmean), 
                              timeBodyAccelerationMagStandardDeviationAverage=mean(timeBodyAccelerationMagStandardDeviation), 
                              timeGravityAccelerationMagmeanAverage=mean(timeGravityAccelerationMagmean), 
                              timeGravityAccelerationMagStandardDeviationAverage=mean(timeGravityAccelerationMagStandardDeviation), 
                              timeBodyAccelerationJerkMagmeanAverage=mean(timeBodyAccelerationJerkMagmean), 
                              timeBodyAccelerationJerkMagStandardDeviationAverage=mean(timeBodyAccelerationJerkMagStandardDeviation), 
                              timeBodyGyroscopeMagmeanAverage=mean(timeBodyGyroscopeMagmean), 
                              timeBodyGyroscopeMagStandardDeviationAverage=mean(timeBodyGyroscopeMagStandardDeviation), 
                              timeBodyGyroscopeJerkMagmeanAverage=mean(timeBodyGyroscopeJerkMagmean), 
                              timeBodyGyroscopeJerkMagStandardDeviationAverage=mean(timeBodyGyroscopeJerkMagStandardDeviation), 
                              frequencyBodyAccelerationmeanXAverage=mean(frequencyBodyAccelerationmeanX), 
                              frequencyBodyAccelerationmeanYAverage=mean(frequencyBodyAccelerationmeanY), 
                              frequencyBodyAccelerationmeanZAverage=mean(frequencyBodyAccelerationmeanZ), 
                              frequencyBodyAccelerationStandardDeviationXAverage=mean(frequencyBodyAccelerationStandardDeviationX), 
                              frequencyBodyAccelerationStandardDeviationYAverage=mean(frequencyBodyAccelerationStandardDeviationY), 
                              frequencyBodyAccelerationStandardDeviationZAverage=mean(frequencyBodyAccelerationStandardDeviationZ), 
                              frequencyBodyAccelerationmeanFrequencyXAverage=mean(frequencyBodyAccelerationmeanFrequencyX), 
                              frequencyBodyAccelerationmeanFrequencyYAverage=mean(frequencyBodyAccelerationmeanFrequencyY), 
                              frequencyBodyAccelerationmeanFrequencyZAverage=mean(frequencyBodyAccelerationmeanFrequencyZ), 
                              frequencyBodyAccelerationJerkmeanXAverage=mean(frequencyBodyAccelerationJerkmeanX), 
                              frequencyBodyAccelerationJerkmeanYAverage=mean(frequencyBodyAccelerationJerkmeanY), 
                              frequencyBodyAccelerationJerkmeanZAverage=mean(frequencyBodyAccelerationJerkmeanZ), 
                              frequencyBodyAccelerationJerkStandardDeviationXAverage=mean(frequencyBodyAccelerationJerkStandardDeviationX), 
                              frequencyBodyAccelerationJerkStandardDeviationYAverage=mean(frequencyBodyAccelerationJerkStandardDeviationY), 
                              frequencyBodyAccelerationJerkStandardDeviationZAverage=mean(frequencyBodyAccelerationJerkStandardDeviationZ), 
                              frequencyBodyAccelerationJerkmeanFrequencyXAverage=mean(frequencyBodyAccelerationJerkmeanFrequencyX), 
                              frequencyBodyAccelerationJerkmeanFrequencyYAverage=mean(frequencyBodyAccelerationJerkmeanFrequencyY), 
                              frequencyBodyAccelerationJerkmeanFrequencyZAverage=mean(frequencyBodyAccelerationJerkmeanFrequencyZ), 
                              frequencyBodyGyroscopemeanXAverage=mean(frequencyBodyGyroscopemeanX), 
                              frequencyBodyGyroscopemeanYAverage=mean(frequencyBodyGyroscopemeanY), 
                              frequencyBodyGyroscopemeanZAverage=mean(frequencyBodyGyroscopemeanZ), 
                              frequencyBodyGyroscopeStandardDeviationXAverage=mean(frequencyBodyGyroscopeStandardDeviationX), 
                              frequencyBodyGyroscopeStandardDeviationYAverage=mean(frequencyBodyGyroscopeStandardDeviationY), 
                              frequencyBodyGyroscopeStandardDeviationZAverage=mean(frequencyBodyGyroscopeStandardDeviationZ), 
                              frequencyBodyGyroscopemeanFrequencyXAverage=mean(frequencyBodyGyroscopemeanFrequencyX), 
                              frequencyBodyGyroscopemeanFrequencyYAverage=mean(frequencyBodyGyroscopemeanFrequencyY), 
                              frequencyBodyGyroscopemeanFrequencyZAverage=mean(frequencyBodyGyroscopemeanFrequencyZ), 
                              frequencyBodyAccelerationMagmeanAverage=mean(frequencyBodyAccelerationMagmean), 
                              frequencyBodyAccelerationMagStandardDeviationAverage=mean(frequencyBodyAccelerationMagStandardDeviation), 
                              frequencyBodyAccelerationMagmeanFrequencyAverage=mean(frequencyBodyAccelerationMagmeanFrequency), 
                              frequencyBodyBodyAccelerationJerkMagnitudemeanAverage=mean(frequencyBodyBodyAccelerationJerkMagnitudemean), 
                              frequencyBodyBodyAccelerationJerkMagnitudeStandardDeviationAverage=mean(frequencyBodyBodyAccelerationJerkMagnitudeStandardDeviation), 
                              frequencyBodyBodyAccelerationJerkMagnitudemeanFrequencyAverage=mean(frequencyBodyBodyAccelerationJerkMagnitudemeanFrequency), 
                              frequencyBodyBodyGyroscopeMagnitudemeanAverage=mean(frequencyBodyBodyGyroscopeMagnitudemean), 
                              frequencyBodyBodyGyroscopeMagnitudeStandardDeviationAverage=mean(frequencyBodyBodyGyroscopeMagnitudeStandardDeviation), 
                              frequencyBodyBodyGyroscopeMagnitudemeanFrequencyAverage=mean(frequencyBodyBodyGyroscopeMagnitudemeanFrequency), 
                              frequencyBodyBodyGyroscopeJerkMagnitudemeanAverage=mean(frequencyBodyBodyGyroscopeJerkMagnitudemean), 
                              frequencyBodyBodyGyroscopeJerkMagnitudeStandardDeviationAverage=mean(frequencyBodyBodyGyroscopeJerkMagnitudeStandardDeviation), 
                              frequencyBodyBodyGyroscopeJerkMagnitudemeanFrequencyAverage=mean(frequencyBodyBodyGyroscopeJerkMagnitudemeanFrequency) 
                        )
View(ActivityDataSummarized)

write.table(ActivityDataSummarized, file="ActivityDataSummarized.txt", row.names=FALSE)