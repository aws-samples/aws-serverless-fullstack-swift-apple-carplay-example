ENDPOINT=$1
API_KEY=$2
REGION=$3

cat << EOF > amplify/amplifyconfiguration.json 
{
    "UserAgent": "aws-amplify-cli/2.0",
    "Version": "1.0",
    "api": {
        "plugins": {
            "awsAPIPlugin": {
                "swiftcarplaylocation": {
                    "endpointType": "GraphQL",
                    "endpoint": "$ENDPOINT",
                    "region": "$REGION",
                    "authorizationType": "API_KEY",
                    "apiKey": "$API_KEY"
                }
            }
        }
    }
}
EOF
