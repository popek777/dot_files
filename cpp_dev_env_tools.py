import os
import subprocess

SOURCE_EXTENSIONS = [ '.cpp', '.cxx', '.cc', '.c', '.C', '.m', '.mm' ]
HEADER_EXTENSIONS = [ '.h', '.hxx', '.hpp', '.hh' ]

class CompanionFinder:
    def __init__(
            self, 
            file_path, 
            extensions, 
            in_subpath_pattern,
            companion_file_subpath_pattern):

        file_path = os.path.abspath(file_path)
        if os.path.islink(file_path):
            # since python reads link relatively to link directory, adjustment
            # needs to be done 
            file_path  = os.path.join(
                os.path.dirname(file_path),
                os.readlink(file_path))

        self.file_path_no_ext = os.path.splitext(file_path)[0]
        self.extensions = extensions
        self.in_subpath_pattern = in_subpath_pattern
        self.companion_file_subpath_pattern = companion_file_subpath_pattern

    def find(self, find_dir, file_pattern):
        paths = subprocess.check_output(
            "find " + find_dir + " -iname '" + file_pattern + "'", shell=True).splitlines()
        return paths[0] if len(paths) > 0 else None

    def tryToFindCompanionIn(self, find_dir):
        base_filename = os.path.basename(self.file_path_no_ext)
        for extension in self.extensions:
            cf = self.find(find_dir, base_filename + extension)
            if cf is not None:
                return cf
        return None


    def tryFindCompanionInGrandDir(self):
        # finaly try find in one of 'grand-sester' directory 
        base_filename = os.path.basename(self.file_path_no_ext)
        grand_dir = os.path.dirname(os.path.dirname(self.file_path_no_ext))
        project_root_dir = os.getcwd()
        grand_dir = os.path.relpath(grand_dir, project_root_dir)
        while True:
            if grand_dir == '/' or len(grand_dir) == 0:
              break

            cf = self.tryToFindCompanionIn(grand_dir)
            if cf is not None:
                return cf 

            grand_dir = os.path.dirname(grand_dir)
        
        return None


    def tryToFindAnyCompanionInTheSameDirectory(self):
        file_parent_dir = os.path.dirname(self.file_path_no_ext)
        for extension in self.extensions:
            any_def_file = self.find(file_parent_dir, '*' + extension)
            if any_def_file is not None:
                return any_def_file
        return None


    def tryToFindAnyCompanionInCompanionDirectory(self):
        start, mid, end = self.file_path_no_ext.rpartition(self.in_subpath_pattern)
        companion_subdir = start + self.companion_file_subpath_pattern
        if len(mid) > 0 and os.path.exists(companion_subdir):
            for extension in self.extensions:
                any_def_file = self.find(companion_subdir, '*' + extension)
                if any_def_file is not None:
                    return any_def_file 

        return None


    def getStrictCompanion(self):
        # try match in the same directory
        for extension in self.extensions:
          cf = self.file_path_no_ext + extension
          if os.path.exists(cf):
            return cf

        # try to find in companion dir
        start, mid, end = self.file_path_no_ext.rpartition(self.in_subpath_pattern)
        if len(mid) > 0: 
            # try match in companion dir
            companion_subdir = start + self.companion_file_subpath_pattern
            for extension in self.extensions:
              cf = companion_subdir + end + extension
              if os.path.exists(cf):
                return cf

            # try find in companion dir
            if os.path.exists(companion_subdir):
                cf = self.tryToFindCompanionIn(companion_subdir)
                if cf is not None:
                    return cf 

            # try find in start dir
            cf = self.tryToFindCompanionIn(start)
            if cf is not None:
                return cf 

        return None

    def getLooseCompanion(self):
        cf = self.getStrictCompanion()
        return cf if cf is not None else self.tryFindCompanionInGrandDir()


# functions
def hasExtension(file_path, extensions):
  return os.path.splitext(file_path)[1] in extensions


def getCompanionFinder(file_path):
  if hasExtension(file_path, HEADER_EXTENSIONS):
    return CompanionFinder(
            file_path, 
            SOURCE_EXTENSIONS, 
            '/include/',
            '/src/')
  elif hasExtension(file_path, SOURCE_EXTENSIONS):
    return CompanionFinder(
            file_path, 
            HEADER_EXTENSIONS, 
            '/src/', 
            '/include/')
  else:
    return None


def isHeader(file_path):
    return hasExtension(file_path, HEADER_EXTENSIONS)
