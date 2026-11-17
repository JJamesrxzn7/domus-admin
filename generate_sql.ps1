# Generator for PostgreSQL / Standard SQL DDL & Constraints from PDM
[xml]$pdm = Get-Content -Raw "PhysicalDataModel_4.pdm"
$tables = $pdm.SelectNodes("//*[local-name()='Table' and *[local-name()='Code']]")

$ddl = @()
$ddl += "/* ==========================================================================="
$ddl += "   DOMUS FUEGO - RESTAURANTE & STEAKHOUSE"
$ddl += "   SCRIPT DE CREACION DE TABLAS Y CONSTRAINTS"
$ddl += "   Generado a partir del Modelo Fisico: PhysicalDataModel_4.pdm"
$ddl += "   Total Tablas: $($tables.Count)"
$ddl += "   =========================================================================== */`n"

$pks = @{}
$uniqueKeys = @{}

foreach ($t in $tables) {
    $tCode = $t.SelectSingleNode("*[local-name()='Code']").InnerText
    $tId = $t.GetAttribute("Id")
    $tName = $t.SelectSingleNode("*[local-name()='Name']").InnerText
    
    $ddl += "/* --------------------------------------------------------------------------"
    $ddl += "   TABLA: $tCode ($tName)"
    $ddl += "   -------------------------------------------------------------------------- */"
    $ddl += "CREATE TABLE $tCode ("
    
    $colDefs = @()
    $cols = $t.SelectNodes("*[local-name()='Columns']/*[local-name()='Column']")
    foreach ($c in $cols) {
        $cCode = $c.SelectSingleNode("*[local-name()='Code']").InnerText
        $cType = $c.SelectSingleNode("*[local-name()='DataType']").InnerText
        $mandNode = $c.SelectSingleNode("*[local-name()='Column.Mandatory']")
        $mand = if ($mandNode -and $mandNode.InnerText -eq '1') { "NOT NULL" } else { "NULL" }
        $colDefs += "    $cCode $cType $mand"
    }
    
    # Primary Key
    $pkKeyNode = $t.SelectSingleNode("*[local-name()='PrimaryKey']/*[local-name()='Key']")
    if ($pkKeyNode) {
        $keyRef = $pkKeyNode.GetAttribute("Ref")
        $keyNode = $t.SelectSingleNode(".//*[@Id='$keyRef']")
        if ($keyNode) {
            $keyColRefs = $keyNode.SelectNodes("*[local-name()='Key.Columns']/*[local-name()='Column']")
            $pkCols = @()
            foreach ($kc in $keyColRefs) {
                $cRef = $kc.GetAttribute("Ref")
                $cObj = $t.SelectSingleNode(".//*[@Id='$cRef']/*[local-name()='Code']")
                if ($cObj) { $pkCols += $cObj.InnerText }
            }
            if ($pkCols.Count -gt 0) {
                $colDefs += "    CONSTRAINT pk_$tCode PRIMARY KEY (" + ($pkCols -join ", ") + ")"
            }
        }
    }
    
    $ddl += ($colDefs -join ",`n")
    $ddl += ");`n"
}

$ddl += "/* ==========================================================================="
$ddl += "   FOREIGN KEYS & INTEGRITY CONSTRAINTS"
$ddl += "   =========================================================================== */`n"

$refs = $pdm.SelectNodes("//*[local-name()='Reference' and *[local-name()='Code']]")
foreach ($r in $refs) {
    $rCode = $r.SelectSingleNode("*[local-name()='Code']").InnerText
    $pTableNode = $r.SelectSingleNode("*[local-name()='ParentTable']/*[local-name()='Table']")
    $cTableNode = $r.SelectSingleNode("*[local-name()='ChildTable']/*[local-name()='Table']")
    $pRef = if ($pTableNode) { $pTableNode.GetAttribute("Ref") } else { "" }
    $cRef = if ($cTableNode) { $cTableNode.GetAttribute("Ref") } else { "" }
    
    $pTable = $pdm.SelectSingleNode("//*[@Id='$pRef']/*[local-name()='Code']").InnerText
    $cTable = $pdm.SelectSingleNode("//*[@Id='$cRef']/*[local-name()='Code']").InnerText
    
    # Joins
    $joins = $r.SelectNodes("*[local-name()='Joins']/*[local-name()='ReferenceJoin']")
    $pCols = @()
    $cCols = @()
    foreach ($j in $joins) {
        $pColRef = $j.SelectSingleNode("*[local-name()='Object1']/*[local-name()='Column']").GetAttribute("Ref")
        $cColRef = $j.SelectSingleNode("*[local-name()='Object2']/*[local-name()='Column']").GetAttribute("Ref")
        
        $pColName = $pdm.SelectSingleNode("//*[@Id='$pColRef']/*[local-name()='Code']").InnerText
        $cColName = $pdm.SelectSingleNode("//*[@Id='$cColRef']/*[local-name()='Code']").InnerText
        $pCols += $pColName
        $cCols += $cColName
    }
    
    if ($cCols.Count -gt 0 -and $pCols.Count -gt 0) {
        $ddl += "ALTER TABLE $cTable"
        $ddl += "    ADD CONSTRAINT $rCode FOREIGN KEY (" + ($cCols -join ", ") + ")"
        $ddl += "    REFERENCES $pTable (" + ($pCols -join ", ") + ");"
    }
}

$ddl | Out-File -FilePath "Scripts\Script-Creacion-Tablas-Constrains-DomusFuego.sql" -Encoding utf8
Write-Output "Generated Scripts\Script-Creacion-Tablas-Constrains-DomusFuego.sql successfully."

