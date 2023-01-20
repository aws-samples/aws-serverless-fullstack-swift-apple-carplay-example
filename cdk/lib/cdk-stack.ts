import * as path from "path"
import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as Lambda from 'aws-cdk-lib/aws-lambda';
import * as iam from 'aws-cdk-lib/aws-iam';
import * as secretsmanager from 'aws-cdk-lib/aws-secretsmanager';
import { CfnPlaceIndex } from 'aws-cdk-lib/aws-location'

export class CdkStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // create secrets manager secret to hold the air quality api key
    const aqiAPIKeySecret = new secretsmanager.Secret(this, 'Secret', {
      secretName: 'SwiftCarplayAPISecret'
    });

    // create an Amazon Location Place Index
    const placeIndex = new CfnPlaceIndex(this, 'locationPlaceIndex', {
      dataSource: 'Esri',
      indexName: 'SwiftCarPlayPlaceIndex',
      pricingPlan: 'RequestBasedUsage'
    })
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
      architecture: Lambda.Architecture.X86_64,
      memorySize: 512,
      environment: {
        "API_KEY_SECRET_NAME": aqiAPIKeySecret.secretName,
        "API_ENDPOINT": this.node.tryGetContext('aqiAPIEndpoint')
      }
    });

    // grant the get weather lambda function permission to read the air quality api secret
    aqiAPIKeySecret.grantRead(lambdaGetWeather);

    // create the docker image based lambda function to get-places
    dockerfile = path.join(__dirname, "../lambda/functions/get-places/");

    const lambdaGetPlaces = new Lambda.DockerImageFunction(this, "lambdaGetPlaces", {
      functionName: "swift-carplay-location-get-places",
      code: Lambda.DockerImageCode.fromImageAsset(dockerfile, {
        buildArgs:{
          "TARGET_NAME":"get-places"
      }}),
      timeout:cdk.Duration.minutes(3),
      architecture: Lambda.Architecture.X86_64,
      memorySize: 512,
      environment: {
        "PLACE_INDEX_NAME": placeIndex.indexName
      }
    });

    // grant permission to the get-places function to interact with Amazon Location
    lambdaGetPlaces.addToRolePolicy(new iam.PolicyStatement({
      effect: iam.Effect.ALLOW,
      actions: [
        "geo:SearchPlaceIndexForText"
      ],
      resources: [placeIndex.attrIndexArn]
    }))

    // create the docker image based lambda function to get-location
    dockerfile = path.join(__dirname, "../lambda/functions/get-location/");

    const lambdaGetLocation = new Lambda.DockerImageFunction(this, "lambdaGetLocation", {
      functionName: "swift-carplay-location-get-location",
      code: Lambda.DockerImageCode.fromImageAsset(dockerfile, {
        buildArgs:{
          "TARGET_NAME":"get-location"
      }}),
      timeout:cdk.Duration.minutes(3),
      architecture: Lambda.Architecture.X86_64,
      memorySize: 512,
      environment: {
        "PLACE_INDEX_NAME": placeIndex.indexName
      }
    });

    // grant permission to the get-location function to interact with Amazon Location Service
    lambdaGetLocation.addToRolePolicy(new iam.PolicyStatement({
      effect: iam.Effect.ALLOW,
      actions: [
        "geo:SearchPlaceIndexForPosition"
      ],
      resources: [placeIndex.attrIndexArn]
    }))
  }
}
