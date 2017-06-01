package com.pega.pw2017

import org.gradle.api.Project

class ResultHandler {

    static final String FILE_NAME = "results.properties"

    Project project

    Properties theProperties;

    File resultsDir

    ResultHandler(Project project) {
        resultsDir = project.buildDir
    }

    void putResult(String key, String value) {
        loadProperties()
        theProperties.put(key, value)
        saveProperties()
    }

    String getResult(String key) {
        loadProperties()
        return theProperties.get(key)
    }

    private void loadProperties() {
        Properties properties = getTheProperties()
        def propertiesFile = new File(resultsDir, FILE_NAME)
        if (propertiesFile.exists()) {
            propertiesFile.withInputStream {
                properties.load(it)
            }
        }
    }

    private void saveProperties() {
        def propertiesFile = new File(resultsDir, FILE_NAME)
        insureFileExists(propertiesFile)
        theProperties.store(propertiesFile.newWriter(), null)
    }

    private void insureFileExists(File theFile) {
        if (!theFile.exists()) {
            File parentFile = theFile.getParentFile()
            if (parentFile != null) {
                parentFile.mkdirs()
            }

            theFile.createNewFile()
        }
    }

    public Properties getTheProperties() {
        if (theProperties == null) {
            theProperties = new Properties()
        }

        return theProperties
    }
}