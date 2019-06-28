node {
 try {
  notifySlack()

  stage('Clone repo and clean it') {
   mvnHome = tool 'maven2'
//   host = "https://assertible.com/deployments"
   env.WORKSPACE = pwd()
   echo env.WORKSPACE
   bat "SET F=`${env.WORKSPACE}/apigee-cicd`"

	bat "IF EXIST %F% RMDIR /S /Q %F%"
  // bat "rmdir /s /q apigee-cicd  2>nul"
   bat "git clone https://github.com/satish1240/apigee-cicd.git"
   bat "mvn clean -f apigee-cicd"   


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
   env.PATH = "${env.NODEJS_HOME}/bin:${env.PATH}"
   echo env.PATH
   bat "npm -v"
   bat "apigeelint -s /usr/lib/node_modules/npm/apigee-ci-deploy-bdd-lint-master/cicd-api/apiproxy/ -f table.js"
  }

  stage('Promotion') {
   timeout(time: 2, unit: 'DAYS') {
    input 'Do you want to Approve?'
   }
  }
  stage('Deploy to Production') {
   // Run the maven build
   sh "'${mvnHome}/bin/mvn' -f /usr/lib/node_modules/npm/apigee-ci-deploy-bdd-lint-master/hr-api/pom.xml install -Pprod -Dusername=<email_here> -Dpassword=<password_here>"
  }
  try {
   stage('Integration Tests') {
    // Run the maven build
    env.NODEJS_HOME = "${tool 'nodejs'}"
    env.PATH = "${env.NODEJS_HOME}/bin:${env.PATH}"
     // Copy the features to npm directory in case of cucumber not found error
     //sh "cp $WORKSPACE/hr-api/test/features/prod_tests.feature /usr/lib/node_modules/npm"
    sh "cd /usr/lib/node_modules/npm && cucumber-js --format json:reports.json features/prod_tests.feature"
   }
  } catch (e) {
   //if tests fail, I have used an shell script which has 3 APIs to undeploy, delete current revision & deploy previous revision
   sh "$WORKSPACE/undeploy.sh"
   throw e
  } finally {
   // generate cucumber reports in both Test Pass/Fail scenario
   // to generate reports, cucumber plugin searches for an *.json file in Workspace by default
   sh "cd /usr/lib/node_modules/npm && yes | cp -rf reports.json ${env.WORKSPACE}"

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