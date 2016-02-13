<#
.SYNOPSIS
  Measures an average response time to a remote hosts and forms the resulting table
.DESCRIPTION
  The script uses Test-Connection Cmdlt which sends Internet Control Message Protocol (ICMP) echo request packets ("pings"), calculates the average response time in turn and forms the resulting table showing the host with the lowest value at the top.
.PARAMETER hosts
  The list of hosts you want to test
.PARAMETER count
  The number of pings send to a remote host, 100 by default
.EXAMPLE
  Get-AvgPingResponseTime -hosts 8.8.8.8, 8.8.4.4 -count 10
.LINK
  https://github.com/m-a-ge/utilities
#>

param(
  [Parameter(Mandatory=$true)][string[]]$hosts,
  [string]$count = 100
)

$results = @{}

"`n"
foreach ($hostIp in $hosts) {
  "Starting testing $hostIp"
  $pingResults = Test-Connection $hostIp -count $count -ErrorVariable errorCount -ErrorAction SilentlyContinue
  $avgPingTime = ($pingResults | Measure-Object ResponseTime -average) # measuring the average time
  $roundedAvgPingTime = [System.Math]::Round($avgPingTime.average)
  if ($errorCount.count -le 0) {
    # if there were no errors
    "Ran $count tests without errors"
  } else {
    $percentOfErros = $errorCount.count/$count*100
    "$percentOfErros% error rate"
    # if the error rate is more than 10% exclude the host from testing
    if ($percentOfErros -gt 10) {
      "$hostIp is excluded from testing due to high error rate"
      "`n"
      continue
    }
    "`n"
  }

  $results.Add($hostIp, $roundedAvgPingTime)
  "`n"
}

"Final Results:"
# sort results in ascending order and form a table
$results.GetEnumerator() | Sort-Object -property Value | Format-Table -AutoSize