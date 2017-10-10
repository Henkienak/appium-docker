#!groovy

import org.codehaus.groovy.runtime.*;

properties([
	parameters([
		string(description: 'Desired appium version to be built', name: 'APPIUM_VERSION'), 
		booleanParam(defaultValue: false, description: 'used patched chromedriver', name: 'PATCHED_CHROMEDRIVER'),
		string(description: 'desired chromedriver version', name: 'CHROMEDRIVER_VERSION')
])])

node {

    deleteDir()

    def tag = params.APPIUM_VERSION;

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

    stage("build & push") {
        try {
            docker.build("appium-builder") {
				def command = "build.sh -a ${params.APPIUM_VERSION} -d ${params.APPIUM_VERSION} -p ${params.PATCHED_CHROMEDRIVER} -t ${tag} -r true"
				if (params.CHROMEDRIVER_VERSION) {
					command += " -c ${params.CHROMEDRIVER_VERSION}"
				}

                sh command
            }
        } catch (err) {
            notifySlack("Appium build of `${params.APPIUM_VERSION}` failed: ${err}", "bad")
            throw err
        }
    }

    deleteDir() // don't want to waste space after a build
    notifySlack("Build Appium Version `${tag}` successful")

}

def notifySlack(def message, def color = "good") {
    slackSend channel: "#${env.SLACK_CHANNEL}", color: color, message: message + " (<${env.BUILD_URL}|open>)", teamDomain: "${env.SLACK_SUBDOMAIN}", token: "${env.SLACK_TOKEN}"
}
