#!/bin/bash
  
#aws s3api list-buckets | grep -i Name | awk -F':' '{print $2}' | awk -F'"' '{print $2}' > aws_bucket_list

file="gcp_bucket_list"

if [ -f $file ] ; then
    rm $file
fi

for i in $(cat projectfile)
do
 echo "creating $i"
 gsutil ls -p "$i" gs:// | awk -F'/' '{print $3}' >> gcp_bucket_list
done

#copying dev bucket list
awk 'NR==FNR{a[$0];next}!($0 in a)' gcp_bucket_list dev_aws_bucket_list  > dev_bucket_list


for j in $(cat dev_bucket_list)
do
 echo "creating $j"
 gsutil mb -p runscope-228819 -c Standard -l us-east4 -b on gs://"$j"
 gsutil -m cp -R s3://"$j" gs://"$j"
done

#copying prod bucket list
awk 'NR==FNR{a[$0];next}!($0 in a)' gcp_bucket_list prod_aws_bucket_list  > prod_bucket_list

for j in $(cat prod_bucket_list)
do
 gsutil mb -p esd-runscope-prd -c Standard -l us-east4 -b on gs://"$j"
 gsutil -m cp -R s3://"$j" gs://"$j"
done
