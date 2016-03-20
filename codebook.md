# codebook

==========
This `codebook.md` file explains the analysis that have been done in `run_analysis.R` and the variables, the data, and any transformations or work that was performed to clean up the source data to create a tidy dataset as per requirements of course project.


=========
The data used in this project is based on Human Activity Recognition Using Smartphones Dataset. A full description is available at the site where the data was obtained:
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones


### Some info about the experiment

The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities `(WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING)` wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 

You might have a look at a video of the experiment in Youtube.com that includ an example of the 6 recorded activities with one of the participants in the following link: 
http://www.youtube.com/watch?v=XOEN9W05_4A.


=========================================
The files included in `UCI HAR Dataset` are:

* `README.txt`

* `features_info.txt`: Shows information about the variables used on the feature vector.

* `features.txt`: List of all features.

* `activity_labels.txt`: Links the class labels with their activity name.

* `train/X_train.txt`: Training set.

* `train/y_train.txt`: Training labels.

* `test/X_test.txt`: Test set.

* `test/y_test.txt`: Test labels.

And the following files are available for the train and test data. Their descriptions are equivalent. 

* `train/subject_train.txt`: Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 

* `train/Inertial Signals/total_acc_x_train.txt`: The acceleration signal from the smartphone accelerometer X axis in standard gravity units 'g'. Every row shows a 128 element vector. The same description applies for the 'total_acc_x_train.txt' and 'total_acc_z_train.txt' files for the Y and Z axis. 

* `train/Inertial Signals/body_acc_x_train.txt`: The body acceleration signal obtained by subtracting the gravity from the total acceleration. 

* `train/Inertial Signals/body_gyro_x_train.txt`: The angular velocity vector measured by the gyroscope for each window sample. The units are radians/second. 


====================================
##A big picture about our data

Our task is to construct a data frame that will look like the following:

```
Variable Names  |	    Subject	          |   Activity      |	variable names from `features.txt`
..............................................................................................
Data	         | 	`subject_test.txt`   | `Y_test.txt`	  |`X_test.txt`
Data	         |  `subject_train.txt`   | `Y_train.txt`	 |`X_train.txt`
```



========
#run_analysis.R script

### Download the file and put it in the  existing working directory

The following function called `get_files()`  is to check if the files have been extracted in the working directory under `UCI HAR Dataset` folder.

The `check_files` will check if both our dataset folder and the downloaded file not exist in our directory folder then it will download the zipped data for the project into our directory.
the `unzp` will check dataset folder does not exists the it will extract the downloaded zipped file into our directory. In case that our datasets exists in our directory folder the function will just print the meeasage.


```{r}
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

```

Calling `get_files()` function. In my case I have already downloded and extracted the dataset in my directory folder. the function should only print the message at the end. 


```{r}
get_files()
```

```
## [1] "Files have been extracted in the working directory under 'UCI HAR Dataset' folder"
```

Load all the .text files into memory from train and test folders from the UCI HAR Dataset the dataset has been downloaded and

```{r}
Dataset_Path <- file.path(getwd(), "UCI HAR Dataset")
files <- list.files(Dataset_Path, recursive=TRUE)
files
```
```
##  [1] "activity_labels.txt"                         
##  [2] "features.txt"                                
##  [3] "features_info.txt"                           
##  [4] "README.txt"                                  
##  [5] "test/Inertial Signals/body_acc_x_test.txt"   
##  [6] "test/Inertial Signals/body_acc_y_test.txt"   
##  [7] "test/Inertial Signals/body_acc_z_test.txt"   
##  [8] "test/Inertial Signals/body_gyro_x_test.txt"  
##  [9] "test/Inertial Signals/body_gyro_y_test.txt"  
## [10] "test/Inertial Signals/body_gyro_z_test.txt"  
## [11] "test/Inertial Signals/total_acc_x_test.txt"  
## [12] "test/Inertial Signals/total_acc_y_test.txt"  
## [13] "test/Inertial Signals/total_acc_z_test.txt"  
## [14] "test/subject_test.txt"                       
## [15] "test/X_test.txt"                             
## [16] "test/y_test.txt"                             
## [17] "train/Inertial Signals/body_acc_x_train.txt" 
## [18] "train/Inertial Signals/body_acc_y_train.txt" 
## [19] "train/Inertial Signals/body_acc_z_train.txt" 
## [20] "train/Inertial Signals/body_gyro_x_train.txt"
## [21] "train/Inertial Signals/body_gyro_y_train.txt"
## [22] "train/Inertial Signals/body_gyro_z_train.txt"
## [23] "train/Inertial Signals/total_acc_x_train.txt"
## [24] "train/Inertial Signals/total_acc_y_train.txt"
## [25] "train/Inertial Signals/total_acc_z_train.txt"
## [26] "train/subject_train.txt"                     
## [27] "train/X_train.txt"                           
## [28] "train/y_train.txt"
```

Read the Activity files in `Y_test.txt` & `Y_train.txt` and then save them into new datset and check their structure.

```{r}
ActivityTest_data  <- read.table(file.path(Dataset_Path, "test" , "Y_test.txt" ),header = FALSE)
str(ActivityTest_data)
```
```
## 'data.frame':    2947 obs. of  1 variable:
##  $ V1: int  5 5 5 5 5 5 5 5 5 5 ...
```
```{r}
ActivityTrain_data <- read.table(file.path(Dataset_Path, "train", "Y_train.txt"),header = FALSE)
str(ActivityTrain_data)
## 'data.frame':    7352 obs. of  1 variable:
##  $ V1: int  5 5 5 5 5 5 5 5 5 5 ...
```

Read the Subject files in `subject_train.txt` & `subject_test.txt` and then save them into new datset and check their structure.

```{r}
SubjectTrain_data <- read.table(file.path(Dataset_Path, "train", "subject_train.txt"),header = FALSE)
str(SubjectTrain_data)
```
```
## 'data.frame':    7352 obs. of  1 variable:
##  $ V1: int  1 1 1 1 1 1 1 1 1 1 ...
```
```{r}
SubjectTest_data  <- read.table(file.path(Dataset_Path, "test" , "subject_test.txt"),header = FALSE)
str(SubjectTest_data)
```
```
## 'data.frame':    2947 obs. of  1 variable:
##  $ V1: int  2 2 2 2 2 2 2 2 2 2 ...
```
Read Fearures files in `X_test.txt` & `X"_train.txt` and then save them into new datset and check their structure.

```{r}
FeaturesTest_data  <- read.table(file.path(Dataset_Path, "test" , "X_test.txt" ),header = FALSE)
str(FeaturesTest_data)
```
```
## 'data.frame':    2947 obs. of  561 variables:
##  $ V1  : num  0.257 0.286 0.275 0.27 0.275 ...
##  $ V2  : num  -0.0233 -0.0132 -0.0261 -0.0326 -0.0278 ...
##  $ V3  : num  -0.0147 -0.1191 -0.1182 -0.1175 -0.1295 ...
##  $ V4  : num  -0.938 -0.975 -0.994 -0.995 -0.994 ...
##  $ V5  : num  -0.92 -0.967 -0.97 -0.973 -0.967 ...
##  $ V6  : num  -0.668 -0.945 -0.963 -0.967 -0.978 ...
##  $ V7  : num  -0.953 -0.987 -0.994 -0.995 -0.994 ...
##  $ V8  : num  -0.925 -0.968 -0.971 -0.974 -0.966 ...
##  $ V9  : num  -0.674 -0.946 -0.963 -0.969 -0.977 ...
##  $ V10 : num  -0.894 -0.894 -0.939 -0.939 -0.939 ...
##  $ V11 : num  -0.555 -0.555 -0.569 -0.569 -0.561 ...
##  $ V12 : num  -0.466 -0.806 -0.799 -0.799 -0.826 ...
##  $ V13 : num  0.717 0.768 0.848 0.848 0.849 ...
##  $ V14 : num  0.636 0.684 0.668 0.668 0.671 ...
##  $ V15 : num  0.789 0.797 0.822 0.822 0.83 ...
##  $ V16 : num  -0.878 -0.969 -0.977 -0.974 -0.975 ...
##  $ V17 : num  -0.998 -1 -1 -1 -1 ...
##  $ V18 : num  -0.998 -1 -1 -0.999 -0.999 ...
##  $ V19 : num  -0.934 -0.998 -0.999 -0.999 -0.999 ...
##  $ V20 : num  -0.976 -0.994 -0.993 -0.995 -0.993 ...
##  $ V21 : num  -0.95 -0.974 -0.974 -0.979 -0.967 ...
##  $ V22 : num  -0.83 -0.951 -0.965 -0.97 -0.976 ...
##  $ V23 : num  -0.168 -0.302 -0.618 -0.75 -0.591 ...
##  $ V24 : num  -0.379 -0.348 -0.695 -0.899 -0.74 ...
##  $ V25 : num  0.246 -0.405 -0.537 -0.554 -0.799 ...
##  $ V26 : num  0.521 0.507 0.242 0.175 0.116 ...
##  $ V27 : num  -0.4878 -0.1565 -0.115 -0.0513 -0.0289 ...
##  $ V28 : num  0.4823 0.0407 0.0327 0.0342 -0.0328 ...
##  $ V29 : num  -0.0455 0.273 0.1924 0.1536 0.2943 ...
##  $ V30 : num  0.21196 0.19757 -0.01194 0.03077 0.00063 ...
##  $ V31 : num  -0.1349 -0.1946 -0.0634 -0.1293 -0.0453 ...
##  $ V32 : num  0.131 0.411 0.471 0.446 0.168 ...
##  $ V33 : num  -0.0142 -0.3405 -0.5074 -0.4195 -0.0682 ...
##  $ V34 : num  -0.106 0.0776 0.1885 0.2715 0.0744 ...
##  $ V35 : num  0.0735 -0.084 -0.2316 -0.2258 0.0271 ...
##  $ V36 : num  -0.1715 0.0353 0.6321 0.4164 -0.1459 ...
##  $ V37 : num  0.0401 -0.0101 -0.5507 -0.2864 -0.0502 ...
##  $ V38 : num  0.077 -0.105 0.3057 -0.0638 0.2352 ...
##  $ V39 : num  -0.491 -0.429 -0.324 -0.167 0.29 ...
##  $ V40 : num  -0.709 0.399 0.28 0.545 0.458 ...
##  $ V41 : num  0.936 0.927 0.93 0.929 0.927 ...
##  $ V42 : num  -0.283 -0.289 -0.288 -0.293 -0.303 ...
##  $ V43 : num  0.115 0.153 0.146 0.143 0.138 ...
##  $ V44 : num  -0.925 -0.989 -0.996 -0.993 -0.996 ...
##  $ V45 : num  -0.937 -0.984 -0.988 -0.97 -0.971 ...
##  $ V46 : num  -0.564 -0.965 -0.982 -0.992 -0.968 ...
##  $ V47 : num  -0.93 -0.989 -0.996 -0.993 -0.996 ...
##  $ V48 : num  -0.938 -0.983 -0.989 -0.971 -0.971 ...
##  $ V49 : num  -0.606 -0.965 -0.98 -0.993 -0.969 ...
##  $ V50 : num  0.906 0.856 0.856 0.856 0.854 ...
##  $ V51 : num  -0.279 -0.305 -0.305 -0.305 -0.313 ...
##  $ V52 : num  0.153 0.153 0.139 0.136 0.134 ...
##  $ V53 : num  0.944 0.944 0.949 0.947 0.946 ...
##  $ V54 : num  -0.262 -0.262 -0.262 -0.273 -0.279 ...
##  $ V55 : num  -0.0762 0.149 0.145 0.1421 0.1309 ...
##  $ V56 : num  -0.0178 0.0577 0.0406 0.0461 0.0554 ...
##  $ V57 : num  0.829 0.806 0.812 0.809 0.804 ...
##  $ V58 : num  -0.865 -0.858 -0.86 -0.854 -0.843 ...
##  $ V59 : num  -0.968 -0.957 -0.961 -0.963 -0.965 ...
##  $ V60 : num  -0.95 -0.988 -0.996 -0.992 -0.996 ...
##  $ V61 : num  -0.946 -0.982 -0.99 -0.973 -0.972 ...
##  $ V62 : num  -0.76 -0.971 -0.979 -0.996 -0.969 ...
##  $ V63 : num  -0.425 -0.729 -0.823 -0.823 -0.83 ...
##  $ V64 : num  -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 ...
##  $ V65 : num  0.219 -0.465 -0.53 -0.7 -0.302 ...
##  $ V66 : num  -0.43 -0.51 -0.295 -0.343 -0.482 ...
##  $ V67 : num  0.431 0.525 0.305 0.359 0.539 ...
##  $ V68 : num  -0.432 -0.54 -0.315 -0.375 -0.596 ...
##  $ V69 : num  0.433 0.554 0.326 0.392 0.655 ...
##  $ V70 : num  -0.795 -0.746 -0.232 -0.233 -0.493 ...
##  $ V71 : num  0.781 0.733 0.169 0.176 0.463 ...
##  $ V72 : num  -0.78 -0.737 -0.155 -0.169 -0.465 ...
##  $ V73 : num  0.785 0.749 0.164 0.185 0.483 ...
##  $ V74 : num  -0.984 -0.845 -0.429 -0.297 -0.536 ...
##  $ V75 : num  0.987 0.869 0.44 0.304 0.544 ...
##  $ V76 : num  -0.989 -0.893 -0.451 -0.311 -0.553 ...
##  $ V77 : num  0.988 0.913 0.458 0.315 0.559 ...
##  $ V78 : num  0.981 0.945 0.548 0.986 0.998 ...
##  $ V79 : num  -0.996 -0.911 -0.335 0.653 0.916 ...
##  $ V80 : num  -0.96 -0.739 0.59 0.747 0.929 ...
##  $ V81 : num  0.072 0.0702 0.0694 0.0749 0.0784 ...
##  $ V82 : num  0.04575 -0.01788 -0.00491 0.03227 0.02228 ...
##  $ V83 : num  -0.10604 -0.00172 -0.01367 0.01214 0.00275 ...
##  $ V84 : num  -0.907 -0.949 -0.991 -0.991 -0.992 ...
##  $ V85 : num  -0.938 -0.973 -0.971 -0.973 -0.979 ...
##  $ V86 : num  -0.936 -0.978 -0.973 -0.976 -0.987 ...
##  $ V87 : num  -0.916 -0.969 -0.991 -0.99 -0.991 ...
##  $ V88 : num  -0.937 -0.974 -0.973 -0.973 -0.977 ...
##  $ V89 : num  -0.949 -0.979 -0.975 -0.978 -0.985 ...
##  $ V90 : num  -0.903 -0.915 -0.992 -0.992 -0.994 ...
##  $ V91 : num  -0.95 -0.981 -0.975 -0.975 -0.986 ...
##  $ V92 : num  -0.891 -0.978 -0.962 -0.962 -0.986 ...
##  $ V93 : num  0.898 0.898 0.994 0.994 0.994 ...
##  $ V94 : num  0.95 0.968 0.976 0.976 0.98 ...
##  $ V95 : num  0.946 0.966 0.966 0.97 0.985 ...
##  $ V96 : num  -0.931 -0.974 -0.982 -0.983 -0.987 ...
##  $ V97 : num  -0.995 -0.998 -1 -1 -1 ...
##  $ V98 : num  -0.997 -0.999 -0.999 -0.999 -1 ...
##  $ V99 : num  -0.997 -0.999 -0.999 -0.999 -1 ...
##   [list output truncated]
```
```{r}
FeaturesTrain_data <- read.table(file.path(Dataset_Path, "train", "X_train.txt"),header = FALSE)
str(FeaturesTrain_data)
```
```{r}
## 'data.frame':    7352 obs. of  561 variables:
##  $ V1  : num  0.289 0.278 0.28 0.279 0.277 ...
##  $ V2  : num  -0.0203 -0.0164 -0.0195 -0.0262 -0.0166 ...
##  $ V3  : num  -0.133 -0.124 -0.113 -0.123 -0.115 ...
##  $ V4  : num  -0.995 -0.998 -0.995 -0.996 -0.998 ...
##  $ V5  : num  -0.983 -0.975 -0.967 -0.983 -0.981 ...
##  $ V6  : num  -0.914 -0.96 -0.979 -0.991 -0.99 ...
##  $ V7  : num  -0.995 -0.999 -0.997 -0.997 -0.998 ...
##  $ V8  : num  -0.983 -0.975 -0.964 -0.983 -0.98 ...
##  $ V9  : num  -0.924 -0.958 -0.977 -0.989 -0.99 ...
##  $ V10 : num  -0.935 -0.943 -0.939 -0.939 -0.942 ...
##  $ V11 : num  -0.567 -0.558 -0.558 -0.576 -0.569 ...
##  $ V12 : num  -0.744 -0.818 -0.818 -0.83 -0.825 ...
##  $ V13 : num  0.853 0.849 0.844 0.844 0.849 ...
##  $ V14 : num  0.686 0.686 0.682 0.682 0.683 ...
##  $ V15 : num  0.814 0.823 0.839 0.838 0.838 ...
##  $ V16 : num  -0.966 -0.982 -0.983 -0.986 -0.993 ...
##  $ V17 : num  -1 -1 -1 -1 -1 ...
##  $ V18 : num  -1 -1 -1 -1 -1 ...
##  $ V19 : num  -0.995 -0.998 -0.999 -1 -1 ...
##  $ V20 : num  -0.994 -0.999 -0.997 -0.997 -0.998 ...
##  $ V21 : num  -0.988 -0.978 -0.965 -0.984 -0.981 ...
##  $ V22 : num  -0.943 -0.948 -0.975 -0.986 -0.991 ...
##  $ V23 : num  -0.408 -0.715 -0.592 -0.627 -0.787 ...
##  $ V24 : num  -0.679 -0.501 -0.486 -0.851 -0.559 ...
##  $ V25 : num  -0.602 -0.571 -0.571 -0.912 -0.761 ...
##  $ V26 : num  0.9293 0.6116 0.273 0.0614 0.3133 ...
##  $ V27 : num  -0.853 -0.3295 -0.0863 0.0748 -0.1312 ...
##  $ V28 : num  0.36 0.284 0.337 0.198 0.191 ...
##  $ V29 : num  -0.0585 0.2846 -0.1647 -0.2643 0.0869 ...
##  $ V30 : num  0.2569 0.1157 0.0172 0.0725 0.2576 ...
##  $ V31 : num  -0.2248 -0.091 -0.0745 -0.1553 -0.2725 ...
##  $ V32 : num  0.264 0.294 0.342 0.323 0.435 ...
##  $ V33 : num  -0.0952 -0.2812 -0.3326 -0.1708 -0.3154 ...
##  $ V34 : num  0.279 0.086 0.239 0.295 0.44 ...
##  $ V35 : num  -0.4651 -0.0222 -0.1362 -0.3061 -0.2691 ...
##  $ V36 : num  0.4919 -0.0167 0.1739 0.4821 0.1794 ...
##  $ V37 : num  -0.191 -0.221 -0.299 -0.47 -0.089 ...
##  $ V38 : num  0.3763 -0.0134 -0.1247 -0.3057 -0.1558 ...
##  $ V39 : num  0.4351 -0.0727 -0.1811 -0.3627 -0.1898 ...
##  $ V40 : num  0.661 0.579 0.609 0.507 0.599 ...
##  $ V41 : num  0.963 0.967 0.967 0.968 0.968 ...
##  $ V42 : num  -0.141 -0.142 -0.142 -0.144 -0.149 ...
##  $ V43 : num  0.1154 0.1094 0.1019 0.0999 0.0945 ...
##  $ V44 : num  -0.985 -0.997 -1 -0.997 -0.998 ...
##  $ V45 : num  -0.982 -0.989 -0.993 -0.981 -0.988 ...
##  $ V46 : num  -0.878 -0.932 -0.993 -0.978 -0.979 ...
##  $ V47 : num  -0.985 -0.998 -1 -0.996 -0.998 ...
##  $ V48 : num  -0.984 -0.99 -0.993 -0.981 -0.989 ...
##  $ V49 : num  -0.895 -0.933 -0.993 -0.978 -0.979 ...
##  $ V50 : num  0.892 0.892 0.892 0.894 0.894 ...
##  $ V51 : num  -0.161 -0.161 -0.164 -0.164 -0.167 ...
##  $ V52 : num  0.1247 0.1226 0.0946 0.0934 0.0917 ...
##  $ V53 : num  0.977 0.985 0.987 0.987 0.987 ...
##  $ V54 : num  -0.123 -0.115 -0.115 -0.121 -0.122 ...
##  $ V55 : num  0.0565 0.1028 0.1028 0.0958 0.0941 ...
##  $ V56 : num  -0.375 -0.383 -0.402 -0.4 -0.4 ...
##  $ V57 : num  0.899 0.908 0.909 0.911 0.912 ...
##  $ V58 : num  -0.971 -0.971 -0.97 -0.969 -0.967 ...
##  $ V59 : num  -0.976 -0.979 -0.982 -0.982 -0.984 ...
##  $ V60 : num  -0.984 -0.999 -1 -0.996 -0.998 ...
##  $ V61 : num  -0.989 -0.99 -0.992 -0.981 -0.991 ...
##  $ V62 : num  -0.918 -0.942 -0.993 -0.98 -0.98 ...
##  $ V63 : num  -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 ...
##  $ V64 : num  -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 ...
##  $ V65 : num  0.114 -0.21 -0.927 -0.596 -0.617 ...
##  $ V66 : num  -0.59042 -0.41006 0.00223 -0.06493 -0.25727 ...
##  $ V67 : num  0.5911 0.4139 0.0275 0.0754 0.2689 ...
##  $ V68 : num  -0.5918 -0.4176 -0.0567 -0.0858 -0.2807 ...
##  $ V69 : num  0.5925 0.4213 0.0855 0.0962 0.2926 ...
##  $ V70 : num  -0.745 -0.196 -0.329 -0.295 -0.167 ...
##  $ V71 : num  0.7209 0.1253 0.2705 0.2283 0.0899 ...
##  $ V72 : num  -0.7124 -0.1056 -0.2545 -0.2063 -0.0663 ...
##  $ V73 : num  0.7113 0.1091 0.2576 0.2048 0.0671 ...
##  $ V74 : num  -0.995 -0.834 -0.705 -0.385 -0.237 ...
##  $ V75 : num  0.996 0.834 0.714 0.386 0.239 ...
##  $ V76 : num  -0.996 -0.834 -0.723 -0.387 -0.241 ...
##  $ V77 : num  0.992 0.83 0.729 0.385 0.241 ...
##  $ V78 : num  0.57 -0.831 -0.181 -0.991 -0.408 ...
##  $ V79 : num  0.439 -0.866 0.338 -0.969 -0.185 ...
##  $ V80 : num  0.987 0.974 0.643 0.984 0.965 ...
##  $ V81 : num  0.078 0.074 0.0736 0.0773 0.0734 ...
##  $ V82 : num  0.005 0.00577 0.0031 0.02006 0.01912 ...
##  $ V83 : num  -0.06783 0.02938 -0.00905 -0.00986 0.01678 ...
##  $ V84 : num  -0.994 -0.996 -0.991 -0.993 -0.996 ...
##  $ V85 : num  -0.988 -0.981 -0.981 -0.988 -0.988 ...
##  $ V86 : num  -0.994 -0.992 -0.99 -0.993 -0.992 ...
##  $ V87 : num  -0.994 -0.996 -0.991 -0.994 -0.997 ...
##  $ V88 : num  -0.986 -0.979 -0.979 -0.986 -0.987 ...
##  $ V89 : num  -0.993 -0.991 -0.987 -0.991 -0.991 ...
##  $ V90 : num  -0.985 -0.995 -0.987 -0.987 -0.997 ...
##  $ V91 : num  -0.992 -0.979 -0.979 -0.992 -0.992 ...
##  $ V92 : num  -0.993 -0.992 -0.992 -0.99 -0.99 ...
##  $ V93 : num  0.99 0.993 0.988 0.988 0.994 ...
##  $ V94 : num  0.992 0.992 0.992 0.993 0.993 ...
##  $ V95 : num  0.991 0.989 0.989 0.993 0.986 ...
##  $ V96 : num  -0.994 -0.991 -0.988 -0.993 -0.994 ...
##  $ V97 : num  -1 -1 -1 -1 -1 ...
##  $ V98 : num  -1 -1 -1 -1 -1 ...
##  $ V99 : num  -1 -1 -1 -1 -1 ...
##   [list output truncated]
```

Read Fearures Names file in `features.txt` and then save it into new datset and check its structure.
```{r}
FeaturesNames_data <- read.table(file.path(Dataset_Path, "features.txt"), head=FALSE)
str(FeaturesNames_data)
```
```
## 'data.frame':    561 obs. of  2 variables:
##  $ V1: int  1 2 3 4 5 6 7 8 9 10 ...
##  $ V2: Factor w/ 477 levels "angle(tBodyAccJerkMean),gravityMean)",..: 243 244 245 250 251 252 237 238 239 240 ...
```

## 1. Merges the training and the test sets to create one data set.
```{r}
Subject_data  <- rbind(SubjectTrain_data,  SubjectTest_data)
Activity_data <- rbind(ActivityTrain_data, ActivityTest_data)
Features_data <- rbind(FeaturesTrain_data, FeaturesTest_data)
```

Set names to variables and check

```{r}
names(Subject_data)<-c("Subject")
names(Subject_data)
```
```
## [1] "Subject"
```
```{r}
names(Activity_data)<- c("Activity")
names(Activity_data)
```
```
## [1] "Activity"
```
```{r}
names(Features_data)<- FeaturesNames_data$V2
names(Features_data)
```
```
##   [1] "tBodyAcc-mean()-X"                   
##   [2] "tBodyAcc-mean()-Y"                   
##   [3] "tBodyAcc-mean()-Z"                   
##   [4] "tBodyAcc-std()-X"                    
##   [5] "tBodyAcc-std()-Y"                    
##   [6] "tBodyAcc-std()-Z"                    
##   [7] "tBodyAcc-mad()-X"                    
##   [8] "tBodyAcc-mad()-Y"                    
##   [9] "tBodyAcc-mad()-Z"                    
##  [10] "tBodyAcc-max()-X"                    
##  [11] "tBodyAcc-max()-Y"                    
##  [12] "tBodyAcc-max()-Z"                    
##  [13] "tBodyAcc-min()-X"                    
##  [14] "tBodyAcc-min()-Y"                    
##  [15] "tBodyAcc-min()-Z"                    
##  [16] "tBodyAcc-sma()"                      
##  [17] "tBodyAcc-energy()-X"                 
##  [18] "tBodyAcc-energy()-Y"                 
##  [19] "tBodyAcc-energy()-Z"                 
##  [20] "tBodyAcc-iqr()-X"                    
##  [21] "tBodyAcc-iqr()-Y"                    
##  [22] "tBodyAcc-iqr()-Z"                    
##  [23] "tBodyAcc-entropy()-X"                
##  [24] "tBodyAcc-entropy()-Y"                
##  [25] "tBodyAcc-entropy()-Z"                
##  [26] "tBodyAcc-arCoeff()-X,1"              
##  [27] "tBodyAcc-arCoeff()-X,2"              
##  [28] "tBodyAcc-arCoeff()-X,3"              
##  [29] "tBodyAcc-arCoeff()-X,4"              
##  [30] "tBodyAcc-arCoeff()-Y,1"              
##  [31] "tBodyAcc-arCoeff()-Y,2"              
##  [32] "tBodyAcc-arCoeff()-Y,3"              
##  [33] "tBodyAcc-arCoeff()-Y,4"              
##  [34] "tBodyAcc-arCoeff()-Z,1"              
##  [35] "tBodyAcc-arCoeff()-Z,2"              
##  [36] "tBodyAcc-arCoeff()-Z,3"              
##  [37] "tBodyAcc-arCoeff()-Z,4"              
##  [38] "tBodyAcc-correlation()-X,Y"          
##  [39] "tBodyAcc-correlation()-X,Z"          
##  [40] "tBodyAcc-correlation()-Y,Z"          
##  [41] "tGravityAcc-mean()-X"                
##  [42] "tGravityAcc-mean()-Y"                
##  [43] "tGravityAcc-mean()-Z"                
##  [44] "tGravityAcc-std()-X"                 
##  [45] "tGravityAcc-std()-Y"                 
##  [46] "tGravityAcc-std()-Z"                 
##  [47] "tGravityAcc-mad()-X"                 
##  [48] "tGravityAcc-mad()-Y"                 
##  [49] "tGravityAcc-mad()-Z"                 
##  [50] "tGravityAcc-max()-X"                 
##  [51] "tGravityAcc-max()-Y"                 
##  [52] "tGravityAcc-max()-Z"                 
##  [53] "tGravityAcc-min()-X"                 
##  [54] "tGravityAcc-min()-Y"                 
##  [55] "tGravityAcc-min()-Z"                 
##  [56] "tGravityAcc-sma()"                   
##  [57] "tGravityAcc-energy()-X"              
##  [58] "tGravityAcc-energy()-Y"              
##  [59] "tGravityAcc-energy()-Z"              
##  [60] "tGravityAcc-iqr()-X"                 
##  [61] "tGravityAcc-iqr()-Y"                 
##  [62] "tGravityAcc-iqr()-Z"                 
##  [63] "tGravityAcc-entropy()-X"             
##  [64] "tGravityAcc-entropy()-Y"             
##  [65] "tGravityAcc-entropy()-Z"             
##  [66] "tGravityAcc-arCoeff()-X,1"           
##  [67] "tGravityAcc-arCoeff()-X,2"           
##  [68] "tGravityAcc-arCoeff()-X,3"           
##  [69] "tGravityAcc-arCoeff()-X,4"           
##  [70] "tGravityAcc-arCoeff()-Y,1"           
##  [71] "tGravityAcc-arCoeff()-Y,2"           
##  [72] "tGravityAcc-arCoeff()-Y,3"           
##  [73] "tGravityAcc-arCoeff()-Y,4"           
##  [74] "tGravityAcc-arCoeff()-Z,1"           
##  [75] "tGravityAcc-arCoeff()-Z,2"           
##  [76] "tGravityAcc-arCoeff()-Z,3"           
##  [77] "tGravityAcc-arCoeff()-Z,4"           
##  [78] "tGravityAcc-correlation()-X,Y"       
##  [79] "tGravityAcc-correlation()-X,Z"       
##  [80] "tGravityAcc-correlation()-Y,Z"       
##  [81] "tBodyAccJerk-mean()-X"               
##  [82] "tBodyAccJerk-mean()-Y"               
##  [83] "tBodyAccJerk-mean()-Z"               
##  [84] "tBodyAccJerk-std()-X"                
##  [85] "tBodyAccJerk-std()-Y"                
##  [86] "tBodyAccJerk-std()-Z"                
##  [87] "tBodyAccJerk-mad()-X"                
##  [88] "tBodyAccJerk-mad()-Y"                
##  [89] "tBodyAccJerk-mad()-Z"                
##  [90] "tBodyAccJerk-max()-X"                
##  [91] "tBodyAccJerk-max()-Y"                
##  [92] "tBodyAccJerk-max()-Z"                
##  [93] "tBodyAccJerk-min()-X"                
##  [94] "tBodyAccJerk-min()-Y"                
##  [95] "tBodyAccJerk-min()-Z"                
##  [96] "tBodyAccJerk-sma()"                  
##  [97] "tBodyAccJerk-energy()-X"             
##  [98] "tBodyAccJerk-energy()-Y"             
##  [99] "tBodyAccJerk-energy()-Z"             
## [100] "tBodyAccJerk-iqr()-X"                
## [101] "tBodyAccJerk-iqr()-Y"                
## [102] "tBodyAccJerk-iqr()-Z"                
## [103] "tBodyAccJerk-entropy()-X"            
## [104] "tBodyAccJerk-entropy()-Y"            
## [105] "tBodyAccJerk-entropy()-Z"            
## [106] "tBodyAccJerk-arCoeff()-X,1"          
## [107] "tBodyAccJerk-arCoeff()-X,2"          
## [108] "tBodyAccJerk-arCoeff()-X,3"          
## [109] "tBodyAccJerk-arCoeff()-X,4"          
## [110] "tBodyAccJerk-arCoeff()-Y,1"          
## [111] "tBodyAccJerk-arCoeff()-Y,2"          
## [112] "tBodyAccJerk-arCoeff()-Y,3"          
## [113] "tBodyAccJerk-arCoeff()-Y,4"          
## [114] "tBodyAccJerk-arCoeff()-Z,1"          
## [115] "tBodyAccJerk-arCoeff()-Z,2"          
## [116] "tBodyAccJerk-arCoeff()-Z,3"          
## [117] "tBodyAccJerk-arCoeff()-Z,4"          
## [118] "tBodyAccJerk-correlation()-X,Y"      
## [119] "tBodyAccJerk-correlation()-X,Z"      
## [120] "tBodyAccJerk-correlation()-Y,Z"      
## [121] "tBodyGyro-mean()-X"                  
## [122] "tBodyGyro-mean()-Y"                  
## [123] "tBodyGyro-mean()-Z"                  
## [124] "tBodyGyro-std()-X"                   
## [125] "tBodyGyro-std()-Y"                   
## [126] "tBodyGyro-std()-Z"                   
## [127] "tBodyGyro-mad()-X"                   
## [128] "tBodyGyro-mad()-Y"                   
## [129] "tBodyGyro-mad()-Z"                   
## [130] "tBodyGyro-max()-X"                   
## [131] "tBodyGyro-max()-Y"                   
## [132] "tBodyGyro-max()-Z"                   
## [133] "tBodyGyro-min()-X"                   
## [134] "tBodyGyro-min()-Y"                   
## [135] "tBodyGyro-min()-Z"                   
## [136] "tBodyGyro-sma()"                     
## [137] "tBodyGyro-energy()-X"                
## [138] "tBodyGyro-energy()-Y"                
## [139] "tBodyGyro-energy()-Z"                
## [140] "tBodyGyro-iqr()-X"                   
## [141] "tBodyGyro-iqr()-Y"                   
## [142] "tBodyGyro-iqr()-Z"                   
## [143] "tBodyGyro-entropy()-X"               
## [144] "tBodyGyro-entropy()-Y"               
## [145] "tBodyGyro-entropy()-Z"               
## [146] "tBodyGyro-arCoeff()-X,1"             
## [147] "tBodyGyro-arCoeff()-X,2"             
## [148] "tBodyGyro-arCoeff()-X,3"             
## [149] "tBodyGyro-arCoeff()-X,4"             
## [150] "tBodyGyro-arCoeff()-Y,1"             
## [151] "tBodyGyro-arCoeff()-Y,2"             
## [152] "tBodyGyro-arCoeff()-Y,3"             
## [153] "tBodyGyro-arCoeff()-Y,4"             
## [154] "tBodyGyro-arCoeff()-Z,1"             
## [155] "tBodyGyro-arCoeff()-Z,2"             
## [156] "tBodyGyro-arCoeff()-Z,3"             
## [157] "tBodyGyro-arCoeff()-Z,4"             
## [158] "tBodyGyro-correlation()-X,Y"         
## [159] "tBodyGyro-correlation()-X,Z"         
## [160] "tBodyGyro-correlation()-Y,Z"         
## [161] "tBodyGyroJerk-mean()-X"              
## [162] "tBodyGyroJerk-mean()-Y"              
## [163] "tBodyGyroJerk-mean()-Z"              
## [164] "tBodyGyroJerk-std()-X"               
## [165] "tBodyGyroJerk-std()-Y"               
## [166] "tBodyGyroJerk-std()-Z"               
## [167] "tBodyGyroJerk-mad()-X"               
## [168] "tBodyGyroJerk-mad()-Y"               
## [169] "tBodyGyroJerk-mad()-Z"               
## [170] "tBodyGyroJerk-max()-X"               
## [171] "tBodyGyroJerk-max()-Y"               
## [172] "tBodyGyroJerk-max()-Z"               
## [173] "tBodyGyroJerk-min()-X"               
## [174] "tBodyGyroJerk-min()-Y"               
## [175] "tBodyGyroJerk-min()-Z"               
## [176] "tBodyGyroJerk-sma()"                 
## [177] "tBodyGyroJerk-energy()-X"            
## [178] "tBodyGyroJerk-energy()-Y"            
## [179] "tBodyGyroJerk-energy()-Z"            
## [180] "tBodyGyroJerk-iqr()-X"               
## [181] "tBodyGyroJerk-iqr()-Y"               
## [182] "tBodyGyroJerk-iqr()-Z"               
## [183] "tBodyGyroJerk-entropy()-X"           
## [184] "tBodyGyroJerk-entropy()-Y"           
## [185] "tBodyGyroJerk-entropy()-Z"           
## [186] "tBodyGyroJerk-arCoeff()-X,1"         
## [187] "tBodyGyroJerk-arCoeff()-X,2"         
## [188] "tBodyGyroJerk-arCoeff()-X,3"         
## [189] "tBodyGyroJerk-arCoeff()-X,4"         
## [190] "tBodyGyroJerk-arCoeff()-Y,1"         
## [191] "tBodyGyroJerk-arCoeff()-Y,2"         
## [192] "tBodyGyroJerk-arCoeff()-Y,3"         
## [193] "tBodyGyroJerk-arCoeff()-Y,4"         
## [194] "tBodyGyroJerk-arCoeff()-Z,1"         
## [195] "tBodyGyroJerk-arCoeff()-Z,2"         
## [196] "tBodyGyroJerk-arCoeff()-Z,3"         
## [197] "tBodyGyroJerk-arCoeff()-Z,4"         
## [198] "tBodyGyroJerk-correlation()-X,Y"     
## [199] "tBodyGyroJerk-correlation()-X,Z"     
## [200] "tBodyGyroJerk-correlation()-Y,Z"     
## [201] "tBodyAccMag-mean()"                  
## [202] "tBodyAccMag-std()"                   
## [203] "tBodyAccMag-mad()"                   
## [204] "tBodyAccMag-max()"                   
## [205] "tBodyAccMag-min()"                   
## [206] "tBodyAccMag-sma()"                   
## [207] "tBodyAccMag-energy()"                
## [208] "tBodyAccMag-iqr()"                   
## [209] "tBodyAccMag-entropy()"               
## [210] "tBodyAccMag-arCoeff()1"              
## [211] "tBodyAccMag-arCoeff()2"              
## [212] "tBodyAccMag-arCoeff()3"              
## [213] "tBodyAccMag-arCoeff()4"              
## [214] "tGravityAccMag-mean()"               
## [215] "tGravityAccMag-std()"                
## [216] "tGravityAccMag-mad()"                
## [217] "tGravityAccMag-max()"                
## [218] "tGravityAccMag-min()"                
## [219] "tGravityAccMag-sma()"                
## [220] "tGravityAccMag-energy()"             
## [221] "tGravityAccMag-iqr()"                
## [222] "tGravityAccMag-entropy()"            
## [223] "tGravityAccMag-arCoeff()1"           
## [224] "tGravityAccMag-arCoeff()2"           
## [225] "tGravityAccMag-arCoeff()3"           
## [226] "tGravityAccMag-arCoeff()4"           
## [227] "tBodyAccJerkMag-mean()"              
## [228] "tBodyAccJerkMag-std()"               
## [229] "tBodyAccJerkMag-mad()"               
## [230] "tBodyAccJerkMag-max()"               
## [231] "tBodyAccJerkMag-min()"               
## [232] "tBodyAccJerkMag-sma()"               
## [233] "tBodyAccJerkMag-energy()"            
## [234] "tBodyAccJerkMag-iqr()"               
## [235] "tBodyAccJerkMag-entropy()"           
## [236] "tBodyAccJerkMag-arCoeff()1"          
## [237] "tBodyAccJerkMag-arCoeff()2"          
## [238] "tBodyAccJerkMag-arCoeff()3"          
## [239] "tBodyAccJerkMag-arCoeff()4"          
## [240] "tBodyGyroMag-mean()"                 
## [241] "tBodyGyroMag-std()"                  
## [242] "tBodyGyroMag-mad()"                  
## [243] "tBodyGyroMag-max()"                  
## [244] "tBodyGyroMag-min()"                  
## [245] "tBodyGyroMag-sma()"                  
## [246] "tBodyGyroMag-energy()"               
## [247] "tBodyGyroMag-iqr()"                  
## [248] "tBodyGyroMag-entropy()"              
## [249] "tBodyGyroMag-arCoeff()1"             
## [250] "tBodyGyroMag-arCoeff()2"             
## [251] "tBodyGyroMag-arCoeff()3"             
## [252] "tBodyGyroMag-arCoeff()4"             
## [253] "tBodyGyroJerkMag-mean()"             
## [254] "tBodyGyroJerkMag-std()"              
## [255] "tBodyGyroJerkMag-mad()"              
## [256] "tBodyGyroJerkMag-max()"              
## [257] "tBodyGyroJerkMag-min()"              
## [258] "tBodyGyroJerkMag-sma()"              
## [259] "tBodyGyroJerkMag-energy()"           
## [260] "tBodyGyroJerkMag-iqr()"              
## [261] "tBodyGyroJerkMag-entropy()"          
## [262] "tBodyGyroJerkMag-arCoeff()1"         
## [263] "tBodyGyroJerkMag-arCoeff()2"         
## [264] "tBodyGyroJerkMag-arCoeff()3"         
## [265] "tBodyGyroJerkMag-arCoeff()4"         
## [266] "fBodyAcc-mean()-X"                   
## [267] "fBodyAcc-mean()-Y"                   
## [268] "fBodyAcc-mean()-Z"                   
## [269] "fBodyAcc-std()-X"                    
## [270] "fBodyAcc-std()-Y"                    
## [271] "fBodyAcc-std()-Z"                    
## [272] "fBodyAcc-mad()-X"                    
## [273] "fBodyAcc-mad()-Y"                    
## [274] "fBodyAcc-mad()-Z"                    
## [275] "fBodyAcc-max()-X"                    
## [276] "fBodyAcc-max()-Y"                    
## [277] "fBodyAcc-max()-Z"                    
## [278] "fBodyAcc-min()-X"                    
## [279] "fBodyAcc-min()-Y"                    
## [280] "fBodyAcc-min()-Z"                    
## [281] "fBodyAcc-sma()"                      
## [282] "fBodyAcc-energy()-X"                 
## [283] "fBodyAcc-energy()-Y"                 
## [284] "fBodyAcc-energy()-Z"                 
## [285] "fBodyAcc-iqr()-X"                    
## [286] "fBodyAcc-iqr()-Y"                    
## [287] "fBodyAcc-iqr()-Z"                    
## [288] "fBodyAcc-entropy()-X"                
## [289] "fBodyAcc-entropy()-Y"                
## [290] "fBodyAcc-entropy()-Z"                
## [291] "fBodyAcc-maxInds-X"                  
## [292] "fBodyAcc-maxInds-Y"                  
## [293] "fBodyAcc-maxInds-Z"                  
## [294] "fBodyAcc-meanFreq()-X"               
## [295] "fBodyAcc-meanFreq()-Y"               
## [296] "fBodyAcc-meanFreq()-Z"               
## [297] "fBodyAcc-skewness()-X"               
## [298] "fBodyAcc-kurtosis()-X"               
## [299] "fBodyAcc-skewness()-Y"               
## [300] "fBodyAcc-kurtosis()-Y"               
## [301] "fBodyAcc-skewness()-Z"               
## [302] "fBodyAcc-kurtosis()-Z"               
## [303] "fBodyAcc-bandsEnergy()-1,8"          
## [304] "fBodyAcc-bandsEnergy()-9,16"         
## [305] "fBodyAcc-bandsEnergy()-17,24"        
## [306] "fBodyAcc-bandsEnergy()-25,32"        
## [307] "fBodyAcc-bandsEnergy()-33,40"        
## [308] "fBodyAcc-bandsEnergy()-41,48"        
## [309] "fBodyAcc-bandsEnergy()-49,56"        
## [310] "fBodyAcc-bandsEnergy()-57,64"        
## [311] "fBodyAcc-bandsEnergy()-1,16"         
## [312] "fBodyAcc-bandsEnergy()-17,32"        
## [313] "fBodyAcc-bandsEnergy()-33,48"        
## [314] "fBodyAcc-bandsEnergy()-49,64"        
## [315] "fBodyAcc-bandsEnergy()-1,24"         
## [316] "fBodyAcc-bandsEnergy()-25,48"        
## [317] "fBodyAcc-bandsEnergy()-1,8"          
## [318] "fBodyAcc-bandsEnergy()-9,16"         
## [319] "fBodyAcc-bandsEnergy()-17,24"        
## [320] "fBodyAcc-bandsEnergy()-25,32"        
## [321] "fBodyAcc-bandsEnergy()-33,40"        
## [322] "fBodyAcc-bandsEnergy()-41,48"        
## [323] "fBodyAcc-bandsEnergy()-49,56"        
## [324] "fBodyAcc-bandsEnergy()-57,64"        
## [325] "fBodyAcc-bandsEnergy()-1,16"         
## [326] "fBodyAcc-bandsEnergy()-17,32"        
## [327] "fBodyAcc-bandsEnergy()-33,48"        
## [328] "fBodyAcc-bandsEnergy()-49,64"        
## [329] "fBodyAcc-bandsEnergy()-1,24"         
## [330] "fBodyAcc-bandsEnergy()-25,48"        
## [331] "fBodyAcc-bandsEnergy()-1,8"          
## [332] "fBodyAcc-bandsEnergy()-9,16"         
## [333] "fBodyAcc-bandsEnergy()-17,24"        
## [334] "fBodyAcc-bandsEnergy()-25,32"        
## [335] "fBodyAcc-bandsEnergy()-33,40"        
## [336] "fBodyAcc-bandsEnergy()-41,48"        
## [337] "fBodyAcc-bandsEnergy()-49,56"        
## [338] "fBodyAcc-bandsEnergy()-57,64"        
## [339] "fBodyAcc-bandsEnergy()-1,16"         
## [340] "fBodyAcc-bandsEnergy()-17,32"        
## [341] "fBodyAcc-bandsEnergy()-33,48"        
## [342] "fBodyAcc-bandsEnergy()-49,64"        
## [343] "fBodyAcc-bandsEnergy()-1,24"         
## [344] "fBodyAcc-bandsEnergy()-25,48"        
## [345] "fBodyAccJerk-mean()-X"               
## [346] "fBodyAccJerk-mean()-Y"               
## [347] "fBodyAccJerk-mean()-Z"               
## [348] "fBodyAccJerk-std()-X"                
## [349] "fBodyAccJerk-std()-Y"                
## [350] "fBodyAccJerk-std()-Z"                
## [351] "fBodyAccJerk-mad()-X"                
## [352] "fBodyAccJerk-mad()-Y"                
## [353] "fBodyAccJerk-mad()-Z"                
## [354] "fBodyAccJerk-max()-X"                
## [355] "fBodyAccJerk-max()-Y"                
## [356] "fBodyAccJerk-max()-Z"                
## [357] "fBodyAccJerk-min()-X"                
## [358] "fBodyAccJerk-min()-Y"                
## [359] "fBodyAccJerk-min()-Z"                
## [360] "fBodyAccJerk-sma()"                  
## [361] "fBodyAccJerk-energy()-X"             
## [362] "fBodyAccJerk-energy()-Y"             
## [363] "fBodyAccJerk-energy()-Z"             
## [364] "fBodyAccJerk-iqr()-X"                
## [365] "fBodyAccJerk-iqr()-Y"                
## [366] "fBodyAccJerk-iqr()-Z"                
## [367] "fBodyAccJerk-entropy()-X"            
## [368] "fBodyAccJerk-entropy()-Y"            
## [369] "fBodyAccJerk-entropy()-Z"            
## [370] "fBodyAccJerk-maxInds-X"              
## [371] "fBodyAccJerk-maxInds-Y"              
## [372] "fBodyAccJerk-maxInds-Z"              
## [373] "fBodyAccJerk-meanFreq()-X"           
## [374] "fBodyAccJerk-meanFreq()-Y"           
## [375] "fBodyAccJerk-meanFreq()-Z"           
## [376] "fBodyAccJerk-skewness()-X"           
## [377] "fBodyAccJerk-kurtosis()-X"           
## [378] "fBodyAccJerk-skewness()-Y"           
## [379] "fBodyAccJerk-kurtosis()-Y"           
## [380] "fBodyAccJerk-skewness()-Z"           
## [381] "fBodyAccJerk-kurtosis()-Z"           
## [382] "fBodyAccJerk-bandsEnergy()-1,8"      
## [383] "fBodyAccJerk-bandsEnergy()-9,16"     
## [384] "fBodyAccJerk-bandsEnergy()-17,24"    
## [385] "fBodyAccJerk-bandsEnergy()-25,32"    
## [386] "fBodyAccJerk-bandsEnergy()-33,40"    
## [387] "fBodyAccJerk-bandsEnergy()-41,48"    
## [388] "fBodyAccJerk-bandsEnergy()-49,56"    
## [389] "fBodyAccJerk-bandsEnergy()-57,64"    
## [390] "fBodyAccJerk-bandsEnergy()-1,16"     
## [391] "fBodyAccJerk-bandsEnergy()-17,32"    
## [392] "fBodyAccJerk-bandsEnergy()-33,48"    
## [393] "fBodyAccJerk-bandsEnergy()-49,64"    
## [394] "fBodyAccJerk-bandsEnergy()-1,24"     
## [395] "fBodyAccJerk-bandsEnergy()-25,48"    
## [396] "fBodyAccJerk-bandsEnergy()-1,8"      
## [397] "fBodyAccJerk-bandsEnergy()-9,16"     
## [398] "fBodyAccJerk-bandsEnergy()-17,24"    
## [399] "fBodyAccJerk-bandsEnergy()-25,32"    
## [400] "fBodyAccJerk-bandsEnergy()-33,40"    
## [401] "fBodyAccJerk-bandsEnergy()-41,48"    
## [402] "fBodyAccJerk-bandsEnergy()-49,56"    
## [403] "fBodyAccJerk-bandsEnergy()-57,64"    
## [404] "fBodyAccJerk-bandsEnergy()-1,16"     
## [405] "fBodyAccJerk-bandsEnergy()-17,32"    
## [406] "fBodyAccJerk-bandsEnergy()-33,48"    
## [407] "fBodyAccJerk-bandsEnergy()-49,64"    
## [408] "fBodyAccJerk-bandsEnergy()-1,24"     
## [409] "fBodyAccJerk-bandsEnergy()-25,48"    
## [410] "fBodyAccJerk-bandsEnergy()-1,8"      
## [411] "fBodyAccJerk-bandsEnergy()-9,16"     
## [412] "fBodyAccJerk-bandsEnergy()-17,24"    
## [413] "fBodyAccJerk-bandsEnergy()-25,32"    
## [414] "fBodyAccJerk-bandsEnergy()-33,40"    
## [415] "fBodyAccJerk-bandsEnergy()-41,48"    
## [416] "fBodyAccJerk-bandsEnergy()-49,56"    
## [417] "fBodyAccJerk-bandsEnergy()-57,64"    
## [418] "fBodyAccJerk-bandsEnergy()-1,16"     
## [419] "fBodyAccJerk-bandsEnergy()-17,32"    
## [420] "fBodyAccJerk-bandsEnergy()-33,48"    
## [421] "fBodyAccJerk-bandsEnergy()-49,64"    
## [422] "fBodyAccJerk-bandsEnergy()-1,24"     
## [423] "fBodyAccJerk-bandsEnergy()-25,48"    
## [424] "fBodyGyro-mean()-X"                  
## [425] "fBodyGyro-mean()-Y"                  
## [426] "fBodyGyro-mean()-Z"                  
## [427] "fBodyGyro-std()-X"                   
## [428] "fBodyGyro-std()-Y"                   
## [429] "fBodyGyro-std()-Z"                   
## [430] "fBodyGyro-mad()-X"                   
## [431] "fBodyGyro-mad()-Y"                   
## [432] "fBodyGyro-mad()-Z"                   
## [433] "fBodyGyro-max()-X"                   
## [434] "fBodyGyro-max()-Y"                   
## [435] "fBodyGyro-max()-Z"                   
## [436] "fBodyGyro-min()-X"                   
## [437] "fBodyGyro-min()-Y"                   
## [438] "fBodyGyro-min()-Z"                   
## [439] "fBodyGyro-sma()"                     
## [440] "fBodyGyro-energy()-X"                
## [441] "fBodyGyro-energy()-Y"                
## [442] "fBodyGyro-energy()-Z"                
## [443] "fBodyGyro-iqr()-X"                   
## [444] "fBodyGyro-iqr()-Y"                   
## [445] "fBodyGyro-iqr()-Z"                   
## [446] "fBodyGyro-entropy()-X"               
## [447] "fBodyGyro-entropy()-Y"               
## [448] "fBodyGyro-entropy()-Z"               
## [449] "fBodyGyro-maxInds-X"                 
## [450] "fBodyGyro-maxInds-Y"                 
## [451] "fBodyGyro-maxInds-Z"                 
## [452] "fBodyGyro-meanFreq()-X"              
## [453] "fBodyGyro-meanFreq()-Y"              
## [454] "fBodyGyro-meanFreq()-Z"              
## [455] "fBodyGyro-skewness()-X"              
## [456] "fBodyGyro-kurtosis()-X"              
## [457] "fBodyGyro-skewness()-Y"              
## [458] "fBodyGyro-kurtosis()-Y"              
## [459] "fBodyGyro-skewness()-Z"              
## [460] "fBodyGyro-kurtosis()-Z"              
## [461] "fBodyGyro-bandsEnergy()-1,8"         
## [462] "fBodyGyro-bandsEnergy()-9,16"        
## [463] "fBodyGyro-bandsEnergy()-17,24"       
## [464] "fBodyGyro-bandsEnergy()-25,32"       
## [465] "fBodyGyro-bandsEnergy()-33,40"       
## [466] "fBodyGyro-bandsEnergy()-41,48"       
## [467] "fBodyGyro-bandsEnergy()-49,56"       
## [468] "fBodyGyro-bandsEnergy()-57,64"       
## [469] "fBodyGyro-bandsEnergy()-1,16"        
## [470] "fBodyGyro-bandsEnergy()-17,32"       
## [471] "fBodyGyro-bandsEnergy()-33,48"       
## [472] "fBodyGyro-bandsEnergy()-49,64"       
## [473] "fBodyGyro-bandsEnergy()-1,24"        
## [474] "fBodyGyro-bandsEnergy()-25,48"       
## [475] "fBodyGyro-bandsEnergy()-1,8"         
## [476] "fBodyGyro-bandsEnergy()-9,16"        
## [477] "fBodyGyro-bandsEnergy()-17,24"       
## [478] "fBodyGyro-bandsEnergy()-25,32"       
## [479] "fBodyGyro-bandsEnergy()-33,40"       
## [480] "fBodyGyro-bandsEnergy()-41,48"       
## [481] "fBodyGyro-bandsEnergy()-49,56"       
## [482] "fBodyGyro-bandsEnergy()-57,64"       
## [483] "fBodyGyro-bandsEnergy()-1,16"        
## [484] "fBodyGyro-bandsEnergy()-17,32"       
## [485] "fBodyGyro-bandsEnergy()-33,48"       
## [486] "fBodyGyro-bandsEnergy()-49,64"       
## [487] "fBodyGyro-bandsEnergy()-1,24"        
## [488] "fBodyGyro-bandsEnergy()-25,48"       
## [489] "fBodyGyro-bandsEnergy()-1,8"         
## [490] "fBodyGyro-bandsEnergy()-9,16"        
## [491] "fBodyGyro-bandsEnergy()-17,24"       
## [492] "fBodyGyro-bandsEnergy()-25,32"       
## [493] "fBodyGyro-bandsEnergy()-33,40"       
## [494] "fBodyGyro-bandsEnergy()-41,48"       
## [495] "fBodyGyro-bandsEnergy()-49,56"       
## [496] "fBodyGyro-bandsEnergy()-57,64"       
## [497] "fBodyGyro-bandsEnergy()-1,16"        
## [498] "fBodyGyro-bandsEnergy()-17,32"       
## [499] "fBodyGyro-bandsEnergy()-33,48"       
## [500] "fBodyGyro-bandsEnergy()-49,64"       
## [501] "fBodyGyro-bandsEnergy()-1,24"        
## [502] "fBodyGyro-bandsEnergy()-25,48"       
## [503] "fBodyAccMag-mean()"                  
## [504] "fBodyAccMag-std()"                   
## [505] "fBodyAccMag-mad()"                   
## [506] "fBodyAccMag-max()"                   
## [507] "fBodyAccMag-min()"                   
## [508] "fBodyAccMag-sma()"                   
## [509] "fBodyAccMag-energy()"                
## [510] "fBodyAccMag-iqr()"                   
## [511] "fBodyAccMag-entropy()"               
## [512] "fBodyAccMag-maxInds"                 
## [513] "fBodyAccMag-meanFreq()"              
## [514] "fBodyAccMag-skewness()"              
## [515] "fBodyAccMag-kurtosis()"              
## [516] "fBodyBodyAccJerkMag-mean()"          
## [517] "fBodyBodyAccJerkMag-std()"           
## [518] "fBodyBodyAccJerkMag-mad()"           
## [519] "fBodyBodyAccJerkMag-max()"           
## [520] "fBodyBodyAccJerkMag-min()"           
## [521] "fBodyBodyAccJerkMag-sma()"           
## [522] "fBodyBodyAccJerkMag-energy()"        
## [523] "fBodyBodyAccJerkMag-iqr()"           
## [524] "fBodyBodyAccJerkMag-entropy()"       
## [525] "fBodyBodyAccJerkMag-maxInds"         
## [526] "fBodyBodyAccJerkMag-meanFreq()"      
## [527] "fBodyBodyAccJerkMag-skewness()"      
## [528] "fBodyBodyAccJerkMag-kurtosis()"      
## [529] "fBodyBodyGyroMag-mean()"             
## [530] "fBodyBodyGyroMag-std()"              
## [531] "fBodyBodyGyroMag-mad()"              
## [532] "fBodyBodyGyroMag-max()"              
## [533] "fBodyBodyGyroMag-min()"              
## [534] "fBodyBodyGyroMag-sma()"              
## [535] "fBodyBodyGyroMag-energy()"           
## [536] "fBodyBodyGyroMag-iqr()"              
## [537] "fBodyBodyGyroMag-entropy()"          
## [538] "fBodyBodyGyroMag-maxInds"            
## [539] "fBodyBodyGyroMag-meanFreq()"         
## [540] "fBodyBodyGyroMag-skewness()"         
## [541] "fBodyBodyGyroMag-kurtosis()"         
## [542] "fBodyBodyGyroJerkMag-mean()"         
## [543] "fBodyBodyGyroJerkMag-std()"          
## [544] "fBodyBodyGyroJerkMag-mad()"          
## [545] "fBodyBodyGyroJerkMag-max()"          
## [546] "fBodyBodyGyroJerkMag-min()"          
## [547] "fBodyBodyGyroJerkMag-sma()"          
## [548] "fBodyBodyGyroJerkMag-energy()"       
## [549] "fBodyBodyGyroJerkMag-iqr()"          
## [550] "fBodyBodyGyroJerkMag-entropy()"      
## [551] "fBodyBodyGyroJerkMag-maxInds"        
## [552] "fBodyBodyGyroJerkMag-meanFreq()"     
## [553] "fBodyBodyGyroJerkMag-skewness()"     
## [554] "fBodyBodyGyroJerkMag-kurtosis()"     
## [555] "angle(tBodyAccMean,gravity)"         
## [556] "angle(tBodyAccJerkMean),gravityMean)"
## [557] "angle(tBodyGyroMean,gravityMean)"    
## [558] "angle(tBodyGyroJerkMean,gravityMean)"
## [559] "angle(X,gravityMean)"                
## [560] "angle(Y,gravityMean)"                
## [561] "angle(Z,gravityMean)"
```

##### Merge columns to get the data frame Data for all data

Now we have one varibale called `Activity` with 10299 observatons and one varibale called `Subject` with 10299 observatons and 561 variable for `feature` with 10299 observations for each variable We are now going to merge columns to get the data frame for all data.

Combine the subject abd Activity data into two columns and check names of columns for our new combined data in `combine_data`
```{r}
Combine_data <- cbind(Subject_data, Activity_data)
names(Combine_data)
```
```
## [1] "Subject"  "Activity"
```

Now we are going to combine another 561 columns for the our features data and attachet to our `Combine_data`

```{r}
Combine_data <- cbind(Features_data, Combine_data)
```

Here are the names of our new `combine_data` columns

```{r}
names(Combine_data)
```
```
##   [1] "tBodyAcc-mean()-X"                   
##   [2] "tBodyAcc-mean()-Y"                   
##   [3] "tBodyAcc-mean()-Z"                   
##   [4] "tBodyAcc-std()-X"                    
##   [5] "tBodyAcc-std()-Y"                    
##   [6] "tBodyAcc-std()-Z"                    
##   [7] "tBodyAcc-mad()-X"                    
##   [8] "tBodyAcc-mad()-Y"                    
##   [9] "tBodyAcc-mad()-Z"                    
##  [10] "tBodyAcc-max()-X"                    
##  [11] "tBodyAcc-max()-Y"                    
##  [12] "tBodyAcc-max()-Z"                    
##  [13] "tBodyAcc-min()-X"                    
##  [14] "tBodyAcc-min()-Y"                    
##  [15] "tBodyAcc-min()-Z"                    
##  [16] "tBodyAcc-sma()"                      
##  [17] "tBodyAcc-energy()-X"                 
##  [18] "tBodyAcc-energy()-Y"                 
##  [19] "tBodyAcc-energy()-Z"                 
##  [20] "tBodyAcc-iqr()-X"                    
##  [21] "tBodyAcc-iqr()-Y"                    
##  [22] "tBodyAcc-iqr()-Z"                    
##  [23] "tBodyAcc-entropy()-X"                
##  [24] "tBodyAcc-entropy()-Y"                
##  [25] "tBodyAcc-entropy()-Z"                
##  [26] "tBodyAcc-arCoeff()-X,1"              
##  [27] "tBodyAcc-arCoeff()-X,2"              
##  [28] "tBodyAcc-arCoeff()-X,3"              
##  [29] "tBodyAcc-arCoeff()-X,4"              
##  [30] "tBodyAcc-arCoeff()-Y,1"              
##  [31] "tBodyAcc-arCoeff()-Y,2"              
##  [32] "tBodyAcc-arCoeff()-Y,3"              
##  [33] "tBodyAcc-arCoeff()-Y,4"              
##  [34] "tBodyAcc-arCoeff()-Z,1"              
##  [35] "tBodyAcc-arCoeff()-Z,2"              
##  [36] "tBodyAcc-arCoeff()-Z,3"              
##  [37] "tBodyAcc-arCoeff()-Z,4"              
##  [38] "tBodyAcc-correlation()-X,Y"          
##  [39] "tBodyAcc-correlation()-X,Z"          
##  [40] "tBodyAcc-correlation()-Y,Z"          
##  [41] "tGravityAcc-mean()-X"                
##  [42] "tGravityAcc-mean()-Y"                
##  [43] "tGravityAcc-mean()-Z"                
##  [44] "tGravityAcc-std()-X"                 
##  [45] "tGravityAcc-std()-Y"                 
##  [46] "tGravityAcc-std()-Z"                 
##  [47] "tGravityAcc-mad()-X"                 
##  [48] "tGravityAcc-mad()-Y"                 
##  [49] "tGravityAcc-mad()-Z"                 
##  [50] "tGravityAcc-max()-X"                 
##  [51] "tGravityAcc-max()-Y"                 
##  [52] "tGravityAcc-max()-Z"                 
##  [53] "tGravityAcc-min()-X"                 
##  [54] "tGravityAcc-min()-Y"                 
##  [55] "tGravityAcc-min()-Z"                 
##  [56] "tGravityAcc-sma()"                   
##  [57] "tGravityAcc-energy()-X"              
##  [58] "tGravityAcc-energy()-Y"              
##  [59] "tGravityAcc-energy()-Z"              
##  [60] "tGravityAcc-iqr()-X"                 
##  [61] "tGravityAcc-iqr()-Y"                 
##  [62] "tGravityAcc-iqr()-Z"                 
##  [63] "tGravityAcc-entropy()-X"             
##  [64] "tGravityAcc-entropy()-Y"             
##  [65] "tGravityAcc-entropy()-Z"             
##  [66] "tGravityAcc-arCoeff()-X,1"           
##  [67] "tGravityAcc-arCoeff()-X,2"           
##  [68] "tGravityAcc-arCoeff()-X,3"           
##  [69] "tGravityAcc-arCoeff()-X,4"           
##  [70] "tGravityAcc-arCoeff()-Y,1"           
##  [71] "tGravityAcc-arCoeff()-Y,2"           
##  [72] "tGravityAcc-arCoeff()-Y,3"           
##  [73] "tGravityAcc-arCoeff()-Y,4"           
##  [74] "tGravityAcc-arCoeff()-Z,1"           
##  [75] "tGravityAcc-arCoeff()-Z,2"           
##  [76] "tGravityAcc-arCoeff()-Z,3"           
##  [77] "tGravityAcc-arCoeff()-Z,4"           
##  [78] "tGravityAcc-correlation()-X,Y"       
##  [79] "tGravityAcc-correlation()-X,Z"       
##  [80] "tGravityAcc-correlation()-Y,Z"       
##  [81] "tBodyAccJerk-mean()-X"               
##  [82] "tBodyAccJerk-mean()-Y"               
##  [83] "tBodyAccJerk-mean()-Z"               
##  [84] "tBodyAccJerk-std()-X"                
##  [85] "tBodyAccJerk-std()-Y"                
##  [86] "tBodyAccJerk-std()-Z"                
##  [87] "tBodyAccJerk-mad()-X"                
##  [88] "tBodyAccJerk-mad()-Y"                
##  [89] "tBodyAccJerk-mad()-Z"                
##  [90] "tBodyAccJerk-max()-X"                
##  [91] "tBodyAccJerk-max()-Y"                
##  [92] "tBodyAccJerk-max()-Z"                
##  [93] "tBodyAccJerk-min()-X"                
##  [94] "tBodyAccJerk-min()-Y"                
##  [95] "tBodyAccJerk-min()-Z"                
##  [96] "tBodyAccJerk-sma()"                  
##  [97] "tBodyAccJerk-energy()-X"             
##  [98] "tBodyAccJerk-energy()-Y"             
##  [99] "tBodyAccJerk-energy()-Z"             
## [100] "tBodyAccJerk-iqr()-X"                
## [101] "tBodyAccJerk-iqr()-Y"                
## [102] "tBodyAccJerk-iqr()-Z"                
## [103] "tBodyAccJerk-entropy()-X"            
## [104] "tBodyAccJerk-entropy()-Y"            
## [105] "tBodyAccJerk-entropy()-Z"            
## [106] "tBodyAccJerk-arCoeff()-X,1"          
## [107] "tBodyAccJerk-arCoeff()-X,2"          
## [108] "tBodyAccJerk-arCoeff()-X,3"          
## [109] "tBodyAccJerk-arCoeff()-X,4"          
## [110] "tBodyAccJerk-arCoeff()-Y,1"          
## [111] "tBodyAccJerk-arCoeff()-Y,2"          
## [112] "tBodyAccJerk-arCoeff()-Y,3"          
## [113] "tBodyAccJerk-arCoeff()-Y,4"          
## [114] "tBodyAccJerk-arCoeff()-Z,1"          
## [115] "tBodyAccJerk-arCoeff()-Z,2"          
## [116] "tBodyAccJerk-arCoeff()-Z,3"          
## [117] "tBodyAccJerk-arCoeff()-Z,4"          
## [118] "tBodyAccJerk-correlation()-X,Y"      
## [119] "tBodyAccJerk-correlation()-X,Z"      
## [120] "tBodyAccJerk-correlation()-Y,Z"      
## [121] "tBodyGyro-mean()-X"                  
## [122] "tBodyGyro-mean()-Y"                  
## [123] "tBodyGyro-mean()-Z"                  
## [124] "tBodyGyro-std()-X"                   
## [125] "tBodyGyro-std()-Y"                   
## [126] "tBodyGyro-std()-Z"                   
## [127] "tBodyGyro-mad()-X"                   
## [128] "tBodyGyro-mad()-Y"                   
## [129] "tBodyGyro-mad()-Z"                   
## [130] "tBodyGyro-max()-X"                   
## [131] "tBodyGyro-max()-Y"                   
## [132] "tBodyGyro-max()-Z"                   
## [133] "tBodyGyro-min()-X"                   
## [134] "tBodyGyro-min()-Y"                   
## [135] "tBodyGyro-min()-Z"                   
## [136] "tBodyGyro-sma()"                     
## [137] "tBodyGyro-energy()-X"                
## [138] "tBodyGyro-energy()-Y"                
## [139] "tBodyGyro-energy()-Z"                
## [140] "tBodyGyro-iqr()-X"                   
## [141] "tBodyGyro-iqr()-Y"                   
## [142] "tBodyGyro-iqr()-Z"                   
## [143] "tBodyGyro-entropy()-X"               
## [144] "tBodyGyro-entropy()-Y"               
## [145] "tBodyGyro-entropy()-Z"               
## [146] "tBodyGyro-arCoeff()-X,1"             
## [147] "tBodyGyro-arCoeff()-X,2"             
## [148] "tBodyGyro-arCoeff()-X,3"             
## [149] "tBodyGyro-arCoeff()-X,4"             
## [150] "tBodyGyro-arCoeff()-Y,1"             
## [151] "tBodyGyro-arCoeff()-Y,2"             
## [152] "tBodyGyro-arCoeff()-Y,3"             
## [153] "tBodyGyro-arCoeff()-Y,4"             
## [154] "tBodyGyro-arCoeff()-Z,1"             
## [155] "tBodyGyro-arCoeff()-Z,2"             
## [156] "tBodyGyro-arCoeff()-Z,3"             
## [157] "tBodyGyro-arCoeff()-Z,4"             
## [158] "tBodyGyro-correlation()-X,Y"         
## [159] "tBodyGyro-correlation()-X,Z"         
## [160] "tBodyGyro-correlation()-Y,Z"         
## [161] "tBodyGyroJerk-mean()-X"              
## [162] "tBodyGyroJerk-mean()-Y"              
## [163] "tBodyGyroJerk-mean()-Z"              
## [164] "tBodyGyroJerk-std()-X"               
## [165] "tBodyGyroJerk-std()-Y"               
## [166] "tBodyGyroJerk-std()-Z"               
## [167] "tBodyGyroJerk-mad()-X"               
## [168] "tBodyGyroJerk-mad()-Y"               
## [169] "tBodyGyroJerk-mad()-Z"               
## [170] "tBodyGyroJerk-max()-X"               
## [171] "tBodyGyroJerk-max()-Y"               
## [172] "tBodyGyroJerk-max()-Z"               
## [173] "tBodyGyroJerk-min()-X"               
## [174] "tBodyGyroJerk-min()-Y"               
## [175] "tBodyGyroJerk-min()-Z"               
## [176] "tBodyGyroJerk-sma()"                 
## [177] "tBodyGyroJerk-energy()-X"            
## [178] "tBodyGyroJerk-energy()-Y"            
## [179] "tBodyGyroJerk-energy()-Z"            
## [180] "tBodyGyroJerk-iqr()-X"               
## [181] "tBodyGyroJerk-iqr()-Y"               
## [182] "tBodyGyroJerk-iqr()-Z"               
## [183] "tBodyGyroJerk-entropy()-X"           
## [184] "tBodyGyroJerk-entropy()-Y"           
## [185] "tBodyGyroJerk-entropy()-Z"           
## [186] "tBodyGyroJerk-arCoeff()-X,1"         
## [187] "tBodyGyroJerk-arCoeff()-X,2"         
## [188] "tBodyGyroJerk-arCoeff()-X,3"         
## [189] "tBodyGyroJerk-arCoeff()-X,4"         
## [190] "tBodyGyroJerk-arCoeff()-Y,1"         
## [191] "tBodyGyroJerk-arCoeff()-Y,2"         
## [192] "tBodyGyroJerk-arCoeff()-Y,3"         
## [193] "tBodyGyroJerk-arCoeff()-Y,4"         
## [194] "tBodyGyroJerk-arCoeff()-Z,1"         
## [195] "tBodyGyroJerk-arCoeff()-Z,2"         
## [196] "tBodyGyroJerk-arCoeff()-Z,3"         
## [197] "tBodyGyroJerk-arCoeff()-Z,4"         
## [198] "tBodyGyroJerk-correlation()-X,Y"     
## [199] "tBodyGyroJerk-correlation()-X,Z"     
## [200] "tBodyGyroJerk-correlation()-Y,Z"     
## [201] "tBodyAccMag-mean()"                  
## [202] "tBodyAccMag-std()"                   
## [203] "tBodyAccMag-mad()"                   
## [204] "tBodyAccMag-max()"                   
## [205] "tBodyAccMag-min()"                   
## [206] "tBodyAccMag-sma()"                   
## [207] "tBodyAccMag-energy()"                
## [208] "tBodyAccMag-iqr()"                   
## [209] "tBodyAccMag-entropy()"               
## [210] "tBodyAccMag-arCoeff()1"              
## [211] "tBodyAccMag-arCoeff()2"              
## [212] "tBodyAccMag-arCoeff()3"              
## [213] "tBodyAccMag-arCoeff()4"              
## [214] "tGravityAccMag-mean()"               
## [215] "tGravityAccMag-std()"                
## [216] "tGravityAccMag-mad()"                
## [217] "tGravityAccMag-max()"                
## [218] "tGravityAccMag-min()"                
## [219] "tGravityAccMag-sma()"                
## [220] "tGravityAccMag-energy()"             
## [221] "tGravityAccMag-iqr()"                
## [222] "tGravityAccMag-entropy()"            
## [223] "tGravityAccMag-arCoeff()1"           
## [224] "tGravityAccMag-arCoeff()2"           
## [225] "tGravityAccMag-arCoeff()3"           
## [226] "tGravityAccMag-arCoeff()4"           
## [227] "tBodyAccJerkMag-mean()"              
## [228] "tBodyAccJerkMag-std()"               
## [229] "tBodyAccJerkMag-mad()"               
## [230] "tBodyAccJerkMag-max()"               
## [231] "tBodyAccJerkMag-min()"               
## [232] "tBodyAccJerkMag-sma()"               
## [233] "tBodyAccJerkMag-energy()"            
## [234] "tBodyAccJerkMag-iqr()"               
## [235] "tBodyAccJerkMag-entropy()"           
## [236] "tBodyAccJerkMag-arCoeff()1"          
## [237] "tBodyAccJerkMag-arCoeff()2"          
## [238] "tBodyAccJerkMag-arCoeff()3"          
## [239] "tBodyAccJerkMag-arCoeff()4"          
## [240] "tBodyGyroMag-mean()"                 
## [241] "tBodyGyroMag-std()"                  
## [242] "tBodyGyroMag-mad()"                  
## [243] "tBodyGyroMag-max()"                  
## [244] "tBodyGyroMag-min()"                  
## [245] "tBodyGyroMag-sma()"                  
## [246] "tBodyGyroMag-energy()"               
## [247] "tBodyGyroMag-iqr()"                  
## [248] "tBodyGyroMag-entropy()"              
## [249] "tBodyGyroMag-arCoeff()1"             
## [250] "tBodyGyroMag-arCoeff()2"             
## [251] "tBodyGyroMag-arCoeff()3"             
## [252] "tBodyGyroMag-arCoeff()4"             
## [253] "tBodyGyroJerkMag-mean()"             
## [254] "tBodyGyroJerkMag-std()"              
## [255] "tBodyGyroJerkMag-mad()"              
## [256] "tBodyGyroJerkMag-max()"              
## [257] "tBodyGyroJerkMag-min()"              
## [258] "tBodyGyroJerkMag-sma()"              
## [259] "tBodyGyroJerkMag-energy()"           
## [260] "tBodyGyroJerkMag-iqr()"              
## [261] "tBodyGyroJerkMag-entropy()"          
## [262] "tBodyGyroJerkMag-arCoeff()1"         
## [263] "tBodyGyroJerkMag-arCoeff()2"         
## [264] "tBodyGyroJerkMag-arCoeff()3"         
## [265] "tBodyGyroJerkMag-arCoeff()4"         
## [266] "fBodyAcc-mean()-X"                   
## [267] "fBodyAcc-mean()-Y"                   
## [268] "fBodyAcc-mean()-Z"                   
## [269] "fBodyAcc-std()-X"                    
## [270] "fBodyAcc-std()-Y"                    
## [271] "fBodyAcc-std()-Z"                    
## [272] "fBodyAcc-mad()-X"                    
## [273] "fBodyAcc-mad()-Y"                    
## [274] "fBodyAcc-mad()-Z"                    
## [275] "fBodyAcc-max()-X"                    
## [276] "fBodyAcc-max()-Y"                    
## [277] "fBodyAcc-max()-Z"                    
## [278] "fBodyAcc-min()-X"                    
## [279] "fBodyAcc-min()-Y"                    
## [280] "fBodyAcc-min()-Z"                    
## [281] "fBodyAcc-sma()"                      
## [282] "fBodyAcc-energy()-X"                 
## [283] "fBodyAcc-energy()-Y"                 
## [284] "fBodyAcc-energy()-Z"                 
## [285] "fBodyAcc-iqr()-X"                    
## [286] "fBodyAcc-iqr()-Y"                    
## [287] "fBodyAcc-iqr()-Z"                    
## [288] "fBodyAcc-entropy()-X"                
## [289] "fBodyAcc-entropy()-Y"                
## [290] "fBodyAcc-entropy()-Z"                
## [291] "fBodyAcc-maxInds-X"                  
## [292] "fBodyAcc-maxInds-Y"                  
## [293] "fBodyAcc-maxInds-Z"                  
## [294] "fBodyAcc-meanFreq()-X"               
## [295] "fBodyAcc-meanFreq()-Y"               
## [296] "fBodyAcc-meanFreq()-Z"               
## [297] "fBodyAcc-skewness()-X"               
## [298] "fBodyAcc-kurtosis()-X"               
## [299] "fBodyAcc-skewness()-Y"               
## [300] "fBodyAcc-kurtosis()-Y"               
## [301] "fBodyAcc-skewness()-Z"               
## [302] "fBodyAcc-kurtosis()-Z"               
## [303] "fBodyAcc-bandsEnergy()-1,8"          
## [304] "fBodyAcc-bandsEnergy()-9,16"         
## [305] "fBodyAcc-bandsEnergy()-17,24"        
## [306] "fBodyAcc-bandsEnergy()-25,32"        
## [307] "fBodyAcc-bandsEnergy()-33,40"        
## [308] "fBodyAcc-bandsEnergy()-41,48"        
## [309] "fBodyAcc-bandsEnergy()-49,56"        
## [310] "fBodyAcc-bandsEnergy()-57,64"        
## [311] "fBodyAcc-bandsEnergy()-1,16"         
## [312] "fBodyAcc-bandsEnergy()-17,32"        
## [313] "fBodyAcc-bandsEnergy()-33,48"        
## [314] "fBodyAcc-bandsEnergy()-49,64"        
## [315] "fBodyAcc-bandsEnergy()-1,24"         
## [316] "fBodyAcc-bandsEnergy()-25,48"        
## [317] "fBodyAcc-bandsEnergy()-1,8"          
## [318] "fBodyAcc-bandsEnergy()-9,16"         
## [319] "fBodyAcc-bandsEnergy()-17,24"        
## [320] "fBodyAcc-bandsEnergy()-25,32"        
## [321] "fBodyAcc-bandsEnergy()-33,40"        
## [322] "fBodyAcc-bandsEnergy()-41,48"        
## [323] "fBodyAcc-bandsEnergy()-49,56"        
## [324] "fBodyAcc-bandsEnergy()-57,64"        
## [325] "fBodyAcc-bandsEnergy()-1,16"         
## [326] "fBodyAcc-bandsEnergy()-17,32"        
## [327] "fBodyAcc-bandsEnergy()-33,48"        
## [328] "fBodyAcc-bandsEnergy()-49,64"        
## [329] "fBodyAcc-bandsEnergy()-1,24"         
## [330] "fBodyAcc-bandsEnergy()-25,48"        
## [331] "fBodyAcc-bandsEnergy()-1,8"          
## [332] "fBodyAcc-bandsEnergy()-9,16"         
## [333] "fBodyAcc-bandsEnergy()-17,24"        
## [334] "fBodyAcc-bandsEnergy()-25,32"        
## [335] "fBodyAcc-bandsEnergy()-33,40"        
## [336] "fBodyAcc-bandsEnergy()-41,48"        
## [337] "fBodyAcc-bandsEnergy()-49,56"        
## [338] "fBodyAcc-bandsEnergy()-57,64"        
## [339] "fBodyAcc-bandsEnergy()-1,16"         
## [340] "fBodyAcc-bandsEnergy()-17,32"        
## [341] "fBodyAcc-bandsEnergy()-33,48"        
## [342] "fBodyAcc-bandsEnergy()-49,64"        
## [343] "fBodyAcc-bandsEnergy()-1,24"         
## [344] "fBodyAcc-bandsEnergy()-25,48"        
## [345] "fBodyAccJerk-mean()-X"               
## [346] "fBodyAccJerk-mean()-Y"               
## [347] "fBodyAccJerk-mean()-Z"               
## [348] "fBodyAccJerk-std()-X"                
## [349] "fBodyAccJerk-std()-Y"                
## [350] "fBodyAccJerk-std()-Z"                
## [351] "fBodyAccJerk-mad()-X"                
## [352] "fBodyAccJerk-mad()-Y"                
## [353] "fBodyAccJerk-mad()-Z"                
## [354] "fBodyAccJerk-max()-X"                
## [355] "fBodyAccJerk-max()-Y"                
## [356] "fBodyAccJerk-max()-Z"                
## [357] "fBodyAccJerk-min()-X"                
## [358] "fBodyAccJerk-min()-Y"                
## [359] "fBodyAccJerk-min()-Z"                
## [360] "fBodyAccJerk-sma()"                  
## [361] "fBodyAccJerk-energy()-X"             
## [362] "fBodyAccJerk-energy()-Y"             
## [363] "fBodyAccJerk-energy()-Z"             
## [364] "fBodyAccJerk-iqr()-X"                
## [365] "fBodyAccJerk-iqr()-Y"                
## [366] "fBodyAccJerk-iqr()-Z"                
## [367] "fBodyAccJerk-entropy()-X"            
## [368] "fBodyAccJerk-entropy()-Y"            
## [369] "fBodyAccJerk-entropy()-Z"            
## [370] "fBodyAccJerk-maxInds-X"              
## [371] "fBodyAccJerk-maxInds-Y"              
## [372] "fBodyAccJerk-maxInds-Z"              
## [373] "fBodyAccJerk-meanFreq()-X"           
## [374] "fBodyAccJerk-meanFreq()-Y"           
## [375] "fBodyAccJerk-meanFreq()-Z"           
## [376] "fBodyAccJerk-skewness()-X"           
## [377] "fBodyAccJerk-kurtosis()-X"           
## [378] "fBodyAccJerk-skewness()-Y"           
## [379] "fBodyAccJerk-kurtosis()-Y"           
## [380] "fBodyAccJerk-skewness()-Z"           
## [381] "fBodyAccJerk-kurtosis()-Z"           
## [382] "fBodyAccJerk-bandsEnergy()-1,8"      
## [383] "fBodyAccJerk-bandsEnergy()-9,16"     
## [384] "fBodyAccJerk-bandsEnergy()-17,24"    
## [385] "fBodyAccJerk-bandsEnergy()-25,32"    
## [386] "fBodyAccJerk-bandsEnergy()-33,40"    
## [387] "fBodyAccJerk-bandsEnergy()-41,48"    
## [388] "fBodyAccJerk-bandsEnergy()-49,56"    
## [389] "fBodyAccJerk-bandsEnergy()-57,64"    
## [390] "fBodyAccJerk-bandsEnergy()-1,16"     
## [391] "fBodyAccJerk-bandsEnergy()-17,32"    
## [392] "fBodyAccJerk-bandsEnergy()-33,48"    
## [393] "fBodyAccJerk-bandsEnergy()-49,64"    
## [394] "fBodyAccJerk-bandsEnergy()-1,24"     
## [395] "fBodyAccJerk-bandsEnergy()-25,48"    
## [396] "fBodyAccJerk-bandsEnergy()-1,8"      
## [397] "fBodyAccJerk-bandsEnergy()-9,16"     
## [398] "fBodyAccJerk-bandsEnergy()-17,24"    
## [399] "fBodyAccJerk-bandsEnergy()-25,32"    
## [400] "fBodyAccJerk-bandsEnergy()-33,40"    
## [401] "fBodyAccJerk-bandsEnergy()-41,48"    
## [402] "fBodyAccJerk-bandsEnergy()-49,56"    
## [403] "fBodyAccJerk-bandsEnergy()-57,64"    
## [404] "fBodyAccJerk-bandsEnergy()-1,16"     
## [405] "fBodyAccJerk-bandsEnergy()-17,32"    
## [406] "fBodyAccJerk-bandsEnergy()-33,48"    
## [407] "fBodyAccJerk-bandsEnergy()-49,64"    
## [408] "fBodyAccJerk-bandsEnergy()-1,24"     
## [409] "fBodyAccJerk-bandsEnergy()-25,48"    
## [410] "fBodyAccJerk-bandsEnergy()-1,8"      
## [411] "fBodyAccJerk-bandsEnergy()-9,16"     
## [412] "fBodyAccJerk-bandsEnergy()-17,24"    
## [413] "fBodyAccJerk-bandsEnergy()-25,32"    
## [414] "fBodyAccJerk-bandsEnergy()-33,40"    
## [415] "fBodyAccJerk-bandsEnergy()-41,48"    
## [416] "fBodyAccJerk-bandsEnergy()-49,56"    
## [417] "fBodyAccJerk-bandsEnergy()-57,64"    
## [418] "fBodyAccJerk-bandsEnergy()-1,16"     
## [419] "fBodyAccJerk-bandsEnergy()-17,32"    
## [420] "fBodyAccJerk-bandsEnergy()-33,48"    
## [421] "fBodyAccJerk-bandsEnergy()-49,64"    
## [422] "fBodyAccJerk-bandsEnergy()-1,24"     
## [423] "fBodyAccJerk-bandsEnergy()-25,48"    
## [424] "fBodyGyro-mean()-X"                  
## [425] "fBodyGyro-mean()-Y"                  
## [426] "fBodyGyro-mean()-Z"                  
## [427] "fBodyGyro-std()-X"                   
## [428] "fBodyGyro-std()-Y"                   
## [429] "fBodyGyro-std()-Z"                   
## [430] "fBodyGyro-mad()-X"                   
## [431] "fBodyGyro-mad()-Y"                   
## [432] "fBodyGyro-mad()-Z"                   
## [433] "fBodyGyro-max()-X"                   
## [434] "fBodyGyro-max()-Y"                   
## [435] "fBodyGyro-max()-Z"                   
## [436] "fBodyGyro-min()-X"                   
## [437] "fBodyGyro-min()-Y"                   
## [438] "fBodyGyro-min()-Z"                   
## [439] "fBodyGyro-sma()"                     
## [440] "fBodyGyro-energy()-X"                
## [441] "fBodyGyro-energy()-Y"                
## [442] "fBodyGyro-energy()-Z"                
## [443] "fBodyGyro-iqr()-X"                   
## [444] "fBodyGyro-iqr()-Y"                   
## [445] "fBodyGyro-iqr()-Z"                   
## [446] "fBodyGyro-entropy()-X"               
## [447] "fBodyGyro-entropy()-Y"               
## [448] "fBodyGyro-entropy()-Z"               
## [449] "fBodyGyro-maxInds-X"                 
## [450] "fBodyGyro-maxInds-Y"                 
## [451] "fBodyGyro-maxInds-Z"                 
## [452] "fBodyGyro-meanFreq()-X"              
## [453] "fBodyGyro-meanFreq()-Y"              
## [454] "fBodyGyro-meanFreq()-Z"              
## [455] "fBodyGyro-skewness()-X"              
## [456] "fBodyGyro-kurtosis()-X"              
## [457] "fBodyGyro-skewness()-Y"              
## [458] "fBodyGyro-kurtosis()-Y"              
## [459] "fBodyGyro-skewness()-Z"              
## [460] "fBodyGyro-kurtosis()-Z"              
## [461] "fBodyGyro-bandsEnergy()-1,8"         
## [462] "fBodyGyro-bandsEnergy()-9,16"        
## [463] "fBodyGyro-bandsEnergy()-17,24"       
## [464] "fBodyGyro-bandsEnergy()-25,32"       
## [465] "fBodyGyro-bandsEnergy()-33,40"       
## [466] "fBodyGyro-bandsEnergy()-41,48"       
## [467] "fBodyGyro-bandsEnergy()-49,56"       
## [468] "fBodyGyro-bandsEnergy()-57,64"       
## [469] "fBodyGyro-bandsEnergy()-1,16"        
## [470] "fBodyGyro-bandsEnergy()-17,32"       
## [471] "fBodyGyro-bandsEnergy()-33,48"       
## [472] "fBodyGyro-bandsEnergy()-49,64"       
## [473] "fBodyGyro-bandsEnergy()-1,24"        
## [474] "fBodyGyro-bandsEnergy()-25,48"       
## [475] "fBodyGyro-bandsEnergy()-1,8"         
## [476] "fBodyGyro-bandsEnergy()-9,16"        
## [477] "fBodyGyro-bandsEnergy()-17,24"       
## [478] "fBodyGyro-bandsEnergy()-25,32"       
## [479] "fBodyGyro-bandsEnergy()-33,40"       
## [480] "fBodyGyro-bandsEnergy()-41,48"       
## [481] "fBodyGyro-bandsEnergy()-49,56"       
## [482] "fBodyGyro-bandsEnergy()-57,64"       
## [483] "fBodyGyro-bandsEnergy()-1,16"        
## [484] "fBodyGyro-bandsEnergy()-17,32"       
## [485] "fBodyGyro-bandsEnergy()-33,48"       
## [486] "fBodyGyro-bandsEnergy()-49,64"       
## [487] "fBodyGyro-bandsEnergy()-1,24"        
## [488] "fBodyGyro-bandsEnergy()-25,48"       
## [489] "fBodyGyro-bandsEnergy()-1,8"         
## [490] "fBodyGyro-bandsEnergy()-9,16"        
## [491] "fBodyGyro-bandsEnergy()-17,24"       
## [492] "fBodyGyro-bandsEnergy()-25,32"       
## [493] "fBodyGyro-bandsEnergy()-33,40"       
## [494] "fBodyGyro-bandsEnergy()-41,48"       
## [495] "fBodyGyro-bandsEnergy()-49,56"       
## [496] "fBodyGyro-bandsEnergy()-57,64"       
## [497] "fBodyGyro-bandsEnergy()-1,16"        
## [498] "fBodyGyro-bandsEnergy()-17,32"       
## [499] "fBodyGyro-bandsEnergy()-33,48"       
## [500] "fBodyGyro-bandsEnergy()-49,64"       
## [501] "fBodyGyro-bandsEnergy()-1,24"        
## [502] "fBodyGyro-bandsEnergy()-25,48"       
## [503] "fBodyAccMag-mean()"                  
## [504] "fBodyAccMag-std()"                   
## [505] "fBodyAccMag-mad()"                   
## [506] "fBodyAccMag-max()"                   
## [507] "fBodyAccMag-min()"                   
## [508] "fBodyAccMag-sma()"                   
## [509] "fBodyAccMag-energy()"                
## [510] "fBodyAccMag-iqr()"                   
## [511] "fBodyAccMag-entropy()"               
## [512] "fBodyAccMag-maxInds"                 
## [513] "fBodyAccMag-meanFreq()"              
## [514] "fBodyAccMag-skewness()"              
## [515] "fBodyAccMag-kurtosis()"              
## [516] "fBodyBodyAccJerkMag-mean()"          
## [517] "fBodyBodyAccJerkMag-std()"           
## [518] "fBodyBodyAccJerkMag-mad()"           
## [519] "fBodyBodyAccJerkMag-max()"           
## [520] "fBodyBodyAccJerkMag-min()"           
## [521] "fBodyBodyAccJerkMag-sma()"           
## [522] "fBodyBodyAccJerkMag-energy()"        
## [523] "fBodyBodyAccJerkMag-iqr()"           
## [524] "fBodyBodyAccJerkMag-entropy()"       
## [525] "fBodyBodyAccJerkMag-maxInds"         
## [526] "fBodyBodyAccJerkMag-meanFreq()"      
## [527] "fBodyBodyAccJerkMag-skewness()"      
## [528] "fBodyBodyAccJerkMag-kurtosis()"      
## [529] "fBodyBodyGyroMag-mean()"             
## [530] "fBodyBodyGyroMag-std()"              
## [531] "fBodyBodyGyroMag-mad()"              
## [532] "fBodyBodyGyroMag-max()"              
## [533] "fBodyBodyGyroMag-min()"              
## [534] "fBodyBodyGyroMag-sma()"              
## [535] "fBodyBodyGyroMag-energy()"           
## [536] "fBodyBodyGyroMag-iqr()"              
## [537] "fBodyBodyGyroMag-entropy()"          
## [538] "fBodyBodyGyroMag-maxInds"            
## [539] "fBodyBodyGyroMag-meanFreq()"         
## [540] "fBodyBodyGyroMag-skewness()"         
## [541] "fBodyBodyGyroMag-kurtosis()"         
## [542] "fBodyBodyGyroJerkMag-mean()"         
## [543] "fBodyBodyGyroJerkMag-std()"          
## [544] "fBodyBodyGyroJerkMag-mad()"          
## [545] "fBodyBodyGyroJerkMag-max()"          
## [546] "fBodyBodyGyroJerkMag-min()"          
## [547] "fBodyBodyGyroJerkMag-sma()"          
## [548] "fBodyBodyGyroJerkMag-energy()"       
## [549] "fBodyBodyGyroJerkMag-iqr()"          
## [550] "fBodyBodyGyroJerkMag-entropy()"      
## [551] "fBodyBodyGyroJerkMag-maxInds"        
## [552] "fBodyBodyGyroJerkMag-meanFreq()"     
## [553] "fBodyBodyGyroJerkMag-skewness()"     
## [554] "fBodyBodyGyroJerkMag-kurtosis()"     
## [555] "angle(tBodyAccMean,gravity)"         
## [556] "angle(tBodyAccJerkMean),gravityMean)"
## [557] "angle(tBodyGyroMean,gravityMean)"    
## [558] "angle(tBodyGyroJerkMean,gravityMean)"
## [559] "angle(X,gravityMean)"                
## [560] "angle(Y,gravityMean)"                
## [561] "angle(Z,gravityMean)"                
## [562] "Subject"                             
## [563] "Activity"
```

## 2. Extracts only the measurements on the mean and standard deviation for each measurement.

Now for the purpose of this project we only the measurements of the `mean` and `standard deviation` for each measurement.
We are going to look at `V2` in the `FeaturesNames_data` which a Factor w/ 477 levels and extract all features names with `mean()` and `std()` and store them in a new variable called `FeaturesNames_subdata`

```{r}
FeaturesNames_subdata <- FeaturesNames_data$V2[grep("mean\\(\\)|std\\(\\)",FeaturesNames_data$V2)]
```

Now we are going to Subset the data frame `Combine_data` by seleted names of `Features` we stored in our `FeaturesNames_subdata` and stor theme in a variable called `new_data`

```{r}
Names_selected <- c(as.character(FeaturesNames_subdata), "Subject", "Activity" )
new_data <- subset(Combine_data,select=Names_selected)
```

Check the structures of the data frame 'new_data' which should have only 68 variables and 10299 observations

```
str(new_data)
## 'data.frame':    10299 obs. of  68 variables:
##  $ tBodyAcc-mean()-X          : num  0.289 0.278 0.28 0.279 0.277 ...
##  $ tBodyAcc-mean()-Y          : num  -0.0203 -0.0164 -0.0195 -0.0262 -0.0166 ...
##  $ tBodyAcc-mean()-Z          : num  -0.133 -0.124 -0.113 -0.123 -0.115 ...
##  $ tBodyAcc-std()-X           : num  -0.995 -0.998 -0.995 -0.996 -0.998 ...
##  $ tBodyAcc-std()-Y           : num  -0.983 -0.975 -0.967 -0.983 -0.981 ...
##  $ tBodyAcc-std()-Z           : num  -0.914 -0.96 -0.979 -0.991 -0.99 ...
##  $ tGravityAcc-mean()-X       : num  0.963 0.967 0.967 0.968 0.968 ...
##  $ tGravityAcc-mean()-Y       : num  -0.141 -0.142 -0.142 -0.144 -0.149 ...
##  $ tGravityAcc-mean()-Z       : num  0.1154 0.1094 0.1019 0.0999 0.0945 ...
##  $ tGravityAcc-std()-X        : num  -0.985 -0.997 -1 -0.997 -0.998 ...
##  $ tGravityAcc-std()-Y        : num  -0.982 -0.989 -0.993 -0.981 -0.988 ...
##  $ tGravityAcc-std()-Z        : num  -0.878 -0.932 -0.993 -0.978 -0.979 ...
##  $ tBodyAccJerk-mean()-X      : num  0.078 0.074 0.0736 0.0773 0.0734 ...
##  $ tBodyAccJerk-mean()-Y      : num  0.005 0.00577 0.0031 0.02006 0.01912 ...
##  $ tBodyAccJerk-mean()-Z      : num  -0.06783 0.02938 -0.00905 -0.00986 0.01678 ...
##  $ tBodyAccJerk-std()-X       : num  -0.994 -0.996 -0.991 -0.993 -0.996 ...
##  $ tBodyAccJerk-std()-Y       : num  -0.988 -0.981 -0.981 -0.988 -0.988 ...
##  $ tBodyAccJerk-std()-Z       : num  -0.994 -0.992 -0.99 -0.993 -0.992 ...
##  $ tBodyGyro-mean()-X         : num  -0.0061 -0.0161 -0.0317 -0.0434 -0.034 ...
##  $ tBodyGyro-mean()-Y         : num  -0.0314 -0.0839 -0.1023 -0.0914 -0.0747 ...
##  $ tBodyGyro-mean()-Z         : num  0.1077 0.1006 0.0961 0.0855 0.0774 ...
##  $ tBodyGyro-std()-X          : num  -0.985 -0.983 -0.976 -0.991 -0.985 ...
##  $ tBodyGyro-std()-Y          : num  -0.977 -0.989 -0.994 -0.992 -0.992 ...
##  $ tBodyGyro-std()-Z          : num  -0.992 -0.989 -0.986 -0.988 -0.987 ...
##  $ tBodyGyroJerk-mean()-X     : num  -0.0992 -0.1105 -0.1085 -0.0912 -0.0908 ...
##  $ tBodyGyroJerk-mean()-Y     : num  -0.0555 -0.0448 -0.0424 -0.0363 -0.0376 ...
##  $ tBodyGyroJerk-mean()-Z     : num  -0.062 -0.0592 -0.0558 -0.0605 -0.0583 ...
##  $ tBodyGyroJerk-std()-X      : num  -0.992 -0.99 -0.988 -0.991 -0.991 ...
##  $ tBodyGyroJerk-std()-Y      : num  -0.993 -0.997 -0.996 -0.997 -0.996 ...
##  $ tBodyGyroJerk-std()-Z      : num  -0.992 -0.994 -0.992 -0.993 -0.995 ...
##  $ tBodyAccMag-mean()         : num  -0.959 -0.979 -0.984 -0.987 -0.993 ...
##  $ tBodyAccMag-std()          : num  -0.951 -0.976 -0.988 -0.986 -0.991 ...
##  $ tGravityAccMag-mean()      : num  -0.959 -0.979 -0.984 -0.987 -0.993 ...
##  $ tGravityAccMag-std()       : num  -0.951 -0.976 -0.988 -0.986 -0.991 ...
##  $ tBodyAccJerkMag-mean()     : num  -0.993 -0.991 -0.989 -0.993 -0.993 ...
##  $ tBodyAccJerkMag-std()      : num  -0.994 -0.992 -0.99 -0.993 -0.996 ...
##  $ tBodyGyroMag-mean()        : num  -0.969 -0.981 -0.976 -0.982 -0.985 ...
##  $ tBodyGyroMag-std()         : num  -0.964 -0.984 -0.986 -0.987 -0.989 ...
##  $ tBodyGyroJerkMag-mean()    : num  -0.994 -0.995 -0.993 -0.996 -0.996 ...
##  $ tBodyGyroJerkMag-std()     : num  -0.991 -0.996 -0.995 -0.995 -0.995 ...
##  $ fBodyAcc-mean()-X          : num  -0.995 -0.997 -0.994 -0.995 -0.997 ...
##  $ fBodyAcc-mean()-Y          : num  -0.983 -0.977 -0.973 -0.984 -0.982 ...
##  $ fBodyAcc-mean()-Z          : num  -0.939 -0.974 -0.983 -0.991 -0.988 ...
##  $ fBodyAcc-std()-X           : num  -0.995 -0.999 -0.996 -0.996 -0.999 ...
##  $ fBodyAcc-std()-Y           : num  -0.983 -0.975 -0.966 -0.983 -0.98 ...
##  $ fBodyAcc-std()-Z           : num  -0.906 -0.955 -0.977 -0.99 -0.992 ...
##  $ fBodyAccJerk-mean()-X      : num  -0.992 -0.995 -0.991 -0.994 -0.996 ...
##  $ fBodyAccJerk-mean()-Y      : num  -0.987 -0.981 -0.982 -0.989 -0.989 ...
##  $ fBodyAccJerk-mean()-Z      : num  -0.99 -0.99 -0.988 -0.991 -0.991 ...
##  $ fBodyAccJerk-std()-X       : num  -0.996 -0.997 -0.991 -0.991 -0.997 ...
##  $ fBodyAccJerk-std()-Y       : num  -0.991 -0.982 -0.981 -0.987 -0.989 ...
##  $ fBodyAccJerk-std()-Z       : num  -0.997 -0.993 -0.99 -0.994 -0.993 ...
##  $ fBodyGyro-mean()-X         : num  -0.987 -0.977 -0.975 -0.987 -0.982 ...
##  $ fBodyGyro-mean()-Y         : num  -0.982 -0.993 -0.994 -0.994 -0.993 ...
##  $ fBodyGyro-mean()-Z         : num  -0.99 -0.99 -0.987 -0.987 -0.989 ...
##  $ fBodyGyro-std()-X          : num  -0.985 -0.985 -0.977 -0.993 -0.986 ...
##  $ fBodyGyro-std()-Y          : num  -0.974 -0.987 -0.993 -0.992 -0.992 ...
##  $ fBodyGyro-std()-Z          : num  -0.994 -0.99 -0.987 -0.989 -0.988 ...
##  $ fBodyAccMag-mean()         : num  -0.952 -0.981 -0.988 -0.988 -0.994 ...
##  $ fBodyAccMag-std()          : num  -0.956 -0.976 -0.989 -0.987 -0.99 ...
##  $ fBodyBodyAccJerkMag-mean() : num  -0.994 -0.99 -0.989 -0.993 -0.996 ...
##  $ fBodyBodyAccJerkMag-std()  : num  -0.994 -0.992 -0.991 -0.992 -0.994 ...
##  $ fBodyBodyGyroMag-mean()    : num  -0.98 -0.988 -0.989 -0.989 -0.991 ...
##  $ fBodyBodyGyroMag-std()     : num  -0.961 -0.983 -0.986 -0.988 -0.989 ...
##  $ fBodyBodyGyroJerkMag-mean(): num  -0.992 -0.996 -0.995 -0.995 -0.995 ...
##  $ fBodyBodyGyroJerkMag-std() : num  -0.991 -0.996 -0.995 -0.995 -0.995 ...
##  $ Subject                    : int  1 1 1 1 1 1 1 1 1 1 ...
##  $ Activity                   : int  5 5 5 5 5 5 5 5 5 5 ...
```

## 3. Uses descriptive activity names to name the activities in the data set

Now we are gong to use descriptive activity names to name the activities in the data set

Read descriptive Activity names from `activity_labels.txt`

```{r}
activity_Labels <- read.table(file.path(Dataset_Path, "activity_labels.txt"),header = FALSE)
new_data$Activity <- factor(new_data$Activity, levels = activity_Labels[,1], labels = activity_Labels[,2])
```
Check if our Activity data has been Labeled
```{r}
head(new_data$Activity, n=10)
```
```
##  [1] STANDING STANDING STANDING STANDING STANDING STANDING STANDING
##  [8] STANDING STANDING STANDING
## 6 Levels: WALKING WALKING_UPSTAIRS WALKING_DOWNSTAIRS ... LAYING

```{r}
tail(new_data$Activity, n=10)
```
```
##  [1] WALKING_UPSTAIRS WALKING_UPSTAIRS WALKING_UPSTAIRS WALKING_UPSTAIRS
##  [5] WALKING_UPSTAIRS WALKING_UPSTAIRS WALKING_UPSTAIRS WALKING_UPSTAIRS
##  [9] WALKING_UPSTAIRS WALKING_UPSTAIRS
## 6 Levels: WALKING WALKING_UPSTAIRS WALKING_DOWNSTAIRS ... LAYING
```

## 4. Appropriately labels the data set with descriptive variable names.


Now we are going to label the data set with descriptive variable names.

```{r}
names(new_data)<-gsub("^t", "Time", names(new_data))
names(new_data)<-gsub("^f", "Frequency", names(new_data))
names(new_data)<-gsub("Gyro", "Gyroscope", names(new_data))
names(new_data)<-gsub("Mag", "Magnitude", names(new_data))
names(new_data)<-gsub("Acc", "Accelerometer", names(new_data))
names(new_data)<-gsub("BodyBody", "Body", names(new_data))
```
do a check for names
```{r}
names(new_data)
```
```
##  [1] "TimeBodyAccelerometer-mean()-X"                
##  [2] "TimeBodyAccelerometer-mean()-Y"                
##  [3] "TimeBodyAccelerometer-mean()-Z"                
##  [4] "TimeBodyAccelerometer-std()-X"                 
##  [5] "TimeBodyAccelerometer-std()-Y"                 
##  [6] "TimeBodyAccelerometer-std()-Z"                 
##  [7] "TimeGravityAccelerometer-mean()-X"             
##  [8] "TimeGravityAccelerometer-mean()-Y"             
##  [9] "TimeGravityAccelerometer-mean()-Z"             
## [10] "TimeGravityAccelerometer-std()-X"              
## [11] "TimeGravityAccelerometer-std()-Y"              
## [12] "TimeGravityAccelerometer-std()-Z"              
## [13] "TimeBodyAccelerometerJerk-mean()-X"            
## [14] "TimeBodyAccelerometerJerk-mean()-Y"            
## [15] "TimeBodyAccelerometerJerk-mean()-Z"            
## [16] "TimeBodyAccelerometerJerk-std()-X"             
## [17] "TimeBodyAccelerometerJerk-std()-Y"             
## [18] "TimeBodyAccelerometerJerk-std()-Z"             
## [19] "TimeBodyGyroscope-mean()-X"                    
## [20] "TimeBodyGyroscope-mean()-Y"                    
## [21] "TimeBodyGyroscope-mean()-Z"                    
## [22] "TimeBodyGyroscope-std()-X"                     
## [23] "TimeBodyGyroscope-std()-Y"                     
## [24] "TimeBodyGyroscope-std()-Z"                     
## [25] "TimeBodyGyroscopeJerk-mean()-X"                
## [26] "TimeBodyGyroscopeJerk-mean()-Y"                
## [27] "TimeBodyGyroscopeJerk-mean()-Z"                
## [28] "TimeBodyGyroscopeJerk-std()-X"                 
## [29] "TimeBodyGyroscopeJerk-std()-Y"                 
## [30] "TimeBodyGyroscopeJerk-std()-Z"                 
## [31] "TimeBodyAccelerometerMagnitude-mean()"         
## [32] "TimeBodyAccelerometerMagnitude-std()"          
## [33] "TimeGravityAccelerometerMagnitude-mean()"      
## [34] "TimeGravityAccelerometerMagnitude-std()"       
## [35] "TimeBodyAccelerometerJerkMagnitude-mean()"     
## [36] "TimeBodyAccelerometerJerkMagnitude-std()"      
## [37] "TimeBodyGyroscopeMagnitude-mean()"             
## [38] "TimeBodyGyroscopeMagnitude-std()"              
## [39] "TimeBodyGyroscopeJerkMagnitude-mean()"         
## [40] "TimeBodyGyroscopeJerkMagnitude-std()"          
## [41] "FrequencyBodyAccelerometer-mean()-X"           
## [42] "FrequencyBodyAccelerometer-mean()-Y"           
## [43] "FrequencyBodyAccelerometer-mean()-Z"           
## [44] "FrequencyBodyAccelerometer-std()-X"            
## [45] "FrequencyBodyAccelerometer-std()-Y"            
## [46] "FrequencyBodyAccelerometer-std()-Z"            
## [47] "FrequencyBodyAccelerometerJerk-mean()-X"       
## [48] "FrequencyBodyAccelerometerJerk-mean()-Y"       
## [49] "FrequencyBodyAccelerometerJerk-mean()-Z"       
## [50] "FrequencyBodyAccelerometerJerk-std()-X"        
## [51] "FrequencyBodyAccelerometerJerk-std()-Y"        
## [52] "FrequencyBodyAccelerometerJerk-std()-Z"        
## [53] "FrequencyBodyGyroscope-mean()-X"               
## [54] "FrequencyBodyGyroscope-mean()-Y"               
## [55] "FrequencyBodyGyroscope-mean()-Z"               
## [56] "FrequencyBodyGyroscope-std()-X"                
## [57] "FrequencyBodyGyroscope-std()-Y"                
## [58] "FrequencyBodyGyroscope-std()-Z"                
## [59] "FrequencyBodyAccelerometerMagnitude-mean()"    
## [60] "FrequencyBodyAccelerometerMagnitude-std()"     
## [61] "FrequencyBodyAccelerometerJerkMagnitude-mean()"
## [62] "FrequencyBodyAccelerometerJerkMagnitude-std()" 
## [63] "FrequencyBodyGyroscopeMagnitude-mean()"        
## [64] "FrequencyBodyGyroscopeMagnitude-std()"         
## [65] "FrequencyBodyGyroscopeJerkMagnitude-mean()"    
## [66] "FrequencyBodyGyroscopeJerkMagnitude-std()"     
## [67] "Subject"                                       
## [68] "Activity"
```

## 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

From the data set new_data in in the pervious step, we are going to creates a second, independent tidy data set with the `average` of each variable for each `Activity` and each `Subject` and call it `tidydata`. 
And then order our `tidydata` so that the `Subject` & `Activity` are on the first two colomns. 
Note that we need `plyr` package for this step.

```{r}
library(plyr);
tidydata <- aggregate(. ~Subject + Activity, new_data, mean)
tidydata <- tidydata[order(tidydata$Subject,tidydata$Activity),]
```
Check our tidydata structure.

```{r}
str(tidydata)
```
```
## 'data.frame':    180 obs. of  68 variables:
##  $ Subject                                       : int  1 1 1 1 1 1 2 2 2 2 ...
##  $ Activity                                      : Factor w/ 6 levels "WALKING","WALKING_UPSTAIRS",..: 1 2 3 4 5 6 1 2 3 4 ...
##  $ TimeBodyAccelerometer-mean()-X                : num  0.277 0.255 0.289 0.261 0.279 ...
##  $ TimeBodyAccelerometer-mean()-Y                : num  -0.01738 -0.02395 -0.00992 -0.00131 -0.01614 ...
##  $ TimeBodyAccelerometer-mean()-Z                : num  -0.1111 -0.0973 -0.1076 -0.1045 -0.1106 ...
##  $ TimeBodyAccelerometer-std()-X                 : num  -0.284 -0.355 0.03 -0.977 -0.996 ...
##  $ TimeBodyAccelerometer-std()-Y                 : num  0.11446 -0.00232 -0.03194 -0.92262 -0.97319 ...
##  $ TimeBodyAccelerometer-std()-Z                 : num  -0.26 -0.0195 -0.2304 -0.9396 -0.9798 ...
##  $ TimeGravityAccelerometer-mean()-X             : num  0.935 0.893 0.932 0.832 0.943 ...
##  $ TimeGravityAccelerometer-mean()-Y             : num  -0.282 -0.362 -0.267 0.204 -0.273 ...
##  $ TimeGravityAccelerometer-mean()-Z             : num  -0.0681 -0.0754 -0.0621 0.332 0.0135 ...
##  $ TimeGravityAccelerometer-std()-X              : num  -0.977 -0.956 -0.951 -0.968 -0.994 ...
##  $ TimeGravityAccelerometer-std()-Y              : num  -0.971 -0.953 -0.937 -0.936 -0.981 ...
##  $ TimeGravityAccelerometer-std()-Z              : num  -0.948 -0.912 -0.896 -0.949 -0.976 ...
##  $ TimeBodyAccelerometerJerk-mean()-X            : num  0.074 0.1014 0.0542 0.0775 0.0754 ...
##  $ TimeBodyAccelerometerJerk-mean()-Y            : num  0.028272 0.019486 0.02965 -0.000619 0.007976 ...
##  $ TimeBodyAccelerometerJerk-mean()-Z            : num  -0.00417 -0.04556 -0.01097 -0.00337 -0.00369 ...
##  $ TimeBodyAccelerometerJerk-std()-X             : num  -0.1136 -0.4468 -0.0123 -0.9864 -0.9946 ...
##  $ TimeBodyAccelerometerJerk-std()-Y             : num  0.067 -0.378 -0.102 -0.981 -0.986 ...
##  $ TimeBodyAccelerometerJerk-std()-Z             : num  -0.503 -0.707 -0.346 -0.988 -0.992 ...
##  $ TimeBodyGyroscope-mean()-X                    : num  -0.0418 0.0505 -0.0351 -0.0454 -0.024 ...
##  $ TimeBodyGyroscope-mean()-Y                    : num  -0.0695 -0.1662 -0.0909 -0.0919 -0.0594 ...
##  $ TimeBodyGyroscope-mean()-Z                    : num  0.0849 0.0584 0.0901 0.0629 0.0748 ...
##  $ TimeBodyGyroscope-std()-X                     : num  -0.474 -0.545 -0.458 -0.977 -0.987 ...
##  $ TimeBodyGyroscope-std()-Y                     : num  -0.05461 0.00411 -0.12635 -0.96647 -0.98773 ...
##  $ TimeBodyGyroscope-std()-Z                     : num  -0.344 -0.507 -0.125 -0.941 -0.981 ...
##  $ TimeBodyGyroscopeJerk-mean()-X                : num  -0.09 -0.1222 -0.074 -0.0937 -0.0996 ...
##  $ TimeBodyGyroscopeJerk-mean()-Y                : num  -0.0398 -0.0421 -0.044 -0.0402 -0.0441 ...
##  $ TimeBodyGyroscopeJerk-mean()-Z                : num  -0.0461 -0.0407 -0.027 -0.0467 -0.049 ...
##  $ TimeBodyGyroscopeJerk-std()-X                 : num  -0.207 -0.615 -0.487 -0.992 -0.993 ...
##  $ TimeBodyGyroscopeJerk-std()-Y                 : num  -0.304 -0.602 -0.239 -0.99 -0.995 ...
##  $ TimeBodyGyroscopeJerk-std()-Z                 : num  -0.404 -0.606 -0.269 -0.988 -0.992 ...
##  $ TimeBodyAccelerometerMagnitude-mean()         : num  -0.137 -0.1299 0.0272 -0.9485 -0.9843 ...
##  $ TimeBodyAccelerometerMagnitude-std()          : num  -0.2197 -0.325 0.0199 -0.9271 -0.9819 ...
##  $ TimeGravityAccelerometerMagnitude-mean()      : num  -0.137 -0.1299 0.0272 -0.9485 -0.9843 ...
##  $ TimeGravityAccelerometerMagnitude-std()       : num  -0.2197 -0.325 0.0199 -0.9271 -0.9819 ...
##  $ TimeBodyAccelerometerJerkMagnitude-mean()     : num  -0.1414 -0.4665 -0.0894 -0.9874 -0.9924 ...
##  $ TimeBodyAccelerometerJerkMagnitude-std()      : num  -0.0745 -0.479 -0.0258 -0.9841 -0.9931 ...
##  $ TimeBodyGyroscopeMagnitude-mean()             : num  -0.161 -0.1267 -0.0757 -0.9309 -0.9765 ...
##  $ TimeBodyGyroscopeMagnitude-std()              : num  -0.187 -0.149 -0.226 -0.935 -0.979 ...
##  $ TimeBodyGyroscopeJerkMagnitude-mean()         : num  -0.299 -0.595 -0.295 -0.992 -0.995 ...
##  $ TimeBodyGyroscopeJerkMagnitude-std()          : num  -0.325 -0.649 -0.307 -0.988 -0.995 ...
##  $ FrequencyBodyAccelerometer-mean()-X           : num  -0.2028 -0.4043 0.0382 -0.9796 -0.9952 ...
##  $ FrequencyBodyAccelerometer-mean()-Y           : num  0.08971 -0.19098 0.00155 -0.94408 -0.97707 ...
##  $ FrequencyBodyAccelerometer-mean()-Z           : num  -0.332 -0.433 -0.226 -0.959 -0.985 ...
##  $ FrequencyBodyAccelerometer-std()-X            : num  -0.3191 -0.3374 0.0243 -0.9764 -0.996 ...
##  $ FrequencyBodyAccelerometer-std()-Y            : num  0.056 0.0218 -0.113 -0.9173 -0.9723 ...
##  $ FrequencyBodyAccelerometer-std()-Z            : num  -0.28 0.086 -0.298 -0.934 -0.978 ...
##  $ FrequencyBodyAccelerometerJerk-mean()-X       : num  -0.1705 -0.4799 -0.0277 -0.9866 -0.9946 ...
##  $ FrequencyBodyAccelerometerJerk-mean()-Y       : num  -0.0352 -0.4134 -0.1287 -0.9816 -0.9854 ...
##  $ FrequencyBodyAccelerometerJerk-mean()-Z       : num  -0.469 -0.685 -0.288 -0.986 -0.991 ...
##  $ FrequencyBodyAccelerometerJerk-std()-X        : num  -0.1336 -0.4619 -0.0863 -0.9875 -0.9951 ...
##  $ FrequencyBodyAccelerometerJerk-std()-Y        : num  0.107 -0.382 -0.135 -0.983 -0.987 ...
##  $ FrequencyBodyAccelerometerJerk-std()-Z        : num  -0.535 -0.726 -0.402 -0.988 -0.992 ...
##  $ FrequencyBodyGyroscope-mean()-X               : num  -0.339 -0.493 -0.352 -0.976 -0.986 ...
##  $ FrequencyBodyGyroscope-mean()-Y               : num  -0.1031 -0.3195 -0.0557 -0.9758 -0.989 ...
##  $ FrequencyBodyGyroscope-mean()-Z               : num  -0.2559 -0.4536 -0.0319 -0.9513 -0.9808 ...
##  $ FrequencyBodyGyroscope-std()-X                : num  -0.517 -0.566 -0.495 -0.978 -0.987 ...
##  $ FrequencyBodyGyroscope-std()-Y                : num  -0.0335 0.1515 -0.1814 -0.9623 -0.9871 ...
##  $ FrequencyBodyGyroscope-std()-Z                : num  -0.437 -0.572 -0.238 -0.944 -0.982 ...
##  $ FrequencyBodyAccelerometerMagnitude-mean()    : num  -0.1286 -0.3524 0.0966 -0.9478 -0.9854 ...
##  $ FrequencyBodyAccelerometerMagnitude-std()     : num  -0.398 -0.416 -0.187 -0.928 -0.982 ...
##  $ FrequencyBodyAccelerometerJerkMagnitude-mean(): num  -0.0571 -0.4427 0.0262 -0.9853 -0.9925 ...
##  $ FrequencyBodyAccelerometerJerkMagnitude-std() : num  -0.103 -0.533 -0.104 -0.982 -0.993 ...
##  $ FrequencyBodyGyroscopeMagnitude-mean()        : num  -0.199 -0.326 -0.186 -0.958 -0.985 ...
##  $ FrequencyBodyGyroscopeMagnitude-std()         : num  -0.321 -0.183 -0.398 -0.932 -0.978 ...
##  $ FrequencyBodyGyroscopeJerkMagnitude-mean()    : num  -0.319 -0.635 -0.282 -0.99 -0.995 ...
##  $ FrequencyBodyGyroscopeJerkMagnitude-std()     : num  -0.382 -0.694 -0.392 -0.987 -0.995 ...
```
And here is a summary of our `tidydata`
```{r}
summary(tidydata)
```
```
##     Subject                   Activity  TimeBodyAccelerometer-mean()-X
##  Min.   : 1.0   WALKING           :30   Min.   :0.2216                
##  1st Qu.: 8.0   WALKING_UPSTAIRS  :30   1st Qu.:0.2712                
##  Median :15.5   WALKING_DOWNSTAIRS:30   Median :0.2770                
##  Mean   :15.5   SITTING           :30   Mean   :0.2743                
##  3rd Qu.:23.0   STANDING          :30   3rd Qu.:0.2800                
##  Max.   :30.0   LAYING            :30   Max.   :0.3015                
##  TimeBodyAccelerometer-mean()-Y TimeBodyAccelerometer-mean()-Z
##  Min.   :-0.040514              Min.   :-0.15251              
##  1st Qu.:-0.020022              1st Qu.:-0.11207              
##  Median :-0.017262              Median :-0.10819              
##  Mean   :-0.017876              Mean   :-0.10916              
##  3rd Qu.:-0.014936              3rd Qu.:-0.10443              
##  Max.   :-0.001308              Max.   :-0.07538              
##  TimeBodyAccelerometer-std()-X TimeBodyAccelerometer-std()-Y
##  Min.   :-0.9961               Min.   :-0.99024             
##  1st Qu.:-0.9799               1st Qu.:-0.94205             
##  Median :-0.7526               Median :-0.50897             
##  Mean   :-0.5577               Mean   :-0.46046             
##  3rd Qu.:-0.1984               3rd Qu.:-0.03077             
##  Max.   : 0.6269               Max.   : 0.61694             
##  TimeBodyAccelerometer-std()-Z TimeGravityAccelerometer-mean()-X
##  Min.   :-0.9877               Min.   :-0.6800                  
##  1st Qu.:-0.9498               1st Qu.: 0.8376                  
##  Median :-0.6518               Median : 0.9208                  
##  Mean   :-0.5756               Mean   : 0.6975                  
##  3rd Qu.:-0.2306               3rd Qu.: 0.9425                  
##  Max.   : 0.6090               Max.   : 0.9745                  
##  TimeGravityAccelerometer-mean()-Y TimeGravityAccelerometer-mean()-Z
##  Min.   :-0.47989                  Min.   :-0.49509                 
##  1st Qu.:-0.23319                  1st Qu.:-0.11726                 
##  Median :-0.12782                  Median : 0.02384                 
##  Mean   :-0.01621                  Mean   : 0.07413                 
##  3rd Qu.: 0.08773                  3rd Qu.: 0.14946                 
##  Max.   : 0.95659                  Max.   : 0.95787                 
##  TimeGravityAccelerometer-std()-X TimeGravityAccelerometer-std()-Y
##  Min.   :-0.9968                  Min.   :-0.9942                 
##  1st Qu.:-0.9825                  1st Qu.:-0.9711                 
##  Median :-0.9695                  Median :-0.9590                 
##  Mean   :-0.9638                  Mean   :-0.9524                 
##  3rd Qu.:-0.9509                  3rd Qu.:-0.9370                 
##  Max.   :-0.8296                  Max.   :-0.6436                 
##  TimeGravityAccelerometer-std()-Z TimeBodyAccelerometerJerk-mean()-X
##  Min.   :-0.9910                  Min.   :0.04269                   
##  1st Qu.:-0.9605                  1st Qu.:0.07396                   
##  Median :-0.9450                  Median :0.07640                   
##  Mean   :-0.9364                  Mean   :0.07947                   
##  3rd Qu.:-0.9180                  3rd Qu.:0.08330                   
##  Max.   :-0.6102                  Max.   :0.13019                   
##  TimeBodyAccelerometerJerk-mean()-Y TimeBodyAccelerometerJerk-mean()-Z
##  Min.   :-0.0386872                 Min.   :-0.067458                 
##  1st Qu.: 0.0004664                 1st Qu.:-0.010601                 
##  Median : 0.0094698                 Median :-0.003861                 
##  Mean   : 0.0075652                 Mean   :-0.004953                 
##  3rd Qu.: 0.0134008                 3rd Qu.: 0.001958                 
##  Max.   : 0.0568186                 Max.   : 0.038053                 
##  TimeBodyAccelerometerJerk-std()-X TimeBodyAccelerometerJerk-std()-Y
##  Min.   :-0.9946                   Min.   :-0.9895                  
##  1st Qu.:-0.9832                   1st Qu.:-0.9724                  
##  Median :-0.8104                   Median :-0.7756                  
##  Mean   :-0.5949                   Mean   :-0.5654                  
##  3rd Qu.:-0.2233                   3rd Qu.:-0.1483                  
##  Max.   : 0.5443                   Max.   : 0.3553                  
##  TimeBodyAccelerometerJerk-std()-Z TimeBodyGyroscope-mean()-X
##  Min.   :-0.99329                  Min.   :-0.20578          
##  1st Qu.:-0.98266                  1st Qu.:-0.04712          
##  Median :-0.88366                  Median :-0.02871          
##  Mean   :-0.73596                  Mean   :-0.03244          
##  3rd Qu.:-0.51212                  3rd Qu.:-0.01676          
##  Max.   : 0.03102                  Max.   : 0.19270          
##  TimeBodyGyroscope-mean()-Y TimeBodyGyroscope-mean()-Z
##  Min.   :-0.20421           Min.   :-0.07245          
##  1st Qu.:-0.08955           1st Qu.: 0.07475          
##  Median :-0.07318           Median : 0.08512          
##  Mean   :-0.07426           Mean   : 0.08744          
##  3rd Qu.:-0.06113           3rd Qu.: 0.10177          
##  Max.   : 0.02747           Max.   : 0.17910          
##  TimeBodyGyroscope-std()-X TimeBodyGyroscope-std()-Y
##  Min.   :-0.9943           Min.   :-0.9942          
##  1st Qu.:-0.9735           1st Qu.:-0.9629          
##  Median :-0.7890           Median :-0.8017          
##  Mean   :-0.6916           Mean   :-0.6533          
##  3rd Qu.:-0.4414           3rd Qu.:-0.4196          
##  Max.   : 0.2677           Max.   : 0.4765          
##  TimeBodyGyroscope-std()-Z TimeBodyGyroscopeJerk-mean()-X
##  Min.   :-0.9855           Min.   :-0.15721              
##  1st Qu.:-0.9609           1st Qu.:-0.10322              
##  Median :-0.8010           Median :-0.09868              
##  Mean   :-0.6164           Mean   :-0.09606              
##  3rd Qu.:-0.3106           3rd Qu.:-0.09110              
##  Max.   : 0.5649           Max.   :-0.02209              
##  TimeBodyGyroscopeJerk-mean()-Y TimeBodyGyroscopeJerk-mean()-Z
##  Min.   :-0.07681               Min.   :-0.092500             
##  1st Qu.:-0.04552               1st Qu.:-0.061725             
##  Median :-0.04112               Median :-0.053430             
##  Mean   :-0.04269               Mean   :-0.054802             
##  3rd Qu.:-0.03842               3rd Qu.:-0.048985             
##  Max.   :-0.01320               Max.   :-0.006941             
##  TimeBodyGyroscopeJerk-std()-X TimeBodyGyroscopeJerk-std()-Y
##  Min.   :-0.9965               Min.   :-0.9971              
##  1st Qu.:-0.9800               1st Qu.:-0.9832              
##  Median :-0.8396               Median :-0.8942              
##  Mean   :-0.7036               Mean   :-0.7636              
##  3rd Qu.:-0.4629               3rd Qu.:-0.5861              
##  Max.   : 0.1791               Max.   : 0.2959              
##  TimeBodyGyroscopeJerk-std()-Z TimeBodyAccelerometerMagnitude-mean()
##  Min.   :-0.9954               Min.   :-0.9865                      
##  1st Qu.:-0.9848               1st Qu.:-0.9573                      
##  Median :-0.8610               Median :-0.4829                      
##  Mean   :-0.7096               Mean   :-0.4973                      
##  3rd Qu.:-0.4741               3rd Qu.:-0.0919                      
##  Max.   : 0.1932               Max.   : 0.6446                      
##  TimeBodyAccelerometerMagnitude-std()
##  Min.   :-0.9865                     
##  1st Qu.:-0.9430                     
##  Median :-0.6074                     
##  Mean   :-0.5439                     
##  3rd Qu.:-0.2090                     
##  Max.   : 0.4284                     
##  TimeGravityAccelerometerMagnitude-mean()
##  Min.   :-0.9865                         
##  1st Qu.:-0.9573                         
##  Median :-0.4829                         
##  Mean   :-0.4973                         
##  3rd Qu.:-0.0919                         
##  Max.   : 0.6446                         
##  TimeGravityAccelerometerMagnitude-std()
##  Min.   :-0.9865                        
##  1st Qu.:-0.9430                        
##  Median :-0.6074                        
##  Mean   :-0.5439                        
##  3rd Qu.:-0.2090                        
##  Max.   : 0.4284                        
##  TimeBodyAccelerometerJerkMagnitude-mean()
##  Min.   :-0.9928                          
##  1st Qu.:-0.9807                          
##  Median :-0.8168                          
##  Mean   :-0.6079                          
##  3rd Qu.:-0.2456                          
##  Max.   : 0.4345                          
##  TimeBodyAccelerometerJerkMagnitude-std()
##  Min.   :-0.9946                         
##  1st Qu.:-0.9765                         
##  Median :-0.8014                         
##  Mean   :-0.5842                         
##  3rd Qu.:-0.2173                         
##  Max.   : 0.4506                         
##  TimeBodyGyroscopeMagnitude-mean() TimeBodyGyroscopeMagnitude-std()
##  Min.   :-0.9807                   Min.   :-0.9814                 
##  1st Qu.:-0.9461                   1st Qu.:-0.9476                 
##  Median :-0.6551                   Median :-0.7420                 
##  Mean   :-0.5652                   Mean   :-0.6304                 
##  3rd Qu.:-0.2159                   3rd Qu.:-0.3602                 
##  Max.   : 0.4180                   Max.   : 0.3000                 
##  TimeBodyGyroscopeJerkMagnitude-mean()
##  Min.   :-0.99732                     
##  1st Qu.:-0.98515                     
##  Median :-0.86479                     
##  Mean   :-0.73637                     
##  3rd Qu.:-0.51186                     
##  Max.   : 0.08758                     
##  TimeBodyGyroscopeJerkMagnitude-std() FrequencyBodyAccelerometer-mean()-X
##  Min.   :-0.9977                      Min.   :-0.9952                    
##  1st Qu.:-0.9805                      1st Qu.:-0.9787                    
##  Median :-0.8809                      Median :-0.7691                    
##  Mean   :-0.7550                      Mean   :-0.5758                    
##  3rd Qu.:-0.5767                      3rd Qu.:-0.2174                    
##  Max.   : 0.2502                      Max.   : 0.5370                    
##  FrequencyBodyAccelerometer-mean()-Y FrequencyBodyAccelerometer-mean()-Z
##  Min.   :-0.98903                    Min.   :-0.9895                    
##  1st Qu.:-0.95361                    1st Qu.:-0.9619                    
##  Median :-0.59498                    Median :-0.7236                    
##  Mean   :-0.48873                    Mean   :-0.6297                    
##  3rd Qu.:-0.06341                    3rd Qu.:-0.3183                    
##  Max.   : 0.52419                    Max.   : 0.2807                    
##  FrequencyBodyAccelerometer-std()-X FrequencyBodyAccelerometer-std()-Y
##  Min.   :-0.9966                    Min.   :-0.99068                  
##  1st Qu.:-0.9820                    1st Qu.:-0.94042                  
##  Median :-0.7470                    Median :-0.51338                  
##  Mean   :-0.5522                    Mean   :-0.48148                  
##  3rd Qu.:-0.1966                    3rd Qu.:-0.07913                  
##  Max.   : 0.6585                    Max.   : 0.56019                  
##  FrequencyBodyAccelerometer-std()-Z
##  Min.   :-0.9872                   
##  1st Qu.:-0.9459                   
##  Median :-0.6441                   
##  Mean   :-0.5824                   
##  3rd Qu.:-0.2655                   
##  Max.   : 0.6871                   
##  FrequencyBodyAccelerometerJerk-mean()-X
##  Min.   :-0.9946                        
##  1st Qu.:-0.9828                        
##  Median :-0.8126                        
##  Mean   :-0.6139                        
##  3rd Qu.:-0.2820                        
##  Max.   : 0.4743                        
##  FrequencyBodyAccelerometerJerk-mean()-Y
##  Min.   :-0.9894                        
##  1st Qu.:-0.9725                        
##  Median :-0.7817                        
##  Mean   :-0.5882                        
##  3rd Qu.:-0.1963                        
##  Max.   : 0.2767                        
##  FrequencyBodyAccelerometerJerk-mean()-Z
##  Min.   :-0.9920                        
##  1st Qu.:-0.9796                        
##  Median :-0.8707                        
##  Mean   :-0.7144                        
##  3rd Qu.:-0.4697                        
##  Max.   : 0.1578                        
##  FrequencyBodyAccelerometerJerk-std()-X
##  Min.   :-0.9951                       
##  1st Qu.:-0.9847                       
##  Median :-0.8254                       
##  Mean   :-0.6121                       
##  3rd Qu.:-0.2475                       
##  Max.   : 0.4768                       
##  FrequencyBodyAccelerometerJerk-std()-Y
##  Min.   :-0.9905                       
##  1st Qu.:-0.9737                       
##  Median :-0.7852                       
##  Mean   :-0.5707                       
##  3rd Qu.:-0.1685                       
##  Max.   : 0.3498                       
##  FrequencyBodyAccelerometerJerk-std()-Z FrequencyBodyGyroscope-mean()-X
##  Min.   :-0.993108                      Min.   :-0.9931                
##  1st Qu.:-0.983747                      1st Qu.:-0.9697                
##  Median :-0.895121                      Median :-0.7300                
##  Mean   :-0.756489                      Mean   :-0.6367                
##  3rd Qu.:-0.543787                      3rd Qu.:-0.3387                
##  Max.   :-0.006236                      Max.   : 0.4750                
##  FrequencyBodyGyroscope-mean()-Y FrequencyBodyGyroscope-mean()-Z
##  Min.   :-0.9940                 Min.   :-0.9860                
##  1st Qu.:-0.9700                 1st Qu.:-0.9624                
##  Median :-0.8141                 Median :-0.7909                
##  Mean   :-0.6767                 Mean   :-0.6044                
##  3rd Qu.:-0.4458                 3rd Qu.:-0.2635                
##  Max.   : 0.3288                 Max.   : 0.4924                
##  FrequencyBodyGyroscope-std()-X FrequencyBodyGyroscope-std()-Y
##  Min.   :-0.9947                Min.   :-0.9944               
##  1st Qu.:-0.9750                1st Qu.:-0.9602               
##  Median :-0.8086                Median :-0.7964               
##  Mean   :-0.7110                Mean   :-0.6454               
##  3rd Qu.:-0.4813                3rd Qu.:-0.4154               
##  Max.   : 0.1966                Max.   : 0.6462               
##  FrequencyBodyGyroscope-std()-Z FrequencyBodyAccelerometerMagnitude-mean()
##  Min.   :-0.9867                Min.   :-0.9868                           
##  1st Qu.:-0.9643                1st Qu.:-0.9560                           
##  Median :-0.8224                Median :-0.6703                           
##  Mean   :-0.6577                Mean   :-0.5365                           
##  3rd Qu.:-0.3916                3rd Qu.:-0.1622                           
##  Max.   : 0.5225                Max.   : 0.5866                           
##  FrequencyBodyAccelerometerMagnitude-std()
##  Min.   :-0.9876                          
##  1st Qu.:-0.9452                          
##  Median :-0.6513                          
##  Mean   :-0.6210                          
##  3rd Qu.:-0.3654                          
##  Max.   : 0.1787                          
##  FrequencyBodyAccelerometerJerkMagnitude-mean()
##  Min.   :-0.9940                               
##  1st Qu.:-0.9770                               
##  Median :-0.7940                               
##  Mean   :-0.5756                               
##  3rd Qu.:-0.1872                               
##  Max.   : 0.5384                               
##  FrequencyBodyAccelerometerJerkMagnitude-std()
##  Min.   :-0.9944                              
##  1st Qu.:-0.9752                              
##  Median :-0.8126                              
##  Mean   :-0.5992                              
##  3rd Qu.:-0.2668                              
##  Max.   : 0.3163                              
##  FrequencyBodyGyroscopeMagnitude-mean()
##  Min.   :-0.9865                       
##  1st Qu.:-0.9616                       
##  Median :-0.7657                       
##  Mean   :-0.6671                       
##  3rd Qu.:-0.4087                       
##  Max.   : 0.2040                       
##  FrequencyBodyGyroscopeMagnitude-std()
##  Min.   :-0.9815                      
##  1st Qu.:-0.9488                      
##  Median :-0.7727                      
##  Mean   :-0.6723                      
##  3rd Qu.:-0.4277                      
##  Max.   : 0.2367                      
##  FrequencyBodyGyroscopeJerkMagnitude-mean()
##  Min.   :-0.9976                           
##  1st Qu.:-0.9813                           
##  Median :-0.8779                           
##  Mean   :-0.7564                           
##  3rd Qu.:-0.5831                           
##  Max.   : 0.1466                           
##  FrequencyBodyGyroscopeJerkMagnitude-std()
##  Min.   :-0.9976                          
##  1st Qu.:-0.9802                          
##  Median :-0.8941                          
##  Mean   :-0.7715                          
##  3rd Qu.:-0.6081                          
##  Max.   : 0.2878
```

The last step of our task is to save our tidydata into a file called tidydata.txt

```{r}
write.table(tidydata, file = "tidydata.txt",row.name=FALSE)
```

===============================

