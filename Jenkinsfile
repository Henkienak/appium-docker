#!groovy

import org.codehaus.groovy.runtime.*;

properties([
	parameters([
		string(description: 'Desired appium version to be built', name: 'APPIUM_VERSION'), 
		booleanParam(defaultValue: true, description: 'Push appium image to remote', name: 'PUSH_IMAGE')
])])

node {

	deleteDir()

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
			docker.image('node:8.9.4').inside {
				installJava()
				installAppium()
				moveAppium()
				addIfWDAExists(params.APPIUM_VERSION)
				copyNodeBinaries()
			}
			sh "docker build -t testobject-appium:${params.APPIUM_VERSION} --build-arg APPIUM_VERSION=${params.APPIUM_VERSION}"
		} catch (err) {
			notifySlack("Appium build of `${params.APPIUM_VERSION}` failed: ${err}", "bad")
			throw err
		}
	}

	stage("push") {
		try {
			if (params.PUSH_IMAGE) {
				sh "docker tag testobject-appium:${params.APPIUM_VERSION} testobject/appium:${params.APPIUM_VERSION}"
				sh "docker push testobject/appium:${params.APPIUM_VERSION}"
			}
			
		} catch (err) {
			notifySlack("Appium push of `${params.APPIUM_VERSION}` failed: ${err}", "bad")
			throw err
		}
	}

	deleteDir() // don't want to waste space after a build
	notifySlack("Build Appium Version `${params.APPIUM_VERSION}` successful")
}
def copyNodeBinaries() {
	echo "Copying node"
	// Add the binaries from repo. This is necessary since we support linux and osx at the same time
	sh "mkdir -p appium/node/linux/bin"
	sh "mkdir -p appium/node/osx/bin"
	sh "cp node/linux/bin/node appium/node/linux/bin"
	sh "cp node/osx/bin/node appium/node/osx/bin"
}
def installJava() {
	sh "apt-get update"
	sh "apt-get -y install default-jdk"
}

def installAppium() {
	sh "npm install --legacy-bundling appium@${params.APPIUM_VERSION}"
	echo "Removing dev packages"
	sh "cd node_modules/appium && npm prune --production"
}

def moveAppium() {
	sh "cp -r node_modules/appium/. appium"
	sh "mkdir -p appium/build/SafariLauncher"
	sh "cp --no-clobber SafariLauncher.zip appium/build/SafariLauncher/SafariLauncher.zip"
}

def addIfWDAExists(String appiumVersion) {
	if (fileExists("WDA/${appiumVersion}/WebDriverAgent.ipa")) {
		sh "rm -r appium/node_modules/appium-xcuitest-driver/WebDriverAgent"
		sh "cp WDA/${appiumVersion}/WebDriverAgent.ipa appium/node_modules/appium-xcuitest-driver/WebDriverAgent.ipa"
	} else {
		echo "No WDA version exists for this appium version"
	}
}

def notifySlack(def message, def color = "good") {
	slackSend channel: "#${env.SLACK_CHANNEL}", color: color, message: message + " (<${env.BUILD_URL}|open>)", teamDomain: "${env.SLACK_SUBDOMAIN}", token: "${env.SLACK_TOKEN}"
}
