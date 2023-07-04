install.packages("xlsx")
install.packages("caret")
install.packages("/Users/kingsley/Desktop/VTC\ DSA\ SEM3/ITP\ 4869/Flask-master",repos=NULL,type="source")
install.packages("tm")
install.packages("randomForest")
install.packages("rpart.plot")
install.packages("SnowballC")
#import library
library(xlsx)
library(caret)
library(dplyr)
library(tm)
library(randomForest)
library(rpart)
library(rpart.plot)
library(SnowballC)
Sys.setlocale(category = "LC_ALL", locale = "cht")

#Data Preparation ----------------------------------------------------

#read file
raw.data <- read.xlsx("/Users/kingsley/Desktop/VTC\ DSA\ SEM3/ITP\ 4869/Flask-master/Dataset.xlsx",1)
raw.data <- raw.data[1:1000,]
data_no_index <- select(raw.data,-1)

#set up a word db for NLP
corpusdb <- Corpus(VectorSource(data_no_index$title))
#turn the corpusdb into vector and remove punctuation
corpusdbVector <- as.vector(unlist(corpusdb))
corpusdbVector <- gsub('[[:punct:]]',' ',corpusdbVector[1:1000])
corpusdbVector <- gsub('[[:digit:]]',' ',corpusdbVector[1:1000])
#turn the text into lower case
corpusdbVector <- tolower(corpusdbVector)

frequencies <- DocumentTermMatrix(corpusdbVector)
sparse <- removeSparseTerms(frequencies,0.99)
tSparse = as.data.frame(as.matrix(sparse))

#fit the job code data
fitted.my.jobCode <- data_no_index[,"job_code_1A"]
fitted.my.jobCode <- gsub('\\#','',fitted.my.jobCode)
fitted.my.jobCode[which(fitted.my.jobCode=="0")] <- "000"
fitted.my.jobCode[grep("[[:punct:]]000[[:punct:]]",fitted.my.jobCode)] <- "000"
fitted.my.jobCode[grep("[[:punct:]]000",fitted.my.jobCode)] <- "000"
fitted.my.jobCode[grep("000[[:punct:]]",fitted.my.jobCode)] <- "000"
fitted.my.jobCode[is.na(fitted.my.jobCode)] <- "000"
#get first labelled code
i=1
for (variable in fitted.my.jobCode) {
  fitted.my.jobCode[i] <- substr(variable,1,3)
  i=i+1
}


#adding dependent variable
tSparse$recommended_code <- fitted.my.jobCode

##Data Modeling -----------------------------------------------------------
set.seed(150)#100

#set the training set and testset
trainRange <- sample(1:1000,750)
trainset <- tSparse[trainRange,]
testset <- tSparse[-trainRange,]

trainset$recommended_code <- as.factor(trainset$recommended_code)

#building decision tree
tree_model <- rpart(trainset$recommended_code~.,data=trainset,control = rpart.control(minsplit=2, minibucket=1))
predictTree <- predict(tree_model, newdata=testset, type="class")
table(testset$recommended_code, predictTree) 
rpart.plot(tree_model)
printcp(tree_model)
# set the baseline accuracy of the model
prop.table(table(tSparse$recommended_code))*100
# Show the multiple variable confusion matrix
cm = as.matrix(table(testset$recommended_code, predictTree))
#Creates vectors having data points
predicted_value <- factor(testset$recommended_code)
predicted_value <- factor(predictTree)
#Creating confusion matrix
result <- confusionMatrix(data=predicted_value, reference = predicted_value)
#Display results
result

