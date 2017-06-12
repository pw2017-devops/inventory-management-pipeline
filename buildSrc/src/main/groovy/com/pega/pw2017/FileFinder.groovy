package com.pega.pw2017

/*
* Copyright (c) 2017 and Confidential to Pegasystems Inc. All rights reserved.  
*/ 

class FileFinder {

    static String findFile(File baseDir, String fileName) {
        return findFile(baseDir.toString(), fileName)
    }

    static String findFile(String baseDir, String fileName) {
        def files
        try {
            files = new FileNameFinder().getFileNames(baseDir, "**/${fileName}")
        } catch (Throwable th) {
            return "not exist"
        }

        if (files != null && files.size() == 1) {
            return files[0]
        } else {
            return "not found"
        }
    }

    static String insureFileExists(File theFile) {
        if (!theFile.exists()) {
            File parentFile = theFile.getParentFile()
            if (parentFile != null) {
                parentFile.mkdirs()
            }

            theFile.createNewFile()
        }

        theFile.toString()
    }

    static String insureDirectoryExists(String theDirectory) {
        return insureDirectoryExists(new File(theDirectory))
    }

    static String insureDirectoryExists(File theDirectory) {
        if (!theDirectory.exists()) {
            theDirectory.mkdirs()
        }

        theDirectory.toString()
    }
}
