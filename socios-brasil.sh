#!/bin/bash

# Author:  Cristian Simioni Milani (cristiansimionimilani@gmail.com)
# Date:    27.11.2019
# Version: 1.0.0

SCRIPT=$(basename $0)

# Print usage help message
usage() {
  echo "Usage: ./$SCRIPT [-h] [-d -c -u -b|bucket name]"
  echo "       -h .... print help message "
  echo "       -d .... download all zip file from website"
  echo "       -c .... convert zip files to CSV"
  echo "       -u .... upload files to bucket s3"
  echo 
  echo "Examples:"
  echo "       ./$SCRIPT -d -c -u -b <bucket name>     [for execute the whole process]"
  echo "       ./$SCRIPT -d                            [only download the zip files]"
  exit 1
}

# Get script options
while getopts "hdcub:" OPT; do
  case $OPT in
  "h") usage;;
  "d") opt_D=1;; # Download zip files
  "c") opt_C=1;; # Convert zip files to CSV
  "u") opt_U=1;; # Upload files to bucket s3
  "b") BUCKET_NAME=$OPTARG;;
  \?)  usage;;
  esac
done

# Defines
DOWNLOAD_DIR="./zip-files"
CSV_DIR="./csv-files"
# This is the official website
#WEBPAGE="http://receita.economia.gov.br/orientacao/tributaria/cadastros/cadastro-nacional-de-pessoas-juridicas-cnpj/dados-publicos-cnpj"
#DOWNLOAD_URL="http://200.152.38.155/CNPJ/"
# This is a better mirror that provides the same files. 
# I'm using it because the download speed of receita.economia.gov.br website is VERY slow!
WEBPAGE="https://data.brasil.io/mirror/socios-brasil/_meta/list.html"
DOWNLOAD_URL="https://data.brasil.io/mirror/socios-brasil/"
FILE_PREFIX="DADOS_ABERTOS_CNPJ_" # DADOS_ABERTOS_CNPJ_03
FILE_EXTENSION=".zip"

# Step 1: Download all necessary zip files
if [ $opt_D ]; then

if [ ! -d "$DOWNLOAD_DIR" ]; then
  echo "Creating a directory to save all zip files..."
  mkdir -p $DOWNLOAD_DIR
fi

echo "Downloading all necessary files..."
for i in {1..20}; do #TODO: remove hardcoded number of files
  
  # It's needed to add 0 before file number if it is less than 10. Name convertion of the website
  if [ $i -lt 10 ]; then
    FILE_NAME="${FILE_PREFIX}0$i${FILE_EXTENSION}"   
  else
    FILE_NAME="${FILE_PREFIX}${i}${FILE_EXTENSION}"
  fi

  WGET_CMD="wget -qcNt0 --show-progress $DOWNLOAD_URL$FILE_NAME -P $DOWNLOAD_DIR" #TODO: use md5sum to make sure we have the correct file
  eval $WGET_CMD; xR=$?

  if [ $xR -ne 0 ]; then
    echo "Failed to download $FILE_NAME. Aborting... :("
    exit 1
  fi

  echo "File $FILE_NAME has been downloaded. :)"

done

fi

## Step 2: Convert .zip file to CSV files
if [ $opt_C ]; then

if [ ! -d "$CSV_DIR" ]; then
  echo "Creating output directory to save CSV files..."
  mkdir -p $CSV_DIR
fi

echo "Starting the convertion of zip file to CSV files. Be patient, it takes time..."
CNPJ_CMD="python3 CNPJ-full/cnpj.py $DOWNLOAD_DIR csv $CSV_DIR --dir"
eval "$CNPJ_CMD"; xR=$?

# Check with convertion has finished sucessfully
if [ $xR -ne 0 ]; then
  echo "Failed to convert the zip file to CSV. Aborting... :("
  exit 1
fi
echo "The convertion has finished sucessfully. :)"

fi

## Step 3: Upload all CSV files to Amazon Bucket S3
if [ $opt_U ]; then

# Upload files using AWS CLI
echo "Starting the upload of all CSV files to Bucket $BUCKET_NAME"
AWS_CMD="aws s3 sync $CSV_DIR s3://$BUCKET_NAME/"

eval "$AWS_CMD"; xR=$?

# Check with upload has finished properly
if [ $xR -ne 0 ]; then
  echo "Failed to upload CSV files. Aborting... :("
  exit 1
fi
echo "The upload of CSV files has finished sucessfully. :)"

fi