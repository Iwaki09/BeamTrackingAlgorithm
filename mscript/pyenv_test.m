clear all;
terminate(pyenv)
% pyenv(ExecutionMode="InProcess")
% pe = pyenv(Version="/Users/iwakiryo2/.pyenv/versions/3.10.12/bin/python")
pe = pyenv("Version", "/Users/iwakiryo2/.pyenv/shims/python")
% pyrunfile("pyenv_test.py", "df")
% py = pyenv;
% pe.Version

% search_way = pyrunfile("svm_for_matlab.py", "res", dist=20, speed=20, accel=20)
% pyenv(ExecutionMode="OutOfProcess")
py.list({"Monday","Tuesday","Wednesday","Thursday","Friday"});
% pyrun(["print('Hello World')"])
