<#
.SYNOPSIS
  Automation script for running TestNG test suites with Maven which uses .csv file as an imput data
.DESCRIPTION
  The script reads 'TestNG_suites_location.csv' from 'data' directory, parses it, then spawnes an instance of command line interpreter and passes required arguments to it to run TestNG test suites
.PARAMETER Line
  Line server against wich tests will be run (passed to Maven as a parametr), 'q1' by default
.PARAMETER PathToMavenProjectDirectory
  Absolute path to root directory of a Maven project
.PARAMETER PathToCsvFile
  Absolute path to a .csv file with input data, by default it is located in subdirectory 'data' of the same directory as the script is located and its file name is 'TestNG_suites_location.csv'
.EXAMPLE
  .\Run-TestNGSuites.ps1 -Line 'd1' -PathToMavenProjectDirectory 'D:\Test\Maven\'
.LINK
  https://github.com/m-a-ge/notes/tree/master/utility_scripts
#>

Param(
  [string]$Line = 'q1',
  [string]$PathToMavenProjectDirectory,
  [string]$PathToCsvFile = $PSScriptRoot + '\data\TestNG_suites_location.csv'
)
  
$LINE_SERVER = $Line                                                            # line server (passed to Maven)
$MAVEN_PROJECT_ROOT = $PathToMavenProjectDirectory                              # root directory of a Maven project (where pom.xl is located)
$PATH_TO_TESTNG_SUITE_CSV = $PathToCsvFile                                      # contains location of failed TestNG suites


function Spawn-Process {
  Param(
    [Parameter(Mandatory=$true)][string]$PathToExecutable,         # full path to executable to run
    [string]$ArgumentList,             # list of arguments which will be passed to executable
    [string]$RedirectOutputToFile      # full path to file in which output will be redirected
  );

  "Starting a new process:"
     $PathToExecutable  
  "with the following arguments:" 
     $ArgumentList
  "output is redirected to:" 
     $RedirectOutputToFile

  If ($ArgumentList -and $RedirectOutputToFile) {
    Start-Process -FilePath $PathToExecutable -ArgumentList $ArgumentList -RedirectStandardOutput $RedirectOutputToFile
  } elseif ($ArgumentList -and !$RedirectOutputToFile) {
    Start-Process -FilePath $PathToExecutable -ArgumentList $ArgumentList
  } elseif ($RedirectOutputToFile -and !$ArgumentList) {
    Start-Process -FilePath $PathToExecutable -RedirectStandardOutput $RedirectOutputToFile
  }
}


function Read-Csv {
  Param([string]$PathToCsvFile)

  If (!$PathToCsvFile) {
    "No path to csv file specified, exiting..."
    return -1
  }

  return Import-Csv -Path $PathToCsvFile
}


function main {
  # reading csv file
  $test_suites_csv = Read-Csv -PathToCsvFile $PATH_TO_TESTNG_SUITE_CSV
  # parsing .csv file contents
  foreach($line in $test_suites_csv)
  { 
      $full_suite_name = ''
      # header of .csv file shouldn't be changed since its values are hard coded
      $dir = $line | Select-Object -ExpandProperty 'directory' 
      $name = $line | Select-Object -ExpandProperty 'name'
      
      # generating the full TestNG suite name
      $full_suite_name = $dir + '/' + $name

      # starting an instance of CLI and passing required arguments (based on .csv file)
      Spawn-Process -PathToExecutable ($env:windir + '\System32\cmd.exe') -ArgumentList ('/K cd ' + $dir + ' & echo "mvn verify -DLine=' + $LINE_SERVER + ' -Dsuite.folder=' + $dir + ' -Dintegration.type=' + $name + '" >> ' + $PSScriptRoot + '\' + $name)

      # an example of how to run a TestNG suite with Maven
      # starting an instance of CLI and passing required arguments to run TestNG suites using Maven (based on .csv file)
      #Spawn-Process -PathToExecutable ($env:windir + '\System32\cmd.exe') -ArgumentList ('/K cd ' + $MAVEN_PROJECT_ROOT + ' & mvn verify -DLine=' + $LINE_SERVER + ' -Dsuite.folder=' + $dir + ' -Dintegration.type=' + $name + ' & exit') + -RedirectOutputToFile ($PSScriptRoot + '\' + $full_suite_name + '.log')
  }
}


main