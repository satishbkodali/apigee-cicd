node {
 try {
  notifySlack()

//  stage('Preparation') {
//   mvnHome = tool 'm2'
//   host = "https://assertible.com/deployments"
//  }

   stage('Clone repo and clean it') {
   mvnHome = tool 'maven2'
   env.WORKSPACE = pwd
   echo env.WORKSPACE
   sh """
      if [ -d apigee-cicd ]; then rm -Rf apigee-cicd; fi
	  git clone https://github.com/satish1240/apigee-cicd.git
	  mvn clean -f apigee-cicd/cicd-api
	  """	
  }


  stage('Policy-Code Analysis') {
   // Run the maven build
   env.NODEJS_HOME = "${tool 'nodejs'}"
   echo env.NODEJS_HOME
   sh "npm -v"
   sh "apigeelint -s apigee-cicd/cicd-api/apiproxy/ -f table.js"
  }

  stage('Promotion') {
   timeout(time: 2, unit: 'DAYS') {
    input 'Do you want to Approve?'
   }
  }
  
  stage('Deploy to Production') {
   // Run the maven build
   sh "mvn -f apigee-cicd/cicd-api/ install -P prod -D username=$ae_username -D password=$ae_password -D org=$ae_org"
  }
  try {
   stage('Integration Tests') {
    // Run the maven build
     // Copy the features to npm directory in case of cucumber not found error
     //sh "cp $WORKSPACE/hr-api/test/features/prod_tests.feature /usr/lib/node_modules/npm"
    sh """
	    cd apigee-cicd/cicd-api/test
		./node_modules/cucumber/bin/cucumber-js --format json:reports.json feature
	   """
   }
  } catch (e) {
   //if tests fail, I have used an shell script which has 3 APIs to undeploy, delete current revision & deploy previous revision
   sh "${env.WORKSPACE}/undeploy.sh"
   throw e
  } finally {
   // generate cucumber reports in both Test Pass/Fail scenario
   // to generate reports, cucumber plugin searches for an *.json file in Workspace by default
   sh "cd /usr/lib/node_modules/npm && yes | cp -rf reports.json ${env.WORKSPACE}/apigee-cicd"

  }
 } catch (e) {
  currentBuild.result = 'FAILURE'
  throw e
 } finally {
  notifySlack(currentBuild.result)
 }
}



def notifySlack(String buildStatus = 'STARTED') {
 // Build status of null means success.
 cucumber '**/*.json'
 buildStatus = buildStatus ? : 'SUCCESS'

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