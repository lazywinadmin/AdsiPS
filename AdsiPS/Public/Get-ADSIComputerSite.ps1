function Get-ADSIComputerSite
{
<#
.SYNOPSIS
	Function to retrieve the AD Site of a Computer

.DESCRIPTION
	Function to retrieve the AD Site of a Computer
	
	This function does not rely on the .NET Framework to retrieve the information
	http://www.pinvoke.net/default.aspx/netapi32.dsgetsitename

	There is .NET method to get this information but only works on the local machine.
	[System.DirectoryServices.ActiveDirectory.ActiveDirectorySite]::GetComputerSite()

.PARAMETER ComputerName
	Specifies the computer name(s) that you want to know the site.

.EXAMPLE
	Get-ADSIComputerName -ComputerName TestServer01

	This will retrieve the Site of the Computer TestServer01

.EXAMPLE
	Get-ADSIComputerName -ComputerName TestServer01,TestServer02

	This will retrieve the Site of the Computers TestServer01 and TestServer02

.NOTES
	Francois-Xavier Cat
	lazywinadmin.com
	@lazywinadm
	github.com/lazywinadmin/ADSIPS
	
	Thanks to the Reddit folks for their help! :-)
	https://www.reddit.com/r/PowerShell/comments/4cjdk8/get_the_ad_site_name_of_a_computer/

#>
	
	[CmdletBinding()]
	[OutputType('System.Management.Automation.PSCustomObject')]
	param
	(
        [parameter()]
		[String[]]$ComputerName=$env:computername
	)
	
	BEGIN
	{
		$code = @"
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;

public static class NetApi32 {
    private class unmanaged {
        [DllImport("NetApi32.dll", CharSet=CharSet.Auto, SetLastError=true)]
        internal static extern UInt32 DsGetSiteName([MarshalAs(UnmanagedType.LPTStr)]string ComputerName, out IntPtr SiteNameBuffer);

        [DllImport("Netapi32.dll", SetLastError=true)]
        internal static extern int NetApiBufferFree(IntPtr Buffer);
    }

    public static string DsGetSiteName(string ComputerName) {
        IntPtr siteNameBuffer = IntPtr.Zero;
        UInt32 hResult = unmanaged.DsGetSiteName(ComputerName, out siteNameBuffer);
        string siteName = Marshal.PtrToStringAuto(siteNameBuffer);
        unmanaged.NetApiBufferFree(siteNameBuffer);
        if(hResult == 0x6ba) { throw new Exception("ComputerName not found"); }
        return siteName;
    }
}
"@
		
		Add-Type -TypeDefinition $code
	}
	PROCESS
	{
		FOREACH ($Computer in $ComputerName)
		{
			TRY
			{
				[PSCustomObject][ordered]@{
					ComputerName = $Computer
					SiteName = [NetApi32]::DsGetSiteName($Computer)
				}
			}
			CATCH
			{
				Write-Error -Message "[Get-ADSIComputerSite][PROCESS] Something wrong happened when quering $Computer"
				$Error[0].Exception.Message
			}
		}
	}
}
