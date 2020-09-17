# Work-Specific profile (currently @ Microsoft)

${function:cd-Locations} = { cd "${env:INETROOT}\sources\dev\Calendar\src\Locations" }

function powerline() {
    # For some reason 'opening a cmd shell > initGriffin > powershell' causes posh-git to load REALLY slow
    # so instead we'll define our prompt in this `powerline` function to be applied whenever it's safe to do so
    Import-Module Posh-Git
    Import-Module Oh-My-Posh
    Set-Theme Paradox
}

function DeployDll-CalendarLocations($tdsIp) {
    Copy-Item "${env:INETROOT}\target\dev\calendar\Microsoft.O365.Calendar.Locations\debug\amd64\Microsoft.O365.Calendar.Locations.*" `
              "\\$tdsIp\D$\MicroService\Locations\bin" -Exclude *.config
}