#!groovy

import org.codehaus.groovy.runtime.*;

properties([
	parameters([
		string(description: 'Desired appium version to be built', name: 'APPIUM_VERSION'), 
		booleanParam(defaultValue: false, description: 'used patched chromedriver', name: 'PATCHED_CHROMEDRIVER'),
		string(description: 'desired chromedriver version', name: 'CHROMEDRIVER_VERSION'),
		booleanParam(defaultValue: true, description: 'Push appium image to remote', name: 'PUSH_IMAGE')
])])

node {

    deleteDir()

    def tag = params.APPIUM_VERSION

	if (params.PATCHED_CHROMEDRIVER) {
		println "Using patched chromedriver for `${params.APPIUM_VERSION}` "
		tag += "-patched-chromedriver" 
	}

	if (params.CHROMEDRIVER_VERSION) {
		println "Using custom chromedriver version `${params.APPIUM_VERSION}` "
		tag += "-updated-chromedriver"
	}

    stage("checkout") {
        try {
            checkout scm
        } catch (err) {
            notifySlack("Checkout failed: ${err}", "bad")
            throw err
        }
    }

    stage("build") {
        try {
			def dockerBuildCommand = "docker build -t testobject-appium:${tag} --build-arg APPIUM_VERSION=${params.APPIUM_VERSION} --build-arg DIR_NAME=${params.APPIUM_VERSION} --build-arg PATCHED_CHROMEDRIVER=${PATCHED_CHROMEDRIVER}"
			
			if (params.CHROMEDRIVER_VERSION) {
				dockerBuildCommand += " --build-arg CHROMEDRIVER_VERSION=${params.CHROMEDRIVER_VERSION}"
			}

			dockerBuildCommand += " ."
			sh dockerBuildCommand
			
        } catch (err) {
            notifySlack("Appium build of `${params.APPIUM_VERSION}` failed: ${err}", "bad")
            throw err
        }
    }

	stage("push") {
        try {
			if (params.PUSH_IMAGE) {
				sh "docker tag testobject-appium:${tag} testobject/appium:${tag}"
    			sh "docker push testobject/appium:${tag}"
			}
			
        } catch (err) {
            notifySlack("Appium push of `${params.APPIUM_VERSION}` failed: ${err}", "bad")
            throw err
        }
    }

    deleteDir() // don't want to waste space after a build
    notifySlack("Build Appium Version `${tag}` successful")

}

def notifySlack(def message, def color = "good") {
    slackSend channel: "#${env.SLACK_CHANNEL}", color: color, message: message + " (<${env.BUILD_URL}|open>)", teamDomain: "${env.SLACK_SUBDOMAIN}", token: "${env.SLACK_TOKEN}"
}
