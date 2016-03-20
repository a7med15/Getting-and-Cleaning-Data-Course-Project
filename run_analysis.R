
### Download the file and put it in the  existing working directory
  
get_files <- function(...){
  zipped_file <- "getdata_projectfiles_UCI HAR Dataset.zip"
  data_dir <- "./UCI HAR Dataset"
  
  check_files <- if(!dir.exists(data_dir) & !file.exists(zipped_file)){
    
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileURL, destfile = zipped_file ,method = "auto")
    print("secssefully downloaded")
    
  }
  
  unzp <-   if (!dir.exists(data_dir)){
    unzip(zipfile = zipped_file, exdir = getwd())
    print("secssefully unziped")
  }
  
  print("Files have been extracted in the working directory under 'UCI HAR Dataset' folder")  
  
} 




### Calling the get_files function to check if the files have been extracted in the working directory under 'UCI HAR Dataset' folder


get_files()


# load all the .text files into memory from train and test folders from the UCI HAR Dataset
#### the dataset has been downloaded and

Dataset_Path <- file.path(getwd(), "UCI HAR Dataset")
files <- list.files(Dataset_Path, recursive=TRUE)
files

### save the loaded
### Read the Activity files

ActivityTest_data  <- read.table(file.path(Dataset_Path, "test" , "Y_test.txt" ),header = FALSE)
str(ActivityTest_data)

ActivityTrain_data <- read.table(file.path(Dataset_Path, "train", "Y_train.txt"),header = FALSE)
str(ActivityTrain_data)


### Read the Subject files

SubjectTrain_data <- read.table(file.path(Dataset_Path, "train", "subject_train.txt"),header = FALSE)
str(SubjectTrain_data)

SubjectTest_data  <- read.table(file.path(Dataset_Path, "test" , "subject_test.txt"),header = FALSE)
str(SubjectTest_data)


### Read Fearures files

FeaturesTest_data  <- read.table(file.path(Dataset_Path, "test" , "X_test.txt" ),header = FALSE)
str(FeaturesTest_data)

FeaturesTrain_data <- read.table(file.path(Dataset_Path, "train", "X_train.txt"),header = FALSE)
str(FeaturesTrain_data)


### Read Fearures Names file

FeaturesNames_data <- read.table(file.path(Dataset_Path, "features.txt"), head=FALSE)
str(FeaturesNames_data)


## 1. Merges the training and the test sets to create one data set.


Subject_data  <- rbind(SubjectTrain_data,  SubjectTest_data)
str(Subject_data)
Activity_data <- rbind(ActivityTrain_data, ActivityTest_data)
str(Activity_data)
Features_data <- rbind(FeaturesTrain_data, FeaturesTest_data)
str(Features_data)


### set names to variables

names(Subject_data)<-c("Subject")
names(Subject_data)

names(Activity_data)<- c("Activity")
names(Activity_data)

names(Features_data)<- FeaturesNames_data$V2
names(Features_data)

### now we have one varibale called Activity with 10299 observatons
### and one varibale called Subject with 10299 observatons
### and 561 variable for feature with 10299 observations for each variable
### We are now going to merge columns to get the data frame Data for all data

### Combine the subject abd Activity data into two columns 
Combine_data <- cbind(Subject_data, Activity_data)
### Check names of columns for our new Combined data
names(Combine_data)

### now we are going to combine another 561 columns for the our features data
### and attachet to our Combine_data

Combine_data <- cbind(Features_data, Combine_data)

### here are the names of our new combined data columns
names(Combine_data)

names(FeaturesNames_data)


## Now for the purpose of this project we only the measurements of the mean and standard deviation for each measurement.

### we are going to look at V2 in the FeaturesNames_data which a Factor w/ 477 levels 
### and take extract all features names with 'mean()' and 'std()' 
### and store them in a new variable called 'FeaturesNames_subdata'

FeaturesNames_subdata <- FeaturesNames_data$V2[grep("mean\\(\\)|std\\(\\)", FeaturesNames_data$V2)]

str(FeaturesNames_subdata)

### now we are going to Subset the data frame 'Combined_data'
### by seleted names of Features we stored in our 'FeaturesNames_subdata'
### and stor theme in a variable called 'new_data'

Names_selected <-c(as.character(FeaturesNames_subdata), "Subject", "Activity" )
new_data <- subset(Combine_data,select=Names_selected)



###Check the structures of the data frame 'new_data' which should have only 68 variables and 10299 observations
str(new_data)


# Now we are gong tp use descriptive activity names to name the activities in the data set


### Read descriptive Activity names from “activity_labels.txt”

activity_Labels <- read.table(file.path(Dataset_Path, "activity_labels.txt"),header = FALSE)
new_data$Activity <- factor(new_data$Activity, levels = activity_Labels[,1], labels = activity_Labels[,2])
 
### check if our Activity data has been Labeled

head(new_data$Activity, n=10)
tail(new_data$Activity, n=10)

# Now we are going to label the data set with descriptive variable names.


names(new_data) <- gsub("^t", "Time", names(new_data))
names(new_data) <- gsub("^f", "Frequency", names(new_data))
names(new_data) <- gsub("Acc", "Accelerometer", names(new_data))
names(new_data) <- gsub("Gyro", "Gyroscope", names(new_data))
names(new_data) <- gsub("Mag", "Magnitude", names(new_data))
names(new_data) <- gsub("BodyBody", "Body", names(new_data))

###check

names(new_data)


# From the data set 'new_data' in in the pervious step, we are going to creates a second, independent tidy data set 
# with the average of each variable for each activity and each subject.


library(plyr);
tidydata <- aggregate(. ~Subject + Activity, new_data, mean)
tidydata <- tidydata[order(tidydata$subject,tidydata$activity),]


## Check our tidydata


str(tidydata)


#Save our tidy data into a file called 'tidydata.txt'


write.table(tidydata, file = "tidydata.txt",row.name=FALSE)



