Automation script designed for  running TestNG test suites with Maven which uses `.csv` file as an input data

The script reads 'TestNG_suites_location.csv' from 'data' directory (by default), parses it, then spawns an instance of command line interpreter and passes required arguments to it to run TestNG test suites with Maven

Parameters: 

* `-Line`:
  Line server against wich tests will be run (passed to Maven as a parameter), `q1` by default
* `-PathToMavenProjectDirectory`:
  Absolute path to root directory of a Maven project
* `-PathToCsvFile`:
  Absolute path to a `.csv` file with input data, by default it is located in subdirectory `data` of the same directory as the script is located and its file name is `TestNG_suites_location.csv`; you can specify a different file using respective parameter

Example:
```PowerShell
.\Run-TestNGSuites.ps1 -Line 'd1' -PathToMavenProjectDirectory 'D:\Test\Maven\Demo'
```