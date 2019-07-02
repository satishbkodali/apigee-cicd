//stable
node {
 try {
 

  notifySlack()
  
   stage('Clone repo and clean it') {
   mvnHome = tool 'maven2'
   env.WORKSPACE = pwd()
   echo env.WORKSPACE
   //Clone git repo
   bat "IF EXIST apigee-cicd RMDIR /S /Q apigee-cicd"
   bat "git clone https://github.com/satish1240/apigee-cicd.git"
   bat "mvn clean -f apigee-cicd/cicd-api"   
  }


//  stage('Unit testing') {
//   sh "curl -u apikey: 'https://assertible.com/deployments' //  -d'{\"service\":\"d8d73-b0a94b325ae4\",\"environmentName\":\"production\",\"version\":\"v1\"}'"
//  }


  stage('Build started') {
  }
  stage('Policy-Code Analysis') {
   env.NODEJS_HOME = "${tool 'nodejs'}"
   echo env.NODEJS_HOME   
   //run apigeelint to anlaysis code scan   
   env.apigeelint="C:\\Users\\847763\\AppData\\Roaming\\npm\\apigeelint"


   bat "npm -v"
   bat "apigeelint -s apigee-cicd\\cicd-api\\apiproxy -f table.js"
  }
  // Approve or not to promote the API
  stage('Promotion') {
   timeout(time: 2, unit: 'DAYS') {
    input 'Do you want to Approve?'
   }
  }
  stage('Deploy to Production') {
   // Run the maven build to deploy to prod
   bat "mvn -f apigee-cicd/cicd-api/ install -P prod -D username=$ae_username -D password=$ae_password -D org=$ae_org"
  }
  
  try {
   stage('Integration Tests') {
	 // npm install the apickli and cucumber
	bat """
		cd apigee-cicd/cicd-api/test
		npm install
		"""
     // run the cucumber for unit tests and run the tests		
	bat """
		cd ${env.WORKSPACE}/apigee-cicd/cicd-api/test/node_modules/.bin
		cucumber-js --format json:${env.WORKSPACE}/reports.json ${env.WORKSPACE}/apigee-cicd/cicd-api/test/features
		"""	 
	 

   }
  } catch (e) {
   //if tests fail, I have used an shell script which has 3 APIs to undeploy, delete current revision & deploy previous revision
   sh "$WORKSPACE/undeploy.sh"
   throw e
  } finally {
   // generate cucumber reports in both Test Pass/Fail scenario
   // to generate reports, cucumber plugin searches for an *.json file in Workspace by default
//            bat "cd apigee-cicd/cicd-api/test/features && copy  reports.json         ${env.WORKSPACE}/apigee-cicd"
             // run cucumber reports from workspace home
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