 'Getting and Cleaning Data' Class Project - David R Scott ('Belaqua@me.com') 
 Created April 10th, 2016, in R v3.2.4
(Please Note: some font irregularity exisits in this docuemnt, which I have not been able to resolve. Please excuse the occational words and phrases which abruptly shift to larger bold font. Thanks, -DS.

This program creates as its output a tidy data set called "ActivityDataSummarized.txt", which
includes summary statistics from SmartPhones Dataset on Human Activity Recognition devices (please 
see the attached R program script 'run_analsis.R', and the data details in the project codebook, both
 of which are attached to this repo.)
The program accomplishes the 5 primary sucess criteria of given for this project, in 5 programming steps:
                            1: Merge the Training and Test Data into a single 'tidy' data set. 
                            2: Extract only the Mean and Standard Deviation measures from each 
                                of the available measurement data fields on that data set.
                            3: Apply descriptive activity names to name the Activity variable   
                               in the data set.
                            4: Label the data set with descriptive variable names.
                            5: Create a final  tidy data set with the average of each variable, 
                               for each Activity and each Subject. 
                               This file is called "ActivityDataSummarized.txt"
The 5 criteria above  roughly correspond to the 5 parts of the program. However, this correspondence is not
exact. For example, an exception is part 1, where test and training data are combined. Though this is still 
done in part 1, the bringing together of the 'X' (measurements) and 'Y' (Activities) columnns into a single 
data set is accomplished only at the end of part 2, after the measure data column list has been reduced. 
------------------------------------------------------------------------------------------------------------
DEPENDENCIES:
This programming depends on the working directory including the following 
files which are part of the project data package. It will NOT run correctly 
unless these files are in the Working directory:
  "X_test.txt"          "X_train.txt"         "y_test.txt"          "y_train.txt"
  "subject_test.txt"    "subject_train.txt"  "activity_labels.txt" "features.txt"

Part 5 alse requires the plyr package.

PART 1:Merge the Training and Test Data into a single 'tidy' data set.
-----------------------------------------------------------------------
First, the program combines the Training and Test data sets for the X and then Y data.

Next, to be able to determine what the final feature set will be, the program will create feature names. 
This requires reading in features for X, and also creating them for Y, since the Y (activites) data 
are numeric codes in the source data. Also I have created a Data Use column (train/test) and the subject column (1-30); 
d then added them to the data as column headers. 

-----------------------------------------------------------------------
-PART 2: Limit to only Mean and Standard Deviaton measures. 
-----------------------------------------------------------------------
Here the program separates out the Subject data, to re-attache later after 
limiting to the Mean and SD measures. Note that the data has 561 columns of measure data, and so the 
subject (ID of the person being studied) data are listed as the 563rd column in the newly combined X data set.
 
 The column name vector has to be created complete with the column names for the new 'Test/Train' indicator 
 and and Subject ID, to combine with the other feature names. 

Finally, this section ends by combining the X (measured data, subject and 'Test/Train indicator) and Y (Activity Category) 
into a single data set.

-----------------------------------------------------------------------
-PART 3: Apply descriptive activity names to name the Activity variable   
-        in the data set.
-----------------------------------------------------------------------

First, the program creates decriptive names for the numeric activity categories, 
 by reading in the activity labels file, renaming the headers, and merging to 
 the ActivityData file.

This is done by choosing only the activity data associated with the final column list, based on the 'mean' and 
'standard deviation' criterion used above.

-----------------------------------------------------------------------
-PART 4: Label the data set with descriptive variable names.  
-----------------------------------------------------------------------
This code section replaces abbreviations with actual names of the measures, via the gsub function.
(See the codebook for more details on what these terms mean.)

-----------------------------------------------------------------------
-PART 5: Create a 2nd tidy data set with the average of each variable, 
-        for each Activity and each Subject.  
-----------------------------------------------------------------------
This is the final section of program code, where the numeric data are 
summarized as mean values by subject and activity. The final output is
a text file called "ActivityDataSummarized.txt", which will write to the 
working directory.

