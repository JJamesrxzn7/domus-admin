# Parse PDM and extract tables, columns, keys, references
[xml]$pdm = Get-Content -Raw "PhysicalDataModel_4.pdm"
$tables = $pdm.SelectNodes("//*[local-name()='Table' and *[local-name()='Code']]")

$lines = @()
$lines += "# MODEL SUMMARY"
$lines += "Total tables found: $($tables.Count)"

foreach ($t in $tables) {
    $tCode = $t.SelectSingleNode("*[local-name()='Code']").InnerText
    $tName = $t.SelectSingleNode("*[local-name()='Name']").InnerText
    $lines += "`n### Table: $tCode ($tName)"
    
    $cols = $t.SelectNodes("*[local-name()='Columns']/*[local-name()='Column']")
    foreach ($c in $cols) {
        $cCode = $c.SelectSingleNode("*[local-name()='Code']").InnerText
        $cType = $c.SelectSingleNode("*[local-name()='DataType']").InnerText
        $mandNode = $c.SelectSingleNode("*[local-name()='Column.Mandatory']")
        $mand = if ($mandNode -and $mandNode.InnerText -eq '1') { "NOT NULL" } else { "NULL" }
        $lines += "  - $cCode : $cType $mand"
    }
}

$refs = $pdm.SelectNodes("//*[local-name()='Reference' and *[local-name()='Code']]")
$lines += "`n# REFERENCES / RELATIONSHIPS ($($refs.Count))"
foreach ($r in $refs) {
    $rCode = $r.SelectSingleNode("*[local-name()='Code']").InnerText
    $pTableNode = $r.SelectSingleNode("*[local-name()='ParentTable']/*[local-name()='Table']")
    $cTableNode = $r.SelectSingleNode("*[local-name()='ChildTable']/*[local-name()='Table']")
    $pRef = if ($pTableNode) { $pTableNode.GetAttribute("Ref") } else { "" }
    $cRef = if ($cTableNode) { $cTableNode.GetAttribute("Ref") } else { "" }
    
    $pTable = $pdm.SelectSingleNode("//*[@Id='$pRef']/*[local-name()='Code']")
    $cTable = $pdm.SelectSingleNode("//*[@Id='$cRef']/*[local-name()='Code']")
    
    $pName = if ($pTable) { $pTable.InnerText } else { $pRef }
    $cName = if ($cTable) { $cTable.InnerText } else { $cRef }
    
    $lines += "  - $rCode : $cName -> $pName"
}

$lines | Out-File -FilePath "pdm_summary.txt" -Encoding utf8
Write-Output "Extracted $($tables.Count) tables and $($refs.Count) references."

