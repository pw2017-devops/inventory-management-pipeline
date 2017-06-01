package com.pega.pw2017

/**
 * Created by vagrant on 6/1/17.
 */
class FileFinder {

    static String findFile(File baseDir, String fileName) {
        def files = new FileNameFinder().getFileNames(baseDir.toString(), "**/${fileName}")

        if (files != null && files.size() == 1) {
            return files[0]
        } else {
            throw new RuntimeException("File not found! ${fileName}")
        }
    }
}
