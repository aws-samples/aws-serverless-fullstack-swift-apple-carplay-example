import * as path from "path"
import * as cdk from '@aws-cdk/core';
import * as Lambda from '@aws-cdk/aws-lambda'
import * as iam from '@aws-cdk/aws-iam'
import * as secretsmanager from '@aws-cdk/aws-secretsmanager';

export class CdkStack extends cdk.Stack {
  constructor(scope: cdk.Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // create secrets manager secret to hold the air quality api key
    const aqiAPIKeySecret = new secretsmanager.Secret(this, 'Secret');

    // create the docker image based lambda function to get-weather
    // pass in the api secret name and the api endpoint as environment variables
    let dockerfile = path.join(__dirname, "../lambda/functions/get-weather/");

    const lambdaGetWeather = new Lambda.DockerImageFunction(this, "lambdaGetWeather", {
      functionName: "swift-carplay-location-get-weather",
      code: Lambda.DockerImageCode.fromImageAsset(dockerfile, {
        buildArgs:{
          "TARGET_NAME":"get-weather"
      }}),
      timeout:cdk.Duration.minutes(3),
      memorySize: 512,
      environment: {
        "API_KEY_SECRET_NAME": aqiAPIKeySecret.secretName,
        "API_ENDPOINT": this.node.tryGetContext('aqiAPIEndpoint')
      }
    });

    // grant the get weather lambda function permission to read the air quality api secret
    aqiAPIKeySecret.grantRead(lambdaGetWeather);

    // output the secret name so it can be identified after the cdk stack deploys
    new cdk.CfnOutput(this, "aqiAPIKeySecretName", {
      value: aqiAPIKeySecret.secretName
    });

    // create the docker image based lambda function to get-places
    // pass in the api end point for Amazon Location that will be used by the function

    dockerfile = path.join(__dirname, "../lambda/functions/get-places/");

    let locationApiEndpoint = this.node.tryGetContext('locationApiEndpoint')
    locationApiEndpoint = locationApiEndpoint.replace("{REGION}", this.region)

    const lambdaGetPlaces = new Lambda.DockerImageFunction(this, "lambdaGetPlaces", {
      functionName: "swift-carplay-location-get-places",
      code: Lambda.DockerImageCode.fromImageAsset(dockerfile, {
        buildArgs:{
          "TARGET_NAME":"get-places"
      }}),
      timeout:cdk.Duration.minutes(3),
      memorySize: 512,
      environment: {
        "API_ENDPOINT": locationApiEndpoint
      }
    });

    // grant permission to the get-places function to interact with Amazon Location
    let locationArn = this.node.tryGetContext('locationArn')
    locationArn = locationArn.replace("{REGION}", this.region)
    locationArn = locationArn.replace("{ACCOUNT}", this.account)

    lambdaGetPlaces.addToRolePolicy(new iam.PolicyStatement({
      effect: iam.Effect.ALLOW,
      actions: [
        "geo:SearchPlaceIndexForPosition",
        "geo:SearchPlaceIndexForText"
      ],
      resources: [locationArn]
    }))
  }
}
