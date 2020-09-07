#!/usr/bin/env python 

# simple test app to see if companion file can be found

import cpp_dev_env_tools
import sys

def GetCompilationInfoForFile( filename ):
  if cpp_dev_env_tools.isHeader(filename):
    finder = cpp_dev_env_tools.getCompanionFinder(filename)
    cf = finder.getStrictCompanion()
    if cf is None:
        cf = finder.tryToFindAnyCompanionInTheSameDirectory()
    if cf is None:
        cf = finder.tryFindCompanionInGrandDir()
    if cf is None:
        cf = finder.tryToFindAnyCompanionInCompanionDirectory()
    return cf;

def main():
    print 'org file %s' % sys.argv[1]
    print 'companion: %s' % GetCompilationInfoForFile(sys.argv[1])

if __name__ == "__main__":
      main()
