# AWS Full Stack Swift with Apple CarPlay

This application demonstrates a full-stack Apple CarPlay app that uses Swift for both the UI and the backend services in AWS.  The app implements the latest features of AWS Lambda that allow you to develop and deploy functions written in Swift as Docker images.

This is important as it allows frontend developers who are proficient in Swift to leverage their skills in building out the backend of their applications.  It also enables an entire geneation of Swift engineers to build apps on AWS using their language of choice.

This sample app is useful for iOS/CarPlay developers learning how to interact with backend services running on AWS.  It is also beneficial for customers who want to build their backend infrastructure using Swift, regardless if there is an iOS front end component.  Explore the CDK portion of this project to discover how to build and deploy Swift based Lambda functions to AWS.

![Image description](images/carplay.jpg)

The application tracks the user's current location and displays the current weather, air quality, and nearby points of interest such as coffee, food, and fuel. The app also allows you to send messages from the AWS Cloud to the app which are displayed in real-time to the user.


## Architecture

![Image description](images/architecture.jpg)

1. The Apple CarPlay app is written in Swift and uses AWS Amplify libraries to communicate with services in the AWS Cloud.
2. All data is served to the client application via an AWS AppSync GraphQL API.  As the client changes its location, queries are sent via the API to obtain weather, air quality, and points of interest in the vicinity of the user.
3. The AWS AppSync GraphQL API uses Lambda functions written in Swift to interact with Amazon Location Service for points of interest.  It also communicates with a 3rd party API outside of AWS for weather and air quality. The API key for the 3rd party weather service is stored in AWS Secrets Manager.
4. The Lambda functions use the new [AWS SDK for Swift](https://github.com/awslabs/aws-sdk-swift) to interact with the AWS services!
5. The client establishes a subscription to AWS AppSync to receive real-time notifications triggered from the cloud.  These messages are also stored in an Amazon DynamoDB table.

## Getting Started

### **Prerequisites**
The following software was used in the development of this application.  While it may work with alternative versions, we recommend you deploy the specified minimum version.

1. An AWS account in which you have Administrator access.

2. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) (2.1.32) the AWS Command Line Interface (CLI) is used to configure your connection credentials to AWS.  These credentials are used by the CDK, Amplify, and the CLI.

3. [Node.js](https://nodejs.org/en/download/current/) (^16.8.0) with NPM (^7.19.1)

4. [Typescript](https://www.npmjs.com/package/typescript) (^4.2.4) Typescript is required by the Cloud Development Kit (CDK).

6. [Amplify CLI](https://docs.amplify.aws/cli/start/install) (^6.3.1) Amplify is used to create the AWS AppSync API and generate the client side Swift code to interact with AWS.

7. [IQ Air](https://www.iqair.com/us/air-pollution-data-api) is a 3rd party API used to obtain weather and air quality for a specified location.  Create a free Community Edition API key.

8. [Docker Desktop](https://www.docker.com/products/docker-desktop) (4.1.1) Docker is used to compile the Swift Lambda functions into a Docker image. 

9. [Xcode](https://developer.apple.com/xcode/) (13.0) Xcode is used to build and debug the CarPlay application.  You will need iOS Simulator 14.0 enabled.

### **Installation**

The application utilizes the AWS Cloud Development Kit (CDK) and Docker to compile and deploy your Swift based Lambda functions.  It also utilizes AWS Amplify to build the AppSync GraphQL API the front-end uses to receive data.

*Make sure you have [configured the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html) prior to following these instructions as several steps assume you gave defined credentials for your default AWS account.*

**Clone this code repository**

```
$ git clone git@github.com:aws-samples/aws-serverless-fullstack-swift-apple-carplay-example.git
```

**Switch to the project's CDK folder**

```
$ cd aws-serverless-fullstack-swift-apple-carplay-example/cdk
```

**Install the CDK app's Node.js packages**

```
$ npm install
```

**Deploy the CDK project**

If you have not used the CDK in your AWS account you must first bootstrap the CDK.  This will configure your AWS account for interaction with the CDK.

```
$ npx cdk bootstrap
```

View the resources the CDK will deploy into your account:

```
$ npx cdk diff
```

Deploy the resources into your account.  This will create 2 Lambda functions, an Amazon Location Place Index, and a Secrets Manager secret.  The CDK will use Docker on your local machine to compile the Lambda Function Swift code into images and push them to the Amazon Elastic Container Registry (ECR).

```
$ npx cdk deploy
```

**Configure Secrets Manager with the IQ Air API Key**

The CDK created a secret in AWS Secrets Manager to hold the IQ Air API key.  Lambda will use this secret for the key to access the IQ Air API.  Use the AWS CLI to update the secret with the API key you obtained from the IQ Air site.

Replace the values in brackets with your values:

```
$ aws secretsmanager put-secret-value --secret-id SwiftCarplayAPISecret --secret-string [your IQ Air API key]
```

**Initialize the CarPlay app and AWS AppSync API**

Switch to the **mobile** folder of the application:

```
$ cd ../mobile
```

Initialize the Amplify project that will create the AppSync GraphQL API

```
$ amplify init

? Enter a name for the environment (dev)
? Choose your default editor: (Xcode Mac OS only)
? Select the authentication method you want to use: (AWS profile)
? Please choose the profile you want to use (default)
```

Amplify will then begin to provision your account for the project deployment. Once your account has been provisioned, entering the *amplify status* command will show you the resources Amplify will create in your account:

```
$ amplify status

  Current Environment: dev
    
┌──────────┬──────────────────────┬───────────┬───────────────────┐
│ Category │ Resource name        │ Operation │ Provider plugin   │
├──────────┼──────────────────────┼───────────┼───────────────────┤
│ Api      │ swiftcarplaylocation │ Create    │ awscloudformation │
└──────────┴──────────────────────┴───────────┴───────────────────┘
```

Deploy the API to your AWS account

```
$ amplify push

? Do you want to update code for your updated GraphQL API (Y/n) N
```

You will then see a series of output messages as Amplify builds and deploys the app's CloudFormation templates, creating the API in your AWS account. 

Resources being created in your account include:

- AppSync GraphQL API
- DynamoDB Table

**Generate the Swift client side code and credentials:**

This command will generate the Swift class and configuration files for your app to communicate with the the API.

```
$ amplify codegen models
```

## Run the CarPlay app

From the **mobile** folder of the application open the project in Xcode:

```
$ open mobile.xcodeproj
```

*Note - you can also open the project from the Xcode UI*

Once the project loads in Xcode, select an iPhone simulator from the menu bar and the "Run" arrow button to start the app.

Once the iPhone app is running in the iOS Simulator, initiate a "Freeway Drive" to simulate the user driving:

![Image description](images/carplay-freeway.jpg)

As the user's location changes:

- Select the Weather button at the bottom of the iOS app to view the weather and air quality of the current location.

- Select the Places button to view coffee, food, and fuel locations in the vicinity of the user.

- Select the Messages button to view messages sent to the user from the AWS Cloud.  Instructions for sending messages are detailed below.

If the simulator does not display the feature to simulate a Freeway Drive, ensure Location Simulation is enabled in Xcode:

From the Xcode menu select *Product -> Scheme -> Edit Scheme*

Then ensure *Core Location: Allow Location Simulation* is checked.

![Image description](images/xcode-simulate-location.jpg)

**Start the CarPlay simulator**

From the Simulator menu select I/O -> External Displays -> CarPlay:

![Image description](images/carplay-simulator.jpg)

When the CarPlay simulator screen launches select the AWS app:

![Image description](images/carplay.jpg)

The app will display a map with the user's current location.  Click the map to view the navbar buttons and select the Weather and Places buttons.

*Note - when selecting a location from the Places screen (Coffee, Food, or Fuel) the screen will display a navigation alert to "Go" to that location.  For this sample we have not implemented navigation functionality.  That is functionality you may want to add to your version of this app.*

**Send a real-time message to the application from AWS**

To send a message to the driver, logon to the AWS Console and navigate to the AppSync service.  From there select the **swiftcarplaylocation** API.

From the API screen select the **Run a Query** button.  Paste the following GraphQL mutation code into the middle query panel and click the orange Run arrow button

```
mutation MyMutation {
  createVehicleMessage(input: {
    message: "Pickup package", 
    owner: "Vehicle1", 
    timestamp: "2021-04-21T19:36:30.653Z"}
  ) {
    createdAt
    id
    message
    owner
    timestamp
    updatedAt
  }
}
```

Console screenshot:

![Image description](images/carplay-send-message.jpg)

You should see the message delivered to both the CarPlay and iPhone apps.

## Cleanup

Once you are finished working with this project, you may want to delete the resources it created in your AWS account.  

From the **mobile** folder delete the resources created by Amplify:

```
$ amplify delete
```

From the **cdk** folder delete the resources created by the CDK:

```
$ cdk destroy
```

## License

This sample code is made available under a modified MIT-0 license. See the LICENSE file.
