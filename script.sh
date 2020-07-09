#! /bin/bash
touch data.dat
echo "enter security group ID"
read sgID

echo "enter your aws profile (enter default if you don't have profile set"
read awsprofile
#region=us-west-1
aws ec2 describe-instances --query 'Reservations[*].Instances[*].{Names:Tags[?Key==`Name`]|[0].Value,SG:SecurityGroups[*].GroupId}' --profile $awsprofile --region eu-west-1 | grep -w '\"Names\"\|sg'|awk '/Names/{if (NR!=1)print "\t\t"$2 ;next}{printf $1 $7}END{print "";}' > data.dat
echo "">> data.dat
aws rds describe-db-instances  --profile $awsprofile --region eu-west-1 | grep -w '\"VpcSecurityGroupId\"\|DBInstanceIdentifier'|sed 'N;s/\n/ /'| tr "\"" " " >>data.dat
aws elb describe-load-balancers --profile $awsprofile --region eu-west-1 | grep '\"LoadBalancerName\"\|sg-'| tail -r|tr -d " \t\n\r"| perl -pe 's#(?<=.)(?="LoadBalancerName")#\n#g' >> data.dat
aws elbv2 describe-load-balancers --profile $awsprofile --region eu-west-1 | grep '\"LoadBalancerName\"\|sg-'| tail -r|tr -d " \t\n\r"| perl -pe 's#(?<=.)(?="LoadBalancerName")#\n#g' >> data.dat

#region us-west-2
aws ec2 describe-instances --query 'Reservations[*].Instances[*].{Names:Tags[?Key==`Name`]|[0].Value,SG:SecurityGroups[*].GroupId}' --profile $awsprofile --region us-west-2 | grep -w '\"Names\"\|sg'|awk '/Names/{if (NR!=1)print "\t\t"$2 ;next}{printf $1 $7}END{print "";}' >> data.dat
echo "">> data.dat
aws rds describe-db-instances --profile $awsprofile --profile work --region us-west-2 | grep -w '\"VpcSecurityGroupId\"\|DBInstanceIdentifier'|sed 'N;s/\n/ /'>>data.dat
aws elb describe-load-balancers --profile $awsprofile --region us-west-2 | grep '\"LoadBalancerName\"\|sg-'| tail -r|tr -d " \t\n\r"| perl -pe 's#(?<=.)(?="LoadBalancerName")#\n#g' >> data.dat
aws elbv2 describe-load-balancers --profile $awsprofile --region us-west-2 | grep '\"LoadBalancerName\"\|sg-'| tail -r|tr -d " \t\n\r"| perl -pe 's#(?<=.)(?="LoadBalancerName")#\n#g' >> data.dat

#search the network interface
aws ec2 describe-network-interfaces --filters Name=group-id,Values=$sgID --profile $awsprofile --region eu-west-1 | grep -w '\"Description\"\|NetworkInterfaceId'|sed 'N;s/\n/ /' >searchResult1
aws ec2 describe-network-interfaces --filters Name=group-id,Values=$sgID --profile $awsprofile --region us-west-2 | grep -w '\"Description\"\|NetworkInterfaceId'|sed 'N;s/\n/ /' >searchResult2



echo "this security group id $sgID, is associated  with  the following network interface(s):"
cat searchResult1
cat searchResult2

echo "searching for exact resource(s) associated with the above security group"
sleep 10
cat data.dat | grep $sgID
#cleaning up....
rm -r data.dat searchResult2 searchResult1
