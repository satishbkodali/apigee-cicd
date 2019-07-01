node {
 try {
 

  notifySlack()
  
   stage('Clone repo and clean it') {
   mvnHome = tool 'maven2'
//   host = "https://assertible.com/deployments"
   env.WORKSPACE = pwd()
   echo env.WORKSPACE
   env.pf = "%ProgramFiles(x86)%/Jenkins/workspace/APG-Test"


	bat "IF EXIST apigee-cicd RMDIR /S /Q apigee-cicd"
  // bat "rmdir /s /q apigee-cicd  2>nul"
   bat "git clone https://github.com/satish1240/apigee-cicd.git"
   bat "mvn clean -f apigee-cicd/cicd-api"   
//	bat """
//		cd apigee-cicd\\cicd-api\\test
//		npm install
//		cd ${env.WORKSPACE}
//		"""

	
  }


//  stage('Unit testing') {
//   sh "curl -u apikey: 'https://assertible.com/deployments' //  -d'{\"service\":\"d8d73-b0a94b325ae4\",\"environmentName\":\"production\",\"version\":\"v1\"}'"
//  }


  stage('Build started') {
  }
  stage('Policy-Code Analysis') {
   // Run the maven build

   env.NODEJS_HOME = "${tool 'nodejs'}"
   echo env.NODEJS_HOME    
   env.apigeelint="C:\\Users\\847763\\AppData\\Roaming\\npm\\apigeelint"
   
   env.PATH = "${env.NODEJS_HOME}/bin:${env.PATH}"
   echo env.PATH

   bat "npm -v"
   bat "apigeelint -s apigee-cicd\\cicd-api\\apiproxy -f table.js"
  }

  stage('Promotion') {
   timeout(time: 2, unit: 'DAYS') {
    input 'Do you want to Approve?'
   }
  }
  stage('Deploy to Production') {
   // Run the maven build
   bat "mvn -f apigee-cicd/cicd-api/ install -P prod -D username=$ae_username -D password=$ae_password -D org=$ae_org"
  }
  try {
   stage('Integration Tests') {
    // Run the maven build
    env.NODEJS_HOME = "${tool 'nodejs'}"
    env.PATH = "${env.NODEJS_HOME}/bin:${env.PATH}"

     // Copy the features to npm directory in case of cucumber not found error
     //sh "cp $WORKSPACE/hr-api/test/features/prod_tests.feature /usr/lib/node_modules/npm"
	bat """
		cd ${env.NODEJS_HOME}/node_modules/.bin
		cucumber-js --format json:reports.json  ..\..\..\..\..\workspace\APG-Test/apigee-cicd/cicd-api/test/features/prod_tests.feature
		copy reports.json ${env.WORKSPACE}/apigee-cicd/cicd-api/test/features
		del /f reports.json
		"""	 
	 

   }
  } catch (e) {
   //if tests fail, I have used an shell script which has 3 APIs to undeploy, delete current revision & deploy previous revision
   sh "$WORKSPACE/undeploy.sh"
   throw e
  } finally {
   // generate cucumber reports in both Test Pass/Fail scenario
   // to generate reports, cucumber plugin searches for an *.json file in Workspace by default
            bat "cd apigee-cicd/cicd-api/test/features && copy -rf reports.json ${env.WORKSPACE}"
            cucumber fileIncludePattern: 'reports.json'
   
 

  }
 } catch (e) {
  currentBuild.result = 'FAILURE'
  throw e
 } finally {
  notifySlack(currentBuild.result)
     bat "mvn clean -f apigee-cicd/cicd-api" 
 }
}



def notifySlack(String buildStatus = 'STARTED') {
 // Build status of null means success.
    env.WORKSPACE = pwd()

 cucumber '**/*.json'
 buildStatus = buildStatus ?: 'SUCCESS'

 def color

 if (buildStatus == 'STARTED') {
  color = '#636363'
 } else if (buildStatus == 'SUCCESS') {
  color = '#47ec05'
 } else if (buildStatus == 'UNSTABLE') {
  color = '#d5ee0d'
 } else {
  color = '#ec2805'
 }

 def msg = "${buildStatus}: `${env.JOB_NAME}` #${env.BUILD_NUMBER}:\n${env.BUILD_URL}"

 slackSend(color: color, message: msg)
}